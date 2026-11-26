// Para cada resultado, procura um quadro em que o botão verde "Nova análise" aparece e recorta
// a faixa logo acima dele (a linha "Modelo ... inferência em X ms no aparelho").
// Uso: node infer.mjs <video> <saida.png> <ini1-fim1,ini2-fim2,...>
import puppeteer from "puppeteer-core";
import http from "node:http";
import fs from "node:fs";
import path from "node:path";

const [video, out, spans] = process.argv.slice(2);
const windows = spans.split(",").map((s) => s.split("-").map(Number));
const size = fs.statSync(video).size;
const server = http.createServer((req, res) => {
  if (req.url.startsWith("/v.mp4")) {
    const range = req.headers.range;
    const [s, e] = (range || "bytes=0-").replace("bytes=", "").split("-");
    const start = Number(s), end = e ? Number(e) : size - 1;
    res.writeHead(range ? 206 : 200, { "Content-Type": "video/mp4", "Accept-Ranges": "bytes", "Content-Range": `bytes ${start}-${end}/${size}`, "Content-Length": end - start + 1 });
    fs.createReadStream(video, { start, end }).pipe(res);
  } else {
    res.writeHead(200, { "Content-Type": "text/html" });
    res.end('<!doctype html><video id="v" src="/v.mp4" muted playsinline preload="auto"></video>');
  }
});
await new Promise((r) => server.listen(0, "127.0.0.1", r));
const browser = await puppeteer.launch({
  executablePath: "C:\\Program Files (x86)\\Microsoft\\Edge\\Application\\msedge.exe",
  headless: true, userDataDir: path.join(path.dirname(out), ".edge-infer"),
  args: ["--no-first-run", "--disable-extensions"], protocolTimeout: 1800000,
});
try {
  const page = await browser.newPage();
  await page.goto(`http://127.0.0.1:${server.address().port}/`);
  if (process.env.LAST) await page.evaluate(() => { window.__LAST = true; });
  const data = await page.evaluate(async (windows) => {
    const v = document.getElementById("v");
    if (v.readyState < 1) await new Promise((r) => (v.onloadedmetadata = r));
    const W = v.videoWidth, H = v.videoHeight;
    const c = document.createElement("canvas"); c.width = W; c.height = H;
    const g = c.getContext("2d", { willReadFrequently: true });
    const seek = (t) => new Promise((r) => { v.onseeked = r; v.currentTime = t; });
    const crops = [];
    const lastMode = !!window.__LAST;
    for (const [a, b] of windows) {
      let found = null;
      const ts = [];
      for (let t = a + 0.4; t < b - 0.1; t += 0.25) ts.push(t);
      if (lastMode) ts.reverse(); // procura do fim para o começo (tela já rolada até embaixo)
      for (const t of ts) {
        if (found) break;
        await seek(t);
        g.drawImage(v, 0, 0);
        const px = g.getImageData(0, 0, W, H).data;
        // linhas com verde escuro em quase toda a largura (botão "Nova análise")
        const isRow = (y) => { let n = 0, tot = 0; for (let x = Math.round(W * 0.1); x < W * 0.9; x += 4) { const k = 4 * (y * W + x); const r = px[k], gg = px[k + 1], bb = px[k + 2]; if (gg - r > 25 && gg < 140 && r < 90) n++; tot++; } return n / tot > 0.8; };
        const bands = []; let y0 = -1;
        const yEnd = Math.round(H * 0.94);
        for (let y = Math.round(H * 0.3); y < yEnd; y++) { const on = isRow(y); if (on && y0 < 0) y0 = y; if (!on && y0 >= 0) { if (y - y0 > H * 0.03) bands.push([y0, y]); y0 = -1; } }
        if (y0 >= 0 && yEnd - y0 > H * 0.02) bands.push([y0, yEnd]); // faixa que encosta na barra de navegação
        if (!bands.length) continue;
        // o "Nova análise" é a faixa verde mais alta que tem um botão claro ("Ver histórico") abaixo; na dúvida, a mais baixa
        const top = bands[bands.length - 1][0];
        const bandTop = Math.round(top - H * 0.06), bandH = Math.round(H * 0.045);
        if (bandTop < H * 0.1) continue;
        const cc = document.createElement("canvas"); cc.width = W; cc.height = bandH;
        cc.getContext("2d").drawImage(c, 0, bandTop, W, bandH, 0, 0, W, bandH);
        found = { t, url: cc.toDataURL("image/png") };
      }
      crops.push(found);
    }
    // junta tudo numa imagem, com o instante à esquerda
    const imgs = await Promise.all(crops.map((cr) => cr ? new Promise((r) => { const i = new Image(); i.onload = () => r(i); i.src = cr.url; }) : null));
    const rowH = Math.round(H * 0.045) + 10, labelW = 220;
    const s = document.createElement("canvas"); s.width = W + labelW; s.height = rowH * crops.length;
    const sg = s.getContext("2d"); sg.fillStyle = "#fff"; sg.fillRect(0, 0, s.width, s.height);
    sg.font = "bold 36px Arial"; sg.fillStyle = "#c00";
    crops.forEach((cr, k) => { sg.fillText(`${k + 1}: ${cr ? cr.t.toFixed(1) + "s" : "--"}`, 8, k * rowH + rowH / 2 + 12); if (imgs[k]) sg.drawImage(imgs[k], labelW, k * rowH); });
    return { sheet: s.toDataURL("image/png"), times: crops.map((cr) => cr && cr.t) };
  }, windows);
  fs.writeFileSync(out, Buffer.from(data.sheet.split(",")[1], "base64"));
  console.log("quadros usados:", data.times.map((t) => (t == null ? "--" : t.toFixed(2))).join(" "));
} finally {
  await browser.close();
  server.close();
}
