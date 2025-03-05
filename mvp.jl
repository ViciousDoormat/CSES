using Metatheory
using Metatheory.Library
using Metatheory.EGraphs
using IterTools

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
  true --> :a ≥ :zero
  a --> cond(true, a, -a)
  -(-a) == a
  -(:zero) == :zero
end

g₁ = EGraph{Expr, Nothing}(:(a))
saturate!(g₁, t₁)
println(g₁)

t₂ = @theory a begin
  false --> :a ≥ :zero
  -a --> cond(false, a, -a)
  -(-a) == a
  -(:zero) == :zero
end

g₂ = EGraph{Expr, Nothing}(:(-a))
saturate!(g₂, t₂)
println(g₂)

"""
For each node in an eclass, get its root constant
Then return a dictionary with the constant as key and the node as value
"""
function get_eclass_constants(g::EGraph, c::EClass)
  constants = Dict{Symbol, VecExpr}()
  for node in c.nodes  
      v = v_head(node)
      c = get_constant(g, v)
      if typeof(c) != Symbol
        println(typeof(c))
        c = Symbol(c) #TODO find out why this is necessary
      end
      constants[c] = node
    end
  return constants
end

"""
Interstects two eclasses
Find equal constants in two eclasses
If found, find equal expressions in the children
Go on until all equal expressions are found
"""
function eclass_intersect(g₁::EGraph, g₂::EGraph, c₁::EClass=g₁[g₁.root], c₂::EClass=g₂[g₂.root], seen=Set{Tuple{Id, Id}}())

  #TODO add memoization
  #I think you can record that something isnt seen yet, is being explored, or has been explored
  !in((c₁.id, c₂.id), seen) || (return nothing)
  push!(seen, (c₁.id, c₂.id))

  c₁_constants = get_eclass_constants(g₁, c₁)
  c₂_constants = get_eclass_constants(g₂, c₂)

  common_constants = intersect(Set{Symbol}(collect(keys(c₁_constants))), Set{Symbol}(collect(keys(c₂_constants))))

  # define set of extracted programs
  found_programs = Vector()

  for c in common_constants
    node₁ = c₁_constants[c]
    node₂ = c₂_constants[c]

    children₁ = v_children(node₁)
    children₂ = v_children(node₂)

    # if the nodes have no children, they must be equal and complete
    if length(children₁) == 0 
      push!(found_programs, c) # add constant to extracted programs and continue
      continue 
    end

    # else, for each child, recursively check if they have representations of that child that are equal
    all_child_programs = Vector() # make an array. for each i, store the found programs
    for i in eachindex(children₁)
      seen_child = copy(seen) # every recursion branch should have its own seen set
      child₁ = children₁[i]
      child₂ = children₂[i]
      c_child₁ = g₁[child₁]
      c_child₂ = g₂[child₂]
      child_programs = eclass_intersect(g₁, g₂, c_child₁, c_child₂, seen_child)
      child_programs !== nothing || break
      push!(all_child_programs, child_programs)
    end

    if length(all_child_programs) == length(children₁)
      #return true 
      combinations = collect(IterTools.product(all_child_programs...))
      for combination in combinations
        # for each combination of all_child_programs, perform a maketerm() and add to found_programs
        p = maketerm(Expr, c, combination, nothing)
        push!(found_programs, p)
      end
    end    
    
  end

  if isempty(found_programs)
    return nothing
  else
    return found_programs
  end
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

