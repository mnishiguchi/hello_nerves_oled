defmodule HelloNervesOled do
  @moduledoc false

  def japan(opts \\ []) do
    font_name = opts[:font_name] || "6x10.bdf"
    chisel_font = HelloNervesOled.Font.load!(font_name)

    # Clear the display buffer
    HelloNervesOled.Display.clear()

    # Draw shapes on the display buffer
    padding_x = 50
    HelloNervesOled.Display.rect(padding_x, 0, 127 - padding_x * 2, 16)
    HelloNervesOled.Display.circle(63, 8, 4)

    # Draw text on the display buffer
    HelloNervesOled.Display.put_text("JAPAN", x: 48, y: 18, chisel_font: chisel_font)

    # Transfer the display buffer to the screen
    HelloNervesOled.Display.display()

    :ok
  end

  def circle(radius \\ 15) do
    for x <- 0..(127 + radius + 1) do
      HelloNervesOled.Display.clear()
      HelloNervesOled.Display.circle(x, 15, radius)
      HelloNervesOled.Display.display()
      Process.sleep(1)
    end

    :ok
  end

  def metrics do
    case result = HelloNervesOled.MetricsServer.start_link() do
      {:ok, _pid} ->
        {:ok, "started"}

      {:error, {:already_started, pid}} ->
        GenServer.stop(pid)
        {:ok, "stopped"}
    end
  end

  def bmp280 do
    case result = HelloNervesOled.BMP280Server.start_link() do
      {:ok, _pid} ->
        {:ok, "started"}

      {:error, {:already_started, pid}} ->
        GenServer.stop(pid)
        {:ok, "stopped"}
    end
  end
end
