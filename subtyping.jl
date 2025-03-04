using Metatheory
using Metatheory.Library
using Metatheory.EGraphs

abstract type Program end

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

struct Neg <: Program
    a::Program
end

struct Var <: Program
    name::Symbol
end

struct Constant <: Program
    value::Int
end

struct IfElse <: Program
    cond::Program
    thn::Program
    els::Program
end

struct And <: Program
    a::Program
    b::Program
end

struct Or <: Program
    a::Program
    b::Program
end

struct Not <: Program
    a::Program
end

struct Prop
    expr::Symbol
end

struct Program_with_Context
    program::Program
    context::Prop
end

t_p = @theory a b c prop begin
    (IfElse(a, b, c), prop::Prop) --> (IfElse(prop.expr, b, c), prop) #why doesnt this get recognized
    (Var(a), prop::Prop) --> (IfElse(true, Var(a), Neg(Var(a))), prop)
    Neg(Neg(a)) --> a
end

g_p = EGraph(:((Var(a), Prop(Var(a) ≥ 0))))
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