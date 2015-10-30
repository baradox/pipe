defmodule Pipe.BuilderTest do
  use ExSpec

  describe "__before_compile__/1" do
    defmodule TestBeforeCompile do
      @specs [:spec]
      @before_compile Pipe.Builder
    end

    it "returns a %Pipe.ContextSpec{} with the given context" do
      assert TestBeforeCompile.with([x: 0]) == %Pipe.ContextSpec{context: [x: 0], spec: [:spec]}
    end

    it "returns a %Pipe.ContextSpec{context: []} when no context is supplied" do
      assert TestBeforeCompile.with() == %Pipe.ContextSpec{context: [], spec: [:spec]}
    end
  end

  describe "pipe/1" do
    defmodule TestPipe1 do
      import Pipe.Builder

      pipe :spec

      def specs do
        @specs
      end
    end

    it "adds a spec with effect :both" do
      assert TestPipe1.specs == [%Pipe.EffectSpec{affects: :both, spec: :spec}]
    end
  end

  describe "pipe/2" do
    defmodule TestPipe2 do
      import Pipe.Builder

      pipe test(value, context) do
        {value, context}
      end

      def specs do
        @specs
      end
    end

    it "defines the function and adds a spec returns :both with effect :both" do
      assert TestPipe2.test(1, []) == {1, []}
      assert TestPipe2.specs == [%Pipe.EffectSpec{
        affects: :both,
        spec: %Pipe.SimpleSpec{
          function: :test,
          module: Pipe.BuilderTest.TestPipe2,
          returns: :both
         }
       }]
    end
  end

  describe "value_pipe/1" do
    defmodule TestValuePipe1 do
      import Pipe.Builder

      value_pipe :spec

      def specs do
        @specs
      end
    end

    it "adds a spec with effect :value" do
      assert TestValuePipe1.specs == [%Pipe.EffectSpec{affects: :value, spec: :spec}]
    end
  end

  describe "value_pipe/2" do
    defmodule TestValuePipe2 do
      import Pipe.Builder

      value_pipe test(value, _) do
        value
      end

      def specs do
        @specs
      end
    end

    it "defines the function and adds a spec that returns :value with effect :value" do
      assert TestValuePipe2.test(1, []) == 1
      assert TestValuePipe2.specs == [%Pipe.EffectSpec{
        affects: :value,
        spec: %Pipe.SimpleSpec{
          function: :test,
          module: Pipe.BuilderTest.TestValuePipe2,
          returns: :value
        }
      }]
    end
  end

  describe "context_pipe/1" do
    defmodule TestContextPipe1 do
      import Pipe.Builder

      context_pipe :spec

      def specs do
        @specs
      end
    end

    it "adds a spec with effect :context" do
      assert TestContextPipe1.specs == [%Pipe.EffectSpec{affects: :context, spec: :spec}]
    end
  end

  describe "context_pipe/2" do
    defmodule TestContextPipe2 do
      import Pipe.Builder

      context_pipe test(_, context) do
        context
      end

      def specs do
        @specs
      end
    end

    it "defines the function and adds a spec returns :context with effect :context" do
      assert TestContextPipe2.test(1, []) == []
      assert TestContextPipe2.specs == [%Pipe.EffectSpec{
        affects: :context,
        spec: %Pipe.SimpleSpec{
          function: :test,
          module: Pipe.BuilderTest.TestContextPipe2,
          returns: :context
         }
       }]
    end
  end

  describe "passthru_pipe/1" do
    defmodule TestPassthruPipe1 do
      import Pipe.Builder

      passthru_pipe :spec

      def specs do
        @specs
      end
    end

    it "adds a spec with effect :nothing" do
      assert TestPassthruPipe1.specs == [%Pipe.EffectSpec{affects: :nothing, spec: :spec}]
    end
  end

  describe "passthru_pipe/2" do
    defmodule TestPassthruPipe2 do
      import Pipe.Builder

      passthru_pipe test(value, context) do
        {value, context}
      end

      def specs do
        @specs
      end
    end

    it "defines the function and adds a spec returns :nothing with effect :nothing" do
      assert TestPassthruPipe2.test(1, []) == {1, []}
      assert TestPassthruPipe2.specs == [%Pipe.EffectSpec{
        affects: :nothing,
        spec: %Pipe.SimpleSpec{
          function: :test,
          module: Pipe.BuilderTest.TestPassthruPipe2,
          returns: :nothing
         }
       }]
    end
  end

  describe "~>/2" do
    it "concatenates specs" do
      import Pipe.Builder, only: [~>: 2]
      assert [:spec1] ~> :spec2 ~> [:spec3] == [:spec1, :spec2, :spec3]
    end
  end
end
