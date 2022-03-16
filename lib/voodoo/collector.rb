require 'json'
require 'socket'
require 'securerandom'

module VOODOO

    class Collector
        attr_reader :port
        attr_reader :thread
        attr_reader :token

        def initialize(port = 0, close_browser: nil)
            @chunks = []
            @close_browser = close_browser
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
                        
                        jsonData = JSON.parse(post_body, {:symbolize_names => true})

                        if jsonData[:log]
                            puts jsonData[:log]
                        end

                        if jsonData[:chunk]
                            @chunks << jsonData[:payload][1]
                            if jsonData[:payload][0] == @chunks.length
                                payload = {
                                    payload: @chunks.join('')
                                }
                                @chunks = []
                                yield payload
                            end
                            return
                        end

                        if jsonData[:kill] == true
                            if jsonData[:close_browser] && @close_browser != nil
                                @close_browser.call()
                            end
                            self.thread.kill
                            return
                        end
                        
                        yield jsonData
                    rescue
                    end
                }
            end
        end
    end

end