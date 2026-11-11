const { createHash, randomBytes, randomUUID } = require('node:crypto');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const prisma = require('../db');

const ACCESS_TTL = '15m';
const REFRESH_TTL_SECONDS = 7 * 24 * 60 * 60;
const INTERNAL_PHONE_PATTERN = /^\+?[0-9]{7,20}$/;
const EMAIL_PATTERN = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

function normalizePhone(value) {
  if (typeof value !== 'string') return null;
  const normalized = value.trim().replace(/[\s()-]/g, '');
  return INTERNAL_PHONE_PATTERN.test(normalized) ? normalized : null;
}

function normalizeEmail(value) {
  if (value == null || value === '') return null;
  if (typeof value !== 'string') return undefined;
  const email = value.trim().toLowerCase();
  return email.length <= 254 && EMAIL_PATTERN.test(email) ? email : undefined;
}

function hashToken(token) {
  return createHash('sha256').update(token).digest('hex');
}

function safeUser(user) {
  return {
    id: user.id,
    phone: user.phone,
    email: user.email,
    fullName: user.fullName,
    isVerified: user.isVerified,
    createdAt: user.createdAt,
    profile: user.profile ?? null,
    wallets: user.wallets ?? [],
  };
}

function issueAccessToken(user, sessionId) {
  return jwt.sign(
    { userId: user.id, phone: user.phone, type: 'access', sid: sessionId },
    process.env.JWT_SECRET,
    { expiresIn: ACCESS_TTL },
  );
}

async function createSession(tx, user, req) {
  const refreshJti = randomUUID();
  const refreshToken = jwt.sign(
    { userId: user.id, type: 'refresh', jti: refreshJti },
    process.env.JWT_REFRESH_SECRET,
    { expiresIn: REFRESH_TTL_SECONDS },
  );
  const decoded = jwt.decode(refreshToken);

  const session = await tx.userSession.create({
    data: {
      userId: user.id,
      // The legacy column stores a one-way digest. It never contains the bearer token.
      refreshToken: hashToken(refreshToken),
      expiresAt: new Date(decoded.exp * 1000),
    },
  });

  await writeAudit(tx, user.id, 'SESSION_CREATED', req);
  return { accessToken: issueAccessToken(user, session.id), refreshToken };
}

async function writeAudit(tx, userId, action, req) {
  await tx.auditLog.create({
    data: {
      userId,
      action,
      ipAddress: typeof req.ip === 'string' ? req.ip.slice(0, 64) : null,
      details: JSON.stringify({ source: 'madad-api' }),
    },
  });
}

function accountNumber() {
  return `MAD-${randomBytes(8).toString('hex').toUpperCase()}`;
}

function respondWithAuth(res, status, message, user, tokens) {
  return res.status(status).json({
    message,
    accessToken: tokens.accessToken,
    refreshToken: tokens.refreshToken,
    user: safeUser(user),
  });
}

async function register(req, res) {
  const phone = normalizePhone(req.body?.phone);
  const fullName = typeof req.body?.fullName === 'string' ? req.body.fullName.trim() : '';
  const password = req.body?.password;
  const email = normalizeEmail(req.body?.email);

  if (!phone || fullName.length < 2 || fullName.length > 100 ||
      typeof password !== 'string' || password.length < 8 || password.length > 128 ||
      email === undefined) {
    return res.status(400).json({
      error: 'Provide a valid phone, full name, optional email, and password of at least 8 characters.',
      code: 'VALIDATION_ERROR',
    });
  }

  try {
    const result = await prisma.$transaction(async (tx) => {
      const user = await tx.user.create({
        data: {
          phone,
          fullName,
          email,
          passwordHash: await bcrypt.hash(password, 12),
          profile: { create: {} },
          wallets: {
            create: {
              accountNumber: accountNumber(),
              name: 'الرئيسية',
              isMain: true,
              // Empty account record only; this is not provider-backed funds.
              balance: 0,
            },
          },
        },
        include: { profile: true, wallets: true },
      });
      const tokens = await createSession(tx, user, req);
      await writeAudit(tx, user.id, 'USER_REGISTERED', req);
      return { user, tokens };
    });
    return respondWithAuth(res, 201, 'Account created.', result.user, result.tokens);
  } catch (error) {
    if (error.code === 'P2002') {
      return res.status(409).json({
        error: 'An account already exists for the supplied phone or email.',
        code: 'ACCOUNT_ALREADY_EXISTS',
      });
    }
    console.error('Registration failed:', error.message);
    return res.status(500).json({ error: 'Internal server error', code: 'INTERNAL_ERROR' });
  }
}

