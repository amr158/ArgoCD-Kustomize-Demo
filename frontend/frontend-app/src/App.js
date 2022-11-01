import logo from './logo.svg';
import './App.css';
import React, { useEffect, useState } from "react"

function App() {
  const [Data, setData] = useState([])
  const fetchData = () => {
    fetch("/api")
    .then((response) => response.text().then(data => {setData(data)}))
  }
  useEffect(() => {
    fetchData()
  }, [])
  
  return (
    <div className="App">
      <header className="App-header">
        <img src={logo} className="App-logo" alt="logo" />
        <p>
          {Data}
        </p>
      </header>
    </div>
  );
}

export default App;
