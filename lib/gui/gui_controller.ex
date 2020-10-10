defmodule Flamelex.GUI.Controller do
  @moduledoc """
  This process is in some ways the equal-opposite of OmegaMaster. That process
  holds all our buffers & manipulates them. This process holds the actual
  %RootScene{} and %Layout{}, as well as keeping track of open buffers etc.
  """
  use GenServer
  use Flamelex.CommonDeclarations
  require Logger


  def start_link(_params) do
    viewport_size = Dimensions.new(:viewport_size)

    init_state = %{
        viewport: viewport_size,
          layout: Layout.default(viewport_size),
           graph: Draw.blank_graph()
      }

    GenServer.start_link(__MODULE__, init_state)
  end

  def action(a) do
    GenServer.cast(__MODULE__, {:action, a})
  end

  def frame_stack do
    GenServer.call(__MODULE__, :get_frame_stack)
  end


  ## GenServer callbacks
  ## -------------------------------------------------------------------


  def init(state) do
    IO.puts "#{__MODULE__} initializing..."
    Process.register(self(), __MODULE__)
    {:ok, state, {:continue, :draw_default_gui}}
  end

  def handle_continue(:draw_default_gui, %{viewport: vp} = state) do

    new_graph =
      Draw.blank_graph()
      |> GUI.Component.CommandBuffer.draw(viewport: vp)
      |> GUI.Component.TransmutationCircle.draw(viewport: vp)
      |> Scenic.Primitives.rect({vp.width, vp.height}) # rectangle used for capturing input for the scene

    new_graph
    |> Flamelex.GUI.Root.Scene.redraw()

    new_state =
      %{state|graph: new_graph}

    {:noreply, new_state}
  end

  # def handle_cast(:show_in_gui, %Buffer{} = buffer}, state) do

  #   # the reason we need this controller is, it can keep track of all the buffers that the GUI is managing. Ok fuck it we can maybe get rid of it

  #   # new_state =
  #   #   state
  #   #   |> Map.update!(:buffer_list, fn b -> b ++ [buffer] end)
  #   #   |> Map.update!(:active_buffer, fn _ab -> buffer end)

  #   # IO.puts "SENDING --- #{new_state.active_buffer.content}"
  #   GUI.Scene.Root.action({'NEW_FRAME', [type: :text, content: buffer.content]}) #TODO this action should be more like, SHOW_BUFFER_FULL_SCREEN

  #   {:noreply, state}
  # end




  def handle_cast({:action, action}, state) do
    case GUI.Root.Reducer.process(state, action) do
      # :ignore_action
      #     -> {:noreply, {scene, graph}}
      # {:update_state, new_scene} when is_map(new_scene)
      #     -> {:noreply, {new_scene, graph}}
      {:redraw_root_scene, %{graph: new_graph} = new_state}  ->
        Flamelex.GUI.Root.Scene.redraw(new_graph)
        {:noreply, new_state}
      # {:update_state_and_graph, {new_scene, %Scenic.Graph{} = new_graph}} when is_map(new_scene)
      #     -> {:noreply, {new_scene, new_graph}, push: new_graph}
    end
  end

  def handle_call(:get_frame_stack, _from, state) do
    {:reply, state.layout.frames, state}
  end











  # def handle_cast({:register_new_buffer, [type: :text, content: c, action: 'OPEN_FULL_SCREEN'] = args}, %{
  #   buffer_list: [] # the case where we have no open buffers
  # } = state) do


  #   new_state =
  #     state
  #     |> Map.update!(:buffer_list, fn _b -> [1] end) #TODO have a buffer struct I guess...

  #   #TODO call Scenic GUI component process (registered to this topic/whatever) &
  #   GUI.Scene.Root.action({'NEW_FRAME', [type: :text, content: c]})

  #   {:noreply, new_state}
  # end

  def handle_cast({:show_fullscreen, %Buffer{} = buffer}, state) do

    # the reason we need this controller is, it can keep track of all the buffers that the GUI is managing. Ok fuck it we can maybe get rid of it

    # new_state =
    #   state
    #   |> Map.update!(:buffer_list, fn b -> b ++ [buffer] end)
    #   |> Map.update!(:active_buffer, fn _ab -> buffer end)

    # IO.puts "SENDING --- #{new_state.active_buffer.content}"
    GUI.Scene.Root.action({'NEW_FRAME', [type: :text, content: buffer.content]}) #TODO this action should be more like, SHOW_BUFFER_FULL_SCREEN

    {:noreply, state}
  end


  # @impl true
  # def handle_info(:check_reminders, state) do
  #   # Logger.info("Checking reminders...")
  #   state =
  #     Utilities.Data.find(tags: "reminder") |> process_reminders(state)
  #   Process.send_after(self(), :check_reminders, :timer.seconds(10))
  #   {:noreply, state}
  # end

  # def handle_info({:reminder!, r}, state) do
  #   Logger.warn "REMINDING YOU ABOUT! - #{inspect r}"
  #   #TODO right now, schedule to remind me again (so I don't forget) - when it's acknowledged, this will stop
  #   Process.send_after(self(), {:reminder!, r}, @default_reminder_time_in_minutes * (60 * 1000))
  #   {:noreply, state}
  # end

  # defp process_reminders([], state), do: state
  # defp process_reminders([{_key, data} = r | rest], state) do
  #   case reminder_already_pending?(r, state) do
  #     true ->
  #       # Logger.info "Reminder was already pending. #{inspect r}"
  #       process_reminders(rest, state)
  #     false ->
  #       # we found a new reminder...
  #       case data["remind_me_datetime"] do
  #         nil ->
  #           Logger.error "Found a reminder #{inspect r} that didn't have a reminder time."
  #           state = set_up_reminder(r, state, @default_reminder_time_in_minutes)
  #           process_reminders(rest, state)
  #         _remind_me_datetime ->
  #           Logger.info "Found a new reminder! Setting up a reminder... #{inspect r}"
  #           state = set_up_reminder(r, state)
  #           process_reminders(rest, state)
  #       end
  #   end
  # end

  # defp reminder_already_pending?(r, state) when is_list(state) do
  #   state |> Enum.member?(r)
  # end

  # defp set_up_reminder({_key, _data} = r, state, time_in_minutes) do
  #   Process.send_after(self(), {:reminder!, r}, time_in_minutes * (60 * 1000))
  #   state ++ [r]
  # end
  # defp set_up_reminder({_key, data} = r, state) do
  #   now_utc = DateTime.utc_now()
  #   remind_me_datetime = data["remind_me_datetime"]
  #   {:ok, remind_me_utc, 0} = remind_me_datetime |> DateTime.from_iso8601()
  #   case DateTime.compare(remind_me_utc, now_utc) do
  #     future when future in [:gt] ->
  #       notify_delay_ms = DateTime.diff(remind_me_utc, DateTime.utc_now()) * 1000 |> IO.inspect
  #       Process.send_after(self(), {:reminder!, r}, notify_delay_ms)
  #       state ++ [r]
  #     past_or_present when past_or_present in [:lt, :eq] ->
  #       Logger.warn "This reminder is in the past! #{inspect r}"
  #       Process.send_after(self(), {:reminder!, r}, @default_reminder_time_in_minutes * (60 * 1000))
  #       state ++ [r]
  #   end
  # end

  # defp ack_reminder_in_user_data_file(r) do
  #   ackd_reminder = r |> TidBit.ack_reminder()
  #   Utilities.Data.replace_tidbit(r, ackd_reminder)
  # end

  # add a new buffer to the state's buffer_list
  # defp add_buffer(state, buf, f) do
  #   buf_frame = {buf: buf, frame: f}

  #   state
  #   |> Map.update!(:buffers, fn buf_list -> buf_list ++ [buf_frame] end)
  # end
end