import http from 'node:http';
import { createApp } from './app.js';

if (process.env.NODE_ENV === 'production') {
  throw new Error('The synthetic portal API cannot run in production');
}

const app = createApp();

const server = http.createServer(async (request, response) => {
  let body = null;
  if (request.method !== 'GET' && request.method !== 'HEAD') {
    const chunks = [];
    for await (const chunk of request) chunks.push(chunk);
    if (chunks.length > 0) body = JSON.parse(Buffer.concat(chunks).toString('utf8'));
  }

  const headers = Object.fromEntries(Object.entries(request.headers).map(([key, value]) => [key.toLowerCase(), value]));
  const result = await app.handle({ method: request.method, url: request.url, headers, body });
  response.writeHead(result.status, { 'content-type': 'application/json; charset=utf-8' });
  response.end(JSON.stringify(result.body));
});

const port = Number(process.env.PORT ?? 8787);
server.listen(port, '127.0.0.1', () => {
  console.log(`Fala Comigo portal API local: http://127.0.0.1:${port}`);
});
