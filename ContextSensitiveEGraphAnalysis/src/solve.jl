using Metatheory
using Metatheory.Library
using Metatheory.EGraphs

using HerbSearch
using HerbGrammar
using HerbSpecification
using HerbConstraints
using HerbCore

using IterTools

function solve(examples, grammar, grammar_root, variable, ::Type{AllTypes}, ::Type{CVec}, num_solutions=1, up_to_size=3) where {AllTypes, CVec}
    println("create termset")
    ungrouped_termset, solutions_per_example = create_termset(examples, grammar, grammar_root, variable, AllTypes, num_solutions, up_to_size)
    println(solutions_per_example)
    #TODO TEMPORARY; to get beyond creating termset in debugger
    # ungrouped_termset = Set(Union{Int64, Expr, Symbol}[:(3 + 0), :(2 + 3), :(x * 1), :(1 + 2), 0, :(3 * 2), :(0 * 0), :(1 * 1), :(x * 3), :(2 + 2), :x, :(0 + 1), :(2 * 1), :(x + 1), :(1 * 3), :(1 + 0), :(1 * x), :(3 * 0), :(0 + 3), :(1 + x), :(x * 2), :(2 * 3), :(x + 3), :(2 + 0), :(2 + x), :(3 + 1), :(1 * 2), :(x * x), :(0 + 2), :(3 + 3), 1, :(2 * 2), :(x * 0), :(x + 2), :(x + x), :(0 * 1), 3, :(1 * 0), :(3 + 2), :(0 * 3), :(0 + x), :(0 * x), :(0 + 0), :(1 + 1), :(2 * 0), :(x + 0), :(3 * 1), :(2 * x), :(3 + x), 2, :(2 + 1), :(1 + 3), :(0 * 2), :(3 * 3), :(3 * x)])
    # solutions_per_example = Dict{Any, Any}(0 => Any[:(x + 1)], 1 => Any[:(3 * x)])

    grouped_termset,max_operator_count = group_by_operator_count(ungrouped_termset)

    println(grouped_termset)

    println("termset created\n")
    println("Find rules")

    all_rules = Dict()
    for (n,example) in enumerate(examples)
        i = example[1].in[variable]
    
        println("Find rules for input $i; example $n/$(length(examples))\n")
    
        Ruler.variable_cvec = () -> [i]
        println(Ruler.variable_cvec())
        T,R = ruler(max_operator_count, grouped_termset, variable, CVec)
        R = reduce(vcat, R)
        all_rules[i] = R
    
        println("Found $(length(R)) rules for input $i")
        println(R)
    end
    println("Rules found")

    all_graphs::Vector{EGraph{Expr,Nothing}} = []

    for (n,example) in enumerate(examples)
        i::CVec = example[1].in[variable]
    
        println("Find solutions for input $i; example $n/$(length(examples))\n")
    
        solutions = solutions_per_example[i]
        G = EGraph{Expr,Nothing}()
        for term in solutions
            G.root = addexpr!(G, term)
        end
        @invokelatest saturate!(G,all_rules[i])
        push!(all_graphs, G)
    
        println("Found soltutions for input $i")
    
    end

    println("Solutions found")

    #TODO it finally terminates, but it doesnt find it even though 2x+1 is represented by both
    #to find 2x+1:
        #1: intersect(2,1) intersects %1+%2 with %11+%2
            #2: intersect(1,11) intersects %13*%1 with %11*%2
                    #the moment you intersect 1 and 11 it has already done so and found nothing
                    #probably because of the order
                #3: intersect(13,11) finds 2
                #4: intersect(1,2) finds x
            #so we find 2*x
            #5: intersect(2,2) finds 1
        #so we find 2x+1

    println("Intersect solutions")

    return intersect(AllTypes, all_graphs)
end
