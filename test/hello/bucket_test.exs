defmodule Hello.BucketTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, bucket} = Hello.Bucket.start_link()

    # The return value of the last statement in a function is returned by the function.
    # In this case, the return value of setup is merged into the `context` of all tests that
    # follow.
    #
    # Note that there are two syntaxes for map literals:
    # - `%{:bucket => bucket}` (key is an atom in this case, but can be anything)
    # - `%{bucket: bucket}` (shorthands syntax if the key is an atom)
    %{bucket: bucket}
  end

  # Test takes as a second parameter a `context` object. Below we're extracting the bucket value
  # from the context using pattern matching.
  test "stores values by key", %{bucket: bucket} do
    assert Hello.Bucket.get(bucket, "milk") === nil

    Hello.Bucket.put(bucket, "milk", 3)
    assert Hello.Bucket.get(bucket, "milk") === 3
  end

  test "removes an existing value by key", %{bucket: bucket} do
    Hello.Bucket.put(bucket, "milk", 2)
    assert Hello.Bucket.delete(bucket, "milk") === 2
  end

  test "returns nil when attempting to remove a non-existent key", %{bucket: bucket} do
    assert Hello.Bucket.get(bucket, "milk") === nil
    assert Hello.Bucket.delete(bucket, "milk") === nil
  end
end
