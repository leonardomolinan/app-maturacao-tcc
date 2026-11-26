// Recorta a mesma faixa vertical de vários instantes de um vídeo e empilha numa imagem.
// Uso: node crops.mjs <video> <saida.png> <t1,t2,...> <y0> <y1>
import puppeteer from "puppeteer-core";
import http from "node:http";
import fs from "node:fs";
import path from "node:path";

const [video, out, list, y0s, y1s] = process.argv.slice(2);
const times = list.split(",").map(Number), Y0 = Number(y0s), Y1 = Number(y1s);
const size = fs.statSync(video).size;
const server = http.createServer((req, res) => {
  if (req.url.startsWith("/v.mp4")) {
    const range = req.headers.range;
    const [s, e] = (range || "bytes=0-").replace("bytes=", "").split("-");
    const start = Number(s), end = e ? Number(e) : size - 1;
    res.writeHead(range ? 206 : 200, { "Content-Type": "video/mp4", "Accept-Ranges": "bytes", "Content-Range": `bytes ${start}-${end}/${size}`, "Content-Length": end - start + 1 });
    fs.createReadStream(video, { start, end }).pipe(res);
  } else { res.writeHead(200, { "Content-Type": "text/html" }); res.end('<!doctype html><video id="v" src="/v.mp4" muted playsinline preload="auto"></video>'); }
});
await new Promise((r) => server.listen(0, "127.0.0.1", r));
const browser = await puppeteer.launch({ executablePath: "C:\\Program Files (x86)\\Microsoft\\Edge\\Application\\msedge.exe", headless: true, userDataDir: path.join(path.dirname(out), ".edge-crops"), args: ["--no-first-run", "--disable-extensions"], protocolTimeout: 1800000 });
try {
  const page = await browser.newPage();
  await page.goto(`http://127.0.0.1:${server.address().port}/`);
  const url = await page.evaluate(async (times, Y0, Y1) => {
    const v = document.getElementById("v");
    if (v.readyState < 1) await new Promise((r) => (v.onloadedmetadata = r));
    const W = v.videoWidth, h = Y1 - Y0, labelW = 220;
    const s = document.createElement("canvas"); s.width = W + labelW; s.height = (h + 8) * times.length;
    const g = s.getContext("2d"); g.fillStyle = "#fff"; g.fillRect(0, 0, s.width, s.height);
    g.font = "bold 36px Arial"; g.fillStyle = "#c00";
    for (let k = 0; k < times.length; k++) {
      await new Promise((r) => { v.onseeked = r; v.currentTime = times[k]; });
      g.drawImage(v, 0, Y0, W, h, labelW, k * (h + 8), W, h);
      g.fillText(`${k + 1}: ${times[k].toFixed(1)}s`, 8, k * (h + 8) + h / 2 + 12);
    }
    return s.toDataURL("image/png");
  }, times, Y0, Y1);
  fs.writeFileSync(out, Buffer.from(url.split(",")[1], "base64"));
  console.log("ok", out);
} finally { await browser.close(); server.close(); }
