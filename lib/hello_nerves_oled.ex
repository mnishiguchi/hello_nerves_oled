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
    chisel_font = Font.load!("6x10.bdf")

    ClockServer.start_link(
      interval_ms: 1_000,
      on_tick: fn ->
        Display.clear()

        Enum.with_index(collect_metrics(), fn {key, value}, index ->
          content = "#{key |> to_string() |> String.pad_trailing(10)}: #{value}"
          Display.put_text(content, x: 0, y: 10 * index, chisel_font: chisel_font)
        end)

        Display.display()
      end
    )
  end

  defp collect_metrics() do
    [
      time: Time.utc_now() |> Time.truncate(:second) |> to_string(),
      memory: :erlang.memory(:total),
      process: :erlang.system_info(:process_count)
    ]
  end
end
