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

function solve(examples, grammar, grammar_root, variable, ::Type{AllTypes}, num_solutions=1, up_to_size=3) where {AllTypes}
    println("create termset")
    ungrouped_termset, solutions_per_example = create_termset(examples, grammar, grammar_root, variable, AllTypes, num_solutions, up_to_size)

    #TODO now above uses arg_1, all other stuff must too

    #TODO TEMPORARY; to get beyond creating termset in debugger
    # ungrouped_termset = Set(Union{Int64, Expr, Symbol}[:(3 + 0), :(2 + 3), :(x * 1), :(1 + 2), 0, :(3 * 2), :(0 * 0), :(1 * 1), :(x * 3), :(2 + 2), :x, :(0 + 1), :(2 * 1), :(x + 1), :(1 * 3), :(1 + 0), :(1 * x), :(3 * 0), :(0 + 3), :(1 + x), :(x * 2), :(2 * 3), :(x + 3), :(2 + 0), :(2 + x), :(3 + 1), :(1 * 2), :(x * x), :(0 + 2), :(3 + 3), 1, :(2 * 2), :(x * 0), :(x + 2), :(x + x), :(0 * 1), 3, :(1 * 0), :(3 + 2), :(0 * 3), :(0 + x), :(0 * x), :(0 + 0), :(1 + 1), :(2 * 0), :(x + 0), :(3 * 1), :(2 * x), :(3 + x), 2, :(2 + 1), :(1 + 3), :(0 * 2), :(3 * 3), :(3 * x)])
    # solutions_per_example = Dict{Any, Any}(0 => Any[:(x + 1)], 1 => Any[:(3 * x)])

    grouped_termset,max_operator_count = group_by_operator_count(ungrouped_termset)

    println("termset created\n")
    println("Find rules")

    all_rules = Dict()
    for (n,example) in enumerate(examples)
        i = example[1].in[variable]
    
        println("Find rules for input $i; example $n/$(length(examples))\n")
    
        Ruler.variable_cvec = () -> [i]
        println(Ruler.variable_cvec())
        T,R = ruler(max_operator_count, grouped_termset, variable)
        all_rules[i] = R
    
        println("Found $(length(R)) rules for input $i")
    
    end

    println("Rules found")

    all_graphs::Vector{EGraph{Expr,Nothing}} = []

    for (n,example) in enumerate(examples)
        i = example[1].in[variable]
    
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

    return eclass_intersect_many(AllTypes, all_graphs)
end

end

bvneg_cvc(n::UInt) = -n
bvnot_cvc(n::UInt) = ~n
bvadd_cvc(n1::UInt, n2::UInt) = n1 + n2
bvsub_cvc(n1::UInt, n2::UInt) = n1 - n2
bvxor_cvc(n1::UInt, n2::UInt) = n1 ⊻ n2 #xor
bvand_cvc(n1::UInt, n2::UInt) = n1 & n2
bvor_cvc(n1::UInt, n2::UInt) = n1 | n2
bvshl_cvc(n1::UInt, n2::Int) = n1 << n2
bvlshr_cvc(n1::UInt, n2::Int) = n1 >>> n2
bvashr_cvc(n1::UInt, n2::Int) = n1 >> n2
bvnand_cvc(n1::UInt, n2::UInt) = n1 ⊼ n2 #nand
bvnor_cvc(n1::UInt, n2::UInt) = n1 ⊽ n2 #nor

# CUSTOM functions

ehad_cvc(n::UInt) = bvlshr_cvc(n, 1)
arba_cvc(n::UInt) = bvlshr_cvc(n, 4)
shesh_cvc(n::UInt) = bvlshr_cvc(n, 16)
smol_cvc(n::UInt) = bvshl_cvc(n, 1)
im_cvc(x::UInt, y::UInt, z::UInt) = x == UInt(1) ? y : z
if0_cvc(x::UInt, y::UInt, z::UInt) = x == UInt(0) ? y : z

module Test

using HerbSearch
using HerbGrammar
using HerbSpecification
using HerbConstraints
using HerbCore

using ..Solve

using HerbBenchmarks
using HerbBenchmarks.SyGuS

println("Obtaining problems")
pairs = get_all_problem_grammar_pairs(PBE_BV_Track_2018)
for (i, pair) in enumerate(pairs)
    println("Running problem number $i/$(length(pairs)).")

    g = pair.grammar
    examples = map(example -> [example], pair.problem.spec)
    
    solution = Solve.solve(examples, g, :Start, :_arg_1, Union{UInt, Expr, Symbol}, 1, 2)


    if !isnothing(solution)
        @show "Solution: ", solution
        solved_problems += 1
    end
    break
end

# const grammar = @csgrammar begin
#     Number = |(0:3)
#     Number = x
#     #Number = -Number
#     Number = Number + Number
#     Number = Number * Number
# end

# # Define IO examples
# const examples = [[IOExample(Dict(:x => x), 2x + 1)] for x ∈ 0:1]

# println("Solutions: ", Solve.solve(examples, grammar))

end



# for (i,graph) in enumerate(all_graphs)
#     for (_,class) in graph.classes
#         if class.data[1] == examples[i][1].out
#             push!(eclasses, class)
#             break
#         end
#     end
# end