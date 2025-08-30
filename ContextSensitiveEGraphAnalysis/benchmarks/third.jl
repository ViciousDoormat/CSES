#using ContextSensitiveEGraphAnalysis

using ContextSensitiveEGraphAnalysis
using HerbBenchmarks
using HerbBenchmarks.SyGuS
using HerbConstraints
using HerbGrammar
using HerbSearch
using Metatheory

# CVC5 functions

## String typed
concat_cvc(str1::String, str2::String) = str1 * str2
replace_cvc(mainstr::String, to_replace::String, replace_with::String) = replace(mainstr, to_replace => replace_with)
at_cvc(str::String, index) = string(str[Int(index)])
int_to_str_cvc(n) = "$(Int(n))"
substr_cvc(str::String, start_index, end_index) = str[Int(start_index):Int(end_index)]

# Int typed
len_cvc(str::String) = length(str)
str_to_int_cvc(str::String) = parse(Int64, str)
indexof_cvc(str::String, substring::String, index) = (n = findfirst(substring, str); n == nothing ? -1 : (n[1] >= Int(index) ? n[1] : -1))

# Bool typed
prefixof_cvc(prefix::String, str::String) = startswith(str, prefix)
suffixof_cvc(suffix::String, str::String) = endswith(str, suffix)
contains_cvc(str::String, contained::String) = contains(str, contained)
lt_cvc(str1::String, str2::String) = cmp(str1, str2) < 0
leq_cvc(str1::String, str2::String) = cmp(str1, str2) <= 0
isdigit_cvc(str::String) = tryparse(Int, str) !== nothing

# pair = get_problem_grammar_pair(PBE_SLIA_Track_2019, "split_text_string_at_specific_character") 

# g = pair.grammar
# examples = map(example -> [example], pair.problem.spec)
    
#println(find_solutions_per_example(examples, g, :Start, 1, [:_arg_1], add_constraints_split_text_string_at_specific_character!))

function add_constraints_dumb_12948338!(grammar)
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

    addconstraint!(grammar, Forbidden(RuleNode(strint, [RuleNode(dash)])))
    addconstraint!(grammar, Forbidden(RuleNode(strint, [RuleNode(space)])))
    addconstraint!(grammar, Forbidden(RuleNode(strint, [RuleNode(empty)])))
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

    addconstraint!(grammar, Ordered(RuleNode(equals, [VarNode(:a), VarNode(:b)]), [:a, :b]))

    add_constraints_dumb_12948338!(grammar)
end

function add_constraints_dumb_remove_file_extension_from_filename!(grammar)
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

    addconstraint!(grammar, Forbidden(RuleNode(strint, [DomainRuleNode(strings)])))
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
    
    add_constraints_dumb_remove_file_extension_from_filename!(grammar)

    addconstraint!(grammar, Ordered(RuleNode(equals, [VarNode(:a), VarNode(:b)]), [:a, :b]))
end

function add_constraints_dumb_30732554!(grammar)
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

    addconstraint!(grammar, Forbidden(RuleNode(strint, [DomainRuleNode(strings)])))

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
    
    
    add_constraints_dumb_30732554!(grammar)

    addconstraint!(grammar, Ordered(RuleNode(equals, [VarNode(:a), VarNode(:b)]), [:a, :b]))
end

function add_constraints_dumb_44789427!(grammar)
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

    addconstraint!(grammar, Forbidden(RuleNode(strint, [DomainRuleNode(strings)])))
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
    
    
    add_constraints_dumb_44789427!(grammar)

    addconstraint!(grammar, Ordered(RuleNode(equals, [VarNode(:a), VarNode(:b)]), [:a, :b]))
end

function add_constraints_dumb_remove_characters_from_left!(grammar)
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

    addconstraint!(grammar, Forbidden(RuleNode(strint, [DomainRuleNode(strings)])))
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
    
    
    add_constraints_dumb_remove_characters_from_left!(grammar)

    addconstraint!(grammar, Ordered(RuleNode(equals, [VarNode(:a), VarNode(:b)]), [:a, :b]))
end

