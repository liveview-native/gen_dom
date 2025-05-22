defmodule GenDOM do
  def generate_name(prefix) when is_atom(prefix),
    do: generate_name(Atom.to_string(prefix))

  def generate_name(prefix) do
    prefix <> "-" <>
    (:crypto.hash(:sha, "#{:erlang.system_time(:nanosecond)}")
    |> Base.encode32(case: :lower))
    |> String.to_atom()
  end
end
