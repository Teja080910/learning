import React, { useCallback, useEffect, useState } from "react";
import { Link } from "react-router-dom";
import {
    Alert,
    Box,
    Button,
    Container,
    Paper,
    Stack,
    Table,
    TableBody,
    TableCell,
    TableContainer,
    TableHead,
    TableRow,
    TextField,
    Typography,
} from "@mui/material";
import { request } from "../lib/api";
import { useAuth } from "../lib/AuthContext";

const formatAmount = (amount) =>
    new Intl.NumberFormat("en-IN", { style: "currency", currency: "INR" }).format(Number(amount));

const formatDate = (date) => new Date(date).toLocaleString();

const Orders = () => {
    const { user } = useAuth();
    const [orders, setOrders] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);
    const [form, setForm] = useState({ item: "", amount: "" });
    const [creating, setCreating] = useState(false);

    const fetchOrders = useCallback(async () => {
        setLoading(true);
        setError(null);
        try {
            const query = user ? `?userId=${user.id}` : "";
            const data = await request(`/orders${query}`);
            setOrders(data);
        } catch (err) {
            setError(err.message);
        } finally {
            setLoading(false);
        }
    }, [user]);

    useEffect(() => {
        fetchOrders();
    }, [fetchOrders]);

    const handleChange = (e) => {
        setForm({ ...form, [e.target.name]: e.target.value });
    };

    const handleCreate = async (e) => {
        e.preventDefault();
        setCreating(true);
        setError(null);
        try {
            const data = await request("/orders/create", {
                method: "POST",
                body: JSON.stringify({
                    userId: user ? user.id : null,
                    item: form.item,
                    amount: Number(form.amount),
                }),
            });
            setOrders((prev) => [data.order, ...prev]);
            setForm({ item: "", amount: "" });
        } catch (err) {
            setError(err.message);
        } finally {
            setCreating(false);
        }
    };

    return (
        <Container maxWidth="md" sx={{ py: 6 }}>
            <Typography variant="h3" component="h1" gutterBottom>
                Orders
            </Typography>
            <Typography variant="body1" color="text.secondary" paragraph>
                {user
                    ? `Showing orders for ${user.username}.`
                    : "Showing all orders. Login to scope orders to your account."}
            </Typography>

            <Paper elevation={3} sx={{ p: 3, mb: 4 }}>
                <Typography variant="h6" gutterBottom>
                    Create an order
                </Typography>
                <Box component="form" onSubmit={handleCreate} noValidate>
                    <Stack direction={{ xs: "column", sm: "row" }} spacing={2}>
                        <TextField
                            label="Item"
                            name="item"
                            required
                            fullWidth
                            value={form.item}
                            onChange={handleChange}
                        />
                        <TextField
                            label="Amount"
                            name="amount"
                            type="number"
                            inputProps={{ min: 0, step: "0.01" }}
                            required
                            fullWidth
                            value={form.amount}
                            onChange={handleChange}
                        />
                        <Button
                            type="submit"
                            variant="contained"
                            disabled={creating}
                            sx={{ minWidth: 140 }}
                        >
                            {creating ? "Creating..." : "Create"}
                        </Button>
                    </Stack>
                </Box>
                {error && (
                    <Alert severity="error" sx={{ mt: 2 }}>
                        {error}
                    </Alert>
                )}
            </Paper>

            {loading ? (
                <Typography color="text.secondary">Loading orders...</Typography>
            ) : orders.length === 0 ? (
                <Paper variant="outlined" sx={{ p: 4, textAlign: "center" }}>
                    <Typography variant="h6" gutterBottom>
                        No orders yet
                    </Typography>
                    <Typography variant="body2" color="text.secondary">
                        Create your first order above to see it here.
                    </Typography>
                </Paper>
            ) : (
                <TableContainer component={Paper}>
                    <Table>
                        <TableHead>
                            <TableRow>
                                <TableCell>Item</TableCell>
                                <TableCell align="right">Amount</TableCell>
                                <TableCell>Created</TableCell>
                            </TableRow>
                        </TableHead>
                        <TableBody>
                            {orders.map((order) => (
                                <TableRow key={order.id}>
                                    <TableCell sx={{ fontWeight: 600 }}>{order.item}</TableCell>
                                    <TableCell align="right">{formatAmount(order.amount)}</TableCell>
                                    <TableCell>{formatDate(order.created_at)}</TableCell>
                                </TableRow>
                            ))}
                        </TableBody>
                    </Table>
                </TableContainer>
            )}

            {!user && (
                <Box sx={{ mt: 3, textAlign: "center" }}>
                    <Button component={Link} to="/login" variant="outlined">
                        Login to manage your orders
                    </Button>
                </Box>
            )}
        </Container>
    );
};

export default Orders;
