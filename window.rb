#!/usr/bin/env ruby
# encoding: utf-8
require 'curses'

class Window

    def initialize()
    end

    def login
        print "Nickname:"; nickname = gets.chomp!
        @nickname = nickname
    end

    def refresh
    end

end

