# Imagens privadas das empresas Caxias

Projeto exclusivo: wqfkysoodjyweanhsquk. Bucket privado caxias-empresas. Nenhuma configuração ou arquivo do Torres foi alterado.

No painel administrativo, cada empresa possui o botão Logo e foto. Objetos associados pelo UUID da empresa: <id>/logo e <id>/capa. Esses caminhos fixos permitem substituir uma imagem sem acumular versões órfãs. Nesta etapa não se altera logo_url/imagem_url nem se publica mídia; a integração com o diretório público será implementada em etapa própria.

Permissões: administrador ativo e empresa existente no Caxias. RLS em storage.objects para SELECT, INSERT, UPDATE (necessários ao upsert) e DELETE. Função auxiliar privada invoker, search_path vazio e EXECUTE restrito a authenticated. Nomes fora dos dois espaços, empresas inexistentes e outros buckets não recebem permissão.

Bucket aceita JPEG, PNG e WebP de até 2 MiB. A interface aceita originais até 15 MiB, decodifica e converte no navegador, mantendo proporção: logo até 640 pixels e foto até 1600 pixels no maior lado. WebP com qualidade 0,82; fallback do navegador aceito somente se JPEG/PNG/WebP e até 2 MiB. Previews carregam apenas ao abrir a área de imagens. URLs assinadas válidas por 5 minutos. Novos arquivos privados usam cache-control 0.

Testes reais com conta Auth/empresa temporárias no Caxias: login da conta de teste por senha; upload, upsert e download autenticado de PNG; download assinado confirmou exatamente o arquivo substituído; listagem; bloqueios de upload anônimo, download público, caminho de empresa inexistente, espaço inválido, SVG e tamanho superior ao limite. Após revogar o perfil administrativo, RLS retornou zero arquivos, listagem vazia, download novo sem cache foi negado e envio de PNG válido falhou com AccessDenied. Uma resposta previamente acessada foi servida em cache; o teste novo confirmou revogação e as novas prévias foram ajustadas para cache-control 0. Arquivos já recebidos e URLs assinadas já emitidas não podem ser revogados retroativamente antes da expiração.

Limpeza por APIs de Storage/Auth, nunca exclusão direta de metadados de storage.objects. Arquivos, empresa, perfil e usuário temporários removidos. Função temporária de teste substituída por resposta 410 e validação JWT habilitada.

Testes de lógica simulados: preview privado, tipo inválido, original acima do limite, falha de decodificação, redimensionamento, envio WebP, limpeza ao sair e backend exclusivo. Testes anteriores de login, senha e cadastro básico passaram novamente. Inspeção visual e conversão em navegador real permanecem pendentes; API real de armazenamento foi testada.

Advisor sem alertas novos; permanece o aviso existente da checagem de senhas vazadas indisponível no Free, https://supabase.com/docs/guides/auth/password-security#password-strength-and-leaked-password-protection . As tabelas dos módulos ainda fechados seguem com RLS sem políticas, https://supabase.com/docs/guides/database/database-linter?lint=0008_rls_enabled_no_policy .
