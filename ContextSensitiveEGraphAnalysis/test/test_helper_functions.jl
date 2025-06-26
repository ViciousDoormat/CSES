include("../src/helper_functions.jl")

using Test

@testset "contains_variable" begin
    @test contains_variable(:x,:x)
    @test !contains_variable(:(1),:x)
    @test contains_variable(:(x+1),:x)
    @test contains_variable(:(1+x),:x)
    @test contains_variable(:(x+y),:x)
    @test contains_variable(:(x+x),:x)
    @test !contains_variable(:(y+1),:x)
    @test contains_variable(:(1+1+x),:x)
    @test contains_variable(:(x+1+1),:x)
    @test contains_variable(:(1+x+1),:x)
    @test !contains_variable(:(1+1+1),:x)
    @test contains_variable(:(1+-x+1),:x)
    @test contains_variable(:(1-(-x)),:x)
end

@testset "count_operators" begin
    @test count_operators(:x) == 0
    @test count_operators(:(1)) == 0
    @test count_operators(:(x+1)) == 1
    @test count_operators(:(1+x)) == 1
    @test count_operators(:(x+y)) == 1
    @test count_operators(:(x+x)) == 1
    @test count_operators(:(y+1)) == 1
    @test count_operators(:(1+(1+x))) == 2
    @test count_operators(:((x+1)+1)) == 2
    @test count_operators(:(1+(x+1))) == 2
    @test count_operators(:(1+(1+1))) == 2
    @test count_operators(:((1+(-x))+1)) == 3
    @test count_operators(:(1-(-x))) == 2
end

@testset "count_operators" begin
    @test count_operators(:x) == 0
    @test count_operators(:(1)) == 0
    @test count_operators(:(x+1)) == 1
    @test count_operators(:(1+x)) == 1
    @test count_operators(:(x+y)) == 1
    @test count_operators(:(1+(1+x))) == 2
    @test count_operators(:((x+1)+1)) == 2
    @test count_operators(:(1+(1+1))) == 2
    @test count_operators(:((1+(-x))+1)) == 3
    @test count_operators(:(1-(-x))) == 2
end

@testset "group_by_operator_count" begin
    @test group_by_operator_count(Set([:x, :1, :(x+1), :(1+x), :(x+y), :(1+(1+x)), :((x+1)+1), :(1+(1+1)), :((1+(-x))+1), :(1-(-x))])) == 
    (Dict{Int64, Vector{Any}}(0 => [1, :x], 2 => [:(1 + (1 + x)), :((x + 1) + 1), :(1 + (1 + 1)), :(1 - -x)], 3 => [:((1 + -x) + 1)], 1 => [:(1 + x), :(x + y), :(x + 1)]), 3)
end 

@testset "replace_with_symbol" begin
    @test replace_with_symbol(:x,[:x]) == :(:x)
    @test replace_with_symbol(:(1),[:x]) == :(1)
    @test replace_with_symbol(:(x+1),[:x]) == :(:x+1)
    @test replace_with_symbol(:(1+x),[:x]) == :(1+:x)
    @test replace_with_symbol(:(x+y),[:x]) == :(:x+y)
    @test replace_with_symbol(:(x+y),[:x,:y]) == :(:x+:y)
    @test replace_with_symbol(:(x+x),[:x]) == :(:x+:x)
    @test replace_with_symbol(:(y+1),[:x]) == :(y+1)
    @test replace_with_symbol(:(1+1+x),[:x]) == :(1+1+:x)
    @test replace_with_symbol(:((x+1)+1),[:x]) == :((:x+1)+1)
    @test replace_with_symbol(:(1+(x+1)),[:x]) == :(1+(:x+1))
    @test replace_with_symbol(:(1+1+1),[:x]) == :(1+1+1)
    @test replace_with_symbol(:(1+((-x)+1)),[:x]) == :(1+((-(:x))+1))
end 

@testset "replace_back_to_expr" begin
    @test replace_back_to_expr(:(:x),[:x]) == :x
    @test replace_back_to_expr(:(1),[:x]) == :(1)
    @test replace_back_to_expr(:(:x+1),[:x]) == :(x+1)
    @test replace_back_to_expr(:(1+:x),[:x]) == :(1+x)
    @test replace_back_to_expr(:(:x+:y),[:x]) == :(x+:y)
    @test replace_back_to_expr(:(:x+:y),[:x,:y]) == :(x+y)
    @test replace_back_to_expr(:(:x+:x),[:x]) == :(x+x)
    @test replace_back_to_expr(:(y+1),[:x]) == :(y+1)
    @test replace_back_to_expr(:(1+1+:x),[:x]) == :(1+1+x)
    @test replace_back_to_expr(:((:x+1)+1),[:x]) == :((x+1)+1)
    @test replace_back_to_expr(:(1+(:x+1)),[:x]) == :(1+(x+1))
    @test replace_back_to_expr(:(1+1+1),[:x]) == :(1+1+1)
    @test replace_back_to_expr(:(1+((-(:x))+1)),[:x]) == :(1+((-x)+1))
