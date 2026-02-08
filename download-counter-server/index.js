import express from 'express';
import http from 'http';
import { Server } from 'socket.io';
import cors from 'cors';
import fs from 'fs/promises';
import path from 'path';

const DATA_FILE = path.resolve(new URL('.', import.meta.url).pathname, 'data.json');
const PORT = process.env.PORT || 4000;

async function readCount() {
  try {
    const data = await fs.readFile(DATA_FILE, 'utf8');
    const { count } = JSON.parse(data);
    return typeof count === 'number' ? count : 0;
  } catch (e) {
    return 0;
  }
}

async function writeCount(count) {
  await fs.writeFile(DATA_FILE, JSON.stringify({ count }), 'utf8');
}

const app = express();
app.use(cors());
app.use(express.json());

const server = http.createServer(app);
const io = new Server(server, { cors: { origin: true } });

io.on('connection', (socket) => {
  console.log('Socket connected', socket.id);
  // send current count on new connection
  readCount().then((count) => socket.emit('count', count));
});

app.get('/count', async (req, res) => {
  const count = await readCount();
  res.json({ count });
});

app.post('/increment', async (req, res) => {
  const current = await readCount();
  const newCount = current + 1;
  await writeCount(newCount);
  io.emit('count', newCount);
  res.json({ count: newCount });
});

app.post('/set', async (req, res) => {
  const { count } = req.body;
  if (typeof count !== 'number') return res.status(400).json({ error: 'count must be number' });
  await writeCount(count);
  io.emit('count', count);
  res.json({ count });
});

server.listen(PORT, () => console.log(`Download counter server listening on ${PORT}`));
