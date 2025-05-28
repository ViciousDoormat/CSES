include("../ruler.jl")

using .Ruler
using Test
using Metatheory

#create_rewrite_rule tests

t = Ruler.create_rewrite_rule(:(x),:(x+0),:x)

g = EGraph(:x)
saturate!(g, t)
println(g)

g = EGraph(:(x+0))
saturate!(g, t)
println(g)

t = Ruler.create_rewrite_rule(:(x),:(0),:x)

g = EGraph(:x)
saturate!(g, t)
println(g)

g = EGraph(:(0))
saturate!(g, t)
println(g)

t = Ruler.create_rewrite_rule(:(0),:(x),:x)

g = EGraph(:x)
saturate!(g, t)
println(g)

g = EGraph(:(0))
saturate!(g, t)
println(g)

t = Ruler.create_rewrite_rule(:(0),:(0+0),:x)

g = EGraph(:(0))
saturate!(g, t)
println(g)

g = EGraph(:(0+0))
saturate!(g, t)
println(g)

#CVEC tests

Ruler.variable_cvec = () -> [1]
g = EGraph{Expr, Vector{Int}}(:(2x+1))

@testset "CVEC" begin
    @test g.classes[Metatheory.EGraphs.IdKey(1)].data == [2]
    @test g.classes[Metatheory.EGraphs.IdKey(2)].data == [1]
    @test g.classes[Metatheory.EGraphs.IdKey(3)].data == [2]
    @test g.classes[Metatheory.EGraphs.IdKey(4)].data == [1]
    @test g.classes[Metatheory.EGraphs.IdKey(5)].data == [3]
end

#cvec_match test

C = Ruler.cvec_match(g, :x, Int)
println(C)

#choose_eqs test

R::Vector{Vector{RewriteRule}} = []
R = Ruler.choose_eqs(R, C, :x, Int)
println(R)

#run_rewrites test

Ruler.run_rewrites!(g, reduce(vcat, R))
g


#Ruler final full tests
D::Dict{Int,Vector{Union{Int,Symbol,Expr}}} = Dict([(0, [:(2), :(x), :(1)]),(1, [:(2x)]),(2, [:(2x+1)])])
println(Ruler.ruler(2, D, :x, Int))

D::Dict{Int,Vector{Union{Int,Symbol,Expr}}} = Dict([(0, [:(2), :(x), :(1)]),(1, [:(2x), :(x+2), :(2+x)])])
println(Ruler.ruler(1, D, :x, Int))

Ruler.variable_cvec = () -> [true]

r₁::Vector{RewriteRule} = Ruler.create_rewrite_rule(:(false),:(x && false),:x)
r₂::Vector{RewriteRule} = Ruler.create_rewrite_rule(:(false),:(x ⊻ x),:x) #TODO bug probably. should also be two rules
r₃::Vector{RewriteRule} = Ruler.create_rewrite_rule(:(x && false),:(x ⊻ x),:x)

@testset "shrink" begin 
    @test isempty(Ruler.shrink(reduce(vcat, [r₁, r₂]), [r₃],:x, Bool))
    @test isempty(Ruler.shrink(reduce(vcat, [r₁, r₃]), [r₂],:x, Bool))
    @test isempty(Ruler.shrink(reduce(vcat, [r₂, r₃]), [r₁],:x, Bool))
end

Ruler.variable_cvec = () -> [true]
E::Dict{Int,Vector{Union{Bool,Expr,Symbol}}} = Dict([(0, [:(x), :(false)]),(1, [:(x ⊻ x), :(x && false)])])
println(Ruler.ruler(1, E, :x, Bool))

#TODO test remaining pipeline parts
