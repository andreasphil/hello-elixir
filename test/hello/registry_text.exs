defmodule Hello.RegistryTest do
  use ExUnit.Case, async: true

  setup do
    # start_supervised/1 calls the start_link/1 method in the module passed to it. ExUnit will shut
    # down each process started this way before the next test runs, so we're always starting from
    # a blank slate. This is useful in testing because it helps avoid side effects messing up tests.
    # The docs recommend to always start processes in tests in this way.
    registry = start_supervised!(Hello.Registry)
    %{registry: registry}
  end

  test "spawns buckets" do
    assert Hello.Registry.lookup(registry, "shopping") == :error

    Hello.Registry.create(registry, "shopping")
    assert {:ok, bucket} = Hello.Registry.lookup(registry, "shopping")

    Hello.Bucket.put(bucket, "milk", 1)
    assert Hello.Bucket.get("milk") == 1
  end
end
