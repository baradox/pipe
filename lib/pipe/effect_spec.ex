defmodule Pipe.EffectSpec do
  defstruct spec: nil, affects: :both
  @type t :: %__MODULE__{spec: Pipe.Spec.t, affects: Pipe.Spec.result_type}
end


defimpl Pipe.Spec, for: Pipe.EffectSpec do
  def run(spec, value, context) do
    {result_value, result_context} = Pipe.Spec.run(spec.spec, value, context)
    case spec.affects do
      :nothing ->
        {value, context}
      :value ->
        {result_value, context}
      :context ->
        {value, result_context}
      :both ->
        {result_value, result_context}
    end
  end
end