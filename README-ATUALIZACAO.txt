BUSQUE CARDÁPIO — FRONTEND V2 (LAYOUT PRETO/AMARELO/LARANJA)

COMO SUBIR NO GITHUB
1. Abra o repositório Domus-solucoes/busque-torres.
2. Envie a pasta "cardapio" inteira para a raiz do repositório.
3. Quando o GitHub avisar que arquivos dentro de /cardapio já existem, confirme a substituição.
4. NÃO substitua o index.html da raiz do Busque Torres.

A estrutura correta ficará:
/cardapio/index.html
/cardapio/cadastro.html
/cardapio/painel.html
/cardapio/cardapio-core.js
/cardapio/styles.css
/cardapio/logo-cardapio.jpg
/cardapio/icone-cardapio.jpg

O QUE MUDOU
- Home redesenhada na identidade preta/amarela/laranja do Busque Cardápio.
- Home não fica vazia quando ainda não existem empresas: mostra categorias, chamada de lançamento e posições "Em breve" claramente identificadas.
- Cadastro e painel harmonizados com a mesma identidade.
- Cadastro agora possui botão para reenviar o e-mail de confirmação.
- Confirmação de e-mail redireciona para /cardapio/painel.html e o frontend captura a sessão.
- Checkout mostra e-mail/documento somente quando o provedor (PicPay/PagBank) exigir.
- Painel consulta o catálogo real de bancos do Supabase e mostra instituições ativas e "em breve".
- Campos bancários mudam conforme a instituição: Pix/mTLS, PicPay ou PagBank.
- Corrigido um erro de sintaxe que existia no painel anterior na renderização da foto da empresa.

IMPORTANTE
O backend permanece no Supabase. Este pacote altera apenas o frontend /cardapio.


ATUALIZAÇÃO DE CADASTRO:
- Empresas do Busque Cardápio não precisam confirmar e-mail para entrar.
- O cadastro usa a função cardapio-cadastrar-empresa e libera o acesso imediatamente.
- A configuração global de confirmação do Supabase não foi alterada, preservando o Busque Torres.
