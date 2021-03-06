defmodule Flamelex.ProjectAliases do
  @moduledoc """
  This module makes it easy to include a whole set of very common aliases
  used throughout Flamelex.
  """

  defmacro __using__(_opts) do
    quote do

      # alias Flamelex.Utilities.TerminalIO

      alias Flamelex.API.{Buffer, Kommander, GUI, Memex, Journal}

      alias Flamelex.Utilities.ProcessRegistry
      alias Flamelex.Utils.PubSub

      # alias Flamelex.Memex.Structs.LiteraryQuote

      alias Flamelex.GUI.Structs.{Coordinates, Dimensions, Frame, Layout}
      alias Flamelex.GUI.Utilities.Draw

      alias Flamelex.Fluxus.Actions.CoreActions

    end
  end
end
