"use strict";
(() => {
  const API = "https://wqfkysoodjyweanhsquk.supabase.co";
  const KEY = "sb_publishable_lpHHnebV1KE0Gj8ojfLBiw_N7wfUjIf";
  const $ = id => document.getElementById(id);
  let tokenHash = new URLSearchParams(location.hash.slice(1)).get("t");
  let accessToken = null;
  history.replaceState(null, "", location.pathname);
  function show(text, success = false) {
    $("message").textContent = text;
    $("message").className = "form-message " + (success ? "success" : "error");
    $("message").hidden = false;
  }
  async function request(path, body, token) {
    return fetch(API + path, { method: path === "/auth/v1/user" ? "PUT" : "POST",
      credentials: "omit", cache: "no-store", body: JSON.stringify(body),
      headers: { apikey: KEY, "Content-Type": "application/json",
        ...(token ? { Authorization: "Bearer " + token } : {}) }
    });
  }
  if (!tokenHash) {
    $("saveButton").disabled = true;
    show("Abra o link exclusivo de ativação fornecido para sua conta do Caxias.");
  }
  $("passwordForm").addEventListener("submit", async event => {
    event.preventDefault();
    const password = $("password").value;
    if (password.length < 10) return show("Use uma senha com pelo menos 10 caracteres.");
    if (password !== $("confirmPassword").value) return show("As senhas precisam ser iguais.");
    $("saveButton").disabled = true;
    $("message").hidden = true;
    try {
      if (!accessToken) {
        const verification = await request("/auth/v1/verify", { token_hash: tokenHash, type: "recovery" });
        if (!verification.ok) {
          tokenHash = null;
          throw new Error("Este link expirou ou já foi usado. Solicite um novo link de ativação.");
        }
        const session = await verification.json();
        accessToken = session.access_token;
        tokenHash = null;
        if (!accessToken) throw new Error("Não foi possível validar sua ativação.");
      }
      const update = await request("/auth/v1/user", { password }, accessToken);
      if (!update.ok) throw new Error("Não foi possível salvar a senha. Use uma senha mais forte e tente novamente nesta tela.");
      $("password").value = "";
      $("confirmPassword").value = "";
      try { await request("/auth/v1/logout?scope=local", {}, accessToken); } catch {}
      accessToken = null;
      $("passwordForm").hidden = true;
      $("loginLink").hidden = false;
      show("Senha definida. Você já pode entrar no acesso administrativo do Caxias.", true);
    } catch (error) {
      show(error instanceof TypeError ? "Falha de conexão. Tente novamente nesta tela." : error.message);
    } finally {
      $("saveButton").disabled = !tokenHash && !accessToken;
    }
  });
})();
