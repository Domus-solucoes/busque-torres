-- Armazenamento privado exclusivo do projeto Caxias.
INSERT INTO storage.buckets(id,name,public,file_size_limit,allowed_mime_types)
VALUES ('caxias-empresas','caxias-empresas',false,2097152,ARRAY['image/jpeg','image/png','image/webp']);

CREATE FUNCTION caxias_private.midia_empresa_permitida(p_nome text)
RETURNS boolean LANGUAGE sql STABLE SECURITY INVOKER SET search_path = '' AS $$
  SELECT (SELECT public.usuario_e_admin_ativo()) AND EXISTS (
    SELECT 1 FROM public.empresas e
    WHERE e.id = CASE WHEN p_nome ~ '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/(logo|capa)$'
      THEN split_part(p_nome,'/',1)::uuid ELSE NULL END
    AND e.cidade_id='caxias'
  );
$$;
REVOKE ALL ON FUNCTION caxias_private.midia_empresa_permitida(text) FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION caxias_private.midia_empresa_permitida(text) TO authenticated;

CREATE POLICY caxias_midias_leitura ON storage.objects FOR SELECT TO authenticated
USING (bucket_id='caxias-empresas' AND caxias_private.midia_empresa_permitida(name));
CREATE POLICY caxias_midias_envio ON storage.objects FOR INSERT TO authenticated
WITH CHECK (bucket_id='caxias-empresas' AND caxias_private.midia_empresa_permitida(name));
CREATE POLICY caxias_midias_substituicao ON storage.objects FOR UPDATE TO authenticated
USING (bucket_id='caxias-empresas' AND caxias_private.midia_empresa_permitida(name))
WITH CHECK (bucket_id='caxias-empresas' AND caxias_private.midia_empresa_permitida(name));
CREATE POLICY caxias_midias_exclusao ON storage.objects FOR DELETE TO authenticated
USING (bucket_id='caxias-empresas' AND caxias_private.midia_empresa_permitida(name));
