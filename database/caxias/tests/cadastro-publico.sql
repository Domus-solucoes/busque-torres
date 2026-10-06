BEGIN;
SET LOCAL ROLE service_role;
DO $$
DECLARE
  v_data jsonb := '{"nome":"TESTE CADASTRO PUBLICO CAXIAS","categoria":"servicos","subcategoria":"Teste","descricao":"Descrição temporária de teste do formulário.","whatsapp":"54999999999","aceite":true,"ativo":true,"pagamento_confirmado":true,"cidade":"Torres"}';
  v_id uuid := gen_random_uuid(); v_result jsonb; v_count integer;
BEGIN
  v_result := public.caxias_receber_cadastro(v_data,repeat('a',64),v_id);
  IF v_result->>'ok' <> 'true' THEN RAISE EXCEPTION 'Cadastro falhou'; END IF;
  PERFORM public.caxias_receber_cadastro(v_data,repeat('a',64),v_id);
  PERFORM public.caxias_receber_cadastro(v_data,repeat('a',64),gen_random_uuid());
  SELECT count(*) INTO v_count FROM public.empresas WHERE nome='TESTE CADASTRO PUBLICO CAXIAS' AND origem='formulario_publico_caxias';
  IF v_count<>1 THEN RAISE EXCEPTION 'Cadastro duplicado'; END IF;
  IF NOT EXISTS(SELECT 1 FROM public.empresas WHERE nome='TESTE CADASTRO PUBLICO CAXIAS' AND cidade_id='caxias' AND cidade='Caxias do Sul' AND status='pendente' AND NOT ativo AND NOT pagamento_confirmado AND plano='comum') THEN RAISE EXCEPTION 'Estado protegido incorreto'; END IF;
  FOR i IN 1..11 LOOP
    v_result := public.caxias_receber_cadastro(v_data||jsonb_build_object('nome','TESTE LIMITE CADASTRO '||i,'whatsapp','549999999'||lpad(i::text,2,'0')),repeat('b',64),gen_random_uuid());
    IF i<=10 AND v_result->>'ok'<>'true' THEN RAISE EXCEPTION 'Limite antecipado'; END IF;
    IF i=11 AND v_result->>'limite'<>'true' THEN RAISE EXCEPTION 'Limite por origem falhou'; END IF;
  END LOOP;
  UPDATE caxias_private.cadastro_limites SET quantidade=60 WHERE chave='global' AND janela=date_trunc('hour',now());
  v_result:=public.caxias_receber_cadastro(v_data||jsonb_build_object('nome','TESTE LIMITE GLOBAL'),repeat('c',64),gen_random_uuid());
  IF v_result->>'limite'<>'true' THEN RAISE EXCEPTION 'Limite global falhou'; END IF;
END;
$$;
RESET ROLE;
SET LOCAL ROLE anon;
DO $$ BEGIN
  BEGIN PERFORM public.caxias_receber_cadastro('{}',repeat('a',64),gen_random_uuid()); RAISE EXCEPTION 'RPC anon liberada'; EXCEPTION WHEN insufficient_privilege THEN NULL; END;
  BEGIN PERFORM id FROM public.empresas; RAISE EXCEPTION 'Leitura anon liberada'; EXCEPTION WHEN insufficient_privilege THEN NULL; END;
END $$;
RESET ROLE;
SET LOCAL ROLE authenticated;
DO $$ BEGIN
  BEGIN PERFORM public.caxias_receber_cadastro('{}',repeat('a',64),gen_random_uuid()); RAISE EXCEPTION 'RPC autenticada liberada'; EXCEPTION WHEN insufficient_privilege THEN NULL; END;
END $$;
RESET ROLE;
ROLLBACK;
SELECT 'cadastro_publico_testes_passaram_dados_descartados' AS resultado;
