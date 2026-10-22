import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import App from './App.tsx'
import './index.css'
const MENU_FONTS = ['16px "tabler-icons"', '900 16px "Font Awesome 6 Free"', '400 16px "Font Awesome 6 Free"', '400 16px "Font Awesome 6 Brands"', '400 13px Poppins', '500 13px Poppins', '600 13px Poppins'];
MENU_FONTS.forEach(font => { document.fonts?.load(font).catch(() => undefined); });
const root = document.getElementById('root');

createRoot(root!).render(
  <StrictMode>
    <App />
  </StrictMode>
)