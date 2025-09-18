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

    # nums = falses(25)      
    # nums[10:13] .= true

    # addconstraint!(grammar, Forbidden(RuleNode(at, [RuleNode(space), DomainRuleNode(nums)]))) 
    # addconstraint!(grammar, Forbidden(RuleNode(at, [RuleNode(empty), DomainRuleNode(nums)])))
    # addconstraint!(grammar, Forbidden(RuleNode(at, [RuleNode(intstr, [DomainRuleNode(nums)]), DomainRuleNode(nums)]))) 
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
    concat_cvc(a::String, "") --> a
    concat_cvc("", a::String) --> a
    replace_cvc(a::String, b::String, b::String) --> a
    replace_cvc("", a::String, b::String) --> ""
    str_to_int_cvc(int_to_str_cvc(a::Int)) --> a
    int_to_str_cvc(str_to_int_cvc(a::String)) --> a
    a::Int+0 == a
    0 + a::Int == a
    a::Int - 0 == a
    a == a --> :waar
    prefixof_cvc(a::String, a::String) --> :waar
    prefixof_cvc("", a::String) --> :waar
    suffixof_cvc(a::String, a::String) --> :waar
    suffixof_cvc("", a::String) --> :waar
    contains_cvc(a::String, a::String) --> :waar
    contains_cvc(a::String, "") --> :waar
    concat_cvc(a::String, concat_cvc(b::String, c::String)) == concat_cvc(concat_cvc(a::String, b::String), c::String)
    len_cvc(concat_cvc(a::String, b::String)) == len_cvc(a::String) + len_cvc(b::String)
    substr_cvc(a::String, 1, len_cvc(a::String)) --> a
    substr_cvc(a::String, 1, 0) --> ""
    prefixof_cvc(a::String, concat_cvc(a::String, b::String)) --> :waar
    suffixof_cvc(a::String, concat_cvc(b::String, a::String)) --> :waar
    contains_cvc(concat_cvc(a::String, b::String), a::String) --> :waar
    contains_cvc(concat_cvc(b::String, a::String), a::String) --> :waar
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

for n in 0:2
    for use_new_select in [true,false]
        for use_general_rules in [true,false]
            io = open("n=$(n)_R=$(use_general_rules)_S=$(use_new_select).txt", "w")  
            ioruler = open("n=$(n)_R=$(use_general_rules)_S=$(use_new_select)._ruler.txt", "w") 
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
                if use_general_rules
                    solution = solve(examples, g, :Start, variables, Union{String, Int, Bool, Expr, Symbol}, Union{String, Int, Bool, Symbol}, constraints, constraints_dumb, io, ioruler, find_indiv_solutions, 1, n, use_new_select, R)
                else
                    solution = solve(examples, g, :Start, variables, Union{String, Int, Bool, Expr, Symbol}, Union{String, Int, Bool, Symbol}, constraints, constraints_dumb, io, ioruler, find_indiv_solutions, 1, n, use_new_select)
                end
                totaltime = time() - starttime
                println(io, "$name with n=$n: iterations $(solution[2]), estimate $(solution[3]), solution found: $(solution[1]), time $totaltime, rulertime $(solution[4])")
                
            end
            close(io)
            close(ioruler)
        end
    end
end
