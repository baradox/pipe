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

        pipe TestPipe
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
        assert Pipe.run(1, TestUsingPipe, [initial: 1]) == {7, [from_inline_context_pipe: 1, from_inline_pipe: 1, from_test_pipe: 1, from_context_pipe: 1, from_pipe: 1, initial: 1]}
        assert called Action.call(7, [])
      end
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

  describe "value/2" do
    it 'runs Pipe.Spec.run with nil value and returns value only' do
      with_mock Pipe.Spec, [:passthrough], [run: fn(:spec, nil, context)->{1, context} end] do
        assert Pipe.value(:spec, [context: 0]) == 1
      end
    end
  end

  describe "value/3" do
    it 'runs Pipe.Spec.run and returns value only' do
      with_mock Pipe.Spec, [:passthrough], [run: fn(:spec, value, context)->{value, context} end] do
        assert Pipe.value(1, :spec, [context: 0]) == 1
      end
    end
  end

  describe "context/2" do
    it 'runs Pipe.Spec.run with nil value and returns context only' do
      with_mock Pipe.Spec, [:passthrough], [run: fn(:spec, nil, context)->{1, context |> Dict.put(:inner, 1)} end] do
        assert Pipe.context(:spec, [context: 0]) == [inner: 1, context: 0]
      end
    end
  end

  describe "context/3" do
    it 'runs Pipe.Spec.run and returns context only' do
      with_mock Pipe.Spec, [:passthrough], [run: fn(:spec, 1, context)->{1, context |> Dict.put(:inner, 1)} end] do
        assert Pipe.context(1, :spec, [context: 0]) == [inner: 1, context: 0]
      end
    end
  end
end
