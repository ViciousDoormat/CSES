using Metatheory
using Metatheory.Library
using Metatheory.EGraphs

#Steps:
#1) try to test the cvec thing DONE
#2) find out what R should be DONE
#3) make a dumb implementation of add terms DONE
#4) implement cvec_match MOSTLY DONE
#4) find out how two terms can be made into a rule, then add to C.
#5) merging eclasses found equivalent in T in run_rewrites
#6) implement shrink and other choose_eqs stuff

#TODO is should contain the output values. what is a great type for output values?
#TODO Maybe dependent on the domain? For integers just Int, for the absolute function Union(Int,Bool) something like that?
#TODO or does Symbol generally work as I can translate everything to it? If so, how?
#TODO For Now Int is fine, but this should be changed to the actual output type of the domain or something general
const CVecAnalysis = Vector{Int} # According to the paper, cvecs consist of only the output

#TODO this should probably become the number of IO examples per egraph???
const N = 1 #The number of outputs in a cvec

const proven_unequal = Set{Tuple{Id, Id}}() #A set of eclasses that have been proven unequal

"""
The values of the target domain used for the cvecs of variables.
In my case, this can directly be taken from the IO example(s) per EGraph.
Meaning that this will just return the output(s) of the IO example(s) that correspond with an EGraph.
"""
function variable_cvec()::CVecAnalysis
    return [5] # the output of an IO example
end

"""
Two cvecs match when all, and at least one, non-nothing elements are equal.
"""
function equal_cvecs(a::CVecAnalysis, b::CVecAnalysis)::Bool
    all_equal = true
    at_least_one_equal = false
    for i in eachindex(a)
        if a === nothing || b === nothing
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

# EGraphs.modify! should not be required for cvecs

#cvec tests:
#test one, making singular and inductive cases
expr = :(a+0)
g = EGraph{Expr, CVecAnalysis}(:($expr))
#test two, joining cvecs
t = @theory a begin
    a + 0 == a
end
saturate!(g, t)
println(g)

"""
Adding terms to an egraph. Rudimentory implementation
"""
function add_terms!(g::EGraph{ExprType, CVecAnalysis}, i) where {ExprType}
    #TODO maybe the root should be set?

    if i == 0
        addexpr!(g, :(a))
        addexpr!(g, 0)
    else
        addexpr!(g, :(a+0))
    end
end

"""
Returns a collection of pairs of eclasses that have the same cvec.
If two eclasses were seen before and proven unequal, they should not be in the output.
"""
x_can = nothing
y_can = nothing
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

            if equal_cvecs(x, y) && (key_x, key_y) ∉ proven_unequal
                global x_can = extract!(g, astsize, eclasses[key_x].id) #TODO WHYYYYYYYYYY CANT THIS BE key_x?????????????????????????????
                global y_can = extract!(g, astsize, eclasses[key_y].id) 

                #TODO how can I do this
                #TODO maybe just directly make a RewriteRule()
                #r = RewriteRule("kaas", Metatheory.Rules.==, )
                r = @rule x_can == y_can
                #it must use global vars for some reason but here uses unupdated version; nothing == nothing
                adsds = 2 
                
                push!(C, r)
            end
        end
    end

    return C
end

#test cvec_match
expr = :(a+0)
g = EGraph{Expr, CVecAnalysis}(:($expr))
cvec_match(g)

#TODO
select!(step, C::Vector{RewriteRule}) = [pop!(C) for _ in 1:step]

function shrink(C::Vector{RewriteRule}, R::Vector{RewriteRule})
    E = EGraph{ExprType, CVecAnalysis}() 
    for r in C
        #addexpr!(g, r.l)
        #addexpr!(g, r.r)
    end
    run_rewrites!(E, R)
    for r in C
        #if r.l and r.r are in the same eclass, remove r from C
    end
    C
end

function choose_eqs(R::Vector{RewriteRule}, C::Vector{RewriteRule}) #TODO add n and potentially is_valid
    for step in 100:10:1
        K::Vector{RewriteRule} = []
        while !isempty(C)
            best = select!(step, C)
            push!(K, best)
            C = shrink(C, R ∪ K)
        end
    end
end

function run_rewrites!(T::EGraph{ExprType, CVecAnalysis}, R::Vector{RewriteRule}) where {ExprType}
    # To ensure that run_rewrites only shrinks the term e-graph, Ruler performs this equality
    # saturation on a copy of the e-graph, and then copies the newly learned equalities (e-class merges)
    # back to the original e-graph. This avoids polluting the e-graph with terms added during equality
    # saturation, i.e., it prevents enumeration of new terms based on intermediate terms introduced
    # during equality saturation.

    g = deepcopy(T)

    saturate!(g, R)

    #TODO maybe: for all eclasses in T, check if in g. If in g, someone make it the one from g. if not, delete it from T

    #merge eclasses in T that were merged in g
    union!(T, a, b) #TODO
end

#test run_rewrites!
# expr = :(a+0)
# g = EGraph{Expr, CVecAnalysis}(:($expr))
# t = @theory a begin
#     a + 0 == a
# end
# run_rewrites!(g, t)


function ruler(iterations, ::Type{ExprType}) where {ExprType}
    #start with an empty egraph and collection of rewrite rules
    T = EGraph{ExprType, CVecAnalysis}() 
    R::Vector{RewriteRule} = []

    for i in 0:iterations
        #important that this does not already join eclasses. But it should not be able to as there are not rules
        add_terms!(T, i) 
        C::Vector{RewriteRule} = cvec_match(T)
        while !isempty(C)
            union!(R, choose_eqs(R, C))
            run_rewrites!(T, R)
            C = cvec_match(T)
        end
    end
    T,R
end

ruler(1, Expr)