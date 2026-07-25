import { pool } from "../lib/db.js";

const Register = (data) => {
    const { username, email, password } = data;
    console.log('Registering user:', username, email, password);
    const query = `INSERT INTO "user" (username, email, password) VALUES ($1, $2, $3) RETURNING *`;
    const executeQuery = async () => {
        try {
            const { rows } = await pool.query(query, [username, email, password]);
            console.log('User registered successfully:', rows[0]);
            return rows[0];
        } catch (error) {
            console.error('Error registering user:', error);
            throw error;
        }
    };
    return executeQuery();
}

export default Register;