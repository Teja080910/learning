import { Router } from "express";
import Login from "./login.js";
import Register from "./register.js";

const router = Router();

router.post('/register', async (req, res) => {
    const result = await Register(req.body);
    if (!result) {
        res.status(400).send('Error registering user');
        return;
    }
    console.log('User registered successfully:', result);
    res.send({
        message: 'User registered successfully',
        user: result
    });
});

router.post('/login', async (req, res) => {
    const result = await Login(req.body);
    if (!result) {
        res.status(400).send('Invalid email or password');
        return;
    }
    res.send('User logged in successfully');
});

export default router;