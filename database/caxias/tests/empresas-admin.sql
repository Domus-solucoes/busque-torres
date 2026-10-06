BEGIN;
SELECT set_config('request.jwt.claim.sub',(SELECT user_id::text FROM public.administradores WHERE papel='dono' AND ativo LIMIT 1),true);
SET LOCAL ROLE authenticated;
DO $$
DECLARE v_id uuid; v_count integer;
BEGIN
  INSERT INTO public.empresas(nome,categoria,subcategoria,descricao,whatsapp,cidade)
  VALUES ('Teste controlado Caxias','Serviços','Teste','Empresa temporária para testar o cadastro.','54999999999','Caxias do Sul') RETURNING id INTO v_id;
  PERFORM set_config('caxias.test_empresa',v_id::text,true);
  UPDATE public.empresas SET nome='Teste editado Caxias' WHERE id=v_id;
  SELECT count(*) INTO v_count FROM public.empresas WHERE id=v_id AND nome='Teste editado Caxias' AND status='pendente' AND NOT ativo;
  IF v_count<>1 THEN RAISE EXCEPTION 'Cadastro/edição falhou'; END IF;
  BEGIN
    INSERT INTO public.empresas(nome,categoria,subcategoria,descricao,whatsapp,cidade) VALUES ('Teste cidade errada','Serviços','Teste','Teste de restrição de cidade.','54999999999','Torres');
    RAISE EXCEPTION 'Cidade incorreta aceita';
  EXCEPTION WHEN check_violation OR insufficient_privilege THEN NULL; END;
  BEGIN UPDATE public.empresas SET pagamento_confirmado=true WHERE id=v_id; RAISE EXCEPTION 'Pagamento alterável'; EXCEPTION WHEN insufficient_privilege THEN NULL; END;
  BEGIN UPDATE public.empresas SET status='ativo',ativo=true WHERE id=v_id; RAISE EXCEPTION 'Ativação permitida'; EXCEPTION WHEN insufficient_privilege THEN NULL; END;
  BEGIN UPDATE public.empresas SET cidade_id='torres' WHERE id=v_id; RAISE EXCEPTION 'Troca de cidade permitida'; EXCEPTION WHEN insufficient_privilege THEN NULL; END;
  BEGIN DELETE FROM public.empresas WHERE id=v_id; RAISE EXCEPTION 'Exclusão permitida'; EXCEPTION WHEN insufficient_privilege THEN NULL; END;
END;
$$;
RESET ROLE;
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.empresas WHERE id=current_setting('caxias.test_empresa')::uuid AND busca_texto LIKE '%teste editado caxias%' AND NOT pagamento_confirmado AND plano='comum' AND cidade_id='caxias') THEN RAISE EXCEPTION 'Valores internos inesperados'; END IF;
END;
$$;
SELECT set_config('request.jwt.claim.sub','11111111-1111-4111-8111-111111111111',true);
SET LOCAL ROLE authenticated;
DO $$
DECLARE v_count integer;
BEGIN
  SELECT count(id) INTO v_count FROM public.empresas;
  IF v_count<>0 THEN RAISE EXCEPTION 'Usuário comum leu empresas'; END IF;
  UPDATE public.empresas SET nome='Alteração indevida' WHERE id=current_setting('caxias.test_empresa')::uuid;
  GET DIAGNOSTICS v_count=ROW_COUNT;
  IF v_count<>0 THEN RAISE EXCEPTION 'Usuário comum editou empresa'; END IF;
  BEGIN
    INSERT INTO public.empresas(nome,categoria,subcategoria,descricao,whatsapp,cidade) VALUES ('Teste sem autorização','Serviços','Teste','Cadastro sem autorização de administrador.','54999999999','Caxias do Sul');
    RAISE EXCEPTION 'Usuário comum cadastrou';
  EXCEPTION WHEN insufficient_privilege THEN NULL; END;
END;
$$;
RESET ROLE;
SET LOCAL ROLE anon;
DO $$
BEGIN
  BEGIN PERFORM id FROM public.empresas; RAISE EXCEPTION 'Anônimo leu empresas'; EXCEPTION WHEN insufficient_privilege THEN NULL; END;
END;
$$;
RESET ROLE;
ROLLBACK;
SELECT 'testes_empresas_passaram_dados_descartados' AS resultado;
