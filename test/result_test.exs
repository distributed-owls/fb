defmodule FE.ResultTest do
  use ExUnit.Case, async: true
  doctest FE.Result

  alias FE.Result

  test "ok value can be created with a constructor" do
    assert Result.ok(:foo) == {:ok, :foo}
  end

  test "error value can be created with a constructor" do
    assert Result.error("bar") == {:error, "bar"}
  end

  test "mapping over an error returns the same error" do
    assert Result.map(Result.error(:foo), fn _ -> :bar end) == Result.error(:foo)
  end

  test "mapping over an ok value applies function to value" do
    assert Result.map(Result.ok(2), &(&1 * 5)) == Result.ok(10)
  end

  test "and_then returns error if an error is passed" do
    assert Result.and_then(Result.error(5), fn x -> Result.ok(x * 2) end) == Result.error(5)
  end

  test "and_then applies function to the ok value that's passed" do
    assert Result.and_then(Result.ok(5), fn x -> Result.ok(x * 2) end) == Result.ok(10)
  end

  test "and_then chain stops on first error" do
    result =
      Result.ok(1)
      |> Result.and_then(&Result.ok(&1 + 2))
      |> Result.and_then(&Result.error(&1 * 3))
      |> Result.and_then(&Result.ok(&1 - 4))

    assert result == Result.error(9)
  end

  test "and_then chain returns last if there is no error on the way" do
    result =
      Result.ok(1)
      |> Result.and_then(&Result.ok(&1 + 2))
      |> Result.and_then(&Result.ok(&1 * 3))
      |> Result.and_then(&Result.ok(&1 - 4))

    assert result == Result.ok(5)
  end
end