import { pool } from '../lib/db.js';

const CreateOrder = async (orderData) => {
    const { userId, item, amount } = orderData;

    if (!item || amount === undefined || amount === null) {
        const error = new Error('item and amount are required');
        error.status = 400;
        throw error;
    }

    const numericAmount = Number(amount);
    if (Number.isNaN(numericAmount) || numericAmount < 0) {
        const error = new Error('amount must be a non-negative number');
        error.status = 400;
        throw error;
    }

    const { rows } = await pool.query(
        'INSERT INTO orders (user_id, item, amount) VALUES ($1, $2, $3) RETURNING *',
        [userId || null, item, numericAmount]
    );
    return rows[0];
};

export default CreateOrder;
