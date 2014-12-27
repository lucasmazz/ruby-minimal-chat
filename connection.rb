#!/usr/bin/env ruby
# encoding: utf-8
require 'socket'

module Connection

    class Connection
        attr_accessor :nickname

        # def initialize
            # if block_given?
            #     yield self
            # else
            #     Thread.new { loop { read{ |data| puts(data) } } }
            #     loop { write(gets) }
            # end
        # end

        def write(data)
            @conn.puts data
        end

        def read
            @conn.recv 1024
        end

        def close
            @conn.close
            exit
        end
    end


    class Server < Connection

        def initialize(ip="127.0.0.1", port=5555)
            @ip = ip
            @port = port
            server = TCPServer.open(@ip, @port)
            @conn = server.accept
        end
    end


    class Client < Connection

        def initialize(ip="127.0.0.1", port=5555)
            @ip = ip
            @port = port
            @conn = TCPSocket.new(@ip, @port)
        end
    end

end

