using HerbBenchmarks
using HerbBenchmarks.SyGuS
using HerbConstraints
using HerbGrammar
using HerbSearch
using Metatheory

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

S = Set(Union{Bool, Int64, Expr, String, Symbol}[:_arg_1, " ", 1002, "101", true, false, -1, "1002", "743", 743, "", 101])

R = @theory a b c begin
    # concat_cvc(a, "") == a
    # concat_cvc("", a) == a
    # replace_cvc(a, b, b) --> a
    # replace_cvc("", a, b) --> ""
    # str_to_int_cvc(int_to_str_cvc(a)) == a
    # int_to_str_cvc(str_to_int_cvc(a)) == a
     a::Int == a+0
    # 0 + a == a
    # a - 0 == a
    # a == a --> true
    # prefixof_cvc(a, a) --> true
    # prefixof_cvc("", a) --> true
    # suffixof_cvc(a, a) --> true
    # suffixof_cvc("", a) --> true
    # contains_cvc(a, a) --> true
    # contains_cvc(a, "") --> true
    # concat_cvc(a, concat_cvc(b, c)) == concat_cvc(concat_cvc(a, b), c)
    # len_cvc(concat_cvc(a, b)) == len_cvc(a) + len_cvc(b)
    # substr_cvc(a, 1, len_cvc(a)) == a
    # substr_cvc(a, 1, 0) --> ""
    # prefixof_cvc(a, concat_cvc(a, b)) --> true
    # suffixof_cvc(a, concat_cvc(b, a)) --> true
    # contains_cvc(concat_cvc(a, b), a) --> true
    # contains_cvc(concat_cvc(b, a), a) --> true
end

function equal_cvecs(a::Vector{CVec}, b::Vector{CVec})::Bool where {CVec}
    all_equal = true
    at_least_one_equal = false
    for i in eachindex(a)
        if a === nothing || b === nothing
            continue
        end
        if a[i] != b[i] # TODO maybe !== (to counter 0 == false)
            all_equal = false
            break
        else
            at_least_one_equal = true
        end
    end
    all_equal && at_least_one_equal
end

"""
Make the cvec for a new eclass.
When the term of the eclass is a constant, return N copies of that constant.
When the term of the eclass is a function call f(c1, c2, ..., cn), return map(f, zip(v1, v2, ..., vn)).
When the term of the eclass is a variable x, return N values from the target domain (randomly or in some specific way).
"""
function EGraphs.make(g::EGraph{Expr, Vector{CVec}}, n::VecExpr)::Vector{CVec} where {CVec}
    # This is the first element of a new eclass.
    op = get_constant(g, v_head(n)) 
    cvec = nothing
    
    if !v_isexpr(n)
        if typeof(op) == Symbol
            # When op is a variable, return N values from the target domain as defined by variable_cvec
            cvec = variable_cvec(op)
        else
            # When op is a constant, return N copies
            cvec = fill(op, N)
        end
    else
        # When op is a function call op(c1, c2, ..., cn), return map(op, zip(v1, v2, ..., vn))

        # All cvecs of the children of n
        children_cvecs = map(c -> g[c].data, v_children(n))

        # n gets called in all these ways
        parameter_possibilities = zip(children_cvecs...)

        # Call op, that represents n, in all those ways to get the cvec
        if v_iscall(n)
            # If n is represented as an explicit function call in Julia
            cvec = map(params -> interpret_function(maketerm(Expr, :call, [op, params...], nothing)), parameter_possibilities)
        else
            # If n is not represented as a function call; example is &&
            cvec = map(params -> interpret_function(maketerm(Expr, op, params, nothing)), parameter_possibilities)
        end
    end

    haskey(cvec_to_classes,cvec) || (cvec_to_classes[cvec] = Set())
    push!(cvec_to_classes[cvec],Metatheory.EGraphs.IdKey(g.memo[n]))

    return cvec
end

"""
Join the cvecs of two merging eclasses.
"""
# TODO how should this actually be done? If they match, but a has nothings that b does not have and vice versa, what should be done?
# TODO should the nothing or non-nothing values be chosen
function EGraphs.join(a::Vector{CVec}, b::Vector{CVec})::Vector{CVec} where {CVec}
    equal_cvecs(a,b) || (return :error)#error("Cannot join different cvecs $a and $b")
    a 
end

