defmodule Pipe.ContextSpec do
  defstruct spec: nil, context: []
  @type t :: %__MODULE__{spec: Pipe.Spec.t, context: Dict.t}


  defimpl Pipe.Spec, for: Pipe.ContextSpec do
    def run(spec, value, context) do
      Pipe.Spec.run(spec.spec, value, context |> Dict.merge(spec.context))
    end
  end
end