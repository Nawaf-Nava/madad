const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const { rateLimit } = require('express-rate-limit');

const authRoutes = require('./routes/authRoutes');
const walletRoutes = require('./routes/walletRoutes');
const prisma = require('./db');

function createApp() {
  const app = express();
  app.disable('x-powered-by');
  app.use(helmet());

  const configuredOrigins = (process.env.CORS_ORIGINS || '')
    .split(',')
    .map((origin) => origin.trim())
    .filter(Boolean);
  const corsOptions = configuredOrigins.length > 0
    ? { origin: configuredOrigins }
    : process.env.NODE_ENV === 'production'
      ? { origin: false }
      : { origin: true };

  app.use(cors(corsOptions));
  app.use(express.json({ limit: '32kb' }));

  app.get('/health', (req, res) => {
    res.json({ status: 'UP', service: 'MADAD Backend Server' });
  });

  app.get('/ready', async (req, res) => {
    try {
      await prisma.$queryRaw`SELECT 1`;
      res.json({ status: 'READY', database: 'CONNECTED' });
    } catch (error) {
      res.status(503).json({ status: 'NOT_READY', database: 'UNAVAILABLE' });
    }
  });

  const authLimiter = rateLimit({
    windowMs: 15 * 60 * 1000,
    limit: 10,
    standardHeaders: 'draft-8',
    legacyHeaders: false,
    message: {
      error: 'Too many authentication attempts. Try again later.',
      code: 'AUTH_RATE_LIMITED',
    },
  });

  app.use('/api/auth', authLimiter, authRoutes);
  app.use('/api/wallet', walletRoutes);

  app.use((req, res) => {
    res.status(404).json({ error: 'Route not found', code: 'NOT_FOUND' });
  });

  app.use((error, req, res, next) => {
    if (res.headersSent) return next(error);
    if (error instanceof SyntaxError && error.status === 400 && 'body' in error) {
      return res.status(400).json({ error: 'Invalid JSON body', code: 'INVALID_JSON' });
    }
    console.error('Unhandled API error:', error.message);
    return res.status(500).json({ error: 'Internal server error', code: 'INTERNAL_ERROR' });
  });

  return app;
}

module.exports = { createApp };
