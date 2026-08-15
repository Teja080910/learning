import React from "react";
import { Link } from "react-router-dom";
import { Box, Button, Card, CardContent, Container, Grid, Typography } from "@mui/material";
import CodeIcon from "@mui/icons-material/Code";
import TimerIcon from "@mui/icons-material/Timer";
import ShoppingCartIcon from "@mui/icons-material/ShoppingCart";
import PersonIcon from "@mui/icons-material/Person";
import { useAuth } from "../lib/AuthContext";

const Home = (props) => {
    const { user } = useAuth();

    const pages = [
        {
            title: "Props",
            description: "See how data flows from a parent component into a child component.",
            icon: <CodeIcon fontSize="large" color="primary" />,
            to: "/props",
        },
        {
            title: "Timer",
            description: "A stopwatch built with useState and useEffect, wired to the backend API.",
            icon: <TimerIcon fontSize="large" color="secondary" />,
            to: "/timer",
        },
        {
            title: "Orders",
            description: "Create and browse orders stored in PostgreSQL through the Express API.",
            icon: <ShoppingCartIcon fontSize="large" color="primary" />,
            to: "/orders",
        },
    ];

    return (
        <Box
            sx={{
                minHeight: "calc(100vh - 64px)",
                background: "linear-gradient(160deg, #2f6fed 0%, #7c3aed 100%)",
                py: 10,
            }}
        >
            <Container maxWidth="lg">
                <Box sx={{ textAlign: "center", color: "white", mb: 8 }}>
                    <Typography variant="h2" component="h1" gutterBottom>
                        Welcome, {user ? user.username : props.name}!
                    </Typography>
                    <Typography variant="h6" sx={{ fontWeight: 400, maxWidth: 640, mx: "auto", opacity: 0.9 }}>
                        A learning project exploring the full stack: React with Material UI on the
                        frontend, Express and PostgreSQL on the backend.
                    </Typography>
                    <Box sx={{ mt: 4, display: "flex", gap: 2, justifyContent: "center", flexWrap: "wrap" }}>
                        {!user && (
                            <Button
                                component={Link}
                                to="/register"
                                variant="contained"
                                color="secondary"
                                size="large"
                            >
                                Get started
                            </Button>
                        )}
                        <Button
                            component={Link}
                            to="/timer"
                            variant={user ? "contained" : "outlined"}
                            color={user ? "secondary" : "inherit"}
                            size="large"
                            sx={user ? undefined : { borderColor: "white", color: "white", "&:hover": { borderColor: "white", bgcolor: "rgba(255,255,255,0.1)" } }}
                        >
                            Try the timer
                        </Button>
                    </Box>
                </Box>

                <Grid container spacing={4}>
                    {pages.map((page) => (
                        <Grid item xs={12} sm={6} md={4} key={page.title}>
                            <Card sx={{ height: "100%", display: "flex", flexDirection: "column" }}>
                                <CardContent sx={{ flexGrow: 1 }}>
                                    <Box sx={{ mb: 2 }}>{page.icon}</Box>
                                    <Typography variant="h5" gutterBottom>
                                        {page.title}
                                    </Typography>
                                    <Typography variant="body1" color="text.secondary">
                                        {page.description}
                                    </Typography>
                                </CardContent>
                                <Box sx={{ p: 2, pt: 0 }}>
                                    <Button component={Link} to={page.to} variant="contained" fullWidth>
                                        Open {page.title}
                                    </Button>
                                </Box>
                            </Card>
                        </Grid>
                    ))}
                </Grid>

                <Box sx={{ display: "flex", justifyContent: "center", mt: 6 }}>
                    <Button
                        component={Link}
                        to="/login"
                        variant="outlined"
                        startIcon={<PersonIcon />}
                        sx={{ borderColor: "white", color: "white", "&:hover": { borderColor: "white", bgcolor: "rgba(255,255,255,0.1)" } }}
                    >
                        {user ? "Switch account" : "Login to your account"}
                    </Button>
                </Box>
            </Container>
        </Box>
    );
};

export default Home;
