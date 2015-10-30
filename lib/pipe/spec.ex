defprotocol Pipe.Spec do
  @doc "Returns new value and context for the given spec"
  def run(spec, value, context)

  @type result_type :: :nothing | :value | :context | :both
end

defimpl Pipe.Spec, for: List do
  def run(spec, value, context) do
    Enum.reduce(spec, {value, context}, fn(s, {value, context})->
      Pipe.Spec.run(s, value, context)
    end)
  end
end

defimpl Pipe.Spec, for: Atom do
  def run(module, value, context) do
    Pipe.Spec.run(module.with(), value, context)
  end
end

