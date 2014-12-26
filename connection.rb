#!/usr/bin/env ruby
# encoding: utf-8
require 'socket'

module Connection

	class Connection
		def initialize
            Thread.new { loop { puts @conn.recv 1024 } }
            loop { @conn.puts(gets) }
		end

		def send(text)
			@conn.puts text
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
            puts "Server is listening on #{@ip}:#{@port}, waiting for connection."
            @conn = server.accept
            puts "A connection has been established."
            puts "---------------------------------"

			super()
		end
	end


	class Client < Connection

		def initialize(ip="127.0.0.1", port=5555)
			@ip = ip
			@port = port

			@conn = TCPSocket.new(@ip, @port)
            puts "Successfully connected."
            puts "---------------------------------"

			super()
		end

	end

end

