defmodule HelloNervesOled.Font do
  @moduledoc false

  alias HelloNervesOled.ChiselFontCache

  @fonts_destination_dir "/data/fonts"
  @fonts_source_base_url "https://raw.githubusercontent.com/olikraus/u8g2/master/tools/font/bdf"

  @doc """
  Loads a font from [olikraus/u8g2] as [Chisel.Font].

  ## Examples

      Font.load!("5x8.bdf")

  [Chisel.Font]: https://hexdocs.pm/chisel/Chisel.Font.html
  [olikraus/u8g2]: https://github.com/olikraus/u8g2/tree/master/tools/font/bdf

  """
  def load!(bdf_font_name) do
    if not String.ends_with?(bdf_font_name, ".bdf") do
      raise("font name must end with .bdf")
    end

    ChiselFontCache.get_or_insert_by(bdf_font_name, &build_chisel_font/1)
  end

  defp build_chisel_font(bdf_font_name) do
    File.mkdir_p(@fonts_destination_dir)

    font_data_src = Path.join([@fonts_source_base_url, bdf_font_name])
    font_data_file = Path.join([@fonts_destination_dir, bdf_font_name])

    if not File.exists?(font_data_file) do
      %{status: 200, body: raw_font} = Req.get!(font_data_src)
      File.write!(font_data_file, raw_font)
    end

    {:ok, %Chisel.Font{} = chisel_font} = Chisel.Font.load(font_data_file)

    chisel_font
  end
end
