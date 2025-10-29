module.exports = {
  apps: [{
    name: 'opusclean',
    cwd: '/home/opus/apps/facilitiesultima',
    script: 'dist/index.js',                   // ← roda o build diretamente
    node_args: '-r dotenv/config --enable-source-maps',   // ← carrega .env antes de tudo
    env: { NODE_ENV: 'production' }            // outras variáveis estáticas, se quiser
  }]
}
