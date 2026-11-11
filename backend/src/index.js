require('dotenv').config();
const prisma = require('./db');
const { createApp } = require('./app');

const requiredEnvironment = ['DATABASE_URL', 'JWT_SECRET', 'JWT_REFRESH_SECRET'];
const missingEnvironment = requiredEnvironment.filter((name) => {
  const value = process.env[name];
  return !value || value.startsWith('replace-') || (name.startsWith('JWT_') && value.length < 32);
});
if (missingEnvironment.length > 0) {
  throw new Error(`Missing or unsafe environment configuration: ${missingEnvironment.join(', ')}`);
}
if (process.env.JWT_SECRET === process.env.JWT_REFRESH_SECRET) {
  throw new Error('JWT_SECRET and JWT_REFRESH_SECRET must be different values');
}

const PORT = process.env.PORT || 5000;
const app = createApp();
let server;

async function start() {
  await prisma.$connect();
  server = app.listen(PORT, () => {
    console.log(`MADAD Backend Server listening on port ${PORT}`);
  });
  return server;
}

start().catch((error) => {
  console.error('MADAD backend failed to connect to PostgreSQL:', error.message);
  process.exitCode = 1;
});

process.on('SIGTERM', async () => {
  if (server) await new Promise((resolve) => server.close(resolve));
  await prisma.$disconnect();
  process.exit(0);
});

process.on('SIGINT', async () => {
  if (server) await new Promise((resolve) => server.close(resolve));
  await prisma.$disconnect();
  process.exit(0);
});
