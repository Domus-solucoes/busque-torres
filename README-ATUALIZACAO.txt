BUSQUE CARDÁPIO — LAYOUT V4 / AJUSTES DE TESTE

Suba a pasta "cardapio" inteira para a raiz do repositório busque-torres,
substituindo a pasta /cardapio atual. NÃO substitua o index.html da raiz.

Esta versão mantém a identidade preta/amarela/laranja e acrescenta:
- KM e R$ fixos nos campos de entrega.
- Foto da empresa no cadastro inicial.
- Foto por produto com compressão automática WebP <= 256 KB.
- Sabores, tamanhos e adicionais vinculados a um único produto/imagem.
- Abertura manual da empresa; horário de fechamento opcional.
- Exibição imediata da área de "Outro banco" ao selecionar o modelo.
- QR Code e Pix para recarga de créditos.
- Acompanhamento público de pedidos por código.
- Fluxo de status no painel: recebido > preparo > pronto/entrega > concluído.

BACKEND SUPABASE JÁ ATUALIZADO:
- abertura não é mais obrigatória;
- fechamento opcional pode pausar automaticamente a empresa;
- listagem pública mostra somente empresas abertas;
- Mercado Pago split permanece com marketplace_fee R$ 1 e taxa_busque R$ 1.
