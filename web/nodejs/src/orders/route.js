import { Router } from 'express';
import CreateOrder from './create.order.js';

const router = Router();

router.get('/', (req, res) => {
    res.send('Hello from the orders route');
});

router.post('/create', async (req, res) => {
    try {
        const orderItem = await CreateOrder(req.body);
        console.log('Order created successfully with Item:', orderItem);
        res.send({
            message: 'Order created successfully',
            orderItem: orderItem
        });
    } catch (error) {
        console.error('Error creating order:', error);
        res.status(500).send('Error creating order');
    }
});

export default router;