const express = require('express')
const bodyParser = require('body-parser');
const app = express()
const port = 3000

app.use("*/js", express.static("public/js"));
app.use("*/css", express.static("public/css"));
app.use("*/images", express.static("public/images"));
app.use("*/font", express.static("public/font"));
app.use(bodyParser.urlencoded({ extended: true }));
app.set("view engine", "ejs");

app.get('/', (req, res) => {
  res.render("index");
})

app.get('/layers', (req, res) => {
  res.render("layers");
})

app.listen(port, () => {
  console.log(`Example app listening on port ${port}`)
})