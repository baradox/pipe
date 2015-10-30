defmodule Pipe.SimpleSpecTest do
  use ExSpec, async: true

  describe "run/3 for: Pipe.SimpleSpec" do
    defmodule Test do
      def returns_both(value, context) do
        {value + 1, context |> Dict.put(:returns, 1)}
      end

      def returns_value(value, _context) do
        value + 1
      end

      def returns_context(_value, context) do
        context |> Dict.put(:returns, 1)
      end

      def returns_nothing(_value, _context) do
        "1"
      end

      def raises(_value, _context) do
        raise "Oops"
      end
    end

    it "interprets result from a spec that returns both context and value as {value, context}" do
      assert Pipe.Spec.run(%Pipe.SimpleSpec{module: Test, function: :returns_both, returns: :both}, 1, [initial: 1]) ==
        {2, [returns: 1, initial: 1]}
    end

    it "interprets result from a spec that returns only value as value" do
      assert Pipe.Spec.run(%Pipe.SimpleSpec{module: Test, function: :returns_value, returns: :value}, 1, [initial: 1]) ==
        {2, [initial: 1]}
    end

    it "interprets result from a spec that returns only context as context" do
      assert Pipe.Spec.run(%Pipe.SimpleSpec{module: Test, function: :returns_context, returns: :context}, 1, [initial: 1]) ==
        {1, [returns: 1, initial: 1]}
    end

    it "interprets a spec that returns nothing as nothing" do
      assert Pipe.Spec.run(%Pipe.SimpleSpec{module: Test, function: :returns_nothing, returns: :nothing}, 1, [initial: 1]) ==
        {1, [initial: 1]}
    end

    it "runs a spec that returns nothing" do
      assert_raise RuntimeError, fn ->
        Pipe.Spec.run(%Pipe.SimpleSpec{module: Test, function: :raises, returns: :nothing}, 1, [initial: 1])
      end
    end
  end
end
