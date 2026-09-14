import fs from 'node:fs/promises';
import path from 'node:path';
import process from 'node:process';

const ROOT = process.cwd();
const EMPRESAS_DIR = path.join(ROOT, 'empresa');
const SITEMAP_PATH = path.join(ROOT, 'sitemap.xml');
const MARKER = '<!-- BUSQUE SEO AUTO-GERADO -->';
const SITE_ORIGIN = (process.env.SITE_ORIGIN || 'https://busquetorres.com.br').replace(/\/$/, '');
const CIDADE_ID = process.env.CIDADE_ID || 'torres';
const SUPABASE_URL = (process.env.SUPABASE_URL || 'https://xwkmsqawiimouilldwit.supabase.co').replace(/\/$/, '');
const SUPABASE_KEY = process.env.SUPABASE_PUBLISHABLE_KEY || 'sb_publishable_yDaiyt-jns7xIhSd5MHrrQ_jcSi_r_s';

function esc(value = '') {
  return String(value ?? '')
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&#39;');
}

function text(value = '') {
  return String(value ?? '').replace(/\s+/g, ' ').trim();
}

function safeUrl(value = '') {
  const v = text(value);
  if (!v) return '';
  try {
    const u = new URL(v);
    return ['http:', 'https:'].includes(u.protocol) ? u.href : '';
  } catch {
    return '';
  }
}

function metaDescription(company) {
  const base = text(company.descricao) ||
    `${text(company.nome)} em Torres RS. Veja serviços, endereço, horário e formas de contato no Busque Torres.`;
  if (base.length <= 158) return base;
  return `${base.slice(0, 155).replace(/[\s,.;:!?-]+$/,'')}...`;
}

function whatsappUrl(raw, companyName) {
  let digits = String(raw ?? '').replace(/\D/g, '');
  if (!digits) return '';
  if (!digits.startsWith('55')) digits = `55${digits}`;
  const msg = encodeURIComponent(`Olá, encontrei ${text(companyName)} no Busque Torres.`);
  return `https://wa.me/${digits}?text=${msg}`;
}

function tel(raw) {
  let digits = String(raw ?? '').replace(/\D/g, '');
  if (!digits) return '';
  if (!digits.startsWith('55')) digits = `55${digits}`;
  return `+${digits}`;
}

function keywords(company) {
  const src = [company.servicos, company.produtos, company.palavras_chave, company.subcategoria, company.categoria]
    .filter(Boolean)
    .join(',')
    .split(/[,;|\n]+/)
    .map(text)
    .filter(Boolean);
  return [...new Set(src)].slice(0, 8);
}

function schemaJson(company, canonical, cover, logo) {
  const schema = {
    '@context': 'https://schema.org',
    '@type': 'LocalBusiness',
    '@id': `${canonical}#empresa`,
    name: text(company.nome),
    description: metaDescription(company),
    url: canonical,
  };
  const phone = tel(company.whatsapp);
  if (phone) schema.telephone = phone;
  const images = [cover, logo].filter(Boolean);
  if (images.length) schema.image = images;
  if (logo) schema.logo = logo;
  if (company.endereco || company.cidade || company.bairro) {
    schema.address = {
      '@type': 'PostalAddress',
      ...(company.endereco ? { streetAddress: `${text(company.endereco)}${company.bairro ? `, ${text(company.bairro)}` : ''}` } : {}),
      addressLocality: CIDADE_ID === 'torres' ? 'Torres' : (text(company.cidade).replace(/\s*\/?\s*RS$/i, '').trim() || text(company.cidade) || CIDADE_ID),
      addressRegion: 'RS',
      addressCountry: 'BR',
    };
  }
  const sameAs = [safeUrl(company.instagram), safeUrl(company.site)].filter(Boolean);
  if (sameAs.length) schema.sameAs = sameAs;
  const knows = keywords(company);
  if (knows.length) schema.knowsAbout = knows;
  return JSON.stringify(schema).replaceAll('<', '\\u003c').replaceAll('\u2028', '\\u2028').replaceAll('\u2029', '\\u2029');
}

function tagsHtml(company) {
  const tags = keywords(company).slice(0, 6);
  if (!tags.length) return '';
  return `<div class="services" aria-label="Serviços">${tags.map(x => `<span class="tag">${esc(x)}</span>`).join('')}</div>`;
}

function initial(company) {
  return esc(text(company.nome).slice(0, 1).toUpperCase() || 'B');
}

