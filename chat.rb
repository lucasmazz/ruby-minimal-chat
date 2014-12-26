#!/usr/bin/env ruby
# encoding: utf-8
require 'curses'

class Chat

    def initialize()
    end

    def login
        print "Nickname:"; nickname = gets.chomp!
        @nickname = nickname
    end

end

