defmodule Pipe.ContextSpecTest do
  use ExSpec
  import Mock

  describe "run/3 for: Pipe.EffectSpecTest" do
    it "runs an enclosed spec with overriding context" do
      with_mock Pipe.Spec.Atom, [:passthrough], [run: fn
        (:spec, value, context)-> {value + 1, context |> Dict.put(:spec, 0)}
        end] do
        assert Pipe.Spec.run(%Pipe.ContextSpec{spec: :spec, context: [override: 1]}, 1, [initial: 0]) == {2, [spec: 0, override: 1, initial: 0]}
      end
    end
  end
end