defmodule ProblemD do
  @moduledoc """
  ProblemD.
  """

  @enforce_keys [:pid, :ref]
  defstruct [:pid, :ref]

  @doc """
  Start a task and await on the result, as `Task.async`.
  """
  def async(fun)

  @doc """
  Await the result of a task, as `Task.await`
  """
  def await(task, timeout)

  @doc """
  Yield to wait the result of a task, as `Task.yield`.
  """
  def yield(task, timeout)
end
