require "webrick"

class DisplayDictionary < WEBrick::HTTPServlet::AbstractServlet

  def do_GET(request, response)

    dictionary_lines = File.readlines("dictionary.txt")

    dictionary_html = "<ul>" + dictionary_lines.map { |line| "<li>#{line}</li>" }.join + "</ul>"

    response.status = 200
    response.body = %{
      <html>
        <body>
          <a href="/add"> To add a word, click here </a>
          <form method="POST" action="/search">
            <span>Search</span>
            <input name="to_search" type="search">
            <button type="submit"> Search it! </button>
          </form>

          <p>Dictionary</p>
          <p>#{dictionary_html}</p>

        </body>
      </html>
      }
  end
end


class AddToDictionary < WEBrick::HTTPServlet::AbstractServlet
  # This gets called when the user clicks the link from the "/" page
  def do_GET(request, response)

    response.status = 200
    response.body = %{
      <html>
        <body>
          <form method="POST" action="/save">
            <span>Word</span>
            <input name="word"/>
            <span>Definition</span>
            <input name="definition"/>
            <button type="submit"> Add it! </button>
          </form>
        </body>
      </html>
      }
  end
end


class SaveToDatabase < WEBrick::HTTPServlet::AbstractServlet
  # This is called when the user submits the form from the "/add" page
  # They get here because the "/add" page gave "/save" as the action.
  def do_POST(request, response)

    File.open("dictionary.txt", "a+") do |file|
      file.puts "#{request.query["word"]} = #{request.query["definition"]}"
    end
    # Get the word from the "request"
    # Add it to the text file
    # Redirect the user back tom "/"
    response.status = 302
    response.header["Location"] = "/"
    response.body = %{
      <html>
        <body>
          <p>Saved!</p>
        </body>
      </html>
    }
  end
end

class SearchDatabase < WEBrick::HTTPServlet::AbstractServlet

  def do_POST(request, response)

    dictionary_lines = File.readlines("dictionary.txt")
    search_results = dictionary_lines.select {|line| line.include?(request.query["to_search"])}
    search_html = "<ul>" + search_results.map { |line| "<li>#{line}</li>" }.join + "</ul>"

    response.status = 200
    response.body = %{
      <html>
        <body>
        <a href="/"> Back to full dictionary </a>
        <p>#{search_html}</p>
        </body>
      </html>
    }
  end
end


server = WEBrick::HTTPServer.new(Port: 3000)
server.mount "/", DisplayDictionary
server.mount "/add", AddToDictionary
server.mount "/save", SaveToDatabase
server.mount "/search", SearchDatabase

trap "INT" do server.shutdown end
server.start
