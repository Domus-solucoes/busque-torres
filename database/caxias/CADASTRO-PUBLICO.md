# Cadastro público pendente Caxias

Página /cadastro.html. Visual/CSS e categorias/subcategorias reaproveitados do formulário Torres, sem analytics, cobrança, planos, checkout, contratos comerciais, cortesias ou referências a outros projetos. Cidade fixa Caxias do Sul/RS. Este envio não cria usuário Auth nem publica empresa. Imagens ainda são adicionadas pelo administrador na revisão.

Endpoint caxias-cadastro-publico exclusivo de wqfkysoodjyweanhsquk. Chave publishable validada no código para identificar o aplicativo público; não autentica a identidade do anunciante. Origin/CORS restritos ao workers.dev do Caxias. verify_jwt false porque a chave moderna não é JWT. Essa configuração não atribui privilégio genérico ao visitante: a operação limitada passa por validação e usa RPC invoker executável apenas por service_role no servidor. Não foi criado grant/policy de INSERT nem leitura pública em empresas.

Validação de campos, corpo até 16 KiB, checkbox de autorização obrigatório, honeypot, idempotência por UUID e deduplicação por nome/WhatsApp/cidade. Dados de empresa já existente não são sobrescritos pelo visitante e a resposta permanece genérica, sem IDs, códigos de renovação ou dados comerciais. Todos os novos registros são forçados a pendente/inativo/comum/pagamento não confirmado no Caxias.

Proteção básica contra abuso: limite de 10 novas tentativas por hash de origem/hora e 60 globais/hora, sob lock transacional para não ultrapassar o limite em concorrência. A origem deriva de headers da infraestrutura e não é prova de identidade; o teto global é independente dela. IP em texto não é armazenado; hash é derivado com chave secreta do servidor. Entradas antigas de limites são removidas na próxima requisição após 24h; tokens após 48h. Não há CAPTCHA nesta etapa. Reavaliar limites e proteção antes da divulgação ampla.

Testes transacionais SQL: cadastro correto, campos privilegiados ignorados no servidor, repetição por token e por nome/WhatsApp sem duplicação, limite por origem e global, RPC inacessível a anon/authenticated e leitura pública bloqueada. ROLLBACK descartou os dados.

Testes reais da API: OPTIONS 204, chave inválida 401, Origin indevida 403, campos privilegiados/aceite ausente/descrição curta 400, honeypot sem gravação, envio 200, repetição sem duplicação. Conferido no banco: uma empresa de teste, caxias/Caxias do Sul/pendente/inativa/pagamento false/plano comum. Cadastro e metadados de teste removidos.

Testes de lógica de interface simulados: categorias, erro visível, sucesso pendente, token estável na repetição, WhatsApp normalizado, payload sem campos privilegiados, reset para outro cadastro e backend exclusivo. Inspeção visual no navegador depende da validação da publicação.

Advisors sem alerta novo: tabelas de módulos fechados e duas tabelas internas com RLS sem política porque só service_role usa, conforme https://supabase.com/docs/guides/database/database-linter?lint=0008_rls_enabled_no_policy . Aviso existente de proteção contra senhas vazadas indisponível no Free: https://supabase.com/docs/guides/auth/password-security#password-strength-and-leaked-password-protection . Nenhuma alteração de plano/custo ou de main/Torres.
