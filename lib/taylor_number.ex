defmodule TaylorNumber do
  @moduledoc """
  A symbolic ('lazy') representation of a number,
  to be calculated up to an arbitrary to-be-specified precision at a later time.

  Combination of a Taylor Sequence with a number `x`.
  """

  defstruct [:taylor, :x]

  def new(x) do
    new(Taylor.const, x)
  end

  def new(taylor = %Taylor{}, x) do
    %__MODULE__{taylor: taylor, x: x}
  end

  def evaluate(tn) do
    Taylor.evaluate(tn.taylor, tn.x)
  end



end

defimpl Inspect, for: TaylorNumber do
  def inspect(tn = %TaylorNumber{}, _opts) do
    "#TaylorNumber< #{tn.taylor.name.(inspect(tn.x)) } >"
  end
end
