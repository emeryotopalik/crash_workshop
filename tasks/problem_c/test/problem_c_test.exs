defmodule ProblemCTest do
  use ExUnit.Case
  doctest ProblemC

  test "fetch a value from a map when key exists returns {:ok, value}" do
    assert {:ok, :bar} =
      ProblemC.run(fn() ->
        Map.fetch!(%{foo: :bar}, :foo)
      end)
  end

  test "fetch a value from a map when key does not exist returns {:error, _}" do
    assert {:error, %KeyError{}} =
      ProblemC.run(fn() ->
        # key :buzz does exist in map
        Map.fetch!(%{foo: :bar}, :buzz)
      end)
  end

  test "run/1 uses linked process and does not trap exits" do
    ref = make_ref()
    {_, monitor} = spawn_monitor(fn() ->
      try do
        ProblemC.run(fn() ->
          # start a linked task inside the fun that always exits
          fn() -> exit({:shutdown, ref}) end
          |> Task.async()
          |> Task.await()
        end)
      after
          flunk "trapping exits!"
      end
    end)

    # process calling run/1 exited with the same reason as linked task
    assert_receive {:DOWN, ^monitor, _, _, {:shutdown, ^ref}}
  end

  test "run/1 exit reason includes reason that process exited" do
    Process.flag(:trap_exit, true)
    ref = make_ref()
    assert {{:shutdown, ref}, {Task, :await, _}} =
      catch_exit(ProblemC.run(fn() ->
        exit({:shutdown, ref})
      end))
  end

  test "run/1 exit reason includes reason of exit signal crash process" do
    Process.flag(:trap_exit, true)
    ref = make_ref()
    assert {{:shutdown, ref}, {Task, :await, _}} =
      catch_exit(ProblemC.run(fn() ->
        # start a linked task inside the fun that always exits
        fn() -> exit({:shutdown, ref}) end
        |> Task.async()
        |> Task.await()
      end))
  end
end
