import { Router } from 'express';
import CreateOrder from './create.order.js';
import { pool } from '../lib/db.js';

const router = Router();

router.get('/', async (req, res) => {
    try {
        const userId = req.query.userId;
        if (userId) {
            const { rows } = await pool.query(
                'SELECT * FROM orders WHERE user_id = $1 ORDER BY created_at DESC',
                [userId]
            );
            return res.json(rows);
        }
        const { rows } = await pool.query('SELECT * FROM orders ORDER BY created_at DESC');
        res.json(rows);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

router.get('/:id', async (req, res) => {
    try {
        const { rows } = await pool.query('SELECT * FROM orders WHERE id = $1', [req.params.id]);
        if (rows.length === 0) {
            return res.status(404).json({ error: 'Order not found' });
        }
        res.json(rows[0]);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

router.post('/create', async (req, res) => {
    try {
        const order = await CreateOrder(req.body);
        res.status(201).json({
            message: 'Order created successfully',
            order
        });
    } catch (error) {
        res.status(error.status || 500).json({ error: error.message });
    }
});

export default router;
