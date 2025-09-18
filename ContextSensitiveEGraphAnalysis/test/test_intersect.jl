include("../src/intersect.jl")

using Test
using Metatheory

t₁ = @theory a b begin
    a + b == b + a
    a * b == b * a
    a + 0 == a
    # a * 1 == a
    # 1 + 1 == 2
    # 2 + 1 == 3
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

mutable struct CountData
    total::Int          # total number of terms
    seen::UInt64  # eclass IDs that contributed
    graph::EGraph{Expr,CountData}
end



function EGraphs.make(g::EGraph{Expr,CountData}, n::VecExpr)::CountData
    if !v_isexpr(n)
        return CountData(1, g.memo[n], g)
    else
        return CountData(prod(c -> g[c].data.total, v_children(n)), find(g,g.memo[n]), g)
    end
end

function EGraphs.join(a::CountData, b::CountData)::CountData
    if a.seen == b.seen
        return a
    else
        #find out what used a and what used b
        #for something that uses a, divide its total by a and multiply by (a+b)
        #for something that uses b, divide its total by a and multiply by (a+b)
        return (CountData(a.total + b.total, find(a.graph, a.seen), a.graph))
    end
end

g₁ = EGraph{Expr, CountData}()
#g₂ = EGraph{Expr, Set{Int}}()
D = [
     0,:a,:(0+0),:(0*0),:(0*1),:(1*0),:(0*2),:(2*0),:(0*3),:(3*0),
    1,:(1+0),:(0+1),:(1*1),
    2,:(2+0),:(0+2),:(1+1),:(1*2),:(2*1),
    3,:(3+0),:(0+3),:(2+1),:(1+2),:(3*1),:(1*3)
    
]


for term in D
    println("adding term: ", term)
    i = addexpr!(g₁, term)
    # j = addexpr!(g₂, term)
    if term == 1
        g₁.root = i
    end
    # elseif term == 3
    #     g₂.root = j
    # end
end


  
  
saturate!(g₁, t₁)

println(g₁)

# saturate!(g₂, t₂)

for c in g₁.classes
    println(c.second.data)
end

# println(sum(c -> c.second.data, g₁.classes) + sum(c -> c.second.data, g₂.classes))

# println("Intersecting eclasses")
# count = [0]
# println(intersect(Union{Int, Symbol, Expr}, count, [g₁, g₂]))
# println(count[1])