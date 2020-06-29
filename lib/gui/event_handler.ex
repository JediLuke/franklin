defmodule GUI.Input.EventHandler do
  @moduledoc """
  This module contains functions which process events received from the GUI.
  """
  require Logger
  use GUI.ScenicInputEvents
  alias GUI.Scene.Root, as: Scene

  # eliminate the don't cares
  def process(state, {input, _details}) when input in @inputs_we_dont_care_about do
    state # do nothing - pass through unaltered state
  end


  ## Command buffer commands
  ## -------------------------------------------------------------------


  def process(%{command_buffer: %{visible?: false}, mode: :control} = state, @space_bar) do
    Scene.action('SHOW_EXECUTE_COMMAND_PROMPT')
    state
  end

  def process(%{command_buffer: %{visible?: true}, mode: :control} = state, input) when input in @valid_command_buffer_inputs do
    Scene.action({'COMMAND_BUFFER_INPUT', input})
    state |> add_to_input_history(input)
  end

  def process(%{command_buffer: %{visible?: true}, mode: :control} = state, @enter_key) do
    Scene.action('PROCESS_COMMAND_BUFFER_TEXT_AS_COMMAND')
    state
  end

  def process(%{command_buffer: %{visible?: true}, mode: :control} = state, @escape_key) do
    Scene.action('CLEAR_AND_CLOSE_COMMAND_BUFFER')
    state
  end

  def process(%{command_buffer: %{visible?: true}, mode: :control} = state, @left_shift_and_space_bar) do
    Scene.action('CLEAR_AND_CLOSE_COMMAND_BUFFER')
    state
  end

  def process(%{command_buffer: %{visible?: true}, mode: :control} = state, @space_bar = input) do
    Scene.action({'COMMAND_BUFFER_INPUT', input})
    state |> add_to_input_history(input)
  end

  def process(%{command_buffer: %{visible?: true}, mode: :control} = state, backspace) when backspace in @backspace_input do
    Scene.action('COMMAND_BUFFER_BACKSPACE')
    state
  end


  ## Active buffer
  ## -------------------------------------------------------------------


  def process(%{active_buffer: {:note, _x, _pid} = buf} = state, input) when input in @valid_command_buffer_inputs do
    Scene.action({'NOTE_INPUT', buf, input})
    state |> add_to_input_history(input)
  end

  def process(%{active_buffer: {:note, _x, buffer_pid}} = state, @tab_key) do
    Franklin.Buffer.Note.tab_key_pressed(buffer_pid)
    state
  end

  def process(%{active_buffer: {:note, _x, _buffer_pid}, mode: :control} = state, @escape_key) do
    Logger.warn "Pressing ESC in control mode does nothing right now."
    state
  end

  def process(%{active_buffer: {:note, _x, buffer_pid}, mode: :control} = state, @enter_key) do
    Franklin.Buffer.Note.save_and_close(buffer_pid)
    state
  end

  def process(%{active_buffer: {:note, _x, _buffer_pid}, mode: mode} = state, @escape_key) when mode != :control do
    #TODO write own action for switching modes
    state |> Map.replace!(:mode, :control)
  end

  def process(%{active_buffer: {:note, _x, buffer_pid}} = state, @left_shift_and_tab) do
    Franklin.Buffer.Note.reverse_tab(buffer_pid) #TODO have better lookup than just pid, so we could use this from cmd line
    state
  end



  # def process(%{command_buffer: %{visible?: false}} = state, @lowercase_j) do
  #   if state.input_history |> List.last == @space_bar do
  #     Scene.action('SHOW_COMMAND_BUFFER')
  #   end
  #   state |> add_to_input_history(@lowercase_j)
  # end



  def process(state, unhandled_event) do
    Logger.debug("#{__MODULE__} Unhandled event: #{inspect(unhandled_event)}")
    state
  end


  ## private functions
  ## -------------------------------------------------------------------


  #TODO lose input after certain amount
  defp add_to_input_history(state, {:codepoint, _details} = input) do
    %{state|input_history: state.input_history ++ [input]}
  end
end