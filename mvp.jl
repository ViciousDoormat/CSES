using Metatheory
using Metatheory.Library
using Metatheory.EGraphs
using IterTools

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
      typeof(c) == Symbol || (c = Symbol(string(c))) #TODO Check if this always works
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
function eclass_intersect(g₁::EGraph, g₂::EGraph, c₁::EClass=g₁[g₁.root], c₂::EClass=g₂[g₂.root], seen=Set{Tuple{Id, Id}}(), found=Dict{Tuple{Id,Id},Union{Vector{Union{Symbol,Expr}}, Nothing}}())
  # if the considered eclasses have already been seen together for this operator, we found a cycle and return nothing
  !in((c₁.id, c₂.id), seen) || (return nothing)
  # if the eclasses have already been intersected, return the result (improves efficiency)
  haskey(found, (c₁.id, c₂.id)) && (return found[(c₁.id, c₂.id)])
  push!(seen, (c₁.id, c₂.id))
  c₁_constants = get_eclass_constants(g₁, c₁)
  c₂_constants = get_eclass_constants(g₂, c₂)

  common_constants = intersect(Set{Symbol}(collect(keys(c₁_constants))), Set{Symbol}(collect(keys(c₂_constants))))

  # define set of extracted programs
  found_programs = Vector()

  for c in common_constants
    (node₁, node₂) = (c₁_constants[c], c₂_constants[c])

    (children₁, children₂) = (v_children(node₁), v_children(node₂))

    #nodes with same symbol but different children count are different operations (unary vs binary -)
    length(children₁) == length(children₂) || continue

    # if the nodes have no children, they must be equal and complete
    if length(children₁) == 0 
      push!(found_programs, c) # add constant to extracted programs and continue
      continue 
    end

    # else, for each child, recursively check if they have representations of that child that are equal
    all_child_programs = Vector() # make an array. for each parameter, store the found programs
    for i in eachindex(children₁)
      seen_child = copy(seen) # every recursion branch should have its own seen set 
      c_child₁ = g₁[children₁[i]]
      c_child₂ = g₂[children₂[i]]
      child_programs = eclass_intersect(g₁, g₂, c_child₁, c_child₂, seen_child, found)
      child_programs !== nothing || break
      push!(all_child_programs, child_programs)
    end

    if length(all_child_programs) == length(children₁)
      combinations = collect.(collect(IterTools.product(all_child_programs...)))
      #combinations = [collect(c) for c in combinations] #TODO why doest make vectors automatically?
      for combination in combinations
        # for each combination of parameters, make the total term and add to found_programs
        if v_iscall(node₁)
          p = maketerm(Expr, :call, [c; combination], nothing)
        else
          p = maketerm(Expr, c, combination, nothing) #TODO do I need this?
        end
        push!(found_programs, p)
      end
    end    
    
  end

  if isempty(found_programs)
    found_programs = nothing
  end
  found[(c₁.id, c₂.id)] = found_programs
  return found_programs
end

eclass_intersect(g₁, g₂)

"""
Interstects any number of eclasses
Find equal operations in the eclasses
If found, find equal expressions in the children
Go on until all equal expressions are found
"""
function eclass_intersect_many(gs::Vector{<:EGraph}, cs::Vector{<:EClass}=map(g -> g[g.root], gs), seen=Set{Vector{Id}}(), found=Dict{Vector{Id},Union{Vector{Union{Symbol,Expr}},Nothing}}())
  ids = map(c -> c.id, cs)
  # if the considered eclasses have already been seen together for this operator, we found a cycle and return nothing
  !in(ids, seen) || (return nothing)
  # if the eclasses have already been intersected, return the result (improves efficiency)
  haskey(found, ids) && (return found[ids])
  push!(seen, ids)

  c_constants = map((g,c) -> get_eclass_constants(g, c), gs, cs)
  common_constants = intersect(map(c -> Set{Symbol}(collect(keys(c))), c_constants)...)

  # define set of extracted programs
  found_programs = Vector()

  for c in common_constants
    nodes = map(cᵢ -> cᵢ[c], c_constants)
    children = map(n -> v_children(n), nodes)

    #nodes with same symbol but different children count are different operations (unary vs binary -)
    all(length(children[1]) == length(children[i]) for i in eachindex(children)) || continue

    # if the nodes have no children, they must be equal and complete
    if length(children[1]) == 0 
      push!(found_programs, c) # add constant to extracted programs and continue
      continue 
    end

    # else, for each child, recursively check if they have representations of that child that are equal
    all_child_programs = Vector() # make an array. for each parameter, store the found programs
    for i in eachindex(children[1])
      seen_child = copy(seen) # every recursion branch should have its own seen set
      c_childs = map((g,child) -> g[child[i]], gs, children)
      child_programs = eclass_intersect_many(gs, c_childs, seen_child)
      child_programs !== nothing || break
      push!(all_child_programs, child_programs)
    end

    if length(all_child_programs) == length(children[1])
      combinations = collect.(collect(IterTools.product(all_child_programs...)))
      for combination in combinations
        # for each combination of parameters, make the total term and add to found_programs
        if v_iscall(nodes[1])
          p = maketerm(Expr, :call, [c; combination], nothing)
        else
          p = maketerm(Expr, c, combination, nothing) #TODO do I need this?
        end
        push!(found_programs, p)
      end
    end    
    
  end

  if isempty(found_programs)
    found_programs = nothing
  end
  found[ids] = found_programs
  return found_programs
end

eclass_intersect_many([g₁, g₂])