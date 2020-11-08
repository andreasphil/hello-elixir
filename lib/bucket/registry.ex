defmodule Hello.Registry do
  use GenServer

  # ----- Client methods ----- #
  # Technically we could call the server methods below directly, but we're wrapping them into this
  # public API which is a bit cleaner and optimized for our specific use case.

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def lookup(server, name) do
    GenServer.call(server, {:lookup, name})
  end

  def create(server, name) do
    GenServer.cast(server, {:create, name})
  end

  # ----- Server implementation ----- #

  # Annotation that this implements a callback
  @impl true
  def init(:ok) do
    names = %{}
    refs = %{}
    {:ok, {names, refs}}
  end

  # Calls are synchronous = client needs to wait for the server to respond
  # This implementation uses pattern matching in function parameters to only handle calls with the
  # :lookup message.
  @impl true
  def handle_call({:lookup, name}, _from, state) do
    {names, _} = state
    {:reply, Map.fetch(names, name), state}
  end

  # Casts are asynchronous = client will not wait for the server to respond; server will not send
  # a response.
  # Uses pattern matching for only handle :create casts
  @impl true
  def handle_cast({:create, name}, {names, refs}) do
    if Map.has_key?(names, name) do
      {:noreply, {names, refs}}
    else
      {:ok, bucket} = Hello.Bucket.start_link([])
      ref = Process.monitor(bucket)
      refs = Map.put(refs, ref, name)
      names = Map.put(names, name, bucket)
      {:noreply, {names, refs}}
    end
  end

  # Info = all other messages to the server that are not handled via send/2 or handle_info/2.
  @impl true
  def handle_info({:DOWN, ref, :process, _pid, _reason}, {names, refs}) do
    {name, refs} = Map.pop(refs, ref)
    names = Map.delete(names, name)
    {:noreply, {names, refs}}
  end

  @impl true
  def handle_info(_msg, state) do
    {:noreply, state}
  end
end
