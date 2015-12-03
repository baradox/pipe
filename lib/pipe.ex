defmodule Pipe do
  defmacro __using__(_opts) do
    quote do
      @specs []

      import Pipe.Builder, only: [
        ~>: 2,
        pipe: 1, pipe: 2,
        value_pipe: 1, value_pipe: 2,
        context_pipe: 1, context_pipe: 2,
        passthru_pipe: 1, passthru_pipe: 2,
      ]

      @doc false
      def run(value, context) do
        Pipe.run(value, __MODULE__, context)
      end

      @doc false
      def run(context \\ []) do
        Pipe.run(nil, __MODULE__, context)
      end

      @doc false
      def call(value, context) do
        Pipe.call(value, __MODULE__, context)
      end

      @doc false
      def call(context \\ []) do
        Pipe.call(nil, __MODULE__, context)
      end

      @before_compile Pipe.Builder
    end
  end

  @doc "runs a pipe with {value, context} returns new {value, context}"
  def run(value, spec, context) do
    Pipe.Spec.run(spec, value, context)
  end

  @doc "runs a pipe with {nil, context} returns new {value, context}"
  def run(spec, context) do
    run(nil, spec, context)
  end

  @doc "runs a pipe with {value, context} returns new value"
  def call(value, spec, context) do
    {value, _} = run(value, spec, context)
    value
  end

  @doc "runs a pipe with {nil, context} returns new value"
  def call(spec, context) do
    call(nil, spec, context)
  end
end
