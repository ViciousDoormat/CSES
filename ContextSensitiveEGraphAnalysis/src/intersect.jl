
using Metatheory
using Metatheory.Library
using Metatheory.EGraphs
using IterTools

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

function intersect(::Type{AllTypes}, gs::Vector{<:EGraph}, cs::Vector{<:EClass}=map(g -> g[g.root], gs), seen=Set{Vector{Id}}(), found=Dict{Vector{Id},Union{AllTypes,Nothing}}()) where {AllTypes}
  
  ids = map(c -> c.id, cs)
  
  # if the eclasses have already been intersected, return the result (improves efficiency)
  haskey(found, ids) && (return found[ids])
  # if the considered eclasses have already been seen together for this operator, we found a cycle and return nothing
  in(ids, seen) && (return nothing)
    
  push!(seen, ids)

  println("finding common: ", ids)
  c_constants_to_nodes = map((g,c) -> get_eclass_constants(g, c, AllTypes), gs, cs)
  common_constants = Base.intersect(map(c -> Vector{Tuple{AllTypes,Int}}(collect(keys(c))), c_constants_to_nodes)...)
  sort!(common_constants, by=(t -> t[2]))
  
  #before finding common constants, remove all classes that are :any
  #if length(cs) becomes 0, return :any

  for c in common_constants
    println("constant: ", c)
    node_collections = map(cᵢ -> cᵢ[c], c_constants_to_nodes)

    for nodes in IterTools.product(node_collections...)
      children = map(n -> v_children(n), nodes)
      println("children: ", children)

      # if the nodes have no children, they must be equal and complete
      if length(children[1]) == 0 
        println("is a constant: ", children)
        found[ids] = c[1]
        return c[1]
      else 
        println("is not a constant: ", children)

        # else, for each child, recursively check if they have representations of that child that are equal
        all_child_programs = Vector() # make an array. for each parameter, store the found program
        for i in eachindex(children[1])
          println("child: ", i, "of: ", length(children[1]))
          seen_child = copy(seen) # every recursion branch should have its own seen set
          c_childs = map((g,child) -> g[child[i]], gs, children)
          child_program = intersect(AllTypes, gs, c_childs, seen_child, found) #TODO now I do pass found allong. check
          child_program !== nothing || break
          push!(all_child_programs, child_program)
        end

        println("making combinations for: ", children)
        if length(all_child_programs) == length(children[1])
          if v_iscall(nodes[1])
            p = maketerm(Expr, :call, [c[1]; all_child_programs], nothing)
          else
            p = maketerm(Expr, c[1], all_child_programs, nothing) #TODO do I need this?
          end
          found[ids] = p
          return p
        end
      end
    end
  end

  found[ids] = nothing
  return nothing
end