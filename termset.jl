module Termset

export create_termset

using HerbSearch
using HerbGrammar
using HerbSpecification
using HerbConstraints
using HerbCore

include("helper_functions.jl")

using .Helper

function find_solutions_per_example(examples, grammar, grammar_root, num_solutions)
    solutions_per_example = Dict() #TODO remember this was for examples that go like 1,2,3,4,5

    for example in examples
        found_solutions = []
        symboltable :: SymbolTable = SymbolTable(grammar, Main)
        problem = Problem("example", example)
        for (i, candidate_program) ∈ enumerate(BFSIterator(grammar, grammar_root))
            # Create expression from rulenode representation of AST
            expr = rulenode2expr(candidate_program, grammar)
        
            # Evaluate the expression
            score = HerbSearch.evaluate(problem, expr, symboltable)
            if score == 1
                expr = rulenode2expr(HerbConstraints.freeze_state(candidate_program),grammar)
                if contains_variable(expr)
                    push!(found_solutions, expr)
                end
            end
        
            if length(found_solutions) >= num_solutions
                break
            end
        end
        solutions_per_example[example[1].in[:x]] = found_solutions
    end
    
    return solutions_per_example
end

function generate_small_terms(grammar, up_to_size)
    small_terms = []

    for (i, candidate_program) ∈ enumerate(BFSIterator(grammar, :Number, max_size=up_to_size))
        expr = rulenode2expr(candidate_program, grammar)
        #if contains_variable(expr)    
            push!(small_terms, expr)
        #end
    end

    return small_terms
end

function create_termset(examples, grammar, grammar_root=:Number, num_solutions=1, up_to_size=3, ::Type{ExprType}=Expr) where {ExprType}
    D = Set{Union{ExprType, Symbol, Int}}()
    solutions_per_example = find_solutions_per_example(examples, grammar, grammar_root, num_solutions)
    #println("Solutions per example: ", solutions_per_example)
    small_terms = generate_small_terms(grammar, up_to_size)
    
    for solutions in values(solutions_per_example)
        union!(D, solutions)
    end

    union!(D, small_terms)

    return D, solutions_per_example
end

end


# module Test
# using ..Termset

# using HerbSearch
# using HerbGrammar
# using HerbSpecification
# using HerbConstraints
# using HerbCore

# # Define the grammar
# const grammar = @csgrammar begin
#     Number = |(0:4)
#     Number = x
#     Number = -Number
#     Number = Number + Number
#     Number = Number * Number
# end

# # Define IO examples
# const examples = [[IOExample(Dict(:x => x), 2x + 1)] for x ∈ -10:10]

# println(create_termset(examples, grammar))

# end






