module.exports = {
  apps: [{
    name: 'opusclean',
    cwd: '/home/opus/apps/facilitiesultima',
    script: 'dist/index.js',
    node_args: '-r dotenv/config --enable-source-maps',
    env: {
      NODE_ENV: 'production'
    }
  }]
}
