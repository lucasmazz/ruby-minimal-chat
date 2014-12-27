#!/usr/bin/env ruby
# encoding: utf-8
require 'optparse'
require './connection'
require './ui'


class Chat

    def initialize connection=nil
        @connection = connection
        @messages = Array.new()

        # gets the nickname
        UI::Dialog.new("What will be your nickname?", "Nickname: ") do |nickname|
            @nickname = nickname
        end

        @window = UI::Window.new()
        @window.refresh
    end

    def update

        total_lines = @window.lines-2
        first_line = (@messages.length-total_lines) > 0 ? (@messages.length-total_lines) : 0

        @window.setpos(0, 0)

        cont = 0

        @messages[(first_line)..(@messages.length)].each do |msg|
            @window.setpos(cont, 0)
            @window.addstr(msg)
            cont+=1
        end

        # draws the input division
        @window.setpos(@window.lines-2,0)
        @window.addstr("-"*@window.cols)
        @window.setpos(@window.lines-1,0)

        @window.refresh
    end

    def write
        # clears the input text
        @window.clear

        # updates the screen
        update

        # gets the message and send
        input = @window.getstr.chomp.strip

        if !input.empty?
            data = "#{@nickname}: "<< input
            @messages << ("#{Time.now.strftime('%I:%M')} " << data)
            @connection.write data
        end
    end

    def read
        # reads the message
        data = @connection.read

        if !data.chomp.strip.empty?
            @messages << ("#{Time.now.strftime('%I:%M')} " << data)
            update
        end
    end

    def close
    end

end



if __FILE__ == $0

    options = {}

    OptionParser.new do |opts|
        opts.banner = "Usage: example.rb [options]"

        opts.on('-i', '--name NAME', 'Source Ip') do |v|

            if v =~ /^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$/
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

    chat = Chat.new conn

    Thread.new do
        loop do
            chat.read
        end
    end

    loop do
        chat.write
    end
end
