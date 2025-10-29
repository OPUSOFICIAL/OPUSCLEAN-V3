import 'dotenv/config'
const { default: app } = await import('./dist/index.js')  // importa a app
const PORT = process.env.PORT || 3007
app.listen(PORT, () => console.log('API up on :' + PORT))
