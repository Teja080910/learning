import { Router } from 'express';
import Login from './login.js';
import Register from './register.js';

const router = Router();

router.post('/register', async (req, res) => {
    try {
        const user = await Register(req.body);
        res.status(201).json({
            message: 'User registered successfully',
            user
        });
    } catch (error) {
        res.status(error.status || 500).json({ error: error.message });
    }
});

router.post('/login', async (req, res) => {
    try {
        const user = await Login(req.body);
        res.json({
            message: 'User logged in successfully',
            user
        });
    } catch (error) {
        res.status(error.status || 500).json({ error: error.message });
    }
});

export default router;
