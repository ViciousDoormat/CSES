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

pair = get_problem_grammar_pair(PBE_SLIA_Track_2019, "convert_text_to_numbers") 

g = pair.grammar
add_constraints_convert_numbers_to_text!(g)
examples = map(example -> [example], pair.problem.spec)
    
solution = solve(examples, g, :Start, [:_arg_1], Union{String, Int, Bool, Expr, Symbol}, Union{String, Int, Bool}, 1, 3)
println(solution)
