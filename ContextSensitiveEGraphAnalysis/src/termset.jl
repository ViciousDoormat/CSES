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

function generate_small_terms(grammar, up_to_size, grammar_root, examples)
    small_terms = Set()
    symboltable :: SymbolTable = SymbolTable(grammar, Main)

    for type in unique(grammar.types)
        for candidate_program ∈ BFSIterator(grammar, type, max_size=up_to_size)
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

    return small_terms
end

function add_constraints!(grammar)
    arg1 = 2
    arg2 = 3
    empty = 4
    space = 5
    dash = 6
    concat = 7
    replace = 8
    at = 9
    intstr = 10
    ifstr = 11
    substr = 12
    one = 13
    zero = 14
    mone = 15
    two = 16
    three = 17
    plus = 18
    minus = 19
    len = 20
    strint = 21
    ifnum = 22
    indexof = 23
    tru = 24
    fls = 25
    equals = 26
    prefixof = 27
    suffixof = 28
    contains = 29

    addconstraint!(grammar, Forbidden(RuleNode(concat, [VarNode(:A), RuleNode(empty)]))) # A + ""
    addconstraint!(grammar, Forbidden(RuleNode(concat, [RuleNode(empty), VarNode(:A)]))) # "" + A

    addconstraint!(grammar, Forbidden(RuleNode(replace, [VarNode(:A), VarNode(:B), VarNode(:B)]))) # A.replace(B, B)
    
    addconstraint!(grammar, Forbidden(RuleNode(strint, [RuleNode(intstr, [VarNode(:A)])]))) # str(int(A))
    addconstraint!(grammar, Forbidden(RuleNode(intstr, [RuleNode(strint, [VarNode(:A)])]))) # int(str(A))

    #addconstraint!(grammar, Forbidden(RuleNode(ifstr, [RuleNode(tru), VarNode(:A), VarNode(:B)]))) # if true then A else B
    #addconstraint!(grammar, Forbidden(RuleNode(ifstr, [RuleNode(fls), VarNode(:A), VarNode(:B)]))) # if false then A else B

    addconstraint!(grammar, Forbidden(RuleNode(ifstr, [VarNode(:A), VarNode(:B), VarNode(:B)]))) # if A then B else B
    addconstraint!(grammar, Forbidden(RuleNode(ifnum, [VarNode(:A), VarNode(:B), VarNode(:B)]))) # if A then B else B

    addconstraint!(grammar, Forbidden(RuleNode(plus, [VarNode(:A), zero]))) # A + 0
    addconstraint!(grammar, Forbidden(RuleNode(plus, [zero, VarNode(:A)]))) # 0 + A
    addconstraint!(grammar, Forbidden(RuleNode(minus, [VarNode(:A), zero]))) # A - 0

    addconstraint!(grammar, Forbidden(RuleNode(equals, [VarNode(:A), VarNode(:A)]))) # A == A

    addconstraint!(grammar, Forbidden(RuleNode(prefixof, [VarNode(:A), VarNode(:A)]))) # A.prefixof(A)
    addconstraint!(grammar, Forbidden(RuleNode(prefixof, [RuleNode(empty), VarNode(:A)]))) # "".prefixof(A)

    addconstraint!(grammar, Forbidden(RuleNode(suffixof, [VarNode(:A), VarNode(:A)]))) # A.suffixof(A)
    addconstraint!(grammar, Forbidden(RuleNode(suffixof, [RuleNode(empty), VarNode(:A)]))) # "".suffixof(A)

    addconstraint!(grammar, Forbidden(RuleNode(contains, [VarNode(:A), VarNode(:A)]))) # A.contains(A)
    addconstraint!(grammar, Forbidden(RuleNode(contains, [VarNode(:A), RuleNode(empty)]))) # A.contains("")

    # 1) loop door ruler code heen --> check new ruler iteration imp, test initial in keys(T.classes)
    # 2) test rule select change
    # 3) constraints + test
    # 4) idea of instead of constraints add rewrite rule (in principe meer grammar onafhankelijk)
    # 5) other rule select approach


end

function create_termset(examples, grammar, grammar_root, variables, ::Type{AllTypes}, num_solutions=1, up_to_size=3) where {AllTypes}
    add_constraints!(grammar)
    
    D = Set{AllTypes}()
    println("find solutions per example")
    solutions_per_example = find_solutions_per_example(examples, grammar, grammar_root, num_solutions, variables)
    
    println("finding small terms")
    small_terms = generate_small_terms(grammar, up_to_size, grammar_root, examples)
    println(length(small_terms))
    
    for solutions in values(solutions_per_example)
        union!(D, solutions)
    end

    union!(D, small_terms)

    return D, solutions_per_example
end