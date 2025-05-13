module Solve

export solve

using Metatheory
using Metatheory.Library
using Metatheory.EGraphs

using HerbSearch
using HerbGrammar
using HerbSpecification
using HerbConstraints
using HerbCore

using IterTools

include("helper_functions.jl")
using .Helper

include("termset.jl")
using .Termset

include("intersect.jl")
using .Intersect

include("ruler.jl")
using .Ruler

using Infiltrator

#TODO test the rewrite rules with a::Symbol and write tests

function solve(examples, grammar)
    ungrouped_termset, solutions_per_example = create_termset(examples, grammar)
    grouped_termset,max_operator_count = group_by_operator_count(ungrouped_termset)

    all_rules = Dict()
    for example in examples
        i = example[1].in[:x]
    
        println("Find rules for input $i")
    
        Ruler.variable_cvec = () -> [i]
        println(Ruler.variable_cvec())
        T,R = ruler(max_operator_count, grouped_termset, Expr)
        all_rules[i] = R
    
        println("Found $(length(R)) rules for input $i")
    
    end

    all_graphs::Vector{EGraph{Expr,Nothing}} = []

    for example in examples
        i = example[1].in[:x]
    
        println("Find solutions for input $i")
    
        solutions = solutions_per_example[i]
        G = EGraph{Expr,Nothing}()
        for term in solutions
            G.root = addexpr!(G, term)
        end
        saturate!(G,all_rules[i])
        push!(all_graphs, G)
    
        println("Found soltutions for input $i")
    
    end

    eclasses::Vector{EClass{Nothing}} = []

    for graph in all_graphs
        println("Graph: $graph")
    end

    return eclass_intersect_many(all_graphs)
end

end

module Test

using HerbSearch
using HerbGrammar
using HerbSpecification
using HerbConstraints
using HerbCore

using ..Solve

const grammar = @csgrammar begin
    Number = |(0:4)
    Number = x
    Number = -Number
    Number = Number + Number
    Number = Number * Number
end

# Define IO examples
const examples = [[IOExample(Dict(:x => x), 2x + 1)] for x ∈ 0:3]

println("Solutions: ", Solve.solve(examples, grammar))

end

# for (i,graph) in enumerate(all_graphs)
#     for (_,class) in graph.classes
#         if class.data[1] == examples[i][1].out
#             push!(eclasses, class)
#             break
#         end
#     end
# end