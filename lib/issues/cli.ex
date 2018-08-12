defmodule Issues.CLI do
  @default_count 4

  def run(argv) do
    parse_args(argv)
    |> process
    |> display
  end

  def parse_args(argv) do
    OptionParser.parse(
      argv,
      switches: [help: :boolean],
      aliases: [h: :help]
    )
    |> elem(1)
    |> args_to_internal
  end

  def args_to_internal([user, project, count]), do: {user, project, String.to_integer(count)}
  def args_to_internal([user, project]), do: {user, project, @default_count}
  def args_to_internal(_), do: :help

  def process(:help) do
    IO.puts """
    usage: issues <user> <project> [ count | #{@default_count}]
    """

    System.halt(0)
  end

  def process({user, project, count}) do
    Issues.GithubIssues.fetch(user, project)
    |> decode_response
    |> sort_into_descending_order
    |> last(count)
  end

  def display(issues) do
    issues 
    |> format_issues
    |> Enum.each(&(IO.puts &1))
  end

  def format_issues([head|tail]) do
    ["#{head["id"]} | #{head["created_at"]} | #{head["title"]}"| format_issues(tail)]
  end
  def format_issues([]), do: []

  def decode_response({:ok, body}), do: body
  def decode_response({:error, error}) do
    IO.puts("Error fetching from Github: #{error["message"]}")
    System.halt(2)
  end

  def last(list, count) do
    list 
    |> Enum.take(count)
    |> Enum.reverse
  end

  def sort_into_descending_order(issues) do
    Enum.sort(issues, fn i1, i2 -> 
      i1["created_at"] >= i2["created_at"]
    end)
  end

end
