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

pair = get_problem_grammar_pair(PBE_SLIA_Track_2019, "split_text_string_at_specific_character") 

g = pair.grammar
examples = map(example -> [example], pair.problem.spec)
    
println(find_solutions_per_example(examples, g, :Start, 1, [:_arg_1], add_constraints_split_text_string_at_specific_character!))

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



problem set, aim for 10 problems that show interesting stuff
1) 2x+1 --> x + <x+1>: [(0,1,x+1),(1,3,x+2),(2,5,x+3)] D = [0,1,2,x,x+1,x+2,x+3] (shows power of individual solutions)
    - meeting note I could do more of this one but for the point one is enough right?
2) x^2 +2x + 1, ((0,1),(1,4),(2,9)), D = [for (2,9) we need 2*2+1. so terms up to 2 ops] (shows power but bigger)
3) D = [x, -x, x==5, x==-5] R = (a == b --> a >= b, a >= b --> a >= b-1), W = (a --> if true then a else :any) (shows power of wildcard rules)
4) prefixof(arg1, arg2) || suffixof(arg1, arg2) with indiv ones as the indiv solutions using, A == A or :any + :any or A (shows other wildcard rule)
5) D = [1,x,-x,x-x,x-1] (shows cycles)
6) problem (1) but with Int = -Int (shows cycles for bigger problem)
7) problem_get_last_name_from_name but with numbers up to like 20 (shows power of the rewrite idea of my system for a bigger problem that was unsolved)
    - meeting note: maybe introducing cvecs as terms is enough for this. but i dont want to alter my stuff a lot anymore :cry: (future work idea?)
    - I think this is the most interesting one 
8) problem_split_text_string_at_specific_character
    - solution would be if arg2 == 1 then substr_cvc(kaas, 1, indexof_cvc(kaas, "_", 1)-1) else substr_cvc(kaas, 1, indexof_cvc(kaas, "_", 1)+1)
    - both the individual ones can be constructed
    - using both wildcard rules for true and false the whole thing should be findable
    - then also this one is found
    - also solve these ones with enumeration





problem 2 in more detail:
0,1,2
1,4,9

A + B

A = x*x             0/1/4           0+1, 1+3, 4+5
B = (2*x) + 1       1/3/5               



problem 7 in more detail:
substr_cvc(_arg_1, indexof_cvc(_arg_1, " ", 1)+1, len_cvc(_arg_1))

D=[_arg_1, len_cvc(_arg_1), ]

substr_cvc_(A,B,C)

A == _arg_1

B = indexof_cvc(_arg_1, " ", 1)+1  ==> this number wont be available either. so remake this problem but with bigger numbers for

C = len_cvc(_arg_1) ==> this is the problem mostly as you wont have the big numbers. so introduce by hand or enumerate to larger size

substr_cvc(A, B, len_cvc(_arg_1))

=#

#solution = solve(examples, g, :Start, [:_arg_1], Union{String, Int, Bool, Expr, Symbol}, Union{String, Int, Bool}, 1, 3)
#println(solution)