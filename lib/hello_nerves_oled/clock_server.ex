defmodule HelloNervesOled.ClockServer do
  @moduledoc false

  use GenServer, restart: :transient

  @interval_ms :timer.seconds(10)

  @doc """
  ## Examples

      ClockServer.start_link(
        on_tick: fn _ -> IO.puts "hello" end
      )

  """
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def stop do
    GenServer.stop(__MODULE__)
  end

  @impl GenServer
  def init(opts) do
    on_tick = Access.fetch!(opts, :on_tick)

    send(self(), :tick)

    {:ok, %{on_tick: on_tick}}
  end

  @impl GenServer
  def handle_info(:tick, state) do
    task = Task.async(state.on_tick)
    Process.send_after(self(), :tick, @interval_ms)
    Task.await(task, @interval_ms)

    {:noreply, state}
  end
end
