const jwt = require('jsonwebtoken');
const prisma = require('../db');

async function authenticateToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  const [scheme, token, ...extra] = (authHeader || '').split(' ');
  if (scheme !== 'Bearer' || !token || extra.length > 0) {
    return res.status(401).json({ error: 'Access token required.', code: 'ACCESS_TOKEN_REQUIRED' });
  }

  let claims;
  try {
    claims = jwt.verify(token, process.env.JWT_SECRET, { algorithms: ['HS256'] });
  } catch {
    return res.status(401).json({ error: 'Access token is invalid or expired.', code: 'INVALID_ACCESS_TOKEN' });
  }

  if (!claims.userId || (claims.type && claims.type !== 'access')) {
    return res.status(401).json({ error: 'Access token is invalid or expired.', code: 'INVALID_ACCESS_TOKEN' });
  }

  try {
    // New access tokens are tied to the persisted refresh-session row. Deleting
    // or rotating that row revokes both access and refresh immediately.
    if (claims.sid) {
      const session = await prisma.userSession.findFirst({
        where: {
          id: claims.sid,
          userId: claims.userId,
          expiresAt: { gt: new Date() },
        },
        select: { id: true },
      });
      if (!session) {
        return res.status(401).json({ error: 'Session is no longer active.', code: 'SESSION_REVOKED' });
      }
    }
    req.user = { userId: claims.userId, phone: claims.phone, sessionId: claims.sid };
    return next();
  } catch (error) {
    console.error('Authentication session check failed:', error.message);
    return res.status(503).json({ error: 'Authentication service is unavailable.', code: 'AUTH_UNAVAILABLE' });
  }
}

module.exports = authenticateToken;
