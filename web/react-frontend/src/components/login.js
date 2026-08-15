import React, { useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import { Alert, Box, Button, Container, Paper, TextField, Typography } from "@mui/material";
import { request } from "../lib/api";
import { useAuth } from "../lib/AuthContext";

const Login = () => {
    const [form, setForm] = useState({ email: "", password: "" });
    const [error, setError] = useState(null);
    const [submitting, setSubmitting] = useState(false);
    const { login } = useAuth();
    const navigate = useNavigate();

    const handleChange = (e) => {
        setForm({ ...form, [e.target.name]: e.target.value });
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        setError(null);
        setSubmitting(true);
        try {
            const data = await request("/auth/login", {
                method: "POST",
                body: JSON.stringify(form),
            });
            login(data.user);
            navigate("/");
        } catch (err) {
            setError(err.message);
        } finally {
            setSubmitting(false);
        }
    };

    return (
        <Container maxWidth="xs" sx={{ py: 8 }}>
            <Paper elevation={3} sx={{ p: 4 }}>
                <Typography variant="h4" component="h1" gutterBottom align="center">
                    Login
                </Typography>
                <Typography variant="body2" color="text.secondary" align="center" sx={{ mb: 3 }}>
                    Welcome back! Sign in to continue.
                </Typography>
                <Box component="form" onSubmit={handleSubmit} noValidate>
                    <TextField
                        label="Email"
                        name="email"
                        type="email"
                        required
                        fullWidth
                        margin="normal"
                        autoComplete="email"
                        value={form.email}
                        onChange={handleChange}
                    />
                    <TextField
                        label="Password"
                        name="password"
                        type="password"
                        required
                        fullWidth
                        margin="normal"
                        autoComplete="current-password"
                        value={form.password}
                        onChange={handleChange}
                    />
                    {error && (
                        <Alert severity="error" sx={{ mt: 2 }}>
                            {error}
                        </Alert>
                    )}
                    <Button
                        type="submit"
                        variant="contained"
                        fullWidth
                        size="large"
                        disabled={submitting}
                        sx={{ mt: 3 }}
                    >
                        {submitting ? "Signing in..." : "Sign in"}
                    </Button>
                </Box>
                <Typography variant="body2" align="center" sx={{ mt: 3 }}>
                    Don&apos;t have an account? <Link to="/register">Create one</Link>
                </Typography>
            </Paper>
        </Container>
    );
};

export default Login;
