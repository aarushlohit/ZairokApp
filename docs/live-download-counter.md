# Live Download Counter — Setup & Run ✅

This project includes a simple backend to maintain a global download counter and broadcast live updates to the website.

Server (download-counter-server):

- Location: `download-counter-server/`
- Quick start:
  1. cd download-counter-server
  2. npm install
  3. npm start

By default the server runs on port `4000` and stores the count in `data.json`.

Website integration:

- The website (`website/`) uses `socket.io-client` to subscribe to live updates and calls `POST /increment` when a download link is clicked.
- The client reads `VITE_COUNTER_URL` environment variable if set, otherwise it falls back to `http://localhost:4000`.

Local dev notes:

- Start the server first, then run `cd website && npm install && npm run dev`.
- You can change the initial count by editing `download-counter-server/data.json` or calling `POST /set`.

Security notes:

- This is a minimal example for live counters. For production consider
  - Authentication or rate-limiting to avoid misuse
  - Use a robust storage (Postgres/Redis/Cloud DB) for concurrency and resilience
  - Deploy the server behind your preferred host (Heroku, Vercel (serverless), Cloud Run, etc.)
