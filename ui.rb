#!/usr/bin/env ruby
# encoding: utf-8
require 'rubygems'
require 'curses'
require 'io/console'

module UI

  class Window < Curses::Window
    attr_reader :lines, :cols

    def initialize
      Curses.init_screen()

      @lines = Curses.lines
      @cols = Curses.cols

      super(@lines, @cols, 0, 0)
    end

    # Reads keypresses from the user including 2 and 3 escape character sequences.
    def getch
      STDIN.echo = false
      STDIN.raw!

      # input = STDIN.getc.chr
      input = STDIN.getch

      if input == "\e"
        input << STDIN.read_nonblock(3) rescue nil
        input << STDIN.read_nonblock(2) rescue nil
      end

    ensure
      STDIN.echo = true
      STDIN.cooked!

      return input
    end

  end

  class Dialog < Curses::Window

    def initialize(question="", label="", opts=nil)
      Curses.init_screen()

      super(5, (question.length),
          (Curses.lines - 5) / 2,
          (Curses.cols - (question.length)) / 2 )

      setpos(1,0)
      addstr(question)
      setpos(2,0)
      addstr("-"*question.length)
      setpos(3,0)
      addstr(label << " ")
      setpos(3,label.length-1)

      refresh
      answer = getstr
      close

      yield answer

    end

  end


end

