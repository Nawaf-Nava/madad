const { afterEach, test } = require('node:test');
const assert = require('node:assert/strict');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');

process.env.JWT_SECRET = 'test-access-secret-for-madad-only-0001';
process.env.JWT_REFRESH_SECRET = 'test-refresh-secret-for-madad-only-0002';
process.env.NODE_ENV = 'test';

const prisma = require('../src/db');
const { createApp } = require('../src/app');
const patches = [];
function patch(target, key, value) {
  if (!patches.some((entry) => entry.target === target && entry.key === key)) {
    patches.push({ target, key, value: target[key] });
  }
  target[key] = value;
}
afterEach(() => {
  for (const { target, key, value } of patches.splice(0).reverse()) {
    target[key] = value;
  }
});

function createMemoryDb() {
  const users = new Map();
  const sessions = new Map();
  const wallets = new Map();
  const transactions = new Map();
  const audits = [];
  let nextId = 0;
  const newId = () => `test-${++nextId}`;

  const tx = {
    user: {
      async create({ data }) {
        if ([...users.values()].some((user) => user.phone === data.phone)) {
          const error = new Error('unique');
          error.code = 'P2002';
          throw error;
        }
        const user = {
          id: newId(),
          phone: data.phone,
          email: data.email ?? null,
          fullName: data.fullName,
          passwordHash: data.passwordHash,
          isVerified: false,
          createdAt: new Date(),
          profile: { id: newId(), userId: null },
          wallets: [],
        };
        user.profile.userId = user.id;
        for (const input of data.wallets.create ? [data.wallets.create] : []) {
          const wallet = {
            id: newId(),
            userId: user.id,
            ...input,
            createdAt: new Date(),
            updatedAt: new Date(),
          };
          wallets.set(wallet.id, wallet);
          user.wallets.push(wallet);
        }
        users.set(user.id, user);
        return user;
      },
      async findUnique({ where, include }) {
        const user = [...users.values()].find((item) =>
          where.id ? item.id === where.id : item.phone === where.phone);
        if (!user) return null;
        return include?.wallets || include?.profile ? user : user;
      },
      async update({ where, data }) {
        const user = users.get(where.id);
        if (!user) {
          const error = new Error('missing');
          error.code = 'P2025';
          throw error;
        }
        Object.assign(user, data);
        return user;
      },
    },
    userSession: {
      async create({ data }) {
        const session = { id: newId(), ...data };
        sessions.set(session.id, session);
        return session;
      },
      async findFirst({ where }) {
        return sessions.get(where.id) ?? [...sessions.values()].find((session) =>
          session.userId === where.userId &&
          session.expiresAt > new Date() &&
          (where.OR ?? []).some((option) => session.refreshToken === option.refreshToken));
      },
      async deleteMany({ where }) {
        let count = 0;
        for (const [id, session] of sessions) {
          const matchesId = !where.id || session.id === where.id;
          const matchesUser = !where.userId || session.userId === where.userId;
          const matchesToken = !where.OR || where.OR.some((option) => session.refreshToken === option.refreshToken);
          if (matchesId && matchesUser && matchesToken) {
            sessions.delete(id);
            count++;
          }
        }
        return { count };
      },
    },
    auditLog: {
      async create({ data }) {
        audits.push(data);
        return data;
      },
    },
    wallet: {
      async findMany({ where }) {
        return [...wallets.values()].filter((wallet) => wallet.userId === where.userId);
      },
      async findFirst({ where }) {
        const wallet = wallets.get(where.id);
        return wallet?.userId === where.userId ? wallet : null;
      },
    },
    transaction: {
      async findMany({ where }) {
        return [...transactions.values()].filter((item) => item.userId === where.userId);
      },
    },
  };
  patch(prisma, '$transaction', (callback) => callback(tx));
  patch(prisma, '$queryRaw', async () => 1);
  for (const [model, methods] of Object.entries(tx)) {
    for (const [method, handler] of Object.entries(methods)) patch(prisma[model], method, handler);
  }
  return { users, sessions, wallets, transactions, audits };
}

