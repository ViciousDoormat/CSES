using HerbSearch
using HerbGrammar
using HerbSpecification
using HerbConstraints
using HerbCore
using HerbBenchmarks

using HerbBenchmarks.SyGuS
using Test

include("../src/sygus_string_interpret.jl")

# CVC5 functions

## String typed
concat_cvc(str1::String, str2::String) = str1 * str2
replace_cvc(mainstr::String, to_replace::String, replace_with::String) = replace(mainstr, to_replace => replace_with)
at_cvc(str::String, index::Int) = string(str[index])
int_to_str_cvc(n::Int) = "$n"
substr_cvc(str::String, start_index::Int, end_index::Int) = str[start_index:end_index]
# Int typed
len_cvc(str::String) = length(str)
str_to_int_cvc(str::String) = parse(Int64, str)
indexof_cvc(str::String, substring::String, index::Int) = (n = findfirst(substring, str); n == nothing ? -1 : (n[1] >= index ? n[1] : -1))
# Bool typed
prefixof_cvc(prefix::String, str::String) = startswith(str, prefix)
suffixof_cvc(suffix::String, str::String) = endswith(str, suffix)
contains_cvc(str::String, contained::String) = contains(str, contained)
lt_cvc(str1::String, str2::String) = cmp(str1, str2) < 0
leq_cvc(str1::String, str2::String) = cmp(str1, str2) <= 0

isdigit_cvc(str::String) = tryparse(Int, str) !== nothing

g = HerbBenchmarks.PBE_SLIA_Track_2019.grammar_split_text_string_at_specific_character
t = get_relevant_tags(g)
d = Dict([(:_arg_1, 10)])

@testset "interpreter" begin
    @test interpret_sygus((@rulenode 2),t,d) == 10
    @test interpret_sygus((@rulenode 12),t,d) == :_arg_2
    @test interpret_sygus((@rulenode 3),t,d) == ""
    @test interpret_sygus((@rulenode 4),t,d) == " "
    @test interpret_sygus((@rulenode 5),t,d) == "_"
    @test interpret_sygus((@rulenode 13),t,d) == 1
    @test interpret_sygus((@rulenode 14),t,d) == 0
    @test interpret_sygus((@rulenode 15),t,d) == -1
    @test interpret_sygus((@rulenode 16),t,d) == 2
    @test interpret_sygus((@rulenode 23),t,d) == true
    @test interpret_sygus((@rulenode 24),t,d) == false
    @test interpret_sygus((@rulenode 17{13,13}),t,d) == 2
    @test interpret_sygus((@rulenode 18{13,13}),t,d) == 0
    @test interpret_sygus((@rulenode 25{13,13}),t,d) == true
    @test interpret_sygus((@rulenode 6{3,4}),t,d) == " "
    @test interpret_sygus((@rulenode 7{5,5,4}),t,d) == " "
    @test interpret_sygus((@rulenode 8{4,13}),t,d) == " "
    @test interpret_sygus((@rulenode 9{13}),t,d) == "1"
    @test interpret_sygus((@rulenode 11{5,13,13}),t,d) == "_"
    @test interpret_sygus((@rulenode 19{5}),t,d) == 1
    @test interpret_sygus((@rulenode 20{9{13}}),t,d) == 1
    @test interpret_sygus((@rulenode 22{5,5,13}),t,d) == 1
    @test interpret_sygus((@rulenode 26{5,5}),t,d) == true
    @test interpret_sygus((@rulenode 27{5,5}),t,d) == true
    @test interpret_sygus((@rulenode 28{5,5}),t,d) == true

    @test interpret_sygus((@rulenode 10{23,3,4}),t,d) == ""
    @test interpret_sygus((@rulenode 21{23,13,14}),t,d) == 1
end 

@testset "interpreter" begin
    @test interpret_sygus(rulenode2expr((@rulenode 2),g),d) == 10
    @test interpret_sygus(rulenode2expr((@rulenode 12),g),d) == :_arg_2
    @test interpret_sygus(rulenode2expr((@rulenode 3),g),d) == ""
    @test interpret_sygus(rulenode2expr((@rulenode 4),g),d) == " "
    @test interpret_sygus(rulenode2expr((@rulenode 5),g),d) == "_"
    @test interpret_sygus(rulenode2expr((@rulenode 13),g),d) == 1
    @test interpret_sygus(rulenode2expr((@rulenode 14),g),d) == 0
    @test interpret_sygus(rulenode2expr((@rulenode 15),g),d) == -1
    @test interpret_sygus(rulenode2expr((@rulenode 16),g),d) == 2
    @test interpret_sygus(rulenode2expr((@rulenode 23),g),d) == true
    @test interpret_sygus(rulenode2expr((@rulenode 24),g),d) == false
    @test interpret_sygus(rulenode2expr((@rulenode 17{13,13}),g),d) == 2
    @test interpret_sygus(rulenode2expr((@rulenode 18{13,13}),g),d) == 0
    @test interpret_sygus(rulenode2expr((@rulenode 25{13,13}),g),d) == true
    @test interpret_sygus(rulenode2expr((@rulenode 6{3,4}),g),d) == " "
    @test interpret_sygus(rulenode2expr((@rulenode 7{5,5,4}),g),d) == " "
    @test interpret_sygus(rulenode2expr((@rulenode 8{4,13}),g),d) == " "
    @test interpret_sygus(rulenode2expr((@rulenode 9{13}),g),d) == "1"
    @test interpret_sygus(rulenode2expr((@rulenode 11{5,13,13}),g),d) == "_"
    @test interpret_sygus(rulenode2expr((@rulenode 19{5}),g),d) == 1
    @test interpret_sygus(rulenode2expr((@rulenode 20{9{13}}),g),d) == 1
    @test interpret_sygus(rulenode2expr((@rulenode 22{5,5,13}),g),d) == 1
    @test interpret_sygus(rulenode2expr((@rulenode 26{5,5}),g),d) == true
    @test interpret_sygus(rulenode2expr((@rulenode 27{5,5}),g),d) == true
    @test interpret_sygus(rulenode2expr((@rulenode 28{5,5}),g),d) == true

    @test interpret_sygus(rulenode2expr((@rulenode 10{23,3,4}),g),d) == ""
    @test interpret_sygus(rulenode2expr((@rulenode 21{23,13,14}),g),d) == 1
end 