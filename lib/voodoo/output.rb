require 'base64'

module VOODOO

    class Output
        attr_reader :writable

        def initialize(file: nil, in_format: nil, for_command: nil)
            @file = nil
            @format = in_format
            @command = for_command
            @writable = in_format != 'none'
            @file = open(file, 'a') if file
        end

        def write(any, with_print: false)
            if @file
                @file.puts any
            else
                if with_print
                    print any
                else
                    puts any
                end
            end
        end

        def handle(event)
            if !@writable
                return
            end

            case @format
                when 'pretty'
                    case @command
                        when 'keylogger'
                            write event[:payload], with_print: true
                        when 'intercept'
                            req = event[:payload]
                            write "#{req[:method]} #{req[:url]}"
                            req[:body] = req[:body][0...97] + "..." if req[:body] && req[:body].length > 100
                            
                            if req[:body]
                                write "BODY: #{event[:payload][:body]}"
                            end 
                        else
                            write JSON.generate(event[:payload])
                    end
                when 'json'
                    write JSON.generate(event)
                when 'payload'
                    write JSON.generate(event[:payload])
                when 'payload:base64decode'
                    write Base64.decode64(event[:payload])
                else
                    write JSON.generate(event)
            end

            true
        end

    end

end