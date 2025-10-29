import { config } from 'dotenv';

// Carrega .env ANTES de importar o bundle
config({ path: '/home/opus/apps/facilitiesultima/.env' });

// Defaults seguros (se faltar no .env)
if (!process.env.PORT) process.env.PORT = '3007';

// Agora sim importe seu bundle; se ele mesmo der app.listen(), beleza.
// Se seu bundle exporta algo, ainda assim o import acima já executa o top-level.
await import('./dist/index.js');

console.log('Launcher: env carregado e bundle importado. PORT=', process.env.PORT);
