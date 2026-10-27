# Busque Serviços — critérios de homologação antes do PIX real

**Estado:** planejamento técnico; não é comprovação de implementação. Não publicar sem aprovação.

## Isolamento
- Branch de desenvolvimento `preview-busque-ajuda-20261026`, nunca mesclar automaticamente em `main`.
- Novas tabelas e funções exclusivas do Busque Serviços; não alterar pagamentos existentes do Busque Torres ou Cardápio.
- Nenhuma cobrança habilitada enquanto o webhook e o fluxo de recuperação de pagamento não forem validados.

## Pré-requisitos técnicos
1. Aplicar migração de pagamentos após revisão de constraints, RLS e auditoria.
2. Implementar endpoint para criar pagamento PIX com valor fixo de R$ 3,50 e referência externa única.
3. Confirmar pagamentos consultando a API oficial do Mercado Pago; não confiar em status enviado pelo navegador.
4. Processar notificações repetidas de forma idempotente, com transação e trava de concorrência.
5. Premium: máximo de 3 pedidos ativos; reserva expira, destaque encerra com o pedido.
6. Contatos: máximo de 3 ou 5 liberações por pedido; mesmo profissional não ocupa duas vagas.
7. Restringir recuperação de contato ao pagador legitimamente identificado; nunca devolver dados privados em public_list.
8. Conferir estornos, pagamentos atrasados, webhook inválido, pedido vencido, pagamento duplicado e concorrência.

## Testes sem cobrança real
- [ ] Requisição pública retorna somente pedidos aprovados e não vencidos.
- [ ] A resposta pública não contém nome, WhatsApp, endereço nem caminhos privados de fotos.
- [ ] Usuário anônimo não consulta tabelas privadas diretamente.
- [ ] Admin não autenticado não aprova pedidos.
- [ ] Pedidos rejeitados/encerrados não aparecem no mural.
- [ ] Três Premium ocupados impedem o quarto, mesmo com requisições simultâneas.
- [ ] Três/cinco contatos impedem o próximo, inclusive em concorrência.
- [ ] Repetição de webhook não duplica desbloqueio.
- [ ] Pagamento não confirmado não desbloqueia nada.
- [ ] PIX de um pedido não desbloqueia outro.
- [ ] Expiração/cancelamento libera reserva pendente.
- [ ] Fotos privadas não têm acesso público permanente.

## Homologação real — solicitar participação do responsável
- [ ] PIX Premium R$ 3,50; conferir crédito, webhook, destaque e expiração.
- [ ] PIX desbloqueio R$ 3,50; conferir crédito, contato específico e limite.
- [ ] Confirmar que os dois tipos de PIX são independentes.
- [ ] Aprovação explícita para publicação.

**Não executar pagamentos reais antes de todos os testes técnicos passarem.**
