-- BUSQUE SERVIÇOS — ETAPA 1 / MIGRAÇÃO JÁ APLICADA NO SUPABASE DO BUSQUE TORRES
-- Tabelas existentes não foram alteradas. Este arquivo documenta a estrutura implantada; não reaplicar sem revisão.
create table if not exists public.busque_servicos_pedidos (
 id uuid primary key default gen_random_uuid(),
 titulo text not null check (char_length(trim(titulo)) between 5 and 120),
 descricao text not null check (char_length(trim(descricao)) between 10 and 2000),
 bairro text not null check (char_length(trim(bairro)) between 2 and 100),
 nome_solicitante text not null check (char_length(trim(nome_solicitante)) between 2 and 100),
 whatsapp text not null check (char_length(whatsapp) between 10 and 20),
 endereco_privado text,
 fotos_paths text[] not null default '{}' check (cardinality(fotos_paths) <= 3),
 limite_orcamentos smallint not null check (limite_orcamentos in (3,5)),
 duracao_dias smallint not null check (duracao_dias in (3,5)),
 status text not null default 'pendente' check (status in ('pendente','aprovado','rejeitado','encerrado')),
 aceite_termos_versao text not null check (char_length(aceite_termos_versao) between 1 and 40),
 aceite_privacidade_versao text not null check (char_length(aceite_privacidade_versao) between 1 and 40),
 aceite_em timestamptz not null,
 criado_em timestamptz not null default now(),
 aprovado_em timestamptz,
 expira_em timestamptz,
 revisado_por uuid references auth.users(id),
 revisado_em timestamptz,
 motivo_rejeicao text,
 constraint bs_aprovacao_consistente check(status <> 'aprovado' or (aprovado_em is not null and expira_em is not null and expira_em > aprovado_em))
);
create index if not exists bs_pedidos_fila_idx on public.busque_servicos_pedidos(status,criado_em);
create index if not exists bs_pedidos_ativos_idx on public.busque_servicos_pedidos(expira_em) where status='aprovado';
alter table public.busque_servicos_pedidos enable row level security;
revoke all on public.busque_servicos_pedidos from anon, authenticated;
-- Somente endpoints autenticados no servidor poderão criar e revisar pedidos.
-- Não usar service_role no browser, não criar policy pública de SELECT.
-- Validação de CAPTCHA/rate limit, upload privado e validação de admin no backend.
-- Fotos: bucket privado dedicado, tamanho/tipo validados e URLs temporárias.
-- Páginas públicas deverão usar endpoint que retorna APENAS campos públicos.
