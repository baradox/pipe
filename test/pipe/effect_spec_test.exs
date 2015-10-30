defmodule Pipe.EffectSpecTest do
  use ExSpec
  import Mock

  describe "run/3 for: Pipe.EffectSpecTest" do
    it "returns both value and context from an enclosed spec that affects both" do
      with_mock Pipe.Spec.Atom, [:passthrough], [run: fn
        (:spec, value, context)-> {value + 1, context |> Dict.put(:spec, 0)}
        end] do
        assert Pipe.Spec.run(%Pipe.EffectSpec{spec: :spec, affects: :both}, 1, [initial: 0]) == {2, [spec: 0, initial: 0]}
      end
    end

    it "returns value and original context from an enclosed spec that affects value" do
      with_mock Pipe.Spec.Atom, [:passthrough], [run: fn
        (:spec, value, context)-> {value + 1, context |> Dict.put(:spec, 0)}
        end] do
        assert Pipe.Spec.run(%Pipe.EffectSpec{spec: :spec, affects: :value}, 1, [initial: 0]) == {2, [initial: 0]}
      end
    end

    it "returns original value and context from an enclosed spec that affects context" do
      with_mock Pipe.Spec.Atom, [:passthrough], [run: fn
        (:spec, value, context)-> {value + 1, context |> Dict.put(:spec, 0)}
        end] do
        assert Pipe.Spec.run(%Pipe.EffectSpec{spec: :spec, affects: :context}, 1, [initial: 0]) == {1, [spec: 0, initial: 0]}
      end
    end

    it "returns original value and original context for an enclosed spec that affects nothing" do
      with_mock Pipe.Spec.Atom, [:passthrough], [run: fn
        (:spec, value, context)-> {value + 1, context |> Dict.put(:spec, 0)}
        end] do
        assert Pipe.Spec.run(%Pipe.EffectSpec{spec: :spec, affects: :nothing}, 1, [initial: 0]) == {1, [initial: 0]}
      end
    end
  end
end