end 

@testset "add_symbol_type" begin
    @test add_symbol_type(:x,[:x]) == :(x::Symbol)
    @test add_symbol_type(:y,[:x]) == :y
    @test add_symbol_type(1,[:x]) == 1
    @test add_symbol_type(:(x+1),[:x]) == :(x::Symbol + 1)
    @test add_symbol_type(:(1+x),[:x]) == :(1 + x::Symbol)
    @test add_symbol_type(:(1+1),[:x]) == :(1+1)
    @test add_symbol_type(:(1+(1+1)),[:x]) == :(1+(1+1))
    @test add_symbol_type(:(1+(1+x)),[:x]) == :(1+(1+x::Symbol))
    @test add_symbol_type(:(1-(-x)),[:x]) == :(1-(-x::Symbol))
end

@testset "remove_symbol_type" begin
    @test remove_symbol_type(:(x::Symbol),[:x]) == :x
    @test remove_symbol_type(:y,[:x]) == :y
    @test remove_symbol_type(1,[:x]) == 1
    @test remove_symbol_type(:(x::Symbol + 1),[:x]) == :(x+1)
    @test remove_symbol_type(:(1 + x::Symbol),[:x]) == :(1+x)
    @test remove_symbol_type(:(1+1),[:x]) == :(1+1)
    @test remove_symbol_type(:(1+(1+1)),[:x]) == :(1+(1+1))
    @test remove_symbol_type(:(1+(1+x::Symbol)),[:x]) == :(1+(1+x))
    @test remove_symbol_type(:(1-(-x::Symbol)),[:x]) == :(1-(-x))
end

# Ruler’s syntactic heuristic prefers candidates with the following characteristics (lexicographically): 
# more distinct variables, fewer constants, shorter larger side (between the two terms forming the candidate), 
# shorter smaller side, and fewer distinct operators.
@testset "compare_rules_test" begin
    @test compare_rules(:(x+(y+z)),:(a+(b+c)),:(z+(y+x)),:(c+(b+a)),[:x,:y,:z,:a,:b,:c]) == true #equal in this context
    @test compare_rules(:(x+(y+z)),:(a+(b+c)),:(x+(a+c)),:(b+(y+z)),[:x,:y,:z,:a,:b,:c]) == true #equal in this context
    @test compare_rules(:(x+(y+z)),:(a+(b+c)),:(x+y),:(a+b),[:x,:y,:z,:a,:b,:c]) == true #left one has more vars, even though right one is shorter
    @test compare_rules(:(x+y),:(a+b),:(x+(y+y)),:(a+(b+b)),[:x,:y,:z,:a,:b,:c]) == true #left one is shorter
    @test compare_rules(:(x+(y+(z+x))),:(a+(b+c)),:(x+(y+(z+1))),:(a+(b+c)),[:x,:y,:z,:a,:b,:c]) == true #left has no constants
    @test compare_rules(:(x+(y+z)),:(a+(b+c)),:(x+y),:(x+(y+(z+(a+(b+c))))),[:x,:y,:z,:a,:b,:c]) == true #left has shorter largest side
    @test compare_rules(:(x+(y+z)),:(a+(b+c)),:(x+(y+z)),:(a+(b+(c+c))),[:x,:y,:z,:a,:b,:c]) == true #left has shorter smaller side
end

xs = [[:(x+(y+z)),:(a+(b+c))],[:(z+(y+x)),:(c+(b+a))], [:(x+(y+z)),:(a+(b+c))],[:(x+(a+c)),:(b+(y+z))],[:(x+(y+z)),:(a+(b+c))],[:(x+y),:(a+b)],
[:(x+y),:(a+b)],[:(x+(y+y)),:(a+(b+b))],[:(x+(y+(z+x))),:(a+(b+c))],[:(x+(y+(z+1))),:(a+(b+c))],[:(x+(y+z)),:(a+(b+c))],[:(x+y),:(x+(y+(z+(a+(b+c)))))],[:(x+(y+z)),:(a+(b+c))],[:(x+(y+z)),:(a+(b+(c+c)))]]
vars = [:x,:y,:z,:a,:b,:c]
sort_rules(xs,vars)
