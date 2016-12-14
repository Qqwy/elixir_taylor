defmodule Taylor do
  defstruct [:function, :name]

  @default_precision 10

  alias Numbers, as: N

  # First argument should be 'x', second argument should be 'n'.
  def new(function, name) when is_function(function, 2) do
    %__MODULE__{function: function, name: name}
  end

  def apply(series, x) do
    TaylorNumber.new(series, x)
  end

  def evaluate(series = %__MODULE__{}, x, precision \\ @default_precision) when is_integer(precision) do
    Stream.iterate(0, &(&1+1))
    |> Stream.map(&(series.function.(x, &1)))
    |> Enum.take(precision)
    |> Enum.reduce(&(N.add(&1, &2)))
  end

  def fact(integer) do
    Math.factorial(integer)
  end

  binops = [add: "+", sub: "-", mult: "*", div: "/", pow: "^"]

  for {binop, opsymbol} <- binops do
    def unquote(binop)(t1 = %__MODULE__{}, t2 = %__MODULE__{}) do
      new(fn x, n ->
        N.unquote(binop)(t1.function.(x, n), t2.function.(x, n))
      end, fn x -> "(#{t1.name.(x)} #{unquote(opsymbol)} #{t2.name.(x)})" end)
    end
  end

  unaryops = [:minus, :abs]
  for unaryop <- unaryops do
    def unquote(unaryop)(t1 = %__MODULE__{}) do
      fn x, n -> N.unquote(unaryop)(t1.function.(x, n)) end
    end
  end

  def const do
    new(fn
      x, 0 -> x
      _, n -> 0
    end,
    fn x -> x end)
  end

  def exp do
    new(fn x, n -> N.div(N.pow(x, n), fact(n)) end, fn x -> "e^(#{x})" end)
  end

  def sin do
    new(fn x, n ->
      N.mult(N.div(N.pow(Decimal.new(-1), n), Math.factorial(2 * n + 1)), N.pow(x, 2 * n + 1))
    end, fn x -> "sin(#{x})" end)
  end

  def cos do
    new(fn x, n ->
      N.mult(N.div(N.pow(Decimal.new(-1), n), Math.factorial(2 * n)), N.pow(x, 2 * n))
    end, fn x -> "cos(#{x})" end)
  end
end

defimpl Inspect, for: Taylor do
  def inspect(taylor = %Taylor{}, _opts) do
    "#Taylor< #{taylor.name.("x")} >"
  end
end
