module Intersect
export eclass_intersect, eclass_intersect_many

using Metatheory
using Metatheory.Library
using Metatheory.EGraphs
using IterTools

using Infiltrator

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
function get_eclass_constants(g::EGraph, c::EClass, ::Type{AllTypes}) where {AllTypes}
  constants = Dict{Tuple{AllTypes,Int}, Vector{VecExpr}}()
  for node in c.nodes  
      v = v_head(node)
      c = get_constant(g, v)
      n = length(v_children(node))
      #typeof(c) == Symbol || (c = Symbol(string(c))) #TODO make this Union{Synbol,Expr,Int}
      haskey(constants, (c,n)) || (constants[(c,n)] = Vector{VecExpr}())
      push!(constants[(c,n)], node)
    end
  return constants
end

"""
Interstects two eclasses
Find equal constants in two eclasses
If found, find equal expressions in the children
Go on until all equal expressions are found
"""
function eclass_intersect(g₁::EGraph, g₂::EGraph, c₁::EClass=g₁[g₁.root], c₂::EClass=g₂[g₂.root], seen=Set{Tuple{Id, Id}}(), found=Dict{Tuple{Id,Id},Union{Vector{Union{Symbol,Expr,Int,Bool}}, Nothing}}())
  # if the considered eclasses have already been seen together for this operator, we found a cycle and return nothing
  !in((c₁.id, c₂.id), seen) || (return nothing)
  # if the eclasses have already been intersected, return the result (improves efficiency)
  haskey(found, (c₁.id, c₂.id)) && (return found[(c₁.id, c₂.id)])
  push!(seen, (c₁.id, c₂.id))
  c₁_constants_to_nodes = get_eclass_constants(g₁, c₁, Union{Int, Symbol, Bool})
  c₂_constants_to_nodes = get_eclass_constants(g₂, c₂, Union{Int, Symbol, Bool})
  common_constants = intersect(Set{Union{Symbol,Int,Bool}}(collect(keys(c₁_constants_to_nodes))), Set{Union{Symbol,Int,Bool}}(collect(keys(c₂_constants_to_nodes))))
  sort!(common_constants, by=(t -> t[2]))

  # define set of extracted programs
  found_programs = Vector()

  for c in common_constants
    (nodes₁, nodes₂) = (c₁_constants_to_nodes[c], c₂_constants_to_nodes[c])

    for node₁ in nodes₁, node₂ in nodes₂
      (children₁, children₂) = (v_children(node₁), v_children(node₂))

      #nodes with same symbol but different children count are different operations (unary vs binary -)
      length(children₁) == length(children₂) || continue

      # if the nodes have no children, they must be equal and complete
      if length(children₁) == 0 
        push!(found_programs, c[1]) # add constant to extracted programs and continue
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
        #println(combinations)
        #combinations = [collect(c) for c in combinations] #TODO why doest make vectors automatically?
        for combination in combinations
          # for each combination of parameters, make the total term and add to found_programs
          if v_iscall(node₁)
            p = maketerm(Expr, :call, [c[1]; combination], nothing)
          else
            p = maketerm(Expr, c[1], combination, nothing) #TODO do I need this?
          end
          push!(found_programs, p)
        end
      end  

    end  
    
  end

  if isempty(found_programs)
    found_programs = nothing
  end
  found[(c₁.id, c₂.id)] = found_programs
  return found_programs
end

#eclass_intersect(g₁, g₂)

