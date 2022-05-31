defmodule HelloNervesOled.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: HelloNervesOled.Supervisor]

    children =
      [
        # Children for all targets
        # Starts a worker by calling: HelloNervesOled.Worker.start_link(arg)
        # {HelloNervesOled.Worker, arg},
      ] ++ children(target())

    Supervisor.start_link(children, opts)
  end

  # List all child processes to be supervised
  def children(:host) do
    [
      # Children that only run on the host
      # Starts a worker by calling: HelloNervesOled.Worker.start_link(arg)
      # {HelloNervesOled.Worker, arg},
    ]
  end

  def children(_target) do
    [
      # Children for all targets except host
      # Starts a worker by calling: HelloNervesOled.Worker.start_link(arg)
      # {HelloNervesOled.Worker, arg},
      HelloNervesOled.ChiselFontCache,
      HelloNervesOled.Display,
      demo_server_mod()
    ]
  end

  def demo_server_mod do
    Application.get_env(:hello_nerves_oled, :demo_server_mod)
  end

  def target() do
    Application.get_env(:hello_nerves_oled, :target)
  end
end