function generateHtml(company) {
  const slug = text(company.slug);
  const canonical = `${SITE_ORIGIN}/empresa/${slug}/`;
  const cover = safeUrl(company.imagem_url);
  const logo = safeUrl(company.logo_url);
  const insta = safeUrl(company.instagram);
  const site = safeUrl(company.site);
  const maps = safeUrl(company.mapa_url);
  const wa = whatsappUrl(company.whatsapp, company.nome);
  const name = text(company.nome);
  const city = CIDADE_ID === 'torres' ? 'Torres' : (text(company.cidade).replace(/\s*\/?\s*RS$/i, '').trim() || text(company.cidade) || CIDADE_ID);
  const title = `${name} em ${city} RS | Busque Torres`;
  const meta = metaDescription(company);
  const category = text(company.subcategoria) || text(company.categoria) || 'Empresa local';
  const desc = text(company.descricao) || `${name} em ${city}/RS. Consulte informações, serviços e formas de contato no Busque Torres.`;
  const localTerms = keywords(company).slice(0, 4).join(', ');

  const actionLinks = [
    wa ? `<a class="btn whats" href="${esc(wa)}" target="_blank" rel="noopener">Falar no WhatsApp</a>` : '',
    maps ? `<a class="btn gold" href="${esc(maps)}" target="_blank" rel="noopener">Como chegar</a>` : '',
    insta ? `<a class="btn outline" href="${esc(insta)}" target="_blank" rel="noopener">Instagram</a>` : '',
    site ? `<a class="btn outline" href="${esc(site)}" target="_blank" rel="noopener">Site</a>` : '',
  ].filter(Boolean).join('');

  const heroMedia = cover
    ? `<img src="${esc(cover)}" alt="${esc(name)} em ${esc(city)} RS" width="1200" height="630" fetchpriority="high">`
    : `<div class="hero-fallback" aria-hidden="true">${initial(company)}</div>`;
  const logoMedia = logo
    ? `<img class="logo" src="${esc(logo)}" alt="Logo ${esc(name)}" width="104" height="104">`
    : `<div class="logo logo-fallback" aria-hidden="true">${initial(company)}</div>`;

  const info = [
    company.endereco ? `<div class="info-item"><span class="label">Endereço</span><span class="value">${esc(text(company.endereco))}${company.bairro ? `<br>${esc(text(company.bairro))}` : ''} · ${esc(city)}/RS</span></div>` : '',
    company.horario ? `<div class="info-item"><span class="label">Horário</span><span class="value">${esc(text(company.horario))}</span></div>` : '',
    (company.servicos || company.produtos) ? `<div class="info-item"><span class="label">Atendimento</span><span class="value">${esc(text(company.servicos || company.produtos))}</span></div>` : '',
  ].filter(Boolean).join('');

  return `<!doctype html>
<html lang="pt-BR">
<head>
  ${MARKER}
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>${esc(title)}</title>
  <meta name="description" content="${esc(meta)}">
  <meta name="robots" content="index,follow,max-image-preview:large">
  <meta name="theme-color" content="#081b33">
  <link rel="canonical" href="${esc(canonical)}">
  <link rel="preconnect" href="https://xwkmsqawiimouilldwit.supabase.co" crossorigin>
  <meta property="og:type" content="website">
  <meta property="og:locale" content="pt_BR">
  <meta property="og:site_name" content="Busque Torres">
  <meta property="og:title" content="${esc(`${name} em ${city} RS`)}">
  <meta property="og:description" content="${esc(meta)}">
  <meta property="og:url" content="${esc(canonical)}">
  ${cover ? `<meta property="og:image" content="${esc(cover)}">` : ''}
  <meta name="twitter:card" content="summary_large_image">
  <script type="application/ld+json">${schemaJson(company, canonical, cover, logo)}</script>
  <script async src="https://www.googletagmanager.com/gtag/js?id=G-12944C67MW"></script>
  <script>window.dataLayer=window.dataLayer||[];function gtag(){dataLayer.push(arguments)}gtag('js',new Date());gtag('config','G-12944C67MW',{page_location:window.location.origin+window.location.pathname});</script>
  <style>
    :root{--navy:#081b33;--navy2:#102d4f;--gold:#e6b84b;--gold2:#f3d184;--bg:#f5f7fb;--surface:#fff;--text:#172033;--muted:#667085;--line:#e6eaf0;--green:#20bf6b;--shadow:0 16px 40px rgba(8,27,51,.10);--max:1040px}*{box-sizing:border-box}html{scroll-behavior:smooth}body{margin:0;background:var(--bg);color:var(--text);font-family:Inter,"Segoe UI",Arial,sans-serif}a{color:inherit}.shell{width:min(var(--max),calc(100% - 30px));margin:auto}.top{background:var(--navy);color:#fff;padding:16px 0}.nav{display:flex;align-items:center;justify-content:space-between;gap:16px}.brand{text-decoration:none;font-weight:950;letter-spacing:-.02em}.brand b{color:var(--gold2)}.back{text-decoration:none;border:1px solid rgba(255,255,255,.22);border-radius:999px;padding:10px 15px;font-size:.9rem;font-weight:850}.hero{position:relative;height:390px;overflow:hidden;background:linear-gradient(135deg,#06162b,#153d68)}.hero>img{width:100%;height:100%;object-fit:cover;display:block}.hero:after{content:"";position:absolute;inset:0;background:linear-gradient(180deg,rgba(8,27,51,.05),rgba(8,27,51,.72))}.hero-fallback{height:100%;display:grid;place-items:center;color:rgba(255,255,255,.18);font-size:11rem;font-weight:950}.identity{position:relative;margin-top:-74px;z-index:3}.card{background:#fff;border:1px solid var(--line);border-radius:26px;box-shadow:var(--shadow);padding:28px}.identity-row{display:flex;align-items:center;gap:20px}.logo{width:104px;height:104px;border-radius:24px;border:5px solid #fff;background:#fff;box-shadow:0 10px 30px rgba(8,27,51,.2);object-fit:contain}.logo-fallback{display:grid;place-items:center;background:var(--navy);color:var(--gold2);font-size:2.4rem;font-weight:950}.eyebrow{display:inline-block;margin-bottom:7px;padding:6px 10px;border-radius:999px;background:#fff5d9;color:#755400;font-size:.74rem;font-weight:950;text-transform:uppercase}h1{margin:0;color:var(--navy);font-size:clamp(1.9rem,5vw,3rem);line-height:1.05;letter-spacing:-.045em}.subtitle{margin:9px 0 0;color:var(--muted);font-weight:700}.actions{display:flex;flex-wrap:wrap;gap:10px;margin-top:22px}.btn{display:inline-flex;align-items:center;justify-content:center;min-height:46px;padding:12px 18px;border-radius:13px;text-decoration:none;font-weight:900}.whats{background:var(--green);color:#fff}.gold{background:linear-gradient(135deg,var(--gold2),var(--gold));color:var(--navy)}.outline{border:1px solid var(--line);color:var(--navy);background:#fff}main{padding:28px 0 60px}.grid{display:grid;grid-template-columns:1.35fr .65fr;gap:22px}.section{background:#fff;border:1px solid var(--line);border-radius:22px;padding:24px;box-shadow:0 7px 22px rgba(8,27,51,.045)}h2{margin:0 0 14px;color:var(--navy);font-size:1.35rem;letter-spacing:-.025em}p{line-height:1.7}.desc{margin:0;color:#4d5b70}.info{display:grid;gap:14px}.info-item{padding-bottom:14px;border-bottom:1px solid var(--line)}.info-item:last-child{border-bottom:0;padding-bottom:0}.label{display:block;margin-bottom:4px;color:var(--muted);font-size:.76rem;font-weight:900;text-transform:uppercase;letter-spacing:.04em}.value{font-weight:800;color:var(--navy);line-height:1.45}.services{display:flex;flex-wrap:wrap;gap:9px;margin-top:14px}.tag{padding:8px 11px;border-radius:10px;background:#f2f5f8;color:#445269;font-size:.84rem;font-weight:850}.local{margin-top:22px}footer{background:var(--navy);color:#d7e0ea;padding:28px 0;text-align:center;font-size:.9rem}footer strong{color:#fff}footer a{color:var(--gold2)}@media(max-width:760px){.hero{height:280px}.identity{margin-top:-48px}.card{padding:20px}.identity-row{align-items:flex-start}.logo{width:82px;height:82px;border-radius:20px}.grid{grid-template-columns:1fr}.actions .btn{flex:1 1 100%}}
  </style>
</head>
<body>
  <header class="top"><div class="shell nav"><a class="brand" href="/">Busque <b>Torres</b></a><a class="back" href="/">← Voltar para o Busque Torres</a></div></header>
  <section class="hero" aria-label="${esc(name)}">${heroMedia}</section>
  <section class="shell identity"><div class="card"><div class="identity-row">${logoMedia}<div><span class="eyebrow">${esc(category)} · ${esc(city)}/RS</span><h1>${esc(name)}</h1><p class="subtitle">${esc(text(company.produtos || company.servicos || category))}</p></div></div>${actionLinks ? `<div class="actions">${actionLinks}</div>` : ''}</div></section>
  <main class="shell"><div class="grid"><section class="section"><h2>Sobre</h2><p class="desc">${esc(desc)}</p>${tagsHtml(company)}</section><aside class="section"><h2>Informações</h2><div class="info">${info || '<div class="info-item"><span class="value">Consulte os canais de contato disponíveis.</span></div>'}</div></aside></div><section class="section local"><h2>${esc(`${category} em ${city} RS`)}</h2><p class="desc">Encontre ${esc(name)} no Busque Torres. ${localTerms ? `Serviços e termos relacionados: ${esc(localTerms)}.` : ''} Consulte endereço, horário e canais de contato atualizados.</p></section></main>
  <footer><div class="shell"><strong>Busque Torres</strong> · Tudo o que você procura em um só lugar.<br><a href="/">busquetorres.com.br</a></div></footer>
</body>
</html>\n`;
}

