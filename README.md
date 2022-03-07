# VOODOO
Man in the Browser Framework

<p align="center">
    <br />
    <img src="./.github/voodoo.svg" width="80%" />
</p>

## Browser Support

| [<img src="https://raw.githubusercontent.com/alrra/browser-logos/master/src/edge/edge_48x48.png" alt="IE / Edge" width="24px" height="24px" />](http://godban.github.io/browsers-support-badges/)<br/>Edge | [<img src="https://raw.githubusercontent.com/alrra/browser-logos/master/src/chrome/chrome_48x48.png" alt="Chrome" width="24px" height="24px" />](http://godban.github.io/browsers-support-badges/)<br/>Chrome | [<img src="https://raw.githubusercontent.com/alrra/browser-logos/master/src/opera/opera_48x48.png" alt="Opera" width="24px" height="24px" />](http://godban.github.io/browsers-support-badges/)<br/>Opera |
| --------- | --------- | --------- |
| macOS only | macOS only | macOS only

## Quick Start

```rb
require 'voodoo'

browser = VOODOO::Browser.Chrome
browser.add_script 'alert("only on example.com")', matches: 'https://example.com/*'
browser.hijack 'https://example.com'
```

```rb
require 'voodoo'

browser = VOODOO::Browser.Chrome
browser.keylogger() {|event| puts event }
browser.hijack
```