"""
Interstects any number of eclasses
Find equal operations in the eclasses
If found, find equal expressions in the children
Go on until all equal expressions are found
"""
function eclass_intersect_many(::Type{AllTypes}, gs::Vector{<:EGraph}, cs::Vector{<:EClass}=map(g -> g[g.root], gs), seen=Set{Vector{Id}}(), found=Dict{Vector{Id},Union{Vector{AllTypes},Nothing}}()) where {AllTypes}
  
  ids = map(c -> c.id, cs) #BoundsError: attempt to access 22-element Vector{UInt64} at index [0]. bug: class 0 does not exist, but root is 0
  println("intesecting: ", ids)
  # if the considered eclasses have already been seen together for this operator, we found a cycle and return nothing
  
  # if the eclasses have already been intersected, return the result (improves efficiency)
  haskey(found, ids) && (return found[ids])
  
  if in(ids, seen)
    #return [:already_seen]
    println("already seen: ", ids)
    return [:already_seen]
    #TODO here, we are back at a point that we already have seen
    #TODO we came here with some sequence of operators
    #TODO say that we are back where we were, 
    #TODO and that, at the point where we started from here, we can apply those operators to the other programs found
    #TODO example: (x)<--A--(-)-->B--(-)-->A
    #TODO take the root from A to B with - and from B to a with -. Now we are here
    #TODO 1) in A, return already_seen(ids), now back at B
    #TODO 2) in B, return -already_seen(ids), now back at A
    #TODO 3) in A, we see that this.ids == ids, so we create map(x -> (-(-(x)), [x]) where [x] here is the list of other final found programs
    #TODO to tired now, but something like this must also happen in B to find -x
  end
  #println("seen: ", seen, " ids: ", ids)
  push!(seen, ids)

  println("finding common: ", ids)
  c_constants_to_nodes = map((g,c) -> get_eclass_constants(g, c, AllTypes), gs, cs)
  common_constants = intersect(map(c -> Vector{Tuple{AllTypes,Int}}(collect(keys(c))), c_constants_to_nodes)...)
  sort!(common_constants, by=(t -> t[2]))

  # define set of extracted programs
  found_programs = Vector()

  for c in common_constants
    println("constant: ", c)
    node_collections = map(cᵢ -> cᵢ[c], c_constants_to_nodes)

    for nodes in IterTools.product(node_collections...)
      children = map(n -> v_children(n), nodes)
      println("children: ", children)

      #nodes with same symbol but different children count are different operations (unary vs binary -)
      all(length(children[1]) == length(children[i]) for i in eachindex(children)) || continue

      # if the nodes have no children, they must be equal and complete
      if length(children[1]) == 0 
        println("is a constant: ", children)
        found[ids] = [c[1]]
        return [c[1]]
        #push!(found_programs, c[1]) # add constant to extracted programs
      else 
        println("is not a constant: ", children)

        # else, for each child, recursively check if they have representations of that child that are equal
        all_child_programs = Vector() # make an array. for each parameter, store the found programs
        for i in eachindex(children[1])
          println("child: ", i, "of: ", length(children[1]))
          seen_child = copy(seen) # every recursion branch should have its own seen set
          c_childs = map((g,child) -> g[child[i]], gs, children)
          child_programs = eclass_intersect_many(AllTypes, gs, c_childs, seen_child, found) #TODO now I do pass found allong. check
          child_programs !== nothing || break
          push!(all_child_programs, child_programs)
        end

        println("making combinations for: ", children)
        if length(all_child_programs) == length(children[1])
          combinations = collect.(collect(IterTools.product(all_child_programs...)))
          for combination in combinations
            # for each combination of parameters, make the total term and add to found_programs
            if v_iscall(nodes[1])
              p = maketerm(Expr, :call, [c[1]; combination], nothing)
            else
              p = maketerm(Expr, c[1], combination, nothing) #TODO do I need this?
            end
            found[ids] = [p]
            return [p]
            push!(found_programs, p)
          end
        end
      end
      
      if !isempty(found_programs)
        found[ids] = found_programs
      end

    end
    
  end

  if isempty(found_programs)
    found_programs = nothing
  else
    unique!(found_programs) #TODO changes nothing????????
  end
  found[ids] = found_programs
  #println("found programs: ", found_programs)
  return found_programs
end

#eclass_intersect_many([g₁, g₂])


end