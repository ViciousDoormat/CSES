module Termset

export create_termset

using HerbSearch
using HerbGrammar
using HerbSpecification
using HerbConstraints
using HerbCore

using HerbBenchmarks.SyGuS

using Timeout

include("helper_functions.jl")

using .Helper

function find_individual_solution(problem, grammar, grammar_root, num_solutions, symboltable, variable)
    found_solutions = []
    
    for candidate_program ∈ BFSIterator(grammar, grammar_root)
        # Create expression from rulenode representation of AST
        expr = rulenode2expr(candidate_program, grammar)
        #println(expr)
    
        # Evaluate the expression
        score = HerbSearch.evaluate(problem, expr, symboltable)
        if score == 1
            expr = rulenode2expr(HerbConstraints.freeze_state(candidate_program),grammar)
            if contains_variable(expr, variable)
                push!(found_solutions, expr)
            end
        end
    
        if length(found_solutions) >= num_solutions
            break
        end
    end

    return found_solutions
end

function find_solutions_per_example(examples, grammar, grammar_root, num_solutions, variable=:x)
    solutions_per_example = Dict()
    symboltable :: SymbolTable = SymbolTable(grammar, Main)

    for (num, example) in enumerate(examples)
        println("example $num")
        problem = Problem("example$num", example)

        #TODO timeout
        found_solutions = find_individual_solution(problem, grammar, grammar_root, num_solutions, symboltable, variable)
        #timeout(()->find_individual_solution(problem, grammar, grammar_root, num_solutions, symboltable, variable), 1)()
        
        solutions_per_example[example[1].in[variable]] = found_solutions
    end
    
    return solutions_per_example
end

function generate_small_terms(grammar, up_to_size, grammar_root)
    small_terms = []

    for candidate_program ∈ BFSIterator(grammar, grammar_root, max_size=up_to_size)
        expr = rulenode2expr(candidate_program, grammar) 
        push!(small_terms, expr)
        #count_operators(expr) <= up_to_size  || break TODO it iterates incorectly for this; in order of size; size(--x) == size(x+1)
    end

    return small_terms
end

function create_termset(examples, grammar, grammar_root, variable, ::Type{AllTypes}, num_solutions=1, up_to_size=3) where {AllTypes}
    D = Set{AllTypes}()#Set{Union{ExprType, Symbol, Int}}()
    println("find solutions per example")
    solutions_per_example = find_solutions_per_example(examples, grammar, grammar_root, num_solutions, variable)
    
    println("finding small terms")
    small_terms = generate_small_terms(grammar, up_to_size, grammar_root)
    
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

# println(create_termset(examples, grammar, :Number, :y, Union{Int,Expr,Symbol}))

# end






