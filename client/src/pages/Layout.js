import React from 'react';
import Header from './Header';
import Footer from '../layouts/Footer';
import { Outlet } from "react-router-dom"

function Layout({ children }) {
  return (
    <div>
      <Header />
      <main>Outlet</main>
      <Footer />
    </div>
  );
}

export default Layout;