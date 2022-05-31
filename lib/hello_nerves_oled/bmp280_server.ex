defmodule HelloNervesOled.BMP280Server do
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

    case BMP280.start_link(name: BMP280) do
      {:ok, _} -> BMP280.force_altitude(BMP280, 100)
      _ -> nil
    end

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
    {:ok, measurement} = BMP280.measure(BMP280)
    text = measurement_to_string(measurement)

    HelloNervesOled.Display.clear()
    put_pixel_fun = fn x, y -> HelloNervesOled.Display.put_pixel(x, y, []) end
    Chisel.Renderer.draw_text(text, 0, 0, state.chisel_font, put_pixel_fun, [])
    HelloNervesOled.Display.display()
  end

  defp measurement_to_string(%BMP280.Measurement{} = measurement) do
    [
      time: Time.utc_now() |> Time.truncate(:second) |> to_string(),
      humidity: measurement.humidity_rh |> :erlang.float_to_binary(decimals: 2),
      pressure: measurement.pressure_pa |> :erlang.float_to_binary(decimals: 0),
      dew_point: measurement.dew_point_c |> :erlang.float_to_binary(decimals: 2),
      temperature: measurement.temperature_c |> :erlang.float_to_binary(decimals: 2)
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
