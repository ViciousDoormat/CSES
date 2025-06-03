using ContextSensitiveEGraphAnalysis
using HerbSearch
using HerbGrammar
using HerbSpecification
using HerbConstraints
using HerbCore 

const grammar1 = @csgrammar begin
    Number = |(0:4)
    Number = x
    Number = -Number
    Number = Number + Number
    Number = Number * Number
end

const examples = [[IOExample(Dict(:x => x), 2x + 1)] for x ∈ -10:10]

println(create_termset(examples, grammar1, :Number, [:y], Union{Int,Expr,Symbol}))