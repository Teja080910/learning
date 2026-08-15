import bcrypt from 'bcryptjs';
import { pool } from '../lib/db.js';

// Registers a new user with a hashed password.
const Register = async (data) => {
    const { username, email, password } = data;

    if (!username || !email || !password) {
        const error = new Error('Username, email and password are required');
        error.status = 400;
        throw error;
    }

    const existing = await pool.query(
        'SELECT id FROM users WHERE username = $1 OR email = $2',
        [username, email]
    );
    if (existing.rows.length > 0) {
        const error = new Error('Username or email already exists');
        error.status = 409;
        throw error;
    }

    const passwordHash = await bcrypt.hash(password, 10);
    const { rows } = await pool.query(
        'INSERT INTO users (username, email, password) VALUES ($1, $2, $3) RETURNING id, username, email, created_at',
        [username, email, passwordHash]
    );
    return rows[0];
};

export default Register;
