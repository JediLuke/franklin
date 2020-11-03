defmodule Flamelex.GUI.Structs.Frame do #TODO rename this moduile to have utilities in it
  @moduledoc """
  Struct which holds relevant data for rendering a buffer frame status bar.
  """
  require Logger
  use Flamelex.ProjectAliases

  #TODO each "new/x" function should be making a new Scenic.Graph, we need
  # to actually build one and cant just use a default struct cause it spits chips

  defstruct [
    id:            nil,               # uniquely identify frames
    #TODO rename to top_left
    coordinates:   nil, # %Coordinates{},    # the top-left corner of the frame, referenced from top-left corner of the viewport
    dimensions:    nil, # :w%Dimensions{},     # the height and width of the frame
    scenic_opts:   [],                # Scenic options
    # picture_graph: %Scenic.Graph{}    # The Scenic.Graph that this frame will display
    buffer:        nil
  ]

  def test do
    new("tester", {100, 100}, {100, 100})
  end

  def new(slug, %Coordinates{} = c, %Dimensions{}  = d) do
    new(
      id:              slug,
      top_left_corner: %Coordinates{} = c,
      dimensions:      %Dimensions{}  = d
    )
  end
  def new(slug, coords, dimensions) do
    new(slug, Coordinates.new(coords), Dimensions.new(dimensions))
  end

  def new(
    top_left_corner: %Coordinates{} = c,
    dimensions:      %Dimensions{}  = d
  ) do
    %Frame{
      coordinates: c,
      dimensions:  d
    }
  end

  def new(top_left: top_left, size: size) do
    %Frame{
      id:          "#TODO",
      coordinates: top_left |> Coordinates.new(),
      dimensions:  size     |> Dimensions.new()
    }

  end

  #TODO do we really need an id?? (probably)
  def new(id:              id,
          top_left_corner: %Coordinates{} = c,
          dimensions:      %Dimensions{}  = d
  ) do
    %Frame{
      id:          id,
      coordinates: c,
      dimensions:  d
    }
  end

  #TODO deprecate this too
  # def new([id: id, top_left_corner: c, dimensions: d, picture_graph: g]) do
  def new([id: id, top_left_corner: c, dimensions: d, buffer: b]) do
    %Frame{
      id: id,
      coordinates: c |> Coordinates.new(),
      dimensions:  d |> Dimensions.new(),
      # picture_graph: g
      buffer: b
    }
  end

  #TODO deprecate these
  def new([id: id, top_left_corner: c, dimensions: d]) do
    %Frame{
      id: id,
      coordinates: c |> Coordinates.new(),
      dimensions:  d |> Dimensions.new()
    }
  end

  def new(top_left_corner: {_x, _y} = c, dimensions: {_w, _h} = d) do
    %Frame{
      coordinates: c |> Coordinates.new(),
      dimensions:  d |> Dimensions.new()
    }
  end

