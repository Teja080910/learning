const Login = (data) => {
    const { email, password } = data;
    console.log('Logging in user:', email, password);
    const query = `SELECT * FROM users WHERE email = $1 AND password = $2`;
    const executeQuery = async () => {
        try {
            const { rows } = await pool.query(query, [email, password]);
            if (rows.length > 0) {
                console.log('User logged in successfully:', rows[0]);
                return rows[0];
            } else {
                console.log('Invalid email or password');
                return null;
            }
        } catch (error) {
            console.error('Error logging in user:', error);
            throw error;
        }
    };
    return executeQuery();
}

export default Login;