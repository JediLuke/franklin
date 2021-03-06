defmodule Flamelex.Application do
  @moduledoc false
  use Application


  def start(_type, _args) do

    IO.puts "#{__MODULE__} initializing..."

    #TODO do we want to show a popup / println / anything to "new" users? (no environment detected)
    # maybe show a popup about loading in a Memex environment? Maybe load in a sample one?

    # start_gui? = true

    # children =
    #     if start_gui? do
    #       boot_gui_process_tree() ++ boot_regular_applications()
    #     else
    #       boot_regular_applications()
    #     end

    children = boot_regular_applications() ++ boot_gui_process_tree()

    opts = [strategy: :one_for_one, name: Flamelex.Trismegistus]
    Supervisor.start_link(children, opts)
  end





  defp boot_gui_process_tree do
    [
      Flamelex.GUI.TopLevelSupervisor
    ]
  end

  defp boot_regular_applications do
    [
      Flamelex.Fluxus.TopLevelSupervisor,
      Flamelex.Buffer.TopLevelSupervisor,
      # Flamelex.Agent.TopLevelSupervisor, #TODO this is just commented out to stop spamming the log with reminders atm
    ]
  end
end
