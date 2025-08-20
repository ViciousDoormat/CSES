#using ContextSensitiveEGraphAnalysis
include("../src/helper_functions.jl")
include("../src/termset.jl")

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

pair = get_problem_grammar_pair(PBE_SLIA_Track_2019, "30732554") 

g = pair.grammar
examples = map(example -> [example], pair.problem.spec)
    
println(find_solutions_per_example(examples, g, :Start, 1, [:_arg_1], add_constraints_30732554!))

#=
EASY(2 nodes):                                  SOLUTION:                                               UNIVERSAL SOLUTION FOUND:   TIME:
problem_convert_numbers_to_text,                int_to_str_cvc(_arg_1)                                  YES                         0.06
problem_convert_text_to_numbers,                str_to_int_cvc(_arg_1)                                  YES                         0.05
problem_cell_contains_specific_text             contains_cvc(_arg_1, _arg_2)                            YES                         0.12
problem_replace_one_character_with_another      replace_cvc(_arg_1, " ", "-")                           YES                         1.41
problem_remove_text_by_matching                 replace_cvc(_arg_1, "-", "")                            YES                         1.43
problem_count_total_characters_in_a_cell        len_cvc(_arg_1)                                         YES                         0.03

MEDIUM(3+ nodes):                               SOLUTION:
problem_compare_two_strings                     prefixof_cvc(_arg_1, _arg_2)                            YES                         0.09   
problem_change_negative_numbers_to_positive     replace_cvc(_arg_1, "-", "")                            YES                         0.77
problem_remove_unwanted_characters              replace_cvc(_arg_1, _arg_2, "")                         YES                         0.87
problem_remove_characters_from_left             replace_cvc(_arg_1, substr_cvc(_arg_1, 1, _arg_2), "")  YES                         51.57
problem_join_first_and_last_name                concat_cvc(_arg_1, concat_cvc(" ", _arg_2))             YES                         2.16
problem_37281007                                contains_cvc(_arg_1, _arg_2)                            YES                         0.13
problem_19558979                                at_cvc(_arg_1, _arg_2)                                  YES                         0.17      

HARD(many nodes):                               SOLUTIONS                               UNIVERSAL SOLUTION FOUND:
problem_clean_and_reformat_telephone_numbers    :(replace_cvc(_arg_1, "-/.", "")) 2/3   NO
problem_44789427                                NO                                      NO
stackoverflow9                                  NO                                      NO
stackoverflow10                                 NO                                      NO
remove_file_extension_from_filename
get_last_name_from_name_with_comma              NO                                      NO
problem_get_last_name_from_name                 NO                                      NO
problem_11604909 
problem_12948338
problem_30732554




interesting for my own (moeite vanaf deze size):
problem_get_last_name_from_name     with solution   substr_cvc(aap, indexof_cvc(aap, " ", 1)+1, len_cvc(aap))
problem_30732554                    with solution   substr_cvc(test,1,indexof_cvc(test,"|",1)-1)

substr_cvc(test,1,indexof_cvc(test,"|",1)-1)

problem_37281007new = Problem("problem_37281007new", [
	IOExample(Dict{Symbol, Any}(:_arg_1 => "ABCD", :_arg_2 => "D", :_arg_3 => 1), true),            if arg3 == 1 suffix(arg1, arg2) 
    IOExample(Dict{Symbol, Any}(:_arg_1 => "ABCD", :_arg_2 => "AB", :_arg_3 => 0), true), 
	IOExample(Dict{Symbol, Any}(:_arg_1 => "ABCD", :_arg_2 => "A", :_arg_3 => 1), false)]),
    IOExample(Dict{Symbol, Any}(:_arg_1 => "ABCD", :_arg_2 => "CD", :_arg_3 => 0), false)])


substr(arg1, 1, at_cvc(_arg_1, "|"))

=#

#solution = solve(examples, g, :Start, [:_arg_1], Union{String, Int, Bool, Expr, Symbol}, Union{String, Int, Bool}, 1, 3)
#println(solution)
