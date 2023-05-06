require('dotenv').config();
let bodyParser = require('body-parser');
let express = require('express');
let app = express();

console.log('Hello World');



app.use('/public', express.static(__dirname + '/public'));



app.use(function(req, res, next) {
	const string = req.method + " " + req.path + " - " + req.ip;
	console.log(string);
	next();
});



app.use(bodyParser.urlencoded({extended: false}));



const nameQueryHandler = function(req, res) {
	const fullname = req.query.first + ' ' + req.query.last;
	const data = {name: fullname};
	res.json(data);
};
const nameBodyHandler = function(req, res) {
	const fullname = req.body.first + ' ' + req.body.last;
	const data = {name: fullname};
	res.json(data);
}
app.route('/name').get(nameQueryHandler).post(nameBodyHandler);



app.get('/:word/echo', function(req, res) {
	const data = {echo: req.params.word};
	res.json(data);
});



app.get('/now', function(req, res, next) {
	req.time = new Date().toString();
	next();
}, function(req, res) {
	const data = {time: req.time};
	res.json(data);
});



app.get('/json', function(req, res) {
	const message = (process.env.MESSAGE_STYLE === 'uppercase') ? "HELLO JSON" : "Hello json";
	const data = {message: message};
	res.json(data);
});



app.get('/', function(req, res) {
	const absolutePath = __dirname + '/views/index.html';
	res.sendFile(absolutePath);
});



module.exports = app;
