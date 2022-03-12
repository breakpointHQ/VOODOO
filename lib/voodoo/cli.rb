require 'thor'
require 'json'
require 'yaml'
require 'voodoo/output'
require 'voodoo/browser'

module VOODOO

    VERSION = 'v0.0.9'

    class CLI < Thor

        desc 'version', 'Prints voodoo version'
        def version
            puts VERSION
        end
        
        option :url_include, :type => :string, :aliases => :u, :default => nil
        option :body_include, :type => :string, :aliases => :i, :default => nil
        option :header_exists, :type => :string, :aliases => :h, :default => nil
        option :format, :type => :string, :aliases => :f, :default => 'pretty', :desc => 'pretty, json, payload'
        option :output, :type => :string, :aliases => :o, :desc => 'File path', :default => nil
        option :urls, :type => :array, :aliases => :x, :default => []
        option :matches, :type => :array, :aliases => :m, :default => ['<all_urls>']
        option :browser, :type => :string, :aliases => :b, :default => 'chrome'
        option :max_events, :type => :numeric, :default => nil
        desc 'intercept', 'Intercept browser requests'
        def intercept
            browser = get_browser options[:browser]
            output_handler = Output.new(file: options[:output], in_format: options[:format], for_command: 'intercept')

            browser.intercept(matches: options[:matches],
                              url_include: options[:url_include],
                              body_include: options[:body_include],
                              max_events: options[:max_events]) do |event|
                output_handler.handle(event)
            end

            browser.hijack options[:urls]
        end

        option :urls, :type => :array, :aliases => :x, :default => []
        option :format, :type => :string, :aliases => :f, :default => 'pretty', :desc => 'pretty, json, payload, none'
        option :output, :type => :string, :aliases => :o, :desc => 'File path', :default => nil
        option :params, :type => :hash,:aliases => :p, :default => {}
        option :matches, :type => :array, :aliases => :m, :default => ['*://*/*']
        option :browser, :type => :string, :aliases => :b, :default => 'chrome'
        option :permissions, :type => :array, :aliases => :p, :default => []
        option :max_events, :type => :numeric, :default => nil
        desc 'script <js/path>', 'Add a content script'
        def script(path_or_js)
            browser = get_browser options[:browser]
            browser.add_permissions options[:permissions]
            output_handler = Output.new(file: options[:output], in_format: options[:format], for_command: 'script')

            file = nil
            content = nil

            if File.exists? path_or_js
                file = path_or_js
            else
                content = path_or_js
            end

            if output_handler.writable
                browser.add_script file: file, content: content, options: options[:params], max_events: options[:max_events] do |event|
                    output_handler.handle(event)
                end
            else
                browser.add_script file: file, content: content, options: options[:params]
            end

            browser.hijack options[:urls]
        end
        
        option :urls, :type => :array, :aliases => :x, :default => []
        option :format, :type => :string, :aliases => :f, :default => 'pretty', :desc => 'pretty, json, payload'
        option :output, :type => :string, :aliases => :o, :desc => 'File path', :default => nil
        option :matches, :type => :array, :aliases => :m, :default => ['*://*/*']
        option :browser, :type => :string, :aliases => :b, :default => 'chrome'
        option :max_events, :type => :numeric, :default => nil
        desc 'keylogger', 'Records user keystrokes'
        def keylogger
            browser = get_browser options[:browser]
            output_handler = Output.new(file: options[:output], in_format: options[:format], for_command: 'keylogger')
            browser.keylogger(matches: options[:matches], max_events: options[:max_events]) do |event|
                output_handler.handle(event)
            end
            browser.hijack options[:urls]
        end

        option :browser, :type => :string, :aliases => :b, :default => nil
        option :format, :type => :string, :aliases => :f, :default => 'none', :desc => 'json, payload, none'
        option :output, :type => :string, :aliases => :o, :desc => 'File path', :default => nil
        option :urls, :type => :array, :aliases => :x, :default => []
        option :params, :type => :hash,:aliases => :p, :default => {}
        option :max_events, :type => :numeric, :default => nil
        desc 'template <path>', 'Execute a VOODOO template'
        def template(path)
            pwd = Dir.pwd

            if File.directory? path
                pwd = File.expand_path(File.join(pwd, path))
                template = YAML.load_file(File.join(path, 'voodoo.yaml'))
            else
                pwd = File.expand_path(File.join(pwd, File.dirname(path)))
                template = YAML.load_file(path)
            end

            browser_inst = template['browser'] || {}
            browser = get_browser(options[:browser] || browser_inst['name'] || 'chrome')

            if template['permissions']
                browser.add_permissions template['permissions']
            end
            
            output_format = options[:format]
            is_default = output_format == 'none'

            if is_default && template['format']
                output_format = template['format']
            end

            output_handler = Output.new(file: options[:output], in_format: output_format, for_command: 'template')

            template['scripts'].each do |script|
                file = File.expand_path(File.join(pwd, script['file'])) if script['file']
                content = script['content']
                matches = script['matches']
                background = script['background'] || false
                
                if output_handler.writable
                    browser.add_script(max_events: options[:max_events], matches: matches, file: file, content: content, options: options[:params], background: background) do |event|
                        output_handler.handle(event)
                    end
                else
                    browser.add_script(matches: matches,content: content, options: options[:params], background: background)
                end
            end

            urls = options[:urls]

            if urls.length == 0 && browser_inst['urls']
                urls = browser_inst['urls']
            end

            browser.hijack urls
        end

        def self.exit_on_failure?
            true
        end

        private

        def get_browser(name)
            browser = nil
            
            case name.downcase
                when 'chrome'
                    browser = Browser.Chrome
                when 'chromium'
                    browser = Browser.Chromium
                when 'opera'
                    browser = Browser.Opera
                when 'edge'
                    browser = Browser.Edge
                when 'brave'
                    browser = Browser.Brave
            end

            if browser == nil
                raise StandardError.new "Unsupported browser \"#{name}\""
            end

            return browser
        end

    end

end