using Metatheory
using Metatheory.Library


t₁ = @theory a b begin
  :true --> :a ≥ :0
  a --> cond(:true, a, -a)
  -(-a) --> a
end

g₁ = EGraph(:(a))
saturate!(g₁, t₁)
g₁

