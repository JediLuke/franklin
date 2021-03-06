defmodule Flamelex.Memex.Structs.Reminder do
  @moduledoc false
  require Logger

  # defguard is_valid(data) when is_map(data)

  @derive Jason.Encoder
  defstruct [
    uuid: nil,                # a UUIDv4
    # hash: nil,                # the md5 of the tidbit
    # title: nil,               # Title of the TidBit
    # tags: [],                 # any tags we want to apply to this TidBit
    # creation_timestamp: nil,  # when the TidBit was created
    # content: nil,             # actual TidBit content
    # remind_me_datetime: nil,  # when to remind me (for reminder TidBits)
    # due_datetime: nil,        # the due date (for reminders)
    # log: nil                  # a log of edits for this TidBit
  ]

  # def initialize(data), do: validate(data) |> create_struct()

  # def ack_reminder(reminder = %__MODULE__{tags: old_tags}) when is_list(old_tags) do
  #   new_tags =
  #     old_tags
  #     |> Enum.reject(& &1 == "reminder")
  #     |> Enum.concat(["ackd_reminder"])

  #   reminder |> Map.replace!(:tags, new_tags)
  # end


  ## private functions
  ## -------------------------------------------------------------------


  # defp validate(%{title: t, tags: tags, content: c} = data)
  #   when is_binary(t) and is_list(tags) and is_binary(c) do
  #     data = data |> Map.merge(%{
  #       uuid: UUID.uuid4(),
  #       creation_timestamp: DateTime.utc_now()
  #     })

  #     # take a hash of all other elements in the map
  #     hash =
  #       :crypto.hash(:md5, data |> Jason.encode!())
  #       |> Base.encode16()
  #       |> String.downcase()
  #     data |> Map.merge(%{hash: hash}) #TODO test this hashing thing
  # end
  # defp validate(_else), do: :invalid_data

  # defp create_struct(:invalid_data), do: raise "Invalid data provided when initializing #{__MODULE__}."
  # defp create_struct(data), do: struct(__MODULE__, data)

end
