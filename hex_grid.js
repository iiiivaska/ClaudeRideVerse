/** @schema 2.10 */
const W = pencil.width;
const H = pencil.height;
const CX = W / 2;
const CY = H / 2;
const R = Math.min(W, H) * 0.41;
const r = R * (11 / 92);
const F = R * 1.05;
const rV = r * 0.97;
const dx = r * Math.sqrt(3);
const dy = r * 1.5;
const litCx = CX - R * (14 / 92);
const litCy = CY - R * (10 / 92);
const litR = R * (38 / 92);

function warp(fx, fy) {
  const vx = fx - CX;
  const vy = fy - CY;
  const fd = Math.hypot(vx, vy);
  if (fd < 0.0001) return { x: CX, y: CY, z: 1 };
  const phi = Math.min(Math.PI / 2, (fd / F) * Math.PI / 2);
  const sd = R * Math.sin(phi);
  const z = Math.cos(phi);
  const k = sd / fd;
  return { x: CX + vx * k, y: CY + vy * k, z };
}

const hexAngles = [];
for (let i = 0; i < 6; i++) hexAngles.push(Math.PI / 180 * (60 * i - 30));

function isLit(fhx, fhy) {
  return Math.hypot(fhx - litCx, fhy - litCy) < litR;
}

function hexToByte(a) {
  const v = Math.round(Math.max(0, Math.min(1, a)) * 255);
  return v.toString(16).padStart(2, "0");
}

const hexes = [];
const colsN = Math.ceil(F / dx) + 2;
const rowsN = Math.ceil(F / dy) + 2;

for (let row = -rowsN; row <= rowsN; row++) {
  for (let col = -colsN; col <= colsN; col++) {
    const xOff = (row & 1) ? dx / 2 : 0;
    const fhx = CX + col * dx + xOff;
    const fhy = CY + row * dy;
    const fd = Math.hypot(fhx - CX, fhy - CY);
    if (fd <= F - r * 0.5) {
      hexes.push({ fhx, fhy });
    }
  }
}

const hexData = hexes.map(h => {
  const warped = hexAngles.map(a => warp(h.fhx + rV * Math.cos(a), h.fhy + rV * Math.sin(a)));
  const center = warp(h.fhx, h.fhy);
  return { fhx: h.fhx, fhy: h.fhy, warped, z: center.z };
});

hexData.sort((a, b) => a.z - b.z);

const nodes = [];

for (const p of hexData) {
  const lit = isLit(p.fhx, p.fhy);
  const fwd = p.z;

  const xs = p.warped.map(v => v.x);
  const ys = p.warped.map(v => v.y);
  const minX = Math.min.apply(null, xs);
  const minY = Math.min.apply(null, ys);
  const maxX = Math.max.apply(null, xs);
  const maxY = Math.max.apply(null, ys);
  const bboxW = maxX - minX;
  const bboxH = maxY - minY;

  const pts = p.warped.map(v => `${(v.x - minX).toFixed(2)} ${(v.y - minY).toFixed(2)}`);
  const geometry = `M ${pts[0]} L ${pts.slice(1).join(" L ")} Z`;

  const fillAlpha = lit ? (0.14 + fwd * 0.44) : (0.22 + fwd * 0.55);
  const strokeAlpha = lit ? (0.35 + fwd * 0.55) : (0.20 + fwd * 0.42);

  const fillColor = (lit ? "#4A7DBB" : "#282E3A") + hexToByte(fillAlpha);
  const strokeColor = (lit ? "#5A8FD0" : "#6E7A8E") + hexToByte(strokeAlpha);

  nodes.push({
    type: "path",
    x: minX,
    y: minY,
    width: bboxW,
    height: bboxH,
    viewBox: [0, 0, bboxW, bboxH],
    geometry,
    fill: fillColor,
    stroke: {
      align: "center",
      thickness: lit ? 0.75 : 0.7,
      fill: strokeColor,
      join: "miter",
    },
  });
}

return nodes;
