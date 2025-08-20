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

function find_solutions_per_example(examples, grammar, grammar_root, num_solutions, variables, constraints)
    println("start")
    start = time()
    symboltable :: SymbolTable = SymbolTable(grammar, Main)
    fs = falses(length(examples))
    solutions_per_example = Dict()
    for (num, _) in enumerate(examples)
        solutions_per_example[num] = []
    end

    constraints(grammar)

    for candidate_program ∈ BFSIterator(grammar, grammar_root)
        expr = rulenode2expr(candidate_program, grammar)
        all(variable -> contains_variable(expr, variable), variables) || continue
        #println(expr)
        for (num, example) in enumerate(examples)
            fs[num] && continue
            score = HerbSearch.evaluate(Problem("example$num", example), expr, symboltable, allow_evaluation_errors=true)
            if score == 1
                #expr = rulenode2expr(HerbConstraints.freeze_state(candidate_program),grammar) TODO maybe does something
                println("example $num has solution $expr")
                push!(solutions_per_example[num], expr)
                if length(solutions_per_example[num]) >= num_solutions
                    fs[num] = true
                end
            end
        end
        
        all(fs) && break

    end

    println(time() - start)
    
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

function add_constraints_12948338!(grammar)
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

    addconstraint!(grammar, Unique(contains))
    addconstraint!(grammar, Unique(suffixof))
    addconstraint!(grammar, Unique(prefixof))

    addconstraint!(grammar, Forbidden(RuleNode(len, [RuleNode(intstr, [VarNode(:A)])]))) # len(str(A::Int))
    addconstraint!(grammar, Forbidden(RuleNode(equals, [VarNode(:A), VarNode(:A)]))) # A.contains(A)

    num_is_num = falses(29)       # Creates a BitVector of 28 falses (0s)
    num_is_num[13:17] .= true     # Sets indices 12 to 16 to true (1)

    addconstraint!(grammar, Forbidden(RuleNode(equals, [DomainRuleNode(num_is_num),DomainRuleNode(num_is_num)])))

    addconstraint!(grammar, Forbidden(RuleNode(ifstr, [RuleNode(tru), VarNode(:A), VarNode(:B)]))) # if true then A else B
    addconstraint!(grammar, Forbidden(RuleNode(ifstr, [RuleNode(fls), VarNode(:A), VarNode(:B)]))) # if false then A else B
    addconstraint!(grammar, Forbidden(RuleNode(ifnum, [RuleNode(tru), VarNode(:A), VarNode(:B)]))) # if true then A else B
    addconstraint!(grammar, Forbidden(RuleNode(ifnum, [RuleNode(fls), VarNode(:A), VarNode(:B)]))) # if false then A else B
    
    
    addconstraint!(grammar, Forbidden(RuleNode(len, [RuleNode(dash)]))) 
    addconstraint!(grammar, Forbidden(RuleNode(len, [RuleNode(space)]))) 
    addconstraint!(grammar, Forbidden(RuleNode(len, [RuleNode(empty)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(replace, [RuleNode(dash), VarNode(:A), VarNode(:B)]))) 
    addconstraint!(grammar, Forbidden(RuleNode(replace, [RuleNode(space), VarNode(:A), VarNode(:B)]))) 
    addconstraint!(grammar, Forbidden(RuleNode(replace, [RuleNode(empty), VarNode(:A), VarNode(:B)]))) 
    
    addconstraint!(grammar, Forbidden(RuleNode(substr, [RuleNode(dash), VarNode(:A), VarNode(:B)]))) 
    addconstraint!(grammar, Forbidden(RuleNode(substr, [RuleNode(space), VarNode(:A), VarNode(:B)]))) 
    addconstraint!(grammar, Forbidden(RuleNode(substr, [RuleNode(empty), VarNode(:A), VarNode(:B)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(prefixof, [VarNode(:A), RuleNode(dash)]))) 
    addconstraint!(grammar, Forbidden(RuleNode(prefixof, [VarNode(:A), RuleNode(space)]))) 
    addconstraint!(grammar, Forbidden(RuleNode(prefixof, [VarNode(:A), RuleNode(empty)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(suffixof, [VarNode(:A), RuleNode(dash)]))) 
    addconstraint!(grammar, Forbidden(RuleNode(suffixof, [VarNode(:A), RuleNode(space)]))) 
    addconstraint!(grammar, Forbidden(RuleNode(suffixof, [VarNode(:A), RuleNode(empty)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(contains, [RuleNode(dash), VarNode(:A)]))) 
    addconstraint!(grammar, Forbidden(RuleNode(contains, [RuleNode(space), VarNode(:A)]))) 
    addconstraint!(grammar, Forbidden(RuleNode(contains, [RuleNode(empty), VarNode(:A)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(indexof, [RuleNode(dash), VarNode(:A), VarNode(:B)]))) 
    addconstraint!(grammar, Forbidden(RuleNode(indexof, [RuleNode(space), VarNode(:A), VarNode(:B)]))) 
    addconstraint!(grammar, Forbidden(RuleNode(indexof, [RuleNode(empty), VarNode(:A), VarNode(:B)]))) 

    addconstraint!(grammar, Ordered(RuleNode(equals, [VarNode(:a), VarNode(:b)]), [:a, :b]))
end

function add_constraints_remove_file_extension_from_filename!(grammar)
    arg1 = 2
    empty = 3
    space = 4
    dot = 5
    concat = 6
    replace = 7
    at = 8
    intstr = 9
    ifstr = 10
    substr = 11
    one = 12
    zero = 13
    mone = 14
    plus = 15
    minus = 16
    len = 17
    strint = 18
    ifnum = 19
    indexof = 20
    tru = 21
    fls = 22
    equals = 23
    prefixof = 24
    suffixof = 25
    contains = 26

    addconstraint!(grammar, Forbidden(RuleNode(concat, [VarNode(:A), RuleNode(empty)]))) # A + ""
    addconstraint!(grammar, Forbidden(RuleNode(concat, [RuleNode(empty), VarNode(:A)]))) # "" + A

    addconstraint!(grammar, Forbidden(RuleNode(replace, [VarNode(:A), VarNode(:B), VarNode(:B)]))) # A.replace(B, B)
    
    addconstraint!(grammar, Forbidden(RuleNode(strint, [RuleNode(intstr, [VarNode(:A)])]))) # str(int(A))
    addconstraint!(grammar, Forbidden(RuleNode(intstr, [RuleNode(strint, [VarNode(:A)])]))) # int(str(A))

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

    addconstraint!(grammar, Unique(contains))
    addconstraint!(grammar, Unique(suffixof))
    addconstraint!(grammar, Unique(prefixof))

    addconstraint!(grammar, Forbidden(RuleNode(len, [RuleNode(intstr, [VarNode(:A)])]))) # len(str(A::Int))

    num_is_num = falses(26)      
    num_is_num[12:14] .= true     

    addconstraint!(grammar, Forbidden(RuleNode(equals, [DomainRuleNode(num_is_num),DomainRuleNode(num_is_num)])))

    addconstraint!(grammar, Forbidden(RuleNode(ifstr, [RuleNode(tru), VarNode(:A), VarNode(:B)]))) # if true then A else B
    addconstraint!(grammar, Forbidden(RuleNode(ifstr, [RuleNode(fls), VarNode(:A), VarNode(:B)]))) # if false then A else B
    addconstraint!(grammar, Forbidden(RuleNode(ifnum, [RuleNode(tru), VarNode(:A), VarNode(:B)]))) # if true then A else B
    addconstraint!(grammar, Forbidden(RuleNode(ifnum, [RuleNode(fls), VarNode(:A), VarNode(:B)]))) # if false then A else B
    
    
    strings = falses(26)      
    strings[3:5] .= true  
    
    addconstraint!(grammar, Forbidden(RuleNode(len, [DomainRuleNode(strings)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(replace, [DomainRuleNode(strings), VarNode(:A), VarNode(:B)]))) 
    
    addconstraint!(grammar, Forbidden(RuleNode(substr, [DomainRuleNode(strings), VarNode(:A), VarNode(:B)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(prefixof, [VarNode(:A), DomainRuleNode(strings)]))) 
    
    addconstraint!(grammar, Forbidden(RuleNode(prefixof, [RuleNode(at, [VarNode(:A), RuleNode(one)]), VarNode(:B)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(suffixof, [VarNode(:A), DomainRuleNode(strings)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(contains, [DomainRuleNode(strings), VarNode(:A)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(indexof, [DomainRuleNode(strings), VarNode(:A), VarNode(:B)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(contains, [VarNode(:A), DomainRuleNode(strings)])))

    addconstraint!(grammar, Ordered(RuleNode(equals, [VarNode(:a), VarNode(:b)]), [:a, :b]))
end

function add_constraints_30732554!(grammar)
    arg1 = 2
    empty = 3
    space = 4
    stripe = 5
    concat = 6
    replace = 7
    at = 8
    intstr = 9
    ifstr = 10
    substr = 11
    one = 12
    zero = 13
    mone = 14
    plus = 15
    minus = 16
    len = 17
    strint = 18
    ifnum = 19
    indexof = 20
    tru = 21
    fls = 22
    equals = 23
    prefixof = 24
    suffixof = 25
    contains = 26

    addconstraint!(grammar, Forbidden(RuleNode(concat, [VarNode(:A), RuleNode(empty)]))) # A + ""
    addconstraint!(grammar, Forbidden(RuleNode(concat, [RuleNode(empty), VarNode(:A)]))) # "" + A

    addconstraint!(grammar, Forbidden(RuleNode(replace, [VarNode(:A), VarNode(:B), VarNode(:B)]))) # A.replace(B, B)
    
    addconstraint!(grammar, Forbidden(RuleNode(strint, [RuleNode(intstr, [VarNode(:A)])]))) # str(int(A))
    addconstraint!(grammar, Forbidden(RuleNode(intstr, [RuleNode(strint, [VarNode(:A)])]))) # int(str(A))

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

    addconstraint!(grammar, Unique(contains))
    addconstraint!(grammar, Unique(suffixof))
    addconstraint!(grammar, Unique(prefixof))

    addconstraint!(grammar, Forbidden(RuleNode(len, [RuleNode(intstr, [VarNode(:A)])]))) # len(str(A::Int))

    num_is_num = falses(26)      
    num_is_num[12:14] .= true     

    addconstraint!(grammar, Forbidden(RuleNode(equals, [DomainRuleNode(num_is_num),DomainRuleNode(num_is_num)])))

    addconstraint!(grammar, Forbidden(RuleNode(ifstr, [RuleNode(tru), VarNode(:A), VarNode(:B)]))) # if true then A else B
    addconstraint!(grammar, Forbidden(RuleNode(ifstr, [RuleNode(fls), VarNode(:A), VarNode(:B)]))) # if false then A else B
    addconstraint!(grammar, Forbidden(RuleNode(ifnum, [RuleNode(tru), VarNode(:A), VarNode(:B)]))) # if true then A else B
    addconstraint!(grammar, Forbidden(RuleNode(ifnum, [RuleNode(fls), VarNode(:A), VarNode(:B)]))) # if false then A else B
    
    
    strings = falses(26)      
    strings[3:5] .= true  
    
    addconstraint!(grammar, Forbidden(RuleNode(len, [DomainRuleNode(strings)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(replace, [DomainRuleNode(strings), VarNode(:A), VarNode(:B)]))) 
    
    addconstraint!(grammar, Forbidden(RuleNode(substr, [DomainRuleNode(strings), VarNode(:A), VarNode(:B)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(prefixof, [VarNode(:A), DomainRuleNode(strings)]))) 
    
    addconstraint!(grammar, Forbidden(RuleNode(prefixof, [RuleNode(at, [VarNode(:A), RuleNode(one)]), VarNode(:B)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(suffixof, [VarNode(:A), DomainRuleNode(strings)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(contains, [DomainRuleNode(strings), VarNode(:A)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(indexof, [DomainRuleNode(strings), VarNode(:A), VarNode(:B)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(contains, [VarNode(:A), DomainRuleNode(strings)])))

    addconstraint!(grammar, Ordered(RuleNode(equals, [VarNode(:a), VarNode(:b)]), [:a, :b]))
end

function add_constraints_44789427!(grammar)
    arg1 = 2
    arg2 = 12
    empty = 3
    space = 4
    dash = 5
    concat = 6
    replace = 7
    at = 8
    intstr = 9
    ifstr = 10
    substr = 11
    one = 13
    zero = 14
    mone = 15
    two = 16
    plus = 17
    minus = 18
    len = 19
    strint = 20
    ifnum = 21
    indexof = 22
    tru = 23
    fls = 24
    equals = 25
    prefixof = 26
    suffixof = 27
    contains = 28

    addconstraint!(grammar, Forbidden(RuleNode(concat, [VarNode(:A), RuleNode(empty)]))) # A + ""
    addconstraint!(grammar, Forbidden(RuleNode(concat, [RuleNode(empty), VarNode(:A)]))) # "" + A

    addconstraint!(grammar, Forbidden(RuleNode(replace, [VarNode(:A), VarNode(:B), VarNode(:B)]))) # A.replace(B, B)
    
    addconstraint!(grammar, Forbidden(RuleNode(strint, [RuleNode(intstr, [VarNode(:A)])]))) # str(int(A))
    addconstraint!(grammar, Forbidden(RuleNode(intstr, [RuleNode(strint, [VarNode(:A)])]))) # int(str(A))

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

    addconstraint!(grammar, Unique(contains))
    addconstraint!(grammar, Unique(suffixof))
    addconstraint!(grammar, Unique(prefixof))

    addconstraint!(grammar, Forbidden(RuleNode(len, [RuleNode(intstr, [VarNode(:A)])]))) # len(str(A::Int))

    num_is_num = falses(28)      
    num_is_num[13:16] .= true     

    addconstraint!(grammar, Forbidden(RuleNode(equals, [DomainRuleNode(num_is_num),DomainRuleNode(num_is_num)])))

    addconstraint!(grammar, Forbidden(RuleNode(ifstr, [RuleNode(tru), VarNode(:A), VarNode(:B)]))) # if true then A else B
    addconstraint!(grammar, Forbidden(RuleNode(ifstr, [RuleNode(fls), VarNode(:A), VarNode(:B)]))) # if false then A else B
    addconstraint!(grammar, Forbidden(RuleNode(ifnum, [RuleNode(tru), VarNode(:A), VarNode(:B)]))) # if true then A else B
    addconstraint!(grammar, Forbidden(RuleNode(ifnum, [RuleNode(fls), VarNode(:A), VarNode(:B)]))) # if false then A else B
    
    
    strings = falses(28)      
    strings[3:5] .= true  
    
    addconstraint!(grammar, Forbidden(RuleNode(len, [DomainRuleNode(strings)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(replace, [DomainRuleNode(strings), VarNode(:A), VarNode(:B)]))) 
    
    addconstraint!(grammar, Forbidden(RuleNode(substr, [DomainRuleNode(strings), VarNode(:A), VarNode(:B)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(prefixof, [VarNode(:A), DomainRuleNode(strings)]))) 
    
    addconstraint!(grammar, Forbidden(RuleNode(prefixof, [RuleNode(at, [VarNode(:A), RuleNode(one)]), VarNode(:B)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(suffixof, [VarNode(:A), DomainRuleNode(strings)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(contains, [DomainRuleNode(strings), VarNode(:A)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(indexof, [DomainRuleNode(strings), VarNode(:A), VarNode(:B)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(contains, [VarNode(:A), DomainRuleNode(strings)])))

    addconstraint!(grammar, Ordered(RuleNode(equals, [VarNode(:a), VarNode(:b)]), [:a, :b]))
end

function add_constraints_remove_characters_from_left!(grammar)
    arg1 = 2
    arg2 = 11
    empty = 3
    space = 4
    concat = 5
    replace = 6
    at = 7
    intstr = 8
    ifstr = 9
    substr = 10
    one = 12
    zero = 13
    mone = 14
    plus = 15
    minus = 16
    len = 17
    strint = 18
    ifnum = 19
    indexof = 20
    tru = 21
    fls = 22
    equals = 23
    prefixof = 24
    suffixof = 25
    contains = 26

    addconstraint!(grammar, Forbidden(RuleNode(concat, [VarNode(:A), RuleNode(empty)]))) # A + ""
    addconstraint!(grammar, Forbidden(RuleNode(concat, [RuleNode(empty), VarNode(:A)]))) # "" + A

    addconstraint!(grammar, Forbidden(RuleNode(replace, [VarNode(:A), VarNode(:B), VarNode(:B)]))) # A.replace(B, B)
    
    addconstraint!(grammar, Forbidden(RuleNode(strint, [RuleNode(intstr, [VarNode(:A)])]))) # str(int(A))
    addconstraint!(grammar, Forbidden(RuleNode(intstr, [RuleNode(strint, [VarNode(:A)])]))) # int(str(A))

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

    addconstraint!(grammar, Unique(contains))
    addconstraint!(grammar, Unique(suffixof))
    addconstraint!(grammar, Unique(prefixof))

    addconstraint!(grammar, Forbidden(RuleNode(len, [RuleNode(intstr, [VarNode(:A)])]))) # len(str(A::Int))

    num_is_num = falses(26)      
    num_is_num[12:14] .= true     

    addconstraint!(grammar, Forbidden(RuleNode(equals, [DomainRuleNode(num_is_num),DomainRuleNode(num_is_num)])))

    addconstraint!(grammar, Forbidden(RuleNode(ifstr, [RuleNode(tru), VarNode(:A), VarNode(:B)]))) # if true then A else B
    addconstraint!(grammar, Forbidden(RuleNode(ifstr, [RuleNode(fls), VarNode(:A), VarNode(:B)]))) # if false then A else B
    addconstraint!(grammar, Forbidden(RuleNode(ifnum, [RuleNode(tru), VarNode(:A), VarNode(:B)]))) # if true then A else B
    addconstraint!(grammar, Forbidden(RuleNode(ifnum, [RuleNode(fls), VarNode(:A), VarNode(:B)]))) # if false then A else B
    
    
    strings = falses(26)      
    strings[3:4] .= true  
    
    addconstraint!(grammar, Forbidden(RuleNode(len, [DomainRuleNode(strings)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(replace, [DomainRuleNode(strings), VarNode(:A), VarNode(:B)]))) 
    
    addconstraint!(grammar, Forbidden(RuleNode(substr, [DomainRuleNode(strings), VarNode(:A), VarNode(:B)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(prefixof, [VarNode(:A), DomainRuleNode(strings)]))) 
    
    addconstraint!(grammar, Forbidden(RuleNode(prefixof, [RuleNode(at, [VarNode(:A), RuleNode(one)]), VarNode(:B)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(suffixof, [VarNode(:A), DomainRuleNode(strings)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(contains, [DomainRuleNode(strings), VarNode(:A)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(indexof, [DomainRuleNode(strings), VarNode(:A), VarNode(:B)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(contains, [VarNode(:A), DomainRuleNode(strings)])))

    addconstraint!(grammar, Ordered(RuleNode(equals, [VarNode(:a), VarNode(:b)]), [:a, :b]))
end

function add_constraints_19558979!(grammar)
    arg1 = 2
    arg2 = 11
    empty = 3
    space = 4
    concat = 5
    replace = 6
    at = 7
    intstr = 8
    ifstr = 9
    substr = 10
    one = 12
    zero = 13
    mone = 14
    two = 15
    three = 16
    four = 17
    five = 18
    plus = 19
    minus = 20
    len = 21
    strint = 22
    ifnum = 23
    indexof = 24
    tru = 25
    fls = 26
    equals = 27
    prefixof = 28
    suffixof = 29
    contains = 30

    addconstraint!(grammar, Forbidden(RuleNode(concat, [VarNode(:A), RuleNode(empty)]))) # A + ""
    addconstraint!(grammar, Forbidden(RuleNode(concat, [RuleNode(empty), VarNode(:A)]))) # "" + A

    addconstraint!(grammar, Forbidden(RuleNode(replace, [VarNode(:A), VarNode(:B), VarNode(:B)]))) # A.replace(B, B)
    
    addconstraint!(grammar, Forbidden(RuleNode(strint, [RuleNode(intstr, [VarNode(:A)])]))) # str(int(A))
    addconstraint!(grammar, Forbidden(RuleNode(intstr, [RuleNode(strint, [VarNode(:A)])]))) # int(str(A))

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

    addconstraint!(grammar, Unique(contains))
    addconstraint!(grammar, Unique(suffixof))
    addconstraint!(grammar, Unique(prefixof))

    addconstraint!(grammar, Forbidden(RuleNode(len, [RuleNode(intstr, [VarNode(:A)])]))) # len(str(A::Int))

    num_is_num = falses(30)      
    num_is_num[12:18] .= true     

    addconstraint!(grammar, Forbidden(RuleNode(equals, [DomainRuleNode(num_is_num),DomainRuleNode(num_is_num)])))

    addconstraint!(grammar, Forbidden(RuleNode(ifstr, [RuleNode(tru), VarNode(:A), VarNode(:B)]))) # if true then A else B
    addconstraint!(grammar, Forbidden(RuleNode(ifstr, [RuleNode(fls), VarNode(:A), VarNode(:B)]))) # if false then A else B
    addconstraint!(grammar, Forbidden(RuleNode(ifnum, [RuleNode(tru), VarNode(:A), VarNode(:B)]))) # if true then A else B
    addconstraint!(grammar, Forbidden(RuleNode(ifnum, [RuleNode(fls), VarNode(:A), VarNode(:B)]))) # if false then A else B
    
    
    strings = falses(30)      
    strings[3:4] .= true  
    
    addconstraint!(grammar, Forbidden(RuleNode(len, [DomainRuleNode(strings)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(replace, [DomainRuleNode(strings), VarNode(:A), VarNode(:B)]))) 
    
    addconstraint!(grammar, Forbidden(RuleNode(substr, [DomainRuleNode(strings), VarNode(:A), VarNode(:B)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(prefixof, [VarNode(:A), DomainRuleNode(strings)]))) 
    
    addconstraint!(grammar, Forbidden(RuleNode(prefixof, [RuleNode(at, [VarNode(:A), RuleNode(one)]), VarNode(:B)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(suffixof, [VarNode(:A), DomainRuleNode(strings)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(contains, [DomainRuleNode(strings), VarNode(:A)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(indexof, [DomainRuleNode(strings), VarNode(:A), VarNode(:B)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(contains, [VarNode(:A), DomainRuleNode(strings)])))

    addconstraint!(grammar, Ordered(RuleNode(equals, [VarNode(:a), VarNode(:b)]), [:a, :b]))
end

function add_constraints_cell_contains_number!(grammar)
    arg1 = 2
    empty = 3
    space = 4
    sone = 5
    stwo = 6
    sthree = 7
    sfour = 8
    sfive = 9
    concat = 10
    replace = 11
    at = 12
    intstr = 13
    ifstr = 14
    substr = 15
    one = 16
    zero = 17
    mone = 18
    plus = 19
    minus = 20
    len = 21
    strint = 22
    ifnum = 23
    indexof = 24
    tru = 25
    fls = 26
    equals = 27
    prefixof = 28
    suffixof = 29
    contains = 30

    addconstraint!(grammar, Forbidden(RuleNode(concat, [VarNode(:A), RuleNode(empty)]))) # A + ""
    addconstraint!(grammar, Forbidden(RuleNode(concat, [RuleNode(empty), VarNode(:A)]))) # "" + A

    addconstraint!(grammar, Forbidden(RuleNode(replace, [VarNode(:A), VarNode(:B), VarNode(:B)]))) # A.replace(B, B)
    
    addconstraint!(grammar, Forbidden(RuleNode(strint, [RuleNode(intstr, [VarNode(:A)])]))) # str(int(A))
    addconstraint!(grammar, Forbidden(RuleNode(intstr, [RuleNode(strint, [VarNode(:A)])]))) # int(str(A))

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

    addconstraint!(grammar, Unique(contains))
    addconstraint!(grammar, Unique(suffixof))
    addconstraint!(grammar, Unique(prefixof))

    addconstraint!(grammar, Forbidden(RuleNode(len, [RuleNode(intstr, [VarNode(:A)])]))) # len(str(A::Int))

    num_is_num = falses(30)      
    num_is_num[16:18] .= true     

    addconstraint!(grammar, Forbidden(RuleNode(equals, [DomainRuleNode(num_is_num),DomainRuleNode(num_is_num)])))

    addconstraint!(grammar, Forbidden(RuleNode(ifstr, [RuleNode(tru), VarNode(:A), VarNode(:B)]))) # if true then A else B
    addconstraint!(grammar, Forbidden(RuleNode(ifstr, [RuleNode(fls), VarNode(:A), VarNode(:B)]))) # if false then A else B
    addconstraint!(grammar, Forbidden(RuleNode(ifnum, [RuleNode(tru), VarNode(:A), VarNode(:B)]))) # if true then A else B
    addconstraint!(grammar, Forbidden(RuleNode(ifnum, [RuleNode(fls), VarNode(:A), VarNode(:B)]))) # if false then A else B
    
    
    strings = falses(30)      
    strings[3:9] .= true  
    
    addconstraint!(grammar, Forbidden(RuleNode(len, [DomainRuleNode(strings)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(replace, [DomainRuleNode(strings), VarNode(:A), VarNode(:B)]))) 
    
    addconstraint!(grammar, Forbidden(RuleNode(substr, [DomainRuleNode(strings), VarNode(:A), VarNode(:B)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(prefixof, [VarNode(:A), DomainRuleNode(strings)]))) 
    
    addconstraint!(grammar, Forbidden(RuleNode(prefixof, [RuleNode(at, [VarNode(:A), RuleNode(one)]), VarNode(:B)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(suffixof, [VarNode(:A), DomainRuleNode(strings)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(contains, [DomainRuleNode(strings), VarNode(:A)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(indexof, [DomainRuleNode(strings), VarNode(:A), VarNode(:B)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(contains, [VarNode(:A), DomainRuleNode(strings)])))

    addconstraint!(grammar, Ordered(RuleNode(equals, [VarNode(:a), VarNode(:b)]), [:a, :b]))
end

function add_constraints_compare_two_strings!(grammar)
    arg1 = 2
    arg2 = 3
    empty = 4
    space = 5
    concat = 6
    replace = 7
    at = 8
    intstr = 9
    ifstr = 10
    substr = 11
    one = 12
    zero = 13
    mone = 14
    plus = 15
    minus = 16
    len = 17
    strint = 18
    ifnum = 19
    indexof = 20
    tru = 21
    fls = 22
    equals = 23
    prefixof = 24
    suffixof = 25
    contains = 26

    addconstraint!(grammar, Forbidden(RuleNode(concat, [VarNode(:A), RuleNode(empty)]))) # A + ""
    addconstraint!(grammar, Forbidden(RuleNode(concat, [RuleNode(empty), VarNode(:A)]))) # "" + A

    addconstraint!(grammar, Forbidden(RuleNode(replace, [VarNode(:A), VarNode(:B), VarNode(:B)]))) # A.replace(B, B)
    
    addconstraint!(grammar, Forbidden(RuleNode(strint, [RuleNode(intstr, [VarNode(:A)])]))) # str(int(A))
    addconstraint!(grammar, Forbidden(RuleNode(intstr, [RuleNode(strint, [VarNode(:A)])]))) # int(str(A))

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

    addconstraint!(grammar, Unique(contains))
    addconstraint!(grammar, Unique(suffixof))
    addconstraint!(grammar, Unique(prefixof))

    addconstraint!(grammar, Forbidden(RuleNode(len, [RuleNode(intstr, [VarNode(:A)])]))) # len(str(A::Int))

    num_is_num = falses(26)      
    num_is_num[12:14] .= true     

    addconstraint!(grammar, Forbidden(RuleNode(equals, [DomainRuleNode(num_is_num),DomainRuleNode(num_is_num)])))

    addconstraint!(grammar, Forbidden(RuleNode(ifstr, [RuleNode(tru), VarNode(:A), VarNode(:B)]))) # if true then A else B
    addconstraint!(grammar, Forbidden(RuleNode(ifstr, [RuleNode(fls), VarNode(:A), VarNode(:B)]))) # if false then A else B
    addconstraint!(grammar, Forbidden(RuleNode(ifnum, [RuleNode(tru), VarNode(:A), VarNode(:B)]))) # if true then A else B
    addconstraint!(grammar, Forbidden(RuleNode(ifnum, [RuleNode(fls), VarNode(:A), VarNode(:B)]))) # if false then A else B
    
    
    addconstraint!(grammar, Forbidden(RuleNode(len, [RuleNode(space)]))) 
    addconstraint!(grammar, Forbidden(RuleNode(len, [RuleNode(empty)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(replace, [RuleNode(space), VarNode(:A), VarNode(:B)]))) 
    addconstraint!(grammar, Forbidden(RuleNode(replace, [RuleNode(empty), VarNode(:A), VarNode(:B)]))) 
    
    addconstraint!(grammar, Forbidden(RuleNode(substr, [RuleNode(space), VarNode(:A), VarNode(:B)]))) 
    addconstraint!(grammar, Forbidden(RuleNode(substr, [RuleNode(empty), VarNode(:A), VarNode(:B)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(prefixof, [VarNode(:A), RuleNode(space)]))) 
    addconstraint!(grammar, Forbidden(RuleNode(prefixof, [VarNode(:A), RuleNode(empty)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(suffixof, [VarNode(:A), RuleNode(space)]))) 
    addconstraint!(grammar, Forbidden(RuleNode(suffixof, [VarNode(:A), RuleNode(empty)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(contains, [RuleNode(space), VarNode(:A)]))) 
    addconstraint!(grammar, Forbidden(RuleNode(contains, [RuleNode(empty), VarNode(:A)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(indexof, [RuleNode(space), VarNode(:A), VarNode(:B)]))) 
    addconstraint!(grammar, Forbidden(RuleNode(indexof, [RuleNode(empty), VarNode(:A), VarNode(:B)]))) 

    addconstraint!(grammar, Ordered(RuleNode(equals, [VarNode(:a), VarNode(:b)]), [:a, :b]))
end

function add_constraints_clean_and_reformat_telephone_numbers!(grammar)
    arg1 = 2
    empty = 3
    space = 4
    comma = 5
    dash = 6
    dot = 7
    small = 8
    big = 9
    concat = 10
    replace = 11
    at = 12
    intstr = 13
    ifstr = 14
    substr = 15
    one = 16
    zero = 17
    mone = 18
    plus = 19
    minus = 20
    len = 21
    strint = 22
    ifnum = 23
    indexof = 24
    tru = 25
    fls = 26
    equals = 27
    prefixof = 28
    suffixof = 29
    contains = 30

    addconstraint!(grammar, Forbidden(RuleNode(concat, [VarNode(:A), RuleNode(empty)]))) # A + ""
    addconstraint!(grammar, Forbidden(RuleNode(concat, [RuleNode(empty), VarNode(:A)]))) # "" + A

    addconstraint!(grammar, Forbidden(RuleNode(replace, [VarNode(:A), VarNode(:B), VarNode(:B)]))) # A.replace(B, B)
    
    addconstraint!(grammar, Forbidden(RuleNode(strint, [RuleNode(intstr, [VarNode(:A)])]))) # str(int(A))
    addconstraint!(grammar, Forbidden(RuleNode(intstr, [RuleNode(strint, [VarNode(:A)])]))) # int(str(A))

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

    addconstraint!(grammar, Unique(contains))
    addconstraint!(grammar, Unique(suffixof))
    addconstraint!(grammar, Unique(prefixof))

    addconstraint!(grammar, Forbidden(RuleNode(len, [RuleNode(intstr, [VarNode(:A)])]))) # len(str(A::Int))

    num_is_num = falses(30)      
    num_is_num[16:18] .= true     

    addconstraint!(grammar, Forbidden(RuleNode(equals, [DomainRuleNode(num_is_num),DomainRuleNode(num_is_num)])))

    addconstraint!(grammar, Forbidden(RuleNode(ifstr, [RuleNode(tru), VarNode(:A), VarNode(:B)]))) # if true then A else B
    addconstraint!(grammar, Forbidden(RuleNode(ifstr, [RuleNode(fls), VarNode(:A), VarNode(:B)]))) # if false then A else B
    addconstraint!(grammar, Forbidden(RuleNode(ifnum, [RuleNode(tru), VarNode(:A), VarNode(:B)]))) # if true then A else B
    addconstraint!(grammar, Forbidden(RuleNode(ifnum, [RuleNode(fls), VarNode(:A), VarNode(:B)]))) # if false then A else B
    
    strings = falses(30)      
    strings[3:9] .= true  
    
    addconstraint!(grammar, Forbidden(RuleNode(len, [DomainRuleNode(strings)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(replace, [DomainRuleNode(strings), VarNode(:A), VarNode(:B)]))) 
    
    addconstraint!(grammar, Forbidden(RuleNode(substr, [DomainRuleNode(strings), VarNode(:A), VarNode(:B)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(prefixof, [VarNode(:A), DomainRuleNode(strings)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(suffixof, [VarNode(:A), DomainRuleNode(strings)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(contains, [DomainRuleNode(strings), VarNode(:A)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(indexof, [DomainRuleNode(strings), VarNode(:A), VarNode(:B)]))) 

    addconstraint!(grammar, Ordered(RuleNode(equals, [VarNode(:a), VarNode(:b)]), [:a, :b]))
end

function add_constraints_change_negative_numbers_to_positive!(grammar)
    arg1 = 2
    empty = 3
    space = 4
    dash = 5
    concat = 6
    replace = 7
    at = 8
    intstr = 9
    ifstr = 10
    substr = 11
    one = 12
    zero = 13
    mone = 14
    plus = 15
    minus = 16
    len = 17
    strint = 18
    ifnum = 19
    indexof = 20
    tru = 21
    fls = 22
    equals = 23
    prefixof = 24
    suffixof = 25
    contains = 26

    addconstraint!(grammar, Forbidden(RuleNode(concat, [VarNode(:A), RuleNode(empty)]))) # A + ""
    addconstraint!(grammar, Forbidden(RuleNode(concat, [RuleNode(empty), VarNode(:A)]))) # "" + A

    addconstraint!(grammar, Forbidden(RuleNode(replace, [VarNode(:A), VarNode(:B), VarNode(:B)]))) # A.replace(B, B)
    
    addconstraint!(grammar, Forbidden(RuleNode(strint, [RuleNode(intstr, [VarNode(:A)])]))) # str(int(A))
    addconstraint!(grammar, Forbidden(RuleNode(intstr, [RuleNode(strint, [VarNode(:A)])]))) # int(str(A))

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

    addconstraint!(grammar, Unique(contains))
    addconstraint!(grammar, Unique(suffixof))
    addconstraint!(grammar, Unique(prefixof))

    addconstraint!(grammar, Forbidden(RuleNode(len, [RuleNode(intstr, [VarNode(:A)])]))) # len(str(A::Int))

    num_is_num = falses(26)      
    num_is_num[12:14] .= true     

    addconstraint!(grammar, Forbidden(RuleNode(equals, [DomainRuleNode(num_is_num),DomainRuleNode(num_is_num)])))

    addconstraint!(grammar, Forbidden(RuleNode(ifstr, [RuleNode(tru), VarNode(:A), VarNode(:B)]))) # if true then A else B
    addconstraint!(grammar, Forbidden(RuleNode(ifstr, [RuleNode(fls), VarNode(:A), VarNode(:B)]))) # if false then A else B
    addconstraint!(grammar, Forbidden(RuleNode(ifnum, [RuleNode(tru), VarNode(:A), VarNode(:B)]))) # if true then A else B
    addconstraint!(grammar, Forbidden(RuleNode(ifnum, [RuleNode(fls), VarNode(:A), VarNode(:B)]))) # if false then A else B
    
    strings = falses(26)      
    strings[3:5] .= true  
    
    addconstraint!(grammar, Forbidden(RuleNode(len, [DomainRuleNode(strings)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(replace, [DomainRuleNode(strings), VarNode(:A), VarNode(:B)]))) 
    
    addconstraint!(grammar, Forbidden(RuleNode(substr, [DomainRuleNode(strings), VarNode(:A), VarNode(:B)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(prefixof, [VarNode(:A), DomainRuleNode(strings)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(suffixof, [VarNode(:A), DomainRuleNode(strings)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(contains, [DomainRuleNode(strings), VarNode(:A)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(indexof, [DomainRuleNode(strings), VarNode(:A), VarNode(:B)]))) 

    addconstraint!(grammar, Ordered(RuleNode(equals, [VarNode(:a), VarNode(:b)]), [:a, :b]))
end

function add_constraints_replace_one_character_with_another!(grammar)
    arg1 = 2
    empty = 3
    space = 4
    dash = 5
    concat = 6
    replace = 7
    at = 8
    intstr = 9
    ifstr = 10
    substr = 11
    one = 12
    zero = 13
    mone = 14
    plus = 15
    minus = 16
    len = 17
    strint = 18
    ifnum = 19
    indexof = 20
    tru = 21
    fls = 22
    equals = 23
    prefixof = 24
    suffixof = 25
    contains = 26

    addconstraint!(grammar, Forbidden(RuleNode(concat, [VarNode(:A), RuleNode(empty)]))) # A + ""
    addconstraint!(grammar, Forbidden(RuleNode(concat, [RuleNode(empty), VarNode(:A)]))) # "" + A

    addconstraint!(grammar, Forbidden(RuleNode(replace, [VarNode(:A), VarNode(:B), VarNode(:B)]))) # A.replace(B, B)
    
    addconstraint!(grammar, Forbidden(RuleNode(strint, [RuleNode(intstr, [VarNode(:A)])]))) # str(int(A))
    addconstraint!(grammar, Forbidden(RuleNode(intstr, [RuleNode(strint, [VarNode(:A)])]))) # int(str(A))

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

    addconstraint!(grammar, Unique(contains))
    addconstraint!(grammar, Unique(suffixof))
    addconstraint!(grammar, Unique(prefixof))

    addconstraint!(grammar, Forbidden(RuleNode(len, [RuleNode(intstr, [VarNode(:A)])]))) # len(str(A::Int))

    num_is_num = falses(26)      
    num_is_num[12:14] .= true     

    addconstraint!(grammar, Forbidden(RuleNode(equals, [DomainRuleNode(num_is_num),DomainRuleNode(num_is_num)])))

    addconstraint!(grammar, Forbidden(RuleNode(ifstr, [RuleNode(tru), VarNode(:A), VarNode(:B)]))) # if true then A else B
    addconstraint!(grammar, Forbidden(RuleNode(ifstr, [RuleNode(fls), VarNode(:A), VarNode(:B)]))) # if false then A else B
    addconstraint!(grammar, Forbidden(RuleNode(ifnum, [RuleNode(tru), VarNode(:A), VarNode(:B)]))) # if true then A else B
    addconstraint!(grammar, Forbidden(RuleNode(ifnum, [RuleNode(fls), VarNode(:A), VarNode(:B)]))) # if false then A else B
    
    strings = falses(26)      
    strings[3:5] .= true  
    
    addconstraint!(grammar, Forbidden(RuleNode(len, [DomainRuleNode(strings)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(replace, [DomainRuleNode(strings), VarNode(:A), VarNode(:B)]))) 
    
    addconstraint!(grammar, Forbidden(RuleNode(substr, [DomainRuleNode(strings), VarNode(:A), VarNode(:B)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(prefixof, [VarNode(:A), DomainRuleNode(strings)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(suffixof, [VarNode(:A), DomainRuleNode(strings)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(contains, [DomainRuleNode(strings), VarNode(:A)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(indexof, [DomainRuleNode(strings), VarNode(:A), VarNode(:B)]))) 

    addconstraint!(grammar, Ordered(RuleNode(equals, [VarNode(:a), VarNode(:b)]), [:a, :b]))
end

function add_constraints_remove_text_by_matching!(grammar)
    arg1 = 2
    empty = 3
    space = 4
    dash = 5
    concat = 6
    replace = 7
    at = 8
    intstr = 9
    ifstr = 10
    substr = 11
    one = 12
    zero = 13
    mone = 14
    plus = 15
    minus = 16
    len = 17
    strint = 18
    ifnum = 19
    indexof = 20
    tru = 21
    fls = 22
    equals = 23
    prefixof = 24
    suffixof = 25
    contains = 26

    addconstraint!(grammar, Forbidden(RuleNode(concat, [VarNode(:A), RuleNode(empty)]))) # A + ""
    addconstraint!(grammar, Forbidden(RuleNode(concat, [RuleNode(empty), VarNode(:A)]))) # "" + A

    addconstraint!(grammar, Forbidden(RuleNode(replace, [VarNode(:A), VarNode(:B), VarNode(:B)]))) # A.replace(B, B)
    
    addconstraint!(grammar, Forbidden(RuleNode(strint, [RuleNode(intstr, [VarNode(:A)])]))) # str(int(A))
    addconstraint!(grammar, Forbidden(RuleNode(intstr, [RuleNode(strint, [VarNode(:A)])]))) # int(str(A))

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

    addconstraint!(grammar, Unique(contains))
    addconstraint!(grammar, Unique(suffixof))
    addconstraint!(grammar, Unique(prefixof))

    addconstraint!(grammar, Forbidden(RuleNode(len, [RuleNode(intstr, [VarNode(:A)])]))) # len(str(A::Int))

    num_is_num = falses(26)      
    num_is_num[12:14] .= true     

    addconstraint!(grammar, Forbidden(RuleNode(equals, [DomainRuleNode(num_is_num),DomainRuleNode(num_is_num)])))

    addconstraint!(grammar, Forbidden(RuleNode(ifstr, [RuleNode(tru), VarNode(:A), VarNode(:B)]))) # if true then A else B
    addconstraint!(grammar, Forbidden(RuleNode(ifstr, [RuleNode(fls), VarNode(:A), VarNode(:B)]))) # if false then A else B
    addconstraint!(grammar, Forbidden(RuleNode(ifnum, [RuleNode(tru), VarNode(:A), VarNode(:B)]))) # if true then A else B
    addconstraint!(grammar, Forbidden(RuleNode(ifnum, [RuleNode(fls), VarNode(:A), VarNode(:B)]))) # if false then A else B
    
    strings = falses(26)      
    strings[3:5] .= true  
    
    addconstraint!(grammar, Forbidden(RuleNode(len, [DomainRuleNode(strings)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(replace, [DomainRuleNode(strings), VarNode(:A), VarNode(:B)]))) 
    
    addconstraint!(grammar, Forbidden(RuleNode(substr, [DomainRuleNode(strings), VarNode(:A), VarNode(:B)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(prefixof, [VarNode(:A), DomainRuleNode(strings)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(suffixof, [VarNode(:A), DomainRuleNode(strings)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(contains, [DomainRuleNode(strings), VarNode(:A)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(indexof, [DomainRuleNode(strings), VarNode(:A), VarNode(:B)]))) 

    addconstraint!(grammar, Ordered(RuleNode(equals, [VarNode(:a), VarNode(:b)]), [:a, :b]))
end

function add_constraints_get_last_name_from_name_with_comma!(grammar)
    arg1 = 2
    empty = 3
    space = 4
    comma = 5
    concat = 6
    replace = 7
    at = 8
    intstr = 9
    ifstr = 10
    substr = 11
    one = 12
    zero = 13
    mone = 14
    plus = 15
    minus = 16
    len = 17
    strint = 18
    ifnum = 19
    indexof = 20
    tru = 21
    fls = 22
    equals = 23
    prefixof = 24
    suffixof = 25
    contains = 26

    addconstraint!(grammar, Forbidden(RuleNode(concat, [VarNode(:A), RuleNode(empty)]))) # A + ""
    addconstraint!(grammar, Forbidden(RuleNode(concat, [RuleNode(empty), VarNode(:A)]))) # "" + A

    addconstraint!(grammar, Forbidden(RuleNode(replace, [VarNode(:A), VarNode(:B), VarNode(:B)]))) # A.replace(B, B)
    
    addconstraint!(grammar, Forbidden(RuleNode(strint, [RuleNode(intstr, [VarNode(:A)])]))) # str(int(A))
    addconstraint!(grammar, Forbidden(RuleNode(intstr, [RuleNode(strint, [VarNode(:A)])]))) # int(str(A))

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

    addconstraint!(grammar, Unique(contains))
    addconstraint!(grammar, Unique(suffixof))
    addconstraint!(grammar, Unique(prefixof))

    addconstraint!(grammar, Forbidden(RuleNode(len, [RuleNode(intstr, [VarNode(:A)])]))) # len(str(A::Int))

    num_is_num = falses(26)      
    num_is_num[12:14] .= true     

    addconstraint!(grammar, Forbidden(RuleNode(equals, [DomainRuleNode(num_is_num),DomainRuleNode(num_is_num)])))

    addconstraint!(grammar, Forbidden(RuleNode(ifstr, [RuleNode(tru), VarNode(:A), VarNode(:B)]))) # if true then A else B
    addconstraint!(grammar, Forbidden(RuleNode(ifstr, [RuleNode(fls), VarNode(:A), VarNode(:B)]))) # if false then A else B
    addconstraint!(grammar, Forbidden(RuleNode(ifnum, [RuleNode(tru), VarNode(:A), VarNode(:B)]))) # if true then A else B
    addconstraint!(grammar, Forbidden(RuleNode(ifnum, [RuleNode(fls), VarNode(:A), VarNode(:B)]))) # if false then A else B
    
    strings = falses(26)      
    strings[3:5] .= true  
    
    addconstraint!(grammar, Forbidden(RuleNode(len, [DomainRuleNode(strings)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(replace, [DomainRuleNode(strings), VarNode(:A), VarNode(:B)]))) 
    
    addconstraint!(grammar, Forbidden(RuleNode(substr, [DomainRuleNode(strings), VarNode(:A), VarNode(:B)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(prefixof, [VarNode(:A), DomainRuleNode(strings)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(suffixof, [VarNode(:A), DomainRuleNode(strings)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(contains, [DomainRuleNode(strings), VarNode(:A)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(indexof, [DomainRuleNode(strings), VarNode(:A), VarNode(:B)]))) 

    addconstraint!(grammar, Ordered(RuleNode(equals, [VarNode(:a), VarNode(:b)]), [:a, :b]))
end

function add_constraints_cell_contains_some_words_but_not_others!(grammar)
    arg1 = 2
    arg2 = 3
    arg3 = 4
    arg4 = 5
    empty = 6
    space = 7
    concat = 8
    replace = 9
    at = 10
    intstr = 11
    ifstr = 12
    substr = 13
    one = 14
    zero = 15
    mone = 16
    plus = 17
    minus = 18
    len = 19
    strint = 20
    ifnum = 21
    indexof = 22
    tru = 23
    fls = 24
    equals = 25
    prefixof = 26
    suffixof = 27
    contains = 28

    addconstraint!(grammar, Forbidden(RuleNode(concat, [VarNode(:A), RuleNode(empty)]))) # A + ""
    addconstraint!(grammar, Forbidden(RuleNode(concat, [RuleNode(empty), VarNode(:A)]))) # "" + A

    addconstraint!(grammar, Forbidden(RuleNode(replace, [VarNode(:A), VarNode(:B), VarNode(:B)]))) # A.replace(B, B)
    
    addconstraint!(grammar, Forbidden(RuleNode(strint, [RuleNode(intstr, [VarNode(:A)])]))) # str(int(A))
    addconstraint!(grammar, Forbidden(RuleNode(intstr, [RuleNode(strint, [VarNode(:A)])]))) # int(str(A))

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

    addconstraint!(grammar, Unique(contains))
    addconstraint!(grammar, Unique(suffixof))
    addconstraint!(grammar, Unique(prefixof))

    addconstraint!(grammar, Forbidden(RuleNode(len, [RuleNode(intstr, [VarNode(:A)])]))) # len(str(A::Int))

    num_is_num = falses(28)      
    num_is_num[14:16] .= true     

    addconstraint!(grammar, Forbidden(RuleNode(equals, [DomainRuleNode(num_is_num),DomainRuleNode(num_is_num)])))

    addconstraint!(grammar, Forbidden(RuleNode(ifstr, [RuleNode(tru), VarNode(:A), VarNode(:B)]))) # if true then A else B
    addconstraint!(grammar, Forbidden(RuleNode(ifstr, [RuleNode(fls), VarNode(:A), VarNode(:B)]))) # if false then A else B
    addconstraint!(grammar, Forbidden(RuleNode(ifnum, [RuleNode(tru), VarNode(:A), VarNode(:B)]))) # if true then A else B
    addconstraint!(grammar, Forbidden(RuleNode(ifnum, [RuleNode(fls), VarNode(:A), VarNode(:B)]))) # if false then A else B
    
    strings = falses(28)      
    strings[6:7] .= true  
    
    addconstraint!(grammar, Forbidden(RuleNode(len, [DomainRuleNode(strings)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(replace, [DomainRuleNode(strings), VarNode(:A), VarNode(:B)]))) 
    
    addconstraint!(grammar, Forbidden(RuleNode(substr, [DomainRuleNode(strings), VarNode(:A), VarNode(:B)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(prefixof, [VarNode(:A), DomainRuleNode(strings)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(suffixof, [VarNode(:A), DomainRuleNode(strings)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(contains, [DomainRuleNode(strings), VarNode(:A)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(indexof, [DomainRuleNode(strings), VarNode(:A), VarNode(:B)]))) 

    addconstraint!(grammar, Ordered(RuleNode(equals, [VarNode(:a), VarNode(:b)]), [:a, :b]))
end

function add_constraints_cell_contains_specific_text!(grammar)
    arg1 = 2
    arg2 = 3
    empty = 4
    space = 5
    concat = 6
    replace = 7
    at = 8
    intstr = 9
    ifstr = 10
    substr = 11
    one = 12
    zero = 13
    mone = 14
    plus = 15
    minus = 16
    len = 17
    strint = 18
    ifnum = 19
    indexof = 20
    tru = 21
    fls = 22
    equals = 23
    prefixof = 24
    suffixof = 25
    contains = 26

    addconstraint!(grammar, Forbidden(RuleNode(concat, [VarNode(:A), RuleNode(empty)]))) # A + ""
    addconstraint!(grammar, Forbidden(RuleNode(concat, [RuleNode(empty), VarNode(:A)]))) # "" + A

    addconstraint!(grammar, Forbidden(RuleNode(replace, [VarNode(:A), VarNode(:B), VarNode(:B)]))) # A.replace(B, B)
    
    addconstraint!(grammar, Forbidden(RuleNode(strint, [RuleNode(intstr, [VarNode(:A)])]))) # str(int(A))
    addconstraint!(grammar, Forbidden(RuleNode(intstr, [RuleNode(strint, [VarNode(:A)])]))) # int(str(A))

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

    addconstraint!(grammar, Unique(contains))
    addconstraint!(grammar, Unique(suffixof))
    addconstraint!(grammar, Unique(prefixof))

    addconstraint!(grammar, Forbidden(RuleNode(len, [RuleNode(intstr, [VarNode(:A)])]))) # len(str(A::Int))

    num_is_num = falses(26)      
    num_is_num[12:14] .= true     

    addconstraint!(grammar, Forbidden(RuleNode(equals, [DomainRuleNode(num_is_num),DomainRuleNode(num_is_num)])))

    addconstraint!(grammar, Forbidden(RuleNode(ifstr, [RuleNode(tru), VarNode(:A), VarNode(:B)]))) # if true then A else B
    addconstraint!(grammar, Forbidden(RuleNode(ifstr, [RuleNode(fls), VarNode(:A), VarNode(:B)]))) # if false then A else B
    addconstraint!(grammar, Forbidden(RuleNode(ifnum, [RuleNode(tru), VarNode(:A), VarNode(:B)]))) # if true then A else B
    addconstraint!(grammar, Forbidden(RuleNode(ifnum, [RuleNode(fls), VarNode(:A), VarNode(:B)]))) # if false then A else B
    
    strings = falses(26)      
    strings[4:5] .= true  
    
    addconstraint!(grammar, Forbidden(RuleNode(len, [DomainRuleNode(strings)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(replace, [DomainRuleNode(strings), VarNode(:A), VarNode(:B)]))) 
    
    addconstraint!(grammar, Forbidden(RuleNode(substr, [DomainRuleNode(strings), VarNode(:A), VarNode(:B)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(prefixof, [VarNode(:A), DomainRuleNode(strings)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(suffixof, [VarNode(:A), DomainRuleNode(strings)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(contains, [DomainRuleNode(strings), VarNode(:A)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(indexof, [DomainRuleNode(strings), VarNode(:A), VarNode(:B)]))) 

    addconstraint!(grammar, Ordered(RuleNode(equals, [VarNode(:a), VarNode(:b)]), [:a, :b]))
end

function add_constraints_remove_unwanted_characters!(grammar)
    arg1 = 2
    arg2 = 3
    empty = 4
    space = 5
    concat = 6
    replace = 7
    at = 8
    intstr = 9
    ifstr = 10
    substr = 11
    one = 12
    zero = 13
    mone = 14
    plus = 15
    minus = 16
    len = 17
    strint = 18
    ifnum = 19
    indexof = 20
    tru = 21
    fls = 22
    equals = 23
    prefixof = 24
    suffixof = 25
    contains = 26

    addconstraint!(grammar, Forbidden(RuleNode(concat, [VarNode(:A), RuleNode(empty)]))) # A + ""
    addconstraint!(grammar, Forbidden(RuleNode(concat, [RuleNode(empty), VarNode(:A)]))) # "" + A

    addconstraint!(grammar, Forbidden(RuleNode(replace, [VarNode(:A), VarNode(:B), VarNode(:B)]))) # A.replace(B, B)
    
    addconstraint!(grammar, Forbidden(RuleNode(strint, [RuleNode(intstr, [VarNode(:A)])]))) # str(int(A))
    addconstraint!(grammar, Forbidden(RuleNode(intstr, [RuleNode(strint, [VarNode(:A)])]))) # int(str(A))

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

    addconstraint!(grammar, Unique(contains))
    addconstraint!(grammar, Unique(suffixof))
    addconstraint!(grammar, Unique(prefixof))

    addconstraint!(grammar, Forbidden(RuleNode(len, [RuleNode(intstr, [VarNode(:A)])]))) # len(str(A::Int))

    num_is_num = falses(26)      
    num_is_num[12:14] .= true     

    addconstraint!(grammar, Forbidden(RuleNode(equals, [DomainRuleNode(num_is_num),DomainRuleNode(num_is_num)])))

    addconstraint!(grammar, Forbidden(RuleNode(ifstr, [RuleNode(tru), VarNode(:A), VarNode(:B)]))) # if true then A else B
    addconstraint!(grammar, Forbidden(RuleNode(ifstr, [RuleNode(fls), VarNode(:A), VarNode(:B)]))) # if false then A else B
    addconstraint!(grammar, Forbidden(RuleNode(ifnum, [RuleNode(tru), VarNode(:A), VarNode(:B)]))) # if true then A else B
    addconstraint!(grammar, Forbidden(RuleNode(ifnum, [RuleNode(fls), VarNode(:A), VarNode(:B)]))) # if false then A else B
    
    strings = falses(26)      
    strings[4:5] .= true  
    
    addconstraint!(grammar, Forbidden(RuleNode(len, [DomainRuleNode(strings)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(replace, [DomainRuleNode(strings), VarNode(:A), VarNode(:B)]))) 
    
    addconstraint!(grammar, Forbidden(RuleNode(substr, [DomainRuleNode(strings), VarNode(:A), VarNode(:B)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(prefixof, [VarNode(:A), DomainRuleNode(strings)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(suffixof, [VarNode(:A), DomainRuleNode(strings)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(contains, [DomainRuleNode(strings), VarNode(:A)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(indexof, [DomainRuleNode(strings), VarNode(:A), VarNode(:B)]))) 

    addconstraint!(grammar, Ordered(RuleNode(equals, [VarNode(:a), VarNode(:b)]), [:a, :b]))
end

function add_constraints_37281007!(grammar)
    arg1 = 2
    arg2 = 3
    empty = 4
    space = 5
    concat = 6
    replace = 7
    at = 8
    intstr = 9
    ifstr = 10
    substr = 11
    one = 12
    zero = 13
    mone = 14
    plus = 15
    minus = 16
    len = 17
    strint = 18
    ifnum = 19
    indexof = 20
    tru = 21
    fls = 22
    equals = 23
    prefixof = 24
    suffixof = 25
    contains = 26

    addconstraint!(grammar, Forbidden(RuleNode(concat, [VarNode(:A), RuleNode(empty)]))) # A + ""
    addconstraint!(grammar, Forbidden(RuleNode(concat, [RuleNode(empty), VarNode(:A)]))) # "" + A

    addconstraint!(grammar, Forbidden(RuleNode(replace, [VarNode(:A), VarNode(:B), VarNode(:B)]))) # A.replace(B, B)
    
    addconstraint!(grammar, Forbidden(RuleNode(strint, [RuleNode(intstr, [VarNode(:A)])]))) # str(int(A))
    addconstraint!(grammar, Forbidden(RuleNode(intstr, [RuleNode(strint, [VarNode(:A)])]))) # int(str(A))

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

    addconstraint!(grammar, Unique(contains))
    addconstraint!(grammar, Unique(suffixof))
    addconstraint!(grammar, Unique(prefixof))

    addconstraint!(grammar, Forbidden(RuleNode(len, [RuleNode(intstr, [VarNode(:A)])]))) # len(str(A::Int))

    num_is_num = falses(26)      
    num_is_num[12:14] .= true     

    addconstraint!(grammar, Forbidden(RuleNode(equals, [DomainRuleNode(num_is_num),DomainRuleNode(num_is_num)])))

    addconstraint!(grammar, Forbidden(RuleNode(ifstr, [RuleNode(tru), VarNode(:A), VarNode(:B)]))) # if true then A else B
    addconstraint!(grammar, Forbidden(RuleNode(ifstr, [RuleNode(fls), VarNode(:A), VarNode(:B)]))) # if false then A else B
    addconstraint!(grammar, Forbidden(RuleNode(ifnum, [RuleNode(tru), VarNode(:A), VarNode(:B)]))) # if true then A else B
    addconstraint!(grammar, Forbidden(RuleNode(ifnum, [RuleNode(fls), VarNode(:A), VarNode(:B)]))) # if false then A else B
    
    strings = falses(26)      
    strings[4:5] .= true  
    
    addconstraint!(grammar, Forbidden(RuleNode(len, [DomainRuleNode(strings)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(replace, [DomainRuleNode(strings), VarNode(:A), VarNode(:B)]))) 
    
    addconstraint!(grammar, Forbidden(RuleNode(substr, [DomainRuleNode(strings), VarNode(:A), VarNode(:B)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(prefixof, [VarNode(:A), DomainRuleNode(strings)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(suffixof, [VarNode(:A), DomainRuleNode(strings)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(contains, [DomainRuleNode(strings), VarNode(:A)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(indexof, [DomainRuleNode(strings), VarNode(:A), VarNode(:B)]))) 

    addconstraint!(grammar, Ordered(RuleNode(equals, [VarNode(:a), VarNode(:b)]), [:a, :b]))
end

function add_constraints_convert_numbers_to_text!(grammar)
    arg1 = 10
    empty = 2
    space = 3
    concat = 4
    replace = 5
    at = 6
    intstr = 7
    ifstr = 8
    substr = 9
    one = 11
    zero = 12
    mone = 13
    plus = 14
    minus = 15
    len = 16
    strint = 17
    ifnum = 18
    indexof = 19
    tru = 20
    fls = 21
    equals = 22
    prefixof = 23
    suffixof = 24
    contains = 25

    addconstraint!(grammar, Forbidden(RuleNode(concat, [VarNode(:A), RuleNode(empty)]))) # A + ""
    addconstraint!(grammar, Forbidden(RuleNode(concat, [RuleNode(empty), VarNode(:A)]))) # "" + A

    addconstraint!(grammar, Forbidden(RuleNode(replace, [VarNode(:A), VarNode(:B), VarNode(:B)]))) # A.replace(B, B)
    
    addconstraint!(grammar, Forbidden(RuleNode(strint, [RuleNode(intstr, [VarNode(:A)])]))) # str(int(A))
    addconstraint!(grammar, Forbidden(RuleNode(intstr, [RuleNode(strint, [VarNode(:A)])]))) # int(str(A))

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

    addconstraint!(grammar, Unique(contains))
    addconstraint!(grammar, Unique(suffixof))
    addconstraint!(grammar, Unique(prefixof))

    addconstraint!(grammar, Forbidden(RuleNode(len, [RuleNode(intstr, [VarNode(:A)])]))) # len(str(A::Int))

    num_is_num = falses(25)      
    num_is_num[11:13] .= true     

    addconstraint!(grammar, Forbidden(RuleNode(equals, [DomainRuleNode(num_is_num),DomainRuleNode(num_is_num)])))

    addconstraint!(grammar, Forbidden(RuleNode(ifstr, [RuleNode(tru), VarNode(:A), VarNode(:B)]))) # if true then A else B
    addconstraint!(grammar, Forbidden(RuleNode(ifstr, [RuleNode(fls), VarNode(:A), VarNode(:B)]))) # if false then A else B
    addconstraint!(grammar, Forbidden(RuleNode(ifnum, [RuleNode(tru), VarNode(:A), VarNode(:B)]))) # if true then A else B
    addconstraint!(grammar, Forbidden(RuleNode(ifnum, [RuleNode(fls), VarNode(:A), VarNode(:B)]))) # if false then A else B
    
    
    addconstraint!(grammar, Forbidden(RuleNode(len, [RuleNode(space)]))) 
    addconstraint!(grammar, Forbidden(RuleNode(len, [RuleNode(empty)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(replace, [RuleNode(space), VarNode(:A), VarNode(:B)]))) 
    addconstraint!(grammar, Forbidden(RuleNode(replace, [RuleNode(empty), VarNode(:A), VarNode(:B)]))) 
    
    addconstraint!(grammar, Forbidden(RuleNode(substr, [RuleNode(space), VarNode(:A), VarNode(:B)]))) 
    addconstraint!(grammar, Forbidden(RuleNode(substr, [RuleNode(empty), VarNode(:A), VarNode(:B)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(prefixof, [VarNode(:A), RuleNode(space)]))) 
    addconstraint!(grammar, Forbidden(RuleNode(prefixof, [VarNode(:A), RuleNode(empty)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(suffixof, [VarNode(:A), RuleNode(space)]))) 
    addconstraint!(grammar, Forbidden(RuleNode(suffixof, [VarNode(:A), RuleNode(empty)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(contains, [RuleNode(space), VarNode(:A)]))) 
    addconstraint!(grammar, Forbidden(RuleNode(contains, [RuleNode(empty), VarNode(:A)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(indexof, [RuleNode(space), VarNode(:A), VarNode(:B)]))) 
    addconstraint!(grammar, Forbidden(RuleNode(indexof, [RuleNode(empty), VarNode(:A), VarNode(:B)]))) 

    addconstraint!(grammar, Ordered(RuleNode(equals, [VarNode(:a), VarNode(:b)]), [:a, :b]))
end

function add_constraints_convert_text_to_numbers!(grammar)
    arg1 = 2
    empty = 3
    space = 4
    concat = 5
    replace = 6
    at = 7
    intstr = 8
    ifstr = 9
    substr = 10
    one = 11
    zero = 12
    mone = 13
    plus = 14
    minus = 15
    len = 16
    strint = 17
    ifnum = 18
    indexof = 19
    tru = 20
    fls = 21
    equals = 22
    prefixof = 23
    suffixof = 24
    contains = 25

    addconstraint!(grammar, Forbidden(RuleNode(concat, [VarNode(:A), RuleNode(empty)]))) # A + ""
    addconstraint!(grammar, Forbidden(RuleNode(concat, [RuleNode(empty), VarNode(:A)]))) # "" + A

    addconstraint!(grammar, Forbidden(RuleNode(replace, [VarNode(:A), VarNode(:B), VarNode(:B)]))) # A.replace(B, B)
    
    addconstraint!(grammar, Forbidden(RuleNode(strint, [RuleNode(intstr, [VarNode(:A)])]))) # str(int(A))
    addconstraint!(grammar, Forbidden(RuleNode(intstr, [RuleNode(strint, [VarNode(:A)])]))) # int(str(A))

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

    addconstraint!(grammar, Unique(contains))
    addconstraint!(grammar, Unique(suffixof))
    addconstraint!(grammar, Unique(prefixof))

    addconstraint!(grammar, Forbidden(RuleNode(len, [RuleNode(intstr, [VarNode(:A)])]))) # len(str(A::Int))

    num_is_num = falses(25)      
    num_is_num[11:13] .= true     

    addconstraint!(grammar, Forbidden(RuleNode(equals, [DomainRuleNode(num_is_num),DomainRuleNode(num_is_num)])))

    addconstraint!(grammar, Forbidden(RuleNode(ifstr, [RuleNode(tru), VarNode(:A), VarNode(:B)]))) # if true then A else B
    addconstraint!(grammar, Forbidden(RuleNode(ifstr, [RuleNode(fls), VarNode(:A), VarNode(:B)]))) # if false then A else B
    addconstraint!(grammar, Forbidden(RuleNode(ifnum, [RuleNode(tru), VarNode(:A), VarNode(:B)]))) # if true then A else B
    addconstraint!(grammar, Forbidden(RuleNode(ifnum, [RuleNode(fls), VarNode(:A), VarNode(:B)]))) # if false then A else B
    
    
    addconstraint!(grammar, Forbidden(RuleNode(len, [RuleNode(space)]))) 
    addconstraint!(grammar, Forbidden(RuleNode(len, [RuleNode(empty)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(replace, [RuleNode(space), VarNode(:A), VarNode(:B)]))) 
    addconstraint!(grammar, Forbidden(RuleNode(replace, [RuleNode(empty), VarNode(:A), VarNode(:B)]))) 
    
    addconstraint!(grammar, Forbidden(RuleNode(substr, [RuleNode(space), VarNode(:A), VarNode(:B)]))) 
    addconstraint!(grammar, Forbidden(RuleNode(substr, [RuleNode(empty), VarNode(:A), VarNode(:B)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(prefixof, [VarNode(:A), RuleNode(space)]))) 
    addconstraint!(grammar, Forbidden(RuleNode(prefixof, [VarNode(:A), RuleNode(empty)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(suffixof, [VarNode(:A), RuleNode(space)]))) 
    addconstraint!(grammar, Forbidden(RuleNode(suffixof, [VarNode(:A), RuleNode(empty)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(contains, [RuleNode(space), VarNode(:A)]))) 
    addconstraint!(grammar, Forbidden(RuleNode(contains, [RuleNode(empty), VarNode(:A)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(indexof, [RuleNode(space), VarNode(:A), VarNode(:B)]))) 
    addconstraint!(grammar, Forbidden(RuleNode(indexof, [RuleNode(empty), VarNode(:A), VarNode(:B)]))) 

    addconstraint!(grammar, Ordered(RuleNode(equals, [VarNode(:a), VarNode(:b)]), [:a, :b]))
end

function add_constraints_get_last_name_from_name!(grammar)
    arg1 = 2
    empty = 3
    space = 4
    concat = 5
    replace = 6
    at = 7
    intstr = 8
    ifstr = 9
    substr = 10
    one = 11
    zero = 12
    mone = 13
    plus = 14
    minus = 15
    len = 16
    strint = 17
    ifnum = 18
    indexof = 19
    tru = 20
    fls = 21
    equals = 22
    prefixof = 23
    suffixof = 24
    contains = 25

    addconstraint!(grammar, Forbidden(RuleNode(concat, [VarNode(:A), RuleNode(empty)]))) # A + ""
    addconstraint!(grammar, Forbidden(RuleNode(concat, [RuleNode(empty), VarNode(:A)]))) # "" + A

    addconstraint!(grammar, Forbidden(RuleNode(replace, [VarNode(:A), VarNode(:B), VarNode(:B)]))) # A.replace(B, B)
    
    addconstraint!(grammar, Forbidden(RuleNode(strint, [RuleNode(intstr, [VarNode(:A)])]))) # str(int(A))
    addconstraint!(grammar, Forbidden(RuleNode(intstr, [RuleNode(strint, [VarNode(:A)])]))) # int(str(A))

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

    addconstraint!(grammar, Unique(contains))
    addconstraint!(grammar, Unique(suffixof))
    addconstraint!(grammar, Unique(prefixof))

    addconstraint!(grammar, Forbidden(RuleNode(len, [RuleNode(intstr, [VarNode(:A)])]))) # len(str(A::Int))

    num_is_num = falses(25)      
    num_is_num[11:13] .= true     

    addconstraint!(grammar, Forbidden(RuleNode(equals, [DomainRuleNode(num_is_num),DomainRuleNode(num_is_num)])))

    addconstraint!(grammar, Forbidden(RuleNode(ifstr, [RuleNode(tru), VarNode(:A), VarNode(:B)]))) # if true then A else B
    addconstraint!(grammar, Forbidden(RuleNode(ifstr, [RuleNode(fls), VarNode(:A), VarNode(:B)]))) # if false then A else B
    addconstraint!(grammar, Forbidden(RuleNode(ifnum, [RuleNode(tru), VarNode(:A), VarNode(:B)]))) # if true then A else B
    addconstraint!(grammar, Forbidden(RuleNode(ifnum, [RuleNode(fls), VarNode(:A), VarNode(:B)]))) # if false then A else B
    
    
    addconstraint!(grammar, Forbidden(RuleNode(len, [RuleNode(space)]))) 
    addconstraint!(grammar, Forbidden(RuleNode(len, [RuleNode(empty)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(replace, [RuleNode(space), VarNode(:A), VarNode(:B)]))) 
    addconstraint!(grammar, Forbidden(RuleNode(replace, [RuleNode(empty), VarNode(:A), VarNode(:B)]))) 
    
    addconstraint!(grammar, Forbidden(RuleNode(substr, [RuleNode(space), VarNode(:A), VarNode(:B)]))) 
    addconstraint!(grammar, Forbidden(RuleNode(substr, [RuleNode(empty), VarNode(:A), VarNode(:B)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(prefixof, [VarNode(:A), RuleNode(space)]))) 
    addconstraint!(grammar, Forbidden(RuleNode(prefixof, [VarNode(:A), RuleNode(empty)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(suffixof, [VarNode(:A), RuleNode(space)]))) 
    addconstraint!(grammar, Forbidden(RuleNode(suffixof, [VarNode(:A), RuleNode(empty)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(contains, [RuleNode(space), VarNode(:A)]))) 
    addconstraint!(grammar, Forbidden(RuleNode(contains, [RuleNode(empty), VarNode(:A)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(indexof, [RuleNode(space), VarNode(:A), VarNode(:B)]))) 
    addconstraint!(grammar, Forbidden(RuleNode(indexof, [RuleNode(empty), VarNode(:A), VarNode(:B)]))) 

    addconstraint!(grammar, Ordered(RuleNode(equals, [VarNode(:a), VarNode(:b)]), [:a, :b]))
end

function add_constraints_count_total_characters_in_a_cell!(grammar)
    arg1 = 2
    empty = 3
    space = 4
    concat = 5
    replace = 6
    at = 7
    intstr = 8
    ifstr = 9
    substr = 10
    one = 11
    zero = 12
    mone = 13
    plus = 14
    minus = 15
    len = 16
    strint = 17
    ifnum = 18
    indexof = 19
    tru = 20
    fls = 21
    equals = 22
    prefixof = 23
    suffixof = 24
    contains = 25

    addconstraint!(grammar, Forbidden(RuleNode(concat, [VarNode(:A), RuleNode(empty)]))) # A + ""
    addconstraint!(grammar, Forbidden(RuleNode(concat, [RuleNode(empty), VarNode(:A)]))) # "" + A

    addconstraint!(grammar, Forbidden(RuleNode(replace, [VarNode(:A), VarNode(:B), VarNode(:B)]))) # A.replace(B, B)
    
    addconstraint!(grammar, Forbidden(RuleNode(strint, [RuleNode(intstr, [VarNode(:A)])]))) # str(int(A))
    addconstraint!(grammar, Forbidden(RuleNode(intstr, [RuleNode(strint, [VarNode(:A)])]))) # int(str(A))

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

    addconstraint!(grammar, Unique(contains))
    addconstraint!(grammar, Unique(suffixof))
    addconstraint!(grammar, Unique(prefixof))

    addconstraint!(grammar, Forbidden(RuleNode(len, [RuleNode(intstr, [VarNode(:A)])]))) # len(str(A::Int))

    num_is_num = falses(25)      
    num_is_num[11:13] .= true     

    addconstraint!(grammar, Forbidden(RuleNode(equals, [DomainRuleNode(num_is_num),DomainRuleNode(num_is_num)])))

    addconstraint!(grammar, Forbidden(RuleNode(ifstr, [RuleNode(tru), VarNode(:A), VarNode(:B)]))) # if true then A else B
    addconstraint!(grammar, Forbidden(RuleNode(ifstr, [RuleNode(fls), VarNode(:A), VarNode(:B)]))) # if false then A else B
    addconstraint!(grammar, Forbidden(RuleNode(ifnum, [RuleNode(tru), VarNode(:A), VarNode(:B)]))) # if true then A else B
    addconstraint!(grammar, Forbidden(RuleNode(ifnum, [RuleNode(fls), VarNode(:A), VarNode(:B)]))) # if false then A else B
    
    
    addconstraint!(grammar, Forbidden(RuleNode(len, [RuleNode(space)]))) 
    addconstraint!(grammar, Forbidden(RuleNode(len, [RuleNode(empty)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(replace, [RuleNode(space), VarNode(:A), VarNode(:B)]))) 
    addconstraint!(grammar, Forbidden(RuleNode(replace, [RuleNode(empty), VarNode(:A), VarNode(:B)]))) 
    
    addconstraint!(grammar, Forbidden(RuleNode(substr, [RuleNode(space), VarNode(:A), VarNode(:B)]))) 
    addconstraint!(grammar, Forbidden(RuleNode(substr, [RuleNode(empty), VarNode(:A), VarNode(:B)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(prefixof, [VarNode(:A), RuleNode(space)]))) 
    addconstraint!(grammar, Forbidden(RuleNode(prefixof, [VarNode(:A), RuleNode(empty)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(suffixof, [VarNode(:A), RuleNode(space)]))) 
    addconstraint!(grammar, Forbidden(RuleNode(suffixof, [VarNode(:A), RuleNode(empty)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(contains, [RuleNode(space), VarNode(:A)]))) 
    addconstraint!(grammar, Forbidden(RuleNode(contains, [RuleNode(empty), VarNode(:A)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(indexof, [RuleNode(space), VarNode(:A), VarNode(:B)]))) 
    addconstraint!(grammar, Forbidden(RuleNode(indexof, [RuleNode(empty), VarNode(:A), VarNode(:B)]))) 

    addconstraint!(grammar, Ordered(RuleNode(equals, [VarNode(:a), VarNode(:b)]), [:a, :b]))
end

function add_constraints_split_text_string_at_specific_character!(grammar)
    arg1 = 2
    arg2 = 12
    empty = 3
    space = 4
    dash = 5
    concat = 6
    replace = 7
    at = 8
    intstr = 9
    ifstr = 10
    substr = 11
    one = 13
    zero = 14
    mone = 15
    two = 16
    plus = 17
    minus = 18
    len = 19
    strint = 20
    ifnum = 21
    indexof = 22
    tru = 23
    fls = 24
    equals = 25
    prefixof = 26
    suffixof = 27
    contains = 28

    addconstraint!(grammar, Forbidden(RuleNode(concat, [VarNode(:A), RuleNode(empty)]))) # A + ""
    addconstraint!(grammar, Forbidden(RuleNode(concat, [RuleNode(empty), VarNode(:A)]))) # "" + A

    addconstraint!(grammar, Forbidden(RuleNode(replace, [VarNode(:A), VarNode(:B), VarNode(:B)]))) # A.replace(B, B)
    
    addconstraint!(grammar, Forbidden(RuleNode(strint, [RuleNode(intstr, [VarNode(:A)])]))) # str(int(A))
    addconstraint!(grammar, Forbidden(RuleNode(intstr, [RuleNode(strint, [VarNode(:A)])]))) # int(str(A))

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

    addconstraint!(grammar, Unique(contains))
    addconstraint!(grammar, Unique(suffixof))
    addconstraint!(grammar, Unique(prefixof))

    addconstraint!(grammar, Forbidden(RuleNode(len, [RuleNode(intstr, [VarNode(:A)])]))) # len(str(A::Int))

    num_is_num = falses(28)      
    num_is_num[13:16] .= true     

    addconstraint!(grammar, Forbidden(RuleNode(equals, [DomainRuleNode(num_is_num),DomainRuleNode(num_is_num)])))

    addconstraint!(grammar, Forbidden(RuleNode(ifstr, [RuleNode(tru), VarNode(:A), VarNode(:B)]))) # if true then A else B
    addconstraint!(grammar, Forbidden(RuleNode(ifstr, [RuleNode(fls), VarNode(:A), VarNode(:B)]))) # if false then A else B
    addconstraint!(grammar, Forbidden(RuleNode(ifnum, [RuleNode(tru), VarNode(:A), VarNode(:B)]))) # if true then A else B
    addconstraint!(grammar, Forbidden(RuleNode(ifnum, [RuleNode(fls), VarNode(:A), VarNode(:B)]))) # if false then A else B
    
    strings = falses(28)      
    strings[3:5] .= true  
    
    addconstraint!(grammar, Forbidden(RuleNode(len, [DomainRuleNode(strings)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(replace, [DomainRuleNode(strings), VarNode(:A), VarNode(:B)]))) 
    
    addconstraint!(grammar, Forbidden(RuleNode(substr, [DomainRuleNode(strings), VarNode(:A), VarNode(:B)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(prefixof, [VarNode(:A), DomainRuleNode(strings)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(suffixof, [VarNode(:A), DomainRuleNode(strings)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(contains, [DomainRuleNode(strings), VarNode(:A)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(indexof, [DomainRuleNode(strings), VarNode(:A), VarNode(:B)]))) 

    addconstraint!(grammar, Ordered(RuleNode(equals, [VarNode(:a), VarNode(:b)]), [:a, :b]))
end 

function add_constraints_stackoverflow9!(grammar)
    arg1 = 2
    empty = 3
    space = 4
    concat = 5
    replace = 6
    at = 7
    intstr = 8
    ifstr = 9
    substr = 10
    one = 11
    zero = 12
    mone = 13
    plus = 14
    minus = 15
    len = 16
    strint = 17
    ifnum = 18
    indexof = 19
    tru = 20
    fls = 21
    equals = 22
    prefixof = 23
    suffixof = 24
    contains = 25

    addconstraint!(grammar, Forbidden(RuleNode(concat, [VarNode(:A), RuleNode(empty)]))) # A + ""
    addconstraint!(grammar, Forbidden(RuleNode(concat, [RuleNode(empty), VarNode(:A)]))) # "" + A

    addconstraint!(grammar, Forbidden(RuleNode(replace, [VarNode(:A), VarNode(:B), VarNode(:B)]))) # A.replace(B, B)
    
    addconstraint!(grammar, Forbidden(RuleNode(strint, [RuleNode(intstr, [VarNode(:A)])]))) # str(int(A))
    addconstraint!(grammar, Forbidden(RuleNode(intstr, [RuleNode(strint, [VarNode(:A)])]))) # int(str(A))

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

    addconstraint!(grammar, Unique(contains))
    addconstraint!(grammar, Unique(suffixof))
    addconstraint!(grammar, Unique(prefixof))

    addconstraint!(grammar, Forbidden(RuleNode(len, [RuleNode(intstr, [VarNode(:A)])]))) # len(str(A::Int))

    num_is_num = falses(25)      
    num_is_num[11:13] .= true     

    addconstraint!(grammar, Forbidden(RuleNode(equals, [DomainRuleNode(num_is_num),DomainRuleNode(num_is_num)])))

    addconstraint!(grammar, Forbidden(RuleNode(ifstr, [RuleNode(tru), VarNode(:A), VarNode(:B)]))) # if true then A else B
    addconstraint!(grammar, Forbidden(RuleNode(ifstr, [RuleNode(fls), VarNode(:A), VarNode(:B)]))) # if false then A else B
    addconstraint!(grammar, Forbidden(RuleNode(ifnum, [RuleNode(tru), VarNode(:A), VarNode(:B)]))) # if true then A else B
    addconstraint!(grammar, Forbidden(RuleNode(ifnum, [RuleNode(fls), VarNode(:A), VarNode(:B)]))) # if false then A else B
    
    
    addconstraint!(grammar, Forbidden(RuleNode(len, [RuleNode(space)]))) 
    addconstraint!(grammar, Forbidden(RuleNode(len, [RuleNode(empty)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(replace, [RuleNode(space), VarNode(:A), VarNode(:B)]))) 
    addconstraint!(grammar, Forbidden(RuleNode(replace, [RuleNode(empty), VarNode(:A), VarNode(:B)]))) 
    
    addconstraint!(grammar, Forbidden(RuleNode(substr, [RuleNode(space), VarNode(:A), VarNode(:B)]))) 
    addconstraint!(grammar, Forbidden(RuleNode(substr, [RuleNode(empty), VarNode(:A), VarNode(:B)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(prefixof, [VarNode(:A), RuleNode(space)]))) 
    addconstraint!(grammar, Forbidden(RuleNode(prefixof, [VarNode(:A), RuleNode(empty)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(suffixof, [VarNode(:A), RuleNode(space)]))) 
    addconstraint!(grammar, Forbidden(RuleNode(suffixof, [VarNode(:A), RuleNode(empty)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(contains, [RuleNode(space), VarNode(:A)]))) 
    addconstraint!(grammar, Forbidden(RuleNode(contains, [RuleNode(empty), VarNode(:A)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(indexof, [RuleNode(space), VarNode(:A), VarNode(:B)]))) 
    addconstraint!(grammar, Forbidden(RuleNode(indexof, [RuleNode(empty), VarNode(:A), VarNode(:B)]))) 

    addconstraint!(grammar, Ordered(RuleNode(equals, [VarNode(:a), VarNode(:b)]), [:a, :b]))
end

function add_constraints_join_first_and_last_name!(grammar)
    arg1 = 2
    arg2 = 3
    empty = 4
    space = 5
    concat = 6
    replace = 7
    at = 8
    intstr = 9
    ifstr = 10
    substr = 11
    one = 12
    zero = 13
    mone = 14
    plus = 15
    minus = 16
    len = 17
    strint = 18
    ifnum = 19
    indexof = 20
    tru = 21
    fls = 22
    equals = 23
    prefixof = 24
    suffixof = 25
    contains = 26

    addconstraint!(grammar, Forbidden(RuleNode(concat, [VarNode(:A), RuleNode(empty)]))) # A + ""
    addconstraint!(grammar, Forbidden(RuleNode(concat, [RuleNode(empty), VarNode(:A)]))) # "" + A

    addconstraint!(grammar, Forbidden(RuleNode(replace, [VarNode(:A), VarNode(:B), VarNode(:B)]))) # A.replace(B, B)
    
    addconstraint!(grammar, Forbidden(RuleNode(strint, [RuleNode(intstr, [VarNode(:A)])]))) # str(int(A))
    addconstraint!(grammar, Forbidden(RuleNode(intstr, [RuleNode(strint, [VarNode(:A)])]))) # int(str(A))

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

    addconstraint!(grammar, Unique(contains))
    addconstraint!(grammar, Unique(suffixof))
    addconstraint!(grammar, Unique(prefixof))

    addconstraint!(grammar, Forbidden(RuleNode(len, [RuleNode(intstr, [VarNode(:A)])]))) # len(str(A::Int))

    num_is_num = falses(26)      
    num_is_num[12:14] .= true     

    addconstraint!(grammar, Forbidden(RuleNode(equals, [DomainRuleNode(num_is_num),DomainRuleNode(num_is_num)])))

    addconstraint!(grammar, Forbidden(RuleNode(ifstr, [RuleNode(tru), VarNode(:A), VarNode(:B)]))) # if true then A else B
    addconstraint!(grammar, Forbidden(RuleNode(ifstr, [RuleNode(fls), VarNode(:A), VarNode(:B)]))) # if false then A else B
    addconstraint!(grammar, Forbidden(RuleNode(ifnum, [RuleNode(tru), VarNode(:A), VarNode(:B)]))) # if true then A else B
    addconstraint!(grammar, Forbidden(RuleNode(ifnum, [RuleNode(fls), VarNode(:A), VarNode(:B)]))) # if false then A else B
    
    
    addconstraint!(grammar, Forbidden(RuleNode(len, [RuleNode(space)]))) 
    addconstraint!(grammar, Forbidden(RuleNode(len, [RuleNode(empty)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(replace, [RuleNode(space), VarNode(:A), VarNode(:B)]))) 
    addconstraint!(grammar, Forbidden(RuleNode(replace, [RuleNode(empty), VarNode(:A), VarNode(:B)]))) 
    
    addconstraint!(grammar, Forbidden(RuleNode(substr, [RuleNode(space), VarNode(:A), VarNode(:B)]))) 
    addconstraint!(grammar, Forbidden(RuleNode(substr, [RuleNode(empty), VarNode(:A), VarNode(:B)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(prefixof, [VarNode(:A), RuleNode(space)]))) 
    addconstraint!(grammar, Forbidden(RuleNode(prefixof, [VarNode(:A), RuleNode(empty)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(suffixof, [VarNode(:A), RuleNode(space)]))) 
    addconstraint!(grammar, Forbidden(RuleNode(suffixof, [VarNode(:A), RuleNode(empty)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(contains, [RuleNode(space), VarNode(:A)]))) 
    addconstraint!(grammar, Forbidden(RuleNode(contains, [RuleNode(empty), VarNode(:A)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(indexof, [RuleNode(space), VarNode(:A), VarNode(:B)]))) 
    addconstraint!(grammar, Forbidden(RuleNode(indexof, [RuleNode(empty), VarNode(:A), VarNode(:B)]))) 

    addconstraint!(grammar, Ordered(RuleNode(equals, [VarNode(:a), VarNode(:b)]), [:a, :b]))
end

function add_constraints_remove_characters_from_right!(grammar)
    arg1 = 2
    empty = 3
    space = 4
    concat = 5
    replace = 6
    at = 7
    intstr = 8
    ifstr = 9
    substr = 10
    one = 11
    zero = 12
    mone = 13
    plus = 14
    minus = 15
    len = 16
    strint = 17
    ifnum = 18
    indexof = 19
    tru = 20
    fls = 21
    equals = 22
    prefixof = 23
    suffixof = 24
    contains = 25

    addconstraint!(grammar, Forbidden(RuleNode(concat, [VarNode(:A), RuleNode(empty)]))) # A + ""
    addconstraint!(grammar, Forbidden(RuleNode(concat, [RuleNode(empty), VarNode(:A)]))) # "" + A

    addconstraint!(grammar, Forbidden(RuleNode(replace, [VarNode(:A), VarNode(:B), VarNode(:B)]))) # A.replace(B, B)
    
    addconstraint!(grammar, Forbidden(RuleNode(strint, [RuleNode(intstr, [VarNode(:A)])]))) # str(int(A))
    addconstraint!(grammar, Forbidden(RuleNode(intstr, [RuleNode(strint, [VarNode(:A)])]))) # int(str(A))

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

    addconstraint!(grammar, Unique(contains))
    addconstraint!(grammar, Unique(suffixof))
    addconstraint!(grammar, Unique(prefixof))

    addconstraint!(grammar, Forbidden(RuleNode(len, [RuleNode(intstr, [VarNode(:A)])]))) # len(str(A::Int))

    num_is_num = falses(25)      
    num_is_num[11:13] .= true     

    addconstraint!(grammar, Forbidden(RuleNode(equals, [DomainRuleNode(num_is_num),DomainRuleNode(num_is_num)])))

    addconstraint!(grammar, Forbidden(RuleNode(ifstr, [RuleNode(tru), VarNode(:A), VarNode(:B)]))) # if true then A else B
    addconstraint!(grammar, Forbidden(RuleNode(ifstr, [RuleNode(fls), VarNode(:A), VarNode(:B)]))) # if false then A else B
    addconstraint!(grammar, Forbidden(RuleNode(ifnum, [RuleNode(tru), VarNode(:A), VarNode(:B)]))) # if true then A else B
    addconstraint!(grammar, Forbidden(RuleNode(ifnum, [RuleNode(fls), VarNode(:A), VarNode(:B)]))) # if false then A else B
    
    
    addconstraint!(grammar, Forbidden(RuleNode(len, [RuleNode(space)]))) 
    addconstraint!(grammar, Forbidden(RuleNode(len, [RuleNode(empty)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(replace, [RuleNode(space), VarNode(:A), VarNode(:B)]))) 
    addconstraint!(grammar, Forbidden(RuleNode(replace, [RuleNode(empty), VarNode(:A), VarNode(:B)]))) 
    
    addconstraint!(grammar, Forbidden(RuleNode(substr, [RuleNode(space), VarNode(:A), VarNode(:B)]))) 
    addconstraint!(grammar, Forbidden(RuleNode(substr, [RuleNode(empty), VarNode(:A), VarNode(:B)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(prefixof, [VarNode(:A), RuleNode(space)]))) 
    addconstraint!(grammar, Forbidden(RuleNode(prefixof, [VarNode(:A), RuleNode(empty)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(suffixof, [VarNode(:A), RuleNode(space)]))) 
    addconstraint!(grammar, Forbidden(RuleNode(suffixof, [VarNode(:A), RuleNode(empty)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(contains, [RuleNode(space), VarNode(:A)]))) 
    addconstraint!(grammar, Forbidden(RuleNode(contains, [RuleNode(empty), VarNode(:A)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(indexof, [RuleNode(space), VarNode(:A), VarNode(:B)]))) 
    addconstraint!(grammar, Forbidden(RuleNode(indexof, [RuleNode(empty), VarNode(:A), VarNode(:B)]))) 

    addconstraint!(grammar, Ordered(RuleNode(equals, [VarNode(:a), VarNode(:b)]), [:a, :b]))
end

function create_termset(examples, grammar, grammar_root, variables, ::Type{AllTypes}, constraints, num_solutions=1, up_to_size=3) where {AllTypes}
    
    D = Set{AllTypes}()
    println("finding small terms")
    small_terms = generate_small_terms(grammar, up_to_size, grammar_root, examples)
    println(length(small_terms))
    
    add_constraints!(grammar)
    
    println("find solutions per example")

    solutions_per_example = find_solutions_per_example(examples, grammar, grammar_root, num_solutions, variables, constraints)
    

    for solutions in values(solutions_per_example)
        union!(D, solutions)
    end

    union!(D, small_terms)

    return D, solutions_per_example
end