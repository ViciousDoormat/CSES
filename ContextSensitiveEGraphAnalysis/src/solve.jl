using Metatheory
using Metatheory.Library
using Metatheory.EGraphs

using HerbSearch
using HerbGrammar
using HerbSpecification
using HerbConstraints
using HerbCore

using IterTools

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

function solve(examples, grammar, grammar_root, variables, ::Type{AllTypes}, ::Type{CVec}, constraints, constraints_dumb, io, ioruler, with_solutions, num_solutions=1, up_to_size=3, R::Vector{RewriteRule} = Vector{RewriteRule}(), use_new_select=false, interpret_function=interpret_sygus) where {AllTypes, CVec}
    println("create termset")
    
    ungrouped_termset, solutions_per_example = create_termset(examples, grammar, grammar_root, variables, AllTypes, constraints, constraints_dumb, with_solutions, num_solutions, up_to_size)
    #ungrouped_termset = Set(Union{Bool, Int64, Expr, String, Symbol}[:_arg_1])
    
    grouped_termset,counts = group_by_operator_count(ungrouped_termset)

    #println("termset created\n")
    println("Find rules")

    Ruler.interpret_function = interpret_function
    Ruler.use_new_select = use_new_select
    all_rules = Dict()
    rulertime = time()
    for (n,example) in enumerate(examples)
        var_to_value = example[1].in
        #i = example[1].in[variable]
        println(ioruler, "example $n")
    
        println("Find rules for inputs $var_to_value; example $n/$(length(examples))\n")
    
        Ruler.variable_cvec = (var::Symbol) -> [var_to_value[var]]
        Ruler.cvec_to_classes = Dict()
        #println(Ruler.variable_cvec())
        result = ruler(counts, grouped_termset, variables, CVec, rulertime, ioruler, deepcopy(R))
        if result === nothing
            return (nothing, -1, -1, rulertime)
        end
        T,rules = result
        all_rules[n] = rules
    
        println("Found $(length(rules)) rules for input $var_to_value")
        #println(rules)
    end
    rulertime = time() - rulertime
    println("Rules found")

    #return (nothing, 1, 1, rulertime) #TODO for one of these remove

    all_graphs::Vector{EGraph{Expr,CountData}} = []
    #iosolutions = open("solutions.txt", "w")  

    
    for (n,example) in enumerate(examples)
        var_to_value = example[1].in
        #i = example[1].in[variable]
    
        println("Find solutions for input $var_to_value; example $n/$(length(examples))\n")
    
        solutions = solutions_per_example[n]
        G = EGraph{Expr,CountData}()
        for term in solutions
            G.root = addexpr!(G, term)
        end
        @invokelatest saturate!(G,all_rules[n],SaturationParams(eclasslimit=15))
        push!(all_graphs, G)
    
        println("Found soltutions for input $var_to_value")
        #println(iosolutions, G)
    
    end

    #close(iosolutions) 
    

    println("Solutions found")

    println("Intersect solutions")

    count = [0]
    result = nothing
    try
        result = intersect(AllTypes, count, all_graphs)
    catch 
        return (result, count[1], -1, rulertime)
    end
    return (result, count[1], sum(g -> sum(c -> c.second.data.total, g.classes), all_graphs), rulertime)
end
