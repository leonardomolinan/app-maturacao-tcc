// Mostra os trechos do vídeo por tipo de tela (pelo perfil do título), para achar
// quanto tempo cada tela de resultado ficou aberta.
// Uso: node segments.mjs <dados.json> <tConferir> <tResultado> <tInicio>
import fs from "node:fs";
const [file, tConf, tRes, tHome] = process.argv.slice(2);
const rows = JSON.parse(fs.readFileSync(file, "utf8"));
const near = (t) => rows.reduce((a, r) => (Math.abs(r.t - t) < Math.abs(a.t - t) ? r : a));
const tpl = { CONF: near(+tConf).title, RES: near(+tRes).title, INICIO: near(+tHome).title };
// título sem o fundo: subtrai a mediana do perfil (o fundo da barra muda quando a tela rola)
const norm = (p) => { const s = [...p].sort((a, b) => a - b); const m = s[s.length >> 1]; return p.map((v) => Math.max(0, v - m)); };
for (const k in tpl) tpl[k] = norm(tpl[k]);
const dist = (a, b) => a.reduce((s, v, i) => s + Math.abs(v - b[i]), 0) / a.length;
const kind = (r) => {
  if (r.lum < 90) return "ESCURA";
  const p = norm(r.title);
  let best = "OUTRA", bd = 4;
  for (const k in tpl) { const d = dist(p, tpl[k]); if (d < bd) { bd = d; best = k; } }
  return best;
};
let cur = null, start = 0;
const segs = [];
rows.forEach((r, i) => { const k = kind(r); if (k !== cur) { if (cur) segs.push([cur, start, rows[i - 1].t]); cur = k; start = r.t; } });
segs.push([cur, start, rows[rows.length - 1].t]);
console.log(segs.filter((s) => s[2] - s[1] > 0.3).map((s) => `${s[0]} ${s[1].toFixed(2)}-${s[2].toFixed(2)}`).join("\n"));
