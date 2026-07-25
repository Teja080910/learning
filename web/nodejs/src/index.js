/**
 * Nodejs (install nodejs  -> https://nodejs.org/en/download)
 * npm 
 * npm install pg
 * npm uninstall pg
 * npm update pg
 * npm install express
 * checking nodejs version -> node -v
 * checking npm version -> npm -v
 * intialize nodejs project -> npm init
 * How to run nodejs project -> node index.js
 */


// common js code
// const express = require('express');

// module.exports = express();


// module code
import express from 'express';
import cors from 'cors';
import Register from './auth/register.js';
import Login from './auth/login.js';

const app = express();
app.use(express.json());
app.use(cors());

const PORT = process.env.PORT || 3000;

// HTTP Methods
/**
 * Post -> create new resource
 * Get -> read resource
 * Put -> update resource
 * Delete -> delete resource
 * Patch -> update resource partially
 */

app.get('/', (req, res) => {
    res.send('Hello World');
});

app.post('/register', async (req, res) => {
    const result = await Register(req.body);
    if (!result) {
        res.status(400).send('Error registering user');
        return;
    }
    res.send('User registered successfully');
});

app.post('/login', async (req, res) => {
    const result = await Login(req.body);
    if (!result) {
        res.status(400).send('Invalid email or password');
        return;
    }
    res.send('User logged in successfully');
});

app.listen(PORT, () => {
    console.log('Server is running on port http://localhost:' + PORT);
});

export default app;