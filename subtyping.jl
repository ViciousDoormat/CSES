using Metatheory
using Metatheory.Library
using Metatheory.EGraphs

abstract type Program end

# struct Neg <: Program
#     a::Program
# end

struct Var <: Program
    name::Symbol
end

struct Constant <: Program
    value::Int
end

struct Plus <: Program
    a::Program
    b::Program
end

struct Minus <: Program
    a::Program
    b::Program
end

struct Times <: Program
    a::Program
    b::Program
end

# struct IfElse <: Program
#     cond::Program
#     thn::Program
#     els::Program
# end

# abstract type Proposition end

# struct Prop <: Proposition
#     expr::Symbol
# end

# abstract type Term end

# struct TermPair <: Term
#     term::Program
#     prop::Proposition
# end

function TermInterface.maketerm(::Type{Program}, head, children, metadata = nothing)
  head(children...)
end

# function TermInterface.maketerm(::Type{Proposition}, head, children, metadata = nothing)
#   head(children...)
# end

# function TermInterface.maketerm(::Type{Term}, head, children, metadata = nothing)
#   head(children...)
# end

t_p = @theory a b c begin
    #(IfElse(a, b, c), prop::Prop) --> (IfElse(prop.expr, b, c), prop) #why doesnt this get recognized
    #(Var(a), prop::Prop) --> (IfElse(true, Var(a), Neg(Var(a))), prop)
    #(Var(a)::Program, prop::Proposition) --> (IfElse(true, Var(a), Neg(Var(a))), prop)
    #(Neg(Neg(a)), prop::Prop) == (a, prop)
    #Term(Var(a), prop::Prop) == Term(IfElse(true, Var(a), Neg(Var(a))), prop)

    
    #Term(IfElse(true, a, b), prop::Prop) --> (IfElse(prop.expr, a, b), prop)
    Var(a) --> 5
    Var(a) == Plus(Var(a), Constant(0))
    Constant(0) == Minus(Var(:a), Var(:a))
    Plus(Var(a), Minus(Var(b), Var(c))) == Minus(Plus(Var(a), Var(b)), Var(c))
    Plus(Var(a), Var(a)) == Times(Constant(2), Var(a))
end

#g_p = EGraph(:(Term(Var(a), Prop(Var(a) ≥ 0))))
g_p = EGraph(:(Minus(Var(a), Constant(4))))
println(g_p)
saturate!(g_p, t_p)
println(g_p)

# t₁ = @theory a b begin
#   true --> :a ≥ 0
#   a --> cond(true, -(-a), -a)
#   -(-a) --> a
#   -(-(-a)) --> -a
# end

# g₁ = EGraph(:(a))
# saturate!(g₁, t₁)
# println(g₁)

# struct Prop
#     expr::Symbol
# end

# prop::Prop = Prop(:a ≥ 0)

#first big thing to understand:
#   the rules needs to be in the form of (program, proposition); they cannot just be program
#      otherwise, the rules, especially variables, can be applied to any expression, and thus also propositions 
#      wherefore we can get stuff like cond(true, prop, -prop), which makes no sense
#note that making it a::Program or something similar does not work because only the outer layer will be Program, while the inside should also be rewritable
#   Thus my first idea: make a grammar and base rewrite rules on ASTs (herb???)!!!!!!!!!!!!!!!
#   The example they give with stuff like (a+b, o::mem) --> (a,o) + (b,o) does work, because there a and b CAN be matched on other expressions
#   That is because they work like ASTs. Thus, if programs can be represented like ASTs, this should be doable
#second big thing to understand:
#    (true, prop::Prop) --> (prop.expr, prop) is a difficult rule to make work, because it will only apply if this is literally the thing on the LHS
#    Because it is a whole tupple structure, this will never occur as part of a program (like `true` would)
#third big thing to understand:
#   for some reason, the (a, prop::Prop) == (cond(true, a, -a), prop) does not apply on EGraph(:((a, Prop(a ≥ 0))))

# t = @theory a prop begin
#     (true, prop::Prop) --> (prop.expr, prop)
#     (a, prop::Prop) == (cond(true, a, -a), prop)
#     (-(-a), prop::Prop) --> (a, prop)
# end


# g = EGraph(:((a, Prop(a ≥ 0))))
# saturate!(g, t)
# println(g)