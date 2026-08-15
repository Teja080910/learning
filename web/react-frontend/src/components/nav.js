import React from "react";
import { Link, useNavigate } from "react-router-dom";
import {
    AppBar,
    Toolbar,
    Box,
    Button,
    IconButton,
    Typography,
    useMediaQuery,
    useTheme,
} from "@mui/material";
import TimerIcon from "@mui/icons-material/Timer";
import { useAuth } from "../lib/AuthContext";

export const Navbar = () => {
    const { user, logout } = useAuth();
    const navigate = useNavigate();
    const theme = useTheme();
    const isMobile = useMediaQuery(theme.breakpoints.down("sm"));

    const handleLogout = () => {
        logout();
        navigate("/");
    };

    const linkSx = {
        color: "inherit",
        textDecoration: "none",
        fontWeight: 600,
        "&:hover": { opacity: 0.85 },
    };

    return (
        <AppBar position="sticky" color="primary" elevation={2}>
            <Toolbar sx={{ gap: isMobile ? 1 : 3 }}>
                <IconButton
                    component={Link}
                    to="/"
                    color="inherit"
                    edge="start"
                    aria-label="Home"
                    sx={{ p: 1 }}
                >
                    <TimerIcon />
                </IconButton>
                <Typography variant="h6" component="div" sx={{ flexGrow: 1 }}>
                    <Link to="/" style={{ color: "inherit", textDecoration: "none" }}>
                        Learning App
                    </Link>
                </Typography>
                <Box sx={{ display: "flex", gap: isMobile ? 1 : 2 }}>
                    <Button component={Link} to="/props" sx={linkSx}>
                        Props
                    </Button>
                    <Button component={Link} to="/timer" sx={linkSx}>
                        Timer
                    </Button>
                    <Button component={Link} to="/orders" sx={linkSx}>
                        Orders
                    </Button>
                </Box>
                {user ? (
                    <Box sx={{ display: "flex", alignItems: "center", gap: 1 }}>
                        <Typography variant="body2" sx={{ display: isMobile ? "none" : "block" }}>
                            Hi, {user.username}
                        </Typography>
                        <Button color="inherit" variant="outlined" onClick={handleLogout} size="small">
                            Logout
                        </Button>
                    </Box>
                ) : (
                    <Button component={Link} to="/login" color="inherit" variant="outlined" size="small">
                        Login
                    </Button>
                )}
            </Toolbar>
        </AppBar>
    );
};
