defmodule GenDOM.Matcher do
  alias GenDOM.{
    Document,
    Element,
    Node,
    Matcher.Pseudo,
    Text
  }

  def match(element, matcher, opts \\ [])

  def match(%Text{}, _matcher, _opts) do
    nil
  end

  def match(%{} = element, {:tag_name, "*", _rule_opts}, _opts) do
    element
  end

  def match(%{tag_name: tag_name} = element, {:tag_name, tag_name, _rule_opts}, _opts) do
    element
  end

  def match(%{id: id} = element, {:id, id}, _opts) do
    element
  end

  def match(%{attributes: attributes} = element, {:attribute, {compare_type, name, compare_value, attr_opts}}, _opts) do
    name = apply_namespace(name, attr_opts[:namespace])

    with {:ok, actual_value} <- Map.fetch(attributes, name),
      {actual_value, compare_value} <- apply_case_sensitivity(actual_value, compare_value, attr_opts[:i]),
      true <- attribute_compare(compare_type, actual_value, compare_value, attr_opts) do
        element
    else
      _ -> nil
    end
  end
  
  def match(%{} = element, {:class, name}, _opts) when is_binary(name) do
    if name in element.class_list,
      do: element,
      else: nil
  end

  def match(%{} = element, {:class, names}, _opts) when is_list(names) do
    case (for name <- names, name in element.class_list, do: name) do
      [] -> nil
      _names -> element
    end
  end

  def match(%{} = element, {:pseudo_class, {type, params}}, opts) do
    Pseudo.match(element, type, params, opts)
  end

  def match(%{} = element, {:selectors, selectors}, opts) do
    all_descendants = :pg.get_members(element.pid)

    tasks = Enum.reduce(all_descendants, [], fn(pid, tasks) ->
      Enum.reduce(selectors, tasks, fn(selector, tasks) ->
        task = Task.async(fn ->
          element = GenServer.call(pid, :get)
          match(element, selector, opts)
        end)

        [task | tasks]
      end)
    end)

    case opts[:await].(tasks) do
      child_elements when is_list(child_elements) ->
        Enum.reduce(selectors, child_elements, fn(selector, child_elements) ->
          case match(element, selector, opts) do
            nil -> child_elements
            child_element -> [child_element | child_elements]
          end
        end)

      nil ->
        Enum.reduce_while(selectors, nil, fn
          selector, nil ->
            case match(element, selector, opts) do
              nil -> {:cont, nil}
              element -> {:halt, element}
            end
        end)

      child_element -> child_element
    end
  end

  def match(%{} = element, {:rules, [rule]}, opts) do
    match(element, rule, opts)
  end

  def match(%{} = element, {:rules, [rule | [{:rule, _next_rules, next_rule_opts} | _] = rules]}, opts) do
    rules = if match(element, rule, opts) do
      rules
    else
      [rule | rules]
    end

    {pids, opts} = if Keyword.get(opts, :recursive, true) do
      apply_options(element, next_rule_opts[:combinator], opts)
    else
      {[], opts}
    end

    tasks = Enum.map(pids, fn(pid) ->
      Task.async(fn ->
        case GenServer.call(pid, :get) do
          %Node{} -> nil
          %Text{} -> nil
          element ->
            match(element, {:rules, rules}, opts)
        end
      end)
    end)

    opts[:await].(tasks)
  end

  def match(%{} = element, {:rule, segments, _rule_opts}, opts) do
    Enum.reduce_while(segments, element, fn(segment, element) ->
      case match(element, segment, opts) do
        nil -> {:halt, nil}
        _element -> {:cont, element}
      end
    end)
  end

  def match(_element, _matcher, _opts) do
    nil
  end

  defp apply_options(%{} = element, nil, opts) do
    {:pg.get_members(element.pid), opts}
  end

  defp apply_options(%{} = element, ">", opts) do
    {element.child_nodes, Keyword.put(opts, :recursive, false)}  
  end

  defp apply_options(%{} = element, "+", opts) do
    parent = GenServer.call(element.parent_element, :get)
    element_idx = Enum.find_index(parent.child_nodes, &(&1 == element.pid))
    pids = case Enum.at(parent.child_nodes, element_idx + 1) do
      nil -> []
      sibling_pid -> [sibling_pid]
    end

    {pids, Keyword.put(opts, :recursive, false)}
  end

  defp apply_options(%{} = element, "~", opts) do
    parent = GenServer.call(element.parent_element, :get)
    element_pid = element.pid
    {_bool, pids} = Enum.reduce(parent.child_nodes, {false, []}, fn
      ^element_pid, {false, []} -> {true, []}
      child_pid, {true, child_pids} -> {true, [child_pid | child_pids]}
      _child_pid, {false, _child_pids} -> {false, []}
    end)

    {pids, Keyword.put(opts, :recursive, false)}
  end

  defp attribute_compare(:exists, _actual_value, _compare_value, _opts) do
    true
  end

  defp attribute_compare(:equal, actual_value, compare_value, _opts) do
    actual_value == compare_value
  end

  defp attribute_compare(:prefix, actual_value, compare_value, _opts) do
    String.starts_with?(actual_value, compare_value)
  end

  defp attribute_compare(:suffix, actual_value, compare_value, _opts) do
    String.ends_with?(actual_value, compare_value)
  end

  defp attribute_compare(:dash_match, actual_value, compare_value, _opts) do
    split_actual_value = String.split(actual_value, "-")

    compare_value in split_actual_value
  end

  defp attribute_compare(:substring, actual_value, compare_value, _opts) do
    String.contains?(actual_value, compare_value)
  end

  defp attribute_compare(:includes, actual_value, compare_value, _opts) do
    split_compare_value = String.split(compare_value)

    Enum.any?(split_compare_value, fn(compare_value) ->
      String.contains?(actual_value, compare_value)
    end)
  end

  defp apply_case_sensitivity(string_a, string_b, nil) do
    {string_a, string_b}
  end

  defp apply_case_sensitivity(string_a, string_b, _i) do
    {String.downcase(string_a), String.downcase(string_b)}
  end

  defp apply_namespace(name, nil) do
    name
  end

  defp apply_namespace(name, namespace) do
    "#{namespace}:#{name}"
  end
end
