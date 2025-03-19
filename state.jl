using Metatheory, Metatheory.EGraphs
using TermInterface

struct ExprWithContext
    head::Any
    args::Vector{Any}
    context::Int #it is important that I can use this context in a rewrite rule
end
ExprWithContext(head, args) = ExprWithContext(head, args, nothing)
ExprWithContext(head) = ExprWithContext(head, [])

function Base.:(==)(a::ExprWithContext, b::ExprWithContext)
    #TODO Maybe define the equality (needs to be defined according to guide) as being equal when equal modulo context!!!
    a.head == b.head && a.args == b.args && a.context == b.context
end

TermInterface.isexpr(::ExprWithContext) = true
TermInterface.iscall(::ExprWithContext) = true
TermInterface.head(e::ExprWithContext) = e.head
TermInterface.children(e::ExprWithContext) = e.args

#this is true if this defined expression always represents function calls. TODO is that true?
TermInterface.operation(e::ExprWithContext) = head(e)
TermInterface.arguments(e::ExprWithContext) = children(e)

#commented out in example. why?
TermInterface.metadata(e::ExprWithContext) = e.context

TermInterface.maketerm(::Type{ExprWithContext}, h, c, metadata) = ExprWithContext(h, c, metadata)

# expr::ExprWithContext = ExprWithContext(:id, [:x], -5) #call a with -5

# t = @theory a b begin
#     a() --> #TODO to get context, maybe "translate" a() back to the form ExprWithContext(a, b, context) and then extract context
# end

# g = EGraph{ExprWithContext, Nothing}(expr)
# saturate!(g, t)
# println(g)


Mem = Vector{Int}
t = @theory a b c mem begin
    (a::Symbol, mem::Mem) => (mem[1], mem)
    (0, mem::Mem) --> (:a - :a, mem)
    #these should be two directional, but then recursive rewrite rules start to happen??? TODO
    (a - b, mem::Mem) == (a, mem) - (b, mem) #cricial, allows to match on not the outermost expression
    (a + b, mem::Mem) == (b, mem) + (a, mem) #cricial, allows to match on not the outermost expression
    (a, mem::Mem) == (a + 0, mem)
    (a+a, mem::Mem) == (2*a, mem)
    (a-b,mem::Mem) == (a + -b, mem)
    (a+(b-c), mem::Mem) == (a + b - c, mem)
    (a::Int - b::Int, mem::Mem) => (a - b, mem)
    (-a::Int, mem::Mem) => (-a, mem)

    a + 0 == a #if I put this in mem, it will add 0 to everything recursively because its only equal when with a mem TODO this one is ugly
end

#(a-4) --> (a)-(4) --> (a+0)-(4) --> ((a)+(0))-(4) --> ((a)+(a-a))-(4) --> (a+(a-a))-(4) --> (a+a-a)-(4) --> 
#(2a-a)-(4) --> ((2a)-(a))-(4) --> (2a)+(-a-4) --> (2a)+(--5-4) --> (2a)+(5-4) --> (2a)+(1) --> (2a+1)

expr = :(a - 4)
mem::Mem = [-5]
g = EGraph{Expr, Nothing}(:(($expr, $mem)))
saturate!(g, t)
println(g)


# Var(a) --> 5
#     Var(a) == Plus(Var(a), Constant(0))
#     Constant(0) == Minus(Var(:a), Var(:a))
#     Plus(Var(a), Minus(Var(b), Var(c))) == Minus(Plus(Var(a), Var(b)), Var(c))
#     Plus(Var(a), Var(a)) == Times(Constant(2), Var(a))