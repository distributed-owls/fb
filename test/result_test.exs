defmodule FE.ResultTest do
  use ExUnit.Case, async: true
  doctest FE.Result

  alias FE.Result

  test "ok can be created with a constructor" do
    assert Result.ok(:foo) == {:ok, :foo}
  end

  test "error can be created with a constructor" do
    assert Result.error("bar") == {:error, "bar"}
  end

  test "mapping over an error returns the same error" do
    assert Result.map(Result.error(:foo), fn _ -> :bar end) == Result.error(:foo)
  end

  test "mapping over an ok value applies function to value" do
    assert Result.map(Result.ok(2), &(&1 * 5)) == Result.ok(10)
  end

  test "unwrap_or returns default value if an error is passed" do
    assert Result.unwrap_or(Result.error(:foo), :default) == :default
    assert Result.unwrap_or(Result.error("bar"), nil) == nil
  end

  test "unwrap_or returns wrapped value if an ok is passed" do
    assert Result.unwrap_or(Result.ok(:bar), :default) == :bar
    assert Result.unwrap_or(Result.ok(3), :x) == 3
  end

  test "unwrap! returns wrapped value if an ok is passed" do
    assert Result.unwrap!(Result.ok(:foo)) == :foo
  end

  test "unwrap! raises an exception if an error is passed" do
    assert_raise FE.Result.Error, "unwrapping Result with an error", fn ->
      Result.unwrap!(Result.error(:bar))
    end
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

  test "fold over an empty list returns passed result" do
    baz = fn _, _ -> Result.ok(:baz) end
    assert Result.fold(Result.ok(:foo), [], baz) == Result.ok(:foo)
    assert Result.fold(Result.error(:bar), [], baz) == Result.error(:bar)
  end

  test "fold over a single value applies function to it if the ok value passed" do
    assert Result.fold(Result.ok(10), [5], &Result.ok(&1 + &2)) == Result.ok(15)

    assert Result.fold(Result.ok(20), [5], fn _, _ -> Result.error(:bar) end) ==
             Result.error(:bar)
  end

  test "fold over a single value doesn't apply function if error is passed" do
    assert Result.fold(Result.error(:foo), [5], &Result.ok(&1 + &2)) == Result.error(:foo)
  end

  test "fold over values returns last value returned by function if it returns only oks" do
    assert Result.fold(Result.ok(1), [2, 3, 4], &Result.ok(&1 * &2)) == Result.ok(24)
  end

  test "fold over values returns error when the function returns it" do
    assert Result.fold(Result.ok(1), [2, 3, 4], fn
             _, 6 -> Result.error("it's a six!")
             x, y -> Result.ok(x + y)
           end) == Result.error("it's a six!")
  end
end