async function login(req, res) {
  const phone = normalizePhone(req.body?.phone);
  const password = req.body?.password;
  if (!phone || typeof password !== 'string' || password.length === 0 || password.length > 128) {
    return res.status(400).json({ error: 'Phone and password are required.', code: 'VALIDATION_ERROR' });
  }

  try {
    const user = await prisma.user.findUnique({
      where: { phone },
      include: { profile: true, wallets: true },
    });
    if (!user || !(await bcrypt.compare(password, user.passwordHash))) {
      return res.status(401).json({ error: 'Invalid phone or password.', code: 'INVALID_CREDENTIALS' });
    }

    const result = await prisma.$transaction(async (tx) => {
      const tokens = await createSession(tx, user, req);
      await writeAudit(tx, user.id, 'USER_LOGIN', req);
      return tokens;
    });
    return respondWithAuth(res, 200, 'Signed in.', user, result);
  } catch (error) {
    console.error('Login failed:', error.message);
    return res.status(500).json({ error: 'Internal server error', code: 'INTERNAL_ERROR' });
  }
}

async function getProfile(req, res) {
  try {
    const user = await prisma.user.findUnique({
      where: { id: req.user.userId },
      include: { profile: true, wallets: true },
    });
    if (!user) return res.status(404).json({ error: 'User not found.', code: 'USER_NOT_FOUND' });
    return res.json(safeUser(user));
  } catch (error) {
    console.error('Profile read failed:', error.message);
    return res.status(500).json({ error: 'Internal server error', code: 'INTERNAL_ERROR' });
  }
}

async function updateProfile(req, res) {
  const data = {};
  if (Object.hasOwn(req.body ?? {}, 'fullName')) {
    if (typeof req.body.fullName !== 'string' || req.body.fullName.trim().length < 2 || req.body.fullName.trim().length > 100) {
      return res.status(400).json({ error: 'Full name must be between 2 and 100 characters.', code: 'VALIDATION_ERROR' });
    }
    data.fullName = req.body.fullName.trim();
  }
  if (Object.hasOwn(req.body ?? {}, 'email')) {
    const email = normalizeEmail(req.body.email);
    if (email === undefined) return res.status(400).json({ error: 'Email is invalid.', code: 'VALIDATION_ERROR' });
    data.email = email;
  }
  if (Object.keys(data).length === 0) {
    return res.status(400).json({ error: 'No editable profile fields supplied.', code: 'VALIDATION_ERROR' });
  }

  try {
    const user = await prisma.$transaction(async (tx) => {
      const updated = await tx.user.update({
        where: { id: req.user.userId },
        data,
        include: { profile: true, wallets: true },
      });
      await writeAudit(tx, updated.id, 'PROFILE_UPDATED', req);
      return updated;
    });
    return res.json(safeUser(user));
  } catch (error) {
    if (error.code === 'P2002') {
      return res.status(409).json({ error: 'Email is already in use.', code: 'EMAIL_ALREADY_EXISTS' });
    }
    if (error.code === 'P2025') {
      return res.status(404).json({ error: 'User not found.', code: 'USER_NOT_FOUND' });
    }
    console.error('Profile update failed:', error.message);
    return res.status(500).json({ error: 'Internal server error', code: 'INTERNAL_ERROR' });
  }
}

