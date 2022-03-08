# VOODOO
Man in the Browser Framework

<p align="center">
    <br />
    <img src="./.github/voodoo.svg" width="50%" />
</p>

## Browser Support

| [<img src="https://raw.githubusercontent.com/alrra/browser-logos/master/src/edge/edge_48x48.png" alt="IE / Edge" width="24px" height="24px" />](http://godban.github.io/browsers-support-badges/)<br/>Edge | [<img src="https://raw.githubusercontent.com/alrra/browser-logos/master/src/chrome/chrome_48x48.png" alt="Chrome" width="24px" height="24px" />](http://godban.github.io/browsers-support-badges/)<br/>Chrome | [<img src="https://raw.githubusercontent.com/alrra/browser-logos/master/src/opera/opera_48x48.png" alt="Opera" width="24px" height="24px" />](http://godban.github.io/browsers-support-badges/)<br/>Opera |
| --------- | --------- | --------- |
| macOS only | macOS only | macOS only

## Features
* 📜 Content Scripts - inject arbitrary JavaScript to user session
* 🔍 Interceptor - intercept all browser requests (url, headers, body, etc)
* 🔑 Keylogger - records user keystrokes on any site

## Requirements
* ruby >= 2.0.0
* rubygems >= 1.8
* thor ~> 1.2.1
* bundler >= 1.17

## Installation
```sh
$: git clone https://github.com/breakpointHQ/VOODOO.git
$: cd VOODOO
$: bundle install
$: ./scripts/build.sh
```

If you don't have the `/Users/[user]/.gem/ruby/[version]/bin` in your `PATH`, add it.

## CLI

```sh
$: voodoo
Commands:
  voodoo help [COMMAND]  # Describe available commands or one specific command
  voodoo hijack          # Hijack browser
  voodoo version         # Prints voodoo version
```

```sh
$: voodoo help hijack
Usage:
  voodoo hijack

Options:
  j, [--js=JS]                
  i, [--intercept=key:value]  
  k, [--keylogger=key:value]  
  b, [--browser=BROWSER]      
                              # Default: chrome

Hijack browser
```