defmodule Rumbl.Multimedia.Permalink do
  use Ecto.Type

  def type, do: :id

  def cast(binary) when is_binary(binary) do
    case Integer.parse(binary) do
      {integer, _} when integer > 0 -> {:ok, integer}
      _ -> :error
    end
  end

  def cast(integer) when is_integer(integer) do
    {:ok, integer}
  end

  def cast(_), do: :error

  def dump(integer) when is_integer(integer), do: {:ok, integer}

  def load(integer) when is_integer(integer), do: {:ok, integer}
end
