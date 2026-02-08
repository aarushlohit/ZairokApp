# Download Counter Server 🔧

Simple Node.js + Express server that stores a global download count and broadcasts live updates via Socket.IO.

Endpoints:
- GET /count -> { count }
- POST /increment -> increments count and emits update
- POST /set { count } -> set count and emits update

Quick start:

1. cd download-counter-server
2. npm install
3. npm start

Default server port: 4000

To connect from the website, set environment variable `VITE_COUNTER_URL` (optional) or use `http://localhost:4000` by default.