async function withServer(run) {
  const app = createApp();
  const server = await new Promise((resolve) => {
    const instance = app.listen(0, '127.0.0.1', () => resolve(instance));
  });
  try {
    await run(`http://127.0.0.1:${server.address().port}`);
  } finally {
    await new Promise((resolve) => server.close(resolve));
  }
}

const jsonPost = (url, body, token) => fetch(url, {
  method: 'POST',
  headers: {
    'content-type': 'application/json',
    ...(token ? { authorization: `Bearer ${token}` } : {}),
  },
  body: JSON.stringify(body),
});

test('register creates only an empty user-owned profile/wallet and hashed session', async () => {
  const db = createMemoryDb();
  await withServer(async (base) => {
    const response = await jsonPost(`${base}/api/auth/register`, {
      phone: '+967771234567',
      fullName: 'Test Account',
      password: 'a-long-test-password',
    });
    assert.equal(response.status, 201);
    const result = await response.json();
    assert.equal(result.user.phone, '+967771234567');
    assert.equal(db.users.size, 1);
    assert.equal(db.wallets.size, 1);
    assert.equal([...db.wallets.values()][0].userId, result.user.id);
    assert.equal(Number([...db.wallets.values()][0].balance), 0);
    assert.equal(db.sessions.size, 1);
    const storedSession = [...db.sessions.values()][0];
    assert.notEqual(storedSession.refreshToken, result.refreshToken);
    assert.equal(storedSession.refreshToken.length, 64);
    assert.equal(db.audits.some((item) => item.action === 'USER_REGISTERED'), true);

    const access = jwt.verify(result.accessToken, process.env.JWT_SECRET);
    assert.equal(access.userId, result.user.id);
    assert.equal(access.type, 'access');
    assert.equal(access.sid, storedSession.id);
  });
});

test('profile, wallet and transaction reads are scoped to the authenticated user', async () => {
  const db = createMemoryDb();
  await withServer(async (base) => {
    const register = await jsonPost(`${base}/api/auth/register`, {
      phone: '771234567', fullName: 'Owner One', password: 'long-test-password',
    });
    const { user, accessToken } = await register.json();
    const wallet = [...db.wallets.values()][0];

    let response = await fetch(`${base}/api/auth/profile`, {
      headers: { authorization: `Bearer ${accessToken}` },
    });
    assert.equal(response.status, 200);
    assert.equal((await response.json()).id, user.id);

    response = await fetch(`${base}/api/wallet/`, {
      headers: { authorization: `Bearer ${accessToken}` },
    });
    assert.equal(response.status, 200);
    assert.equal((await response.json())[0].id, wallet.id);

    response = await fetch(`${base}/api/wallet/${wallet.id}`, {
      headers: { authorization: `Bearer ${accessToken}` },
    });
    assert.equal(response.status, 200);

    response = await fetch(`${base}/api/wallet/transactions`, {
      headers: { authorization: `Bearer ${accessToken}` },
    });
    assert.equal(response.status, 200);
    assert.deepEqual(await response.json(), []);

    const otherAccess = jwt.sign(
      { userId: 'other-user', type: 'access' },
      process.env.JWT_SECRET,
      { expiresIn: '1m' },
    );
    response = await fetch(`${base}/api/wallet/${wallet.id}`, {
      headers: { authorization: `Bearer ${otherAccess}` },
    });
    assert.equal(response.status, 404); // Owner-scoped query hides another user's wallet.
  });
});

