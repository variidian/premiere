// @ts-check
import { defineConfig } from 'astro/config';
import tailwindcss from '@tailwindcss/vite';

export default defineConfig({
  vite: {
    plugins: [tailwindcss()],
    server: {
      proxy: {
        '/api': { //pattern match for find '/api'
          target: 'http://localhost:3000', //forward req to rails server
          changeOrigin: true, //make req pretend it comes from :3000 instead of :4321 so the server accepts the request 
          rewrite: (path) => path.replace(/^\/api/, '') // find '/api' at the start of the string and remove it
        }
      }
    }
  }
});