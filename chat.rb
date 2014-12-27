#!/usr/bin/env ruby
# encoding: utf-8
require 'optparse'
require './connection'
require './ui'





def main(conn)
    nickname = ""

    UI::Dialog.new("What will be your nickname?", "Nickname: "){|answer| nickname = answer}

    messages = []
    window = nil

    def write window, messages
            total_lines = window.lines-2
            first_line = (messages.length-total_lines) > 0 ? (messages.length-total_lines) : 0
            window.setpos(0, 0)

            messages[(first_line)..(messages.length)].each do |msg|
                window.addstr( msg + "\n" )
            end

            window.setpos(Curses.lines-2,0)
            window.addstr("-"*Curses.cols)
            window.setpos(Curses.lines-1,0)

            window.refresh
    end

    Thread.new do
        if !(window.nil?)
            loop do
                messages << ("#{Time.now.strftime('%I:%M')} " << conn.read)
                write window, messages
            end
        end
    end

    loop do
        UI::Window.new() do |win|
            window = win
            write window, messages
            input = ("#{Time.now.strftime('%I:%M')} #{nickname}: " << win.getstr)
            messages << input

            window.addstr(input)

            conn.write input
        end
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
        conn = Connection::Server.new(options[:ip], options[:port].to_i) { main(conn) }
    elsif options[:mod] == "client"
        conn = Connection::Client.new(options[:ip], options[:port].to_i) { main(conn) }
    end

end
