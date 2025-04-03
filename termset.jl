using HerbSearch
using HerbGrammar
using HerbSpecification
using HerbConstraints

# Define the grammar
grammar = @csgrammar begin
    Number = |(-10:10)
    Number = x
    Number = Number + Number
    Number = Number - Number
    Number = Number * Number
end

# Create input-output examples
examples = [[IOExample(Dict(:x => x), 4x + 6)] for x ∈ -10:10]

num_solutions_desired = 3
solutions_per_example = []

for example in examples
    found_solutions = []
    symboltable :: SymbolTable = SymbolTable(grammar, Main)
    problem = Problem("example", example)
    for (i, candidate_program) ∈ enumerate(BFSIterator(grammar, :Number))
        # Create expression from rulenode representation of AST
        expr = rulenode2expr(candidate_program, grammar)
    
        # Evaluate the expression
        score = HerbSearch.evaluate(problem, expr, symboltable)
        if score == 1
            push!(found_solutions, HerbConstraints.freeze_state(candidate_program))
        end
    
        if length(found_solutions) >= num_solutions_desired
            break
        end
    end
    push!(solutions_per_example, found_solutions)
end

#solutions:
for solutions in solutions_per_example
    for s in solutions
        println(rulenode2expr(s, grammar))
    end
end