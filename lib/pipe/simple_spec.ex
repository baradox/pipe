defmodule Pipe.SimpleSpec do
  defstruct module: nil, function: nil, returns: :both
  @type t :: %__MODULE__{module: module, function: atom, returns: Pipe.Spec.result_type}
end


defimpl Pipe.Spec, for: Pipe.SimpleSpec do
  def run(spec, value, context) do
    result = apply(spec.module, spec.function, [value, context])
    case spec.returns do
      :nothing ->
        {value, context}
      :value ->
        {result, context}
      :context ->
        {value, result}
      :both ->
        result
    end
  end
end