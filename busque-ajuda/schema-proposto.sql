-- BUSQUE AJUDA: proposta de migração. NÃO EXECUTAR EM PRODUÇÃO SEM HOMOLOGAÇÃO.
-- Dados pessoais isolados; nenhuma leitura pública das tabelas privadas.
create table if not exists public.busque_ajuda_pedidos (
 id uuid primary key default gen_random_uuid(),
 titulo text not null check (char_length(titulo) between 5 and 120),
 descricao text not null check (char_length(descricao) between 10 and 2000),
 bairro text not null check (char_length(bairro) between 2 and 100),
 nome_solicitante text not null,
 whatsapp text not null,
 endereco text,
 limite_orcamentos smallint not null check (limite_orcamentos in (3,5)),
 duracao_dias smallint not null check (duracao_dias in (3,5)),
 fotos_paths text[] not null default '{}',
 status text not null default 'pendente' check(status in ('pendente','aprovado','rejeitado','encerrado')),
 premium_status text not null default 'nenhum' check(premium_status in ('nenhum','pendente_pagamento','ativo','expirado')),
 premium_pago_em timestamptz,
 aprovado_em timestamptz,
 expira_em timestamptz,
 criado_em timestamptz not null default now(),
 constraint ajuda_fotos_limite check (cardinality(fotos_paths)<=3),
 constraint ajuda_aprovacao_coerente check (status <> 'aprovado' or (aprovado_em is not null and expira_em is not null))
);
create table if not exists public.busque_ajuda_desbloqueios (
 id uuid primary key default gen_random_uuid(),
 pedido_id uuid not null references public.busque_ajuda_pedidos(id),
 comprador_uid uuid references auth.users(id),
 comprador_email text,
 mp_payment_id text unique,
 status text not null default 'pendente' check(status in ('pendente','pago','expirado','cancelado','reembolsado')),
 reservado_ate timestamptz,
 pago_em timestamptz,
 criado_em timestamptz not null default now(),
 constraint ajuda_comprador_identificado check (comprador_uid is not null or comprador_email is not null)
);
create unique index if not exists ajuda_desbloqueio_comprador_unico on public.busque_ajuda_desbloqueios(pedido_id,comprador_uid) where comprador_uid is not null and status in ('pendente','pago');
create index if not exists ajuda_pedidos_mural_idx on public.busque_ajuda_pedidos(status,premium_status,aprovado_em);
create index if not exists ajuda_desbloqueios_pedido_idx on public.busque_ajuda_desbloqueios(pedido_id,status,reservado_ate);
alter table public.busque_ajuda_pedidos enable row level security;
alter table public.busque_ajuda_desbloqueios enable row level security;
revoke all on public.busque_ajuda_pedidos from anon, authenticated;
revoke all on public.busque_ajuda_desbloqueios from anon, authenticated;
-- Não criar policies públicas nas tabelas contendo nome, endereço e WhatsApp.
-- Backend autenticado deve validar admin e publicar somente campos não sensíveis.
-- A reserva do contato e a confirmação de pagamento devem ocorrer numa transação
-- com SELECT ... FOR UPDATE no pedido, verificando limite, expiração e PIX real.
-- Premium: limitar a três ativos numa operação transacional com lock global.
-- Fotos: bucket privado; somente imagens de pedidos aprovados podem ser mostradas
-- via endpoint de imagens controlado. Não armazenar imagens em base64 no Postgres.
