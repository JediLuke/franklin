defmodule Flamelex.ProjectAliases do
  @moduledoc """
  This module makes it easy to include a whole set of very common aliases
  used throughout Flamelex.
  """

  defmacro __using__(_opts) do
    quote do

      alias Flamelex.Structs.{Buffer}

      alias Flamelex.{Buffer, GUI, Memex}

      alias Flamelex.Utilities.ProcessRegistry

      #TODO remove these
      alias Flamelex.Utilities
      alias Flamelex.Utilities.TerminalIO

      alias Flamelex.GUI.Structs.{Coordinates, Dimensions, Frame, Layout}
      alias Flamelex.GUI.Utilities.Draw

    end
  end
end