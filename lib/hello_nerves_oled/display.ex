defmodule HelloNervesOled.Display do
  use OLED.Display, app: :hello_nerves_oled

  @type oled_pixel_options :: OLED.Display.Server.pixel_opts()
  @type chisel_draw_options :: Chisel.Renderer.draw_options()

  @spec put_text(binary, keyword) :: :ok
  def put_text(text, opts) do
    x = opts[:x] || 0
    y = opts[:y] || 0
    chisel_font = Access.fetch!(opts, :chisel_font)

    # TODO: This seems to take 5..8 seconds. Optimize it if possible.
    put_pixel_fun = fn x, y -> put_pixel(x, y, opts) end
    Chisel.Renderer.draw_text(text, x, y, chisel_font, put_pixel_fun, opts)
  end
end
