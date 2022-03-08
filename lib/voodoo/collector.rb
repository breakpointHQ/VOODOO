require 'json'
require 'socket'
require 'securerandom'

module VOODOO

    class Collector
        attr_reader :port
        attr_reader :thread
        attr_reader :token

        def initialize(port = 0)
            if port == 0
                tmp_server = TCPServer.open('127.0.0.1', 0)
                @port = tmp_server.addr[1]
                tmp_server.close
            else
                @port = port
            end
            @token = SecureRandom.uuid
        end

        def url
            return "http://localhost:#{@port}/?token=#{@token}"
        end

        def on_json
           @thread = Thread.new do
                server = TCPServer.new('127.0.0.1', @port)

                loop {
                    begin
                        socket = server.accept
                        headers = {}
                        method, path = socket.gets.split

                        unless path.include? @token
                            socket.puts("HTTP/1.1 400 OK\r\n\r\n")
                            socket.close
                            next
                        end
                        
                        while line = socket.gets.split(" ", 2)
                            break if line[0] == ""
                            headers[line[0].chop] = line[1].strip
                        end

                        post_body = socket.read(headers["Content-Length"].to_i)
                        socket.puts("HTTP/1.1 204 OK\r\n\r\n")
                        socket.close
                        
                        jsonData = JSON.parse(post_body)
                        yield jsonData
                    rescue
                    end
                }
            end
        end
    end

end