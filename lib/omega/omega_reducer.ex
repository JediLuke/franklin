
defmodule Flamelex.Omega.Reducer do
  @moduledoc """
  This module contains functions which process events received from the GUI.

  #TODO this could be a pretty nice use case for a behaviour, but I like having the automatic pattern-match we get from importing modules #TODO num2 - actually, when it comes to applying layers, pushing actions through layers of reducers (with most important last, so they apply their actions over the top of other ones) might be a good model to use...
  In Franklin, a Reducer must always return one of three values

    :ignore                           -> causes GUI.Root.Scene to ignore action
    {new_state, new_graph}            -> causes GUI.Root.Scene to update both it's internal state, & push a new graph
    new_state when is_map(new_state)  -> causes GUI.Root.Scene to update it's internal state, but no change to the %Scenic.Graph{} is necessary

  """
  require Logger
  use Flamelex.CommonDeclarations
  use GUI.ScenicInputEvents
  alias Flamelex.Structs.OmegaState

  @readme "/Users/luke/workbench/elixir/franklin/README.md"

  ## Command mode

  def handle_input(%OmegaState{mode: :command} = state, @escape_key) do
    Flamelex.Commander.deactivate()
    %{state|mode: :normal}
  end

  ## Normal mode

  def handle_input(%OmegaState{mode: :normal} = state, @space_bar) do
    Logger.info "Space bar was pressed !!"
    Flamelex.Commander.activate()
    %{state|mode: :command}
  end

  def handle_input(%OmegaState{mode: :normal} = state, @lowercase_h) do
    Logger.info "Lowercase f was pressed !!"
    Flamelex.Buffer.load(type: :text, file: @readme)
    state
  end



  # This function acts as a catch-all for all actions that don't match
  # anything. Without this, the process which calls this can crash (!!)
  # if no action matches what is passed in.
  def handle_input(%OmegaState{} = state, input) do
    Logger.warn "#{__MODULE__} recv'd unrecognised action/state combo. input: #{inspect input}, mode: #{inspect state.mode}"
    state # ignore
    # |> IO.inspect(label: "-- DEBUG --")
  end
end