async function getCompanies() {
  if (process.env.SEO_DATA_FILE) {
    const raw = await fs.readFile(process.env.SEO_DATA_FILE, 'utf8');
    return JSON.parse(raw);
  }
  const response = await fetch(`${SUPABASE_URL}/rest/v1/rpc/empresas_seo_publicas`, {
    method: 'POST',
    headers: {
      apikey: SUPABASE_KEY,
      Authorization: `Bearer ${SUPABASE_KEY}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ p_cidade_id: CIDADE_ID }),
  });
  const raw = await response.text();
  if (!response.ok) throw new Error(`Supabase respondeu ${response.status}: ${raw}`);
  const data = raw ? JSON.parse(raw) : [];
  if (!Array.isArray(data)) throw new Error('A função empresas_seo_publicas não retornou uma lista.');
  return data;
}

function validSlug(slug) {
  return /^[a-z0-9]+(?:-[a-z0-9]+)*$/.test(text(slug));
}

function lastmod(company) {
  const d = new Date(company.updated_at || Date.now());
  if (Number.isNaN(d.getTime())) return new Date().toISOString().slice(0, 10);
  return d.toISOString().slice(0, 10);
}

async function updateSitemap(companies) {
  let sitemap = await fs.readFile(SITEMAP_PATH, 'utf8');
  const blocks = sitemap.match(/\s*<url>[\s\S]*?<\/url>/g) || [];
  const fixed = blocks.filter(block => {
    const loc = block.match(/<loc>(.*?)<\/loc>/)?.[1] || '';
    return !loc.startsWith(`${SITE_ORIGIN}/empresa/`);
  });
  const dynamic = companies.map(company => `\n  <url>\n    <loc>${SITE_ORIGIN}/empresa/${company.slug}/</loc>\n    <lastmod>${lastmod(company)}</lastmod>\n    <changefreq>monthly</changefreq>\n    <priority>0.8</priority>\n  </url>`);
  const out = `<?xml version="1.0" encoding="UTF-8"?>\n<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">${fixed.join('')}${dynamic.join('')}\n</urlset>\n`;
  await fs.writeFile(SITEMAP_PATH, out, 'utf8');
}

async function removeStale(activeSlugs) {
  await fs.mkdir(EMPRESAS_DIR, { recursive: true });
  const entries = await fs.readdir(EMPRESAS_DIR, { withFileTypes: true });
  for (const entry of entries) {
    if (!entry.isDirectory() || activeSlugs.has(entry.name)) continue;
    const indexPath = path.join(EMPRESAS_DIR, entry.name, 'index.html');
    try {
      const current = await fs.readFile(indexPath, 'utf8');
      if (current.includes(MARKER)) {
        await fs.rm(path.join(EMPRESAS_DIR, entry.name), { recursive: true, force: true });
        console.log(`Removida página SEO inativa: ${entry.name}`);
      }
    } catch {}
  }
}

const companies = (await getCompanies())
  .filter(c => c && c.nome && validSlug(c.slug))
  .sort((a, b) => text(a.nome).localeCompare(text(b.nome), 'pt-BR'));

if (!companies.length) throw new Error('Nenhuma empresa pública elegível foi encontrada; geração abortada para proteger o sitemap atual.');

await fs.mkdir(EMPRESAS_DIR, { recursive: true });
const activeSlugs = new Set(companies.map(c => c.slug));
await removeStale(activeSlugs);

for (const company of companies) {
  const dir = path.join(EMPRESAS_DIR, company.slug);
  const indexPath = path.join(dir, 'index.html');
  await fs.mkdir(dir, { recursive: true });
  try {
    const current = await fs.readFile(indexPath, 'utf8');
    if (!current.includes(MARKER)) {
      console.log(`Preservada página manual: ${company.slug}`);
      continue;
    }
  } catch {}
  await fs.writeFile(indexPath, generateHtml(company), 'utf8');
}

await updateSitemap(companies);
console.log(`SEO gerado para ${companies.length} empresas de ${CIDADE_ID}.`);
