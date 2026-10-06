# Acesso administrativo Caxias — etapa inicial

Página pública: /bt-gestao-8472.html. Visual de login reaproveitado do painel existente, marca Caxias.

Conexão exclusiva: wqfkysoodjyweanhsquk. Login por senha, validação do usuário no Auth e leitura apenas do próprio perfil administrativo autorizado por RLS. Perfis ativos dono/operador podem entrar. Nenhuma operação de empresas ou pagamentos publicada. Nenhuma alteração em main ou no banco Torres.

Sessão apenas em memória, sem armazenamento de tokens. Recarregar exige novo login. Sair revoga a sessão local no Auth. Recuperação de senha e módulos completos ainda pendentes.

Validação: JavaScript sintaticamente válido; testes de lógica com API simulada para senha inválida, usuário sem autorização, administrador autorizado, saída e destino exclusivo Caxias. Teste real do endpoint Auth rejeitou credenciais inválidas (400 invalid_credentials). Testes de permissões de banco realizados na etapa anterior. Login real bem-sucedido e inspeção visual no navegador pendentes: ainda não há usuário definitivo e o Chromium não estava disponível no ambiente.

Próximo requisito: criar o usuário no Auth Caxias e vincular seu UUID a administradores por operação privilegiada. Não criar usuário diretamente via SQL. Não copiar senha ou usuários do Torres. A tela publicada não oferece autoatribuição de administrador.
