defmodule HelloNervesOled.MetricsServer do
  @moduledoc false

  use GenServer, restart: :transient

  @interval_ms 30

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def stop do
    GenServer.stop(__MODULE__)
  end

  @impl GenServer
  def init(_opts) do
    state = %{chisel_font: nil}

    {:ok, state, {:continue, :start}}
  end

  @impl GenServer
  def handle_continue(:start, state) do
    chisel_font = HelloNervesOled.Font.load!("6x10.bdf")

    send(self(), :tick)

    {:noreply, %{state | chisel_font: chisel_font}}
  end

  @impl GenServer
  def handle_info(:tick, state) do
    refresh_display(state)

    Process.send_after(self(), :tick, @interval_ms)

    {:noreply, state}
  end

  defp refresh_display(state) do
    text = get_metrics()

    HelloNervesOled.Display.clear()
    put_pixel_fun = fn x, y -> HelloNervesOled.Display.put_pixel(x, y, []) end
    Chisel.Renderer.draw_text(text, 0, 0, state.chisel_font, put_pixel_fun, [])
    HelloNervesOled.Display.display()
  end

  defp get_metrics do
    [
      time: Time.utc_now() |> Time.truncate(:second) |> to_string(),
      memory: :erlang.memory(:total),
      process: :erlang.system_info(:process_count)
    ]
    |> Enum.map(fn {key, value} ->
      _row = [
        key |> to_string() |> String.pad_trailing(12),
        value |> to_string() |> String.pad_leading(8),
        '\n'
      ]
    end)
    |> to_string()
  end
end
