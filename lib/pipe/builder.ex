defmodule Pipe.Builder do
  defmacro __before_compile__(_env) do
    quote do
      def with(context \\ []) do
        %Pipe.ContextSpec{spec: @specs, context: context}
      end
    end
  end

  defmacro pipe(spec), do: _pipe(:both, spec)
  defmacro pipe(head, do: block), do: _pipe(:both, head, do: block)

  defmacro value_pipe(spec), do: _pipe(:value, spec)
  defmacro value_pipe(head, do: block), do: _pipe(:value, head, do: block)

  defmacro context_pipe(spec), do: _pipe(:context, spec)
  defmacro context_pipe(head, do: block), do: _pipe(:context, head, do: block)

  defmacro passthru_pipe(spec), do: _pipe(:nothing, spec)
  defmacro passthru_pipe(head, do: block), do: _pipe(:nothing, head, do: block)

  defmacro left ~> right do
    quote bind_quoted: [left: left, right: right] do
      List.wrap(left) ++ List.wrap(right)
    end
  end

  def _add_pipe(module, type, spec) do
    specs = Module.get_attribute(module, :specs) || []
    Module.put_attribute(module, :specs, specs ++ [%Pipe.EffectSpec{spec: spec, affects: type}])
  end

  defp _pipe(type, spec) do
    quote do
      Pipe.Builder._add_pipe(__MODULE__, unquote(type), unquote(spec))
    end
  end

  defp _pipe(type, head, do: block) do
    {name, _} = Macro.decompose_call(head)

    quote do
      def unquote(head), do: unquote(block)

      Pipe.Builder._add_pipe(
        __MODULE__,
        unquote(type),
        %Pipe.SimpleSpec{module: __MODULE__, function: unquote(name), returns: unquote(type)}
      )
    end
  end
end