def new( _buf, top_left_corner: {_x, _y} = c, dimensions: {_w, _h} = d, opts: o)  when is_list(o) do #TODO do we need buffer here?
    %Frame{
      coordinates: c |> Coordinates.new(),
      dimensions:  d |> Dimensions.new(),
      scenic_opts: o
    }
  end

  def decorate_graph(%Scenic.Graph{} = graph, %Frame{} = frame, params) when is_map(params) do
    Logger.debug "#{__MODULE__} framing up... frame: #{inspect frame}, params: #{inspect params}"
    Logger.warn "Not rly framing anything yet..."
    graph
  end

  def find_center(%Frame{coordinates: c, dimensions: d}) do
    Coordinates.new([
      x: c.x + d.width/2,
      y: c.y + d.height/2,
    ])
  end

  def reposition(%Frame{coordinates: coords} = frame, x: new_x, y: new_y) do
    new_coordinates =
      coords
      |> Coordinates.modify(x: new_x, y: new_y)

    %{frame|coordinates: new_coordinates}
  end

  def draw(%Scenic.Graph{} = graph, %Frame{} = frame) do
    graph
    |> Draw.border_box(frame)
    |> draw_frame_footer(frame)
  end

  def draw(%Scenic.Graph{} = graph, %Frame{} = frame, opts) when is_map(opts) do
    graph
    |> draw_frame_footer(frame, opts)
    |> Draw.border_box(frame)
  end

  def draw(%Scenic.Graph{} = graph, %Frame{} = frame, %OmegaState{} = omega_state) do
    graph
    |> draw_frame_footer(frame, omega_state)
    |> Draw.border_box(frame)
  end

  def draw_frame_footer(graph, frame, %{mode: :normal} = opts) when is_map(opts) do
    w = frame.dimensions.width + 1 #NOTE: Weird scenic thing, we need the +1 or we see a thin line to the right of the box
    h = Flamelex.GUI.Component.MenuBar.height()
    x = frame.coordinates.x
    y = frame.dimensions.height - h # go to the bottom & back up how high the bar will be
    c = GUI.Colors.menu_bar()

    font_size = Flamelex.GUI.Fonts.size()

    graph
    |> Scenic.Primitives.rect({w, h}, translate: {x, y}, fill: c)
    |> Scenic.Primitives.rect({168, h}, translate: {x, y}, fill: GUI.Colors.mode(:normal))
    |> Scenic.Primitives.line({{x, y}, {w, y}}, stroke: {2, :black})
    |> Scenic.Primitives.line({{x, y}, {w, y}}, stroke: {2, :black})
    |> Scenic.Primitives.text("NORMAL-MODE", font: GUI.Fonts.primary(),
                translate: {x + 25, y + font_size + 2}, # text draws from bottom-left corner??
                font_size: font_size, fill: :black)
    |> Scenic.Primitives.text(frame.id, font: GUI.Fonts.primary(), #TODO should be frame.name ??
                translate: {x + 200, y + font_size + 2}, # text draws from bottom-left corner??
                font_size: font_size, fill: :black)
  end


  def draw_frame_footer(graph, frame, %{mode: :insert} = opts) when is_map(opts) do
    w = frame.dimensions.width + 1 #NOTE: Weird scenic thing, we need the +1 or we see a thin line to the right of the box
    h = Flamelex.GUI.Component.MenuBar.height()
    x = frame.coordinates.x
    y = frame.dimensions.height - h # go to the bottom & back up how high the bar will be
    c = GUI.Colors.menu_bar()

    font_size = Flamelex.GUI.Fonts.size()

    graph
    |> Scenic.Primitives.rect({w, h}, translate: {x, y}, fill: c)
    |> Scenic.Primitives.rect({168, h}, translate: {x, y}, fill: GUI.Colors.mode(:insert))
    |> Scenic.Primitives.line({{x, y}, {w, y}}, stroke: {2, :black})
    |> Scenic.Primitives.line({{x, y}, {w, y}}, stroke: {2, :black})
    |> Scenic.Primitives.text("INSERT-MODE", font: GUI.Fonts.primary(),
                translate: {x + 25, y + font_size + 2}, # text draws from bottom-left corner??
                font_size: font_size, fill: :black)
    |> Scenic.Primitives.text(frame.id, font: GUI.Fonts.primary(), #TODO should be frame.name ??
                translate: {x + 200, y + font_size + 2}, # text draws from bottom-left corner??
                font_size: font_size, fill: :black)
  end

  def draw_frame_footer(graph, frame) do
    w = frame.dimensions.width + 1 #NOTE: Weird scenic thing, we need the +1 or we see a thin line to the right of the box
    h = Flamelex.GUI.Component.MenuBar.height()
    x = frame.coordinates.x
    y = frame.dimensions.height # go to the bottom & back up how high the bar will be
    c = GUI.Colors.menu_bar()

    graph
    |> Scenic.Primitives.rect({w, h}, translate: {x, y}, fill: c)
  end

  def draw_frame_footer(graph, frame, %OmegaState{mode: :normal}) do
    w = frame.dimensions.width + 1 #NOTE: Weird scenic thing, we need the +1 or we see a thin line to the right of the box
    h = Flamelex.GUI.Component.MenuBar.height()
    x = frame.coordinates.x
    y = frame.dimensions.height - h # go to the bottom & back up how high the bar will be
    c = GUI.Colors.menu_bar()

    font_size = Flamelex.GUI.Fonts.size()

    graph
    |> Scenic.Primitives.rect({w, h}, translate: {x, y}, fill: c)
    |> Scenic.Primitives.rect({168, h}, translate: {x, y}, fill: GUI.Colors.mode(:normal))
    |> Scenic.Primitives.line({{x, y}, {w, y}}, stroke: {2, :black})
    |> Scenic.Primitives.line({{x, y}, {w, y}}, stroke: {2, :black})
    |> Scenic.Primitives.text("NORMAL-MODE", font: GUI.Fonts.primary(),
                translate: {x + 25, y + font_size + 2}, # text draws from bottom-left corner??
                font_size: font_size, fill: :black)
    |> Scenic.Primitives.text(frame.id, font: GUI.Fonts.primary(), #TODO should be frame.name ??
                translate: {x + 200, y + font_size + 2}, # text draws from bottom-left corner??
                font_size: font_size, fill: :black)
  end
