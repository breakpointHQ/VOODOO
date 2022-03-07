require 'set'
require 'json'
require 'tmpdir'
require 'fileutils'

module VOODOO

    class Extension
        attr_accessor :permissions
        attr_reader :folder, :manifest

        def initialize
            @id = 0
            @folder = Dir.mktmpdir
            @manifest = {
                name: '~',
                author: '~',
                description: '',
                version: '0.0.1',
                manifest_version: 2,
                background: {
                    scripts: []
                },
                permissions: [],
                content_scripts: []
            }
        end

        def add_background_script(content)
            path = add_file(content, with_extension: '.js')
            @manifest[:background][:scripts] << path
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