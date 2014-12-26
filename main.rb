#!/usr/bin/env ruby
# encoding: utf-8
require 'optparse'
require './connection'

if __FILE__ == $0

	options = {}

	OptionParser.new do |opts|
		opts.banner = "Usage: example.rb [options]"

		opts.on('-i', '--name NAME', 'Source Ip') do |v|
			block = /[01]\d{,2}|2[0-4]\d|25[0-5]/

			if v =~ /\A#{block}\.#{block}\.#{block}\.#{block}\z/
				options[:ip] = v
			else
				raise "The -i parameter must be an ip"
			end
		end

		opts.on('-p', '--port PORT', 'Source Port') do |v|
			if v =~ /^\d+$/
				options[:port] = v
			else
				raise "The -p parameter must be a number"
			end
		end

		opts.on('-m', '--mod MOD', 'Source Mod') do |v|
			if v.downcase =~ /^client$/ or v.downcase =~ /^server$/
				options[:mod] = v.downcase
			else
				raise 'The -m parameter must be "client" or "server"'
			end
		end

	end.parse!


	# verifies the type of connection
	if options[:mod] == "server"
		conn = Connection::Server.new(options[:ip], options[:port].to_i)
	elsif options[:mod] == "client"
		conn = Connection::Client.new(options[:ip], options[:port].to_i)
	end

end
