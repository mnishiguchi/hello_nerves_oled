defmodule HelloNervesOled do
  @moduledoc false

  alias HelloNervesOled.Display

  def japan(padding \\ 40) do
    Display.clear()
    Display.rect(padding, 0, 127 - padding * 2, 31)
    Display.circle(63, 15, 8)
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
