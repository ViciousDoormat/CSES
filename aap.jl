using Metatheory
using Metatheory.Library
using Metatheory.EGraphs

abstract type Program end

struct Var <: Program
    name::Symbol
end

struct Neg <: Program
    a::Program
end

struct Const <: Program
    value::Int
end

struct IfElse <: Program
    cond::Bool
    thn::Program
    els::Program
end

function TermInterface.maketerm(::Type{Program}, head, children, metadata = nothing)
  head(children...)
end

Prop = Vector{Expr}

t₁ = @theory a b prop begin
  Var(a) --> IfElse(true, Var(a), Neg(Var(a)))
  Neg(Neg(Var(a))) == Var(a)
  Neg(Const(0)) == Const(0)
  (IfElse(true, a, b), prop::Prop) => :((cond($(prop[1]), a, b), $(prop)))
end

prop::Prop = [:(a ≥ 0)]
program₁ = :(Var(a))

g₁ = EGraph{Expr, Nothing}(:(($program₁, $prop)))
saturate!(g₁, t₁)
println(g₁)

Mem = Dict{Symbol, Program}

t₂ = @theory a b c mem begin
  #(Var(a), mem::Mem) => (mem[a], mem)
  Var(a) == Plus(Var(a), Const(0))
  Plus(a, b) == Plus(b, a)
  Const(0) == Minus(Var(:a), Var(:a))
  Plus(a, Minus(b, c)) == Minus(Plus(a, b), c)
  Plus(a, a) == Times(Const(2), a)
  Minus(Minus(a, b), c) == Plus(a, Minus(Neg(b), c))
  # Neg(b) => -b
  # Plus(a,b) => a + b
  # Minus(a,b) => a - b
end

mem::Mem = Dict(:a => Const(5))
program₂ = :(Var(:a))

g₂ = EGraph{Expr, Nothing}(:(($program₂, $mem)))
saturate!(g₂, t₂)
println(g₂)

#Minus(x, 4) --> Minus(Plus(x, 0), 4) --> Minus(Plus(x, Minus(x, x)), 4) --> Minus(Minus(Plus(x, x), x), 4) --> Minus(Minus(Times(2, x), x), 4)
#x - 4 --> 2x -x -4



t = @theory a b prop begin
  (a, prop::Prop) --> (cond(true, a, -a), prop)
  (cond(true, a, b), prop::Prop) --> (cond(prop[1], a, b), prop)
end

#first problem: i need to use --> instead of => for true to prop[1]
#  just (true, prop::Prop) => (prop[1], prop) works
#  but introducing the cond to the RHS means that it wants to execute it when using =>.
#     first of, it gives cond is not defined in main, which is already a problem
#     secondly, if it would execute the cond, it wouldnt introduce it
#  we would like to use => instead of -->, because otherwise an explicit introduction of a ≥ 0 does not happen
#     instead it makes something like 1 => [Expr[:(a ≥ 0)]]; 2 => [(%5)[%1]]
#  we do need the cond around true. otherwise it isnt guaranteed to be the outermost expression
#     it needs to be the outermost expression because it is rapped in a tupple with prop and thus matches solely on the whole explicit thing
#     and of course it needs to be in the tupple because we require the prop on the LHS
#  I tried putting a $ around the cond, but rewrite rules seem to not allow that
#second problem: For some reason, it goes on for infinity when starting from (:a, prop)
#  TODO find out why 

# prop::Prop = [:(a ≥ 0)]
# program₁ = :(cond(true, a, -a))
# program₂ = :(a)

#println(rewrite(:((true, $prop)), t))

# g = EGraph{Expr, Nothing}(:(($program₂, $prop)))
# saturate!(g, t)
# println(g)




# abstract type fac end

# @matchable struct fact <: fac
#   n::Symbol
# end

# function TermInterface.maketerm(::Type{fac}, head, children, metadata = nothing)
#   head(children...)
# end

# t = @theory a begin
#   fact(a) == a * fact(a-1)
#   fact(0) == 1
# end

# g = EGraph{Expr, Nothing}(fact(:a))
# saturate!(g, t)
# println(g)