"use strict";
(() => {
  const $ = id => document.getElementById(id);
  let attempt = crypto.randomUUID();
  function message(text) {
    $("mensagemFormulario").textContent = text;
    $("mensagemFormulario").className = "mensagem erro visivel";
    $("mensagemFormulario").hidden = false;
  }
  $("categoria").addEventListener("change", () => {
    $("subcategoria").replaceChildren();
    const first = document.createElement("option");first.value="";first.textContent="Selecione seu nicho";
    $("subcategoria").append(first);
    const options = window.CAXIAS_SUBCATEGORIAS[$("categoria").value] || [];
    options.forEach(value => { const item=document.createElement("option");item.value=value;item.textContent=value;$("subcategoria").append(item); });
    $("subcategoria").disabled = options.length === 0;
  });
  $("cadastroForm").addEventListener("submit", async event => {
    event.preventDefault();
    const fields=["nome","categoria","subcategoria","descricao","whatsapp","email","bairro","endereco","horario","instagram","site","produtos","servicos","palavras_chave","website"];
    const data=Object.fromEntries(fields.map(field=>[field,$(field).value.trim()]));
    data.whatsapp=data.whatsapp.replace(/\D/g,"");data.aceite=$("aceite").checked;data.tentativa=attempt;
    if(!/^[0-9]{10,15}$/.test(data.whatsapp)) return message("Confira o WhatsApp com DDD.");
    if(!data.aceite) return message("Confirme sua autorização para cadastrar o negócio.");
    if(!data.subcategoria) return message("Selecione a categoria e seu nicho.");
    $("submitBtn").disabled=true;$("submitBtn").textContent="Enviando...";$("mensagemFormulario").hidden=true;
    try {
      const response=await fetch("https://wqfkysoodjyweanhsquk.supabase.co/functions/v1/caxias-cadastro-publico",{
        method:"POST",credentials:"omit",cache:"no-store",headers:{apikey:"sb_publishable_lpHHnebV1KE0Gj8ojfLBiw_N7wfUjIf","Content-Type":"application/json"},body:JSON.stringify(data)
      });
      const result=await response.json().catch(()=>({}));
      if(!response.ok || result.ok!==true) throw new Error(result.erro || "Não foi possível enviar agora. Tente novamente.");
      $("cadastroForm").hidden=true;$("sucessoCadastro").hidden=false;$("sucessoCadastro").focus();
    } catch(error) { message(error instanceof TypeError ? "Falha de conexão. Tente novamente; seu envio não será duplicado." : error.message); }
    finally {$("submitBtn").disabled=false;$("submitBtn").textContent="Enviar cadastro para análise";}
  });
  $("novoCadastroBtn").addEventListener("click", () => {
    $("cadastroForm").reset();attempt=crypto.randomUUID();$("categoria").dispatchEvent(new Event("change"));
    $("sucessoCadastro").hidden=true;$("cadastroForm").hidden=false;$("mensagemFormulario").hidden=true;$("nome").focus();
  });
})();
