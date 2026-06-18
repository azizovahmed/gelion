/**
 * Gelion REST API (ixtiyoriy — hozir Firebase ishlatiladi).
 * Ishga tushirish: npm install express cors multer && node server.js
 */
const express = require('express');
const cors = require('cors');
const path = require('path');
const fs = require('fs');

const app = express();
const PORT = process.env.PORT || 3000;
const SERVER_URL = process.env.SERVER_URL || `http://localhost:${PORT}`;
const UPLOAD_DIR = path.join(__dirname, 'uploads');

if (!fs.existsSync(UPLOAD_DIR)) fs.mkdirSync(UPLOAD_DIR, { recursive: true });

// 1) CORS — mobil ilova uchun to‘liq ochiq
app.use(
  cors({
    origin: '*',
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization'],
  }),
);

app.use(express.json());

// 2) uploads papkasi — PUBLIC static
app.use('/uploads', express.static(UPLOAD_DIR));

function fullImageUrl(filename) {
  if (!filename) return null;
  const value = String(filename).trim();
  if (value.startsWith('http://') || value.startsWith('https://')) return value;
  const name = value.replace(/^\/+/, '').replace(/^uploads\//, '');
  return `${SERVER_URL}/uploads/${name}`;
}

// Demo ma'lumot (haqiqiy loyihada DB dan oling)
const meals = [
  { id: '1', name: 'Pizza', price: 45000, image_filename: 'pizza.jpg' },
];
const banners = [
  { id: '1', title: 'Chegirma', subtitle: '50%', image_filename: 'banner.jpg' },
];

// 3) Controller — to‘liq image_url bilan qaytarish
app.get('/api/foods', (req, res) => {
  res.json(
    meals.map((m) => ({
      id: m.id,
      name: m.name,
      price: m.price,
      image_url: fullImageUrl(m.image_filename),
    })),
  );
});

app.get('/api/banners', (req, res) => {
  res.json(
    banners.map((b) => ({
      id: b.id,
      title: b.title,
      subtitle: b.subtitle,
      image_url: fullImageUrl(b.image_filename),
    })),
  );
});

app.listen(PORT, () => {
  console.log(`Gelion API: ${SERVER_URL}`);
  console.log(`Static uploads: ${SERVER_URL}/uploads/`);
});
