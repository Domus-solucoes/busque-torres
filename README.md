# Busque Caxias — etapa 2

Branch destinada exclusivamente ao Worker busque-caxias-rs.
Base do código: main em 28027f5bd55256d3f3685ec4c7ba212f7abf4487.

## Publicação

Comando Cloudflare: npx wrangler deploy --assets ./public --name busque-caxias-rs
Apenas public/ pode ser publicada. source/ contém código de referência ainda não adaptado e não deve ser servido nem executado. Existem referências a Torres nessa pasta.

A página pública é estática, sem scripts, formulários, banco ou pagamentos.
Configuração Supabase da cópia foi bloqueada. Páginas geradas de empresas de Torres, sitemap e automação SEO não foram copiadas.

Próxima etapa: Supabase exclusivo de Caxias; depois adaptar e testar source/ antes de habilitar os fluxos.
Não mesclar esta branch na main. Não executar migrations ou funções no projeto de Torres.
