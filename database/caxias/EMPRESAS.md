# Empresas — cadastro administrativo básico Caxias

Projeto: wqfkysoodjyweanhsquk. Branch exclusiva: v12-multicidades. Página: /bt-gestao-8472.html.

Módulo liberado após login: listar empresas em páginas de 50, buscar pelo nome, criar cadastro pendente/inativo e editar dados básicos. Cidade fixa Caxias do Sul/RS. Categorias e subcategorias nesta etapa são informadas pelo administrador. Cadastro público, contas de empresas, imagens, publicação, aprovação, planos e pagamentos continuam pendentes.

Permissões: RLS exige administrador ativo. Grants de INSERT/UPDATE limitados aos campos do perfil. Sem DELETE, sem alteração de status/ativo/pagamento/plano/cidade_id. Constraint impede qualquer empresa de outra cidade no projeto. Trigger invoker privado atualiza texto de busca e data de edição. Não há acesso de anon, cópia de empresas ou credenciais de Torres.

Testes transacionais reais no banco: cadastro, edição, estado pendente/inativo, indexação do texto e cidade correta; bloqueios de cidade indevida, alteração de pagamento, ativação, mudança de cidade_id, exclusão, leitura/cadastro/edição por usuário comum e leitura anônima. ROLLBACK descartou todos os dados temporários. Estado final: zero empresas, zero pagamentos, uma cidade caxias e um usuário administrador.

Testes de lógica com DOM/API simulados: listagem e filtro de cidade, renderização de texto sem HTML de usuário, payload de criação sem campos privilegiados, edição por id, busca, limpeza ao sair e backend exclusivo. Login e definição de senha também verificados novamente com APIs simuladas. Validação sintática dos scripts passou. Inspeção visual e uso real no navegador pelo administrador continuam pendentes.

Security Advisor: nenhum novo alerta. 76 tabelas ainda fechadas (RLS sem políticas), por módulos futuros, conforme https://supabase.com/docs/guides/database/database-linter?lint=0008_rls_enabled_no_policy . Aviso existente: proteção contra senhas vazadas indisponível no Free, conforme https://supabase.com/docs/guides/auth/password-security#password-strength-and-leaked-password-protection . Plano e custos não alterados.
