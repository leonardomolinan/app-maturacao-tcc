// Estatísticas das medições no celular (medicoes.csv).
import fs from "node:fs";
const [file] = process.argv.slice(2);
const [head, ...lines] = fs.readFileSync(file, "utf8").trim().split(/\r?\n/);
const cols = head.split(",");
const rows = lines.map((l) => { const v = l.split(","); return Object.fromEntries(cols.map((c, i) => [c, v[i]])); });
const num = (a) => a.filter((x) => x !== "" && x != null).map(Number).sort((x, y) => x - y);
const q = (s, p) => { const pos = (s.length - 1) * p, lo = Math.floor(pos), hi = Math.ceil(pos); return s[lo] + (s[hi] - s[lo]) * (pos - lo); };
const show = (nome, a) => { const s = num(a); console.log(`${nome}: n=${s.length} mediana=${q(s, 0.5)} min=${s[0]} max=${s[s.length - 1]} Q1=${q(s, 0.25)} Q3=${q(s, 0.75)} media=${(s.reduce((x, y) => x + y, 0) / s.length).toFixed(1)} valores=[${s.join(", ")}]`); };
show("inferencia (todas)", rows.map((r) => r.inferencia_ms));
const cam2209 = rows.filter((r) => r.sessao === "2" && r.origem_foto === "camera");
show("toque ate inicio do resultado (camera, 22:09)", cam2209.map((r) => r.toque_ate_inicio_ms));
show("toque ate fim da transicao (camera, 22:09)", cam2209.map((r) => r.toque_ate_fim_ms));
show("registro ate inicio (camera, 22:09, wifi)", cam2209.map((r) => r.registro_ate_inicio_ms));
show("registro ate inicio (camera, 21:06, modo aviao)", rows.filter((r) => r.sessao === "1").map((r) => r.registro_ate_inicio_ms));
show("toque ate registro (22:09)", rows.filter((r) => r.sessao === "2").map((r) => Math.round((r.t_registro_s - r.t_toque_s) * 1000)));
show("transicao (inicio ate fim, todas)", rows.map((r) => Math.round((r.t_fim_transicao_s - r.t_inicio_resultado_s) * 1000)));
