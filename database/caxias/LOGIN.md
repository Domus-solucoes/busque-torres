# Login administrativo de Caxias

Autorização baseada em administradores do banco exclusivo de Caxias. Funções privilegiadas ficam no schema privado; wrappers públicos usam SECURITY INVOKER. Apenas SELECT do próprio perfil ativo é permitido. Inserir ou modificar administradores requer backend confiável.

Painel em source/ adaptado para somente Caxias, sessão própria e backend exclusivo. Não publicado: public/ continua em preparação. Pagamentos marcados indisponíveis.

Testes: dono válido, usuário comum, tentativa de autopromoção, user_metadata forjado, admin inativo, leitura de perfil alheio e acesso anon. Todos passaram com rollback dos fixtures. Scripts do painel passaram node --check. Auth settings respondeu HTTP 200 com email habilitado.

Pendências: criar conta definitiva do proprietário; configurar recuperação de senha/URLs; implementar funções dos demais módulos; testar login real e sessão no navegador antes da publicação. Cadastro de empresas ainda depende da função de cadastro e pagamentos.
