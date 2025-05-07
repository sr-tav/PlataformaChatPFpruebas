defmodule SeguidorConexion do
    use Agent

    def start_link(_) do
      Agent.start_link(fn -> 0 end, name: __MODULE__)
    end

    def increment do
      Agent.update(__MODULE__, &(&1 + 1))
    end

    def decrement do
      Agent.update(__MODULE__, fn count -> max(count - 1, 0) end)
    end

    def count do
      Agent.get(__MODULE__, & &1)
    end
  end
