-- Exclusivo do projeto Caxias wqfkysoodjyweanhsquk.
INSERT INTO public.cidades(id,nome_sistema,cidade,uf,url_base)
VALUES ('caxias','BUSQUE CAXIAS','Caxias do Sul','RS','https://busque-caxias-rs.martoandre-a-j2.workers.dev')
ON CONFLICT (id) DO NOTHING;

ALTER TABLE public.empresas ADD CONSTRAINT empresas_exclusivas_caxias
CHECK (cidade_id = 'caxias' AND cidade = 'Caxias do Sul');

CREATE FUNCTION caxias_private.empresas_atualizar_busca()
RETURNS trigger LANGUAGE plpgsql SECURITY INVOKER SET search_path = '' AS $$
BEGIN
  NEW.updated_at := now();
  NEW.busca_texto := lower(concat_ws(' ',NEW.nome,NEW.categoria,NEW.subcategoria,NEW.descricao,NEW.produtos,NEW.servicos,NEW.palavras_chave,NEW.bairro));
  RETURN NEW;
END;
$$;
REVOKE ALL ON FUNCTION caxias_private.empresas_atualizar_busca() FROM PUBLIC,anon,authenticated;
CREATE TRIGGER empresas_atualizar_busca BEFORE INSERT OR UPDATE ON public.empresas
FOR EACH ROW EXECUTE FUNCTION caxias_private.empresas_atualizar_busca();

GRANT SELECT(id,nome,categoria,subcategoria,descricao,whatsapp,instagram,site,email,cidade,bairro,endereco,horario,produtos,servicos,palavras_chave,cidade_id,status,ativo,created_at,updated_at)
ON public.empresas TO authenticated;
GRANT INSERT(nome,categoria,subcategoria,descricao,whatsapp,instagram,site,email,cidade,bairro,endereco,horario,produtos,servicos,palavras_chave)
ON public.empresas TO authenticated;
GRANT UPDATE(nome,categoria,subcategoria,descricao,whatsapp,instagram,site,email,bairro,endereco,horario,produtos,servicos,palavras_chave)
ON public.empresas TO authenticated;

CREATE POLICY caxias_admin_empresas_leitura ON public.empresas FOR SELECT TO authenticated
USING (cidade_id='caxias' AND (SELECT public.usuario_e_admin_ativo()));
CREATE POLICY caxias_admin_empresas_cadastro ON public.empresas FOR INSERT TO authenticated
WITH CHECK (cidade_id='caxias' AND cidade='Caxias do Sul' AND status='pendente' AND NOT ativo
  AND NOT pagamento_confirmado AND plano='comum' AND (SELECT public.usuario_e_admin_ativo()));
CREATE POLICY caxias_admin_empresas_edicao ON public.empresas FOR UPDATE TO authenticated
USING (cidade_id='caxias' AND (SELECT public.usuario_e_admin_ativo()))
WITH CHECK (cidade_id='caxias' AND cidade='Caxias do Sul' AND (SELECT public.usuario_e_admin_ativo()));
