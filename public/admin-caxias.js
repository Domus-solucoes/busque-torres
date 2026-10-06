"use strict";
(() => {
  const API = "https://wqfkysoodjyweanhsquk.supabase.co";
  const KEY = "sb_publishable_lpHHnebV1KE0Gj8ojfLBiw_N7wfUjIf";
  const $ = id => document.getElementById(id);
  let token = null;
  function message(text) {
    $("loginMessage").textContent = text;
    $("loginMessage").className = "form-message error";
    $("loginMessage").hidden = false;
  }
  async function request(path, options = {}, accessToken = null) {
    return fetch(API + path, {
      ...options, cache: "no-store", credentials: "omit",
      headers: { apikey: KEY, "Content-Type": "application/json",
        ...(accessToken ? { Authorization: "Bearer " + accessToken } : {}) }
    });
  }
  async function revoke(accessToken) {
    if (accessToken) {
      const response = await request("/auth/v1/logout?scope=local", { method: "POST" }, accessToken);
      if (!response.ok) throw new Error("Não foi possível confirmar a saída no servidor.");
    }
  }
  $("loginForm").addEventListener("submit", async event => {
    event.preventDefault();
    const button = $("loginButton");
    button.disabled = true;
    button.textContent = "Entrando...";
    $("loginMessage").hidden = true;
    let pendingToken = null;
    try {
      const body = JSON.stringify({ email: $("email").value.trim(), password: $("password").value });
      $("password").value = "";
      const response = await request("/auth/v1/token?grant_type=password", { method: "POST", body });
      if (!response.ok) throw new Error(response.status === 429
        ? "Muitas tentativas. Aguarde antes de tentar novamente."
        : "Não foi possível entrar. Confira suas credenciais e se sua conta do Caxias foi criada.");
      const session = await response.json();
      pendingToken = session.access_token;
      if (!pendingToken) throw new Error("Não foi possível validar sua sessão.");
      const userResponse = await request("/auth/v1/user", {}, pendingToken);
      if (!userResponse.ok) throw new Error("Sua sessão não pôde ser validada.");
      const user = await userResponse.json();
      if (!user.id) throw new Error("Sua sessão não pôde ser validada.");
      const profileResponse = await request("/rest/v1/administradores?select=user_id,papel,ativo&user_id=eq." + encodeURIComponent(user.id), {}, pendingToken);
      if (!profileResponse.ok) throw new Error("Não foi possível verificar sua autorização. Tente novamente.");
      const profiles = await profileResponse.json();
      if (!Array.isArray(profiles) || !profiles.some(profile => profile.user_id === user.id && profile.ativo === true && ["dono", "operador"].includes(profile.papel))) {
        throw new Error("Sua conta não tem acesso administrativo ao Caxias.");
      }
      token = pendingToken;
      pendingToken = null;
      $("authorizedEmail").textContent = user.email || "Administrador";
      $("loginPage").hidden = true;
      $("authorizedPage").hidden = false;
    } catch (error) {
      if (pendingToken) { try { await revoke(pendingToken); } catch {} }
      message(error instanceof TypeError ? "Não foi possível conectar. Verifique sua conexão e tente novamente." : error.message);
    } finally {
      button.disabled = false;
      button.textContent = "Entrar no painel";
    }
  });
  $("logoutButton").addEventListener("click", async () => {
    const current = token;
    token = null;
    $("authorizedEmail").textContent = "";
    $("authorizedPage").hidden = true;
    $("loginPage").hidden = false;
    try { await revoke(current); } catch { message("A sessão foi removida desta tela. Não foi possível confirmar a saída no servidor."); }
  });
})();
