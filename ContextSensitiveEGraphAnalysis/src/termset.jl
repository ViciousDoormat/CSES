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

function find_solutions_per_example(examples, grammar, grammar_root, num_solutions, variables, constraints, ::Type{AllTypes}) where {AllTypes}
    symboltable :: SymbolTable = SymbolTable(grammar, Main)
    fs = falses(length(examples))
    solutions_per_example = Dict{Int, Vector{AllTypes}}(i => [examples[i][1].out] for i in 1:length(examples))

    constraints(grammar)

    #println("start")
    start = time()

    for candidate_program ∈ BFSIterator(grammar, grammar_root)
        expr = rulenode2expr(candidate_program, grammar)
        all(variable -> contains_variable(expr, variable), variables) || continue
        #println(expr)
        for (num, example) in enumerate(examples)
            fs[num] && continue
            score = HerbSearch.evaluate(Problem("example$num", example), expr, symboltable, allow_evaluation_errors=true)
            if score == 1
                #expr = rulenode2expr(HerbConstraints.freeze_state(candidate_program),grammar) TODO maybe does something
                #println("example $num has solution $expr")
                push!(solutions_per_example[num], expr)
                if length(solutions_per_example[num]) >= num_solutions+1
                    fs[num] = true
                end
            end
        end
        
        time() - start > 120 && break
        all(fs) && break

    end

    #println(time() - start)
    
    return solutions_per_example
end

function generate_small_terms(grammar, up_to_size, grammar_root, examples)
    small_terms = Set()
    symboltable :: SymbolTable = SymbolTable(grammar, Main)

    for type in unique(grammar.types)
        for candidate_program ∈ BFSIterator(grammar, type, max_size=(up_to_size+3))
            expr = rulenode2expr(candidate_program, grammar) 

            try
                for example in examples 
                    HerbSearch.HerbInterpret.execute_on_input(symboltable, expr, example[1].in)
                end
                push!(small_terms, expr)
            catch
            end

            #count_operators(expr) <= up_to_size  || break TODO it iterates incorectly for this; in order of size; size(--x) == size(x+1)
        end
    end

    filter!(term -> count_operators(term) <= up_to_size, small_terms)

    return small_terms
end

#TODO write: if we do not find a solution in time, we use the output as solution

function create_termset(examples, grammar, grammar_root, variables, ::Type{AllTypes}, constraints, constraints_dumb, with_solutions, num_solutions=1, up_to_size=3) where {AllTypes}
    
    D = Set{AllTypes}()
    println("finding small terms")
    constraints_dumb(grammar)
    small_terms = generate_small_terms(grammar, up_to_size, grammar_root, examples)
    clearconstraints!(grammar)
    #println(length(small_terms))

    for e in examples
        union!(D, values(e[1].in))
    end
    
    if with_solutions
        constraints(grammar) 
        println("find solutions per example")
        solutions_per_example = find_solutions_per_example(examples, grammar, grammar_root, num_solutions, variables, constraints, AllTypes)
    else
        solutions_per_example = Dict{Int, Vector{AllTypes}}(i => [examples[i][1].out] for i in 1:length(examples))
    end

    #solutions_per_example = Dict{Int64, Vector{Union{Bool, Int64, Expr, String, Symbol}}}(2 => ["1002", :(int_to_str_cvc(_arg_1))], 3 => ["743", :(int_to_str_cvc(_arg_1))], 1 => ["101", :(int_to_str_cvc(_arg_1))])

    for solutions in values(solutions_per_example)
        union!(D, solutions)
    end

    union!(D, small_terms)

    return D, solutions_per_example
end