end










# defmodule Flamelex.GUI.Component.Frame do
#   @moduledoc """
#   Frames are a very special type of Component - they are a container,
#   manipulatable by the layout of the root scene. Virtually all buffers
#   will render their corresponding Component in a Frame.
#   """

#   use Scenic.Component
#   use Flamelex.ProjectAliases
#   require Logger


#   @impl Scenic.Component
#   def verify(%Frame{} = frame), do: {:ok, frame}
#   def verify(_else), do: :invalid_data

#   @impl Scenic.Component
#   def info(_data), do: ~s(Invalid data)


#   ## GenServer callbacks
#   ## -------------------------------------------------------------------


#   @impl Scenic.Scene
#   def init(%Frame{} = frame, _opts) do
#     # IO.puts "Initializing #{__MODULE__}..."
#     {:ok, frame, push: GUI.GraphConstructors.Frame.convert(frame)}
#   end

#   # left-click
#   def handle_input({:cursor_button, {:left, :press, _dunno, _coords}} = action, _context, frame) do
#     # new_frame = frame |> ActionReducer.process(action)
#     new_graph = frame |> GUI.GraphConstructors.Frame.convert_2()
#     {:noreply, frame, push: new_graph}
#   end

#   def handle_input(event, _context, state) do
#     # state = Map.put(state, :contained, true)
#     IO.puts "EVENT #{inspect event}"
#     # {:noreply, state, push: update_color(state)}
#     {:noreply, state}
#   end

#   # def filter_event(event, _, state) do
#   #   IO.puts "EVENT #{event}"
#   #   {:cont, {:click, :transformed}, state}
#   # end

#   # def handle_continue(:draw_frame, frame) do

#   #   IO.inspect frame, label: "FFFFF"

#   #   new_graph =
#   #     frame.graph
#   #     |> Draw.box(
#   #             x: frame.coordinates.x,
#   #             y: frame.coordinates.y,
#   #         width: frame.width,
#   #        height: frame.height)

#   #   new_frame =
#   #     %{frame|graph: new_graph}

#   #   {:noreply, new_frame}
#   #   # {:noreply, new_frame, push: new_graph}
#   # end



#   ## private functions
#   ## -------------------------------------------------------------------


#   # defp register_process() do
#   #   #TODO search for if the process is already registered, if it is, engage recovery procedure
#   #   Process.register(self(), __MODULE__) #TODO this should be gproc
#   # end

#   # def initialize(%Frame{} = frame) do
#   #   # the textbox is internal to the command buffer, but we need the
#   #   # coordinates of it in a few places, so we pre-calculate it here
#   #   textbox_frame =
#   #     %Frame{} = DrawingHelpers.calc_textbox_frame(frame)

#   #   Draw.blank_graph()
#   #   |> Scenic.Primitives.group(fn graph ->
#   #        graph
#   #        |> Draw.background(frame, @command_mode_background_color)
#   #        |> DrawingHelpers.draw_command_prompt(frame)
#   #        |> DrawingHelpers.draw_input_textbox(textbox_frame)
#   #        |> DrawingHelpers.draw_cursor(textbox_frame, id: @cursor_component_id)
#   #        |> DrawingHelpers.draw_text_field("", textbox_frame, id: @text_field_id) #NOTE: Start with an empty string
#   #   end, [
#   #     id: @component_id,
#   #     hidden: true
#   #   ])
#   # end


#   # defp initialize_graph(coordinates: {x, y}, dimensions: {w, h}, color: c) do
#   #   Graph.build()
#   #   |> rect({w, h}, translate: {x, y}, fill: c)
#   # end
#   # defp initialize_graph(coordinates: {x, y}, dimensions: {w, h}, color: c, stroke: {s, border_color}) do
#   #   Graph.build()
#   #   |> rect({w, h}, translate: {x, y}, fill: c, stroke: {s, border_color})
#   # end
# end