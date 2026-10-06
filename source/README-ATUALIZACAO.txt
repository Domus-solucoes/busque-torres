BUSQUE CARDÁPIO — LAYOUT V8

Pacote final de homologação visual/UX.

COMO SUBIR
Substitua a pasta /cardapio do repositório pela pasta cardapio deste pacote.
NÃO substitua o index.html da raiz do Busque Torres.

PRINCIPAIS MUDANÇAS DA V8
- Cadastro da empresa virou um assistente simples em 3 etapas: Empresa > Entrega > Acesso.
- O cadastro inicial não obriga mais a criar produto junto com a empresa.
- Nova empresa começa com 3 créditos gratuitos.
- Painel mostra onboarding para cadastrar o primeiro produto depois que a empresa é criada.
- Cadastro/edição de produto unificado em uma única tela.
- Atalhos simples para Sabores, Tamanhos e Adicionais.
- Preço final para sabores/tamanhos e valor adicional para extras.
- Proteção contra produto duplicado por duplo clique.
- Fotos WebP de até 256 KB e remoção da imagem ao excluir produto.
- Entrega usa Mapbox Directions no backend para rota real de carro pelas ruas.
- Cotação de frete válida por 15 minutos e vinculada ao pedido.
- Acompanhamento de pedido atualiza automaticamente a cada 15 segundos enquanto aberto.

MAPBOX
O token já está salvo no Supabase Vault. Ele NÃO está exposto nos HTML/JS.
Não existe fallback silencioso para distância em linha reta.

PAGAMENTOS
- Mercado Pago: split de R$ 1 continua ativo.
- Outro banco: taxa_busque = 0 e consumo de 1 crédito por pedido pago.
