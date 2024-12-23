require 'set'
require 'json'
require 'tmpdir'
require 'fileutils'

module VOODOO

    class Extension
        attr_accessor :manifest
        attr_reader :folder

        def initialize
            @id = 0
            @folder = Dir.mktmpdir
            @manifest = {
                name: '~',
                author: '~',
                description: '',
                version: '0.0.1',
                manifest_version: 3,
                permissions: [],
                host_permissions: [],
                content_scripts: [],
                background: {
                    service_worker: nil
                }
            }
        end

        def add_service_worker(content: nil, file: nil)
            if content == nil && file != nil
                content = File.read file
            end
            if content == nil
                raise StandardError.new(':content or :file argument are required')
            end
            path = add_file(content, with_extension: '.js')
            @manifest[:background][:service_worker] = path
        end

        def add_content_script(matches, js: [], css: [])
            matches = [matches] unless matches.is_a? Array

            js = js.map { |str| add_file(str) }
            css = css.map { |str| add_file(str, with_extension: '.css') }

            @manifest[:content_scripts] << {
                js: js,
                css: css,
                matches: matches
            }
        end

        def save
            @manifest[:permissions] = @manifest[:permissions].uniq
            service_worker = @manifest[:background][:service_worker]
            if service_worker == nil || service_worker == ''
                @manifest[:background].delete(:service_worker)
            end
            manifest_path = File.join(@folder, 'manifest.json')
            File.write(manifest_path, JSON.generate(@manifest))
            return @folder
        end

        def unlink
            FileUtils.rm_r(@folder, :force=>true)
        end

        private

        def add_file(content, with_extension: '.js')
            @id += 1
            filename = @id.to_s + with_extension
            file_path = File.join(@folder, filename)
            File.write file_path, content
            return filename
        end

    end

end