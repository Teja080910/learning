import React, { useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import { Alert, Box, Button, Container, Paper, TextField, Typography } from "@mui/material";
import { request } from "../lib/api";

const Register = () => {
    const [form, setForm] = useState({ username: "", email: "", password: "" });
    const [error, setError] = useState(null);
    const [success, setSuccess] = useState(null);
    const [submitting, setSubmitting] = useState(false);
    const navigate = useNavigate();

    const handleChange = (e) => {
        setForm({ ...form, [e.target.name]: e.target.value });
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        setError(null);
        setSuccess(null);
        setSubmitting(true);
        try {
            const data = await request("/auth/register", {
                method: "POST",
                body: JSON.stringify(form),
            });
            setSuccess(`Account created for ${data.user.username}. Redirecting to login...`);
            setTimeout(() => navigate("/login"), 1500);
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
                    Register
                </Typography>
                <Typography variant="body2" color="text.secondary" align="center" sx={{ mb: 3 }}>
                    Create an account to get started.
                </Typography>
                <Box component="form" onSubmit={handleSubmit} noValidate>
                    <TextField
                        label="Username"
                        name="username"
                        required
                        fullWidth
                        margin="normal"
                        autoComplete="username"
                        value={form.username}
                        onChange={handleChange}
                    />
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
                        autoComplete="new-password"
                        value={form.password}
                        onChange={handleChange}
                    />
                    {error && (
                        <Alert severity="error" sx={{ mt: 2 }}>
                            {error}
                        </Alert>
                    )}
                    {success && (
                        <Alert severity="success" sx={{ mt: 2 }}>
                            {success}
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
                        {submitting ? "Creating account..." : "Create account"}
                    </Button>
                </Box>
                <Typography variant="body2" align="center" sx={{ mt: 3 }}>
                    Already have an account? <Link to="/login">Sign in</Link>
                </Typography>
            </Paper>
        </Container>
    );
};

export default Register;
