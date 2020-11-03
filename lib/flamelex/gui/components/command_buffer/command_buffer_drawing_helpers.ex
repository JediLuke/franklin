defmodule Flamelex.GUI.Component.CommandBuffer.DrawingHelpers do
  use Flamelex.ProjectAliases


  @prompt_color :ghost_white
  @prompt_size 18
  @prompt_margin 12

  @font_size Flamelex.GUI.Fonts.size()
  # @cursor_width GUI.FontHelpers.monospace_font_width(:ibm_plex, @font_size) #TODO get this properly
  @cursor_width 16

  @text_field_left_margin 2 # distance between the left-hand side of the text field box, and the start of the actual text. We want a little margin here for aesthetics
  # @prompt_to_blinker_distance 22
  # @empty_command_buffer_text_prompt "Enter a command..."


  def draw_command_prompt(graph, %Frame{
    #NOTE: These are the coords/dimens for the whole CommandBuffer Frame
    coordinates: %Coordinates{x: _top_left_x, y: top_left_y},
    dimensions: %Dimensions{height: height, width: _width}
  }) do
    #NOTE: The y_offset
    #      ------------
    #      From the top-left position of the box, the command prompt
    #      y-offset. (height - prompt_size) is how much bigger the
    #      buffer is than the command prompt, so it gives us the extra
    #      space - we divide this by 2 to get how much extra space we
    #      need to add, to the reference y coordinate, to center the
    #      command prompt inside the buffer
    y_offset = top_left_y + (height - @prompt_size)/2

    #NOTE: How Scenic draws triangles
    #      --------------------------
    #      Scenic uses 3 points to draw a triangle, which look like this:
    #
    #           x - point1
    #           |\
    #           | \ x - point2 (apex of triangle)
    #           | /
    #           |/
    #           x - point3
    point1 = {@prompt_margin, y_offset}
    point2 = {@prompt_margin+prompt_width(@prompt_size), y_offset+@prompt_size/2}
    point3 = {@prompt_margin, y_offset + @prompt_size}

    graph
    |> Scenic.Primitives.triangle({point1, point2, point3}, fill: @prompt_color)
  end

  def calc_textbox_frame(_buffer_frame = %Frame{
    #NOTE: These are the coords/dimens for the whole CommandBuffer Frame
    coordinates: %Coordinates{x: cmd_buf_top_left_x, y: cmd_buf_top_left_y},
    dimensions: %Dimensions{height: cmd_buf_height, width: cmd_buf_width}
  }) do
    total_prompt_width = prompt_width(@prompt_size) + (2*@prompt_margin)

    textbox_coordinates = {
      # this is the x coord for the top-left corner of the Textbox - take the CommandBuffer top_left_x and add some margin
      cmd_buf_top_left_x + total_prompt_width,
      # this is the y coord for the top-left corner of the Textbox - plus 5 to move the box down, because remember we reference from top-left corner
      cmd_buf_top_left_y + 5
    }

    textbox_width      = cmd_buf_width - total_prompt_width - @prompt_margin
    textbox_dimensions = {textbox_width, cmd_buf_height - 10}

    textbox_frame =
      Frame.new(
        top_left_corner: textbox_coordinates |> Coordinates.new(),
        dimensions:      textbox_dimensions  |> Dimensions.new())

    # return
    textbox_frame
  end

  def draw_input_textbox(graph, %Frame{} = textbox_frame) do
    graph
    |> Draw.border_box(textbox_frame)
  end

  def draw_cursor(
        graph,
        %Frame{
           coordinates: %Coordinates{x: container_top_left_x, y: container_top_left_y},
           dimensions:  %Dimensions{height: container_height, width: _container_width}
        },
        id: cursor_component_id)
  do

    cursor_frame = Frame.new(
      id:              cursor_component_id,
      top_left_corner: {container_top_left_x, container_top_left_y},
      dimensions:      {@cursor_width, container_height})

    graph
    |> GUI.Component.Cursor.add_to_graph(cursor_frame)
  end

  def draw_text_field(
        graph,
        content,
        %Frame{
           coordinates: %Coordinates{x: container_top_left_x, y: container_top_left_y},
           dimensions:  %Dimensions{height: container_height, width: _container_width}
        },
        id: text_field_id)
  do

    graph
    |> Scenic.Primitives.text(
         content,
         id:        text_field_id,
         translate: # {x_coord, y_coord}
                    {container_top_left_x + @text_field_left_margin,
                     container_top_left_y + (container_height-4)}, # text draws from bottom-left corner?? :( also, how high is it??? #TODO
         font_size: @font_size,
         fill:      :white)

  end

  defp prompt_width(prompt_size) do
    prompt_size * 0.67
  end
end