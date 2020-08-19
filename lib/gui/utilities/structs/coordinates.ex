defmodule GUI.Structs.Coordinates do
  @moduledoc """
  Struct which holds 2d points.
  """
  use Franklin.Misc.CustomGuards

  defstruct [x: 0, y: 0]

  # def new(%__MODULE__{} = struct) do #TODO just return same struct?
  #   struct
  # end

  def new({x, y}) when is_positive_integer(x) and is_positive_integer(y) do
    %__MODULE__{
      x: x,
      y: y
    }
  end

  # def new(x: x, y: y) when is_positive_integer(x) and is_positive_integer(y) do
  #   %__MODULE__{
  #     x: x,
  #     y: y
  #   }
  # end
end
