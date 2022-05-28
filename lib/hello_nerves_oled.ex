defmodule HelloNervesOled do
  @moduledoc false

  alias HelloNervesOled.Display
  alias HelloNervesOled.Font

  def japan(opts \\ []) do
    font_name = opts[:font_name] || "5x8.bdf"
    chisel_font = Font.load!(font_name)

    # Clear the display buffer
    Display.clear()

    # Draw shapes on the display buffer
    padding_x = 50
    Display.rect(padding_x, 0, 127 - padding_x * 2, 16)
    Display.circle(63, 8, 4)

    # Draw text on the display buffer
    Display.put_text("JAPAN", x: 36, y: 18, chisel_font: chisel_font, size_x: 2, size_y: 2)

    # Transfer the display buffer to the screen
    Display.display()

    :ok
  end

  def circle(radius \\ 15) do
    for x <- 0..127 + radius + 1 do
      Display.clear()
      Display.circle(x, 15, radius)
      Display.display()
      Process.sleep(1)
    end

    :ok
  end
end
