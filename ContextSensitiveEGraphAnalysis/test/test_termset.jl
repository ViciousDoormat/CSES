include("../src/termset.jl")

using HerbSearch
using HerbGrammar
using HerbSpecification
using HerbConstraints
using HerbCore
using Test
using Timeout

# Define the grammar
const grammar1 = @csgrammar begin
    Number = |(0:4)
    Number = x
    Number = -Number
    Number = Number + Number
    Number = Number * Number
end

const grammar2 = @csgrammar begin
    Number = |(0:4)
    Number = x
    Number = y
    Number = -Number
    Number = Number + Number
    Number = Number * Number
end

# Define IO examples
const examples = [[IOExample(Dict(:x => x), 2x + 1)] for x ∈ -10:10]

for example in examples
    sol = find_individual_solution(Problem("", example), grammar1, :Number, 1, SymbolTable(grammar1, Main), [:x])
    result = HerbSearch.execute_on_input(SymbolTable(grammar1, Main), sol[1], example[1].in)
    @show @test result == example[1].out
end

# f = timeout(()->find_individual_solution(problem, grammar, :Number, 1, SymbolTable(grammar, Main), :y), 1)
# @test_throws TimeoutException (a = f())

#size 1 means 0 operators

println(generate_small_terms(grammar1, 1, :Number))

const examples2 = [[IOExample(Dict(:x => x, :y => y), 2x + 1)] for x ∈ -10:10, y ∈ -1:1]

for example in examples2
    sol = find_individual_solution(Problem("", example), grammar2, :Number, 1, SymbolTable(grammar2, Main), [:x,:y])
    result = HerbSearch.execute_on_input(SymbolTable(grammar2, Main), sol[1], example[1].in)
    @show @test result == example[1].out
end

println(generate_small_terms(grammar2, 1, :Number))


# println(create_termset(examples, grammar))