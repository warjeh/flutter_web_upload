var express = require('express');
var multer = require('multer');
var cors = require('cors');

var app = express();

// Middleware to enable CORS .
app.use(cors());

// Root path
app.get('/', function (req, res) {
  res.sendFile(__dirname + '/index.html');
})

// ---------------------
// Upload
// ---------------------
// Set uploaded file destination path 
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, './uploads')
  },
  filename: function (req, file, cb) {
    const fileName = Date.now() + '-' + file.originalname
    cb(null, fileName)
  }
});

// Multer for handling multipart/form-data
const uploadMiddleware = multer({ storage: storage }).single('file');

// Upload path
app.post('/api/files/upload', uploadMiddleware, function (req, res) {
  res.json({ message: `File ${req.file?.filename} uploaded successfully!` });
});

app.listen(3000, function () {
  console.log('Server is running on port 3000');
});  