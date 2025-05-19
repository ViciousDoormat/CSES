using Metatheory
using Metatheory.Library
using Metatheory.EGraphs

using HerbSearch
using HerbGrammar
using HerbSpecification
using HerbConstraints
using HerbCore

include("intersect.jl")
using .Intersect

t₁ = @theory a b begin
    a + b == b + a
    a * b == b * a
    a + 0 == a
    a * 1 == a
    1 + 1 == 2
    2 + 1 == 3
    a::Symbol --> 0
end

t₂ = @theory a b begin
    a + b == b + a
    a * b == b * a
    a + 0 == a
    a * 1 == a
    1 + 1 == 2
    2 + 1 == 3
    a::Symbol --> 1
end

g₁ = EGraph{Expr, Nothing}()
g₂ = EGraph{Expr, Nothing}()
D = [
    0,:a,:(0+0),:(0*0),:(0*1),:(1*0),:(0*2),:(2*0),:(0*3),:(3*0),
    1,:(1+0),:(0+1),:(1*1),
    2,:(2+0),:(0+2),:(1+1),:(1*2),:(2*1),
    3,:(3+0),:(0+3),:(2+1),:(1+2),:(3*1),:(1*3)
    
]


for term in D
    i = addexpr!(g₁, term)
    j = addexpr!(g₂, term)
    if term == 0
        g₁.root = i
    elseif term == 1
        g₂.root = j
    end
    println("added $term")
end
  
  
saturate!(g₁, t₁)
saturate!(g₂, t₂)
  
println(g₁)
println(g₂)

println("Intersecting eclasses")
eclass_intersect_many([g₁, g₂])

