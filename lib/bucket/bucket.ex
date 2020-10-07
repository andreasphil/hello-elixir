defmodule Hello.Bucket do
  # The code in our module and the agent consitute a client/server relationship. All code inside
  # the fns passed to the agent are run on the server (= the agent). The server is blocked for the
  # duration of the operation, so subsequent calls need to pause until it has completed. If we're
  # using timeouts in calls to the server, these might expire while we're waiting.
  use Agent

  @doc """
  Starts a new bucket.
  """
  def start_link do
    # `fn` creates an anonymous function
    Agent.start_link(fn -> %{} end)
  end

  @doc """
  Gets a value from the bucket by its key.
  """
  def get(bucket, key) do
    # `&` is the capture operator. It can be used to reference a function by its name and number
    # of parameters (arity). E.g. &Map.get/3 is the same as fn -> Map.get(...) (arity can be omitted
    # because there is only one `Map.get` in this case). While in the scope of a captured function,
    # &1, &2, etc. refer to the position of the parameter that the captured function is called with.
    Agent.get(bucket, &Map.get(&1, key))
  end

  @doc """
  Puts the value for the given key in the bucket.
  """
  def put(bucket, key, value) do
    Agent.update(bucket, &Map.put(&1, key, value))
  end

  @doc """
  Deletes a key from the bucket. Returns the current value of `key` if it exists.
  """
  def delete(bucket, key) do
    # `get_and_update` changes the state of an agent and returns a value. The fn passed as the
    # parameter is required to return a tuple like this: `{returnValue, newState}`. Map.pop/2
    # returns such a tuple, consisting of the removed value (or nil) at the first position and
    # the updated map at the second.
    Agent.get_and_update(bucket, &Map.pop(&1, key))
  end
end
