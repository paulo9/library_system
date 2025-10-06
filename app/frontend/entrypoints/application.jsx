import React from "react";
import ReactDOM from "react-dom/client";
import App from "../components/App";

// Only render React app if the root element exists and has the necessary data
const rootElement = document.getElementById("root");
if (rootElement && window.booksData) {
  const root = ReactDOM.createRoot(rootElement);
  root.render(<App />);
}
