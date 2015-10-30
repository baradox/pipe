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
  def value(value, spec, context) do
    {value, _} = run(value, spec, context)
    value
  end

  @doc "runs a pipe with {nil, context} returns new value"
  def value(spec, context) do
    value(nil, spec, context)
  end

  @doc "runs a pipe with {value, context} returns new context"
  def context(value, spec, context) do
    {_, context} = run(value, spec, context)
    context
  end

  @doc "runs a pipe with {nil, context} returns new context"
  def context(spec, context) do
    context(nil, spec, context)
  end
end