async function refreshSession(req, res) {
  const token = req.body?.refreshToken;
  if (typeof token !== 'string' || token.length > 4096) {
    return res.status(400).json({ error: 'Refresh token is required.', code: 'REFRESH_TOKEN_REQUIRED' });
  }

  let claims;
  try {
    claims = jwt.verify(token, process.env.JWT_REFRESH_SECRET, { algorithms: ['HS256'] });
  } catch {
    return res.status(401).json({ error: 'Refresh session is invalid or expired.', code: 'INVALID_REFRESH_TOKEN' });
  }
  if (!claims.userId || (claims.type && claims.type !== 'refresh')) {
    return res.status(401).json({ error: 'Refresh session is invalid or expired.', code: 'INVALID_REFRESH_TOKEN' });
  }

  const tokenHash = hashToken(token);
  try {
    const result = await prisma.$transaction(async (tx) => {
      // Raw-token fallback permits one-time rotation of sessions created by the prior version.
      const oldSession = await tx.userSession.findFirst({
        where: {
          userId: claims.userId,
          expiresAt: { gt: new Date() },
          OR: [{ refreshToken: tokenHash }, { refreshToken: token }],
        },
      });
      if (!oldSession) return null;

      const deleted = await tx.userSession.deleteMany({
        where: { id: oldSession.id, userId: claims.userId },
      });
      if (deleted.count !== 1) return null;

      const user = await tx.user.findUnique({
        where: { id: claims.userId },
        include: { profile: true, wallets: true },
      });
      if (!user) return null;

      const tokens = await createSession(tx, user, req);
      await writeAudit(tx, user.id, 'SESSION_REFRESHED', req);
      return { user, tokens };
    });

    if (!result) {
      return res.status(401).json({ error: 'Refresh session is invalid or expired.', code: 'INVALID_REFRESH_TOKEN' });
    }
    return respondWithAuth(res, 200, 'Session refreshed.', result.user, result.tokens);
  } catch (error) {
    console.error('Session refresh failed:', error.message);
    return res.status(500).json({ error: 'Internal server error', code: 'INTERNAL_ERROR' });
  }
}

async function logout(req, res) {
  const token = req.body?.refreshToken;
  if (typeof token !== 'string' || token.length > 4096) {
    return res.status(400).json({ error: 'Refresh token is required.', code: 'REFRESH_TOKEN_REQUIRED' });
  }
  let claims;
  try {
    claims = jwt.verify(token, process.env.JWT_REFRESH_SECRET, { algorithms: ['HS256'] });
  } catch {
    return res.status(204).end();
  }
  if (!claims.userId) return res.status(204).end();

  try {
    const deleted = await prisma.userSession.deleteMany({
      where: {
        userId: claims.userId,
        OR: [{ refreshToken: hashToken(token) }, { refreshToken: token }],
      },
    });
    if (deleted.count > 0) {
      await writeAudit(prisma, claims.userId, 'USER_LOGOUT', req);
    }
    return res.status(204).end();
  } catch (error) {
    console.error('Logout failed:', error.message);
    return res.status(500).json({ error: 'Internal server error', code: 'INTERNAL_ERROR' });
  }
}

async function logoutAll(req, res) {
  try {
    const deleted = await prisma.userSession.deleteMany({ where: { userId: req.user.userId } });
    await writeAudit(prisma, req.user.userId, 'USER_LOGOUT_ALL', req);
    return res.json({ revokedSessions: deleted.count });
  } catch (error) {
    console.error('Logout-all failed:', error.message);
    return res.status(500).json({ error: 'Internal server error', code: 'INTERNAL_ERROR' });
  }
}

module.exports = {
  register,
  login,
  getProfile,
  updateProfile,
  refreshSession,
  logout,
  logoutAll,
  normalizePhone,
  hashToken,
};
