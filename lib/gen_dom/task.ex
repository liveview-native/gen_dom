defmodule GenDOM.Task do
  @moduledoc false

  defguardp is_timeout(timeout)
    when timeout == :infinity or (is_integer(timeout) and timeout >= 0)

  def await_one(tasks, timeout \\ 5_000) when is_list(tasks) do
    awaiting =
      Map.new(tasks, fn %Task{ref: ref, owner: owner} = task ->
        if owner != self() do
          raise ArgumentError, invalid_owner_error(task)
        end

        {ref, true}
      end)

    timeout_ref = make_ref()

    timer_ref =
      if timeout != :infinity do
        Process.send_after(self(), timeout_ref, timeout)
      end

    try do
      await_one(tasks, timeout, awaiting, timeout_ref)
    after
      timer_ref && Process.cancel_timer(timer_ref)
      receive do: (^timeout_ref -> :ok), after: (0 -> :ok)
    end
  end

  def await_one(_tasks, _timeout, awaiting, _timeout_ref) when map_size(awaiting) == 0 do
    nil
  end

  def await_one(tasks, timeout, awaiting, timeout_ref) do
    receive do
      ^timeout_ref ->
        demonitor_pending_tasks(awaiting)
        exit({:timeout, {__MODULE__, :await_one, [tasks, timeout]}})

      {:DOWN, ref, _, proc, reason} when is_map_key(awaiting, ref) ->
        demonitor_pending_tasks(awaiting)
        exit({reason(reason, proc), {__MODULE__, :await_many, [tasks, timeout]}})

      {ref, nil} when is_map_key(awaiting, ref) ->
        demonitor(ref)
        await_one(tasks, timeout, Map.delete(awaiting, ref), timeout_ref)

      {ref, reply} when is_map_key(awaiting, ref) ->
        awaiting = Map.delete(awaiting, ref)
        demonitor_pending_tasks(awaiting)
        # shutdown_pending_tasks(awaiting)

        reply
    end
  end

  def await_many(tasks, timeout \\ 60_000) when is_timeout(timeout) do
    awaiting =
      Map.new(tasks, fn %Task{ref: ref, owner: owner} = task ->
        if owner != self() do
          raise ArgumentError, invalid_owner_error(task)
        end

        {ref, true}
      end)

    timeout_ref = make_ref()

    timer_ref =
      if timeout != :infinity do
        Process.send_after(self(), timeout_ref, timeout)
      end

    try do
      await_many(tasks, timeout, awaiting, %{}, timeout_ref)
    after
      timer_ref && Process.cancel_timer(timer_ref)
      receive do: (^timeout_ref -> :ok), after: (0 -> :ok)
    end
  end

  defp await_many(tasks, _timeout, awaiting, replies, _timeout_ref)
       when map_size(awaiting) == 0 do
    for %{ref: ref} <- tasks, do: Map.fetch!(replies, ref)
  end

  defp await_many(tasks, timeout, awaiting, replies, timeout_ref) do
    receive do
      ^timeout_ref ->
        demonitor_pending_tasks(awaiting)
        exit({:timeout, {__MODULE__, :await_many, [tasks, timeout]}})

      {:DOWN, ref, _, proc, reason} when is_map_key(awaiting, ref) ->
        demonitor_pending_tasks(awaiting)
        exit({reason(reason, proc), {__MODULE__, :await_many, [tasks, timeout]}})

      {ref, nil} when is_map_key(awaiting, ref) ->
        demonitor(ref)

        await_many(
          Enum.reject(tasks, &(&1.ref == ref)),
          timeout,
          Map.delete(awaiting, ref),
          replies,
          timeout_ref
        )

      {ref, reply} when is_map_key(awaiting, ref) ->
        demonitor(ref)

        await_many(
          tasks,
          timeout,
          Map.delete(awaiting, ref),
          Map.put(replies, ref, reply),
          timeout_ref
        )
    end
  end

  defp demonitor_pending_tasks(awaiting) do
    Enum.each(awaiting, fn {ref, _} ->
      demonitor(ref)
    end)
  end

  defp reason(:noconnection, proc), do: {:nodedown, monitor_node(proc)}
  defp reason(reason, _), do: reason

  defp monitor_node(pid) when is_pid(pid), do: node(pid)
  defp monitor_node({_, node}), do: node

  defp demonitor(ref) when is_reference(ref) do
    Process.demonitor(ref, [:flush])
    :ok
  end

  defp invalid_owner_error(task) do
    "task #{inspect(task)} must be queried from the owner but was queried from #{inspect(self())}"
  end
end
