module Helper

export contains_variable, count_operators, group_by_operator_count, replace_with_symbol, replace_back_to_expr, add_symbol_type, remove_symbol_type
export bvneg_cvc, bvnot_cvc, bvadd_cvc, bvsub_cvc, bvxor_cvc, bvand_cvc, bvor_cvc, bvshl_cvc, bvlshr_cvc, bvashr_cvc, bvnand_cvc
export bvnor_cvc, ehad_cvc, arba_cvc, shesh_cvc, smol_cvc, im_cvc, if0_cvc

function contains_variable(expr, variable)
    if expr == variable
        return true
    elseif typeof(expr) == Expr 
        for arg in expr.args
            if arg == variable
                return true
            elseif typeof(arg) == Expr && contains_variable(arg, variable)
                return true
            end
        end
    end
    return false
end

# println(contains_variable(:x,:x))
# println(contains_variable(:(x+1),:x))
# println(contains_variable(:(1+x),:x))
# println(contains_variable(:(x+y),:x))
# println(contains_variable(:(x+x),:x))
# println(!contains_variable(:(y+1),:x))
# println(!contains_variable(:(1),:x))
# println(contains_variable(:(1+1+x),:x))
# println(contains_variable(:(x+1+1),:x))
# println(contains_variable(:(1+x+1),:x))
# println(!contains_variable(:(1+1+1),:x))


function count_operators(e::Union{AllTypes})::Int where {AllTypes}
    count = 0
    if typeof(e) == Expr
        count += 1
        for arg in e.args
            if typeof(arg) == Expr
                count += count_operators(arg)
            end
        end
    end
    return count
end

function group_by_operator_count(terms::Set{AllTypes})::Tuple{Dict{Int, Vector{AllTypes}}, Int} where {AllTypes}
    grouped = Dict{Int, Vector{AllTypes}}()
    max_count = 0
    for term in terms
        count = count_operators(term)
        if haskey(grouped, count)
            push!(grouped[count], term)
        else
            max_count = max(max_count, count)
            grouped[count] = [term]
        end
    end
    return grouped, max_count
end

function replace_with_symbol(e, variable)
    expr = deepcopy(e)
    if expr == variable
        return :($variable)
    elseif typeof(expr) == Expr 
        for (i,arg) in enumerate(expr.args)
            if arg == variable
                expr.args[i] = :($variable)
            elseif typeof(arg) == Expr
                expr.args[i] = replace_with_symbol(arg, variable)
            end
        end
    end
    return expr
end

function replace_back_to_expr(e, variable)
    expr = deepcopy(e)
    if expr == :($variable)
        return variable
    elseif typeof(expr) == Expr 
        for (i,arg) in enumerate(expr.args)
            if arg == :($variable)
                expr.args[i] = variable
            elseif typeof(arg) == Expr
                expr.args[i] = replace_back_to_expr(arg, variable)
            end
        end
    end
    return expr
end

function add_symbol_type(e, variable)
    expr = deepcopy(e)
    if expr == variable
        return :($(variable)::Symbol)
    elseif typeof(expr) == Expr 
        for (i,arg) in enumerate(expr.args)
            if arg == variable
                expr.args[i] = :($(variable)::Symbol)
            elseif typeof(arg) == Expr
                expr.args[i] = add_symbol_type(arg, variable)
            end
        end
    end
    return expr
end



# println("add_symbol_type")
# println(add_symbol_type(:x,:x))
# println(add_symbol_type(:y,:x))
# println(add_symbol_type(1,:x))
# println(add_symbol_type(:(x+1),:x))
# println(add_symbol_type(:(1+x),:x))
# println(add_symbol_type(:(1+1),:x))
# println(add_symbol_type(:(1+1+1),:x))
# println(add_symbol_type(:(1+1+x),:x))


function remove_symbol_type(e, variable)
    expr = deepcopy(e)
    if expr == :($(variable)::Symbol)
        return :(x)
    elseif typeof(expr) == Expr 
        for (i,arg) in enumerate(expr.args)
            if arg == :($(variable)::Symbol)
                expr.args[i] = :(x)
            elseif typeof(arg) == Expr
                expr.args[i] = remove_symbol_type(arg,variable)
            end
        end
    end
    return expr
end

# println("remove_symbol_type")
# println(remove_symbol_type(add_symbol_type(:x, :x),:x))
# println(remove_symbol_type(add_symbol_type(:y, :x),:x))
# println(remove_symbol_type(add_symbol_type(1, :x),:x))
# println(remove_symbol_type(add_symbol_type(:(x+1), :x),:x))
# println(remove_symbol_type(add_symbol_type(:(1+x), :x),:x))
# println(remove_symbol_type(add_symbol_type(:(1+1), :x),:x))
# println(remove_symbol_type(add_symbol_type(:(1+1+1), :x),:x))
# println(remove_symbol_type(add_symbol_type(:(1+1+x), :x),:x))

bvneg_cvc(n::UInt) = -n
bvnot_cvc(n::UInt) = ~n
bvadd_cvc(n1::UInt, n2::UInt) = n1 + n2
bvsub_cvc(n1::UInt, n2::UInt) = n1 - n2
bvxor_cvc(n1::UInt, n2::UInt) = n1 ⊻ n2 #xor
bvand_cvc(n1::UInt, n2::UInt) = n1 & n2
bvor_cvc(n1::UInt, n2::UInt) = n1 | n2
bvshl_cvc(n1::UInt, n2::Int) = n1 << n2
bvlshr_cvc(n1::UInt, n2::Int) = n1 >>> n2
bvashr_cvc(n1::UInt, n2::Int) = n1 >> n2
bvnand_cvc(n1::UInt, n2::UInt) = n1 ⊼ n2 #nand
bvnor_cvc(n1::UInt, n2::UInt) = n1 ⊽ n2 #nor

# CUSTOM functions

ehad_cvc(n::UInt) = bvlshr_cvc(n, 1)
arba_cvc(n::UInt) = bvlshr_cvc(n, 4)
shesh_cvc(n::UInt) = bvlshr_cvc(n, 16)
smol_cvc(n::UInt) = bvshl_cvc(n, 1)
im_cvc(x::UInt, y::UInt, z::UInt) = x == UInt(1) ? y : z
if0_cvc(x::UInt, y::UInt, z::UInt) = x == UInt(0) ? y : z

end