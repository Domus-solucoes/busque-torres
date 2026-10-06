"use strict";
(() => {
  const API = "https://wqfkysoodjyweanhsquk.supabase.co/rest/v1/empresas";
  const KEY = "sb_publishable_lpHHnebV1KE0Gj8ojfLBiw_N7wfUjIf";
  const fields = ["nome","categoria","subcategoria","descricao","whatsapp","instagram","site","email","bairro","endereco","horario","produtos","servicos","palavras_chave"];
  const columns = ["id",...fields,"cidade","cidade_id","status","ativo","created_at","updated_at"].join(",");
  const $ = id => document.getElementById(id);
  let readToken = () => null, rows = [], editingId = null, offset = 0, generation = 0, loadSequence = 0;
  function message(text, success = false) {
    $("companyMessage").textContent = text;
    $("companyMessage").className = "form-message " + (success ? "success" : "error");
    $("companyMessage").hidden = false;
  }
  async function request(params, options = {}) {
    const token = readToken();
    if (!token) throw new Error("Entre novamente para acessar as empresas.");
    const response = await fetch(API + "?" + params, { ...options, credentials: "omit", cache: "no-store",
      headers: { apikey: KEY, Authorization: "Bearer " + token, "Content-Type": "application/json", Prefer: "return=representation" }
    });
    if (!response.ok) {
      if (response.status === 401) throw new Error("Sua sessão expirou. Saia e entre novamente.");
      if (response.status === 403) throw new Error("Acesso não autorizado. Confira sua permissão administrativa.");
      const data = await response.json().catch(() => ({}));
      if (data.code === "23514") throw new Error("Confira os campos: descrição de 10 a 600 caracteres e WhatsApp de 10 a 15 dígitos.");
      throw new Error("Não foi possível concluir a operação. Confira os dados e tente novamente.");
    }
    return response.json();
  }
  function resetForm() {
    editingId = null;
    $("companyForm").reset();
    $("companyFormTitle").textContent = "Cadastrar empresa";
    $("companySave").textContent = "Salvar cadastro pendente";
  }
  function render() {
    $("companyList").replaceChildren();
    if (!rows.length) {
      const text = document.createElement("p");
      text.textContent = "Nenhuma empresa encontrada no Caxias.";
      $("companyList").append(text);
    }
    rows.forEach(row => {
      const card = document.createElement("article"); card.className = "company-record";
      const title = document.createElement("h3"); title.textContent = row.nome;
      const detail = document.createElement("p"); detail.textContent = `${row.categoria} · ${row.subcategoria} · ${row.bairro || "Caxias do Sul"}`;
      const status = document.createElement("p"); status.textContent = `Status: ${row.status} · WhatsApp: ${row.whatsapp}`;
      const edit = document.createElement("button"); edit.type = "button"; edit.className = "company-button"; edit.textContent = "Editar dados";
      edit.addEventListener("click", () => {
        editingId = row.id;
        fields.forEach(field => { $("company_" + field).value = row[field] || ""; });
        $("companyFormTitle").textContent = "Editar empresa";
        $("companySave").textContent = "Salvar alterações";
        $("companyForm").hidden = false;
        $("companyMessage").hidden = true;
        $("companyFormTitle").scrollIntoView({ block: "start", behavior: "smooth" });
      });
      const images = document.createElement("button"); images.type = "button"; images.className = "company-button secondary"; images.textContent = "Logo e foto";
      images.addEventListener("click", () => window.CaxiasMidias.open(row,readToken));
      card.append(title,detail,status,edit,images); $("companyList").append(card);
    });
    $("companyPrevious").disabled = offset === 0;
    $("companyNext").disabled = rows.length < 50;
    $("companyPage").textContent = "Página " + (offset / 50 + 1);
  }
  async function load() {
    const current = generation;
    const sequence = ++loadSequence;
    const params = new URLSearchParams({ select: columns, cidade_id: "eq.caxias", order: "created_at.desc,id.desc", limit: "50", offset: String(offset) });
    const term = $("companySearch").value.trim().replace(/[%_*\\]/g, "");
    if (term) params.set("nome", "ilike.%" + term + "%");
    $("companyList").textContent = "Carregando empresas...";
    try {
      const data = await request(params);
      if (current !== generation || sequence !== loadSequence) return;
      if (!Array.isArray(data)) throw new Error("Resposta inesperada ao carregar as empresas.");
      rows = data; render();
    } catch (error) {
      if (current !== generation || sequence !== loadSequence) return;
      rows = []; $("companyList").textContent = "Não foi possível carregar a lista."; message(error.message);
    }
  }
  $("companyNew").addEventListener("click", () => { resetForm(); $("companyForm").hidden = false; $("companyMessage").hidden = true; });
  $("companyCancel").addEventListener("click", () => { resetForm(); $("companyForm").hidden = true; });
  $("companySearchForm").addEventListener("submit", event => { event.preventDefault(); offset = 0; load(); });
  $("companyPrevious").addEventListener("click", () => { offset = Math.max(0,offset - 50); load(); });
  $("companyNext").addEventListener("click", () => { offset += 50; load(); });
  $("companyForm").addEventListener("submit", async event => {
    event.preventDefault();
    const current = generation;
    const payload = Object.fromEntries(fields.map(field => [field, $("company_" + field).value.trim() || null]));
    payload.whatsapp = (payload.whatsapp || "").replace(/\D/g, "");
    for (const field of ["site","instagram"]) {
      if (payload[field] && !/^https?:\/\//i.test(payload[field]) && !(field === "instagram" && /^@?[a-z\d._]+$/i.test(payload[field]))) return message("Use um endereço https:// no site e um perfil ou endereço válido no Instagram.");
    }
    const params = new URLSearchParams({ select: columns, cidade_id: "eq.caxias" });
    if (editingId) params.set("id", "eq." + editingId);
    else payload.cidade = "Caxias do Sul";
    $("companySave").disabled = true;
    try {
      const saved = await request(params, { method: editingId ? "PATCH" : "POST", body: JSON.stringify(payload) });
      if (current !== generation) return;
      if (!saved.length) throw new Error("Nenhum cadastro foi alterado. Recarregue a lista e confira sua permissão.");
      resetForm(); $("companyForm").hidden = true; offset = 0;
      message("Dados salvos no Caxias. A situação de publicação e os pagamentos não foram alterados.",true);
      await load();
    } catch (error) { if (current === generation) message(error.message); }
    finally { if (current === generation) $("companySave").disabled = false; }
  });
  window.CaxiasEmpresas = {
    start(getToken) { generation++; readToken = getToken; offset = 0; $("companiesModule").hidden = false; return load(); },
    clear() { window.CaxiasMidias.clear(); generation++; readToken = () => null; rows = []; offset = 0; resetForm(); $("companyForm").hidden = true; $("companiesModule").hidden = true; $("companyList").replaceChildren(); $("companySearch").value = ""; $("companyMessage").hidden = true; $("companySave").disabled = false; }
  };
})();
