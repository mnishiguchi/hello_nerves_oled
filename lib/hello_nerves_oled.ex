defmodule HelloNervesOled do
  @moduledoc false

  alias HelloNervesOled.Display
  alias HelloNervesOled.Font
  alias HelloNervesOled.ClockServer

  def japan(opts \\ []) do
    font_name = opts[:font_name] || "6x10.bdf"
    chisel_font = Font.load!(font_name)

    # Clear the display buffer
    Display.clear()

    # Draw shapes on the display buffer
    padding_x = 50
    Display.rect(padding_x, 0, 127 - padding_x * 2, 16)
    Display.circle(63, 8, 4)

    # Draw text on the display buffer
    Display.put_text("JAPAN", x: 48, y: 18, chisel_font: chisel_font)

    # Transfer the display buffer to the screen
    Display.display()

    :ok
  end

  def circle(radius \\ 15) do
    for x <- 0..(127 + radius + 1) do
      Display.clear()
      Display.circle(x, 15, radius)
      Display.display()
      Process.sleep(1)
    end

    :ok
  end

  def metrics do
    print_kv_periodically(fn ->
      [
        time: Time.utc_now() |> Time.truncate(:second) |> to_string(),
        memory: :erlang.memory(:total),
        process: :erlang.system_info(:process_count)
      ]
    end)
  end

  def bmp280 do
    case BMP280.start_link(name: BMP280) do
      {:ok, _} -> BMP280.force_altitude(BMP280, 100)
      _ -> nil
    end

    print_kv_periodically(fn ->
      {:ok, measurement} = BMP280.measure(BMP280)

      [
        time: Time.utc_now() |> Time.truncate(:second) |> to_string(),
        humidity: measurement.humidity_rh |> :erlang.float_to_binary(decimals: 2),
        pressure:
          measurement.pressure_pa |> Kernel./(100) |> :erlang.float_to_binary(decimals: 2),
        dew_point: measurement.dew_point_c |> :erlang.float_to_binary(decimals: 2),
        temperature: measurement.temperature_c |> :erlang.float_to_binary(decimals: 2)
      ]
    end)
  end

  defp print_kv_periodically(get_kv_pairs_fn) do
    chisel_font = Font.load!("6x10.bdf")

    ClockServer.start_link(
      on_tick: fn ->
        Display.clear()

        Enum.with_index(get_kv_pairs_fn.(), fn {key, value}, index ->
          content =
            [
              key |> to_string() |> String.pad_trailing(12),
              value |> to_string() |> String.pad_leading(8)
            ]
            |> to_string

          Display.put_text(content, x: 0, y: 10 * index, chisel_font: chisel_font)
        end)

        Display.display()
      end
    )
  end
end
