using ContextSensitiveEGraphAnalysis

include("../src/ruler/ruler.jl")


using .Ruler
using Test
using Metatheory

Ruler.variable_cvec = (_) -> [1]
Ruler.interpret_function = eval
T = EGraph{Expr,Vector{Int}}(:(a+0))
rules::Vector{RewriteRule} = [@rule x x+0 == x]

Ruler.run_rewrites!(T, rules)

#create_rewrite_rule tests

# t::Vector{RewriteRule} = [Ruler.create_rewrite_rule(:(x),:(x+0),[:x])]

# g = EGraph(:x)
# saturate!(g, t)
# println(g)

# g = EGraph(:(x+0))
# saturate!(g, t)
# println(g)

# t = [Ruler.create_rewrite_rule(:(x),:(0),[:x])]

# g = EGraph(:x)
# saturate!(g, t)
# println(g)

# g = EGraph(:(0))
# saturate!(g, t)
# println(g)

# t = [Ruler.create_rewrite_rule(:(0),:(x),[:x])]

# g = EGraph(:x)
# saturate!(g, t)
# println(g)

# g = EGraph(:(0))
# saturate!(g, t)
# println(g)

# t = [Ruler.create_rewrite_rule(:(0),:(0+0),[:x])]

# g = EGraph(:(0))
# saturate!(g, t)
# println(g)

# g = EGraph(:(0+0))
# saturate!(g, t)
# println(g)

# #CVEC tests

# Ruler.variable_cvec = (_) -> [1]
# Ruler.interpret_function = eval
# g = EGraph{Expr, Vector{Int}}(:(2x+1))
# println(Ruler.cvec_to_classes)

# @testset "CVEC" begin
#     @test g.classes[Metatheory.EGraphs.IdKey(1)].data == [2]
#     @test g.classes[Metatheory.EGraphs.IdKey(2)].data == [1]
#     @test g.classes[Metatheory.EGraphs.IdKey(3)].data == [2]
#     @test g.classes[Metatheory.EGraphs.IdKey(4)].data == [1]
#     @test g.classes[Metatheory.EGraphs.IdKey(5)].data == [3]
# end

# # #cvec_match test

# C = Ruler.cvec_match(g, [:x], Int)
# println(C)

# # #choose_eqs test

# R::Vector{RewriteRule} = []
# R = Ruler.choose_eqs(R, C, [:x], Int)
# println(R)

# #run_rewrites test

# Ruler.run_rewrites!(g, R)
# println(g)

# Ruler.cvec_to_classes = Dict()

# #Ruler final full tests
# D::Dict{Int,Vector{Union{Int,Symbol,Expr}}} = Dict([(0, [:(2), :(x), :(1)]),(1, [:(2*x)]),(2, [:((2*x)+1)])])
# println(Ruler.ruler(2, D, [:x], Int))

# D::Dict{Int,Vector{Union{Int,Symbol,Expr}}} = Dict([(0, [:(2), :(x), :(1)]),(1, [:(2*x), :(x+2), :(2+x)])])
# println(Ruler.ruler(1, D, [:x], Int))

# Ruler.variable_cvec = (_) -> [true]

# r₁::Vector{RewriteRule} = [Ruler.create_rewrite_rule(:(false),:(x && false),[:x])]
# r₂::Vector{RewriteRule} = [Ruler.create_rewrite_rule(:(false),:(x ⊻ x),[:x])]
# r₃::Vector{RewriteRule} = [Ruler.create_rewrite_rule(:(x && false),:(x ⊻ x),[:x])]

# @testset "shrink" begin 
#     @test isempty(Ruler.shrink(reduce(vcat, [r₁, r₂]), r₃, [:x], Bool))
#     @test isempty(Ruler.shrink(reduce(vcat, [r₁, r₃]), r₂, [:x], Bool))
#     @test isempty(Ruler.shrink(reduce(vcat, [r₂, r₃]), r₁, [:x], Bool))
# end

# Ruler.variable_cvec = (_) -> [true]
# E::Dict{Int,Vector{Union{Bool,Expr,Symbol}}} = Dict([(0, [:(x), :(false)]),(1, [:(x ⊻ x), :(x && false)])])
# println(Ruler.ruler(1, E, [:x], Bool))

# #TODO test remaining pipeline parts

# Ruler.variable_cvec = (var) -> var == :x ? [true] : (var == :y ? [false] : error("wtf gvd"))
# E::Dict{Int,Vector{Union{Bool,Expr,Symbol}}} = Dict([(0, [:(x), :(y), :(false)]),(1, [:(x ⊻ x), :(x && false), :(x ⊻ y), :(y ⊻ x)])])
# println(Ruler.ruler(1, E, [:x,:y], Bool))

# r₁::Vector{RewriteRule} = Ruler.create_rewrite_rule(:(false),:(y),[:x,:y])
# r₂₃::Vector{RewriteRule} = Ruler.create_rewrite_rule(:(x ⊻ false),:(false ⊻ x),[:x,:y])
# r₄₅::Vector{RewriteRule} = Ruler.create_rewrite_rule(:(x ⊻ x),:(false && false),[:x,:y])
# r₆::Vector{RewriteRule} = Ruler.create_rewrite_rule(:(false),:(x ⊻ x),[:x,:y])
# r₇::Vector{RewriteRule} = Ruler.create_rewrite_rule(:(false),:(x ⊻ x),[:x,:y])
# r₈₉::Vector{RewriteRule} = Ruler.create_rewrite_rule(:(x),:(x ⊻ false),[:x,:y])
# # R::Vector{RewriteRule} = reduce(vcat, [r₁,r₈₉])
# r₈ = [r₈₉[1]]
# R::Vector{RewriteRule} = [r₁[1],r₈[1]]
# Ruler.variable_cvec = (var) -> var == :x ? [true] : (var == :y ? [false] : error("wtf gvd"))
# g = EGraph{Expr, Vector{Bool}}(:(x ⊻ false))
# saturate!(g,R)
# # false == :y, x::Symbol --> :x ⊻ false



# THIS WORKS!!!!!!!!!!!!
# This does require a method to find all unique variables in order to make
# if x == :x && y == :y ... then <rewritten> else <original>
# Ruler.variable_cvec = (var) -> var == :x ? [true] : (var == :y ? [false] : error("wtf gvd"))
# r::Vector{RewriteRule} = [@slots x @rule x::Symbol => x == :x ? :(x ⊻ false) : x]
# g = EGraph{Expr,Vector{Bool}}(:x)
# saturate!(g, r)
# println(g)
# g = EGraph{Expr,Vector{Bool}}(:y)
# saturate!(g, r)
# println(g)

# lhs = :($(QuoteNode(:x)))
# rhs = :($(QuoteNode(:y)))
# r::Vector{RewriteRule} = [eval(:(@rule $lhs --> $rhs))]
# Ruler.variable_cvec = (var) -> var == :x ? [true] : (var == :y ? [true] : error("wtf gvd"))
# g = EGraph{Expr,Vector{Bool}}(:x)
# saturate!(g, r)
# println(g)
# g = EGraph{Expr,Vector{Bool}}(:y)
# saturate!(g, r)
# println(g)


# r₁ = @slots x @rule x == x+0
# r₂ = @slots x @rule x == x+0

# l = [r₁,r₂]
# unique(r -> [r.lhs_original, r.rhs_original], l)