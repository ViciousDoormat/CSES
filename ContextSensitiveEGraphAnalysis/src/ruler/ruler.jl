
module Ruler

export ruler

using ..ContextSensitiveEGraphAnalysis:
    contains_variable, replace_with_symbol, replace_back_to_expr, add_symbol_type, remove_symbol_type, loading_bar,
    bvneg_cvc, bvnot_cvc, bvadd_cvc, bvsub_cvc, bvxor_cvc, bvand_cvc, bvor_cvc, bvshl_cvc, bvlshr_cvc, bvashr_cvc, 
    bvnand_cvc, bvnor_cvc, ehad_cvc, arba_cvc, shesh_cvc, smol_cvc, im_cvc, if0_cvc,
    concat_cvc, replace_cvc, at_cvc, int_to_str_cvc, substr_cvc, len_cvc, str_to_int_cvc, indexof_cvc, prefixof_cvc, 
    suffixof_cvc, contains_cvc, lt_cvc, leq_cvc, isdigit_cvc


# CVC5 functions

## String typed


using Metatheory
using Metatheory.Library
using Metatheory.EGraphs

const N = 1 # The number of outputs in a cvec

"""
The values of the target domain used for the cvecs of variables.
Needs to be implemented per target domain.
"""
variable_cvec = nothing

"""
Two cvecs match when all, and at least one, non-nothing elements are equal.
"""
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
    
    if !v_isexpr(n)
        # When t꜀ is a variable x, return N values from the target domain (randomly or in some specific way)
        if typeof(op) == Symbol
            return variable_cvec(op)
        end
        # When t꜀ is a constant n, return N copies of n
        return fill(op, N)
    end

    # When t꜀ is a function call f(c1, c2, ..., cn), return map(f, zip(v1, v2, ..., vn))
    if v_iscall(n)
        # All cvecs of the children of n
        children_cvecs = map(c -> g[c].data, v_children(n))

        # n gets called in all these ways
        parameter_possibilities = zip(children_cvecs...)

        # Call op, that represents n, in all those ways
        cvec = map(params -> eval(maketerm(Expr, :call, [op, params...], nothing)), parameter_possibilities)

        return cvec
    else
        children_cvecs = map(c -> g[c].data, v_children(n))

        # n gets called in all these ways
        parameter_possibilities = zip(children_cvecs...)

        # Call op, that represents n, in all those ways
        cvec = map(params -> eval(maketerm(Expr, op, params, nothing)), parameter_possibilities)

        return cvec
    end
end

"""
Join the cvecs of two merging eclasses.
"""
# TODO how should this actually be done? If they match, but a has nothings that b does not have and vice versa, what should be done?
# TODO should the nothing or non-nothing values be chosen
function EGraphs.join(a::Vector{CVec}, b::Vector{CVec})::Vector{CVec} where {CVec}
    equal_cvecs(a,b) || error("Cannot join different cvecs $a and $b")
    a 
end

# 1:   [1,1,1,1,1,1,1,1,1,1]
# x/x: [1,1,1,1,nothing,1,1,1,1,1]
# --------------------------------
# [1,1,1,1,nothing,1,1,1,1,1]

# [nothing, 1111, nothing, 11111]

# [1, nothing, 1] 
# [1, 1,       nothing]
# -->
# [1, nothing, nothing]

# EGraphs.modify! should not be required for cvecs. Maybe it could do something like add the canonical term

# A global set of eclasses that have been proven unequal
const proven_unequal = Set{Tuple{Id, Id}}() 

"""
Adding terms to an egraph. Add the ith terms from D to E-Graph g
"""
function add_terms!(g::EGraph{Expr, Vector{CVec}}, D::Dict{Int, Vector{AllTypes}}, i) where {AllTypes, CVec}
    if  haskey(D, i)
        for term in D[i]
            addexpr!(g, term)
            #println("added $term")
        end
    end
end

function create_rewrite_rule(x_can, y_can, variables)::RewriteRule
    r = eval(:(@rule $(replace_with_symbol(x_can,variables)) == $(replace_with_symbol(y_can,variables))))
    return r
end

#TODO when the cvecs are made, add them to a dic of equal cvecs already
"""
Returns a collection of rewrite rules from pairs of eclasses that have the same cvec.
If two eclasses were seen before and proven unequal, the rule they form should not be in the output.
"""
function cvec_match(g::EGraph{Expr, Vector{CVec}}, variables::Vector{Symbol}, ::Type{CVec})::Vector{RewriteRule} where {CVec}
    eclasses = g.classes
    # All candidate rules found
    C::Vector{RewriteRule} = []

    ids = collect(keys(eclasses))

    for i in 1:(length(ids)-1)
        loading_bar(i, length(ids))#println("\ri: $i")
        key_x = ids[i]
        x::Vector{CVec} = eclasses[key_x].data

        for j in (i+1):length(ids)
            key_y = ids[j]   
            y::Vector{CVec} = eclasses[key_y].data
            if equal_cvecs(x, y) && (key_x.val, key_y.val) ∉ proven_unequal
                #TODO why does it try to extract 17 when I tell it to extract 7
                
                x_can = extract!(g, astsize, key_x.val)
                y_can = extract!(g, astsize, key_y.val)

                lhs = replace_with_symbol(x_can,variables)
                rhs = replace_with_symbol(y_can,variables)
                r = eval(:(@rule $lhs == $rhs))
    
                push!(C, r)
            end
        end
    end

    return C
end