function add_constraints_dumb_19558979!(grammar)
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

    addconstraint!(grammar, Forbidden(RuleNode(strint, [DomainRuleNode(strings)])))
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
    
    add_constraints_dumb_19558979!(grammar)

    addconstraint!(grammar, Ordered(RuleNode(equals, [VarNode(:a), VarNode(:b)]), [:a, :b]))
end

function add_constraints_dumb_cell_contains_number!(grammar)
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

    addconstraint!(grammar, Forbidden(RuleNode(strint, [DomainRuleNode(strings)])))
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
    
    add_constraints_dumb_cell_contains_number!(grammar)

    addconstraint!(grammar, Ordered(RuleNode(equals, [VarNode(:a), VarNode(:b)]), [:a, :b]))
end

function add_constraints_dumb_compare_two_strings!(grammar)
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

    addconstraint!(grammar, Forbidden(RuleNode(strint, [RuleNode(space)]))) 
    addconstraint!(grammar, Forbidden(RuleNode(strint, [RuleNode(empty)])))
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
    
    add_constraints_dumb_compare_two_strings!(grammar)

    addconstraint!(grammar, Ordered(RuleNode(equals, [VarNode(:a), VarNode(:b)]), [:a, :b]))
end

function add_constraints_dumb_clean_and_reformat_telephone_numbers!(grammar)
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
    
    strings = falses(30)      
    strings[3:9] .= true  
    
    addconstraint!(grammar, Forbidden(RuleNode(len, [DomainRuleNode(strings)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(replace, [DomainRuleNode(strings), VarNode(:A), VarNode(:B)]))) 
    
    addconstraint!(grammar, Forbidden(RuleNode(substr, [DomainRuleNode(strings), VarNode(:A), VarNode(:B)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(prefixof, [VarNode(:A), DomainRuleNode(strings)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(suffixof, [VarNode(:A), DomainRuleNode(strings)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(contains, [DomainRuleNode(strings), VarNode(:A)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(indexof, [DomainRuleNode(strings), VarNode(:A), VarNode(:B)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(strint, [DomainRuleNode(strings)]))) 
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
    
    add_constraints_dumb_clean_and_reformat_telephone_numbers!(grammar)

    addconstraint!(grammar, Ordered(RuleNode(equals, [VarNode(:a), VarNode(:b)]), [:a, :b]))
end

function add_constraints_dumb_change_negative_numbers_to_positive!(grammar)
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
    
    strings = falses(26)      
    strings[3:5] .= true  
    
    addconstraint!(grammar, Forbidden(RuleNode(len, [DomainRuleNode(strings)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(replace, [DomainRuleNode(strings), VarNode(:A), VarNode(:B)]))) 
    
    addconstraint!(grammar, Forbidden(RuleNode(substr, [DomainRuleNode(strings), VarNode(:A), VarNode(:B)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(prefixof, [VarNode(:A), DomainRuleNode(strings)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(suffixof, [VarNode(:A), DomainRuleNode(strings)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(contains, [DomainRuleNode(strings), VarNode(:A)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(indexof, [DomainRuleNode(strings), VarNode(:A), VarNode(:B)])))

    addconstraint!(grammar, Forbidden(RuleNode(strint, [DomainRuleNode(strings)]))) 
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
    
    add_constraints_dumb_change_negative_numbers_to_positive!(grammar)

    addconstraint!(grammar, Ordered(RuleNode(equals, [VarNode(:a), VarNode(:b)]), [:a, :b]))
end

function add_constraints_dumb_replace_one_character_with_another!(grammar)
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
    
    strings = falses(26)      
    strings[3:5] .= true  
    
    addconstraint!(grammar, Forbidden(RuleNode(len, [DomainRuleNode(strings)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(replace, [DomainRuleNode(strings), VarNode(:A), VarNode(:B)]))) 
    
    addconstraint!(grammar, Forbidden(RuleNode(substr, [DomainRuleNode(strings), VarNode(:A), VarNode(:B)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(prefixof, [VarNode(:A), DomainRuleNode(strings)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(suffixof, [VarNode(:A), DomainRuleNode(strings)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(contains, [DomainRuleNode(strings), VarNode(:A)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(indexof, [DomainRuleNode(strings), VarNode(:A), VarNode(:B)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(strint, [DomainRuleNode(strings)]))) 
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
    
    add_constraints_dumb_replace_one_character_with_another!(grammar)

    addconstraint!(grammar, Ordered(RuleNode(equals, [VarNode(:a), VarNode(:b)]), [:a, :b]))
end

function add_constraints_dumb_remove_text_by_matching!(grammar)
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
    
    strings = falses(26)      
    strings[3:5] .= true  
    
    addconstraint!(grammar, Forbidden(RuleNode(len, [DomainRuleNode(strings)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(replace, [DomainRuleNode(strings), VarNode(:A), VarNode(:B)]))) 
    
    addconstraint!(grammar, Forbidden(RuleNode(substr, [DomainRuleNode(strings), VarNode(:A), VarNode(:B)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(prefixof, [VarNode(:A), DomainRuleNode(strings)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(suffixof, [VarNode(:A), DomainRuleNode(strings)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(contains, [DomainRuleNode(strings), VarNode(:A)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(indexof, [DomainRuleNode(strings), VarNode(:A), VarNode(:B)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(strint, [DomainRuleNode(strings)]))) 
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

    add_constraints_dumb_remove_text_by_matching!(grammar)

    addconstraint!(grammar, Ordered(RuleNode(equals, [VarNode(:a), VarNode(:b)]), [:a, :b]))
end

function add_constraints_dumb_get_last_name_from_name_with_comma!(grammar)
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
    
    strings = falses(26)      
    strings[3:5] .= true  
    
    addconstraint!(grammar, Forbidden(RuleNode(len, [DomainRuleNode(strings)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(replace, [DomainRuleNode(strings), VarNode(:A), VarNode(:B)]))) 
    
    addconstraint!(grammar, Forbidden(RuleNode(substr, [DomainRuleNode(strings), VarNode(:A), VarNode(:B)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(prefixof, [VarNode(:A), DomainRuleNode(strings)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(suffixof, [VarNode(:A), DomainRuleNode(strings)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(contains, [DomainRuleNode(strings), VarNode(:A)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(indexof, [DomainRuleNode(strings), VarNode(:A), VarNode(:B)])))

    addconstraint!(grammar, Forbidden(RuleNode(strint, [DomainRuleNode(strings)]))) 
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
    
    add_constraints_dumb_get_last_name_from_name_with_comma!(grammar)

    addconstraint!(grammar, Ordered(RuleNode(equals, [VarNode(:a), VarNode(:b)]), [:a, :b]))
end

function add_constraints_dumb_cell_contains_some_words_but_not_others!(grammar)
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
    
    strings = falses(28)      
    strings[6:7] .= true  
    
    addconstraint!(grammar, Forbidden(RuleNode(len, [DomainRuleNode(strings)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(replace, [DomainRuleNode(strings), VarNode(:A), VarNode(:B)]))) 
    
    addconstraint!(grammar, Forbidden(RuleNode(substr, [DomainRuleNode(strings), VarNode(:A), VarNode(:B)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(prefixof, [VarNode(:A), DomainRuleNode(strings)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(suffixof, [VarNode(:A), DomainRuleNode(strings)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(contains, [DomainRuleNode(strings), VarNode(:A)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(indexof, [DomainRuleNode(strings), VarNode(:A), VarNode(:B)])))

    addconstraint!(grammar, Forbidden(RuleNode(strint, [DomainRuleNode(strings)]))) 
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
    
    add_constraints_dumb_cell_contains_some_words_but_not_others!(grammar)

    addconstraint!(grammar, Ordered(RuleNode(equals, [VarNode(:a), VarNode(:b)]), [:a, :b]))
end

function add_constraints_dumb_cell_contains_specific_text!(grammar)
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
    
    strings = falses(26)      
    strings[4:5] .= true  
    
    addconstraint!(grammar, Forbidden(RuleNode(len, [DomainRuleNode(strings)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(replace, [DomainRuleNode(strings), VarNode(:A), VarNode(:B)]))) 
    
    addconstraint!(grammar, Forbidden(RuleNode(substr, [DomainRuleNode(strings), VarNode(:A), VarNode(:B)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(prefixof, [VarNode(:A), DomainRuleNode(strings)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(suffixof, [VarNode(:A), DomainRuleNode(strings)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(contains, [DomainRuleNode(strings), VarNode(:A)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(indexof, [DomainRuleNode(strings), VarNode(:A), VarNode(:B)])))

    addconstraint!(grammar, Forbidden(RuleNode(strint, [DomainRuleNode(strings)]))) 
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
    
    add_constraints_dumb_cell_contains_specific_text!(grammar)

    addconstraint!(grammar, Ordered(RuleNode(equals, [VarNode(:a), VarNode(:b)]), [:a, :b]))
end

function add_constraints_dumb_remove_unwanted_characters!(grammar)
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
    
    strings = falses(26)      
    strings[4:5] .= true  
    
    addconstraint!(grammar, Forbidden(RuleNode(len, [DomainRuleNode(strings)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(replace, [DomainRuleNode(strings), VarNode(:A), VarNode(:B)]))) 
    
    addconstraint!(grammar, Forbidden(RuleNode(substr, [DomainRuleNode(strings), VarNode(:A), VarNode(:B)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(prefixof, [VarNode(:A), DomainRuleNode(strings)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(suffixof, [VarNode(:A), DomainRuleNode(strings)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(contains, [DomainRuleNode(strings), VarNode(:A)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(indexof, [DomainRuleNode(strings), VarNode(:A), VarNode(:B)])))

    addconstraint!(grammar, Forbidden(RuleNode(strint, [DomainRuleNode(strings)]))) 
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
    
    add_constraints_dumb_remove_unwanted_characters!(grammar) 

    addconstraint!(grammar, Ordered(RuleNode(equals, [VarNode(:a), VarNode(:b)]), [:a, :b]))
end

function add_constraints_dumb_37281007!(grammar)
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
    
    strings = falses(26)      
    strings[4:5] .= true  
    
    addconstraint!(grammar, Forbidden(RuleNode(len, [DomainRuleNode(strings)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(replace, [DomainRuleNode(strings), VarNode(:A), VarNode(:B)]))) 
    
    addconstraint!(grammar, Forbidden(RuleNode(substr, [DomainRuleNode(strings), VarNode(:A), VarNode(:B)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(prefixof, [VarNode(:A), DomainRuleNode(strings)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(suffixof, [VarNode(:A), DomainRuleNode(strings)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(contains, [DomainRuleNode(strings), VarNode(:A)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(indexof, [DomainRuleNode(strings), VarNode(:A), VarNode(:B)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(strint, [DomainRuleNode(strings)]))) 
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
    
    add_constraints_dumb_37281007!(grammar) 

    addconstraint!(grammar, Ordered(RuleNode(equals, [VarNode(:a), VarNode(:b)]), [:a, :b]))
end

function add_constraints_dumb_convert_numbers_to_text!(grammar)
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

    addconstraint!(grammar, Forbidden(RuleNode(strint, [RuleNode(space)]))) 
    addconstraint!(grammar, Forbidden(RuleNode(strint, [RuleNode(empty)])))
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
    
    add_constraints_dumb_convert_numbers_to_text!(grammar)

    addconstraint!(grammar, Ordered(RuleNode(equals, [VarNode(:a), VarNode(:b)]), [:a, :b]))
end

function add_constraints_dumb_convert_text_to_numbers!(grammar)
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

    addconstraint!(grammar, Forbidden(RuleNode(strint, [RuleNode(space)]))) 
    addconstraint!(grammar, Forbidden(RuleNode(strint, [RuleNode(empty)])))
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
    
    add_constraints_dumb_convert_text_to_numbers!(grammar)

    addconstraint!(grammar, Ordered(RuleNode(equals, [VarNode(:a), VarNode(:b)]), [:a, :b]))
end

function add_constraints_dumb_get_last_name_from_name!(grammar)
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

    addconstraint!(grammar, Forbidden(RuleNode(strint, [RuleNode(space)]))) 
    addconstraint!(grammar, Forbidden(RuleNode(strint, [RuleNode(empty)])))
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
    
    add_constraints_dumb_get_last_name_from_name!(grammar)

    addconstraint!(grammar, Ordered(RuleNode(equals, [VarNode(:a), VarNode(:b)]), [:a, :b]))
end

function add_constraints_dumb_count_total_characters_in_a_cell!(grammar)
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

    addconstraint!(grammar, Forbidden(RuleNode(strint, [RuleNode(space)]))) 
    addconstraint!(grammar, Forbidden(RuleNode(strint, [RuleNode(empty)])))
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
    
    add_constraints_dumb_count_total_characters_in_a_cell!(grammar)

    addconstraint!(grammar, Ordered(RuleNode(equals, [VarNode(:a), VarNode(:b)]), [:a, :b]))
end

function add_constraints_dumb_split_text_string_at_specific_character!(grammar)
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
    
    strings = falses(28)      
    strings[3:5] .= true  
    
    addconstraint!(grammar, Forbidden(RuleNode(len, [DomainRuleNode(strings)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(replace, [DomainRuleNode(strings), VarNode(:A), VarNode(:B)]))) 
    
    addconstraint!(grammar, Forbidden(RuleNode(substr, [DomainRuleNode(strings), VarNode(:A), VarNode(:B)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(prefixof, [VarNode(:A), DomainRuleNode(strings)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(suffixof, [VarNode(:A), DomainRuleNode(strings)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(contains, [DomainRuleNode(strings), VarNode(:A)]))) 

    addconstraint!(grammar, Forbidden(RuleNode(indexof, [DomainRuleNode(strings), VarNode(:A), VarNode(:B)])))

    addconstraint!(grammar, Forbidden(RuleNode(strint, [DomainRuleNode(strings)]))) 
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
    
    add_constraints_dumb_split_text_string_at_specific_character!(grammar)

    addconstraint!(grammar, Ordered(RuleNode(equals, [VarNode(:a), VarNode(:b)]), [:a, :b]))
end 

function add_constraints_dumb_stackoverflow9!(grammar)
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

    addconstraint!(grammar, Forbidden(RuleNode(strint, [RuleNode(space)]))) 
    addconstraint!(grammar, Forbidden(RuleNode(strint, [RuleNode(empty)])))
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
    
    add_constraints_dumb_stackoverflow9!(grammar)

    addconstraint!(grammar, Ordered(RuleNode(equals, [VarNode(:a), VarNode(:b)]), [:a, :b]))
end

function add_constraints_dumb_join_first_and_last_name!(grammar)
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

    addconstraint!(grammar, Forbidden(RuleNode(strint, [RuleNode(space)]))) 
    addconstraint!(grammar, Forbidden(RuleNode(strint, [RuleNode(empty)])))
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
    
    add_constraints_dumb_join_first_and_last_name!(grammar)

    addconstraint!(grammar, Ordered(RuleNode(equals, [VarNode(:a), VarNode(:b)]), [:a, :b]))
end

function add_constraints_dumb_remove_characters_from_right!(grammar)
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

    addconstraint!(grammar, Forbidden(RuleNode(strint, [RuleNode(space)]))) 
    addconstraint!(grammar, Forbidden(RuleNode(strint, [RuleNode(empty)])))
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
    
    add_constraints_dumb_remove_characters_from_right!(grammar)

    addconstraint!(grammar, Ordered(RuleNode(equals, [VarNode(:a), VarNode(:b)]), [:a, :b]))
end

problems = [
    ["convert_numbers_to_text", add_constraints_convert_numbers_to_text!, [:_arg_1], add_constraints_dumb_convert_numbers_to_text!, false],
    ["convert_text_to_numbers", add_constraints_convert_text_to_numbers!, [:_arg_1], add_constraints_dumb_convert_text_to_numbers!, true],
    ["cell_contains_specific_text", add_constraints_cell_contains_specific_text!, [:_arg_1, :_arg_2], add_constraints_dumb_cell_contains_specific_text!, true],
    ["replace_one_character_with_another", add_constraints_replace_one_character_with_another!, [:_arg_1], add_constraints_dumb_replace_one_character_with_another!, true],
    ["remove_text_by_matching", add_constraints_remove_text_by_matching!, [:_arg_1], add_constraints_dumb_remove_text_by_matching!, true],
    ["count_total_characters_in_a_cell", add_constraints_count_total_characters_in_a_cell!, [:_arg_1], add_constraints_dumb_count_total_characters_in_a_cell!, true],
    ["compare_two_strings", add_constraints_compare_two_strings!, [:_arg_1, :_arg_2], add_constraints_dumb_compare_two_strings!, true],
    ["change_negative_numbers_to_positive", add_constraints_change_negative_numbers_to_positive!, [:_arg_1], add_constraints_dumb_change_negative_numbers_to_positive!, true],
    ["remove_unwanted_characters", add_constraints_remove_unwanted_characters!, [:_arg_1, :_arg_2], add_constraints_dumb_remove_unwanted_characters!, true],
    ["remove_characters_from_left", add_constraints_remove_characters_from_left!, [:_arg_1, :_arg_2], add_constraints_dumb_remove_characters_from_left!, true],
    ["join_first_and_last_name", add_constraints_join_first_and_last_name!, [:_arg_1, :_arg_2], add_constraints_dumb_join_first_and_last_name!, true],
    ["37281007", add_constraints_37281007!, [:_arg_1, :_arg_2], add_constraints_dumb_37281007!, true],
    ["19558979", add_constraints_19558979!, [:_arg_1, :_arg_2], add_constraints_dumb_19558979!, true],
    ["clean_and_reformat_telephone_numbers", add_constraints_clean_and_reformat_telephone_numbers!, [:_arg_1], add_constraints_dumb_clean_and_reformat_telephone_numbers!, false],
    ["44789427", add_constraints_44789427!, [:_arg_1, :_arg_2], add_constraints_dumb_44789427!, false],
    ["stackoverflow9", add_constraints_stackoverflow9!, [:_arg_1], add_constraints_dumb_stackoverflow9!, false],
    ##["stackoverflow10", add_constraints_stackoverflow10!, [:_arg_1], add_constraints_dumb_stackoverflow10!],
    ["remove_file_extension_from_filename", add_constraints_remove_file_extension_from_filename!, [:_arg_1], add_constraints_dumb_remove_file_extension_from_filename!, false],
    ["get_last_name_from_name_with_comma", add_constraints_get_last_name_from_name_with_comma!, [:_arg_1], add_constraints_dumb_get_last_name_from_name_with_comma!, false],
    ["get_last_name_from_name", add_constraints_get_last_name_from_name!, [:_arg_1], add_constraints_dumb_get_last_name_from_name!, false],
    ##["11604909", add_constraints_11604909!, [:_arg_1], add_constraints_dumb_11604909!],
    ["12948338", add_constraints_12948338!, [:_arg_1, :_arg_2], add_constraints_dumb_12948338!, false],
    ["30732554", add_constraints_30732554!, [:_arg_1], add_constraints_dumb_30732554!, false]
]

R = @theory a b c begin
    concat_cvc(a::String, "") == a
    concat_cvc("", a::String) == a
    replace_cvc(a::String, b::String, b::String) --> a
    replace_cvc("", a::String, b::String) --> ""
    str_to_int_cvc(int_to_str_cvc(a::Int)) == a
    int_to_str_cvc(str_to_int_cvc(a::String)) == a
    a::Int+0 == a
    0 + a::Int == a
    a::Int - 0 == a
    a == a --> true
    prefixof_cvc(a::String, a::String) --> true
    prefixof_cvc("", a::String) --> true
    suffixof_cvc(a::String, a::String) --> true
    suffixof_cvc("", a::String) --> true
    contains_cvc(a::String, a::String) --> true
    contains_cvc(a::String, "") --> true
    concat_cvc(a::String, concat_cvc(b::String, c::String)) == concat_cvc(concat_cvc(a::String, b::String), c::String)
    len_cvc(concat_cvc(a::String, b::String)) == len_cvc(a::String) + len_cvc(b::String)
    substr_cvc(a::String, 1, len_cvc(a::String)) == a
    substr_cvc(a::String, 1, 0) --> ""
    prefixof_cvc(a::String, concat_cvc(a::String, b::String)) --> true
    suffixof_cvc(a::String, concat_cvc(b::String, a::String)) --> true
    contains_cvc(concat_cvc(a::String, b::String), a::String) --> true
    contains_cvc(concat_cvc(b::String, a::String), a::String) --> true
end

#append!(R, [eval(:(@rule a b $(:(a ? b : b)) --> b)), eval(:(@rule a b $(:(true ? a : b)) --> a)), eval(:(@rule a b $(:(false ? a : b)) --> b))])

# io = open("results_enumeration.txt", "w")
# println(io, "Solution,Type,Time,Iterations")
# for problem in problems
#     name = problem[1]
#     constraints = problem[2]
#     pair = get_problem_grammar_pair(PBE_SLIA_Track_2019, name) 
#     g = pair.grammar
#     constraints(g) 
    
#     println("Solving problem: $name")
#     solution = nothing
    
#     starttime = time()
#     solution = synth(pair.problem, BFSIterator(g, :Start), allow_evaluation_errors = true, max_time = 1200)
#     totaltime = time() - starttime

#     println(io, "$(solution[1]),$(solution[2]),$totaltime,$(solution[3])")
# end
# close(io)

io = open("results_my_system_1.txt", "w")  
ioruler = open("ruler.txt", "w")  

# #TODO add nutteloosheids constraints to normal enumeration
# #TODO add iteration counter to enumeration, and for other one calculate all programs represnted by egraph vs all recursive steps
for n in 1:1
    for problem in problems
        name = problem[1]
        constraints = problem[2]
        variables = problem[3]
        constraints_dumb = problem[4]
        find_indiv_solutions = problem[5] #for the ones it does not, I tested and it takes over the timeout time anyways so this saves me time
        pair = get_problem_grammar_pair(PBE_SLIA_Track_2019, name) 
        g = pair.grammar
        examples = map(example -> [example], pair.problem.spec)
        println(ioruler, "\n$name with n=$n")
        
        println("$name with n=$n")
        solution = nothing
        
        starttime = time() #TODO dont forget to add R back
        solution = solve(examples, g, :Start, variables, Union{String, Int, Bool, Expr, Symbol}, Union{String, Int, Bool, Symbol}, constraints, constraints_dumb, io, ioruler, find_indiv_solutions, 1, n)
        totaltime = time() - starttime
        println(io, "$name with n=$n: iterations $(solution[2]), estimate $(solution[3]), solution found: $(solution[1]), time $totaltime")

        
    end
end

close(io)
close(ioruler)

#=
EASY(2 nodes):                                  SOLUTION:                                               UNIVERSAL SOLUTION FOUND:   TIME:
problem_convert_numbers_to_text,                int_to_str_cvc(_arg_1)                                  YES                         0.06
problem_convert_text_to_numbers,                str_to_int_cvc(_arg_1)                                  YES                         0.05
problem_cell_contains_specific_text             contains_cvc(_arg_1, _arg_2)                            YES                         0.12
problem_replace_one_character_with_another      replace_cvc(_arg_1, " ", "-")                           YES                         1.41
problem_remove_text_by_matching                 replace_cvc(_arg_1, "-", "")                            YES                         1.43
problem_count_total_characters_in_a_cell        len_cvc(_arg_1)                                         YES                         0.03

MEDIUM(3+ nodes):                               SOLUTION:
problem_compare_two_strings                     prefixof_cvc(_arg_1, _arg_2)                            YES                         0.09   
problem_change_negative_numbers_to_positive     replace_cvc(_arg_1, "-", "")                            YES                         0.77
problem_remove_unwanted_characters              replace_cvc(_arg_1, _arg_2, "")                         YES                         0.87
problem_remove_characters_from_left             replace_cvc(_arg_1, substr_cvc(_arg_1, 1, _arg_2), "")  YES                         51.57
problem_join_first_and_last_name                concat_cvc(_arg_1, concat_cvc(" ", _arg_2))             YES                         2.16
problem_37281007                                contains_cvc(_arg_1, _arg_2)                            YES                         0.13
problem_19558979                                at_cvc(_arg_1, _arg_2)                                  YES                         0.17      

HARD(many nodes):                               SOLUTIONS                               UNIVERSAL SOLUTION FOUND:
problem_clean_and_reformat_telephone_numbers    :(replace_cvc(_arg_1, "-/.", "")) 2/3   NO
problem_44789427                                NO                                      NO
stackoverflow9                                  NO                                      NO
stackoverflow10                                 NO                                      NO
remove_file_extension_from_filename
get_last_name_from_name_with_comma              NO                                      NO
problem_get_last_name_from_name                 NO                                      NO
problem_11604909 
problem_12948338
problem_30732554

interesting for my own (moeite vanaf deze size):
problem_get_last_name_from_name     with solution   substr_cvc(aap, indexof_cvc(aap, " ", 1)+1, len_cvc(aap))
problem_30732554                    with solution   substr_cvc(test,1,indexof_cvc(test,"|",1)-1)

substr_cvc(test,1,indexof_cvc(test,"|",1)-1)

problem_37281007new = Problem("problem_37281007new", [
	IOExample(Dict{Symbol, Any}(:_arg_1 => "ABCD", :_arg_2 => "D", :_arg_3 => 1), true),            if arg3 == 1 suffix(arg1, arg2) 
    IOExample(Dict{Symbol, Any}(:_arg_1 => "ABCD", :_arg_2 => "AB", :_arg_3 => 0), true), 
	IOExample(Dict{Symbol, Any}(:_arg_1 => "ABCD", :_arg_2 => "A", :_arg_3 => 1), false)]),
    IOExample(Dict{Symbol, Any}(:_arg_1 => "ABCD", :_arg_2 => "CD", :_arg_3 => 0), false)])


substr(arg1, 1, at_cvc(_arg_1, "|"))



problem set, aim for 10 problems that show interesting stuff
1) 2x+1 --> x + <x+1>: [(0,1,x+1),(1,3,x+2),(2,5,x+3)] D = [0,1,2,x,x+1,x+2,x+3] (shows power of individual solutions)
    - meeting note I could do more of this one but for the point one is enough right?
2) x^2 +2x + 1, ((0,1),(1,4),(2,9)), D = [for (2,9) we need 2*2+1. so terms up to 2 ops] (shows power but bigger)
3) D = [x, -x, x==5, x==-5] R = (a == b --> a >= b, a >= b --> a >= b-1), W = (a --> if true then a else :any) (shows power of wildcard rules)
4) prefixof(arg1, arg2) || suffixof(arg1, arg2) with indiv ones as the indiv solutions using, A == A or :any + :any or A (shows other wildcard rule)
5) D = [1,x,-x,x-x,x-1] (shows cycles)
6) problem (1) but with Int = -Int (shows cycles for bigger problem)
7) problem_get_last_name_from_name but with numbers up to like 20 (shows power of the rewrite idea of my system for a bigger problem that was unsolved)
    - meeting note: maybe introducing cvecs as terms is enough for this. but i dont want to alter my stuff a lot anymore :cry: (future work idea?)
    - I think this is the most interesting one 
8) problem_split_text_string_at_specific_character
    - solution would be if arg2 == 1 then substr_cvc(kaas, 1, indexof_cvc(kaas, "_", 1)-1) else substr_cvc(kaas, 1, indexof_cvc(kaas, "_", 1)+1)
    - both the individual ones can be constructed
    - using both wildcard rules for true and false the whole thing should be findable
    - then also this one is found
    - also solve these ones with enumeration





problem 2 in more detail:
0,1,2
1,4,9

A + B

A = x*x             0/1/4           0+1, 1+3, 4+5
B = (2*x) + 1       1/3/5               



problem 7 in more detail:
substr_cvc(_arg_1, indexof_cvc(_arg_1, " ", 1)+1, len_cvc(_arg_1))

D=[_arg_1, len_cvc(_arg_1), ]

substr_cvc_(A,B,C)

A == _arg_1

B = indexof_cvc(_arg_1, " ", 1)+1  ==> this number wont be available either. so remake this problem but with bigger numbers for

C = len_cvc(_arg_1) ==> this is the problem mostly as you wont have the big numbers. so introduce by hand or enumerate to larger size

substr_cvc(A, B, len_cvc(_arg_1))

=#

#solution = solve(examples, g, :Start, [:_arg_1], Union{String, Int, Bool, Expr, Symbol}, Union{String, Int, Bool}, 1, 3)
#println(solution)