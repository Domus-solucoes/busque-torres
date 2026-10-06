CREATE SCHEMA IF NOT EXISTS caxias_private;
REVOKE ALL ON SCHEMA caxias_private FROM PUBLIC, anon;
GRANT USAGE ON SCHEMA caxias_private TO authenticated;
CREATE FUNCTION caxias_private.admin_ativo() RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $$
SELECT auth.uid() IS NOT NULL AND EXISTS(SELECT 1 FROM public.administradores a WHERE a.user_id=auth.uid() AND a.ativo);
$$;
CREATE FUNCTION caxias_private.admin_dono() RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $$
SELECT auth.uid() IS NOT NULL AND EXISTS(SELECT 1 FROM public.administradores a WHERE a.user_id=auth.uid() AND a.ativo AND a.papel='dono');
$$;
REVOKE ALL ON FUNCTION caxias_private.admin_ativo(),caxias_private.admin_dono() FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION caxias_private.admin_ativo(),caxias_private.admin_dono() TO authenticated;
CREATE FUNCTION public.usuario_e_admin() RETURNS boolean LANGUAGE sql STABLE SECURITY INVOKER SET search_path='' AS $$ SELECT caxias_private.admin_ativo(); $$;
CREATE FUNCTION public.usuario_e_admin_ativo() RETURNS boolean LANGUAGE sql STABLE SECURITY INVOKER SET search_path='' AS $$ SELECT caxias_private.admin_ativo(); $$;
CREATE FUNCTION public.usuario_e_dono() RETURNS boolean LANGUAGE sql STABLE SECURITY INVOKER SET search_path='' AS $$ SELECT caxias_private.admin_dono(); $$;
REVOKE ALL ON FUNCTION public.usuario_e_admin(),public.usuario_e_admin_ativo(),public.usuario_e_dono() FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION public.usuario_e_admin(),public.usuario_e_admin_ativo(),public.usuario_e_dono() TO authenticated;
GRANT SELECT ON public.administradores TO authenticated;
CREATE POLICY admin_le_proprio_perfil ON public.administradores FOR SELECT TO authenticated USING (user_id=(SELECT auth.uid()) AND ativo=true);