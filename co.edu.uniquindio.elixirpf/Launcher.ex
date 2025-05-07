defmodule Launcher do
  def start do
    TCPServer.start()
  end
end
Launcher.start()
