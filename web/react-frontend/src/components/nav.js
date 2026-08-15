import React from "react"
import { Stack } from "@mui/material"

export const Navbar = () => {
    return (
        <Stack direction="row" spacing={2} className="navbar">
            <li>
                <a href="/">Home</a>
            </li>
            <li>
                <a href="/props">Props Example</a>
            </li>
            <li>
                <a href="/timer">Timer Example</a>
            </li>
        </Stack>
    )
}