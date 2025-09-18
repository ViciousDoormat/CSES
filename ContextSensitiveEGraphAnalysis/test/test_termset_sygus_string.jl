include("../src/helper_functions.jl")
include("../src/termset.jl")

using HerbSearch
using HerbGrammar
using HerbSpecification
using HerbConstraints
using HerbCore
using HerbBenchmarks
using HerbBenchmarks.SyGuS
using Test

pair = get_problem_grammar_pair(PBE_BV_Track_2018, "remove_characters_from_right") 

#g = pair.grammar
g = @cfgrammar begin
	Start = ntInt
	ntString = _arg_1
	ntString = " "
	#ntString = replace_cvc(ntString, ntString, ntString)
	ntString = substr_cvc(ntString, ntInt, ntInt)
	ntInt = 1
	ntInt = 0
	ntInt = str_to_int_cvc(ntString)
	ntInt = indexof_cvc(ntString, ntString, ntInt)
end


#add_constraints_remove_characters_from_right!(g)
examples = map(example -> [example], pair.problem.spec)

#println(generate_small_terms(g, 4, nothing, examples))
println(create_termset(examples, g, :Start, [:_arg_1], Union{String, Int, Bool, Expr, Symbol}))

