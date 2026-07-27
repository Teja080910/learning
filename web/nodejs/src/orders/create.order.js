import { pool } from "../lib/db.js";

const CreateOrder = async (orderData) => {
    const { userId, item, totalAmount } = orderData;
    const query = 'INSERT INTO orders (userid, item, amount) VALUES ($1, $2, $3) RETURNING item';
    const values = [userId, item, totalAmount];

    try {
        const { rows } = await pool.query(query, values);
        return rows[0].item; // Return the item of the newly created order
    } catch (error) {
        console.error('Error creating order:', error);
        throw new Error('Error creating order');
    }
}

export default CreateOrder;