defmodule Flamelex.FluxusRadix do
  @moduledoc """
  In latin, `fluxus` means "flow" and `radix` means "root". FluxusRadix
  is the root node in the state-tree of fluxus processes.The FluxusRadix
  holds the highest-level flamelex state, including:

    - the user-input mode
    - the input history (both keystrokes, & commands)
    - it acts as a conduit for all user-input (which got sent
      here by `Flamelex.GUI.RootScene`)

  We need a single junction-point where all the data required to make
  decisions can be combined & acted upon - this is it.

  What belongs in the domain of RadixState? Anything which affects both
  buffers & GUI components. e.g. opening the Command buffer requires:

  * changing the input mode
  * checking the contents of `Flamelex.Buffer.Command`
  * rendering the GUI.Component
  * etc...

  changing the input mode alone requires that we make our changes at the
  FluxusRadix level, so we might as well just put the rest as side-effects
  in the reducer at this level. This makes sense because it's a heirarchy -
  since we need to change the input it's an FluxusRadix level change, so
  the function to open the Command buffer must be implemented at this level.
  If we don't need to alter anything at this level, then do not implement
  it in a reducer/handler at this level, handle it somewhere lower.

  When we need to trigger something at the Radix level, we can use actions.
  Actions get handled by the TansStatum module, though the actual processing
  occurs in a seperate process, running under the
  `Flamelex.Fluxus.HandleAction.TaskSupervisor`.

  User input also gets funneled through this process - the RadixState (which
  includes the user-input history) and the input itself are handled by
  one of the InputHandler functions, which operate in basically the same
  manner as reducers - spun up into their own process & handled in there.
  Inputs usually lead to an action being dispatched, which is sent back
  to FluxusRadix (kind of a loop-back) to be then handled.
  """
  use GenServer
  use Flamelex.ProjectAliases
  alias Flamelex.Fluxus.Structs.RadixState


  def start_link(_params) do
    initial_state = RadixState.new()
    GenServer.start_link(__MODULE__, initial_state)
  end


  def init(%Flamelex.Fluxus.Structs.RadixState{} = radix_state) do
    IO.puts "#{__MODULE__} initializing..."
    Process.register(self(), __MODULE__)
    {:ok, radix_state}
  end


  def handle_cast({:user_input, ii}, radix_state) do
    Flamelex.Fluxus.UserInputHandler.handle(radix_state, {:user_input, ii})
    {:noreply, radix_state |> RadixState.record(keystroke: ii)}
  end


  def handle_cast({:action, a}, radix_state) do
    case radix_state |> Flamelex.Fluxus.RootReducer.handle({:action, a}) do
      {:ok, %RadixState{} = updated_radix_state} ->
          {:noreply, updated_radix_state |> RadixState.record(action: a)}
      {:error, reason} ->
          IO.puts "error handling action: #{inspect a}, #{inspect reason}"
          {:noreply, radix_state}
    end
  end
end
