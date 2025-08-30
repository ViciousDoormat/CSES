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

function solve(examples, grammar, grammar_root, variables, ::Type{AllTypes}, ::Type{CVec}, constraints, constraints_dumb, io, ioruler, with_solutions, num_solutions=1, up_to_size=3, R::Vector{RewriteRule} = Vector{RewriteRule}(), interpret_function=interpret_sygus) where {AllTypes, CVec}
    println("create termset")
    
    ungrouped_termset, solutions_per_example = create_termset(examples, grammar, grammar_root, variables, AllTypes, constraints, constraints_dumb, with_solutions, num_solutions, up_to_size)
    #ungrouped_termset = Set(Union{Bool, Int64, Expr, String, Symbol}[:_arg_1])
    
    grouped_termset,counts = group_by_operator_count(ungrouped_termset)
    
    iokaas = open("kaas.txt", "w")  
    println(iokaas, ungrouped_termset)
    close(iokaas)

    # counts = [0,1]
#     grouped_termset = Dict{Int64, Vector{Union{Bool, Int64, Expr, String, Symbol}}}(0 => [:_arg_1, "smith,bobby", " ", false, ",", -1, "bobby,smith", "aaron,lennox", "lennox,aaron", true, "chang,amy", "amy,chang", ""], 1 => [:(replace_cvc(_arg_1, _arg_1, ",")), :(if true
#     ""
# else
#     ","
# end), :(int_to_str_cvc(0)), :(if true
#     0
# else
#     -1
# end), :(concat_cvc(_arg_1, _arg_1)), :(int_to_str_cvc(-1)), :(if false
#     0
# else
#     1
# end), :(suffixof_cvc(_arg_1, _arg_1)), :(concat_cvc("", ",")), :(concat_cvc(",", " ")), :(if false
#     1
# else
#     0
# end), :(suffixof_cvc(" ", _arg_1)), :(if false
#     1
# else
#     -1
# end), :(prefixof_cvc(_arg_1, _arg_1)), :(concat_cvc(",", "")), :(at_cvc(",", 1)), :(replace_cvc(_arg_1, "", ",")), :(substr_cvc(_arg_1, 1, 0)), :(if true
#     _arg_1
# else
#     ","
# end), :(concat_cvc("", "")), :(concat_cvc(",", _arg_1)), :(substr_cvc(_arg_1, 1, -1)), :(replace_cvc(_arg_1, "", "")), :(if true
#     -1
# else
#     1
# end), :(prefixof_cvc("", _arg_1)), :(if false
#     ""
# else
#     ""
# end), :(if true
#     0
# else
#     1
# end), :(replace_cvc(_arg_1, " ", "")), :(-1 == 0), :(if false
#     _arg_1
# else
#     ""
# end), :(-1 == -1), :(indexof_cvc(_arg_1, ",", 0)), :(if true
#     " "
# else
#     " "
# end), :(concat_cvc("", " ")), :(if true
#     1
# else
#     0
# end), :(if true
#     1
# else
#     -1
# end), :(indexof_cvc(_arg_1, ",", -1)), :(int_to_str_cvc(1)), :(if true
#     ","
# else
#     " "
# end), :(0 == -1), :(0 == 0), :(concat_cvc(_arg_1, "")), :(if false
#     1
# else
#     1
# end), :(at_cvc(" ", 1)), :(-1 - 0), :(replace_cvc(_arg_1, " ", _arg_1)), :(if false
#     ","
# else
#     ""
# end), :(-1 - -1), :(concat_cvc(_arg_1, " ")), :(-1 + 0), :(replace_cvc(_arg_1, _arg_1, _arg_1)), :(if false
#     ","
# else
#     ","
# end), :(-1 + -1), :(if true
#     ""
# else
#     _arg_1
# end), :(indexof_cvc(_arg_1, " ", 0)), :(0 - 0), :(if false
#     " "
# else
#     _arg_1
# end), :(indexof_cvc(_arg_1, " ", -1)), :(if false
#     " "
# else
#     ""
# end), :(0 - -1), :(replace_cvc(_arg_1, _arg_1, "")), :(substr_cvc(_arg_1, 1, 1)), :(prefixof_cvc(" ", _arg_1)), :(0 + 0), :(0 + -1), :(replace_cvc(_arg_1, " ", " ")), :(if true
#     " "
# else
#     ","
# end), :(-1 == 1), :(if true
#     _arg_1
# else
#     " "
# end), :(if false
#     " "
# else
#     ","
# end), :(if true
#     1
# else
#     1
# end), :(indexof_cvc(_arg_1, ",", 1)), :(if false
#     ","
# else
#     _arg_1
# end), :(0 == 1), :(indexof_cvc(_arg_1, _arg_1, 0)), :(indexof_cvc(_arg_1, _arg_1, -1)), :(1 == 0), :(concat_cvc(",", ",")), :(1 == -1), :(if false
#     _arg_1
# else
#     " "
# end), :(if false
#     ""
# else
#     ","
# end), :(-1 - 1), :(replace_cvc(_arg_1, ",", " ")), :(-1 + 1), :(indexof_cvc(_arg_1, " ", 1)), :(0 - 1), :(if true
#     _arg_1
# else
#     ""
# end), :(0 + 1), :(suffixof_cvc(",", _arg_1)), :(concat_cvc(" ", ",")), :(1 - 0), :(if true
#     ","
# else
#     _arg_1
# end), :(if true
#     " "
# else
#     ""
# end), :(1 + 0), :(1 - -1), :(if false
#     " "
# else
#     " "
# end), :(1 + -1), :(if true
#     _arg_1
# else
#     _arg_1
# end), :(concat_cvc(_arg_1, ",")), :(len_cvc(_arg_1)), :(if true
#     ""
# else
#     ""
# end), :(if false
#     ","
# else
#     " "
# end), :(if true
#     ""
# else
#     " "
# end), :(indexof_cvc(_arg_1, _arg_1, 1)), :(if false
#     -1
# else
#     0
# end), :(if false
#     -1
# else
#     -1
# end), :(suffixof_cvc("", _arg_1)), :(if false
#     _arg_1
# else
#     _arg_1
# end), :(1 == 1), :(concat_cvc(" ", _arg_1)), :(if false
#     0
# else
#     0
# end), :(if true
#     ","
# else
#     ""
# end), :(if false
#     0
# else
#     -1
# end), :(replace_cvc(_arg_1, "", _arg_1)), :(contains_cvc(_arg_1, " ")), :(if false
#     ""
# else
#     " "
# end), :(contains_cvc(_arg_1, _arg_1)), :(replace_cvc(_arg_1, _arg_1, " ")), :(concat_cvc(" ", " ")), :(if false
#     ""
# else
#     _arg_1
# end), :(substr_cvc(_arg_1, 0, -1)), :(1 - 1), :(replace_cvc(_arg_1, ",", _arg_1)), :(replace_cvc(_arg_1, ",", "")), :(1 + 1), :(prefixof_cvc(",", _arg_1)), :(if false
#     _arg_1
# else
#     ","
# end), :(at_cvc(_arg_1, 1)), :(replace_cvc(_arg_1, ",", ",")), :(contains_cvc(_arg_1, "")), :(if true
#     -1
# else
#     0
# end), :(concat_cvc(" ", "")), :(if true
#     -1
# else
#     -1
# end), :(replace_cvc(_arg_1, " ", ",")), :(if true
#     " "
# else
#     _arg_1
# end), :(if true
#     0
# else
#     0
# end), :(concat_cvc("", _arg_1)), :(contains_cvc(_arg_1, ",")), :(if false
#     -1
# else
#     1
# end), :(replace_cvc(_arg_1, "", " ")), :(if true
#     ","
# else
#     ","
# end)])

    #println("termset created\n")
    println("Find rules")

    starttime = time()

    Ruler.interpret_function = interpret_function
    all_rules = Dict()
    for (n,example) in enumerate(examples)
        var_to_value = example[1].in
        #i = example[1].in[variable]
        println(ioruler, "example $n")
    
        println("Find rules for inputs $var_to_value; example $n/$(length(examples))\n")
    
        Ruler.variable_cvec = (var::Symbol) -> [var_to_value[var]]
        Ruler.cvec_to_classes = Dict()
        #println(Ruler.variable_cvec())
        result = ruler(counts, grouped_termset, variables, CVec, starttime, ioruler, deepcopy(R))
        if result === nothing
            return (nothing, -1, -1)
        end
        T,rules = result
        all_rules[n] = rules
    
        println("Found $(length(rules)) rules for input $var_to_value")
        #println(rules)
    end
    println("Rules found")

    return (nothing, 1, 1)

    all_graphs::Vector{EGraph{Expr,CountData}} = []
    iosolutions = open("solutions.txt", "w")  


    for (n,example) in enumerate(examples)
        var_to_value = example[1].in
        #i = example[1].in[variable]
    
        println("Find solutions for input $var_to_value; example $n/$(length(examples))\n")
    
        solutions = solutions_per_example[n]
        G = EGraph{Expr,CountData}()
        for term in solutions
            G.root = addexpr!(G, term)
        end
        @invokelatest saturate!(G,all_rules[n],SaturationParams(eclasslimit=20))
        push!(all_graphs, G)
    
        println("Found soltutions for input $var_to_value")
        println(iosolutions, G)
    
    end

    close(iosolutions) 
    

    println("Solutions found")

    println("Intersect solutions")

    count = [0]
    result = intersect(AllTypes, count, all_graphs)
    return (result, count[1], sum(g -> sum(c -> c.second.data.total, g.classes), all_graphs))
end
