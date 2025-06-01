using ContextSensitiveEGraphAnalysis

using HerbBenchmarks
using HerbBenchmarks.SyGuS

# CVC5 functions

## String typed
concat_cvc(str1::String, str2::String) = str1 * str2
replace_cvc(mainstr::String, to_replace::String, replace_with::String) = replace(mainstr, to_replace => replace_with)
at_cvc(str::String, index) = string(str[Int(index)])
int_to_str_cvc(n) = "$(Int(n))"
substr_cvc(str::String, start_index, end_index) = str[Int(start_index):Int(end_index)]

# Int typed
len_cvc(str::String) = length(str)
str_to_int_cvc(str::String) = parse(Int64, str)
indexof_cvc(str::String, substring::String, index) = (n = findfirst(substring, str); n == nothing ? -1 : (n[1] >= Int(index) ? n[1] : -1))

# Bool typed
prefixof_cvc(prefix::String, str::String) = startswith(str, prefix)
suffixof_cvc(suffix::String, str::String) = endswith(str, suffix)
contains_cvc(str::String, contained::String) = contains(str, contained)
lt_cvc(str1::String, str2::String) = cmp(str1, str2) < 0
leq_cvc(str1::String, str2::String) = cmp(str1, str2) <= 0
isdigit_cvc(str::String) = tryparse(Int, str) !== nothing

#19274448, 17212077, 35744094, phone_6_short (also 7/8)

pair = get_problem_grammar_pair(PBE_SLIA_Track_2019, "12948338") 

g = pair.grammar
examples = map(example -> [example], pair.problem.spec)
    
solution = solve(examples, g, :Start, [:_arg_1,:_arg_2], Union{String, Int, Bool, Expr, Symbol}, Union{String, Int, Bool}, 3, 3)
println(solution)

#println("Obtaining problems")
#pairs = get_all_problem_grammar_pairs(PBE_SLIA_Track_2019)

# for (i, pair) in enumerate(pairs)
#     println("Running problem number $i/$(length(pairs)).")

#     g = pair.grammar
#     examples = map(example -> [example], pair.problem.spec)
    
#     solution = solve(examples, g, :Start, :_arg_1, Union{String, Int, Bool, Expr, Symbol}, Union{String, Int, Bool}, 1, 3)


#     if !isnothing(solution)
#         @show "Solution: ", solution
#         solved_problems += 1
#     end
#     break
# end


#problems:

#problem 1:
#I think it puts 0 and false, 1 and true in the same eclass and extracts the wrong one. 
# ERROR: MethodError: no method matching int_to_str_cvc(::Bool)
# The function `int_to_str_cvc` exists, but no method is defined for this combination of argument types.
# Closest candidates are:
#   int_to_str_cvc(::Int64)
#    @ ContextSensitiveEGraphAnalysis C:\Users\matte\Documents\thesis\ContextSensitiveEGraphAnalysis\src\helper_functions.jl:138
# Stacktrace:
#  [1] top-level scope
#    @ none:1
#Useless stacktrace

#problem 2:
#It takes considerable time to generate singular functions for this

#problem 3:
#Singular functions are useless: contains(arg1, arg1) and need to be rewritten to something useful
#TODO find out exactly what goes wrong in this one

#TODO booleans inserten, grammar zonder boolean, arg2 adden