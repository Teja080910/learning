import dotenv from 'dotenv';
import express from 'express';
import formRoutes from './whatsapp-api/routes/form.route.js';

dotenv.config();

const app = express();
app.use(express.json());

app.get('/', (req, res) => {
  res.json({ message: 'Server is running' });
});

app.use('/api', formRoutes);

app.listen(3000, () => {
  console.log('Server running on port http://localhost:3000');
});
