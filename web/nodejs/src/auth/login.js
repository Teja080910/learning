import bcrypt from 'bcryptjs';
import { pool } from '../lib/db.js';

// Verifies credentials and returns the user (without the password hash).
const Login = async (data) => {
    const { email, password } = data;

    if (!email || !password) {
        const error = new Error('Email and password are required');
        error.status = 400;
        throw error;
    }

    const { rows } = await pool.query(
        'SELECT id, username, email, password, created_at FROM users WHERE email = $1',
        [email]
    );

    const user = rows[0];
    if (!user) {
        const error = new Error('Invalid email or password');
        error.status = 401;
        throw error;
    }

    const valid = await bcrypt.compare(password, user.password);
    if (!valid) {
        const error = new Error('Invalid email or password');
        error.status = 401;
        throw error;
    }

    const { password: _password, ...safeUser } = user;
    return safeUser;
};

export default Login;
