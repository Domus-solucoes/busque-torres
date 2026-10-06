"use strict";
(() => {
  const BASE = "https://wqfkysoodjyweanhsquk.supabase.co";
  const BUCKET = "caxias-empresas";
  const KEY = "sb_publishable_lpHHnebV1KE0Gj8ojfLBiw_N7wfUjIf";
  const $ = id => document.getElementById(id);
  let company = null, readToken = () => null, generation = 0, previewSequence = 0;
  function message(text, success = false) {
    $("mediaMessage").textContent = text;
    $("mediaMessage").className = "form-message " + (success ? "success" : "error");
    $("mediaMessage").hidden = false;
  }
  async function request(path, body, raw = false, contentType = "application/json") {
    const token = readToken();
    if (!token) throw new Error("Entre novamente para acessar as imagens.");
    const response = await fetch(BASE + "/storage/v1" + path, { method: "POST", credentials: "omit", cache: "no-store",
      headers: { apikey: KEY, Authorization: "Bearer " + token, "Content-Type": contentType,
        ...(raw ? { "x-upsert": "true", "cache-control": "0" } : {}) },
      body: raw ? body : JSON.stringify(body)
    });
    if (!response.ok) throw new Error(response.status === 401 || response.status === 403
      ? "Sua sessão expirou ou não tem permissão. Saia e entre novamente."
      : "Não foi possível acessar as imagens. Confira o arquivo e tente novamente.");
    return response.json();
  }
  async function refresh(current) {
    const sequence = ++previewSequence;
    const id = company.id;
    const objects = await request("/object/list/" + BUCKET, { prefix: id, limit: 10, offset: 0 });
    if (current !== generation || sequence !== previewSequence) return;
    if (!Array.isArray(objects)) throw new Error("Resposta inesperada ao carregar imagens.");
    for (const type of ["logo","capa"]) {
      const image = $("media_" + type + "_image");
      image.hidden = true; image.removeAttribute("src");
      $("media_" + type + "_status").textContent = "Nenhuma imagem enviada.";
      if (!objects.some(object => object.name === type && object.id)) continue;
      const signed = await request("/object/sign/" + BUCKET + "/" + id + "/" + type, { expiresIn: 300 });
      if (current !== generation || sequence !== previewSequence) return;
      const path = signed.signedURL || signed.signedUrl;
      if (typeof path !== "string") throw new Error("Não foi possível carregar a prévia.");
      const url = new URL(path.startsWith("/object/") ? "/storage/v1" + path : path, BASE);
      if (url.origin !== BASE) throw new Error("Endereço de imagem inesperado.");
      url.searchParams.set("v", String(Date.now()));
      image.src = url.href; image.hidden = false;
      $("media_" + type + "_status").textContent = "Imagem privada · prévia disponível por 5 minutos.";
    }
  }
  async function optimize(file, type) {
    if (!file || !["image/jpeg","image/png","image/webp"].includes(file.type)) throw new Error("Escolha uma imagem JPG, PNG ou WebP.");
    if (file.size > 15 * 1024 * 1024) throw new Error("A imagem original deve ter até 15 MB.");
    let bitmap;
    try { bitmap = await createImageBitmap(file); } catch { throw new Error("Não foi possível abrir essa imagem. Escolha outro arquivo."); }
    try {
      const max = type === "logo" ? 640 : 1600;
      const scale = Math.min(1,max / Math.max(bitmap.width,bitmap.height));
      const canvas = document.createElement("canvas");
      canvas.width = Math.max(1,Math.round(bitmap.width * scale));
      canvas.height = Math.max(1,Math.round(bitmap.height * scale));
      const context = canvas.getContext("2d");
      if (!context) throw new Error("Seu navegador não conseguiu preparar a imagem.");
      context.drawImage(bitmap,0,0,canvas.width,canvas.height);
      const blob = await new Promise(resolve => canvas.toBlob(resolve,"image/webp",0.82));
      if (!blob || blob.size > 2 * 1024 * 1024) throw new Error("A imagem ficou muito grande. Escolha uma imagem menor.");
      if (!["image/jpeg","image/png","image/webp"].includes(blob.type)) throw new Error("Formato de imagem não suportado.");
      return blob;
    } finally { bitmap.close(); }
  }
  for (const type of ["logo","capa"]) {
    $("media_" + type + "_upload").addEventListener("click", async () => {
      if (!company) return;
      const current = generation, id = company.id;
      const button = $("media_" + type + "_upload");
      const file = $("media_" + type + "_file").files[0];
      button.disabled = true; $("mediaMessage").hidden = true;
      try {
        const image = await optimize(file,type);
        if (current !== generation) return;
        await request("/object/" + BUCKET + "/" + id + "/" + type,image,true,image.type);
        if (current !== generation) return;
        $("media_" + type + "_file").value = "";
        message("Imagem salva no Caxias. A publicação da empresa continua sem alterações.",true);
        await refresh(current);
      } catch (error) { if (current === generation) message(error.message); }
      finally { if (current === generation) button.disabled = false; }
    });
  }
  $("mediaClose").addEventListener("click", () => window.CaxiasMidias.clear());
  window.CaxiasMidias = {
    async open(selectedCompany,getToken) {
      window.CaxiasMidias.clear();
      company = { id: selectedCompany.id, nome: selectedCompany.nome }; readToken = getToken;
      const current = generation;
      $("mediaCompanyName").textContent = company.nome;
      $("mediaPanel").hidden = false;
      $("mediaPanel").scrollIntoView({ block: "start", behavior: "smooth" });
      try { await refresh(current); } catch (error) { if (current === generation) message(error.message); }
    },
    clear() {
      generation++; company = null; readToken = () => null;
      $("mediaPanel").hidden = true; $("mediaCompanyName").textContent = ""; $("mediaMessage").hidden = true;
      for (const type of ["logo","capa"]) {
        $("media_" + type + "_file").value = ""; $("media_" + type + "_image").removeAttribute("src");
        $("media_" + type + "_image").hidden = true; $("media_" + type + "_status").textContent = "";
        $("media_" + type + "_upload").disabled = false;
      }
    }
  };
})();
