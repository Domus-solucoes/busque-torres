-- BUSQUE SERVIÇOS — ETAPA 2 / PROPOSTA DE MIGRAÇÃO, NÃO EXECUTAR EM PRODUÇÃO SEM REVISÃO
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
 criado_em timestamptz not null default now(),
 confirmado_em timestamptz,
 check ((tipo='premium' and profissional_whatsapp is null) or (tipo='desbloqueio_contato' and profissional_whatsapp is not null))
);
create index if not exists idx_busque_servicos_pagamentos_pedido on public.busque_servicos_pagamentos(pedido_id,status,tipo);

create table if not exists public.busque_servicos_destaques (
 pedido_id uuid primary key references public.busque_servicos_pedidos(id),
 pagamento_id uuid not null unique references public.busque_servicos_pagamentos(id),
 ativado_em timestamptz not null default now(),
 encerrado_em timestamptz
);

create table if not exists public.busque_servicos_contatos_liberados (
 id uuid primary key default gen_random_uuid(),
 pedido_id uuid not null references public.busque_servicos_pedidos(id),
 pagamento_id uuid not null unique references public.busque_servicos_pagamentos(id),
 profissional_whatsapp text not null,
 criado_em timestamptz not null default now(),
 unique (pedido_id,profissional_whatsapp)
);

alter table public.busque_servicos_pagamentos enable row level security;
alter table public.busque_servicos_destaques enable row level security;
alter table public.busque_servicos_contatos_liberados enable row level security;
revoke all on public.busque_servicos_pagamentos,public.busque_servicos_destaques,public.busque_servicos_contatos_liberados from anon,authenticated;

-- O limite de 3 destaques simultâneos, expiração, verificação de pagamento,
-- máximo de 3/5 contatos e concorrência DEVEM ser impostos por transação
-- atômica no backend antes da implantação. Este SQL sozinho NÃO os garante.
