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

pair = get_problem_grammar_pair(PBE_SLIA_Track_2019, "12948338") 

g = pair.grammar
examples = map(example -> [example], pair.problem.spec)

add_constraints!(g)

#println(generate_small_terms(g, 4, nothing, examples))
create_termset(examples, g, :Start, [:_arg_1, :_arg_2], Union{String, Int, Bool, Expr, Symbol})

