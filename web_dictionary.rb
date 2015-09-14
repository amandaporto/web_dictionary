require "webrick"

server = WEBrick::HTTPServer.new(Port: 3000)
server.mount "/", DictionaryDisplay_class
server.mount "/add", AddToDictionary_class
server.mount "/save", SaveToDatabase_class

trap "INT" do server.shutdown end
server.start
