.pragma library

var BASE_URL = 'http://xkcd.com/'
var JSON_API = 'info.0.json'
var URL = BASE_URL + JSON_API
var REFRESH_TIMEOUT = 3000

function getAPIUrl(num) {
    return getUrl(num) + '/' + JSON_API
}

function getUrl(num) {
    return BASE_URL + num
}

function getRandomStripNumber(latestNumber) {
    return Math.ceil(Math.random() * latestNumber) + 1
}
