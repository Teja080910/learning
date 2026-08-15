import React from "react";
import { Container, Typography, Paper, Table, TableBody, TableCell, TableContainer, TableHead, TableRow } from "@mui/material";

const Props = (props) => {
    const rows = [
        { key: "Name", value: props.name },
        { key: "Age", value: props.age },
        { key: "City", value: props.city },
    ];

    return (
        <Container maxWidth="md" sx={{ py: 6 }}>
            <Typography variant="h3" component="h1" gutterBottom>
                Props Example
            </Typography>
            <Typography variant="body1" color="text.secondary" paragraph>
                This page receives the data object from App.js as props and renders it in a table.
            </Typography>
            <TableContainer component={Paper}>
                <Table>
                    <TableHead>
                        <TableRow>
                            <TableCell>Field</TableCell>
                            <TableCell>Value</TableCell>
                        </TableRow>
                    </TableHead>
                    <TableBody>
                        {rows.map((row) => (
                            <TableRow key={row.key}>
                                <TableCell component="th" scope="row" sx={{ fontWeight: 600 }}>
                                    {row.key}
                                </TableCell>
                                <TableCell>{row.value}</TableCell>
                            </TableRow>
                        ))}
                    </TableBody>
                </Table>
            </TableContainer>
        </Container>
    );
};

export default Props;
