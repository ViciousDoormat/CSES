using HerbSearch
using HerbGrammar
using HerbSpecification
using HerbConstraints
using HerbCore

using HerbBenchmarks.SyGuS

function find_individual_solution(example, grammar, grammar_root, num_solutions, tags, variables)
    found_solutions = []
    
    for candidate_program ∈ BFSIterator(grammar, grammar_root)  
        # Evaluate the expression
        score = 0

        try 
            score = interpret_sygus(candidate_program, tags, example.in) == example.out
        catch
        end

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
    tags = get_relevant_tags(grammar)

    for (num, example) in enumerate(examples)
        println("example $num")

        #TODO timeout
        found_solutions = find_individual_solution(example[1], grammar, grammar_root, num_solutions, tags, variables)
        #timeout(()->find_individual_solution(problem, grammar, grammar_root, num_solutions, symboltable, variable), 1)()
        
        solutions_per_example[num] = found_solutions
    end
    
    return solutions_per_example
end

function generate_small_terms(grammar, up_to_size, grammar_root, examples)
    small_terms = []
    tags = get_relevant_tags(grammar)

    for candidate_program ∈ BFSIterator(grammar, grammar_root, max_size=up_to_size)

        try
            for example in examples 
                interpret_sygus(candidate_program,tags,example[1].in)
            end
            expr = rulenode2expr(candidate_program, grammar) 
            push!(small_terms, expr)
        catch
        end
        
        #count_operators(expr) <= up_to_size  || break TODO it iterates incorectly for this; in order of size; size(--x) == size(x+1)
    end

    return small_terms
end

function create_termset(examples, grammar, grammar_root, variables, ::Type{AllTypes}, num_solutions=1, up_to_size=3) where {AllTypes}
    D = Set{AllTypes}()
    println("find solutions per example")
    solutions_per_example = find_solutions_per_example(examples, grammar, grammar_root, num_solutions, variables)
    
    println("finding small terms")
    small_terms = generate_small_terms(grammar, up_to_size, grammar_root, examples)
    println(small_terms)
    
    for solutions in values(solutions_per_example)
        union!(D, solutions)
    end

    union!(D, small_terms)

    return D, solutions_per_example
end