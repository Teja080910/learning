import { BrowserRouter, Route, Routes } from 'react-router-dom';
import './App.css';
import { Navbar } from './components/nav';
import Props from './components/props';
import Timer from './components/timer';

function App() {

  const data = {
    name: 'Teja',
    age: 23,
    city: 'Bangalore',
  }


  return (
    <div className="App">
      <Navbar />
      <BrowserRouter>
        <Routes>
          <Route path="/" element={<header className="App-header">
            <h1>Welcome to the React Frontend! {data.name}</h1>
          </header>} />
          <Route path="/props" element={<Props {...data} />} />
          <Route path="/timer" element={<Timer {...data} />} />
        </Routes>
      </BrowserRouter>
    </div>
  );
}

export default App;
