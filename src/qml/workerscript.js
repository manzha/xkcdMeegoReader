.pragma library

WorkerScript.onMessage = function(message) {
    var xhr = new XMLHttpRequest;
    xhr.open("GET", message.url);
    xhr.onreadystatechange = function() {
        if (xhr.readyState == XMLHttpRequest.DONE) {
            WorkerScript.sendMessage({ response: xhr.responseText })
        }
    }
    xhr.send();
}
