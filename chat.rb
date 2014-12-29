#!/usr/bin/env ruby
# encoding: utf-8
require 'optparse'
require './connection'
require './ui'


class Chat

  def initialize connection=nil
    @connection = connection
    @messages = Array.new()
    @buffer = ""
    @cur_pos = 0
    @screen_pos = 0

    # gets the nickname
    UI::Dialog.new("What will be your nickname?", "Nickname: ") do |nickname|
      @nickname = nickname
    end

    @window = UI::Window.new()
    @window.refresh
  end

  def update
    @window.clear

    total_lines = @window.lines-2
    first_line = @messages.length-total_lines-@screen_pos > 0 ? \
                 @messages.length-total_lines-@screen_pos : 0

    line = 0

    @messages[(first_line)..(first_line+total_lines)].each do |msg|
      # TODO: linebreaks
      @window.setpos(line, 0)
      @window.addstr(msg)
      line+=1
    end

    # draws the input division
    @window.setpos(@window.lines-2,0)
    @window.addstr("-"*@window.cols)

    @window.setpos(@window.lines-1,0)
    @window.addstr(@buffer)
    @window.setpos(@window.lines-1, @cur_pos)

    @window.refresh
  end

  def write
    # updates the screen
    update

    # gets the message and send
    input = @window.getch

    case input

    # Enter
    when /^\r|\n$/
      data = "#{@nickname}: " << @buffer
      @messages << ("#{Time.now.strftime('%I:%M')} " << data)
      @connection.write data

      # clears the buffer after it was sent
      @buffer = ""
      @cur_pos = 0
      @screen_pos = 0

    # Backspace
    when "\177"
      @cur_pos = @cur_pos - 1 >= 0 ? @cur_pos - 1 : 0
      @buffer.slice!(@cur_pos,1)

    # Tab
    when "\t"
      @buffer << (" "*4)
      @cur_pos += 4

    # Up arrow
    when "\e[A"
      @screen_pos = @screen_pos + 1 <= @messages.length - @window.lines - 2 - @screen_pos? \
                    @screen_pos + 1 : @messages.length - @window.lines - 2

    # Down arrow
    when "\e[B"
      @screen_pos = @screen_pos - 1 >= 0 ? @screen_pos - 1 : 0

    # Right arrow
    when "\e[C"
      @cur_pos = @cur_pos + 1 <= @buffer.length ? \
                 @cur_pos + 1 : @buffer.length

    # Left arrow
    when "\e[D"
      @cur_pos = @cur_pos - 1 >= 0 ? @cur_pos - 1 : 0

    # Delete keys
    when /^\e\[3~|\004$/
      @buffer.slice!(@cur_pos, 1)

    # Esc or Control + C
    when /^\u0003|\e$/
      exit 0

    # Default
    else
      begin
        @buffer.insert(@cur_pos, input)
      rescue Exception => e
        @buffer << input
      end

      @cur_pos += 1
    end

  end

  # Reads the message
  def read
    data = @connection.read

    if !data.chomp.strip.empty?
      @screen_pos = 0
      @messages << ("#{Time.now.strftime('%I:%M')} " << data)
      update
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
