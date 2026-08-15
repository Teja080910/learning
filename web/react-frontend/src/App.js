import { BrowserRouter, Route, Routes } from 'react-router-dom';
import { ThemeProvider, CssBaseline } from '@mui/material';
import theme from './theme';
import './App.css';
import { AuthProvider } from './lib/AuthContext';
import { Navbar } from './components/nav';
import Home from './components/home';
import Props from './components/props';
import Timer from './components/timer';
import Login from './components/login';
import Register from './components/register';
import Orders from './components/orders';

function App() {

  const data = {
    name: 'Teja',
    age: 23,
    city: 'Bangalore',
  };

  return (
    <ThemeProvider theme={theme}>
      <CssBaseline />
      <AuthProvider>
        <BrowserRouter>
          <Navbar />
          <Routes>
            <Route path="/" element={<Home {...data} />} />
            <Route path="/props" element={<Props {...data} />} />
            <Route path="/timer" element={<Timer {...data} />} />
            <Route path="/login" element={<Login />} />
            <Route path="/register" element={<Register />} />
            <Route path="/orders" element={<Orders />} />
          </Routes>
        </BrowserRouter>
      </AuthProvider>
    </ThemeProvider>
  );
}

export default App;
