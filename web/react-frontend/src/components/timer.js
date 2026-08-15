import { useEffect, useState } from 'react';
import { createTimer } from '../lib/api-functions/timer';
import { Alert, Box, Button, Container, Paper, Stack, Typography } from '@mui/material';

const formatTime = (seconds) => {
    const m = String(Math.floor(seconds / 60)).padStart(2, '0');
    const s = String(seconds % 60).padStart(2, '0');
    return `${m}:${s}`;
};

const Timer = (props) => {
    const [time, setTime] = useState(0);
    const [isRunning, setIsRunning] = useState(false);
    const [message, setMessage] = useState(null);
    const [error, setError] = useState(null);
    const [submitting, setSubmitting] = useState(false);

    useEffect(() => {
        let interval;
        if (isRunning) {
            interval = setInterval(() => {
                setTime((prevTime) => prevTime + 1);
            }, 1000);
        }
        return () => clearInterval(interval);
    }, [isRunning]);

    const handleStart = () => {
        setMessage(null);
        setError(null);
        setIsRunning(true);
    };

    const handleStop = () => {
        setIsRunning(false);
    };

    const handleReset = () => {
        setIsRunning(false);
        setTime(0);
        setMessage(null);
        setError(null);
    };

    const handleSubmit = async () => {
        setSubmitting(true);
        setError(null);
        try {
            const data = await createTimer(time);
            setMessage(data.message);
        } catch (err) {
            setError(err.message);
        } finally {
            setSubmitting(false);
        }
    };

    const concepts = [
        'Set up react js (basic concepts)',
        'React components and props',
        'React state and lifecycle',
        'React hooks (useState, useEffect)',
        'React events',
        'React router',
        'API Integration',
        'Material UI',
    ];

    return (
        <Container maxWidth="md" sx={{ py: 6 }}>
            <Typography variant="h3" component="h1" gutterBottom>
                Timer Example
            </Typography>
            <Typography variant="body1" color="text.secondary" paragraph>
                Hi {props.name}! A stopwatch built with React state, posting the final time to the
                backend when you submit.
            </Typography>

            <Paper elevation={3} sx={{ p: 4, textAlign: 'center', mb: 4 }}>
                <Typography variant="h2" component="div" sx={{ fontVariantNumeric: 'tabular-nums', mb: 3 }}>
                    {formatTime(time)}
                </Typography>
                <Stack direction="row" spacing={2} justifyContent="center">
                    <Button variant="contained" color="primary" onClick={handleStart} disabled={isRunning}>
                        Start
                    </Button>
                    <Button variant="contained" color="secondary" onClick={handleStop} disabled={!isRunning}>
                        Stop
                    </Button>
                    <Button variant="contained" color="error" onClick={handleReset}>
                        Reset
                    </Button>
                </Stack>

                <Box sx={{ mt: 3 }}>
                    <Button variant="outlined" color="primary" onClick={handleSubmit} disabled={submitting || isRunning}>
                        {submitting ? 'Sending...' : 'Send time to backend'}
                    </Button>
                </Box>

                {message && (
                    <Alert severity="success" sx={{ mt: 3 }}>
                        {message}
                    </Alert>
                )}
                {error && (
                    <Alert severity="error" sx={{ mt: 3 }}>
                        {error}
                    </Alert>
                )}
            </Paper>

            <Typography variant="h4" component="h2" gutterBottom>
                Completed Concepts
            </Typography>
            <Stack direction="column" spacing={2}>
                {concepts.map((concept) => (
                    <Paper key={concept} variant="outlined" sx={{ px: 3, py: 2 }}>
                        <Typography variant="body1">{concept}</Typography>
                    </Paper>
                ))}
            </Stack>
        </Container>
    );
};

export default Timer;
