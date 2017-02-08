defmodule ProblemBTest do
  use ExUnit.Case
  doctest ProblemB

  test "process is not alive after calling :stop" do
    {:ok, pid} = ProblemB.start()
    ProblemB.stop(pid)
    refute Process.alive?(pid)
  end
end
