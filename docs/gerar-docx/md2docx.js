// Gera o Roadmap do TCC (.docx) a partir do roadmap.md revisado.
// Uso: node md2docx.js <roadmap.md> <saida.docx>
const fs = require('fs');
const {
  Document, Packer, Paragraph, TextRun, Footer, AlignmentType, PageNumber, PageOrientation, BorderStyle,
} = require('docx');
const H = require('./helpers');

const VERSION = 'versão 5 (17/11/2026)';
const LANDSCAPE_SECTION = /^## 8\./;

const visible = s => s.replace(/\*\*|~~|`|_/g, '').replace(/\[([^\]]+)\]\([^)]+\)/g, '$1');

function splitRow(line) {
  return line.trim().replace(/^\|/, '').replace(/\|$/, '').split(' | ').map(c => c.trim());
}

// Larguras proporcionais ao tamanho médio do texto de cada coluna.
function columnWidths(header, rows) {
  return header.map((h, i) => {
    const lens = [h, ...rows.map(r => r[i] || '')].map(c => visible(c).length);
    const mean = lens.reduce((a, b) => a + b, 0) / lens.length;
    return Math.max(8, mean) ** 0.7;
  }).map((w, _, all) => Math.max(w, 0.07 * all.reduce((a, b) => a + b, 0)));
}

function parse(md, total) {
  const lines = md.split('\n');
  const out = [];
  let i = 0;
  let instance = 0;
  let prevNumbered = false;
  while (i < lines.length) {
    const line = lines[i];
    const isNumbered = /^\d+\. /.test(line);
    if (!isNumbered) prevNumbered = false;
    if (!line.trim()) { i += 1; continue; }
    if (line.startsWith('#### ')) out.push(H.h3(line.slice(5)));
    else if (line.startsWith('### ')) out.push(H.h2(line.slice(4)));
    else if (line.startsWith('## ')) out.push(H.h1(line.slice(3)));
    else if (line.startsWith('|')) {
      const block = [];
      while (i < lines.length && lines[i].startsWith('|')) block.push(lines[i++]);
      const header = splitRow(block[0]);
      const rows = block.slice(2).map(splitRow);
      const cells = rows.map(r => r.map(c => c.split('<br>')));
      out.push(H.table(header, cells, columnWidths(header, rows), { total, fontSize: header.length >= 5 ? 16 : 18 }), H.gap());
      continue;
    } else if (line.startsWith('>')) {
      const block = [];
      while (i < lines.length && lines[i].startsWith('>')) block.push(lines[i++].replace(/^>\s?/, ''));
      let content = block.filter(l => l.trim());
      let kind = 'info';
      const tag = content[0].match(/^\[!(\w+)\]\s*/);
      if (tag) { kind = tag[1]; content[0] = content[0].slice(tag[0].length); }
      let title = null;
      if (/^\*\*[^*]+\*\*$/.test(content[0])) { title = content[0].slice(2, -2); content = content.slice(1); }
      const paras = content.map(l => (l.startsWith('- ') ? H.bulletItem(l.slice(2)) : l));
      out.push(H.callout(kind, title, paras, total), H.gap());
      continue;
    } else if (/^\s*- \[ \] /.test(line)) out.push(H.checkItem(line.replace(/^\s*- \[ \] /, '')));
    else if (/^\s*- \[x\] /i.test(line)) out.push(H.checkDoneItem(line.replace(/^\s*- \[x\] /i, '')));
    else if (/^\s*- /.test(line)) {
      const level = Math.floor(line.match(/^\s*/)[0].length / 2);
      out.push(H.bulletItem(line.replace(/^\s*- /, ''), level));
    } else if (isNumbered) {
      if (!prevNumbered) instance += 1;
      prevNumbered = true;
      out.push(H.numberedItem(line.replace(/^\d+\. /, ''), instance));
    } else if (/^_→ .*_$/.test(line)) {
      out.push(new Paragraph({ spacing: { after: 120 }, indent: { left: 300 }, children: H.runs(line.slice(1, -1), { size: 17, color: H.C.gray, italics: true }) }));
    } else out.push(H.p(line));
    i += 1;
  }
  return out;
}

function cover() {
  return [
    new Paragraph({ spacing: { before: 1800, after: 0 }, children: [] }),
    H.p('TRABALHO DE CONCLUSÃO DE CURSO · 2º SEMESTRE DE 2026', { run: { size: 20, color: H.C.gray, bold: true } }),
    new Paragraph({
      spacing: { before: 120, after: 120 },
      children: [new TextRun({ text: 'Roadmap do TCC', font: H.FONT, size: 64, bold: true, color: H.C.green })],
    }),
    new Paragraph({
      spacing: { after: 360 },
      border: { bottom: { style: BorderStyle.SINGLE, size: 12, color: H.C.amberBorder, space: 12 } },
      children: [new TextRun({ text: 'Aplicativo que indica, pela câmera do celular e sem internet, se o tomate está no ponto de colheita', font: H.FONT, size: 30, color: H.C.green2 })],
    }),
    H.table(
      ['Item', 'Detalhe'],
      [
        ['**Curso**', 'Bacharelado em Ciência da Computação · UNITRI (Uberlândia-MG)'],
        ['**Disciplina**', 'N587 · Trabalho de Conclusão de Curso (80 h/a, 8º período) · monografia'],
        ['**Grupo**', 'Leonardo Sergi Molina (execução) · Vítor Tetsuya Kazuma · Victor José Morais de Lima'],
        ['**Orientação**', 'Sem orientador; acompanhamento pelo professor da disciplina'],
        ['**Versão**', '5 · 17/11/2026 · situação em 17/11 e o que falta fazer até a entrega (seção 1)'],
      ],
      [0.22, 0.78],
      { fontSize: 20 },
    ),
    H.gap(240),
    H.callout('alert', 'Prazo final: protocolo do TCC pós-banca até quinta, 10/12/2026', [
      'Antes disso: Projeto de TCC deferido, protocolo pré-banca e apresentação à banca, nas datas que o professor marcar. Meta interna: texto completo em **28/11**. O ENADE é em **29/11**.',
    ]),
    H.gap(240),
    H.small('Base: Manual de Elaboração do TCC enviado pelo professor, calendário letivo oficial 2026/2, MIA 2026.1, matriz curricular 102AN, orientações da UNITRI para protocolar o TCC (29/07/2026), pesquisa com checagem de fatos feita em 03/11/2026 e as decisões tomadas pelo grupo até 17/11/2026. A versão sempre atualizada fica no repositório, em docs/roadmap.md.'),
    H.pageBreak(),
  ];
}

function footer() {
  return {
    default: new Footer({
      children: [new Paragraph({
        alignment: AlignmentType.RIGHT,
        children: [new TextRun({
          font: H.FONT, size: 16, color: H.C.gray,
          children: [`Roadmap do TCC · ${VERSION} · página `, PageNumber.CURRENT, ' de ', PageNumber.TOTAL_PAGES],
        })],
      })],
    }),
  };
}

const margin = { top: H.MARGIN, right: H.MARGIN, bottom: H.MARGIN, left: H.MARGIN };
const portrait = { page: { size: { width: H.PAGE.width, height: H.PAGE.height }, margin } };
const landscape = { page: { size: { width: H.PAGE.width, height: H.PAGE.height, orientation: PageOrientation.LANDSCAPE }, margin } };

// Cada seção "## " começa numa página nova; a seção 8 (cronograma) vai em paisagem.
const md = fs.readFileSync(process.argv[2], 'utf8');
const chunks = md.split(/\n(?=## )/).filter(c => c.trim());
const groups = [];
for (const chunk of chunks) {
  const land = LANDSCAPE_SECTION.test(chunk);
  const last = groups[groups.length - 1];
  if (last && last.land === land && !land) last.chunks.push(chunk);
  else groups.push({ land, chunks: [chunk] });
}
const sections = groups.map((g, gi) => {
  const total = g.land ? H.LANDSCAPE_W : H.CONTENT_W;
  const children = gi === 0 ? cover() : [];
  g.chunks.forEach((c, ci) => {
    if (ci > 0) children.push(H.pageBreak());
    children.push(...parse(c, total));
  });
  return { properties: g.land ? landscape : portrait, footers: footer(), children };
});

const doc = new Document({
  creator: 'Grupo do TCC',
  title: 'Roadmap do TCC',
  description: 'Plano de trabalho do TCC de Ciência da Computação (UNITRI, 2026/2)',
  styles: H.styles,
  numbering: H.numberingConfig,
  sections,
});

Packer.toBuffer(doc).then(buf => {
  fs.writeFileSync(process.argv[3], buf);
  console.log('ok', process.argv[3], buf.length, 'bytes', sections.length, 'sections');
});
