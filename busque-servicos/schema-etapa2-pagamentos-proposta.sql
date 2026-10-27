-- BUSQUE SERVIÇOS — ETAPA 2 / TABELAS APLICADAS EM 2026-10-27; PROCESSAMENTO PIX AINDA NÃO IMPLEMENTADO
-- Isolada de pagamentos e pedidos existentes do Busque Torres e Busque Cardápio.
-- Cobranças em centavos; nunca confiar em valor/status recebido do navegador.
-- Mercado Pago: validar webhook na origem, consultar pagamento pelo provedor e aplicar idempotência.

create table if not exists public.busque_servicos_pagamentos (
 id uuid primary key default gen_random_uuid(),
 pedido_id uuid not null references public.busque_servicos_pedidos(id),
 tipo text not null check (tipo in ('premium','desbloqueio_contato')),
 valor_centavos integer not null check (valor_centavos=350),
 status text not null default 'pendente' check (status in ('pendente','aprovado','rejeitado','cancelado','estornado')),
 provedor text not null default 'mercadopago',
 provedor_pagamento_id text unique,
 referencia_externa text not null unique,
 profissional_nome text,
 profissional_whatsapp text,
 -- Reservas temporárias: um PIX gerado não deve bloquear uma vaga indefinidamente.
 reserva_expira_em timestamptz,
 -- Identificador do pagador/provedor nunca deve ser tomado como confirmação de pagamento.
 provedor_preferencia_id text unique,
 criado_em timestamptz not null default now(),
 confirmado_em timestamptz,
 check ((tipo='premium' and profissional_whatsapp is null) or (tipo='desbloqueio_contato' and profissional_whatsapp is not null))
);
create index if not exists idx_busque_servicos_pagamentos_pedido on public.busque_servicos_pagamentos(pedido_id,status,tipo);

create table if not exists public.busque_servicos_destaques (
 pedido_id uuid primary key references public.busque_servicos_pedidos(id),
 pagamento_id uuid not null unique references public.busque_servicos_pagamentos(id),
 ativado_em timestamptz not null default now(),
 encerrado_em timestamptz,
 check (encerrado_em is null or encerrado_em >= ativado_em)
);

create table if not exists public.busque_servicos_contatos_liberados (
 id uuid primary key default gen_random_uuid(),
 pedido_id uuid not null references public.busque_servicos_pedidos(id),
 pagamento_id uuid not null unique references public.busque_servicos_pagamentos(id),
 profissional_whatsapp text not null,
 criado_em timestamptz not null default now(),
 unique (pedido_id,profissional_whatsapp),
 check (length(regexp_replace(profissional_whatsapp,'[^0-9]','','g')) between 10 and 13)
);

alter table public.busque_servicos_pagamentos enable row level security;
alter table public.busque_servicos_destaques enable row level security;
alter table public.busque_servicos_contatos_liberados enable row level security;
revoke all on public.busque_servicos_pagamentos,public.busque_servicos_destaques,public.busque_servicos_contatos_liberados from anon,authenticated;

-- ATENÇÃO: A migração das três tabelas já foi aplicada. NÃO executar novamente sem revisão.
-- O limite de 3 destaques simultâneos, expiração, verificação de pagamento,
-- máximo de 3/5 contatos e concorrência DEVEM ser impostos por transação
-- atômica no backend antes da implantação. Este SQL sozinho NÃO os garante.

-- REGRAS OBRIGATÓRIAS ANTES DE ATIVAR COBRANÇAS:
-- 1) Criar preferência PIX com valor fixo de 350 centavos SOMENTE no backend.
-- 2) Reservar vaga com lock transacional por pedido, não com contagem no navegador.
-- 3) Expirar reservas pendentes antes de contar vagas ocupadas.
-- 4) Consultar o pagamento no Mercado Pago e conferir valor, moeda BRL,
--    referência externa e pedido/tipo antes de marcar aprovado.
-- 5) Reprocessar webhook repetido sem criar duas liberações ou dois destaques.
-- 6) Estorno/cancelamento exige regra de reversão e registro de auditoria.
-- 7) Contato só pode ser retornado ao pagador autenticado/autorizado.
-- 8) Nunca registrar WhatsApp/endereço do solicitante em logs públicos.
