import Pkg; Pkg.add("TermInterface"); 
using HerbCore, HerbGrammar, HerbSearch
using Metatheory, TermInterface
using Metatheory.EGraphs

TermInterface.istree(::RuleNode) = true

#TermInterface.operation(e::RuleNode) = e.ind #this just results in 5 as return value

println(g.rules[5])

TermInterface.operation(e::RuleNode) = g.rules[e.ind] #is this correct??? but how can i go back from this to the RuleNode
TermInterface.arguments(e::RuleNode) = e.children
TermInterface.metadata(e::RuleNode) = e._val

TermInterface.operation(e::RuleNode) = e.ind

#idk whether this is good
TermInterface.exprhead(::RuleNode) = :call

#what is this?
function TermInterface.similarterm(x::RuleNode, head, args, metadata)
    #RuleNode((head isa Expr) ? 5 : head, metadata, args)
    RuleNode(head, metadata, args)
end

function EGraphs.egraph_reconstruct_expression(::Type{RuleNode}, op, args; metadata=nothing, exprhead=nothing)
    println("op: ", op)
    println("args: ", args)
    #RuleNode((op isa Expr) ? 5 : op, (isnothing(metadata) ? () : metadata), args) 
    RuleNode(op, (isnothing(metadata) ? () : metadata), args) 
end

g = @csgrammar begin
    Number = |(1:2)
    Number = x
    Number = Number + Number
    Number = Number * Number
end

t = @theory begin 
    RuleNode(5, [RuleNode(1), RuleNode(2)]) --> RuleNode(2)
    #1 * 2 --> 2
end

program = RuleNode(5, [RuleNode(1), RuleNode(2)])
println(rulenode2expr(RuleNode(5, [RuleNode(1), RuleNode(2)]), g))

egraph = EGraph(program; keepmeta=true)
settermtype!(egraph, RuleNode)
saturate!(egraph, t)
extract!(egraph, astsize)

rewrite(program, t)

#rewrite(program, t)

# hole = Hole(get_domain(g, g.bytype[:Number]))
# t = @theory a b begin 
#     Number * 1 --> Number
#     Number + 0 --> Number
#     a::Number * b::Number --> (b*a)
#     a::Number + b::Number --> (b+a)
# end