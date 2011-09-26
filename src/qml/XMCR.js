.pragma library

var ZOOM_FIT_ALL = 0
var ZOOM_ACTUAL_SIZE = 1
var BASE_URL = 'http://xkcd.com/'
var JSON_API = 'info.0.json'
var URL = BASE_URL + JSON_API

function getUrl(num) {
    return BASE_URL + num + '/' + JSON_API
}
