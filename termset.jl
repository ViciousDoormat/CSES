module Termset

export contains_variable, examples, solutions_per_example

using HerbSearch
using HerbGrammar
using HerbSpecification
using HerbConstraints
using HerbCore

#TODO temporary; for now
function contains_variable(expr::ExprType) where {ExprType}
    if expr == :(x)
        return true
    elseif typeof(expr) == Expr 
        for arg in expr.args
            if arg == :(x)
                return true
            elseif typeof(arg) == Expr && contains_variable(arg)
                return true
            end
        end
    end
    return false
end

# println(contains_variable(:x))
# println(contains_variable(:b))
# println(contains_variable(:(x+0)))
# println(contains_variable(:(0+0)))
# println(contains_variable(:(0+0+x)))
# println(contains_variable(:(x+0+0)))
# println(contains_variable(:(0+x+0)))

# Define the grammar
const grammar = @csgrammar begin
    Number = |(-10:10)
    Number = x
    Number = Number + Number
    Number = Number - Number
    Number = Number * Number
end

# Create input-output examples
const examples = [[IOExample(Dict(:x => x), 4x + 6)] for x ∈ -10:10]

const num_solutions_desired = 3
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
            expr = rulenode2expr(HerbConstraints.freeze_state(candidate_program),grammar)
            if contains_variable(expr)
                push!(found_solutions, expr)
            end
        end
    
        if length(found_solutions) >= num_solutions_desired
            break
        end
    end
    push!(solutions_per_example, found_solutions)
end


println("Solutions per example")
for (i, example) in enumerate(examples)
    println("Example $i")
    for term in solutions_per_example[i]
        println(term)
    end
end

end









