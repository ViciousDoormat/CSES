using Metatheory
using Metatheory.Library
using Metatheory.EGraphs

#Steps:
#1) try to test the cvec thing DONE
#2) find out what R should be DONE
#3) make a dumb implementation of add terms DONE
#4) implement cvec_match DONE (for now at least)
#5) merging eclasses found equivalent in T in run_rewrites
#6) implement shrink and other choose_eqs stuff

#TODO it should contain the output values. what is a great type for output values?
#TODO Maybe dependent on the domain? For integers just Int, for the absolute function Union(Int,Bool) something like that?
#TODO or does Symbol generally work as I can translate everything to it? If so, how?
#TODO For Now Int is fine, but this should be changed to the actual output type of the domain or something general
#const CVecAnalysis = Vector{Int} # According to the paper, cvecs consist of only the output
const CVecAnalysis = Vector{Float64}

#TODO this should probably become the number of IO examples per egraph???
#const N = 1 #The number of outputs in a cvec
#const N = 2
const N = 5

const proven_unequal = Set{Tuple{Id, Id}}() #A set of eclasses that have been proven unequal

"""
The values of the target domain used for the cvecs of variables.
In my case, this can directly be taken from the IO example(s) per EGraph.
Meaning that this will just return the output(s) of the IO example(s) that correspond with an EGraph.
"""
function variable_cvec()::CVecAnalysis
    #return [5] # the output of an IO example
    #return [true, false]
    return [0,1,2,3,4]
end

"""
Two cvecs match when all, and at least one, non-nothing elements are equal.
"""
function equal_cvecs(a::CVecAnalysis, b::CVecAnalysis)::Bool
    all_equal = true
    at_least_one_equal = false
    for i in eachindex(a)
        if a[i] === nothing || b[i] === nothing || isnan(a[i]) || isnan(b[i])
            continue
        end
        if a[i] != b[i] #TODO maybe !==
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
function EGraphs.make(g::EGraph{ExprType, CVecAnalysis}, n::VecExpr)::CVecAnalysis where {ExprType}
    op = get_constant(g, v_head(n)) #this is the first element of a new eclass.

    #when t꜀ is a constant n, return N copies of n
    if !v_isexpr(n)
        #when t꜀ is a variable x, return N values from the target domain (randomly or in some specific way)
        if typeof(op) == Symbol
            return variable_cvec()
        end

        return fill(op, N)
    end

    #when t꜀ is a function call f(c1, c2, ..., cn), return map(f, zip(v1, v2, ..., vn))
    if v_iscall(n)
        #all cvecs of the children of n
        children_cvecs = map(c -> g[c].data, v_children(n))

        #n gets called in all these ways
        parameter_possibilities = zip(children_cvecs...)

        #call op, that represents n, in all those ways
        cvec = map(params -> eval(maketerm(Expr, :call, [op, params...], nothing)), parameter_possibilities)

        return cvec
    else
        error("Unknown term type")
    end
end

"""
Join the cvecs of two merging eclasses.
"""
# TODO how should this actually be done? If they match, but a has nothings that b does not have and vice versa, what should be done?
function EGraphs.join(a::CVecAnalysis, b::CVecAnalysis)::CVecAnalysis
    equal_cvecs(a,b) || error("Cannot join different cvecs")
    a #TODO should the one with the least/most nothing values be chosen? or should they be merged?
end

# EGraphs.modify! should not be required for cvecs. Maybe it could do something like add the canonical term

# #cvec tests:
# #test one, making singular and inductive cases
# expr = :(a+0)
# g = EGraph{Expr, CVecAnalysis}(:($expr))
# #test two, joining cvecs
# t = @theory a begin
#     a + 0 == a
# end
# saturate!(g, t)
# println(g)

"""
Adding terms to an egraph. Rudimentory implementation
"""
function add_terms!(g::EGraph{ExprType, CVecAnalysis}, i) where {ExprType}
    #TODO maybe the root should be set?

    # if i == 0
    #     addexpr!(g, :(a))
    #     addexpr!(g, 0)
    # else
    #     addexpr!(g, :(a+0))
    # end
    # if i == 0
    #     addexpr!(g, :(a))
    #     addexpr!(g, false)
    # else i == 1
    #     addexpr!(g, :(a ⊻ a))
    #     addexpr!(g, :(a & false))
    # end
    if i == 0
        addexpr!(g, :(a))
        addexpr!(g, 1)
    else i == 1
        addexpr!(g, :(a / a))
    end
end
"""
Returns a collection of rewrite rules from pairs of eclasses that have the same cvec.
If two eclasses were seen before and proven unequal, the rule they form should not be in the output.
"""
function cvec_match(g::EGraph{ExprType, CVecAnalysis}) where {ExprType}
    eclasses = g.classes
    C::Vector{RewriteRule} = []

    ids = collect(keys(eclasses))

    for i in 1:(length(ids)-1)
        key_x = ids[i]
        x::CVecAnalysis = eclasses[key_x].data

        for j in (i+1):length(ids)
            key_y = ids[j]   
            y::CVecAnalysis = eclasses[key_y].data

            if equal_cvecs(x, y) && (key_x.val, key_y.val) ∉ proven_unequal
                #In the paper, the so called canonical term is extracted. afaik MT does not have this concept
                #Therefore, I currently extract the smallest term. I could maybe append the concept to MT instead?
                x_can = extract!(g, astsize, key_x.val)
                y_can = extract!(g, astsize, key_y.val)
                r₁ = eval(:(@slots a @rule $x_can --> $y_can))
                r₂ = eval(:(@slots a @rule $y_can --> $x_can))
                #errors for false == a xor a because a is not at the left side of the equation
                #this should become    
                push!(C, r₁)
                push!(C, r₂)
            end
        end
    end

    return C
