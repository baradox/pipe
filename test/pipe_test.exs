defmodule PipeTest do
  use ExSpec
  import Mock

  describe "__using__/1" do
    it "defines a pipe" do
      defmodule TestPipe do
        use Pipe

        pipe process(value, context) do
          {value + 1, context |> Dict.put(:from_test_pipe, 1)}
        end
      end

      defmodule TestUsingPipe do
        use Pipe

        pipe TestPipe ~> TestPipe ~> TestPipe
        pipe TestPipe.with(from_pipe: 1)
        value_pipe TestPipe.with(from_value_pipe: 1)
        context_pipe TestPipe.with(from_context_pipe: 1)
        passthru_pipe TestPipe.with(from_passthru_pipe: 1)

        pipe inline_pipe(value, context) do
          {value * 2, context |> Dict.put(:from_inline_pipe, 1)}
        end

        value_pipe inline_value_pipe(value, _) do
          value - 1
        end

        context_pipe inline_context_pipe(_, context) do
          context |> Dict.put(:from_inline_context_pipe, 1)
        end

        passthru_pipe inline_passthru_pipe(value, _) do
          Action.call(value, [])
        end
      end

      with_mock Action, [:non_strict], [call: fn(_, _)-> end] do
        assert Pipe.run(1, TestUsingPipe, [initial: 1]) == {11, [from_inline_context_pipe: 1, from_inline_pipe: 1, from_test_pipe: 1, from_context_pipe: 1, from_pipe: 1, initial: 1]}
        assert called Action.call(11, [])
      end
    end

    defmodule TestConvenienceMethods do
      use Pipe

      pipe test(value, context) do
        {value, context |> Dict.put(:context, 1)}
      end
    end


    it "defines run/1" do
      assert TestConvenienceMethods.run() == {nil, [context: 1]}
      assert TestConvenienceMethods.run([run: 1]) == {nil, [context: 1, run: 1]}
    end

    it "defines run/2" do
      assert TestConvenienceMethods.run(1, [run: 1]) == {1, [context: 1, run: 1]}
    end

    it "defines call/1" do
      assert TestConvenienceMethods.call() == nil
      assert TestConvenienceMethods.call([]) == nil
    end

    it "defines call/2" do
      assert TestConvenienceMethods.call(1, []) == 1
    end
  end

  describe "run/2" do
    it 'runs Pipe.Spec.run with nil value' do
      with_mock Pipe.Spec, [:passthrough], [run: fn(:spec, nil, context)->{1, context} end] do
        assert Pipe.run(:spec, [context: 0]) == {1, [context: 0]}
      end
    end
  end

  describe "run/3" do
    it 'runs Pipe.Spec.run' do
      with_mock Pipe.Spec, [:passthrough], [run: fn(:spec, value, context)->{value, context} end] do
        assert Pipe.run(1, :spec, [context: 0]) == {1, [context: 0]}
      end
    end
  end

  describe "call/2" do
    it 'runs Pipe.Spec.run with nil value and returns value only' do
      with_mock Pipe.Spec, [:passthrough], [run: fn(:spec, nil, context)->{1, context} end] do
        assert Pipe.call(:spec, [context: 0]) == 1
      end
    end
  end

  describe "call/3" do
    it 'runs Pipe.Spec.run and returns value only' do
      with_mock Pipe.Spec, [:passthrough], [run: fn(:spec, value, context)->{value, context} end] do
        assert Pipe.call(1, :spec, [context: 0]) == 1
      end
    end
  end
end
