BUSQUE CARDÁPIO — LAYOUT V7

Atualização visual + integração de frete por rota real com Mapbox Directions.

Arquivos da pasta cardapio devem substituir a pasta /cardapio do repositório.
Não substitua o index.html da raiz do Busque Torres.

IMPORTANTE SOBRE MAPBOX
O frontend já está preparado e o backend no Supabase já usa Mapbox Directions.
O token Mapbox NÃO fica dentro destes arquivos. Ele deve ser salvo com segurança no Supabase Vault.
Sem o token, a tela informa que o cálculo de rota ainda está sendo ativado; não há fallback para distância em linha reta.

Fluxo de entrega:
1. Empresa salva sua localização.
2. Cliente autoriza sua localização no checkout.
3. Backend consulta Mapbox Directions (perfil driving).
4. Mapbox retorna a distância da rota pelas ruas.
5. Backend escolhe a faixa de frete da empresa.
6. É criada uma cotação de entrega válida por 15 minutos.
7. O checkout usa essa cotação, sem confiar em quilômetros enviados pelo navegador.
