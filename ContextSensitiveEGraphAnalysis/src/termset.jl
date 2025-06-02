using HerbSearch
using HerbGrammar
using HerbSpecification
using HerbConstraints
using HerbCore

using HerbBenchmarks.SyGuS

function find_individual_solution(problem, grammar, grammar_root, num_solutions, symboltable, variables)
    found_solutions = []
    
    for candidate_program ∈ BFSIterator(grammar, grammar_root)
        # Create expression from rulenode representation of AST
        expr = rulenode2expr(candidate_program, grammar)
        #println(expr)
    
        # Evaluate the expression
        score = HerbSearch.evaluate(problem, expr, symboltable, allow_evaluation_errors=true)
        if score == 1
            expr = rulenode2expr(HerbConstraints.freeze_state(candidate_program),grammar)
            if all(variable -> contains_variable(expr, variable), variables)  #TODO make one function?
                push!(found_solutions, expr)
            end
        end
    
        if length(found_solutions) >= num_solutions
            break
        end
    end

    return found_solutions
end

function find_solutions_per_example(examples, grammar, grammar_root, num_solutions, variables)
    solutions_per_example = Dict()
    symboltable :: SymbolTable = SymbolTable(grammar, Main)

    for (num, example) in enumerate(examples)
        println("example $num")
        problem = Problem("example$num", example)

        #TODO timeout
        found_solutions = find_individual_solution(problem, grammar, grammar_root, num_solutions, symboltable, variables)
        #timeout(()->find_individual_solution(problem, grammar, grammar_root, num_solutions, symboltable, variable), 1)()
        
        solutions_per_example[num] = found_solutions
    end
    
    return solutions_per_example
end

function generate_small_terms(grammar, up_to_size, grammar_root, example_input)
    small_terms = []
    symboltable :: SymbolTable = SymbolTable(grammar, Main)

    for candidate_program ∈ BFSIterator(grammar, grammar_root, max_size=up_to_size)
        expr = rulenode2expr(candidate_program, grammar) 

        try
            execute_on_input(symboltable, expr, example_input)
        catch
            continue
        end

        push!(small_terms, expr)
        #count_operators(expr) <= up_to_size  || break TODO it iterates incorectly for this; in order of size; size(--x) == size(x+1)
    end

    return small_terms
end

function create_termset(examples, grammar, grammar_root, variables, ::Type{AllTypes}, num_solutions=1, up_to_size=3) where {AllTypes}
    D = Set{AllTypes}()
    println("find solutions per example")
    solutions_per_example = find_solutions_per_example(examples, grammar, grammar_root, num_solutions, variables)
    
    println("finding small terms")
    small_terms = generate_small_terms(grammar, up_to_size, grammar_root, examples[1][1].in)
    println(small_terms)
    
    for solutions in values(solutions_per_example)
        union!(D, solutions)
    end

    union!(D, small_terms)

    return D, solutions_per_example
end