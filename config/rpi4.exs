import Config

# https://hexdocs.pm/oled/OLED.Display.html
config :hello_nerves_oled, HelloNervesOled.Display,
  driver: :ssd1306,
  type: :i2c,
  device: "i2c-1",
  address: 0x3D,
  width: 128,
  height: 64

# https://github.com/pappersverk/scenic_driver_oled
config :hello_nerves_oled, :viewport, %{
  name: :main_viewport,
  default_scene: {HelloNervesOled.Scene.Default, nil},
  size: {128, 64},
  opts: [scale: 1.0],
  drivers: [
    %{
      module: OLED.Scenic.Driver,
      opts: [
        display: HelloNervesOled.Display,
        dithering: :sierra
      ]
    }
  ]
}
