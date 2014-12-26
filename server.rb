require 'socket'

server = TCPServer.new 5555
loop do
  Thread.start(server.accept) do |client|
    client.puts "Hello !"
    client.puts "Time is #{Time.now}"
  end


  TCPServer.open(@ip, @port)



end