"""
Saturate T based on R without polluting T with intermediate terms added during equality saturation.
"""
function run_rewrites!(T::EGraph{Expr, Vector{CVec}}, R::Vector{RewriteRule}) where {CVec}
    # To ensure that run_rewrites only shrinks the term e-graph, Ruler performs this equality
    # saturation on a copy of the e-graph
    g = deepcopy(T)
    @invokelatest saturate!(g, R)

    initial_classes = Set(c.val for c in keys(T.classes))

    # It then copies the newly learned equalities (e-class merges) back to the original e-graph. 
    # This avoids polluting the e-graph with terms added during equality saturation.
    for (initial, intermediate) in enumerate(g.uf.parents)
        final = find(g, intermediate)
        if initial != final && initial in initial_classes && intermediate in initial_classes
            #println("merge $initial and $final")
            Metatheory.EGraphs.union!(T, UInt(initial), UInt(final))
        end
    end
    # Finally, make sure that everywhere where the old eclass is used, it is replaced with the one it got merged with  
    rebuild!(T)
end

"""
Remove rules from C that can be proven by the rules in R
If the left and right part of a rewrite rule in C end up in the same eclass after saturation by R
"""
function shrink(R::Vector{RewriteRule}, C::Vector{RewriteRule}, variables, ::Type{CVec}) where {CVec}
    E = EGraph{Expr, Vector{CVec}}() 
    classes_per_rule = []
    for r in C
        # For each rule, add the terms that form it to E
        left_id = addexpr!(E, replace_back_to_expr(r.lhs_original,variables))
        right_id = addexpr!(E, replace_back_to_expr(r.rhs_original,variables))
        # Remember in which classes the terms started
        push!(classes_per_rule, (left_id, right_id))
    end
    run_rewrites!(E, R)

    # For all rules, check whether its terms ended up in the same eclass
    result::Vector{RewriteRule} = []
    for (i,_) in enumerate(C)
        lhs = find(E, classes_per_rule[i][1])
        rhs = find(E, classes_per_rule[i][2])
        if (lhs != rhs)
            rule = create_rewrite_rule(extract!(E,astsize,lhs),extract!(E,astsize,rhs),variables)
            push!(result, rule)
        end
    end

    return result
end

# TODO add heuristic for choosing the best rule
# Ruler’s syntactic heuristic prefers candidates with the following characteristics (lexicographically): 
# more distinct variables, fewer constants, shorter larger side (between the two terms forming the candidate), 
# shorter smaller side, and fewer distinct operators.
"""
Select step best rules from C according to a heurstic.
Currently no heuristic implemented; first step rules are chosen.
"""
function select!(step, C::Vector{RewriteRule})
    [pop!(C) for _ in 1:(min(step, length(C)))]
end

"""
Makes sure that the rewrite rule r is valid.
That the left and right part of r are indeed behaviorally equal.
"""
function is_valid(r::RewriteRule)
    #TODO potentially implement
    true
end

"""
Keep selecting step rules from C until C gets empty or n rules are chosen
Makes sure to not choose superfluous rules by shrinking C with the rules chosen 
"""
function choose_eqs_n(R::Vector{RewriteRule}, C::Vector{RewriteRule}, n, step, variables, ::Type{CVec})::Vector{RewriteRule} where {CVec}
    K::Vector{RewriteRule} = []
        while !isempty(C)
            selection = select!(step, C)
            best = filter(is_valid, selection)
            bad = filter(!is_valid, selection)
            # TODO add bad to proven_unequal, I need to get the eclasses of the bad rules
            # TODO in the paper, the rules themselves are added to proven_unequal, not the classes they come from
            # TODO but isnt it better to add the classes?
            # TODO if classes are added, I need to keep track of how they progress to update this accordingly;
            # TODO if class 2 and 3 end up merging, all forbidden rules with 3 need to be with 2

            push!(K, best...)
            if length(K) ≥ n
                return K[1:n]
            end
            # Shrink C with the kind of arbitrary set K until all rules in C are seen
            C = shrink(R ∪ K, C, variables, CVec)
            unique!(r -> [r.lhs_original, r.rhs_original], C)
        end
    return K
end

"""
Select the "best" set of rules from the candidate set C
If n=Inf, the minimal set of rules that, together with the already found rules, can prove all other valid rules
"""
function choose_eqs(R::Vector{RewriteRule}, C::Vector{RewriteRule}, variables, ::Type{CVec}, n=Inf)::Vector{RewriteRule} where {CVec}
    for step in 101:-10:1 # TODO why this arbitrary iteration system
        if step ≤ n
            C = choose_eqs_n(R::Vector{RewriteRule}, C::Vector{RewriteRule}, n, step, variables, CVec)
        end
    end
    return C
end

"""
Find the minimal set of rewrite rules that can prove all equalities in a term set T
"""
function ruler(iterations::Int, D::Dict{Int, Vector{AllTypes}}, variables::Vector{Symbol}, ::Type{CVec}) where {AllTypes, CVec}
    # Start with an empty E-Graph and no rewrite rules
    T = EGraph{Expr, Vector{CVec}}() 
    R::Vector{RewriteRule} = []

    for i in 0:iterations
        println("Iteration $i of $iterations, add terms to T")
        # Add a batch of terms from the term set to T
        add_terms!(T, D, i) 
        
        println("Added terms to T, run cvec_match")

        # Find all candidate rewrite rules in T
        C::Vector{RewriteRule} = cvec_match(T, variables, CVec)

        println("Found $(length(C)) candidate rules")

        # Select the best rules from the candidate set
        while !isempty(C)
            # Add a batch of found best rules from C to R
            union!(R, choose_eqs(R, C, variables, CVec))
            println("Found $(length(R)) rules, run them on T")

            # Update T with R, guarantees the selected rules will not be considered again
            run_rewrites!(T, R)
            println("Run cvec_match again")

            # Update C
            C = cvec_match(T, variables, CVec)
            println("Found $(length(C)) candidate rules")
        end
    end
    println()
    T,R
end

end