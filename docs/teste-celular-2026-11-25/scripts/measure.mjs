// Percorre o vídeo quadro a quadro (requestVideoFrameCallback) e grava, por quadro:
// instante (mediaTime), contagem de quadros, cor média do botão Analisar, perfil do título
// e diferença em relação ao quadro anterior (fora da faixa do botão).
// Uso: node measure.mjs <video> <saida.json> [playbackRate]
import puppeteer from "puppeteer-core";
import http from "node:http";
import fs from "node:fs";
import path from "node:path";

const [video, out, rateArg] = process.argv.slice(2);
const rate = Number(rateArg || 1);
const size = fs.statSync(video).size;
const server = http.createServer((req, res) => {
  if (req.url.startsWith("/v.mp4")) {
    const range = req.headers.range;
    if (range) {
      const [s, e] = range.replace("bytes=", "").split("-");
      const start = Number(s), end = e ? Number(e) : size - 1;
      res.writeHead(206, { "Content-Type": "video/mp4", "Accept-Ranges": "bytes", "Content-Range": `bytes ${start}-${end}/${size}`, "Content-Length": end - start + 1 });
      fs.createReadStream(video, { start, end }).pipe(res);
    } else {
      res.writeHead(200, { "Content-Type": "video/mp4", "Content-Length": size, "Accept-Ranges": "bytes" });
      fs.createReadStream(video).pipe(res);
    }
  } else {
    res.writeHead(200, { "Content-Type": "text/html" });
    res.end('<!doctype html><video id="v" src="/v.mp4" muted playsinline preload="auto"></video>');
  }
});
await new Promise((r) => server.listen(0, "127.0.0.1", r));
const port = server.address().port;

const browser = await puppeteer.launch({
  executablePath: "C:\\Program Files (x86)\\Microsoft\\Edge\\Application\\msedge.exe",
  headless: true,
  userDataDir: path.join(path.dirname(out), ".edge-measure"),
  args: ["--no-first-run", "--disable-extensions", "--autoplay-policy=no-user-gesture-required", "--disable-background-timer-throttling", "--disable-renderer-backgrounding"],
  protocolTimeout: 1800000,
});
try {
  const page = await browser.newPage();
  await page.goto(`http://127.0.0.1:${port}/`);
  const rows = await page.evaluate((rate) => new Promise((resolve, reject) => {
    const v = document.getElementById("v");
    const W = 108, H = 240; // 1/10 da tela de 1080x2400
    const c = document.createElement("canvas"); c.width = W; c.height = H;
    const g = c.getContext("2d", { willReadFrequently: true });
    const rows = [];
    let prev = null;
    const onFrame = (now, md) => {
      g.drawImage(v, 0, 0, W, H);
      const px = g.getImageData(0, 0, W, H).data;
      const lum = new Float32Array(W * H);
      for (let i = 0; i < W * H; i++) lum[i] = 0.299 * px[4 * i] + 0.587 * px[4 * i + 1] + 0.114 * px[4 * i + 2];
      // botão Analisar: x 100..980, y 1530..1600  ->  colunas 10..98, linhas 153..160
      let r = 0, gg = 0, b = 0, n = 0;
      for (let y = 153; y < 160; y++) for (let x = 10; x < 98; x++) { const k = 4 * (y * W + x); r += px[k]; gg += px[k + 1]; b += px[k + 2]; n++; }
      // perfil do título: linhas 15..23 (y 150..235), escuridão média por coluna
      const title = [];
      for (let x = 0; x < W; x++) { let s = 0; for (let y = 15; y < 24; y++) s += 255 - lum[y * W + x]; title.push(Math.round(s / 9)); }
      // diferença para o quadro anterior, fora da faixa do botão (linhas 148..165)
      let d = 0, nd = 0;
      if (prev) for (let y = 0; y < H; y++) { if (y >= 148 && y < 166) continue; for (let x = 0; x < W; x++) { d += Math.abs(lum[y * W + x] - prev[y * W + x]); nd++; } }
      prev = lum;
      let tot = 0; for (let i = 0; i < W * H; i++) tot += lum[i];
      rows.push({ t: +md.mediaTime.toFixed(4), pf: md.presentedFrames, btn: [Math.round(r / n), Math.round(gg / n), Math.round(b / n)], title, dp: nd ? +(d / nd).toFixed(2) : 0, lum: Math.round(tot / (W * H)) });
      if (!v.ended) v.requestVideoFrameCallback(onFrame);
    };
    v.onended = () => setTimeout(() => resolve(rows), 300);
    v.onerror = () => reject(String(v.error && v.error.message));
    v.playbackRate = rate;
    v.requestVideoFrameCallback(onFrame);
    v.play().catch(reject);
  }), rate);
  fs.writeFileSync(out, JSON.stringify(rows));
  let gaps = 0; for (let i = 1; i < rows.length; i++) if (rows[i].pf - rows[i - 1].pf > 1) gaps += rows[i].pf - rows[i - 1].pf - 1;
  const dts = rows.slice(1).map((r, i) => r.t - rows[i].t).sort((a, b) => a - b);
  console.log(`quadros: ${rows.length}, quadros pulados na leitura: ${gaps}, intervalo mediano entre quadros: ${(dts[dts.length >> 1] * 1000).toFixed(1)} ms, duração: ${rows[rows.length - 1].t} s`);
} finally {
  await browser.close();
  server.close();
}
