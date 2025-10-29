const path = require('path');

// carrega .env explicitamente a partir do diretório do app
require('dotenv').config({ path: path.join(__dirname, '.env') });

// importa o bundle ESM; ele próprio deve subir o servidor (app.listen)
import(path.join(__dirname, 'dist/index.js'))
  .catch((err) => {
    console.error('Falha ao importar dist/index.js:', err);
    process.exit(1);
  });
