CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA extensions;
CREATE EXTENSION IF NOT EXISTS btree_gist WITH SCHEMA extensions;
SET search_path = public, extensions, pg_catalog;
CREATE TABLE public."aceites_contrato" (
"id" uuid DEFAULT gen_random_uuid() NOT NULL,
"empresa_id" uuid NOT NULL,
"cidade_id" text NOT NULL,
"contrato_versao_id" uuid NOT NULL,
"contrato_codigo" text NOT NULL,
"contrato_sha256" text NOT NULL,
"produto_codigo" text NOT NULL,
"produto_nome" text NOT NULL,
"quantidade" integer DEFAULT 1 NOT NULL,
"valor" numeric(12,2) NOT NULL,
"moeda" text DEFAULT 'BRL'::text NOT NULL,
"duracao_dias" integer,
"responsavel_nome" text NOT NULL,
"documento_tipo" text NOT NULL,
"documento_numero" text NOT NULL,
"capacidade" text NOT NULL,
"declaracao_autoridade" boolean DEFAULT false NOT NULL,
"whatsapp_cadastrado" text NOT NULL,
"verificacao_canal" text DEFAULT 'whatsapp_cadastrado'::text NOT NULL,
"verificacao_status" text DEFAULT 'confirmacao_declarada'::text NOT NULL,
"verificacao_em" timestamp with time zone,
"aceite_contrato" boolean DEFAULT false NOT NULL,
"aceite_privacidade" boolean DEFAULT false NOT NULL,
"aceite_politica_comercial" boolean DEFAULT false NOT NULL,
"aceite_em" timestamp with time zone DEFAULT now() NOT NULL,
"ip" inet,
"user_agent" text,
"status" text DEFAULT 'aceite_confirmado_pagamento_pendente'::text NOT NULL,
"pagamento_id" uuid,
"pago_em" timestamp with time zone,
"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE public."aceites_contrato" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public."aceites_contrato" FROM PUBLIC, anon, authenticated;
CREATE TABLE public."aceites_promocao_dia" (
"id" uuid DEFAULT gen_random_uuid() NOT NULL,
"promocao_id" uuid NOT NULL,
"empresa_id" uuid NOT NULL,
"cidade_id" text NOT NULL,
"termos_uso" boolean NOT NULL,
"privacidade" boolean NOT NULL,
"politica_comercial" boolean NOT NULL,
"politica_conteudo" boolean NOT NULL,
"documentos" jsonb DEFAULT '{}'::jsonb NOT NULL,
"aceite_em" timestamp with time zone DEFAULT now() NOT NULL,
"ip" text,
"user_agent" text,
"whatsapp_contato" text
);
ALTER TABLE public."aceites_promocao_dia" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public."aceites_promocao_dia" FROM PUBLIC, anon, authenticated;
CREATE TABLE public."admin_atividades" (
"id" uuid DEFAULT gen_random_uuid() NOT NULL,
"user_id" uuid NOT NULL,
"sessao_id" uuid,
"acao" text NOT NULL,
"entidade" text,
"entidade_id" uuid,
"titulo" text NOT NULL,
"detalhes" jsonb DEFAULT '{}'::jsonb NOT NULL,
"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE public."admin_atividades" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public."admin_atividades" FROM PUBLIC, anon, authenticated;
CREATE TABLE public."admin_permissoes_modulos" (
"user_id" uuid NOT NULL,
"financeiro" boolean DEFAULT false NOT NULL,
"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE public."admin_permissoes_modulos" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public."admin_permissoes_modulos" FROM PUBLIC, anon, authenticated;
CREATE TABLE public."admin_sessoes" (
"id" uuid DEFAULT gen_random_uuid() NOT NULL,
"user_id" uuid NOT NULL,
"iniciado_em" timestamp with time zone DEFAULT now() NOT NULL,
"ultima_atividade_em" timestamp with time zone DEFAULT now() NOT NULL,
"encerrado_em" timestamp with time zone,
"user_agent" text,
"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE public."admin_sessoes" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public."admin_sessoes" FROM PUBLIC, anon, authenticated;
CREATE TABLE public."administradores" (
"user_id" uuid NOT NULL,
"nome" text NOT NULL,
"ativo" boolean DEFAULT true NOT NULL,
"created_at" timestamp with time zone DEFAULT now() NOT NULL,
"papel" text DEFAULT 'operador'::text NOT NULL
);
ALTER TABLE public."administradores" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public."administradores" FROM PUBLIC, anon, authenticated;
CREATE TABLE public."agenda_premium" (
"id" uuid DEFAULT gen_random_uuid() NOT NULL,
"empresa_id" uuid NOT NULL,
"tipo" text NOT NULL,
"slot" integer NOT NULL,
"data_inicio" date NOT NULL,
"data_fim" date NOT NULL,
"status" text DEFAULT 'reservado'::text NOT NULL,
"origem" text DEFAULT 'venda_extra'::text NOT NULL,
"valor" numeric(10,2),
"observacoes" text,
"criado_por" uuid DEFAULT auth.uid(),
"created_at" timestamp with time zone DEFAULT now() NOT NULL,
"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
"periodo" daterange GENERATED ALWAYS AS (daterange(data_inicio, data_fim, '[]'::text)) STORED,
"cidade_id" text NOT NULL
);
ALTER TABLE public."agenda_premium" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public."agenda_premium" FROM PUBLIC, anon, authenticated;
CREATE TABLE public."agenda_premium_historico" (
"id" uuid NOT NULL,
"empresa_id" uuid NOT NULL,
"tipo" text NOT NULL,
"slot" integer,
"data_inicio" date NOT NULL,
"data_fim" date NOT NULL,
"status" text,
"origem" text,
"valor" numeric,
"observacoes" text,
"criado_por" uuid,
"created_at" timestamp with time zone,
"updated_at" timestamp with time zone,
"periodo" daterange,
"cidade_id" text,
"arquivado_em" timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE public."agenda_premium_historico" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public."agenda_premium_historico" FROM PUBLIC, anon, authenticated;
CREATE TABLE public."backup_migracao_midias_empresas" (
"id" bigint GENERATED BY DEFAULT AS IDENTITY NOT NULL,
"lote" text NOT NULL,
"empresa_id" uuid NOT NULL,
"imagem_url" text,
"logo_url" text,
"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE public."backup_migracao_midias_empresas" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public."backup_migracao_midias_empresas" FROM PUBLIC, anon, authenticated;
CREATE TABLE public."backup_migracao_midias_vagas" (
"id" bigint GENERATED BY DEFAULT AS IDENTITY NOT NULL,
"lote" text NOT NULL,
"vaga_id" uuid NOT NULL,
"imagem_url" text,
"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE public."backup_migracao_midias_vagas" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public."backup_migracao_midias_vagas" FROM PUBLIC, anon, authenticated;
CREATE TABLE public."banners_site" (
"id" uuid DEFAULT gen_random_uuid() NOT NULL,
"nome" text NOT NULL,
"tipo" text DEFAULT 'temporario'::text NOT NULL,
"imagem_url" text NOT NULL,
"storage_path" text NOT NULL,
"inicio_em" timestamp with time zone,
"fim_em" timestamp with time zone,
"ativo" boolean DEFAULT true NOT NULL,
"created_at" timestamp with time zone DEFAULT now() NOT NULL,
"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
"cidade_id" text DEFAULT 'caxias'::text NOT NULL
);
ALTER TABLE public."banners_site" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public."banners_site" FROM PUBLIC, anon, authenticated;
CREATE TABLE public."beneficios_foguinho" (
"empresa_id" uuid NOT NULL,
"codigo" text NOT NULL,
"ativo" boolean DEFAULT true NOT NULL,
"created_at" timestamp with time zone DEFAULT now() NOT NULL,
"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE public."beneficios_foguinho" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public."beneficios_foguinho" FROM PUBLIC, anon, authenticated;
CREATE TABLE public."beneficios_foguinho_usos" (
"id" uuid DEFAULT gen_random_uuid() NOT NULL,
"empresa_id" uuid NOT NULL,
"promocao_id" uuid NOT NULL,
"competencia" date NOT NULL,
"codigo_usado" text NOT NULL,
"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE public."beneficios_foguinho_usos" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public."beneficios_foguinho_usos" FROM PUBLIC, anon, authenticated;
CREATE TABLE public."cardapio_acessos_diarios" (
"dia" date NOT NULL,
"origem" text DEFAULT 'cardapio_publico'::text NOT NULL,
"acessos" integer DEFAULT 0 NOT NULL,
"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE public."cardapio_acessos_diarios" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public."cardapio_acessos_diarios" FROM PUBLIC, anon, authenticated;
CREATE TABLE public."cardapio_admin_acessos" (
"user_id" uuid NOT NULL,
"nome" text NOT NULL,
"ativo" boolean DEFAULT true NOT NULL,
"created_at" timestamp with time zone DEFAULT now() NOT NULL,
"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE public."cardapio_admin_acessos" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public."cardapio_admin_acessos" FROM PUBLIC, anon, authenticated;
CREATE TABLE public."cardapio_banco_conexoes" (
"cardapio_empresa_id" uuid NOT NULL,
"banco_codigo" text NOT NULL,
"banco_nome" text NOT NULL,
"status" text DEFAULT 'pendente'::text NOT NULL,
"ambiente" text DEFAULT 'producao'::text NOT NULL,
"pix_chave" text,
"pix_chave_tipo" text,
"config_publica" jsonb DEFAULT '{}'::jsonb NOT NULL,
"client_id_secret_id" uuid,
"client_secret_secret_id" uuid,
"certificado_secret_id" uuid,
"chave_privada_secret_id" uuid,
"conectado_em" timestamp with time zone,
"ultimo_teste_em" timestamp with time zone,
"ultimo_erro" text,
"created_at" timestamp with time zone DEFAULT now() NOT NULL,
"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
"access_token_secret_id" uuid,
"access_token_expires_at" timestamp with time zone,
"webhook_configurado" boolean DEFAULT false NOT NULL,
"adapter_versao" text DEFAULT 'v1'::text NOT NULL,
"tipo_integracao" text,
"api_token_secret_id" uuid,
"webhook_token_secret_id" uuid,
"provider_public_key" text
);
ALTER TABLE public."cardapio_banco_conexoes" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public."cardapio_banco_conexoes" FROM PUBLIC, anon, authenticated;
CREATE TABLE public."cardapio_bancos_catalogo" (
"codigo" text NOT NULL,
"nome" text NOT NULL,
"categoria" text DEFAULT 'banco'::text NOT NULL,
"prioridade" integer DEFAULT 100 NOT NULL,
"status_integracao" text DEFAULT 'homologacao'::text NOT NULL,
"tipo_integracao" text,
"ambiente_homologacao" boolean DEFAULT false NOT NULL,
"requer_pix_chave" boolean DEFAULT false NOT NULL,
"requer_client_credentials" boolean DEFAULT false NOT NULL,
"requer_certificado" boolean DEFAULT false NOT NULL,
"requer_api_token" boolean DEFAULT false NOT NULL,
"requer_webhook_token" boolean DEFAULT false NOT NULL,
"requer_cliente_documento" boolean DEFAULT false NOT NULL,
"requer_cliente_email" boolean DEFAULT false NOT NULL,
"observacao" text,
"fonte_oficial" text,
"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE public."cardapio_bancos_catalogo" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public."cardapio_bancos_catalogo" FROM PUBLIC, anon, authenticated;
CREATE TABLE public."cardapio_busque_torres_beneficios" (
"id" uuid DEFAULT gen_random_uuid() NOT NULL,
"cardapio_empresa_id" uuid NOT NULL,
"convite_id" uuid NOT NULL,
"chave_empresa" text NOT NULL,
"busque_empresa_id" uuid,
"status" text DEFAULT 'emitido'::text NOT NULL,
"criado_em" timestamp with time zone DEFAULT now() NOT NULL,
"utilizado_em" timestamp with time zone,
"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
"chave_negocio" text
);
ALTER TABLE public."cardapio_busque_torres_beneficios" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public."cardapio_busque_torres_beneficios" FROM PUBLIC, anon, authenticated;
CREATE TABLE public."cardapio_comercial_catalogo" (
"codigo" text NOT NULL,
"nome" text NOT NULL,
"tipo" text NOT NULL,
"descricao" text NOT NULL,
"valor" numeric(10,2) NOT NULL,
"duracao_dias" integer NOT NULL,
"limite_slots" integer NOT NULL,
"ativo" boolean DEFAULT true NOT NULL,
"ordem" integer DEFAULT 0 NOT NULL,
"created_at" timestamp with time zone DEFAULT now() NOT NULL,
"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE public."cardapio_comercial_catalogo" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public."cardapio_comercial_catalogo" FROM PUBLIC, anon, authenticated;
CREATE TABLE public."cardapio_comercial_compras" (
"id" uuid DEFAULT gen_random_uuid() NOT NULL,
"cardapio_empresa_id" uuid NOT NULL,
"codigo_produto" text NOT NULL,
"produto_oferta_id" uuid,
"preco_original" numeric(10,2),
"preco_oferta" numeric(10,2),
"status" text DEFAULT 'pendente'::text NOT NULL,
"valor" numeric(10,2) NOT NULL,
"provider" text DEFAULT 'mercadopago_busque'::text NOT NULL,
"provider_payment_id" text,
"external_reference" text NOT NULL,
"qr_code" text,
"qr_code_base64" text,
"ticket_url" text,
"reserva_expira_em" timestamp with time zone NOT NULL,
"inicio_em" timestamp with time zone,
"fim_em" timestamp with time zone,
"created_at" timestamp with time zone DEFAULT now() NOT NULL,
"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE public."cardapio_comercial_compras" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public."cardapio_comercial_compras" FROM PUBLIC, anon, authenticated;
CREATE TABLE public."cardapio_creditos_carteiras" (
"cardapio_empresa_id" uuid NOT NULL,
"saldo" integer DEFAULT 0 NOT NULL,
"reservados" integer DEFAULT 0 NOT NULL,
"alerta_limite" integer DEFAULT 5 NOT NULL,
"created_at" timestamp with time zone DEFAULT now() NOT NULL,
"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE public."cardapio_creditos_carteiras" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public."cardapio_creditos_carteiras" FROM PUBLIC, anon, authenticated;
CREATE TABLE public."cardapio_creditos_config" (
"chave" text NOT NULL,
"valor_credito" numeric(10,2) DEFAULT 1.00 NOT NULL,
"minimo_recarga" integer DEFAULT 1 NOT NULL,
"maximo_recarga" integer DEFAULT 1000 NOT NULL,
"alerta_limite" integer DEFAULT 5 NOT NULL,
"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE public."cardapio_creditos_config" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public."cardapio_creditos_config" FROM PUBLIC, anon, authenticated;
CREATE TABLE public."cardapio_creditos_movimentos" (
"id" uuid DEFAULT gen_random_uuid() NOT NULL,
"cardapio_empresa_id" uuid NOT NULL,
"tipo" text NOT NULL,
"quantidade" integer NOT NULL,
"saldo_antes" integer NOT NULL,
"saldo_depois" integer NOT NULL,
"pedido_id" uuid,
"recarga_id" uuid,
"descricao" text,
"chave_idempotencia" text NOT NULL,
"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE public."cardapio_creditos_movimentos" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public."cardapio_creditos_movimentos" FROM PUBLIC, anon, authenticated;
CREATE TABLE public."cardapio_creditos_recargas" (
"id" uuid DEFAULT gen_random_uuid() NOT NULL,
"cardapio_empresa_id" uuid NOT NULL,
"quantidade" integer NOT NULL,
"valor_unitario" numeric(10,2) DEFAULT 1.00 NOT NULL,
"valor_total" numeric(12,2) NOT NULL,
"status" text DEFAULT 'pendente'::text NOT NULL,
"provider" text DEFAULT 'mercadopago_busque'::text NOT NULL,
"provider_payment_id" text,
"external_reference" text NOT NULL,
"qr_code" text,
"qr_code_base64" text,
"ticket_url" text,
"expira_em" timestamp with time zone,
"pago_em" timestamp with time zone,
"created_at" timestamp with time zone DEFAULT now() NOT NULL,
"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE public."cardapio_creditos_recargas" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public."cardapio_creditos_recargas" FROM PUBLIC, anon, authenticated;
CREATE TABLE public."cardapio_creditos_reservas" (
"pedido_id" uuid NOT NULL,
"cardapio_empresa_id" uuid NOT NULL,
"status" text DEFAULT 'reservada'::text NOT NULL,
"expira_em" timestamp with time zone NOT NULL,
"created_at" timestamp with time zone DEFAULT now() NOT NULL,
"consumida_em" timestamp with time zone,
"liberada_em" timestamp with time zone,
"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE public."cardapio_creditos_reservas" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public."cardapio_creditos_reservas" FROM PUBLIC, anon, authenticated;
CREATE TABLE public."cardapio_empresas" (
"id" uuid DEFAULT gen_random_uuid() NOT NULL,
"empresa_id" uuid,
"auth_user_id" uuid,
"nome" text NOT NULL,
"cidade_id" text DEFAULT 'caxias'::text NOT NULL,
"status" text DEFAULT 'teste'::text NOT NULL,
"periodo_gratis_inicio" timestamp with time zone DEFAULT now() NOT NULL,
"periodo_gratis_fim" timestamp with time zone DEFAULT (now() + '30 days'::interval) NOT NULL,
"created_at" timestamp with time zone DEFAULT now() NOT NULL,
"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
"whatsapp" text,
"endereco" text,
"categorias" text[] DEFAULT '{}'::text[] NOT NULL,
"horario_abertura" time without time zone,
"horario_fechamento" time without time zone,
"aceitando_pedidos" boolean DEFAULT true NOT NULL,
"permite_pagamento_simulado" boolean DEFAULT false NOT NULL,
"foto_url" text,
"modelo_recebimento" text DEFAULT 'mercadopago_split'::text NOT NULL,
"aceitando_pedidos_desde" timestamp with time zone,
"latitude" numeric(9,6),
"longitude" numeric(9,6),
"localizacao_atualizada_em" timestamp with time zone
);
ALTER TABLE public."cardapio_empresas" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public."cardapio_empresas" FROM PUBLIC, anon, authenticated;
CREATE TABLE public."cardapio_entrega_config" (
"cardapio_empresa_id" uuid NOT NULL,
"modo" text DEFAULT 'pickup'::text NOT NULL,
"faixas" jsonb DEFAULT '[]'::jsonb NOT NULL,
"created_at" timestamp with time zone DEFAULT now() NOT NULL,
"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE public."cardapio_entrega_config" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public."cardapio_entrega_config" FROM PUBLIC, anon, authenticated;
CREATE TABLE public."cardapio_entrega_quotes" (
"id" uuid DEFAULT gen_random_uuid() NOT NULL,
"cardapio_empresa_id" uuid NOT NULL,
"cliente_latitude" numeric(9,6) NOT NULL,
"cliente_longitude" numeric(9,6) NOT NULL,
"distancia_km" numeric(9,3) NOT NULL,
"duracao_segundos" integer,
"faixa_km" numeric(8,2) NOT NULL,
"taxa" numeric(10,2) NOT NULL,
"provider" text DEFAULT 'mapbox'::text NOT NULL,
"profile" text DEFAULT 'mapbox/driving'::text NOT NULL,
"created_at" timestamp with time zone DEFAULT now() NOT NULL,
"expires_at" timestamp with time zone DEFAULT (now() + '00:15:00'::interval) NOT NULL,
"pedido_id" uuid
);
ALTER TABLE public."cardapio_entrega_quotes" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public."cardapio_entrega_quotes" FROM PUBLIC, anon, authenticated;
CREATE TABLE public."cardapio_mapbox_config" (
"chave" text DEFAULT 'padrao'::text NOT NULL,
"access_token_secret_id" uuid,
"profile" text DEFAULT 'mapbox/driving'::text NOT NULL,
"enabled" boolean DEFAULT true NOT NULL,
"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE public."cardapio_mapbox_config" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public."cardapio_mapbox_config" FROM PUBLIC, anon, authenticated;
CREATE TABLE public."cardapio_metricas_diarias" (
"cardapio_empresa_id" uuid NOT NULL,
"dia" date NOT NULL,
"menu_views" integer DEFAULT 0 NOT NULL,
"cart_starts" integer DEFAULT 0 NOT NULL,
"checkout_starts" integer DEFAULT 0 NOT NULL,
"product_adds" integer DEFAULT 0 NOT NULL,
"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE public."cardapio_metricas_diarias" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public."cardapio_metricas_diarias" FROM PUBLIC, anon, authenticated;
CREATE TABLE public."cardapio_metricas_produtos_diarias" (
"cardapio_empresa_id" uuid NOT NULL,
"dia" date NOT NULL,
"produto_id" uuid NOT NULL,
"nome_snapshot" text NOT NULL,
"adds" integer DEFAULT 0 NOT NULL,
"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
"clicks" integer DEFAULT 0 NOT NULL
);
ALTER TABLE public."cardapio_metricas_produtos_diarias" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public."cardapio_metricas_produtos_diarias" FROM PUBLIC, anon, authenticated;
CREATE TABLE public."cardapio_mp_tokens" (
"cardapio_empresa_id" uuid NOT NULL,
"mp_user_id" text NOT NULL,
"access_token_ciphertext" text NOT NULL,
"access_token_iv" text NOT NULL,
"refresh_token_ciphertext" text NOT NULL,
"refresh_token_iv" text NOT NULL,
"token_expires_at" timestamp with time zone NOT NULL,
"live_mode" boolean DEFAULT false NOT NULL,
"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE public."cardapio_mp_tokens" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public."cardapio_mp_tokens" FROM PUBLIC, anon, authenticated;
CREATE TABLE public."cardapio_pagamento_config" (
"id" uuid DEFAULT gen_random_uuid() NOT NULL,
"cardapio_empresa_id" uuid NOT NULL,
"provider" text NOT NULL,
"status" text DEFAULT 'desconectado'::text NOT NULL,
"provider_account_id" text,
"pix_key_type" text,
"pix_key" text,
"pix_receiver_name" text,
"connected_at" timestamp with time zone,
"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE public."cardapio_pagamento_config" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public."cardapio_pagamento_config" FROM PUBLIC, anon, authenticated;
CREATE TABLE public."cardapio_pagamentos" (
"id" uuid DEFAULT gen_random_uuid() NOT NULL,
"pedido_id" uuid NOT NULL,
"cardapio_empresa_id" uuid NOT NULL,
"provider" text NOT NULL,
"provider_payment_id" text,
"provider_preference_id" text,
"status" text DEFAULT 'pendente'::text NOT NULL,
"valor_bruto" numeric(12,2) NOT NULL,
"taxa_busque" numeric(12,2) DEFAULT 1.00 NOT NULL,
"status_detail" text,
"pago_em" timestamp with time zone,
"created_at" timestamp with time zone DEFAULT now() NOT NULL,
"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
"provider_order_id" text,
"banco_codigo" text,
"pix_txid" text,
"pix_copia_cola" text,
"pix_location" text
);
ALTER TABLE public."cardapio_pagamentos" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public."cardapio_pagamentos" FROM PUBLIC, anon, authenticated;
CREATE TABLE public."cardapio_pedidos" (
"id" uuid DEFAULT gen_random_uuid() NOT NULL,
"codigo" text NOT NULL,
"cardapio_empresa_id" uuid NOT NULL,
"cliente_nome" text NOT NULL,
"cliente_telefone" text NOT NULL,
"endereco_entrega" text,
"complemento" text,
"modalidade" text NOT NULL,
"itens" jsonb DEFAULT '[]'::jsonb NOT NULL,
"subtotal" numeric(12,2) NOT NULL,
"frete" numeric(12,2) DEFAULT 0 NOT NULL,
"total" numeric(12,2) NOT NULL,
"status" text DEFAULT 'novo'::text NOT NULL,
"created_at" timestamp with time zone DEFAULT now() NOT NULL,
"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
"distancia_entrega_km" numeric(8,3),
"faixa_entrega_km" numeric(8,2)
);
ALTER TABLE public."cardapio_pedidos" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public."cardapio_pedidos" FROM PUBLIC, anon, authenticated;
CREATE TABLE public."cardapio_produto_grupos" (
"id" uuid DEFAULT gen_random_uuid() NOT NULL,
"produto_id" uuid NOT NULL,
"nome" text NOT NULL,
"tipo" text DEFAULT 'single'::text NOT NULL,
"obrigatorio" boolean DEFAULT false NOT NULL,
"minimo" integer DEFAULT 0 NOT NULL,
"maximo" integer DEFAULT 1 NOT NULL,
"ordem" integer DEFAULT 0 NOT NULL,
"created_at" timestamp with time zone DEFAULT now() NOT NULL,
"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
"modo_preco" text DEFAULT 'adicional'::text NOT NULL
);
ALTER TABLE public."cardapio_produto_grupos" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public."cardapio_produto_grupos" FROM PUBLIC, anon, authenticated;
CREATE TABLE public."cardapio_produto_opcoes" (
"id" uuid DEFAULT gen_random_uuid() NOT NULL,
"grupo_id" uuid NOT NULL,
"nome" text NOT NULL,
"preco_adicional" numeric(12,2) DEFAULT 0 NOT NULL,
"disponivel" boolean DEFAULT true NOT NULL,
"ordem" integer DEFAULT 0 NOT NULL,
"created_at" timestamp with time zone DEFAULT now() NOT NULL,
"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE public."cardapio_produto_opcoes" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public."cardapio_produto_opcoes" FROM PUBLIC, anon, authenticated;
CREATE TABLE public."cardapio_produtos" (
"id" uuid DEFAULT gen_random_uuid() NOT NULL,
"cardapio_empresa_id" uuid NOT NULL,
"nome" text NOT NULL,
"descricao" text,
"preco" numeric(10,2) NOT NULL,
"categoria" text NOT NULL,
"disponivel" boolean DEFAULT true NOT NULL,
"imagem_url" text,
"ordem" integer DEFAULT 0 NOT NULL,
"created_at" timestamp with time zone DEFAULT now() NOT NULL,
"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE public."cardapio_produtos" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public."cardapio_produtos" FROM PUBLIC, anon, authenticated;
CREATE TABLE public."cardapio_public_rate_limits" (
"route" text NOT NULL,
"fingerprint" text NOT NULL,
"window_seconds" integer NOT NULL,
"bucket_start" timestamp with time zone NOT NULL,
"hits" integer DEFAULT 1 NOT NULL,
"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE public."cardapio_public_rate_limits" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public."cardapio_public_rate_limits" FROM PUBLIC, anon, authenticated;
CREATE TABLE public."cardapio_visitas_auto_sessoes" (
"fingerprint" text NOT NULL,
"last_seen" timestamp with time zone DEFAULT now() NOT NULL,
"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE public."cardapio_visitas_auto_sessoes" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public."cardapio_visitas_auto_sessoes" FROM PUBLIC, anon, authenticated;
CREATE TABLE public."cardapio_visitas_diarias" (
"dia" date NOT NULL,
"visitas" bigint DEFAULT 0 NOT NULL,
"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE public."cardapio_visitas_diarias" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public."cardapio_visitas_diarias" FROM PUBLIC, anon, authenticated;
CREATE TABLE public."cardapio_visitas_sessoes" (
"session_id" text NOT NULL,
"dia" date NOT NULL,
"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE public."cardapio_visitas_sessoes" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public."cardapio_visitas_sessoes" FROM PUBLIC, anon, authenticated;
CREATE TABLE public."cardapio_webhook_eventos" (
"event_key" text NOT NULL,
"provider" text DEFAULT 'mercadopago'::text NOT NULL,
"topic" text,
"action" text,
"resource_id" text,
"cardapio_empresa_id" uuid,
"pedido_id" uuid,
"status" text DEFAULT 'recebido'::text NOT NULL,
"payload" jsonb,
"error_detail" text,
"created_at" timestamp with time zone DEFAULT now() NOT NULL,
"processed_at" timestamp with time zone
);
ALTER TABLE public."cardapio_webhook_eventos" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public."cardapio_webhook_eventos" FROM PUBLIC, anon, authenticated;
CREATE TABLE public."cidades" (
"id" text NOT NULL,
"nome_sistema" text NOT NULL,
"cidade" text NOT NULL,
"uf" text NOT NULL,
"ativo" boolean DEFAULT true NOT NULL,
"created_at" timestamp with time zone DEFAULT now() NOT NULL,
"url_base" text
);
ALTER TABLE public."cidades" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public."cidades" FROM PUBLIC, anon, authenticated;
CREATE TABLE public."clima_acessos" (
"id" bigint GENERATED BY DEFAULT AS IDENTITY NOT NULL,
"cidade_id" text DEFAULT 'caxias'::text NOT NULL,
"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE public."clima_acessos" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public."clima_acessos" FROM PUBLIC, anon, authenticated;
CREATE TABLE public."configuracoes_comerciais" (
"id" smallint DEFAULT 1 NOT NULL,
"primeiros_dias_gratis" integer DEFAULT 30 NOT NULL,
"data_inicio_cobranca" date DEFAULT '2026-09-10'::date NOT NULL,
"preco_comum" numeric(10,2) DEFAULT 9.90 NOT NULL,
"preco_destaque" numeric(10,2) DEFAULT 29.90 NOT NULL,
"preco_master" numeric(10,2) DEFAULT 49.90 NOT NULL,
"moeda" text DEFAULT 'BRL'::text NOT NULL,
"cobranca_ativa" boolean DEFAULT true NOT NULL,
"created_at" timestamp with time zone DEFAULT now() NOT NULL,
"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE public."configuracoes_comerciais" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public."configuracoes_comerciais" FROM PUBLIC, anon, authenticated;
CREATE TABLE public."contrato_versoes" (
"id" uuid DEFAULT gen_random_uuid() NOT NULL,
"codigo" text NOT NULL,
"titulo" text NOT NULL,
"arquivo_url" text NOT NULL,
"sha256" text NOT NULL,
"publicado_em" timestamp with time zone DEFAULT now() NOT NULL,
"ativo" boolean DEFAULT true NOT NULL,
"created_at" timestamp with time zone DEFAULT now() NOT NULL,
"cidade_id" text NOT NULL
);
ALTER TABLE public."contrato_versoes" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public."contrato_versoes" FROM PUBLIC, anon, authenticated;
CREATE TABLE public."convites_cortesia_cadastro" (
"id" uuid DEFAULT gen_random_uuid() NOT NULL,
"codigo" text NOT NULL,
"nome_destinatario" text,
"cidade_id" text DEFAULT 'caxias'::text NOT NULL,
"dias" integer NOT NULL,
"motivo" text,
"status" text DEFAULT 'disponivel'::text NOT NULL,
"empresa_id" uuid,
"criado_em" timestamp with time zone DEFAULT now() NOT NULL,
"expira_em" timestamp with time zone,
"utilizado_em" timestamp with time zone
);
ALTER TABLE public."convites_cortesia_cadastro" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public."convites_cortesia_cadastro" FROM PUBLIC, anon, authenticated;
CREATE TABLE public."cortesias_empresas" (
"id" uuid DEFAULT gen_random_uuid() NOT NULL,
"empresa_id" uuid,
"empresa_nome" text NOT NULL,
"cidade_id" text DEFAULT 'caxias'::text NOT NULL,
"dias" integer NOT NULL,
"motivo" text NOT NULL,
"vencimento_anterior" timestamp with time zone,
"vencimento_novo" timestamp with time zone NOT NULL,
"concedido_por" uuid NOT NULL,
"concedido_em" timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE public."cortesias_empresas" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public."cortesias_empresas" FROM PUBLIC, anon, authenticated;
CREATE TABLE public."crm_alertas_vencimento" (
"id" uuid DEFAULT gen_random_uuid() NOT NULL,
"empresa_id" uuid NOT NULL,
"user_id" uuid NOT NULL,
"vencimento" date NOT NULL,
"cidade_id" text NOT NULL,
"visto_em" timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE public."crm_alertas_vencimento" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public."crm_alertas_vencimento" FROM PUBLIC, anon, authenticated;
CREATE TABLE public."crm_atividades" (
"id" uuid DEFAULT gen_random_uuid() NOT NULL,
"cidade_id" text NOT NULL,
"lead_id" uuid,
"tipo" text DEFAULT 'nota'::text NOT NULL,
"titulo" text NOT NULL,
"descricao" text,
"created_by" uuid DEFAULT auth.uid(),
"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE public."crm_atividades" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public."crm_atividades" FROM PUBLIC, anon, authenticated;
CREATE TABLE public."crm_leads" (
"id" uuid DEFAULT gen_random_uuid() NOT NULL,
"cidade_id" text NOT NULL,
"empresa_nome" text NOT NULL,
"contato_nome" text,
"whatsapp" text,
"email" text,
"instagram" text,
"categoria" text,
"origem" text DEFAULT 'prospeccao'::text,
"status" text DEFAULT 'novo'::text NOT NULL,
"observacoes" text,
"proximo_contato" date,
"ultimo_contato" timestamp with time zone,
"convertido_empresa_id" text,
"created_at" timestamp with time zone DEFAULT now() NOT NULL,
"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
"historico" jsonb DEFAULT '[]'::jsonb NOT NULL,
"valor_estimado" numeric(12,2) DEFAULT 0 NOT NULL,
"probabilidade" smallint DEFAULT 10 NOT NULL,
"prioridade" text DEFAULT 'media'::text NOT NULL,
"previsao_fechamento" date,
"motivo_perda" text,
"responsavel_id" uuid,
"tags" text[] DEFAULT '{}'::text[] NOT NULL,
"produto_interesse" text,
"empresa_id" uuid,
"ultima_atividade_em" timestamp with time zone
);
ALTER TABLE public."crm_leads" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public."crm_leads" FROM PUBLIC, anon, authenticated;
CREATE TABLE public."crm_tarefas" (
"id" uuid DEFAULT gen_random_uuid() NOT NULL,
"cidade_id" text NOT NULL,
"lead_id" uuid,
"titulo" text NOT NULL,
"descricao" text,
"tipo" text DEFAULT 'follow_up'::text NOT NULL,
"status" text DEFAULT 'pendente'::text NOT NULL,
"prioridade" text DEFAULT 'media'::text NOT NULL,
"vencimento" timestamp with time zone,
"responsavel_id" uuid,
"concluida_em" timestamp with time zone,
"created_by" uuid DEFAULT auth.uid(),
"created_at" timestamp with time zone DEFAULT now() NOT NULL,
"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE public."crm_tarefas" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public."crm_tarefas" FROM PUBLIC, anon, authenticated;
CREATE TABLE public."curtidas_empresas" (
"id" bigint GENERATED BY DEFAULT AS IDENTITY NOT NULL,
"empresa_id" text NOT NULL,
"visitante_token" text NOT NULL,
"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE public."curtidas_empresas" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public."curtidas_empresas" FROM PUBLIC, anon, authenticated;
CREATE TABLE public."empresas" (
"id" uuid DEFAULT gen_random_uuid() NOT NULL,
"nome" text NOT NULL,
"categoria" text NOT NULL,
"subcategoria" text NOT NULL,
"descricao" text NOT NULL,
"whatsapp" text NOT NULL,
"instagram" text,
"site" text,
"email" text,
"cidade" text NOT NULL,
"bairro" text,
"endereco" text,
"horario" text,
"mapa_url" text,
"produtos" text,
"servicos" text,
"palavras_chave" text,
"imagem_url" text,
"logo_url" text,
"plano" text DEFAULT 'comum'::text NOT NULL,
"plano_solicitado" text DEFAULT 'comum'::text NOT NULL,
"status" text DEFAULT 'pendente'::text NOT NULL,
"ativo" boolean DEFAULT false NOT NULL,
"pagamento_confirmado" boolean DEFAULT false NOT NULL,
"data_inicio" timestamp with time zone,
"data_vencimento" timestamp with time zone,
"motivo_status" text,
"moderado_por" uuid,
"moderado_em" timestamp with time zone,
"referencia_pagamento" text,
"ultimo_pagamento_em" timestamp with time zone,
"termos_aceitos_em" timestamp with time zone DEFAULT now() NOT NULL,
"origem" text DEFAULT 'formulario_publico'::text NOT NULL,
"busca_texto" text DEFAULT ''::text NOT NULL,
"created_at" timestamp with time zone DEFAULT now() NOT NULL,
"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
"codigo_renovacao" text DEFAULT (gen_random_uuid())::text NOT NULL,
"cidade_id" text DEFAULT 'caxias'::text NOT NULL,
"assinatura_periodo" text DEFAULT 'mensal'::text NOT NULL,
"premium_master_total" integer DEFAULT 0 NOT NULL,
"premium_master_usado" integer DEFAULT 0 NOT NULL,
"premium_destaque_total" integer DEFAULT 0 NOT NULL,
"premium_destaque_usado" integer DEFAULT 0 NOT NULL,
"periodo_gratis_inicio" timestamp with time zone,
"periodo_gratis_fim" timestamp with time zone,
"cadastro_exige_pagamento" boolean DEFAULT false NOT NULL,
"publicacao_cortesia" boolean DEFAULT false NOT NULL,
"arquivado_em" timestamp with time zone,
"arquivado_motivo" text,
"arquivado_automatico" boolean DEFAULT false NOT NULL,
"slug" text,
"sem_vencimento" boolean DEFAULT false NOT NULL
);
ALTER TABLE public."empresas" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public."empresas" FROM PUBLIC, anon, authenticated;
CREATE TABLE public."finance_ativos" (
"id" uuid DEFAULT gen_random_uuid() NOT NULL,
"cidade_id" text DEFAULT 'caxias'::text NOT NULL,
"nome" text NOT NULL,
"categoria" text,
"numero_serie" text,
"data_aquisicao" date NOT NULL,
"valor_aquisicao" numeric(14,2) NOT NULL,
"valor_residual" numeric(14,2) DEFAULT 0 NOT NULL,
"vida_util_meses" integer DEFAULT 60 NOT NULL,
"metodo" text DEFAULT 'linear'::text NOT NULL,
"status" text DEFAULT 'ativo'::text NOT NULL,
"conta_id" uuid,
"observacoes" text,
"created_by" uuid DEFAULT auth.uid(),
"updated_by" uuid DEFAULT auth.uid(),
"created_at" timestamp with time zone DEFAULT now() NOT NULL,
"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE public."finance_ativos" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public."finance_ativos" FROM PUBLIC, anon, authenticated;
CREATE TABLE public."finance_categorias" (
"id" uuid DEFAULT gen_random_uuid() NOT NULL,
"cidade_id" text DEFAULT 'caxias'::text NOT NULL,
"nome" text NOT NULL,
"tipo" text NOT NULL,
"grupo_dre" text DEFAULT 'outros'::text NOT NULL,
"parent_id" uuid,
"ordem" integer DEFAULT 100 NOT NULL,
"sistema" boolean DEFAULT false NOT NULL,
"ativa" boolean DEFAULT true NOT NULL,
"created_by" uuid DEFAULT auth.uid(),
"updated_by" uuid DEFAULT auth.uid(),
"created_at" timestamp with time zone DEFAULT now() NOT NULL,
"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE public."finance_categorias" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public."finance_categorias" FROM PUBLIC, anon, authenticated;
CREATE TABLE public."finance_centros_custo" (
"id" uuid DEFAULT gen_random_uuid() NOT NULL,
"cidade_id" text DEFAULT 'caxias'::text NOT NULL,
"codigo" text,
"nome" text NOT NULL,
"descricao" text,
"ativo" boolean DEFAULT true NOT NULL,
"created_by" uuid DEFAULT auth.uid(),
"updated_by" uuid DEFAULT auth.uid(),
"created_at" timestamp with time zone DEFAULT now() NOT NULL,
"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE public."finance_centros_custo" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public."finance_centros_custo" FROM PUBLIC, anon, authenticated;
CREATE TABLE public."finance_contas" (
"id" uuid DEFAULT gen_random_uuid() NOT NULL,
"cidade_id" text DEFAULT 'caxias'::text NOT NULL,
"nome" text NOT NULL,
"tipo" text DEFAULT 'banco'::text NOT NULL,
"banco" text,
"agencia" text,
"conta" text,
"chave_pix" text,
"saldo_inicial" numeric(14,2) DEFAULT 0 NOT NULL,
"data_saldo_inicial" date DEFAULT CURRENT_DATE NOT NULL,
"principal" boolean DEFAULT false NOT NULL,
"ativa" boolean DEFAULT true NOT NULL,
"observacoes" text,
"created_by" uuid DEFAULT auth.uid(),
"updated_by" uuid DEFAULT auth.uid(),
"created_at" timestamp with time zone DEFAULT now() NOT NULL,
"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE public."finance_contas" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public."finance_contas" FROM PUBLIC, anon, authenticated;
CREATE TABLE public."finance_extratos" (
"id" uuid DEFAULT gen_random_uuid() NOT NULL,
"cidade_id" text DEFAULT 'caxias'::text NOT NULL,
"conta_id" uuid NOT NULL,
"data_movimento" date NOT NULL,
"descricao" text NOT NULL,
"documento" text,
"valor" numeric(14,2) NOT NULL,
"saldo_apos" numeric(14,2),
"hash_importacao" text,
"lancamento_id" uuid,
"pagamento_id" uuid,
"conciliado" boolean DEFAULT false NOT NULL,
"observacoes" text,
"imported_by" uuid DEFAULT auth.uid(),
"imported_at" timestamp with time zone DEFAULT now() NOT NULL,
"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE public."finance_extratos" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public."finance_extratos" FROM PUBLIC, anon, authenticated;
CREATE TABLE public."finance_fechamentos" (
"id" uuid DEFAULT gen_random_uuid() NOT NULL,
"cidade_id" text DEFAULT 'caxias'::text NOT NULL,
"ano" integer NOT NULL,
"mes" integer NOT NULL,
"status" text DEFAULT 'aberto'::text NOT NULL,
"fechado_em" timestamp with time zone,
"fechado_por" uuid,
"observacoes" text,
"created_at" timestamp with time zone DEFAULT now() NOT NULL,
"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE public."finance_fechamentos" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public."finance_fechamentos" FROM PUBLIC, anon, authenticated;
CREATE TABLE public."finance_lancamentos" (
"id" uuid DEFAULT gen_random_uuid() NOT NULL,
"cidade_id" text DEFAULT 'caxias'::text NOT NULL,
"tipo" text NOT NULL,
"origem" text DEFAULT 'manual'::text NOT NULL,
"descricao" text NOT NULL,
"categoria_id" uuid,
"centro_custo_id" uuid,
"parceiro_id" uuid,
"empresa_id" uuid,
"conta_id" uuid,
"conta_destino_id" uuid,
"recorrencia_id" uuid,
"documento" text,
"competencia" date DEFAULT CURRENT_DATE NOT NULL,
"vencimento" date DEFAULT CURRENT_DATE NOT NULL,
"pago_em" timestamp with time zone,
"valor" numeric(14,2) NOT NULL,
"status" text DEFAULT 'pendente'::text NOT NULL,
"forma_pagamento" text,
"parcela_num" integer DEFAULT 1 NOT NULL,
"parcelas_total" integer DEFAULT 1 NOT NULL,
"conciliado" boolean DEFAULT false NOT NULL,
"observacoes" text,
"anexo_url" text,
"created_by" uuid DEFAULT auth.uid(),
"updated_by" uuid DEFAULT auth.uid(),
"created_at" timestamp with time zone DEFAULT now() NOT NULL,
"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE public."finance_lancamentos" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public."finance_lancamentos" FROM PUBLIC, anon, authenticated;
CREATE TABLE public."finance_orcamentos" (
"id" uuid DEFAULT gen_random_uuid() NOT NULL,
"cidade_id" text DEFAULT 'caxias'::text NOT NULL,
"ano" integer NOT NULL,
"mes" integer NOT NULL,
"tipo" text NOT NULL,
"categoria_id" uuid,
"centro_custo_id" uuid,
"valor_planejado" numeric(14,2) NOT NULL,
"observacoes" text,
"created_by" uuid DEFAULT auth.uid(),
"updated_by" uuid DEFAULT auth.uid(),
"created_at" timestamp with time zone DEFAULT now() NOT NULL,
"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE public."finance_orcamentos" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public."finance_orcamentos" FROM PUBLIC, anon, authenticated;
CREATE TABLE public."finance_parceiros" (
"id" uuid DEFAULT gen_random_uuid() NOT NULL,
"cidade_id" text DEFAULT 'caxias'::text NOT NULL,
"tipo" text DEFAULT 'fornecedor'::text NOT NULL,
"nome" text NOT NULL,
"documento" text,
"email" text,
"whatsapp" text,
"observacoes" text,
"ativo" boolean DEFAULT true NOT NULL,
"created_by" uuid DEFAULT auth.uid(),
"updated_by" uuid DEFAULT auth.uid(),
"created_at" timestamp with time zone DEFAULT now() NOT NULL,
"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE public."finance_parceiros" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public."finance_parceiros" FROM PUBLIC, anon, authenticated;
CREATE TABLE public."finance_recorrencias" (
"id" uuid DEFAULT gen_random_uuid() NOT NULL,
"cidade_id" text DEFAULT 'caxias'::text NOT NULL,
"tipo" text NOT NULL,
"descricao" text NOT NULL,
"categoria_id" uuid,
"centro_custo_id" uuid,
"parceiro_id" uuid,
"empresa_id" uuid,
"conta_id" uuid,
"valor" numeric(14,2) NOT NULL,
"periodicidade" text DEFAULT 'mensal'::text NOT NULL,
"inicio" date DEFAULT CURRENT_DATE NOT NULL,
"fim" date,
"proxima_geracao" date DEFAULT CURRENT_DATE NOT NULL,
"forma_pagamento" text,
"documento" text,
"observacoes" text,
"ativa" boolean DEFAULT true NOT NULL,
"created_by" uuid DEFAULT auth.uid(),
"updated_by" uuid DEFAULT auth.uid(),
"created_at" timestamp with time zone DEFAULT now() NOT NULL,
"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE public."finance_recorrencias" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public."finance_recorrencias" FROM PUBLIC, anon, authenticated;
CREATE TABLE public."inteligencia_buscas" (
"id" bigint GENERATED BY DEFAULT AS IDENTITY NOT NULL,
"cidade_id" text NOT NULL,
"termo" text NOT NULL,
"termo_normalizado" text NOT NULL,
"resultados" integer,
"created_at" timestamp with time zone DEFAULT now() NOT NULL,
"nicho" text DEFAULT 'Não classificado'::text NOT NULL,
"subnicho" text,
"atendida" boolean,
"fonte_classificacao" text DEFAULT 'não_classificado'::text NOT NULL
);
ALTER TABLE public."inteligencia_buscas" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public."inteligencia_buscas" FROM PUBLIC, anon, authenticated;
CREATE TABLE public."inteligencia_regras_nicho" (
"termo_chave" text NOT NULL,
"nicho" text NOT NULL,
"subnicho" text,
"prioridade" integer DEFAULT 100 NOT NULL,
"ativo" boolean DEFAULT true NOT NULL,
"created_at" timestamp with time zone DEFAULT now() NOT NULL,
"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE public."inteligencia_regras_nicho" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public."inteligencia_regras_nicho" FROM PUBLIC, anon, authenticated;
CREATE TABLE public."internal_maintenance_secrets" (
"name" text NOT NULL,
"token" text NOT NULL,
"created_at" timestamp with time zone DEFAULT now() NOT NULL,
"rotated_at" timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE public."internal_maintenance_secrets" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public."internal_maintenance_secrets" FROM PUBLIC, anon, authenticated;
CREATE TABLE public."metricas_eventos" (
"id" bigint GENERATED BY DEFAULT AS IDENTITY NOT NULL,
"evento" text NOT NULL,
"empresa_id" text,
"pagina" text,
"created_at" timestamp with time zone DEFAULT now() NOT NULL,
"cidade_id" text DEFAULT 'caxias'::text NOT NULL
);
ALTER TABLE public."metricas_eventos" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public."metricas_eventos" FROM PUBLIC, anon, authenticated;
CREATE TABLE public."metricas_promocao_dia" (
"id" bigint GENERATED BY DEFAULT AS IDENTITY NOT NULL,
"cidade_id" text DEFAULT 'caxias'::text NOT NULL,
"evento" text NOT NULL,
"origem" text,
"detalhe" text,
"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE public."metricas_promocao_dia" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public."metricas_promocao_dia" FROM PUBLIC, anon, authenticated;
CREATE TABLE public."metricas_rate_limits" (
"route" text NOT NULL,
"fingerprint" text NOT NULL,
"source" text DEFAULT 'unknown'::text NOT NULL,
"bucket_seconds" integer NOT NULL,
"bucket_start" timestamp with time zone NOT NULL,
"hits" integer DEFAULT 0 NOT NULL,
"created_at" timestamp with time zone DEFAULT now() NOT NULL,
"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE public."metricas_rate_limits" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public."metricas_rate_limits" FROM PUBLIC, anon, authenticated;
CREATE TABLE public."metricas_vagas" (
"id" bigint GENERATED BY DEFAULT AS IDENTITY NOT NULL,
"cidade_id" text DEFAULT 'caxias'::text NOT NULL,
"vaga_id" uuid NOT NULL,
"empresa_nome_snapshot" text,
"cargo_snapshot" text,
"posicao_lista" integer NOT NULL,
"idade_dias" integer DEFAULT 0 NOT NULL,
"sessao_hash" text NOT NULL,
"dia" date DEFAULT ((now() AT TIME ZONE 'America/Sao_Paulo'::text))::date NOT NULL,
"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE public."metricas_vagas" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public."metricas_vagas" FROM PUBLIC, anon, authenticated;
CREATE TABLE public."pagamentos" (
"id" uuid DEFAULT gen_random_uuid() NOT NULL,
"empresa_id" uuid NOT NULL,
"tipo" text DEFAULT 'renovacao'::text NOT NULL,
"plano" text NOT NULL,
"valor" numeric(10,2) NOT NULL,
"moeda" text DEFAULT 'BRL'::text NOT NULL,
"status" text DEFAULT 'criado'::text NOT NULL,
"external_reference" text NOT NULL,
"mercado_pago_preference_id" text,
"mercado_pago_payment_id" text,
"checkout_url" text,
"pago_em" timestamp with time zone,
"processado_em" timestamp with time zone,
"erro_detalhe" text,
"dados_retorno" jsonb DEFAULT '{}'::jsonb NOT NULL,
"created_at" timestamp with time zone DEFAULT now() NOT NULL,
"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
"cidade_id" text DEFAULT 'caxias'::text NOT NULL,
"produto_codigo" text,
"quantidade" integer DEFAULT 1 NOT NULL,
"promocao_id" uuid,
"aceite_contrato_id" uuid,
"forma_pagamento" text DEFAULT 'checkout_pro'::text,
"email_pagador" text,
"expira_em" timestamp with time zone,
"valor_liquido" numeric(12,2),
"taxa_mercado_pago" numeric(12,2),
"conciliado_mercado_pago_em" timestamp with time zone,
"agenda_premium_id" uuid
);
ALTER TABLE public."pagamentos" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public."pagamentos" FROM PUBLIC, anon, authenticated;
CREATE TABLE public."produtos_comerciais" (
"cidade_id" text NOT NULL,
"codigo" text NOT NULL,
"tipo" text NOT NULL,
"nome" text NOT NULL,
"descricao" text,
"valor" numeric(10,2) NOT NULL,
"duracao_dias" integer NOT NULL,
"bonus_master" integer DEFAULT 0 NOT NULL,
"bonus_destaque" integer DEFAULT 0 NOT NULL,
"ativo" boolean DEFAULT true NOT NULL,
"ordem" smallint DEFAULT 100 NOT NULL,
"created_at" timestamp with time zone DEFAULT now() NOT NULL,
"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE public."produtos_comerciais" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public."produtos_comerciais" FROM PUBLIC, anon, authenticated;
CREATE TABLE public."promocoes" (
"id" uuid DEFAULT gen_random_uuid() NOT NULL,
"empresa_id" uuid NOT NULL,
"titulo" text NOT NULL,
"descricao" text,
"imagem_url" text NOT NULL,
"status" text DEFAULT 'pendente'::text NOT NULL,
"duracao_dias" integer DEFAULT 1 NOT NULL,
"publicada_em" timestamp with time zone,
"expira_em" timestamp with time zone,
"motivo_status" text,
"moderado_por" uuid,
"moderado_em" timestamp with time zone,
"created_at" timestamp with time zone DEFAULT now() NOT NULL,
"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
"cidade_id" text DEFAULT 'caxias'::text NOT NULL,
"codigo_checkout" text DEFAULT (gen_random_uuid())::text NOT NULL,
"pagamento_confirmado" boolean DEFAULT false NOT NULL,
"pagamento_id" uuid,
"pago_em" timestamp with time zone,
"data_exibicao" date,
"reserva_expira_em" timestamp with time zone,
"imagem_storage_path" text,
"whatsapp_contato" text,
"beneficio_foguinho" boolean DEFAULT false NOT NULL
);
ALTER TABLE public."promocoes" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public."promocoes" FROM PUBLIC, anon, authenticated;
CREATE TABLE public."public_edge_rate_limits" (
"id" bigint GENERATED BY DEFAULT AS IDENTITY NOT NULL,
"route" text NOT NULL,
"ip_hash" text NOT NULL,
"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE public."public_edge_rate_limits" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public."public_edge_rate_limits" FROM PUBLIC, anon, authenticated;
CREATE TABLE public."solicitacoes_alteracao_empresa" (
"id" uuid DEFAULT gen_random_uuid() NOT NULL,
"empresa_id" uuid NOT NULL,
"cidade_id" text DEFAULT 'caxias'::text NOT NULL,
"status" text DEFAULT 'pendente'::text NOT NULL,
"dados" jsonb DEFAULT '{}'::jsonb NOT NULL,
"imagem_url_nova" text,
"logo_url_nova" text,
"criado_em" timestamp with time zone DEFAULT now() NOT NULL,
"revisado_em" timestamp with time zone,
"revisado_por" uuid,
"motivo_recusa" text
);
ALTER TABLE public."solicitacoes_alteracao_empresa" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public."solicitacoes_alteracao_empresa" FROM PUBLIC, anon, authenticated;
CREATE TABLE public."vagas" (
"id" uuid DEFAULT gen_random_uuid() NOT NULL,
"empresa_id" uuid,
"empresa_nome" text NOT NULL,
"cargo" text NOT NULL,
"salario" text,
"local" text NOT NULL,
"horario" text,
"contrato" text NOT NULL,
"descricao" text NOT NULL,
"requisitos" text NOT NULL,
"whatsapp" text NOT NULL,
"email" text,
"duracao_dias" integer NOT NULL,
"status" text DEFAULT 'pendente'::text NOT NULL,
"publicada_em" timestamp with time zone,
"expira_em" timestamp with time zone,
"motivo_status" text,
"moderado_por" uuid,
"moderado_em" timestamp with time zone,
"termos_aceitos_em" timestamp with time zone DEFAULT now() NOT NULL,
"origem" text DEFAULT 'formulario_publico'::text NOT NULL,
"created_at" timestamp with time zone DEFAULT now() NOT NULL,
"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
"imagem_url" text,
"cidade_id" text DEFAULT 'caxias'::text NOT NULL,
"acessos" integer DEFAULT 0 NOT NULL
);
ALTER TABLE public."vagas" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public."vagas" FROM PUBLIC, anon, authenticated;
ALTER TABLE public."metricas_eventos" ADD CONSTRAINT "metricas_eventos_pkey" PRIMARY KEY (id);
ALTER TABLE public."administradores" ADD CONSTRAINT "administradores_nome_check" CHECK (((char_length(TRIM(BOTH FROM nome)) >= 2) AND (char_length(TRIM(BOTH FROM nome)) <= 100)));
ALTER TABLE public."administradores" ADD CONSTRAINT "administradores_pkey" PRIMARY KEY (user_id);
ALTER TABLE public."empresas" ADD CONSTRAINT "empresas_nome_check" CHECK (((char_length(TRIM(BOTH FROM nome)) >= 3) AND (char_length(TRIM(BOTH FROM nome)) <= 100)));
ALTER TABLE public."empresas" ADD CONSTRAINT "empresas_email_check" CHECK (((email IS NULL) OR (email ~* '^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$'::text)));
ALTER TABLE public."empresas" ADD CONSTRAINT "empresas_categoria_check" CHECK (((char_length(TRIM(BOTH FROM categoria)) >= 2) AND (char_length(TRIM(BOTH FROM categoria)) <= 60)));
ALTER TABLE public."empresas" ADD CONSTRAINT "empresas_subcategoria_check" CHECK (((char_length(TRIM(BOTH FROM subcategoria)) >= 2) AND (char_length(TRIM(BOTH FROM subcategoria)) <= 100)));
ALTER TABLE public."empresas" ADD CONSTRAINT "empresas_descricao_check" CHECK (((char_length(TRIM(BOTH FROM descricao)) >= 10) AND (char_length(TRIM(BOTH FROM descricao)) <= 600)));
ALTER TABLE public."empresas" ADD CONSTRAINT "empresas_whatsapp_check" CHECK ((whatsapp ~ '^[0-9]{10,15}$'::text));
ALTER TABLE public."empresas" ADD CONSTRAINT "empresas_instagram_check" CHECK (((instagram IS NULL) OR (char_length(TRIM(BOTH FROM instagram)) <= 200)));
ALTER TABLE public."empresas" ADD CONSTRAINT "empresas_site_check" CHECK (((site IS NULL) OR (char_length(TRIM(BOTH FROM site)) <= 500)));
ALTER TABLE public."empresas" ADD CONSTRAINT "empresas_cidade_check" CHECK (((char_length(TRIM(BOTH FROM cidade)) >= 2) AND (char_length(TRIM(BOTH FROM cidade)) <= 100)));
ALTER TABLE public."empresas" ADD CONSTRAINT "empresas_mapa_url_check" CHECK (((mapa_url IS NULL) OR (char_length(TRIM(BOTH FROM mapa_url)) <= 1000)));
ALTER TABLE public."empresas" ADD CONSTRAINT "empresas_motivo_status_check" CHECK (((motivo_status IS NULL) OR (char_length(TRIM(BOTH FROM motivo_status)) <= 1000)));
ALTER TABLE public."agenda_premium" ADD CONSTRAINT "agenda_premium_datas_check" CHECK ((data_fim >= data_inicio));
ALTER TABLE public."agenda_premium" ADD CONSTRAINT "agenda_premium_slot_check" CHECK ((((tipo = 'master'::text) AND ((slot >= 1) AND (slot <= 4))) OR ((tipo = 'destaque'::text) AND ((slot >= 1) AND (slot <= 3)))));
ALTER TABLE public."agenda_premium" ADD CONSTRAINT "agenda_premium_pkey" PRIMARY KEY (id);
ALTER TABLE public."metricas_vagas" ADD CONSTRAINT "metricas_vagas_idade_dias_check" CHECK ((idade_dias >= 0));
ALTER TABLE public."metricas_vagas" ADD CONSTRAINT "metricas_vagas_pkey" PRIMARY KEY (id);
ALTER TABLE public."finance_ativos" ADD CONSTRAINT "finance_ativos_vida_util_meses_check" CHECK ((vida_util_meses > 0));
ALTER TABLE public."finance_ativos" ADD CONSTRAINT "finance_ativos_metodo_check" CHECK ((metodo = 'linear'::text));
ALTER TABLE public."empresas" ADD CONSTRAINT "empresas_check" CHECK (((data_vencimento IS NULL) OR (data_inicio IS NULL) OR (data_vencimento > data_inicio)));
ALTER TABLE public."empresas" ADD CONSTRAINT "empresas_pkey" PRIMARY KEY (id);
ALTER TABLE public."vagas" ADD CONSTRAINT "vagas_empresa_nome_check" CHECK (((char_length(TRIM(BOTH FROM empresa_nome)) >= 2) AND (char_length(TRIM(BOTH FROM empresa_nome)) <= 100)));
ALTER TABLE public."vagas" ADD CONSTRAINT "vagas_cargo_check" CHECK (((char_length(TRIM(BOTH FROM cargo)) >= 2) AND (char_length(TRIM(BOTH FROM cargo)) <= 100)));
ALTER TABLE public."vagas" ADD CONSTRAINT "vagas_local_check" CHECK (((char_length(TRIM(BOTH FROM local)) >= 2) AND (char_length(TRIM(BOTH FROM local)) <= 150)));
ALTER TABLE public."configuracoes_comerciais" ADD CONSTRAINT "configuracoes_comerciais_preco_comum_check" CHECK ((preco_comum >= (0)::numeric));
ALTER TABLE public."vagas" ADD CONSTRAINT "vagas_contrato_check" CHECK ((contrato = ANY (ARRAY['CLT'::text, 'Temporário'::text, 'Estágio'::text, 'Jovem Aprendiz'::text, 'Freelancer'::text, 'Autônomo'::text, 'PJ'::text, 'Outro'::text])));
ALTER TABLE public."vagas" ADD CONSTRAINT "vagas_descricao_check" CHECK (((char_length(TRIM(BOTH FROM descricao)) >= 10) AND (char_length(TRIM(BOTH FROM descricao)) <= 1200)));
ALTER TABLE public."vagas" ADD CONSTRAINT "vagas_requisitos_check" CHECK (((char_length(TRIM(BOTH FROM requisitos)) >= 2) AND (char_length(TRIM(BOTH FROM requisitos)) <= 1000)));
ALTER TABLE public."vagas" ADD CONSTRAINT "vagas_whatsapp_check" CHECK ((whatsapp ~ '^[0-9]{10,15}$'::text));
ALTER TABLE public."vagas" ADD CONSTRAINT "vagas_email_check" CHECK (((email IS NULL) OR (email ~* '^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$'::text)));
ALTER TABLE public."vagas" ADD CONSTRAINT "vagas_duracao_dias_check" CHECK ((duracao_dias = ANY (ARRAY[1, 3, 5])));
ALTER TABLE public."backup_migracao_midias_empresas" ADD CONSTRAINT "backup_migracao_midias_empresas_lote_empresa_id_key" UNIQUE (lote, empresa_id);
ALTER TABLE public."vagas" ADD CONSTRAINT "vagas_status_check" CHECK ((status = ANY (ARRAY['pendente'::text, 'ativa'::text, 'rejeitada'::text, 'encerrada'::text, 'vencida'::text])));
ALTER TABLE public."vagas" ADD CONSTRAINT "vagas_motivo_status_check" CHECK (((motivo_status IS NULL) OR (char_length(TRIM(BOTH FROM motivo_status)) <= 1000)));
ALTER TABLE public."vagas" ADD CONSTRAINT "vagas_check" CHECK (((expira_em IS NULL) OR (publicada_em IS NULL) OR (expira_em > publicada_em)));
ALTER TABLE public."vagas" ADD CONSTRAINT "vagas_pkey" PRIMARY KEY (id);
ALTER TABLE public."promocoes" ADD CONSTRAINT "promocoes_titulo_check" CHECK (((char_length(TRIM(BOTH FROM titulo)) >= 3) AND (char_length(TRIM(BOTH FROM titulo)) <= 120)));
ALTER TABLE public."promocoes" ADD CONSTRAINT "promocoes_descricao_check" CHECK (((descricao IS NULL) OR (char_length(TRIM(BOTH FROM descricao)) <= 600)));
ALTER TABLE public."configuracoes_comerciais" ADD CONSTRAINT "configuracoes_comerciais_preco_destaque_check" CHECK ((preco_destaque >= (0)::numeric));
ALTER TABLE public."cardapio_entrega_config" ADD CONSTRAINT "cardapio_entrega_config_pkey" PRIMARY KEY (cardapio_empresa_id);
ALTER TABLE public."promocoes" ADD CONSTRAINT "promocoes_motivo_status_check" CHECK (((motivo_status IS NULL) OR (char_length(TRIM(BOTH FROM motivo_status)) <= 1000)));
ALTER TABLE public."promocoes" ADD CONSTRAINT "promocoes_check" CHECK (((expira_em IS NULL) OR (publicada_em IS NULL) OR (expira_em > publicada_em)));
ALTER TABLE public."promocoes" ADD CONSTRAINT "promocoes_pkey" PRIMARY KEY (id);
ALTER TABLE public."promocoes" ADD CONSTRAINT "promocoes_duracao_dias_check" CHECK (((duracao_dias >= 1) AND (duracao_dias <= 7)));
ALTER TABLE public."configuracoes_comerciais" ADD CONSTRAINT "configuracoes_comerciais_id_check" CHECK ((id = 1));
ALTER TABLE public."configuracoes_comerciais" ADD CONSTRAINT "configuracoes_comerciais_primeiros_dias_gratis_check" CHECK (((primeiros_dias_gratis >= 0) AND (primeiros_dias_gratis <= 365)));
ALTER TABLE public."cardapio_creditos_config" ADD CONSTRAINT "cardapio_creditos_config_pkey" PRIMARY KEY (chave);
ALTER TABLE public."configuracoes_comerciais" ADD CONSTRAINT "configuracoes_comerciais_preco_master_check" CHECK ((preco_master >= (0)::numeric));
ALTER TABLE public."configuracoes_comerciais" ADD CONSTRAINT "configuracoes_comerciais_moeda_check" CHECK ((moeda = 'BRL'::text));
ALTER TABLE public."configuracoes_comerciais" ADD CONSTRAINT "configuracoes_comerciais_pkey" PRIMARY KEY (id);
ALTER TABLE public."pagamentos" ADD CONSTRAINT "pagamentos_valor_check" CHECK ((valor >= (0)::numeric));
ALTER TABLE public."pagamentos" ADD CONSTRAINT "pagamentos_moeda_check" CHECK ((moeda = 'BRL'::text));
ALTER TABLE public."pagamentos" ADD CONSTRAINT "pagamentos_status_check" CHECK ((status = ANY (ARRAY['criado'::text, 'pendente'::text, 'aprovado'::text, 'rejeitado'::text, 'cancelado'::text, 'expirado'::text, 'reembolsado'::text, 'erro'::text])));
ALTER TABLE public."pagamentos" ADD CONSTRAINT "pagamentos_pkey" PRIMARY KEY (id);
ALTER TABLE public."pagamentos" ADD CONSTRAINT "pagamentos_external_reference_key" UNIQUE (external_reference);
ALTER TABLE public."pagamentos" ADD CONSTRAINT "pagamentos_mercado_pago_payment_id_key" UNIQUE (mercado_pago_payment_id);
ALTER TABLE public."metricas_eventos" ADD CONSTRAINT "metricas_eventos_pagina_len" CHECK (((pagina IS NULL) OR (char_length(pagina) <= 120)));
ALTER TABLE public."empresas" ADD CONSTRAINT "empresas_plano_check" CHECK ((plano = ANY (ARRAY['comum'::text, 'destaque'::text, 'master'::text])));
ALTER TABLE public."empresas" ADD CONSTRAINT "empresas_plano_solicitado_check" CHECK ((plano_solicitado = ANY (ARRAY['comum'::text, 'destaque'::text, 'master'::text])));
ALTER TABLE public."vagas" ADD CONSTRAINT "vagas_imagem_url_tamanho_check" CHECK (((imagem_url IS NULL) OR (length(imagem_url) <= 1800000)));
ALTER TABLE public."metricas_eventos" ADD CONSTRAINT "metricas_eventos_evento_check" CHECK ((evento = ANY (ARRAY['visita_site'::text, 'busca'::text, 'abriu_empresa'::text, 'clicou_whatsapp'::text, 'abriu_vagas'::text])));
ALTER TABLE public."metricas_eventos" ADD CONSTRAINT "metricas_eventos_empresa_id_len" CHECK (((empresa_id IS NULL) OR (char_length(empresa_id) <= 100)));
ALTER TABLE public."administradores" ADD CONSTRAINT "administradores_papel_check" CHECK ((papel = ANY (ARRAY['dono'::text, 'operador'::text])));
ALTER TABLE public."curtidas_empresas" ADD CONSTRAINT "curtidas_empresas_empresa_id_len" CHECK (((char_length(empresa_id) >= 1) AND (char_length(empresa_id) <= 100)));
ALTER TABLE public."curtidas_empresas" ADD CONSTRAINT "curtidas_empresas_token_check" CHECK ((((char_length(visitante_token) >= 20) AND (char_length(visitante_token) <= 100)) AND (visitante_token ~ '^[A-Za-z0-9_-]+$'::text)));
ALTER TABLE public."curtidas_empresas" ADD CONSTRAINT "curtidas_empresas_pkey" PRIMARY KEY (id);
ALTER TABLE public."curtidas_empresas" ADD CONSTRAINT "curtidas_empresas_unica" UNIQUE (empresa_id, visitante_token);
ALTER TABLE public."banners_site" ADD CONSTRAINT "banners_site_nome_check" CHECK (((char_length(btrim(nome)) >= 3) AND (char_length(btrim(nome)) <= 100)));
ALTER TABLE public."banners_site" ADD CONSTRAINT "banners_site_tipo_check" CHECK ((tipo = ANY (ARRAY['padrao'::text, 'temporario'::text])));
ALTER TABLE public."banners_site" ADD CONSTRAINT "banners_site_periodo_check" CHECK ((((tipo = 'padrao'::text) AND (inicio_em IS NULL) AND (fim_em IS NULL)) OR ((tipo = 'temporario'::text) AND (inicio_em IS NOT NULL) AND (fim_em IS NOT NULL) AND (fim_em > inicio_em))));
ALTER TABLE public."banners_site" ADD CONSTRAINT "banners_site_pkey" PRIMARY KEY (id);
ALTER TABLE public."cidades" ADD CONSTRAINT "cidades_id_check" CHECK ((id ~ '^[a-z0-9_-]{2,30}$'::text));
ALTER TABLE public."admin_sessoes" ADD CONSTRAINT "admin_sessoes_pkey" PRIMARY KEY (id);
ALTER TABLE public."admin_atividades" ADD CONSTRAINT "admin_atividades_pkey" PRIMARY KEY (id);
ALTER TABLE public."cidades" ADD CONSTRAINT "cidades_nome_check" CHECK (((char_length(btrim(nome_sistema)) >= 3) AND (char_length(btrim(nome_sistema)) <= 80)));
ALTER TABLE public."cidades" ADD CONSTRAINT "cidades_cidade_check" CHECK (((char_length(btrim(cidade)) >= 2) AND (char_length(btrim(cidade)) <= 80)));
ALTER TABLE public."cidades" ADD CONSTRAINT "cidades_uf_check" CHECK ((char_length(btrim(uf)) = 2));
ALTER TABLE public."cidades" ADD CONSTRAINT "cidades_pkey" PRIMARY KEY (id);
ALTER TABLE public."crm_leads" ADD CONSTRAINT "crm_leads_pkey" PRIMARY KEY (id);
ALTER TABLE public."metricas_vagas" ADD CONSTRAINT "metricas_vagas_posicao_lista_check" CHECK (((posicao_lista >= 1) AND (posicao_lista <= 500)));
ALTER TABLE public."empresas" ADD CONSTRAINT "empresas_assinatura_periodo_check" CHECK ((assinatura_periodo = ANY (ARRAY['mensal'::text, 'trimestral'::text, 'anual'::text])));
ALTER TABLE public."crm_alertas_vencimento" ADD CONSTRAINT "crm_alertas_vencimento_pkey" PRIMARY KEY (id);
ALTER TABLE public."crm_alertas_vencimento" ADD CONSTRAINT "crm_alertas_vencimento_empresa_id_user_id_vencimento_key" UNIQUE (empresa_id, user_id, vencimento);
ALTER TABLE public."pagamentos" ADD CONSTRAINT "pagamentos_plano_check" CHECK ((plano = ANY (ARRAY['comum'::text, 'destaque'::text, 'master'::text, 'mensal'::text, 'trimestral'::text, 'anual'::text])));
ALTER TABLE public."agenda_premium" ADD CONSTRAINT "agenda_premium_tipo_check" CHECK ((tipo = ANY (ARRAY['master'::text, 'destaque'::text])));
ALTER TABLE public."agenda_premium" ADD CONSTRAINT "agenda_premium_origem_check" CHECK ((origem = ANY (ARRAY['venda_extra'::text, 'bonus_plano'::text, 'cortesia'::text, 'ajuste_manual'::text])));
ALTER TABLE public."produtos_comerciais" ADD CONSTRAINT "produtos_comerciais_tipo_check" CHECK ((tipo = ANY (ARRAY['assinatura'::text, 'premium_extra'::text, 'promocao_dia'::text])));
ALTER TABLE public."produtos_comerciais" ADD CONSTRAINT "produtos_comerciais_valor_check" CHECK ((valor >= (0)::numeric));
ALTER TABLE public."produtos_comerciais" ADD CONSTRAINT "produtos_comerciais_duracao_dias_check" CHECK (((duracao_dias >= 1) AND (duracao_dias <= 730)));
ALTER TABLE public."produtos_comerciais" ADD CONSTRAINT "produtos_comerciais_bonus_master_check" CHECK ((bonus_master >= 0));
ALTER TABLE public."produtos_comerciais" ADD CONSTRAINT "produtos_comerciais_bonus_destaque_check" CHECK ((bonus_destaque >= 0));
ALTER TABLE public."produtos_comerciais" ADD CONSTRAINT "produtos_comerciais_codigo_check" CHECK ((codigo ~ '^[a-z0-9_]{3,50}$'::text));
ALTER TABLE public."produtos_comerciais" ADD CONSTRAINT "produtos_comerciais_pkey" PRIMARY KEY (cidade_id, codigo);
ALTER TABLE public."pagamentos" ADD CONSTRAINT "pagamentos_quantidade_check" CHECK (((quantidade >= 1) AND (quantidade <= 365)));
ALTER TABLE public."backup_migracao_midias_empresas" ADD CONSTRAINT "backup_migracao_midias_empresas_pkey" PRIMARY KEY (id);
ALTER TABLE public."backup_migracao_midias_vagas" ADD CONSTRAINT "backup_migracao_midias_vagas_pkey" PRIMARY KEY (id);
ALTER TABLE public."inteligencia_buscas" ADD CONSTRAINT "inteligencia_buscas_resultados_check" CHECK (((resultados IS NULL) OR (resultados >= 0)));
ALTER TABLE public."inteligencia_buscas" ADD CONSTRAINT "inteligencia_buscas_pkey" PRIMARY KEY (id);
ALTER TABLE public."contrato_versoes" ADD CONSTRAINT "contrato_versoes_sha256_check" CHECK ((sha256 ~ '^[0-9a-f]{64}$'::text));
ALTER TABLE public."contrato_versoes" ADD CONSTRAINT "contrato_versoes_pkey" PRIMARY KEY (id);
ALTER TABLE public."aceites_contrato" ADD CONSTRAINT "aceites_contrato_quantidade_check" CHECK ((quantidade > 0));
ALTER TABLE public."aceites_contrato" ADD CONSTRAINT "aceites_contrato_valor_check" CHECK ((valor >= (0)::numeric));
ALTER TABLE public."aceites_contrato" ADD CONSTRAINT "aceites_contrato_documento_tipo_check" CHECK ((documento_tipo = ANY (ARRAY['cpf'::text, 'cnpj'::text])));
ALTER TABLE public."finance_orcamentos" ADD CONSTRAINT "finance_orcamentos_valor_planejado_check" CHECK ((valor_planejado >= (0)::numeric));
ALTER TABLE public."finance_orcamentos" ADD CONSTRAINT "finance_orcamentos_pkey" PRIMARY KEY (id);
ALTER TABLE public."finance_extratos" ADD CONSTRAINT "finance_extratos_valor_check" CHECK ((valor <> (0)::numeric));
ALTER TABLE public."aceites_contrato" ADD CONSTRAINT "aceites_contrato_capacidade_check" CHECK ((capacidade = ANY (ARRAY['titular_responsavel'::text, 'autorizado'::text])));
ALTER TABLE public."aceites_contrato" ADD CONSTRAINT "aceites_contrato_pkey" PRIMARY KEY (id);
ALTER TABLE public."metricas_promocao_dia" ADD CONSTRAINT "metricas_promocao_dia_pkey" PRIMARY KEY (id);
ALTER TABLE public."aceites_promocao_dia" ADD CONSTRAINT "aceites_promocao_dia_pkey" PRIMARY KEY (id);
ALTER TABLE public."aceites_promocao_dia" ADD CONSTRAINT "aceites_promocao_dia_promocao_id_key" UNIQUE (promocao_id);
ALTER TABLE public."metricas_promocao_dia" ADD CONSTRAINT "metricas_promocao_dia_evento_check" CHECK ((evento = ANY (ARRAY['impressao'::text, 'abertura'::text, 'interesse'::text, 'lead_enviado'::text, 'clicou_promocao'::text, 'iniciou_compra'::text, 'checkout_criado'::text])));
ALTER TABLE public."promocoes" ADD CONSTRAINT "promocoes_whatsapp_contato_check" CHECK (((whatsapp_contato IS NULL) OR (whatsapp_contato ~ '^[0-9]{10,11}$'::text)));
ALTER TABLE public."aceites_promocao_dia" ADD CONSTRAINT "aceites_promocao_dia_whatsapp_contato_check" CHECK (((whatsapp_contato IS NULL) OR (whatsapp_contato ~ '^[0-9]{10,11}$'::text)));
ALTER TABLE public."crm_tarefas" ADD CONSTRAINT "crm_tarefas_prioridade_check" CHECK ((prioridade = ANY (ARRAY['baixa'::text, 'media'::text, 'alta'::text, 'urgente'::text])));
ALTER TABLE public."promocoes" ADD CONSTRAINT "promocoes_status_check" CHECK ((status = ANY (ARRAY['pendente'::text, 'ativa'::text, 'rejeitada'::text, 'encerrada'::text, 'vencida'::text, 'cancelada'::text])));
ALTER TABLE public."pagamentos" ADD CONSTRAINT "pagamentos_email_pagador_check" CHECK (((email_pagador IS NULL) OR (email_pagador ~* '^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$'::text)));
ALTER TABLE public."crm_leads" ADD CONSTRAINT "crm_leads_probabilidade_check" CHECK (((probabilidade >= 0) AND (probabilidade <= 100)));
ALTER TABLE public."crm_leads" ADD CONSTRAINT "crm_leads_prioridade_check" CHECK ((prioridade = ANY (ARRAY['baixa'::text, 'media'::text, 'alta'::text, 'urgente'::text])));
ALTER TABLE public."crm_tarefas" ADD CONSTRAINT "crm_tarefas_status_check" CHECK ((status = ANY (ARRAY['pendente'::text, 'concluida'::text, 'cancelada'::text])));
ALTER TABLE public."finance_orcamentos" ADD CONSTRAINT "finance_orcamentos_ano_check" CHECK (((ano >= 2020) AND (ano <= 2100)));
ALTER TABLE public."crm_tarefas" ADD CONSTRAINT "crm_tarefas_tipo_check" CHECK ((tipo = ANY (ARRAY['follow_up'::text, 'ligacao'::text, 'whatsapp'::text, 'email'::text, 'reuniao'::text, 'proposta'::text, 'renovacao'::text, 'outro'::text])));
ALTER TABLE public."crm_tarefas" ADD CONSTRAINT "crm_tarefas_pkey" PRIMARY KEY (id);
ALTER TABLE public."crm_atividades" ADD CONSTRAINT "crm_atividades_tipo_check" CHECK ((tipo = ANY (ARRAY['nota'::text, 'ligacao'::text, 'whatsapp'::text, 'email'::text, 'reuniao'::text, 'proposta'::text, 'mudanca_etapa'::text, 'tarefa'::text, 'sistema'::text])));
ALTER TABLE public."crm_atividades" ADD CONSTRAINT "crm_atividades_pkey" PRIMARY KEY (id);
ALTER TABLE public."internal_maintenance_secrets" ADD CONSTRAINT "internal_maintenance_secrets_pkey" PRIMARY KEY (name);
ALTER TABLE public."public_edge_rate_limits" ADD CONSTRAINT "public_edge_rate_limits_pkey" PRIMARY KEY (id);
ALTER TABLE public."cortesias_empresas" ADD CONSTRAINT "cortesias_empresas_dias_check" CHECK (((dias >= 1) AND (dias <= 365)));
ALTER TABLE public."cortesias_empresas" ADD CONSTRAINT "cortesias_empresas_motivo_check" CHECK (((char_length(btrim(motivo)) >= 3) AND (char_length(btrim(motivo)) <= 300)));
ALTER TABLE public."cortesias_empresas" ADD CONSTRAINT "cortesias_empresas_pkey" PRIMARY KEY (id);
ALTER TABLE public."pagamentos" ADD CONSTRAINT "pagamentos_tipo_check" CHECK ((tipo = ANY (ARRAY['renovacao'::text, 'premium_extra'::text, 'promocao_dia'::text, 'cadastro'::text])));
ALTER TABLE public."finance_contas" ADD CONSTRAINT "finance_contas_tipo_check" CHECK ((tipo = ANY (ARRAY['banco'::text, 'caixa'::text, 'carteira'::text, 'mercado_pago'::text, 'cartao'::text, 'outro'::text])));
ALTER TABLE public."finance_contas" ADD CONSTRAINT "finance_contas_nome_check" CHECK (((char_length(TRIM(BOTH FROM nome)) >= 2) AND (char_length(TRIM(BOTH FROM nome)) <= 120)));
ALTER TABLE public."finance_contas" ADD CONSTRAINT "finance_contas_pkey" PRIMARY KEY (id);
ALTER TABLE public."finance_categorias" ADD CONSTRAINT "finance_categorias_tipo_check" CHECK ((tipo = ANY (ARRAY['receita'::text, 'despesa'::text, 'ambos'::text])));
ALTER TABLE public."finance_categorias" ADD CONSTRAINT "finance_categorias_grupo_dre_check" CHECK ((grupo_dre = ANY (ARRAY['receita_operacional'::text, 'receita_nao_operacional'::text, 'custo_variavel'::text, 'despesa_operacional'::text, 'despesa_financeira'::text, 'impostos'::text, 'investimento'::text, 'outros'::text])));
ALTER TABLE public."finance_categorias" ADD CONSTRAINT "finance_categorias_nome_check" CHECK (((char_length(TRIM(BOTH FROM nome)) >= 2) AND (char_length(TRIM(BOTH FROM nome)) <= 120)));
ALTER TABLE public."finance_categorias" ADD CONSTRAINT "finance_categorias_pkey" PRIMARY KEY (id);
ALTER TABLE public."finance_orcamentos" ADD CONSTRAINT "finance_orcamentos_tipo_check" CHECK ((tipo = ANY (ARRAY['receita'::text, 'despesa'::text])));
ALTER TABLE public."finance_centros_custo" ADD CONSTRAINT "finance_centros_nome_check" CHECK (((char_length(TRIM(BOTH FROM nome)) >= 2) AND (char_length(TRIM(BOTH FROM nome)) <= 120)));
ALTER TABLE public."finance_centros_custo" ADD CONSTRAINT "finance_centros_custo_pkey" PRIMARY KEY (id);
ALTER TABLE public."finance_parceiros" ADD CONSTRAINT "finance_parceiros_tipo_check" CHECK ((tipo = ANY (ARRAY['fornecedor'::text, 'cliente'::text, 'ambos'::text])));
ALTER TABLE public."finance_parceiros" ADD CONSTRAINT "finance_parceiros_nome_check" CHECK (((char_length(TRIM(BOTH FROM nome)) >= 2) AND (char_length(TRIM(BOTH FROM nome)) <= 160)));
ALTER TABLE public."finance_parceiros" ADD CONSTRAINT "finance_parceiros_pkey" PRIMARY KEY (id);
ALTER TABLE public."finance_recorrencias" ADD CONSTRAINT "finance_recorrencias_tipo_check" CHECK ((tipo = ANY (ARRAY['receita'::text, 'despesa'::text])));
ALTER TABLE public."finance_recorrencias" ADD CONSTRAINT "finance_recorrencias_valor_check" CHECK ((valor > (0)::numeric));
ALTER TABLE public."finance_recorrencias" ADD CONSTRAINT "finance_recorrencias_periodicidade_check" CHECK ((periodicidade = ANY (ARRAY['semanal'::text, 'mensal'::text, 'trimestral'::text, 'semestral'::text, 'anual'::text])));
ALTER TABLE public."finance_recorrencias" ADD CONSTRAINT "finance_recorrencias_descricao_check" CHECK (((char_length(TRIM(BOTH FROM descricao)) >= 2) AND (char_length(TRIM(BOTH FROM descricao)) <= 240)));
ALTER TABLE public."finance_recorrencias" ADD CONSTRAINT "finance_recorrencias_datas_check" CHECK (((fim IS NULL) OR (fim >= inicio)));
ALTER TABLE public."finance_recorrencias" ADD CONSTRAINT "finance_recorrencias_pkey" PRIMARY KEY (id);
ALTER TABLE public."finance_lancamentos" ADD CONSTRAINT "finance_lancamentos_tipo_check" CHECK ((tipo = ANY (ARRAY['receita'::text, 'despesa'::text, 'transferencia'::text])));
ALTER TABLE public."finance_lancamentos" ADD CONSTRAINT "finance_lancamentos_origem_check" CHECK ((origem = ANY (ARRAY['manual'::text, 'recorrencia'::text, 'importacao'::text, 'ajuste'::text, 'outro'::text])));
ALTER TABLE public."finance_lancamentos" ADD CONSTRAINT "finance_lancamentos_valor_check" CHECK ((valor > (0)::numeric));
ALTER TABLE public."finance_orcamentos" ADD CONSTRAINT "finance_orcamentos_mes_check" CHECK (((mes >= 1) AND (mes <= 12)));
ALTER TABLE public."finance_lancamentos" ADD CONSTRAINT "finance_lancamentos_status_check" CHECK ((status = ANY (ARRAY['previsto'::text, 'pendente'::text, 'pago'::text, 'cancelado'::text])));
ALTER TABLE public."finance_lancamentos" ADD CONSTRAINT "finance_lancamentos_parcela_num_check" CHECK ((parcela_num >= 1));
ALTER TABLE public."finance_lancamentos" ADD CONSTRAINT "finance_lancamentos_check" CHECK (((parcelas_total >= 1) AND (parcelas_total >= parcela_num)));
ALTER TABLE public."finance_lancamentos" ADD CONSTRAINT "finance_lancamentos_descricao_check" CHECK (((char_length(TRIM(BOTH FROM descricao)) >= 2) AND (char_length(TRIM(BOTH FROM descricao)) <= 240)));
ALTER TABLE public."finance_lancamentos" ADD CONSTRAINT "finance_transferencia_contas_check" CHECK (((tipo <> 'transferencia'::text) OR ((conta_id IS NOT NULL) AND (conta_destino_id IS NOT NULL) AND (conta_id <> conta_destino_id))));
ALTER TABLE public."finance_lancamentos" ADD CONSTRAINT "finance_lancamentos_pkey" PRIMARY KEY (id);
ALTER TABLE public."finance_extratos" ADD CONSTRAINT "finance_extratos_descricao_check" CHECK (((char_length(TRIM(BOTH FROM descricao)) >= 1) AND (char_length(TRIM(BOTH FROM descricao)) <= 500)));
ALTER TABLE public."finance_extratos" ADD CONSTRAINT "finance_extratos_match_check" CHECK ((NOT ((lancamento_id IS NOT NULL) AND (pagamento_id IS NOT NULL))));
ALTER TABLE public."finance_extratos" ADD CONSTRAINT "finance_extratos_pkey" PRIMARY KEY (id);
ALTER TABLE public."finance_fechamentos" ADD CONSTRAINT "finance_fechamentos_ano_check" CHECK (((ano >= 2020) AND (ano <= 2100)));
ALTER TABLE public."finance_fechamentos" ADD CONSTRAINT "finance_fechamentos_mes_check" CHECK (((mes >= 1) AND (mes <= 12)));
ALTER TABLE public."finance_fechamentos" ADD CONSTRAINT "finance_fechamentos_status_check" CHECK ((status = ANY (ARRAY['aberto'::text, 'fechado'::text])));
ALTER TABLE public."finance_fechamentos" ADD CONSTRAINT "finance_fechamentos_pkey" PRIMARY KEY (id);
ALTER TABLE public."finance_fechamentos" ADD CONSTRAINT "finance_fechamentos_cidade_id_ano_mes_key" UNIQUE (cidade_id, ano, mes);
ALTER TABLE public."finance_ativos" ADD CONSTRAINT "finance_ativos_valor_aquisicao_check" CHECK ((valor_aquisicao >= (0)::numeric));
ALTER TABLE public."finance_ativos" ADD CONSTRAINT "finance_ativos_valor_residual_check" CHECK ((valor_residual >= (0)::numeric));
ALTER TABLE public."finance_ativos" ADD CONSTRAINT "finance_ativos_status_check" CHECK ((status = ANY (ARRAY['ativo'::text, 'baixado'::text, 'vendido'::text])));
ALTER TABLE public."finance_ativos" ADD CONSTRAINT "finance_ativos_nome_check" CHECK (((char_length(TRIM(BOTH FROM nome)) >= 2) AND (char_length(TRIM(BOTH FROM nome)) <= 160)));
ALTER TABLE public."finance_ativos" ADD CONSTRAINT "finance_ativos_pkey" PRIMARY KEY (id);
ALTER TABLE public."inteligencia_regras_nicho" ADD CONSTRAINT "inteligencia_regras_nicho_prioridade_check" CHECK (((prioridade >= 1) AND (prioridade <= 1000)));
ALTER TABLE public."inteligencia_regras_nicho" ADD CONSTRAINT "inteligencia_regras_nicho_pkey" PRIMARY KEY (termo_chave);
ALTER TABLE public."agenda_premium" ADD CONSTRAINT "agenda_premium_sem_sobreposicao" EXCLUDE USING gist (cidade_id WITH =, tipo WITH =, slot WITH =, periodo WITH &&) WHERE ((status = ANY (ARRAY['reservado'::text, 'ativo'::text])));
ALTER TABLE public."contrato_versoes" ADD CONSTRAINT "contrato_versoes_cidade_codigo_key" UNIQUE (cidade_id, codigo);
ALTER TABLE public."empresas" ADD CONSTRAINT "empresas_status_check" CHECK ((status = ANY (ARRAY['pendente'::text, 'ativo'::text, 'rejeitado'::text, 'suspenso'::text, 'vencido'::text, 'inativo'::text, 'arquivado'::text])));
ALTER TABLE public."admin_permissoes_modulos" ADD CONSTRAINT "admin_permissoes_modulos_pkey" PRIMARY KEY (user_id);
ALTER TABLE public."beneficios_foguinho" ADD CONSTRAINT "beneficios_foguinho_pkey" PRIMARY KEY (empresa_id);
ALTER TABLE public."beneficios_foguinho" ADD CONSTRAINT "beneficios_foguinho_codigo_key" UNIQUE (codigo);
ALTER TABLE public."beneficios_foguinho_usos" ADD CONSTRAINT "beneficios_foguinho_usos_pkey" PRIMARY KEY (id);
ALTER TABLE public."beneficios_foguinho_usos" ADD CONSTRAINT "beneficios_foguinho_usos_promocao_id_key" UNIQUE (promocao_id);
ALTER TABLE public."metricas_rate_limits" ADD CONSTRAINT "metricas_rate_limits_pkey" PRIMARY KEY (route, fingerprint, bucket_seconds, bucket_start);
ALTER TABLE public."agenda_premium" ADD CONSTRAINT "agenda_premium_status_check" CHECK ((status = ANY (ARRAY['reservado'::text, 'ativo'::text, 'concluido'::text, 'cancelado'::text, 'aguardando_pagamento'::text])));
ALTER TABLE public."convites_cortesia_cadastro" ADD CONSTRAINT "convites_cortesia_cadastro_dias_check" CHECK (((dias >= 1) AND (dias <= 365)));
ALTER TABLE public."convites_cortesia_cadastro" ADD CONSTRAINT "convites_cortesia_cadastro_status_check" CHECK ((status = ANY (ARRAY['disponivel'::text, 'utilizado'::text, 'cancelado'::text, 'expirado'::text])));
ALTER TABLE public."convites_cortesia_cadastro" ADD CONSTRAINT "convites_cortesia_cadastro_pkey" PRIMARY KEY (id);
ALTER TABLE public."convites_cortesia_cadastro" ADD CONSTRAINT "convites_cortesia_cadastro_codigo_key" UNIQUE (codigo);
ALTER TABLE public."solicitacoes_alteracao_empresa" ADD CONSTRAINT "solicitacoes_alteracao_empresa_status_check" CHECK ((status = ANY (ARRAY['pendente'::text, 'aprovado'::text, 'recusado'::text])));
ALTER TABLE public."solicitacoes_alteracao_empresa" ADD CONSTRAINT "solicitacoes_alteracao_empresa_pkey" PRIMARY KEY (id);
ALTER TABLE public."cardapio_empresas" ADD CONSTRAINT "cardapio_empresas_status_check" CHECK ((status = ANY (ARRAY['teste'::text, 'ativo'::text, 'pausado'::text, 'inativo'::text])));
ALTER TABLE public."cardapio_empresas" ADD CONSTRAINT "cardapio_empresas_pkey" PRIMARY KEY (id);
ALTER TABLE public."cardapio_empresas" ADD CONSTRAINT "cardapio_empresas_empresa_id_key" UNIQUE (empresa_id);
ALTER TABLE public."cardapio_empresas" ADD CONSTRAINT "cardapio_empresas_auth_user_id_key" UNIQUE (auth_user_id);
ALTER TABLE public."cardapio_pagamento_config" ADD CONSTRAINT "cardapio_pagamento_config_provider_check" CHECK ((provider = ANY (ARRAY['mercadopago'::text, 'pix_direto'::text, 'pagbank'::text])));
ALTER TABLE public."cardapio_pagamento_config" ADD CONSTRAINT "cardapio_pagamento_config_status_check" CHECK ((status = ANY (ARRAY['desconectado'::text, 'pendente'::text, 'conectado'::text, 'erro'::text])));
ALTER TABLE public."cardapio_pagamento_config" ADD CONSTRAINT "cardapio_pagamento_config_pkey" PRIMARY KEY (id);
ALTER TABLE public."cardapio_pagamento_config" ADD CONSTRAINT "cardapio_pagamento_config_cardapio_empresa_id_provider_key" UNIQUE (cardapio_empresa_id, provider);
ALTER TABLE public."cardapio_mp_tokens" ADD CONSTRAINT "cardapio_mp_tokens_pkey" PRIMARY KEY (cardapio_empresa_id);
ALTER TABLE public."cardapio_metricas_diarias" ADD CONSTRAINT "cardapio_metricas_diarias_menu_views_check" CHECK ((menu_views >= 0));
ALTER TABLE public."cardapio_pedidos" ADD CONSTRAINT "cardapio_pedidos_modalidade_check" CHECK ((modalidade = ANY (ARRAY['entrega'::text, 'retirada'::text])));
ALTER TABLE public."cardapio_pedidos" ADD CONSTRAINT "cardapio_pedidos_subtotal_check" CHECK ((subtotal >= (0)::numeric));
ALTER TABLE public."cardapio_pedidos" ADD CONSTRAINT "cardapio_pedidos_frete_check" CHECK ((frete >= (0)::numeric));
ALTER TABLE public."cardapio_pedidos" ADD CONSTRAINT "cardapio_pedidos_total_check" CHECK ((total >= (0)::numeric));
ALTER TABLE public."cardapio_pedidos" ADD CONSTRAINT "cardapio_pedidos_status_check" CHECK ((status = ANY (ARRAY['novo'::text, 'aguardando_pagamento'::text, 'pago'::text, 'preparando'::text, 'pronto'::text, 'em_entrega'::text, 'concluido'::text, 'cancelado'::text])));
ALTER TABLE public."cardapio_pedidos" ADD CONSTRAINT "cardapio_pedidos_pkey" PRIMARY KEY (id);
ALTER TABLE public."cardapio_pedidos" ADD CONSTRAINT "cardapio_pedidos_codigo_key" UNIQUE (codigo);
ALTER TABLE public."cardapio_metricas_diarias" ADD CONSTRAINT "cardapio_metricas_diarias_cart_starts_check" CHECK ((cart_starts >= 0));
ALTER TABLE public."cardapio_metricas_diarias" ADD CONSTRAINT "cardapio_metricas_diarias_checkout_starts_check" CHECK ((checkout_starts >= 0));
ALTER TABLE public."cardapio_pagamentos" ADD CONSTRAINT "cardapio_pagamentos_status_check" CHECK ((status = ANY (ARRAY['pendente'::text, 'aprovado'::text, 'recusado'::text, 'cancelado'::text, 'estornado'::text, 'erro'::text])));
ALTER TABLE public."cardapio_pagamentos" ADD CONSTRAINT "cardapio_pagamentos_valor_bruto_check" CHECK ((valor_bruto >= (0)::numeric));
ALTER TABLE public."cardapio_pagamentos" ADD CONSTRAINT "cardapio_pagamentos_taxa_busque_check" CHECK ((taxa_busque >= (0)::numeric));
ALTER TABLE public."cardapio_pagamentos" ADD CONSTRAINT "cardapio_pagamentos_pkey" PRIMARY KEY (id);
ALTER TABLE public."cardapio_webhook_eventos" ADD CONSTRAINT "cardapio_webhook_eventos_pkey" PRIMARY KEY (event_key);
ALTER TABLE public."cardapio_produtos" ADD CONSTRAINT "cardapio_produtos_preco_check" CHECK ((preco >= (0)::numeric));
ALTER TABLE public."cardapio_produtos" ADD CONSTRAINT "cardapio_produtos_pkey" PRIMARY KEY (id);
ALTER TABLE public."cardapio_entrega_config" ADD CONSTRAINT "cardapio_entrega_faixas_array" CHECK ((jsonb_typeof(faixas) = 'array'::text));
ALTER TABLE public."cardapio_entrega_config" ADD CONSTRAINT "cardapio_entrega_max_20_faixas" CHECK ((jsonb_array_length(faixas) <= 20));
ALTER TABLE public."cardapio_metricas_diarias" ADD CONSTRAINT "cardapio_metricas_diarias_product_adds_check" CHECK ((product_adds >= 0));
ALTER TABLE public."cardapio_metricas_diarias" ADD CONSTRAINT "cardapio_metricas_diarias_pkey" PRIMARY KEY (cardapio_empresa_id, dia);
ALTER TABLE public."cardapio_metricas_produtos_diarias" ADD CONSTRAINT "cardapio_metricas_produtos_diarias_adds_check" CHECK ((adds >= 0));
ALTER TABLE public."cardapio_metricas_produtos_diarias" ADD CONSTRAINT "cardapio_metricas_produtos_diarias_pkey" PRIMARY KEY (cardapio_empresa_id, dia, produto_id);
ALTER TABLE public."cardapio_entrega_config" ADD CONSTRAINT "cardapio_entrega_config_modo_check" CHECK ((modo = ANY (ARRAY['own'::text, 'pickup'::text])));
ALTER TABLE public."cardapio_produto_grupos" ADD CONSTRAINT "cardapio_produto_grupos_tipo_check" CHECK ((tipo = ANY (ARRAY['single'::text, 'multiple'::text])));
ALTER TABLE public."cardapio_produto_grupos" ADD CONSTRAINT "cardapio_produto_grupos_minimo_check" CHECK (((minimo >= 0) AND (minimo <= 20)));
ALTER TABLE public."cardapio_produto_grupos" ADD CONSTRAINT "cardapio_produto_grupos_maximo_check" CHECK (((maximo >= 1) AND (maximo <= 20)));
ALTER TABLE public."cardapio_produto_grupos" ADD CONSTRAINT "cardapio_produto_grupos_minmax" CHECK ((minimo <= maximo));
ALTER TABLE public."cardapio_produto_grupos" ADD CONSTRAINT "cardapio_produto_grupos_pkey" PRIMARY KEY (id);
ALTER TABLE public."cardapio_produto_opcoes" ADD CONSTRAINT "cardapio_produto_opcoes_preco_adicional_check" CHECK ((preco_adicional >= (0)::numeric));
ALTER TABLE public."cardapio_produto_opcoes" ADD CONSTRAINT "cardapio_produto_opcoes_pkey" PRIMARY KEY (id);
ALTER TABLE public."cardapio_admin_acessos" ADD CONSTRAINT "cardapio_admin_acessos_pkey" PRIMARY KEY (user_id);
ALTER TABLE public."cardapio_empresas" ADD CONSTRAINT "cardapio_empresas_modelo_recebimento_check" CHECK ((modelo_recebimento = ANY (ARRAY['mercadopago_split'::text, 'banco_creditos'::text])));
ALTER TABLE public."cardapio_creditos_carteiras" ADD CONSTRAINT "cardapio_creditos_carteiras_saldo_check" CHECK ((saldo >= 0));
ALTER TABLE public."cardapio_creditos_carteiras" ADD CONSTRAINT "cardapio_creditos_carteiras_reservados_check" CHECK ((reservados >= 0));
ALTER TABLE public."cardapio_creditos_carteiras" ADD CONSTRAINT "cardapio_creditos_carteiras_alerta_limite_check" CHECK (((alerta_limite >= 1) AND (alerta_limite <= 100)));
ALTER TABLE public."cardapio_creditos_carteiras" ADD CONSTRAINT "cardapio_creditos_carteiras_reservados_saldo" CHECK ((reservados <= saldo));
ALTER TABLE public."cardapio_creditos_carteiras" ADD CONSTRAINT "cardapio_creditos_carteiras_pkey" PRIMARY KEY (cardapio_empresa_id);
ALTER TABLE public."cardapio_creditos_recargas" ADD CONSTRAINT "cardapio_creditos_recargas_quantidade_check" CHECK (((quantidade > 0) AND (quantidade <= 10000)));
ALTER TABLE public."cardapio_creditos_recargas" ADD CONSTRAINT "cardapio_creditos_recargas_valor_unitario_check" CHECK ((valor_unitario > (0)::numeric));
ALTER TABLE public."cardapio_creditos_recargas" ADD CONSTRAINT "cardapio_creditos_recargas_valor_total_check" CHECK ((valor_total > (0)::numeric));
ALTER TABLE public."cardapio_creditos_recargas" ADD CONSTRAINT "cardapio_creditos_recargas_status_check" CHECK ((status = ANY (ARRAY['pendente'::text, 'aprovada'::text, 'recusada'::text, 'cancelada'::text, 'expirada'::text, 'erro'::text])));
ALTER TABLE public."cardapio_creditos_recargas" ADD CONSTRAINT "cardapio_creditos_recargas_provider_check" CHECK ((provider = 'mercadopago_busque'::text));
ALTER TABLE public."cardapio_creditos_recargas" ADD CONSTRAINT "cardapio_creditos_recargas_pkey" PRIMARY KEY (id);
ALTER TABLE public."cardapio_creditos_recargas" ADD CONSTRAINT "cardapio_creditos_recargas_external_reference_key" UNIQUE (external_reference);
ALTER TABLE public."cardapio_creditos_reservas" ADD CONSTRAINT "cardapio_creditos_reservas_status_check" CHECK ((status = ANY (ARRAY['reservada'::text, 'consumida'::text, 'liberada'::text])));
ALTER TABLE public."cardapio_creditos_reservas" ADD CONSTRAINT "cardapio_creditos_reservas_pkey" PRIMARY KEY (pedido_id);
ALTER TABLE public."cardapio_creditos_movimentos" ADD CONSTRAINT "cardapio_creditos_movimentos_tipo_check" CHECK ((tipo = ANY (ARRAY['recarga'::text, 'consumo'::text, 'estorno'::text, 'ajuste'::text])));
ALTER TABLE public."cardapio_creditos_movimentos" ADD CONSTRAINT "cardapio_creditos_movimentos_quantidade_check" CHECK ((quantidade <> 0));
ALTER TABLE public."cardapio_creditos_movimentos" ADD CONSTRAINT "cardapio_creditos_movimentos_saldo_antes_check" CHECK ((saldo_antes >= 0));
ALTER TABLE public."cardapio_creditos_movimentos" ADD CONSTRAINT "cardapio_creditos_movimentos_saldo_depois_check" CHECK ((saldo_depois >= 0));
ALTER TABLE public."cardapio_creditos_movimentos" ADD CONSTRAINT "cardapio_creditos_movimentos_pkey" PRIMARY KEY (id);
ALTER TABLE public."cardapio_creditos_movimentos" ADD CONSTRAINT "cardapio_creditos_movimentos_chave_idempotencia_key" UNIQUE (chave_idempotencia);
ALTER TABLE public."cardapio_banco_conexoes" ADD CONSTRAINT "cardapio_banco_conexoes_status_check" CHECK ((status = ANY (ARRAY['desconectado'::text, 'pendente'::text, 'conectado'::text, 'erro'::text])));
ALTER TABLE public."cardapio_banco_conexoes" ADD CONSTRAINT "cardapio_banco_conexoes_ambiente_check" CHECK ((ambiente = ANY (ARRAY['sandbox'::text, 'producao'::text])));
ALTER TABLE public."cardapio_banco_conexoes" ADD CONSTRAINT "cardapio_banco_codigo_formato" CHECK ((banco_codigo ~ '^[a-z0-9_]{2,40}$'::text));
ALTER TABLE public."cardapio_banco_conexoes" ADD CONSTRAINT "cardapio_banco_conexoes_pkey" PRIMARY KEY (cardapio_empresa_id);
ALTER TABLE public."cardapio_pagamentos" ADD CONSTRAINT "cardapio_pagamentos_provider_check_v2" CHECK ((provider = ANY (ARRAY['mercadopago'::text, 'pix_direto'::text, 'pagbank'::text, 'simulado'::text, 'banco_api'::text])));
ALTER TABLE public."cardapio_creditos_config" ADD CONSTRAINT "cardapio_creditos_config_chave_check" CHECK ((chave = 'padrao'::text));
ALTER TABLE public."cardapio_creditos_config" ADD CONSTRAINT "cardapio_creditos_config_valor_credito_check" CHECK ((valor_credito > (0)::numeric));
ALTER TABLE public."cardapio_creditos_config" ADD CONSTRAINT "cardapio_creditos_config_minimo_recarga_check" CHECK ((minimo_recarga >= 1));
ALTER TABLE public."cardapio_creditos_config" ADD CONSTRAINT "cardapio_creditos_config_check" CHECK ((maximo_recarga >= minimo_recarga));
ALTER TABLE public."cardapio_creditos_config" ADD CONSTRAINT "cardapio_creditos_config_alerta_limite_check" CHECK (((alerta_limite >= 1) AND (alerta_limite <= 100)));
ALTER TABLE public."cardapio_bancos_catalogo" ADD CONSTRAINT "cardapio_bancos_catalogo_categoria_check" CHECK ((categoria = ANY (ARRAY['banco'::text, 'cooperativa'::text, 'fintech'::text, 'meio_pagamento'::text])));
ALTER TABLE public."cardapio_bancos_catalogo" ADD CONSTRAINT "cardapio_bancos_catalogo_status_integracao_check" CHECK ((status_integracao = ANY (ARRAY['ativo'::text, 'homologacao'::text, 'pesquisa'::text, 'indisponivel_api_publica'::text])));
ALTER TABLE public."cardapio_bancos_catalogo" ADD CONSTRAINT "cardapio_bancos_catalogo_tipo_integracao_check" CHECK (((tipo_integracao IS NULL) OR (tipo_integracao = ANY (ARRAY['pix_bcb_mtls'::text, 'oauth_api'::text, 'bearer_api'::text]))));
ALTER TABLE public."cardapio_bancos_catalogo" ADD CONSTRAINT "cardapio_bancos_catalogo_pkey" PRIMARY KEY (codigo);
ALTER TABLE public."cardapio_banco_conexoes" ADD CONSTRAINT "cardapio_banco_conexoes_tipo_integracao_check" CHECK (((tipo_integracao IS NULL) OR (tipo_integracao = ANY (ARRAY['pix_bcb_mtls'::text, 'oauth_api'::text, 'bearer_api'::text]))));
ALTER TABLE public."cardapio_produto_grupos" ADD CONSTRAINT "cardapio_produto_grupos_modo_preco_check" CHECK ((modo_preco = ANY (ARRAY['adicional'::text, 'final'::text])));
ALTER TABLE public."cardapio_empresas" ADD CONSTRAINT "cardapio_empresas_latitude_check" CHECK (((latitude IS NULL) OR ((latitude >= ('-90'::integer)::numeric) AND (latitude <= (90)::numeric))));
ALTER TABLE public."cardapio_empresas" ADD CONSTRAINT "cardapio_empresas_longitude_check" CHECK (((longitude IS NULL) OR ((longitude >= ('-180'::integer)::numeric) AND (longitude <= (180)::numeric))));
ALTER TABLE public."cardapio_mapbox_config" ADD CONSTRAINT "cardapio_mapbox_config_profile_check" CHECK ((profile = ANY (ARRAY['mapbox/driving'::text, 'mapbox/driving-traffic'::text])));
ALTER TABLE public."cardapio_mapbox_config" ADD CONSTRAINT "cardapio_mapbox_config_pkey" PRIMARY KEY (chave);
ALTER TABLE public."cardapio_entrega_quotes" ADD CONSTRAINT "cardapio_entrega_quotes_cliente_latitude_check" CHECK (((cliente_latitude >= ('-90'::integer)::numeric) AND (cliente_latitude <= (90)::numeric)));
ALTER TABLE public."cardapio_entrega_quotes" ADD CONSTRAINT "cardapio_entrega_quotes_cliente_longitude_check" CHECK (((cliente_longitude >= ('-180'::integer)::numeric) AND (cliente_longitude <= (180)::numeric)));
ALTER TABLE public."cardapio_entrega_quotes" ADD CONSTRAINT "cardapio_entrega_quotes_distancia_km_check" CHECK ((distancia_km >= (0)::numeric));
ALTER TABLE public."cardapio_entrega_quotes" ADD CONSTRAINT "cardapio_entrega_quotes_duracao_segundos_check" CHECK (((duracao_segundos IS NULL) OR (duracao_segundos >= 0)));
ALTER TABLE public."cardapio_entrega_quotes" ADD CONSTRAINT "cardapio_entrega_quotes_faixa_km_check" CHECK ((faixa_km > (0)::numeric));
ALTER TABLE public."cardapio_entrega_quotes" ADD CONSTRAINT "cardapio_entrega_quotes_taxa_check" CHECK ((taxa >= (0)::numeric));
ALTER TABLE public."cardapio_entrega_quotes" ADD CONSTRAINT "cardapio_entrega_quotes_pkey" PRIMARY KEY (id);
ALTER TABLE public."cardapio_visitas_sessoes" ADD CONSTRAINT "cardapio_visitas_sessoes_id_chk" CHECK (((char_length(session_id) >= 16) AND (char_length(session_id) <= 100)));
ALTER TABLE public."cardapio_visitas_sessoes" ADD CONSTRAINT "cardapio_visitas_sessoes_pkey" PRIMARY KEY (session_id);
ALTER TABLE public."cardapio_visitas_diarias" ADD CONSTRAINT "cardapio_visitas_diarias_visitas_check" CHECK ((visitas >= 0));
ALTER TABLE public."cardapio_visitas_diarias" ADD CONSTRAINT "cardapio_visitas_diarias_pkey" PRIMARY KEY (dia);
ALTER TABLE public."cardapio_visitas_auto_sessoes" ADD CONSTRAINT "cardapio_visitas_auto_fp_chk" CHECK (((char_length(fingerprint) >= 32) AND (char_length(fingerprint) <= 100)));
ALTER TABLE public."cardapio_visitas_auto_sessoes" ADD CONSTRAINT "cardapio_visitas_auto_sessoes_pkey" PRIMARY KEY (fingerprint);
ALTER TABLE public."cardapio_public_rate_limits" ADD CONSTRAINT "cardapio_public_rate_limits_route_chk" CHECK (((char_length(route) >= 2) AND (char_length(route) <= 80)));
ALTER TABLE public."cardapio_public_rate_limits" ADD CONSTRAINT "cardapio_public_rate_limits_fp_chk" CHECK (((char_length(fingerprint) >= 32) AND (char_length(fingerprint) <= 100)));
ALTER TABLE public."cardapio_public_rate_limits" ADD CONSTRAINT "cardapio_public_rate_limits_window_chk" CHECK (((window_seconds >= 10) AND (window_seconds <= 86400)));
ALTER TABLE public."cardapio_public_rate_limits" ADD CONSTRAINT "cardapio_public_rate_limits_hits_chk" CHECK ((hits >= 1));
ALTER TABLE public."cardapio_public_rate_limits" ADD CONSTRAINT "cardapio_public_rate_limits_pkey" PRIMARY KEY (route, fingerprint, window_seconds, bucket_start);
ALTER TABLE public."cardapio_busque_torres_beneficios" ADD CONSTRAINT "cardapio_busque_torres_beneficios_status_check" CHECK ((status = ANY (ARRAY['emitido'::text, 'utilizado'::text, 'bloqueado'::text])));
ALTER TABLE public."cardapio_busque_torres_beneficios" ADD CONSTRAINT "cardapio_busque_torres_beneficios_pkey" PRIMARY KEY (id);
ALTER TABLE public."cardapio_busque_torres_beneficios" ADD CONSTRAINT "cardapio_busque_torres_beneficios_cardapio_empresa_id_key" UNIQUE (cardapio_empresa_id);
ALTER TABLE public."cardapio_busque_torres_beneficios" ADD CONSTRAINT "cardapio_busque_torres_beneficios_convite_id_key" UNIQUE (convite_id);
ALTER TABLE public."cardapio_busque_torres_beneficios" ADD CONSTRAINT "cardapio_busque_torres_beneficios_chave_empresa_key" UNIQUE (chave_empresa);
ALTER TABLE public."cardapio_comercial_catalogo" ADD CONSTRAINT "cardapio_comercial_catalogo_tipo_check" CHECK ((tipo = ANY (ARRAY['vitrine'::text, 'destaque'::text, 'oferta'::text])));
ALTER TABLE public."cardapio_comercial_catalogo" ADD CONSTRAINT "cardapio_comercial_catalogo_valor_check" CHECK ((valor >= (0)::numeric));
ALTER TABLE public."cardapio_comercial_catalogo" ADD CONSTRAINT "cardapio_comercial_catalogo_duracao_dias_check" CHECK ((duracao_dias >= 1));
ALTER TABLE public."cardapio_comercial_catalogo" ADD CONSTRAINT "cardapio_comercial_catalogo_limite_slots_check" CHECK ((limite_slots >= 1));
ALTER TABLE public."cardapio_comercial_catalogo" ADD CONSTRAINT "cardapio_comercial_catalogo_pkey" PRIMARY KEY (codigo);
ALTER TABLE public."cardapio_comercial_compras" ADD CONSTRAINT "cardapio_comercial_compras_status_check" CHECK ((status = ANY (ARRAY['pendente'::text, 'ativo'::text, 'expirado'::text, 'cancelado'::text, 'erro'::text])));
ALTER TABLE public."cardapio_comercial_compras" ADD CONSTRAINT "cardapio_comercial_compras_valor_check" CHECK ((valor >= (0)::numeric));
ALTER TABLE public."cardapio_comercial_compras" ADD CONSTRAINT "cardapio_comercial_compras_pkey" PRIMARY KEY (id);
ALTER TABLE public."cardapio_comercial_compras" ADD CONSTRAINT "cardapio_comercial_compras_external_reference_key" UNIQUE (external_reference);
ALTER TABLE public."cardapio_acessos_diarios" ADD CONSTRAINT "cardapio_acessos_diarios_acessos_check" CHECK ((acessos >= 0));
ALTER TABLE public."cardapio_acessos_diarios" ADD CONSTRAINT "cardapio_acessos_diarios_pkey" PRIMARY KEY (dia, origem);
ALTER TABLE public."agenda_premium_historico" ADD CONSTRAINT "agenda_premium_historico_pkey" PRIMARY KEY (id);
ALTER TABLE public."pagamentos" ADD CONSTRAINT "pagamentos_forma_pagamento_check" CHECK ((forma_pagamento = ANY (ARRAY['pix'::text, 'checkout_pro'::text, 'dinheiro'::text])));
ALTER TABLE public."clima_acessos" ADD CONSTRAINT "clima_acessos_pkey" PRIMARY KEY (id);
ALTER TABLE public."administradores" ADD CONSTRAINT "administradores_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;
ALTER TABLE public."cardapio_produto_grupos" ADD CONSTRAINT "cardapio_produto_grupos_produto_id_fkey" FOREIGN KEY (produto_id) REFERENCES cardapio_produtos(id) ON DELETE CASCADE;
ALTER TABLE public."agenda_premium" ADD CONSTRAINT "agenda_premium_empresa_id_fkey" FOREIGN KEY (empresa_id) REFERENCES empresas(id) ON DELETE CASCADE;
ALTER TABLE public."cardapio_creditos_movimentos" ADD CONSTRAINT "cardapio_creditos_movimentos_pedido_id_fkey" FOREIGN KEY (pedido_id) REFERENCES cardapio_pedidos(id) ON DELETE SET NULL;
ALTER TABLE public."cardapio_creditos_movimentos" ADD CONSTRAINT "cardapio_creditos_movimentos_recarga_id_fkey" FOREIGN KEY (recarga_id) REFERENCES cardapio_creditos_recargas(id) ON DELETE SET NULL;
ALTER TABLE public."empresas" ADD CONSTRAINT "empresas_moderado_por_fkey" FOREIGN KEY (moderado_por) REFERENCES auth.users(id) ON DELETE SET NULL;
ALTER TABLE public."convites_cortesia_cadastro" ADD CONSTRAINT "convites_cortesia_cadastro_empresa_id_fkey" FOREIGN KEY (empresa_id) REFERENCES empresas(id) ON DELETE SET NULL;
ALTER TABLE public."vagas" ADD CONSTRAINT "vagas_empresa_id_fkey" FOREIGN KEY (empresa_id) REFERENCES empresas(id) ON DELETE SET NULL;
ALTER TABLE public."vagas" ADD CONSTRAINT "vagas_moderado_por_fkey" FOREIGN KEY (moderado_por) REFERENCES auth.users(id) ON DELETE SET NULL;
ALTER TABLE public."cardapio_entrega_config" ADD CONSTRAINT "cardapio_entrega_config_cardapio_empresa_id_fkey" FOREIGN KEY (cardapio_empresa_id) REFERENCES cardapio_empresas(id) ON DELETE CASCADE;
ALTER TABLE public."promocoes" ADD CONSTRAINT "promocoes_empresa_id_fkey" FOREIGN KEY (empresa_id) REFERENCES empresas(id) ON DELETE CASCADE;
ALTER TABLE public."promocoes" ADD CONSTRAINT "promocoes_moderado_por_fkey" FOREIGN KEY (moderado_por) REFERENCES auth.users(id) ON DELETE SET NULL;
ALTER TABLE public."pagamentos" ADD CONSTRAINT "pagamentos_empresa_id_fkey" FOREIGN KEY (empresa_id) REFERENCES empresas(id) ON DELETE RESTRICT;
ALTER TABLE public."admin_atividades" ADD CONSTRAINT "admin_atividades_sessao_id_fkey" FOREIGN KEY (sessao_id) REFERENCES admin_sessoes(id) ON DELETE SET NULL;
ALTER TABLE public."crm_alertas_vencimento" ADD CONSTRAINT "crm_alertas_vencimento_empresa_id_fkey" FOREIGN KEY (empresa_id) REFERENCES empresas(id) ON DELETE CASCADE;
ALTER TABLE public."crm_alertas_vencimento" ADD CONSTRAINT "crm_alertas_vencimento_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;
ALTER TABLE public."produtos_comerciais" ADD CONSTRAINT "produtos_comerciais_cidade_id_fkey" FOREIGN KEY (cidade_id) REFERENCES cidades(id) ON UPDATE CASCADE ON DELETE RESTRICT;
ALTER TABLE public."pagamentos" ADD CONSTRAINT "pagamentos_promocao_id_fkey" FOREIGN KEY (promocao_id) REFERENCES promocoes(id) ON DELETE SET NULL;
ALTER TABLE public."promocoes" ADD CONSTRAINT "promocoes_cidade_id_fkey" FOREIGN KEY (cidade_id) REFERENCES cidades(id) ON UPDATE CASCADE ON DELETE RESTRICT;
ALTER TABLE public."promocoes" ADD CONSTRAINT "promocoes_pagamento_id_fkey" FOREIGN KEY (pagamento_id) REFERENCES pagamentos(id) ON DELETE SET NULL;
ALTER TABLE public."finance_orcamentos" ADD CONSTRAINT "finance_orcamentos_categoria_id_fkey" FOREIGN KEY (categoria_id) REFERENCES finance_categorias(id) ON DELETE CASCADE;
ALTER TABLE public."finance_orcamentos" ADD CONSTRAINT "finance_orcamentos_centro_custo_id_fkey" FOREIGN KEY (centro_custo_id) REFERENCES finance_centros_custo(id) ON DELETE SET NULL;
ALTER TABLE public."aceites_contrato" ADD CONSTRAINT "aceites_contrato_empresa_id_fkey" FOREIGN KEY (empresa_id) REFERENCES empresas(id) ON DELETE RESTRICT;
ALTER TABLE public."aceites_contrato" ADD CONSTRAINT "aceites_contrato_contrato_versao_id_fkey" FOREIGN KEY (contrato_versao_id) REFERENCES contrato_versoes(id) ON DELETE RESTRICT;
ALTER TABLE public."aceites_contrato" ADD CONSTRAINT "aceites_contrato_pagamento_id_fkey" FOREIGN KEY (pagamento_id) REFERENCES pagamentos(id) ON DELETE SET NULL;
ALTER TABLE public."pagamentos" ADD CONSTRAINT "pagamentos_aceite_contrato_id_fkey" FOREIGN KEY (aceite_contrato_id) REFERENCES aceites_contrato(id) ON DELETE SET NULL;
ALTER TABLE public."aceites_promocao_dia" ADD CONSTRAINT "aceites_promocao_dia_promocao_id_fkey" FOREIGN KEY (promocao_id) REFERENCES promocoes(id) ON DELETE CASCADE;
ALTER TABLE public."aceites_promocao_dia" ADD CONSTRAINT "aceites_promocao_dia_empresa_id_fkey" FOREIGN KEY (empresa_id) REFERENCES empresas(id) ON DELETE CASCADE;
ALTER TABLE public."crm_leads" ADD CONSTRAINT "crm_leads_empresa_id_fkey" FOREIGN KEY (empresa_id) REFERENCES empresas(id) ON DELETE SET NULL;
ALTER TABLE public."crm_tarefas" ADD CONSTRAINT "crm_tarefas_lead_id_fkey" FOREIGN KEY (lead_id) REFERENCES crm_leads(id) ON DELETE CASCADE;
ALTER TABLE public."crm_atividades" ADD CONSTRAINT "crm_atividades_lead_id_fkey" FOREIGN KEY (lead_id) REFERENCES crm_leads(id) ON DELETE CASCADE;
ALTER TABLE public."finance_categorias" ADD CONSTRAINT "finance_categorias_parent_id_fkey" FOREIGN KEY (parent_id) REFERENCES finance_categorias(id) ON DELETE SET NULL;
ALTER TABLE public."finance_recorrencias" ADD CONSTRAINT "finance_recorrencias_categoria_id_fkey" FOREIGN KEY (categoria_id) REFERENCES finance_categorias(id) ON DELETE SET NULL;
ALTER TABLE public."finance_recorrencias" ADD CONSTRAINT "finance_recorrencias_centro_custo_id_fkey" FOREIGN KEY (centro_custo_id) REFERENCES finance_centros_custo(id) ON DELETE SET NULL;
ALTER TABLE public."finance_recorrencias" ADD CONSTRAINT "finance_recorrencias_parceiro_id_fkey" FOREIGN KEY (parceiro_id) REFERENCES finance_parceiros(id) ON DELETE SET NULL;
ALTER TABLE public."finance_recorrencias" ADD CONSTRAINT "finance_recorrencias_empresa_id_fkey" FOREIGN KEY (empresa_id) REFERENCES empresas(id) ON DELETE SET NULL;
ALTER TABLE public."finance_recorrencias" ADD CONSTRAINT "finance_recorrencias_conta_id_fkey" FOREIGN KEY (conta_id) REFERENCES finance_contas(id) ON DELETE SET NULL;
ALTER TABLE public."finance_lancamentos" ADD CONSTRAINT "finance_lancamentos_categoria_id_fkey" FOREIGN KEY (categoria_id) REFERENCES finance_categorias(id) ON DELETE SET NULL;
ALTER TABLE public."finance_lancamentos" ADD CONSTRAINT "finance_lancamentos_centro_custo_id_fkey" FOREIGN KEY (centro_custo_id) REFERENCES finance_centros_custo(id) ON DELETE SET NULL;
ALTER TABLE public."finance_lancamentos" ADD CONSTRAINT "finance_lancamentos_parceiro_id_fkey" FOREIGN KEY (parceiro_id) REFERENCES finance_parceiros(id) ON DELETE SET NULL;
ALTER TABLE public."finance_lancamentos" ADD CONSTRAINT "finance_lancamentos_empresa_id_fkey" FOREIGN KEY (empresa_id) REFERENCES empresas(id) ON DELETE SET NULL;
ALTER TABLE public."finance_lancamentos" ADD CONSTRAINT "finance_lancamentos_conta_id_fkey" FOREIGN KEY (conta_id) REFERENCES finance_contas(id) ON DELETE SET NULL;
ALTER TABLE public."finance_lancamentos" ADD CONSTRAINT "finance_lancamentos_conta_destino_id_fkey" FOREIGN KEY (conta_destino_id) REFERENCES finance_contas(id) ON DELETE SET NULL;
ALTER TABLE public."finance_lancamentos" ADD CONSTRAINT "finance_lancamentos_recorrencia_id_fkey" FOREIGN KEY (recorrencia_id) REFERENCES finance_recorrencias(id) ON DELETE SET NULL;
ALTER TABLE public."finance_extratos" ADD CONSTRAINT "finance_extratos_conta_id_fkey" FOREIGN KEY (conta_id) REFERENCES finance_contas(id) ON DELETE CASCADE;
ALTER TABLE public."finance_extratos" ADD CONSTRAINT "finance_extratos_lancamento_id_fkey" FOREIGN KEY (lancamento_id) REFERENCES finance_lancamentos(id) ON DELETE SET NULL;
ALTER TABLE public."finance_extratos" ADD CONSTRAINT "finance_extratos_pagamento_id_fkey" FOREIGN KEY (pagamento_id) REFERENCES pagamentos(id) ON DELETE SET NULL;
ALTER TABLE public."finance_ativos" ADD CONSTRAINT "finance_ativos_conta_id_fkey" FOREIGN KEY (conta_id) REFERENCES finance_contas(id) ON DELETE SET NULL;
ALTER TABLE public."agenda_premium" ADD CONSTRAINT "agenda_premium_cidade_id_fkey" FOREIGN KEY (cidade_id) REFERENCES cidades(id);
ALTER TABLE public."contrato_versoes" ADD CONSTRAINT "contrato_versoes_cidade_id_fkey" FOREIGN KEY (cidade_id) REFERENCES cidades(id);
ALTER TABLE public."beneficios_foguinho" ADD CONSTRAINT "beneficios_foguinho_empresa_id_fkey" FOREIGN KEY (empresa_id) REFERENCES empresas(id) ON DELETE CASCADE;
ALTER TABLE public."beneficios_foguinho_usos" ADD CONSTRAINT "beneficios_foguinho_usos_empresa_id_fkey" FOREIGN KEY (empresa_id) REFERENCES empresas(id) ON DELETE CASCADE;
ALTER TABLE public."beneficios_foguinho_usos" ADD CONSTRAINT "beneficios_foguinho_usos_promocao_id_fkey" FOREIGN KEY (promocao_id) REFERENCES promocoes(id) ON DELETE CASCADE;
ALTER TABLE public."pagamentos" ADD CONSTRAINT "pagamentos_agenda_premium_id_fkey" FOREIGN KEY (agenda_premium_id) REFERENCES agenda_premium(id);
ALTER TABLE public."convites_cortesia_cadastro" ADD CONSTRAINT "convites_cortesia_cadastro_cidade_id_fkey" FOREIGN KEY (cidade_id) REFERENCES cidades(id);
ALTER TABLE public."solicitacoes_alteracao_empresa" ADD CONSTRAINT "solicitacoes_alteracao_empresa_empresa_id_fkey" FOREIGN KEY (empresa_id) REFERENCES empresas(id) ON DELETE CASCADE;
ALTER TABLE public."solicitacoes_alteracao_empresa" ADD CONSTRAINT "solicitacoes_alteracao_empresa_cidade_id_fkey" FOREIGN KEY (cidade_id) REFERENCES cidades(id);
ALTER TABLE public."cardapio_empresas" ADD CONSTRAINT "cardapio_empresas_empresa_id_fkey" FOREIGN KEY (empresa_id) REFERENCES empresas(id) ON DELETE SET NULL;
ALTER TABLE public."cardapio_empresas" ADD CONSTRAINT "cardapio_empresas_auth_user_id_fkey" FOREIGN KEY (auth_user_id) REFERENCES auth.users(id) ON DELETE SET NULL;
ALTER TABLE public."cardapio_pagamento_config" ADD CONSTRAINT "cardapio_pagamento_config_cardapio_empresa_id_fkey" FOREIGN KEY (cardapio_empresa_id) REFERENCES cardapio_empresas(id) ON DELETE CASCADE;
ALTER TABLE public."cardapio_mp_tokens" ADD CONSTRAINT "cardapio_mp_tokens_cardapio_empresa_id_fkey" FOREIGN KEY (cardapio_empresa_id) REFERENCES cardapio_empresas(id) ON DELETE CASCADE;
ALTER TABLE public."cardapio_pedidos" ADD CONSTRAINT "cardapio_pedidos_cardapio_empresa_id_fkey" FOREIGN KEY (cardapio_empresa_id) REFERENCES cardapio_empresas(id) ON DELETE RESTRICT;
ALTER TABLE public."cardapio_pagamentos" ADD CONSTRAINT "cardapio_pagamentos_pedido_id_fkey" FOREIGN KEY (pedido_id) REFERENCES cardapio_pedidos(id) ON DELETE RESTRICT;
ALTER TABLE public."cardapio_pagamentos" ADD CONSTRAINT "cardapio_pagamentos_cardapio_empresa_id_fkey" FOREIGN KEY (cardapio_empresa_id) REFERENCES cardapio_empresas(id) ON DELETE RESTRICT;
ALTER TABLE public."cardapio_webhook_eventos" ADD CONSTRAINT "cardapio_webhook_eventos_cardapio_empresa_id_fkey" FOREIGN KEY (cardapio_empresa_id) REFERENCES cardapio_empresas(id) ON DELETE SET NULL;
ALTER TABLE public."cardapio_webhook_eventos" ADD CONSTRAINT "cardapio_webhook_eventos_pedido_id_fkey" FOREIGN KEY (pedido_id) REFERENCES cardapio_pedidos(id) ON DELETE SET NULL;
ALTER TABLE public."cardapio_produtos" ADD CONSTRAINT "cardapio_produtos_cardapio_empresa_id_fkey" FOREIGN KEY (cardapio_empresa_id) REFERENCES cardapio_empresas(id) ON DELETE CASCADE;
ALTER TABLE public."cardapio_metricas_diarias" ADD CONSTRAINT "cardapio_metricas_diarias_cardapio_empresa_id_fkey" FOREIGN KEY (cardapio_empresa_id) REFERENCES cardapio_empresas(id) ON DELETE CASCADE;
ALTER TABLE public."cardapio_metricas_produtos_diarias" ADD CONSTRAINT "cardapio_metricas_produtos_diarias_cardapio_empresa_id_fkey" FOREIGN KEY (cardapio_empresa_id) REFERENCES cardapio_empresas(id) ON DELETE CASCADE;
ALTER TABLE public."cardapio_metricas_produtos_diarias" ADD CONSTRAINT "cardapio_metricas_produtos_diarias_produto_id_fkey" FOREIGN KEY (produto_id) REFERENCES cardapio_produtos(id) ON DELETE CASCADE;
ALTER TABLE public."cardapio_produto_opcoes" ADD CONSTRAINT "cardapio_produto_opcoes_grupo_id_fkey" FOREIGN KEY (grupo_id) REFERENCES cardapio_produto_grupos(id) ON DELETE CASCADE;
ALTER TABLE public."cardapio_admin_acessos" ADD CONSTRAINT "cardapio_admin_acessos_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;
ALTER TABLE public."cardapio_creditos_carteiras" ADD CONSTRAINT "cardapio_creditos_carteiras_cardapio_empresa_id_fkey" FOREIGN KEY (cardapio_empresa_id) REFERENCES cardapio_empresas(id) ON DELETE CASCADE;
ALTER TABLE public."cardapio_creditos_recargas" ADD CONSTRAINT "cardapio_creditos_recargas_cardapio_empresa_id_fkey" FOREIGN KEY (cardapio_empresa_id) REFERENCES cardapio_empresas(id) ON DELETE CASCADE;
ALTER TABLE public."cardapio_creditos_reservas" ADD CONSTRAINT "cardapio_creditos_reservas_pedido_id_fkey" FOREIGN KEY (pedido_id) REFERENCES cardapio_pedidos(id) ON DELETE CASCADE;
ALTER TABLE public."cardapio_creditos_reservas" ADD CONSTRAINT "cardapio_creditos_reservas_cardapio_empresa_id_fkey" FOREIGN KEY (cardapio_empresa_id) REFERENCES cardapio_empresas(id) ON DELETE CASCADE;
ALTER TABLE public."cardapio_creditos_movimentos" ADD CONSTRAINT "cardapio_creditos_movimentos_cardapio_empresa_id_fkey" FOREIGN KEY (cardapio_empresa_id) REFERENCES cardapio_empresas(id) ON DELETE CASCADE;
ALTER TABLE public."cardapio_banco_conexoes" ADD CONSTRAINT "cardapio_banco_conexoes_cardapio_empresa_id_fkey" FOREIGN KEY (cardapio_empresa_id) REFERENCES cardapio_empresas(id) ON DELETE CASCADE;
ALTER TABLE public."cardapio_entrega_quotes" ADD CONSTRAINT "cardapio_entrega_quotes_cardapio_empresa_id_fkey" FOREIGN KEY (cardapio_empresa_id) REFERENCES cardapio_empresas(id) ON DELETE CASCADE;
ALTER TABLE public."cardapio_entrega_quotes" ADD CONSTRAINT "cardapio_entrega_quotes_pedido_id_fkey" FOREIGN KEY (pedido_id) REFERENCES cardapio_pedidos(id) ON DELETE SET NULL;
ALTER TABLE public."cardapio_busque_torres_beneficios" ADD CONSTRAINT "cardapio_busque_torres_beneficios_cardapio_empresa_id_fkey" FOREIGN KEY (cardapio_empresa_id) REFERENCES cardapio_empresas(id) ON DELETE CASCADE;
ALTER TABLE public."cardapio_busque_torres_beneficios" ADD CONSTRAINT "cardapio_busque_torres_beneficios_convite_id_fkey" FOREIGN KEY (convite_id) REFERENCES convites_cortesia_cadastro(id) ON DELETE RESTRICT;
ALTER TABLE public."cardapio_busque_torres_beneficios" ADD CONSTRAINT "cardapio_busque_torres_beneficios_busque_empresa_id_fkey" FOREIGN KEY (busque_empresa_id) REFERENCES empresas(id) ON DELETE SET NULL;
ALTER TABLE public."cardapio_comercial_compras" ADD CONSTRAINT "cardapio_comercial_compras_cardapio_empresa_id_fkey" FOREIGN KEY (cardapio_empresa_id) REFERENCES cardapio_empresas(id) ON DELETE CASCADE;
ALTER TABLE public."cardapio_comercial_compras" ADD CONSTRAINT "cardapio_comercial_compras_codigo_produto_fkey" FOREIGN KEY (codigo_produto) REFERENCES cardapio_comercial_catalogo(codigo) ON DELETE RESTRICT;
ALTER TABLE public."cardapio_comercial_compras" ADD CONSTRAINT "cardapio_comercial_compras_produto_oferta_id_fkey" FOREIGN KEY (produto_oferta_id) REFERENCES cardapio_produtos(id) ON DELETE SET NULL;
CREATE INDEX crm_tarefas_cidade_status_venc_idx ON public.crm_tarefas USING btree (cidade_id, status, vencimento);
CREATE INDEX crm_tarefas_lead_idx ON public.crm_tarefas USING btree (lead_id);
CREATE INDEX crm_atividades_cidade_data_idx ON public.crm_atividades USING btree (cidade_id, created_at DESC);
CREATE INDEX crm_atividades_lead_data_idx ON public.crm_atividades USING btree (lead_id, created_at DESC);
CREATE INDEX crm_leads_cidade_idx ON public.crm_leads USING btree (cidade_id);
CREATE INDEX crm_leads_status_idx ON public.crm_leads USING btree (cidade_id, status);
CREATE INDEX crm_leads_retorno_idx ON public.crm_leads USING btree (cidade_id, proximo_contato);
CREATE INDEX crm_leads_cidade_status_idx ON public.crm_leads USING btree (cidade_id, status);
CREATE INDEX crm_leads_responsavel_idx ON public.crm_leads USING btree (responsavel_id);
CREATE INDEX crm_leads_proximo_contato_idx ON public.crm_leads USING btree (cidade_id, proximo_contato);
CREATE UNIQUE INDEX cardapio_busque_torres_beneficios_chave_negocio_uidx ON public.cardapio_busque_torres_beneficios USING btree (chave_negocio) WHERE (chave_negocio IS NOT NULL);
CREATE INDEX inteligencia_buscas_cidade_data_idx ON public.inteligencia_buscas USING btree (cidade_id, created_at DESC);
CREATE INDEX inteligencia_buscas_cidade_termo_idx ON public.inteligencia_buscas USING btree (cidade_id, termo_normalizado, created_at DESC);
CREATE INDEX inteligencia_buscas_cidade_nicho_data_idx ON public.inteligencia_buscas USING btree (cidade_id, nicho, created_at DESC);
CREATE INDEX aceites_contrato_empresa_idx ON public.aceites_contrato USING btree (empresa_id, aceite_em DESC);
CREATE INDEX aceites_contrato_pagamento_idx ON public.aceites_contrato USING btree (pagamento_id);
CREATE INDEX public_edge_rate_limits_route_ip_created_idx ON public.public_edge_rate_limits USING btree (route, ip_hash, created_at DESC);
CREATE INDEX idx_metricas_promocao_dia_cidade_data ON public.metricas_promocao_dia USING btree (cidade_id, created_at DESC);
CREATE INDEX finance_contas_cidade_idx ON public.finance_contas USING btree (cidade_id, ativa);
CREATE UNIQUE INDEX finance_contas_nome_uq ON public.finance_contas USING btree (cidade_id, lower(TRIM(BOTH FROM nome))) WHERE (ativa = true);
CREATE INDEX vagas_status_idx ON public.vagas USING btree (status);
CREATE INDEX vagas_pendentes_idx ON public.vagas USING btree (created_at DESC) WHERE (status = 'pendente'::text);
CREATE INDEX vagas_expira_idx ON public.vagas USING btree (expira_em);
CREATE INDEX vagas_empresa_idx ON public.vagas USING btree (empresa_id);
CREATE INDEX vagas_cargo_trgm_idx ON public.vagas USING gin (lower(cargo) gin_trgm_ops);
CREATE INDEX vagas_cidade_status_idx ON public.vagas USING btree (cidade_id, status, created_at DESC);
CREATE UNIQUE INDEX empresas_codigo_renovacao_uidx ON public.empresas USING btree (codigo_renovacao);
CREATE INDEX empresas_data_vencimento_idx ON public.empresas USING btree (data_vencimento);
CREATE INDEX empresas_status_idx ON public.empresas USING btree (status);
CREATE INDEX empresas_pendentes_idx ON public.empresas USING btree (created_at DESC) WHERE (status = 'pendente'::text);
CREATE INDEX empresas_plano_idx ON public.empresas USING btree (plano);
CREATE INDEX empresas_vencimento_idx ON public.empresas USING btree (data_vencimento);
CREATE INDEX empresas_categoria_idx ON public.empresas USING btree (categoria, subcategoria);
CREATE INDEX empresas_busca_trgm_idx ON public.empresas USING gin (busca_texto gin_trgm_ops);
CREATE INDEX empresas_cidade_status_idx ON public.empresas USING btree (cidade_id, status, created_at DESC);
CREATE INDEX empresas_arquivadas_cidade_idx ON public.empresas USING btree (cidade_id, arquivado_em DESC) WHERE (status = 'arquivado'::text);
CREATE UNIQUE INDEX empresas_cidade_slug_unique_idx ON public.empresas USING btree (cidade_id, lower(slug)) WHERE (slug IS NOT NULL);
CREATE INDEX promocoes_status_idx ON public.promocoes USING btree (status);
CREATE INDEX promocoes_expira_idx ON public.promocoes USING btree (expira_em);
CREATE INDEX promocoes_empresa_idx ON public.promocoes USING btree (empresa_id);
CREATE UNIQUE INDEX promocoes_codigo_checkout_uidx ON public.promocoes USING btree (codigo_checkout);
CREATE INDEX idx_promocoes_data_exibicao_capacidade ON public.promocoes USING btree (cidade_id, data_exibicao, status, reserva_expira_em);
CREATE UNIQUE INDEX finance_categorias_nome_uq ON public.finance_categorias USING btree (cidade_id, lower(TRIM(BOTH FROM nome)), tipo) WHERE (ativa = true);
CREATE INDEX finance_categorias_cidade_idx ON public.finance_categorias USING btree (cidade_id, tipo, ativa);
CREATE INDEX metricas_eventos_evento_data_idx ON public.metricas_eventos USING btree (evento, created_at DESC);
CREATE INDEX metricas_eventos_empresa_data_idx ON public.metricas_eventos USING btree (empresa_id, evento, created_at DESC) WHERE (empresa_id IS NOT NULL);
CREATE INDEX metricas_eventos_cidade_idx ON public.metricas_eventos USING btree (cidade_id, evento, created_at DESC);
CREATE INDEX curtidas_empresas_empresa_idx ON public.curtidas_empresas USING btree (empresa_id);
CREATE INDEX curtidas_empresas_data_idx ON public.curtidas_empresas USING btree (created_at DESC);
CREATE INDEX banners_site_cidade_idx ON public.banners_site USING btree (cidade_id, ativo, tipo, created_at DESC);
CREATE INDEX agenda_premium_empresa_idx ON public.agenda_premium USING btree (empresa_id);
CREATE INDEX agenda_premium_datas_idx ON public.agenda_premium USING btree (data_inicio, data_fim);
CREATE INDEX agenda_premium_tipo_status_idx ON public.agenda_premium USING btree (tipo, status);
CREATE INDEX agenda_premium_cidade_data_idx ON public.agenda_premium USING btree (cidade_id, data_inicio, data_fim);
CREATE INDEX admin_sessoes_user_id_idx ON public.admin_sessoes USING btree (user_id);
CREATE INDEX admin_sessoes_iniciado_em_idx ON public.admin_sessoes USING btree (iniciado_em DESC);
CREATE INDEX admin_sessoes_ultima_atividade_idx ON public.admin_sessoes USING btree (ultima_atividade_em DESC);
CREATE INDEX admin_atividades_user_id_idx ON public.admin_atividades USING btree (user_id);
CREATE INDEX admin_atividades_sessao_idx ON public.admin_atividades USING btree (sessao_id);
CREATE INDEX admin_atividades_created_at_idx ON public.admin_atividades USING btree (created_at DESC);
CREATE INDEX admin_atividades_entidade_idx ON public.admin_atividades USING btree (entidade, entidade_id);
CREATE INDEX pagamentos_empresa_idx ON public.pagamentos USING btree (empresa_id, created_at DESC);
CREATE INDEX pagamentos_status_idx ON public.pagamentos USING btree (status, created_at DESC);
CREATE INDEX pagamentos_preference_idx ON public.pagamentos USING btree (mercado_pago_preference_id) WHERE (mercado_pago_preference_id IS NOT NULL);
CREATE INDEX pagamentos_cidade_idx ON public.pagamentos USING btree (cidade_id, created_at DESC);
CREATE INDEX pagamentos_aceite_contrato_idx ON public.pagamentos USING btree (aceite_contrato_id);
CREATE UNIQUE INDEX metricas_vagas_unica_por_dia ON public.metricas_vagas USING btree (vaga_id, sessao_hash, dia);
CREATE INDEX metricas_vagas_posicao_idx ON public.metricas_vagas USING btree (posicao_lista, created_at DESC);
CREATE INDEX metricas_vagas_vaga_idx ON public.metricas_vagas USING btree (vaga_id, created_at DESC);
CREATE UNIQUE INDEX finance_centros_nome_uq ON public.finance_centros_custo USING btree (cidade_id, lower(TRIM(BOTH FROM nome))) WHERE (ativo = true);
CREATE INDEX finance_centros_cidade_idx ON public.finance_centros_custo USING btree (cidade_id, ativo);
CREATE INDEX finance_parceiros_cidade_idx ON public.finance_parceiros USING btree (cidade_id, tipo, ativo);
CREATE INDEX finance_recorrencias_cidade_idx ON public.finance_recorrencias USING btree (cidade_id, ativa, proxima_geracao);
CREATE INDEX finance_lancamentos_cidade_idx ON public.finance_lancamentos USING btree (cidade_id, competencia DESC);
CREATE INDEX finance_lancamentos_vencimento_idx ON public.finance_lancamentos USING btree (cidade_id, status, vencimento);
CREATE INDEX finance_lancamentos_tipo_idx ON public.finance_lancamentos USING btree (cidade_id, tipo, status, pago_em);
CREATE UNIQUE INDEX finance_lancamentos_recorrencia_uq ON public.finance_lancamentos USING btree (recorrencia_id, vencimento) WHERE (recorrencia_id IS NOT NULL);
CREATE UNIQUE INDEX finance_orcamentos_uq ON public.finance_orcamentos USING btree (cidade_id, ano, mes, tipo, categoria_id, COALESCE(centro_custo_id, '00000000-0000-0000-0000-000000000000'::uuid));
CREATE INDEX finance_orcamentos_periodo_idx ON public.finance_orcamentos USING btree (cidade_id, ano, mes);
CREATE UNIQUE INDEX finance_extratos_hash_uq ON public.finance_extratos USING btree (cidade_id, conta_id, hash_importacao) WHERE (hash_importacao IS NOT NULL);
CREATE INDEX finance_extratos_cidade_idx ON public.finance_extratos USING btree (cidade_id, conta_id, data_movimento DESC);
CREATE INDEX finance_extratos_conciliado_idx ON public.finance_extratos USING btree (cidade_id, conciliado, data_movimento DESC);
CREATE INDEX finance_ativos_cidade_idx ON public.finance_ativos USING btree (cidade_id, status);
CREATE INDEX beneficios_foguinho_usos_empresa_comp_idx ON public.beneficios_foguinho_usos USING btree (empresa_id, competencia, created_at);
CREATE INDEX metricas_rate_limits_bucket_idx ON public.metricas_rate_limits USING btree (bucket_start);
CREATE INDEX cardapio_pedidos_empresa_created_idx ON public.cardapio_pedidos USING btree (cardapio_empresa_id, created_at DESC);
CREATE INDEX cardapio_produtos_empresa_idx ON public.cardapio_produtos USING btree (cardapio_empresa_id, ordem, created_at);
CREATE INDEX cardapio_webhook_eventos_resource_idx ON public.cardapio_webhook_eventos USING btree (provider, resource_id);
CREATE INDEX cardapio_webhook_eventos_pedido_idx ON public.cardapio_webhook_eventos USING btree (pedido_id);
CREATE INDEX cardapio_pagamentos_provider_id_idx ON public.cardapio_pagamentos USING btree (provider, provider_payment_id);
CREATE INDEX cardapio_pagamentos_provider_order_idx ON public.cardapio_pagamentos USING btree (provider, provider_order_id);
CREATE UNIQUE INDEX cardapio_pagamentos_provider_payment_uidx ON public.cardapio_pagamentos USING btree (provider, provider_payment_id) WHERE (provider_payment_id IS NOT NULL);
CREATE UNIQUE INDEX cardapio_pagamentos_provider_preference_uidx ON public.cardapio_pagamentos USING btree (provider, provider_preference_id) WHERE (provider_preference_id IS NOT NULL);
CREATE UNIQUE INDEX cardapio_pagamentos_banco_txid_uidx ON public.cardapio_pagamentos USING btree (banco_codigo, pix_txid) WHERE ((banco_codigo IS NOT NULL) AND (pix_txid IS NOT NULL));
CREATE INDEX cardapio_produto_opcoes_grupo_idx ON public.cardapio_produto_opcoes USING btree (grupo_id, ordem, created_at);
CREATE INDEX cardapio_produto_grupos_produto_idx ON public.cardapio_produto_grupos USING btree (produto_id, ordem, created_at);
CREATE UNIQUE INDEX cardapio_creditos_recargas_provider_payment_uidx ON public.cardapio_creditos_recargas USING btree (provider_payment_id) WHERE (provider_payment_id IS NOT NULL);
CREATE INDEX cardapio_creditos_recargas_empresa_created_idx ON public.cardapio_creditos_recargas USING btree (cardapio_empresa_id, created_at DESC);
CREATE INDEX cardapio_creditos_reservas_empresa_status_idx ON public.cardapio_creditos_reservas USING btree (cardapio_empresa_id, status, expira_em);
CREATE UNIQUE INDEX cardapio_creditos_movimentos_consumo_pedido_uidx ON public.cardapio_creditos_movimentos USING btree (pedido_id) WHERE ((tipo = 'consumo'::text) AND (pedido_id IS NOT NULL));
CREATE INDEX cardapio_creditos_movimentos_empresa_created_idx ON public.cardapio_creditos_movimentos USING btree (cardapio_empresa_id, created_at DESC);
CREATE INDEX cardapio_banco_conexoes_status_idx ON public.cardapio_banco_conexoes USING btree (status, banco_codigo);
CREATE INDEX idx_cardapio_entrega_quotes_empresa_expira ON public.cardapio_entrega_quotes USING btree (cardapio_empresa_id, expires_at DESC);
CREATE INDEX idx_cardapio_visitas_sessoes_dia ON public.cardapio_visitas_sessoes USING btree (dia);
CREATE INDEX cardapio_comercial_compras_empresa_idx ON public.cardapio_comercial_compras USING btree (cardapio_empresa_id, created_at DESC);
CREATE INDEX cardapio_comercial_compras_status_idx ON public.cardapio_comercial_compras USING btree (status, fim_em, reserva_expira_em);
CREATE INDEX agenda_premium_historico_empresa_idx ON public.agenda_premium_historico USING btree (empresa_id, data_inicio DESC);
CREATE INDEX clima_acessos_cidade_created_idx ON public.clima_acessos USING btree (cidade_id, created_at DESC);
REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM PUBLIC, anon, authenticated;
GRANT ALL ON ALL TABLES IN SCHEMA public TO service_role;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO service_role;