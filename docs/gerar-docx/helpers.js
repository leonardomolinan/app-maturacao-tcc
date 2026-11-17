// Helpers para montar o roadmap com docx-js (v9).
const {
  Paragraph, TextRun, HeadingLevel, AlignmentType, Table, TableRow, TableCell,
  WidthType, ShadingType, BorderStyle, LevelFormat, PageBreak, VerticalAlign,
  ExternalHyperlink,
} = require('docx');

const FONT = 'Arial';
const C = {
  green: '1B5E20',
  green2: '2E7D32',
  green3: '33691E',
  light: 'E8F5E9',
  zebra: 'F7FBF7',
  amber: 'FFF8E1',
  amberBorder: 'F9A825',
  blue: 'E3F2FD',
  blueBorder: '1565C0',
  red: 'FDECEA',
  redBorder: 'C62828',
  gray: '616161',
  grid: 'C8D6C8',
  link: '0563C1',
};

// A4 retrato, margens de 2 cm.
const PAGE = { width: 11906, height: 16838 };
const MARGIN = 1134;
const CONTENT_W = PAGE.width - 2 * MARGIN; // 9638 DXA
const LANDSCAPE_W = PAGE.height - 2 * MARGIN; // 14570 DXA

// Converte **negrito**, _itálico_, `código` e [link](url) em runs.
// O estilo do trecho vem depois de `base`, para o negrito do markup não ser apagado
// por um `bold: undefined` herdado (falha da v1 dentro das tabelas).
function runs(text, base = {}) {
  const out = [];
  const re = /\*\*(.+?)\*\*|(?<![\w])_(.+?)_(?![\w])|`([^`]+)`|\[([^\]]+)\]\((https?:[^)\s]+)\)|~~(.+?)~~/g;
  let last = 0;
  let m;
  const plain = t => new TextRun({ font: FONT, ...base, text: t });
  while ((m = re.exec(text)) !== null) {
    if (m.index > last) out.push(plain(text.slice(last, m.index)));
    if (m[1] !== undefined) out.push(new TextRun({ font: FONT, ...base, text: m[1], bold: true }));
    else if (m[2] !== undefined) out.push(new TextRun({ font: FONT, ...base, text: m[2], italics: true }));
    else if (m[3] !== undefined) out.push(new TextRun({ ...base, text: m[3], font: 'Consolas', color: '37474F' }));
    else if (m[6] !== undefined) out.push(new TextRun({ font: FONT, ...base, text: m[6], strike: true, color: C.gray }));
    else {
      out.push(new ExternalHyperlink({
        link: m[5],
        children: [new TextRun({ font: FONT, ...base, text: m[4], color: C.link, underline: {} })],
      }));
    }
    last = re.lastIndex;
  }
  if (last < text.length) out.push(plain(text.slice(last)));
  return out;
}

function p(text, opts = {}) {
  const { run = {}, ...para } = opts;
  return new Paragraph({ children: runs(text, run), ...para });
}

function small(text, opts = {}) {
  return p(text, { run: { size: 17, color: C.gray }, ...opts });
}

const h1 = (text, opts = {}) => new Paragraph({ heading: HeadingLevel.HEADING_1, children: runs(text), ...opts });
const h2 = (text, opts = {}) => new Paragraph({ heading: HeadingLevel.HEADING_2, children: runs(text), ...opts });
const h3 = (text, opts = {}) => new Paragraph({ heading: HeadingLevel.HEADING_3, children: runs(text), ...opts });

const pageBreak = () => new Paragraph({ children: [new PageBreak()] });

function bulletItem(text, level = 0) {
  return new Paragraph({ numbering: { reference: 'bullets', level }, spacing: { after: 60 }, children: runs(text) });
}

function checkItem(text) {
  return new Paragraph({ numbering: { reference: 'checks', level: 0 }, spacing: { after: 60 }, children: runs(text) });
}

function checkDoneItem(text) {
  return new Paragraph({ numbering: { reference: 'checksDone', level: 0 }, spacing: { after: 60 }, children: runs(text) });
}

function numberedItem(text, instance) {
  return new Paragraph({ numbering: { reference: 'numbers', level: 0, instance }, spacing: { after: 60 }, children: runs(text) });
}

const GRID = { style: BorderStyle.SINGLE, size: 4, color: C.grid };
const NONE = { style: BorderStyle.NONE, size: 0, color: 'FFFFFF' };

// Célula: string (com markup), array de strings (vira parágrafos) ou array de Paragraphs.
function cellChildren(content, runOpts) {
  const list = Array.isArray(content) ? content : [content];
  return list.map(c => (typeof c === 'string'
    ? new Paragraph({ spacing: { after: 40 }, children: runs(c, runOpts) })
    : c));
}

// widths em frações; converte para DXA somando `total`.
function toDxa(widths, total = CONTENT_W) {
  const sum = widths.reduce((a, b) => a + b, 0);
  const dxa = widths.map(w => Math.floor((w / sum) * total));
  dxa[dxa.length - 1] += total - dxa.reduce((a, b) => a + b, 0);
  return dxa;
}

function table(headers, rows, widths, opts = {}) {
  const { fontSize = 18, headerFill = C.light, zebra = true, total = CONTENT_W } = opts;
  const cols = toDxa(widths, total);
  const margins = { top: 60, bottom: 60, left: 90, right: 90 };
  const headerRow = new TableRow({
    tableHeader: true,
    cantSplit: true,
    children: headers.map((h, i) => new TableCell({
      width: { size: cols[i], type: WidthType.DXA },
      shading: { type: ShadingType.CLEAR, color: 'auto', fill: headerFill },
      verticalAlign: VerticalAlign.CENTER,
      margins,
      children: cellChildren(h, { bold: true, size: fontSize, color: C.green }),
    })),
  });
  const bodyRows = rows.map((r, ri) => new TableRow({
    cantSplit: true,
    children: r.map((c, i) => new TableCell({
      width: { size: cols[i], type: WidthType.DXA },
      shading: zebra && ri % 2 === 1 ? { type: ShadingType.CLEAR, color: 'auto', fill: C.zebra } : undefined,
      margins,
      children: cellChildren(c, { size: fontSize }),
    })),
  }));
  return new Table({
    width: { size: total, type: WidthType.DXA },
    columnWidths: cols,
    borders: { top: GRID, bottom: GRID, left: GRID, right: GRID, insideHorizontal: GRID, insideVertical: GRID },
    rows: [headerRow, ...bodyRows],
  });
}

// Caixa de destaque: tabela de 1 célula com faixa colorida à esquerda.
const BOX = {
  info: { fill: C.blue, border: C.blueBorder },
  tip: { fill: C.light, border: C.green2 },
  warn: { fill: C.amber, border: C.amberBorder },
  alert: { fill: C.red, border: C.redBorder },
};
function callout(kind, title, content, total = CONTENT_W) {
  const style = BOX[kind] || BOX.info;
  const body = Array.isArray(content) ? content : [content];
  const children = [];
  if (title) children.push(new Paragraph({ spacing: { after: 60 }, children: runs(title, { bold: true }) }));
  for (const c of body) {
    children.push(typeof c === 'string' ? new Paragraph({ spacing: { after: 40 }, children: runs(c, { size: 20 }) }) : c);
  }
  return new Table({
    width: { size: total, type: WidthType.DXA },
    columnWidths: [total],
    rows: [new TableRow({
      cantSplit: true,
      children: [new TableCell({
        width: { size: total, type: WidthType.DXA },
        shading: { type: ShadingType.CLEAR, color: 'auto', fill: style.fill },
        margins: { top: 120, bottom: 120, left: 200, right: 200 },
        borders: { left: { style: BorderStyle.SINGLE, size: 36, color: style.border }, top: NONE, bottom: NONE, right: NONE },
        children,
      })],
    })],
  });
}

// Espaço vertical depois de tabelas e caixas.
const gap = (after = 120) => new Paragraph({ spacing: { after }, children: [] });

const numberingConfig = {
  config: [
    {
      reference: 'bullets',
      levels: [
        { level: 0, format: LevelFormat.BULLET, text: '•', alignment: AlignmentType.LEFT, style: { paragraph: { indent: { left: 400, hanging: 260 } } } },
        { level: 1, format: LevelFormat.BULLET, text: '◦', alignment: AlignmentType.LEFT, style: { paragraph: { indent: { left: 800, hanging: 260 } } } },
        { level: 2, format: LevelFormat.BULLET, text: '▪', alignment: AlignmentType.LEFT, style: { paragraph: { indent: { left: 1200, hanging: 260 } } } },
      ],
    },
    {
      reference: 'checks',
      levels: [
        { level: 0, format: LevelFormat.BULLET, text: '☐', alignment: AlignmentType.LEFT, style: { paragraph: { indent: { left: 400, hanging: 300 } }, run: { font: 'Segoe UI Symbol' } } },
      ],
    },
    {
      reference: 'checksDone',
      levels: [
        { level: 0, format: LevelFormat.BULLET, text: '☑', alignment: AlignmentType.LEFT, style: { paragraph: { indent: { left: 400, hanging: 300 } }, run: { font: 'Segoe UI Symbol' } } },
      ],
    },
    {
      reference: 'numbers',
      levels: [
        { level: 0, format: LevelFormat.DECIMAL, text: '%1.', alignment: AlignmentType.LEFT, style: { paragraph: { indent: { left: 400, hanging: 300 } } } },
      ],
    },
  ],
};

const styles = {
  default: {
    document: { run: { font: FONT, size: 21 }, paragraph: { spacing: { after: 100, line: 276 } } },
    title: { run: { font: FONT, size: 52, bold: true, color: C.green }, paragraph: { spacing: { before: 0, after: 200 }, keepNext: true } },
    heading1: { run: { font: FONT, size: 32, bold: true, color: C.green }, paragraph: { spacing: { before: 360, after: 160 }, keepNext: true } },
    heading2: { run: { font: FONT, size: 26, bold: true, color: C.green2 }, paragraph: { spacing: { before: 280, after: 120 }, keepNext: true } },
    heading3: { run: { font: FONT, size: 22, bold: true, color: C.green3 }, paragraph: { spacing: { before: 200, after: 80 }, keepNext: true } },
  },
};

module.exports = {
  FONT, C, PAGE, MARGIN, CONTENT_W, LANDSCAPE_W, runs, p, small, h1, h2, h3, pageBreak,
  bulletItem, checkItem, checkDoneItem, numberedItem, table, callout, gap, numberingConfig, styles,
};
