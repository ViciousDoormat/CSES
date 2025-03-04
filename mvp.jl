using Metatheory
using Metatheory.Library
using Metatheory.EGraphs

#compare this with using true and false

# t₁ = @theory a begin
#   is_positive(a) --> :a ≥ :0
#   a --> cond(is_positive(a), a, -a)
#   -(-a) == a
# end

# g₁ = EGraph{Expr, Nothing}(:(a))
# saturate!(g₁, t₁)
# println(g₁)

# t₂ = @theory a begin
#   is_positive(a) --> :a ≥ 0
#   -a --> cond(is_positive(a), a, -a)
#   -(-a) == a
# end

# g₂ = EGraph{Expr, Nothing}(:(-a))
# saturate!(g₂, t₂)
# println(g₂)

t₁ = @theory a begin
  true --> :a ≥ zero
  a --> cond(true, a, -a)
  -(-a) == a
  -zero == zero
end

g₁ = EGraph{Expr, Nothing}(:(a))
saturate!(g₁, t₁)
println(g₁)

t₂ = @theory a begin
  false --> :a ≥ zero
  -a --> cond(false, a, -a)
  -(-a) == a
  -zero == zero
end

g₂ = EGraph{Expr, Nothing}(:(-a))
saturate!(g₂, t₂)
println(g₂)

"""
Interstects two eclasses
Find equal constants in two eclasses
If found, find equal expressions in the children
Go on until all equal expressions are found
"""
function eclass_intersect(g₁::EGraph, g₂::EGraph, c₁::EClass=g₁[g₁.root], c₂::EClass=g₂[g₂.root], seen=Set{Tuple{Id, Id}}())

  !in((c₁.id, c₂.id), seen) || (return false)
  push!(seen, (c₁.id, c₂.id))

  c₁_constants = Dict{Symbol, VecExpr}()
  for node in c₁.nodes
      v = v_head(node)
      c = get_constant(g₁, v)
      if typeof(c) != Symbol
        c = Symbol(c)
      end
      c₁_constants[c] = node
  end

  c₂_constants = Dict{Symbol, VecExpr}()
  for node in c₂.nodes
      v = v_head(node)
      c = get_constant(g₂, v)
      if typeof(c) != Symbol
        c = Symbol(c)
      end
      c₂_constants[c] = node
  end

  common_constants = intersect(Set{Symbol}(collect(keys(c₁_constants))), Set{Symbol}(collect(keys(c₂_constants))))

  for c in common_constants
    node₁ = c₁_constants[c]
    node₂ = c₂_constants[c]

    children₁ = v_children(node₁)
    children₂ = v_children(node₂)

    all_equal = true

    if length(children₁) > 0
      for i in eachindex(children₁)
        seen_child = copy(seen)
        child₁ = children₁[i]
        child₂ = children₂[i]
        c_child₁ = g₁[child₁]
        c_child₂ = g₂[child₂]
        all_equal = all_equal && eclass_intersect(g₁, g₂, c_child₁, c_child₂, seen_child)
      end
    end

    if all_equal
      return true #TODO change to returning all common expressions
    end    
    
  end

  return false
end

eclass_intersect(g₁, g₂)

# f = @theory a b c begin
#   0 --> :a - :a
#   a --> a + 0
#   a + (b - c) --> (a + b) - c
#   a + a --> 2a
#   a --> -5 # I literally say that everything can be rewritten to -5
# end

# h = EGraph(:(a-4))
# saturate!(h, f)
# h

