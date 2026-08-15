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
import cors from 'cors';
import express from 'express';
import authRoutes from './auth/route.js';
import orderRoutes from './orders/route.js';
import timerRoutes from './timer/route.js';

const app = express();
app.use(express.json());
app.use(cors());
app.use('/auth', authRoutes);
app.use('/orders', orderRoutes);
app.use('/timer', timerRoutes);

const PORT = process.env.PORT || 5000;

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

app.listen(PORT, () => {
    console.log('Server is running on port http://localhost:' + PORT);
});

export default app;