end

# #test cvec_match
# expr = :(a+0)
# g = EGraph{Expr, CVecAnalysis}(:($expr))
# println(cvec_match(g))

"""
Saturate T based on R without polluting T with intermediate terms added during equality saturation.
"""
function run_rewrites!(T::EGraph{ExprType, CVecAnalysis}, R::Vector{RewriteRule}) where {ExprType}
    # To ensure that run_rewrites only shrinks the term e-graph, Ruler performs this equality
    # saturation on a copy of the e-graph
    g = deepcopy(T)
    saturate!(g, R)

    initial_classes = Set(c.val for c in keys(T.classes))

    # and then copies the newly learned equalities (e-class merges) back to the original e-graph. 
    # This avoids polluting the e-graph with terms added during equality saturation.
    for (initial, final) in enumerate(g.uf.parents)
        if initial != final && initial in initial_classes && final in initial_classes
            #initial = Metatheory.EGraphs.IdKey(initial)
            #final = Metatheory.EGraphs.IdKey(final)
            #Metatheory.EGraphs.merge!(initial, final)
            Metatheory.EGraphs.union!(T, UInt(initial), UInt(final))
        end
    end

    #In case the above approach does actually not work, this might be a solution:

    # visited = Set()
    # components::Vector{Set{UInt64}} = []

    # for node in keys(adjacency_list)
    #     if node ∉ visited
    #         queue = [node]
    #         component = Set()
    #         while !isempty(queue)
    #             current = pop!(queue)
    #             if current ∉ visited
    #                 push!(visited, current)
    #                 push!(component, current)
    #                 for neighbor in adjacency_list[current]
    #                     if neighbor ∉ visited
    #                         push!(queue, neighbor)
    #                     end
    #                 end
    #             end
    #         end
    #         push!(components, component)
    #     end
    # end
    
    # initial_classes = Set(c.val for c in keys(T.classes))
    # for component::Set{UInt64} in components
    #     filter!(c -> c in initial_classes, component)
    #     to_merge = collect(component)
    #     if length(component) > 1
    #         Metatheory.EGraphs.union!(T, to_merge...)
    #     end    
    # end

    # return components
end

# #test run_rewrites!
# expr = :(a+0)
# g = EGraph{Expr, CVecAnalysis}(:($expr))
# t = @theory a begin
#     a + 0 == a
# end
# rules::Vector{RewriteRule} = [@slots a @rule a == a+0]
# run_rewrites!(g, rules)
# println(g)

function shrink(R::Vector{RewriteRule}, C::Vector{<:RewriteRule}, ::Type{ExprType}) where {ExprType}
    E = EGraph{ExprType, CVecAnalysis}() 
    classes_per_rule = []
    for r in C
        left_id = addexpr!(E, r.lhs_original)
        right_id = addexpr!(E, r.rhs_original)
        push!(classes_per_rule, (left_id, right_id))
    end
    run_rewrites!(E, R)

    #TODO in the paper they return extract instead of r. This should be fine too however, I dont think it matters much
    return [r for (i, r) in enumerate(C) if find(E, classes_per_rule[i][1]) != find(E, classes_per_rule[i][2])]
end

# expr = :(a+0)
# g = EGraph{Expr, CVecAnalysis}(:($expr))
# rules = cvec_match(g)
# println(shrink(rules, rules, Expr))

#TODO add heuristic for choosing the best rule
function select!(step, C::Vector{<:RewriteRule})
    # Ruler’s syntactic heuristic prefers candidates with the following characteristics (lexicographically): 
    # more distinct variables, fewer constants, shorter larger side (between the two terms forming the candidate), 
    # shorter smaller side, and fewer distinct operators.

    #idea: make a sort function that sorts based on the above criteria
    #then take the first step elements

    #num of variables should I think just be length(r.patvars)


    [pop!(C) for _ in 1:(min(step, length(C)))]
end

# #test select!
# println(select!(1, cvec_match(g)))

function is_valid(r::RewriteRule)
    #TODO potentially implement
    true
end

function choose_eqs_n(R::Vector{RewriteRule}, C::Vector{RewriteRule}, n, step, ::Type{ExprType}) where {ExprType}
    K::Vector{RewriteRule} = []
        while !isempty(C)
            selection = select!(step, C)
            best = filter(is_valid, selection)
            bad = filter(!is_valid, selection)
            #to add bad to proven_unequal, I need to get the eclasses of the bad rules
            #I think the rules are not used before here. Thus I can maybe not create rules in cvec_match and just return the eclasses there
            #and then here create the rules corresponding to those.

            push!(K, best...)
            if length(K) ≥ n
                return K[1:n]
            end
            C = shrink(R ∪ K, C, ExprType)
        end
    return K
end

function choose_eqs(R::Vector{RewriteRule}, C::Vector{RewriteRule}, ::Type{ExprType}, n=Inf) where {ExprType} #TODO add is_valid
    for step in 1:1 #TODO temp
    #for step in 100:10:1
        if step ≤ n
            C = choose_eqs_n(R, C, n, step, ExprType)
        end
    end
    return C
end

function ruler(iterations, ::Type{ExprType}) where {ExprType}
    #start with an empty egraph and collection of rewrite rules
    T = EGraph{ExprType, CVecAnalysis}() 
    R::Vector{RewriteRule} = []

    for i in 0:iterations
        #important that this does not already join eclasses. But it should not be able to as there are not rules
        add_terms!(T, i) 
        C::Vector{RewriteRule} = cvec_match(T)
        while !isempty(C)
            union!(R, choose_eqs(R, C, ExprType))
            run_rewrites!(T, R)
            C = cvec_match(T)
        end
    end
    T,R
end

T,r = ruler(1, Expr)
a = 5