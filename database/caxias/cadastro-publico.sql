CREATE TABLE caxias_private.cadastro_limites (
  chave text NOT NULL, janela timestamptz NOT NULL, quantidade integer NOT NULL DEFAULT 0,
  PRIMARY KEY(chave,janela)
);
CREATE TABLE caxias_private.cadastro_tentativas (
  id uuid PRIMARY KEY, criado_em timestamptz NOT NULL DEFAULT now()
);
ALTER TABLE caxias_private.cadastro_limites ENABLE ROW LEVEL SECURITY;
ALTER TABLE caxias_private.cadastro_tentativas ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON caxias_private.cadastro_limites,caxias_private.cadastro_tentativas FROM PUBLIC,anon,authenticated;
GRANT USAGE ON SCHEMA caxias_private TO service_role;
GRANT ALL ON caxias_private.cadastro_limites,caxias_private.cadastro_tentativas TO service_role;
CREATE INDEX empresas_cadastro_publico_dedupe_idx ON public.empresas(cidade_id,whatsapp,lower(nome));

CREATE FUNCTION caxias_private.receber_cadastro(p_dados jsonb,p_ip_hash text,p_tentativa uuid)
RETURNS jsonb LANGUAGE plpgsql SECURITY INVOKER SET search_path='' AS $$
DECLARE
  v_janela timestamptz := date_trunc('hour',now());
  v_quantidade integer;
  v_nome text := btrim(p_dados->>'nome');
  v_whatsapp text := p_dados->>'whatsapp';
BEGIN
  IF p_ip_hash !~ '^[0-9a-f]{64}$' OR p_tentativa IS NULL THEN RAISE EXCEPTION 'Identificador inválido'; END IF;
  IF p_dados->>'aceite' IS DISTINCT FROM 'true' THEN RAISE EXCEPTION 'Aceite obrigatório'; END IF;
  IF char_length(v_nome) NOT BETWEEN 3 AND 100 OR v_nome IS NULL OR v_whatsapp IS NULL
    OR v_whatsapp !~ '^[0-9]{10,15}$' THEN RAISE EXCEPTION 'Dados inválidos'; END IF;
  PERFORM pg_advisory_xact_lock(hashtextextended('caxias-cadastro-global',0));
  IF EXISTS(SELECT 1 FROM caxias_private.cadastro_tentativas WHERE id=p_tentativa) THEN RETURN '{"ok":true}'::jsonb; END IF;
  DELETE FROM caxias_private.cadastro_limites WHERE janela < now()-interval '1 day';
  DELETE FROM caxias_private.cadastro_tentativas WHERE criado_em < now()-interval '2 days';
  INSERT INTO caxias_private.cadastro_limites(chave,janela,quantidade) VALUES('global',v_janela,1)
  ON CONFLICT(chave,janela) DO UPDATE SET quantidade=caxias_private.cadastro_limites.quantidade+1 RETURNING quantidade INTO v_quantidade;
  IF v_quantidade>60 THEN RETURN '{"limite":true}'::jsonb; END IF;
  INSERT INTO caxias_private.cadastro_limites(chave,janela,quantidade) VALUES(p_ip_hash,v_janela,1)
  ON CONFLICT(chave,janela) DO UPDATE SET quantidade=caxias_private.cadastro_limites.quantidade+1 RETURNING quantidade INTO v_quantidade;
  IF v_quantidade>10 THEN RETURN '{"limite":true}'::jsonb; END IF;
  INSERT INTO caxias_private.cadastro_tentativas(id) VALUES(p_tentativa);
  IF EXISTS(SELECT 1 FROM public.empresas WHERE cidade_id='caxias' AND whatsapp=v_whatsapp AND lower(nome)=lower(v_nome)) THEN RETURN '{"ok":true}'::jsonb; END IF;
  INSERT INTO public.empresas(nome,categoria,subcategoria,descricao,whatsapp,email,instagram,site,cidade,bairro,endereco,horario,produtos,servicos,palavras_chave,cidade_id,origem,status,ativo,pagamento_confirmado,plano,plano_solicitado,termos_aceitos_em)
  VALUES(v_nome,btrim(p_dados->>'categoria'),btrim(p_dados->>'subcategoria'),btrim(p_dados->>'descricao'),v_whatsapp,
    nullif(btrim(p_dados->>'email'),''),nullif(btrim(p_dados->>'instagram'),''),nullif(btrim(p_dados->>'site'),''),'Caxias do Sul',
    nullif(btrim(p_dados->>'bairro'),''),nullif(btrim(p_dados->>'endereco'),''),nullif(btrim(p_dados->>'horario'),''),
    nullif(btrim(p_dados->>'produtos'),''),nullif(btrim(p_dados->>'servicos'),''),nullif(btrim(p_dados->>'palavras_chave'),''),
    'caxias','formulario_publico_caxias','pendente',false,false,'comum','comum',now());
  RETURN '{"ok":true}'::jsonb;
END;
$$;
REVOKE ALL ON FUNCTION caxias_private.receber_cadastro(jsonb,text,uuid) FROM PUBLIC,anon,authenticated;
GRANT EXECUTE ON FUNCTION caxias_private.receber_cadastro(jsonb,text,uuid) TO service_role;

CREATE FUNCTION public.caxias_receber_cadastro(p_dados jsonb,p_ip_hash text,p_tentativa uuid)
RETURNS jsonb LANGUAGE sql SECURITY INVOKER SET search_path='' AS $$
  SELECT caxias_private.receber_cadastro(p_dados,p_ip_hash,p_tentativa);
$$;
REVOKE ALL ON FUNCTION public.caxias_receber_cadastro(jsonb,text,uuid) FROM PUBLIC,anon,authenticated;
GRANT EXECUTE ON FUNCTION public.caxias_receber_cadastro(jsonb,text,uuid) TO service_role;
