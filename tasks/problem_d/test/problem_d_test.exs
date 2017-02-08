defmodule ProblemDTest do
  use ExUnit.Case
  doctest ProblemD

  test "async uses a monitor" do
    %ProblemD{ref: ref} = ProblemD.async(fn() -> 1 + 1 end)
    assert_receive {^ref, 2}
    assert_receive {:DOWN, ^ref, :process, _, :normal}
  end

  test "async uses a link" do
    Process.flag(:trap_exit, true)
    assert %ProblemD{ref: ref, pid: pid} = ProblemD.async(fn() -> 1 + 1 end)

    assert_receive {^ref, 2}
    assert_receive {:EXIT, ^pid, :normal}
  end

  test "await returns result" do
    task = ProblemD.async(fn() -> 1 + 1 end)
    assert ProblemD.await(task, 5000) == 2
  end

  test "await flushes monitor on result" do
    task = ProblemD.async(fn() -> 1 + 1 end)
    assert %ProblemD{ref: ref} = task
    assert ProblemD.await(task, 5000) == 2

    refute Process.demonitor(ref, [:info])
    refute_received {:DOWN, ^ref, _, _, _}
  end

  @tag :capture_log
  test "await exits on exception" do
    Process.flag(:trap_exit, true)

    task = ProblemD.async(fn() -> raise "oops" end)
    assert {{%RuntimeError{message: "oops"}, [_|_]},
            {ProblemD, :await, [^task, 123]}} =
      catch_exit(ProblemD.await(task, 123))
  end

  test "await exits on timeout" do
    task = ProblemD.async(fn() -> :timer.sleep(:infinity) end)
    assert {:timeout, {ProblemD, :await, [^task, 123]}} =
      catch_exit(ProblemD.await(task, 123))
  end

  test "await flushes monitor on timeout" do
    task = ProblemD.async(fn() -> :timer.sleep(:infinity) end)
    assert %ProblemD{ref: ref} = task
    assert catch_exit(ProblemD.await(task, 123))

    refute Process.demonitor(ref, [:info])
    refute_received {:DOWN, ^ref, _, _, _}
  end

  test "await exits on normal exit" do
    task = ProblemD.async(fn() -> exit(:normal) end)
    assert {:normal, {ProblemD, :await, [^task, 123]}} =
      catch_exit(ProblemD.await(task, 123))
  end

  test "yield returns result" do
    task = ProblemD.async(fn() -> 1 + 1 end)
    assert ProblemD.yield(task, 5000) == {:ok, 2}
  end

  test "yield flushes monitor on result" do
    task = ProblemD.async(fn() -> 1 + 1 end)
    assert %ProblemD{ref: ref} = task
    assert ProblemD.yield(task, 5000) == {:ok, 2}

    refute Process.demonitor(ref, [:info])
    refute_received {:DOWN, ^ref, _, _, _}
  end

  @tag :capture_log
  test "yield returns exit on exception" do
    Process.flag(:trap_exit, true)
    task = ProblemD.async(fn() -> raise "oops" end)
    assert {:exit, {%RuntimeError{message: "oops"}, [_|_]}} =
      ProblemD.yield(task, 123)
  end

  test "yield returns nil on timeout" do
    task = ProblemD.async(fn() -> :timer.sleep(:infinity) end)
    assert ProblemD.yield(task, 123) == nil
  end

  test "yield can be used until result received" do
    task = ProblemD.async(fn() ->
      receive do
        :done ->
          :done
      end
    end)
    assert ProblemD.yield(task, 123) == nil
    assert ProblemD.yield(task, 123) == nil
    assert %ProblemD{pid: pid} = task
    send(pid, :done)
    assert ProblemD.yield(task, 123) == {:ok, :done}
  end

  test "yield does NOT flush monitor on timeout" do
    task = ProblemD.async(fn() -> :timer.sleep(:infinity) end)
    assert ProblemD.yield(task, 123) == nil

    assert %ProblemD{ref: ref} = task
    assert Process.demonitor(ref, [:flush, :info])
  end

  test "yield returns exit on normal exit" do
    task = ProblemD.async(fn() -> exit(:normal) end)
    assert ProblemD.yield(task, 123) == {:exit, :normal}
  end
end
