using ContextSensitiveEGraphAnalysis

using HerbBenchmarks
using HerbBenchmarks.SyGuS

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


println("Obtaining problems")
pairs = get_all_problem_grammar_pairs(PBE_BV_Track_2018)
for (i, pair) in enumerate(pairs)
    println("Running problem number $i/$(length(pairs)).")

    g = pair.grammar
    examples = map(example -> [example], pair.problem.spec)
    
    solution = solve(examples, g, :Start, :_arg_1, Union{UInt, Expr, Symbol}, UInt, 1, 3)


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




# for (i,graph) in enumerate(all_graphs)
#     for (_,class) in graph.classes
#         if class.data[1] == examples[i][1].out
#             push!(eclasses, class)
#             break
#         end
#     end
# end