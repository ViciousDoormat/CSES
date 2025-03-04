using Metatheory
using Metatheory.Library

# struct OddEvenAnalysis
#     s::Symbol # :odd or :even 
# end

struct PositiveNegativeNumber
    s::Symbol # :positive or :negative
end

# Should be called only if isexpr(n) is false
# odd_even_base_case(val::Integer) = OddEvenAnalysis(iseven(val) ? :even : :odd)

positive_negative_base_case(val::Integer) = NaturalNumber(val ≥ 0 ? :positive : :negative)

# By default, literals that are not integers yield no analysis value.
# In this case you should return `nothing`
# odd_even_base_case(val) = nothing

positive_negative_base_case(val) = nothing

# function EGraphs.make(g::EGraph{ExpressionType,OddEvenAnalysis}, n::VecExpr) where {ExpressionType}
#     op = get_constant(g, v_head(n))
#     @show n,op

#     v_isexpr(n) || return odd_even_base_case(op)
#     # The e-node is not a literal value,
#     # Let's consider only binary function call terms.
#     child_eclasses = v_children(n)
#     if v_iscall(n) && length(child_eclasses) == 2
#         # Get the left and right child eclasses
#         l,r = g[child_eclasses[1]],  g[child_eclasses[2]]

#         if !isnothing(l.data) && !isnothing(r.data) 
#             if op == :*
#                 if l.data == r.data
#                     l.data
#                 elseif (l.data.s == :even || r.data.s == :even) 
#                     OddEvenAnalysis(:even)
#                 end
#             elseif op == :+
#                 (l.data == r.data) ? OddEvenAnalysis(:even) : OddEvenAnalysis(:odd)
#             end
#         elseif isnothing(l.data) && !isnothing(r.data) && op == :*
#             r.data
#         elseif !isnothing(l.data) && isnothing(r.data) && op == :*
#             l.data
#         end
#     end
# end

function EGraphs.make(g::EGraph{ExpressionType,OddEvenAnalysis}, n::VecExpr) where {ExpressionType}
    op = get_constant(g, v_head(n))
    @show n,op

    v_isexpr(n) || return positive_negative_base_case(op)
    # The e-node is not a literal value,
    # Let's consider only binary function call terms.
    child_eclasses = v_children(n)
    if v_iscall(n) && length(child_eclasses) == 2
        # Get the left and right child eclasses
        l,r = g[child_eclasses[1]],  g[child_eclasses[2]]

        if !isnothing(l.data) && !isnothing(r.data) 
            if op == :*
                if l.data == r.data
                    l.data
                elseif (l.data.s == :even || r.data.s == :even) 
                    OddEvenAnalysis(:even)
                end
            elseif op == :+
                (l.data == r.data) ? OddEvenAnalysis(:even) : OddEvenAnalysis(:odd)
            end
        elseif isnothing(l.data) && !isnothing(r.data) && op == :*
            r.data
        elseif !isnothing(l.data) && isnothing(r.data) && op == :*
            l.data
        end
    end
end

# function EGraphs.join(a::OddEvenAnalysis, b::OddEvenAnalysis)
#     # an expression cannot be odd and even at the same time!
#     # this is contradictory, so we ignore the analysis value
#     a != b && error("contradiction") 
#     a
# end

function EGraphs.join(a::PositiveNegativeNumber, b::PositiveNegativeNumber)
    # an expression cannot be positive and negative at the same time!
    # this is contradictory, so we ignore the analysis value
    a != b && error("contradiction") 
    a
end

t = @theory a b c begin 
    a * (b * c) == (a * b) * c
    a + (b + c) == (a + b) + c
    a * b == b * a
    a + b == b + a
    a * (b + c) == (a * b) + (a * c)
end

function custom_analysis(expr)
    g = EGraph{Expr, OddEvenAnalysis}(expr)
    saturate!(g, t)
    a = g[g.root].data
    #println(a)
    return a
end

custom_analysis(:(3y * (2x*y)))