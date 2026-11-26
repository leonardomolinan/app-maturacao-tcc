// Acha as análises nos dados quadro a quadro e mede os tempos.
// Uso: node analyze.mjs <dados.json> <tConferir> <tResultado> [detalhe]
import fs from "node:fs";

const [file, tConf, tRes, detail] = process.argv.slice(2);
const rows = JSON.parse(fs.readFileSync(file, "utf8"));
const near = (t) => rows.reduce((a, r) => (Math.abs(r.t - t) < Math.abs(a.t - t) ? r : a));
const tplConf = near(Number(tConf)).title, tplRes = near(Number(tRes)).title;
const dist = (a, b) => a.reduce((s, v, i) => s + Math.abs(v - b[i]), 0) / a.length;
const isGray = (b) => b[0] > 190 && b[1] > 190 && b[2] > 185;
const isGreen = (b) => b[1] - b[0] > 20 && b[1] < 160;

rows.forEach((r) => { r.dc = dist(r.title, tplConf); r.dr = dist(r.title, tplRes); });

const events = [];
for (let i = 1; i < rows.length; i++) {
  const r = rows[i], p = rows[i - 1];
  // botão passa a cinza (Analisando...) na tela Conferir enquadramento
  if (isGray(r.btn) && !isGray(p.btn) && r.dc < 6) {
    // o círculo do "Mostrar toques" muda um pouco a cor do botão enquanto o dedo está nele:
    // volta pelos quadros com a mesma cor do último quadro antes do cinza
    const c1 = rows[i - 1].btn;
    const dev = (b) => Math.abs(b[0] - c1[0]) + Math.abs(b[1] - c1[1]) + Math.abs(b[2] - c1[2]);
    let k = i - 1;
    while (k > 0 && dev(rows[k - 1].btn) <= 2) k--;
    const tDown = rows[k].t;
    // primeiro quadro, depois do cinza, em que a tela muda fora do botão (início da transição)
    let m = i + 1;
    while (m < rows.length && rows[m].dp < 1.5) m++;
    // primeiro quadro com o título "Resultado" já assentado
    let q = m;
    while (q < rows.length && !(rows[q].dr < 6)) q++;
    events.push({ tDown, tGray: r.t, tTrans: rows[m] ? rows[m].t : null, tTitle: rows[q] ? rows[q].t : null, idx: i });
  }
}

const ms = (x) => Math.round(x * 1000);
console.log("n | toque(s) | cinza(s) | transicao(s) | titulo(s) | toque->transicao ms | cinza->transicao ms | toque->titulo ms");
events.forEach((e, n) => {
  console.log([n + 1, e.tDown.toFixed(3), e.tGray.toFixed(3), e.tTrans?.toFixed(3), e.tTitle?.toFixed(3),
    ms(e.tTrans - e.tDown), ms(e.tTrans - e.tGray), ms(e.tTitle - e.tDown)].join(" | "));
});
if (detail) {
  const e = events[Number(detail) - 1];
  for (let i = e.idx - 25; i < e.idx + 40 && i < rows.length; i++) {
    const r = rows[i];
    console.log(r.t.toFixed(3), r.pf, JSON.stringify(r.btn), "dp", r.dp, "dc", r.dc.toFixed(1), "dr", r.dr.toFixed(1));
  }
}
