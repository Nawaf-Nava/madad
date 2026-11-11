const express = require('express');
const prisma = require('../db');
const authenticateToken = require('../middleware/auth');

const router = express.Router();

router.get('/', authenticateToken, async (req, res) => {
  try {
    const wallets = await prisma.wallet.findMany({ where: { userId: req.user.userId } });
    return res.json(wallets);
  } catch (error) {
    console.error('Wallet list failed:', error.message);
    return res.status(500).json({ error: 'Internal server error', code: 'INTERNAL_ERROR' });
  }
});

router.post('/transfer', authenticateToken, async (req, res) => {
  return res.status(503).json({
    error: 'Transfers are unavailable until an authorized financial provider is configured',
    code: 'FINANCIAL_PROVIDER_UNAVAILABLE',
  });
});

router.post('/payments', authenticateToken, async (req, res) => {
  return res.status(503).json({
    error: 'Payments are unavailable until an authorized payment provider is configured.',
    code: 'FINANCIAL_PROVIDER_UNAVAILABLE',
  });
});

router.get('/transactions', authenticateToken, async (req, res) => {
  try {
    const txs = await prisma.transaction.findMany({
      where: { userId: req.user.userId },
      orderBy: { createdAt: 'desc' }
    });
    return res.json(txs);
  } catch (error) {
    console.error('Transaction list failed:', error.message);
    return res.status(500).json({ error: 'Internal server error', code: 'INTERNAL_ERROR' });
  }
});

router.get('/:walletId', authenticateToken, async (req, res) => {
  try {
    const wallet = await prisma.wallet.findFirst({
      where: { id: req.params.walletId, userId: req.user.userId },
    });
    if (!wallet) {
      return res.status(404).json({ error: 'Wallet not found.', code: 'WALLET_NOT_FOUND' });
    }
    return res.json(wallet);
  } catch (error) {
    console.error('Wallet read failed:', error.message);
    return res.status(500).json({ error: 'Internal server error', code: 'INTERNAL_ERROR' });
  }
});

module.exports = router;
