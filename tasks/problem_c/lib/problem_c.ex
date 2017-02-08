defmodule ProblemC do
  @moduledoc """
  ProblemC.
  """

  @doc """
  Run an anonymous function in a separate process.

  Returns `{:ok, result} if the function runs successfully, otherwise
  `{:error, exception}` if an exception is raised.
  """
  def run(fun) do
    task = Task.async(fun)
    {:ok, Task.await(task, :infinity)}
  end
end
