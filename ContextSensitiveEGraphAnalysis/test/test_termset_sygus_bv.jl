include("../src/helper_functions.jl")
include("../src/termset.jl")

using ContextSensitiveEGraphAnalysis
using HerbBenchmarks
using HerbBenchmarks.SyGuS
using MLStyle

zero = 1
one = 2
arg1 = 3
not = 4
leftone = 5
urightone = 6
urightfour = 7
urightsixteen = 8
and = 9
or = 10
xor = 11
plus = 12
isone = 13

function add_constraints!(grammar)
    addconstraint!(grammar, Ordered(RuleNode(and, [VarNode(:a), VarNode(:b)]), [:a, :b]))
    addconstraint!(grammar, Ordered(RuleNode(or, [VarNode(:a), VarNode(:b)]), [:a, :b]))
    addconstraint!(grammar, Ordered(RuleNode(plus, [VarNode(:a), VarNode(:b)]), [:a, :b]))
    addconstraint!(grammar, Forbidden(RuleNode(not, [RuleNode(not,[VarNode(:A)])])))
    addconstraint!(grammar, Forbidden(RuleNode(plus, [VarNode(:A), zero]))) # A + 0
    addconstraint!(grammar, Forbidden(RuleNode(plus, [zero, VarNode(:A)]))) # 0 + A
    addconstraint!(grammar, Forbidden(RuleNode(and, [VarNode(:A), VarNode(:A)]))) 
    addconstraint!(grammar, Forbidden(RuleNode(or, [VarNode(:A), VarNode(:A)]))) 
    addconstraint!(grammar, Forbidden(RuleNode(isone, [VarNode(:A), VarNode(:B), VarNode(:B)])))
    addconstraint!(grammar, Forbidden(RuleNode(isone, [one, VarNode(:A), VarNode(:B)])))
    addconstraint!(grammar, Forbidden(RuleNode(isone, [zero, VarNode(:A), VarNode(:B)])))
end

function interpret_sygus_bv(expr, state=nothing)
    if typeof(expr) != Expr 
        return typeof(expr) == Symbol && state !== nothing && haskey(state,expr) ? state[expr] : expr
    end

    c = expr.args
    head = expr.head

    if head != :call
        error(head)
    end

    MLStyle.@match c[1] begin
            :bvnot_cvc       => bvnot_cvc(interpret_sygus_bv(c[2], state))
            :smol_cvc        => smol_cvc(interpret_sygus_bv(c[2], state))
            :ehad_cvc        => ehad_cvc(interpret_sygus_bv(c[2], state))
            :arba_cvc        => arba_cvc(interpret_sygus_bv(c[2], state))
            :shesh_cvc       => shesh_cvc(interpret_sygus_bv(c[2], state))
            :bvand_cvc       => bvand_cvc(interpret_sygus_bv(c[2], state),interpret_sygus_bv(c[3], state))
            :bvor_cvc        => bvor_cvc(interpret_sygus_bv(c[2], state),interpret_sygus_bv(c[3], state))
            :bvxor_cvc       => bvxor_cvc(interpret_sygus_bv(c[2], state),interpret_sygus_bv(c[3], state))
            :bvadd_cvc       => bvadd_cvc(interpret_sygus_bv(c[2], state),interpret_sygus_bv(c[3], state))
            :im_cvc          => im_cvc(interpret_sygus_bv(c[2], state),interpret_sygus_bv(c[3], state),interpret_sygus_bv(c[4], state))
            _                => error("huilen")
    end
end

#pair = get_problem_grammar_pair(PBE_BV_Track_2018, "PRE_102_10")
pair = get_problem_grammar_pair(PBE_BV_Track_2018, "PRE_112_10")
g = pair.grammar

#add_constraints_remove_characters_from_right!(g)
examples = map(example -> [example], pair.problem.spec)

#println(generate_small_terms(g, 3, nothing, examples))
#println(create_termset(examples, g, :Start, [:_arg_1], Union{UInt, Expr, Symbol}, 1, 4))

solve(examples, g, :Start, [:_arg_1], Union{UInt, Expr, Symbol}, Union{UInt, Symbol}, 1, 3, interpret_sygus_bv)