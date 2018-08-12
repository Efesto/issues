defmodule CliTest do
  use ExUnit.Case
  doctest Issues

  import Issues.CLI, only: [
    parse_args: 1,
    sort_into_descending_order: 1
  ]

  test ":help returned by option parsing with -h and --help options" do
    assert parse_args(["-h", "whatever"]) == :help
    assert parse_args(["--help", "whatever"]) == :help
  end

  test "three values returned if three given" do
    assert parse_args(["user", "project", "999"]) === {"user", "project", 999}
  end

  test "three with defautl count returned if two given" do
    assert parse_args(["user", "project"]) === {"user", "project", 4}
  end

  test "sort descending order by created_at" do
    issues = [
      %{"created_at" => "2018-03-12", "id" => 1},
      %{"created_at" => "2018-03-13", "id" => 2},
      %{"created_at" => "2017-05-13", "id" => 3}
    ]
    result = issues
    |> sort_into_descending_order 
    |> Enum.map(&(&1["id"]))
    
    assert result == [2,1,3]
  end
end
