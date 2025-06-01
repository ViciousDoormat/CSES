include("../src/termset.jl")

using HerbSearch
using HerbGrammar
using HerbSpecification
using HerbConstraints
using HerbCore
using Test
using Timeout

# Define the grammar
const grammar = @csgrammar begin
    Number = |(0:4)
    Number = x
    Number = -Number
    Number = Number + Number
    Number = Number * Number
end

# Define IO examples
const examples = [[IOExample(Dict(:x => x), 2x + 1)] for x ∈ -10:10]

for example in examples
    sol = Termset.find_individual_solution(Problem("", example), grammar, :Number, 1, SymbolTable(grammar, Main), :x)
    result = HerbSearch.execute_on_input(SymbolTable(grammar, Main), sol[1], example[1].in)
    @show @test result == example[1].out
end

# f = timeout(()->find_individual_solution(problem, grammar, :Number, 1, SymbolTable(grammar, Main), :y), 1)
# @test_throws TimeoutException (a = f())

#size 1 means 0 operators

println(Termset.generate_small_terms(grammar, 1, :Number))



# println(create_termset(examples, grammar))