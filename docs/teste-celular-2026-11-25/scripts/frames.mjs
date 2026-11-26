// Extrai quadros de um vídeo com o Edge: uma folha de contato (grade) e quadros avulsos.
// Uso: node frames.mjs <video> <pastaSaida> [t1,t2,... para quadros avulsos em segundos]
import puppeteer from "puppeteer-core";
import http from "node:http";
import fs from "node:fs";
import path from "node:path";

const [video, outDir, singles] = process.argv.slice(2);
fs.mkdirSync(outDir, { recursive: true });
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
  userDataDir: path.join(outDir, ".edge-profile"),
  args: ["--no-first-run", "--disable-extensions", "--autoplay-policy=no-user-gesture-required"],
});
try {
  const page = await browser.newPage();
  await page.goto(`http://127.0.0.1:${port}/`);
  const info = await page.evaluate(() => new Promise((res, rej) => {
    const v = document.getElementById("v");
    const done = () => res({ w: v.videoWidth, h: v.videoHeight, d: v.duration });
    if (v.readyState >= 1) done(); else { v.onloadedmetadata = done; v.onerror = () => rej(String(v.error && v.error.message)); }
  }));
  console.log("video:", JSON.stringify(info));

  const grab = (t, maxW, type, q) => page.evaluate((t, maxW, type, q) => new Promise((res) => {
    const v = document.getElementById("v");
    v.onseeked = () => {
      const s = Math.min(1, maxW / v.videoWidth);
      const c = document.createElement("canvas");
      c.width = Math.round(v.videoWidth * s); c.height = Math.round(v.videoHeight * s);
      c.getContext("2d").drawImage(v, 0, 0, c.width, c.height);
      res(c.toDataURL(type, q));
    };
    v.currentTime = t;
  }), t, maxW, type, q);

  // folha de contato: 15 quadros em 5 colunas
  const n = Number(process.env.N || 15), cols = Number(process.env.COLS || 5);
  const times = Array.from({ length: n }, (_, i) => Math.min(info.d - 0.1, (i + 0.5) * info.d / n));
  const thumbs = [];
  for (const t of times) thumbs.push(await grab(t, 260, "image/jpeg", 0.8));
  const sheet = await page.evaluate(async (thumbs, times, cols) => {
    const imgs = await Promise.all(thumbs.map((u) => new Promise((r) => { const i = new Image(); i.onload = () => r(i); i.src = u; })));
    const w = imgs[0].width, h = imgs[0].height, rows = Math.ceil(imgs.length / cols);
    const c = document.createElement("canvas"); c.width = cols * w; c.height = rows * (h + 28);
    const g = c.getContext("2d"); g.fillStyle = "#fff"; g.fillRect(0, 0, c.width, c.height);
    g.font = "bold 20px Arial"; g.fillStyle = "#c00";
    imgs.forEach((im, k) => { const x = (k % cols) * w, y = Math.floor(k / cols) * (h + 28); g.drawImage(im, x, y + 28); g.fillText(times[k].toFixed(1) + " s", x + 6, y + 21); });
    return c.toDataURL("image/jpeg", 0.85);
  }, thumbs, times, cols);
  fs.writeFileSync(path.join(outDir, "folha.jpg"), Buffer.from(sheet.split(",")[1], "base64"));
  console.log("folha:", times.map((t) => t.toFixed(1)).join(" "));

  for (const t of (singles ? singles.split(",").map(Number) : [])) {
    const u = await grab(t, 1080, "image/jpeg", 0.9);
    const f = path.join(outDir, `quadro-${t.toFixed(1)}.jpg`);
    fs.writeFileSync(f, Buffer.from(u.split(",")[1], "base64"));
    console.log("quadro:", f);
  }
} finally {
  await browser.close();
  server.close();
}