test('refresh rotates hashed session; logout revokes access and payments stay 503', async () => {
  const db = createMemoryDb();
  await withServer(async (base) => {
    const registration = await jsonPost(`${base}/api/auth/register`, {
      phone: '771234568', fullName: 'Owner Two', password: 'long-test-password',
    });
    const original = await registration.json();

    const refreshedResponse = await jsonPost(`${base}/api/auth/refresh`, {
      refreshToken: original.refreshToken,
    });
    assert.equal(refreshedResponse.status, 200);
    const refreshed = await refreshedResponse.json();
    assert.notEqual(refreshed.refreshToken, original.refreshToken);

    let response = await fetch(`${base}/api/auth/profile`, {
      headers: { authorization: `Bearer ${original.accessToken}` },
    });
    assert.equal(response.status, 401);

    response = await fetch(`${base}/api/wallet/transfer`, {
      method: 'POST',
      headers: { authorization: `Bearer ${refreshed.accessToken}`, 'content-type': 'application/json' },
      body: JSON.stringify({ recipientPhone: '771000000', amount: 12 }),
    });
    assert.equal(response.status, 503);
    assert.equal((await response.json()).code, 'FINANCIAL_PROVIDER_UNAVAILABLE');

    response = await fetch(`${base}/api/wallet/payments`, {
      method: 'POST',
      headers: { authorization: `Bearer ${refreshed.accessToken}`, 'content-type': 'application/json' },
      body: JSON.stringify({ amount: 12 }),
    });
    assert.equal(response.status, 503);
    assert.equal((await response.json()).code, 'FINANCIAL_PROVIDER_UNAVAILABLE');

    response = await jsonPost(`${base}/api/auth/logout`, {
      refreshToken: refreshed.refreshToken,
    });
    assert.equal(response.status, 204);
    response = await fetch(`${base}/api/auth/profile`, {
      headers: { authorization: `Bearer ${refreshed.accessToken}` },
    });
    assert.equal(response.status, 401);
    assert.equal(db.sessions.size, 0);
  });
});

test('authentication validation and rate-limit middleware are registered', async () => {
  createMemoryDb();
  await withServer(async (base) => {
    let response = await jsonPost(`${base}/api/auth/register`, {});
    assert.equal(response.status, 400);
    response = await jsonPost(`${base}/api/auth/login`, {});
    assert.equal(response.status, 400);
    for (let attempt = 0; attempt < 8; attempt++) {
      response = await jsonPost(`${base}/api/auth/login`, {});
      assert.equal(response.status, 400);
    }
    response = await jsonPost(`${base}/api/auth/login`, {});
    assert.equal(response.status, 429);
    response = await fetch(`${base}/api/wallet/`);
    assert.equal(response.status, 401);
    response = await fetch(`${base}/ready`);
    assert.equal(response.status, 200);
  });
});

test('profile update persists only the authenticated user fields', async () => {
  const db = createMemoryDb();
  await withServer(async (base) => {
    const registration = await jsonPost(`${base}/api/auth/register`, {
      phone: '771234569', fullName: 'Owner Three', password: 'long-test-password',
    });
    const { user, accessToken } = await registration.json();
    const response = await fetch(`${base}/api/auth/profile`, {
      method: 'PATCH',
      headers: {
        authorization: `Bearer ${accessToken}`,
        'content-type': 'application/json',
      },
      body: JSON.stringify({ fullName: 'Updated Owner', email: 'owner@example.test' }),
    });
    assert.equal(response.status, 200);
    const updated = await response.json();
    assert.equal(updated.id, user.id);
    assert.equal(updated.fullName, 'Updated Owner');
    assert.equal(updated.email, 'owner@example.test');
    assert.equal(db.audits.some((item) => item.action === 'PROFILE_UPDATED'), true);
  });
});

test('login rejects an incorrect password and never creates a session', async () => {
  const db = createMemoryDb();
  const passwordHash = await bcrypt.hash('correct-test-password', 4);
  const user = {
    id: 'existing-test-user',
    phone: '771234570',
    passwordHash,
    fullName: 'Existing User',
    isVerified: false,
    profile: null,
    wallets: [],
  };
  db.users.set(user.id, user);
  await withServer(async (base) => {
    const response = await jsonPost(`${base}/api/auth/login`, {
      phone: user.phone,
      password: 'incorrect-test-password',
    });
    assert.equal(response.status, 401);
    assert.equal(db.sessions.size, 0);
  });
});
