defmodule Calmdo.EctoHelpers do
  import Ecto.Query

  def maybe_where(query, _field, nil), do: query
  def maybe_where(query, field, value), do: from(q in query, where: field(q, ^field) == ^value)
end
