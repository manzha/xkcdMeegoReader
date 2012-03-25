/**************************************************************************
 *   XMCR
 *   Copyright (C) 2011 - 2012 Simon Pena <spena@igalia.com>
 *
 *   This program is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation, either version 3 of the License, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 **************************************************************************/

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
    return Math.floor(Math.random() * latestNumber)
}
