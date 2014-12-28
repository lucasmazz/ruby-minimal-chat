#!/usr/bin/env ruby
# encoding: utf-8
require 'rubygems'
require 'curses'

module UI

	class Window < Curses::Window
		attr_reader :lines, :cols

		def initialize
			Curses.init_screen()

			@lines = Curses.lines
			@cols = Curses.cols

			super(@lines, @cols, 0, 0)
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

