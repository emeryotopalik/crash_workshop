defmodule ProblemATest do
  use ExUnit.Case
  doctest ProblemA

  test "process is not alive one second after sending :stop" do
    {:ok, pid} = ProblemA.start_link()
    send(pid, :stop)
    # wait for 1000ms
    :timer.sleep(1000)
    # check process is dead
    refute Process.alive?(pid)
  end
end
