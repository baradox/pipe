defmodule Pipe.SpecTest do
  use ExSpec
  import Mock

  describe "run/3 for: List" do
    it "runs a (nested) list of specs sequentially" do
      with_mock Pipe.Spec.Atom, [:passthrough], [run: fn
        (:plus_one, value, context)-> {value + 1, context |> Dict.put(:plus_one, 0)}
        (:minus_two, value, context)-> {value - 2, context |> Dict.put(:minus_two, 0)}
        (:multiply_by_three, value, context)-> {value * 3, context |> Dict.put(:multiply_by_three, 0)}
        end] do
        assert Pipe.Spec.run([:plus_one, :minus_two, [:multiply_by_three, :multiply_by_three]], 0, [outside: 0]) ==
               {-9, [multiply_by_three: 0, minus_two: 0, plus_one: 0, outside: 0]}
      end
    end
  end


  describe "run/3 for: Atom" do
    it "runs the spec returned by the module's with function" do
      defmodule Test do
        def with(_context \\ []) do
          [:spec]
        end
      end

      with_mock Pipe.Spec.List, [:passthrough], [run: fn
        ([:spec], value, context)-> {value + 1, context |> Dict.put(:inside, 0)}
        end] do
        assert Pipe.Spec.run(Test, 1, [outside: 0]) == {2, [inside: 0, outside: 0]}
      end
    end
  end
end
