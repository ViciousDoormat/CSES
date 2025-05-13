module Helper

export contains_variable, count_operators, group_by_operator_count, replace_with_symbol, replace_back_to_expr, add_symbol_type, remove_symbol_type

function contains_variable(expr::ExprType) where {ExprType}
    if expr == :(x)
        return true
    elseif typeof(expr) == Expr 
        for arg in expr.args
            if arg == :(x)
                return true
            elseif typeof(arg) == Expr && contains_variable(arg)
                return true
            end
        end
    end
    return false
end

function count_operators(e::Union{Int64, ExprType, Symbol})::Int where {ExprType}
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

function group_by_operator_count(terms::Set{Union{Int64, ExprType, Symbol}})::Tuple{Dict{Int, Vector{Union{Int64, ExprType, Symbol}}}, Int} where {ExprType}
    grouped = Dict{Int, Vector{Union{Int64, ExprType, Symbol}}}()
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

function replace_with_symbol(e::ExprType) where {ExprType}
    expr = deepcopy(e)
    if expr == :(x)
        return :(:x)
    elseif typeof(expr) == Expr 
        for (i,arg) in enumerate(expr.args)
            if arg == :(x)
                expr.args[i] = :(:x)
            elseif typeof(arg) == Expr
                expr.args[i] = replace_with_symbol(arg)
            end
        end
    end
    return expr
end

function replace_back_to_expr(e::ExprType) where {ExprType}
    expr = deepcopy(e)
    if expr == :(:x)
        return :(x)
    elseif typeof(expr) == Expr 
        for (i,arg) in enumerate(expr.args)
            if arg == :(:x)
                expr.args[i] = :(x)
            elseif typeof(arg) == Expr
                expr.args[i] = replace_back_to_expr(arg)
            end
        end
    end
    return expr
end

function add_symbol_type(e::ExprType) where {ExprType}
    expr = deepcopy(e)
    if expr == :(x)
        return :(x::Symbol)
    elseif typeof(expr) == Expr 
        for (i,arg) in enumerate(expr.args)
            if arg == :(x)
                expr.args[i] = :(x::Symbol)
            elseif typeof(arg) == Expr
                expr.args[i] = add_symbol_type(arg)
            end
        end
    end
    return expr
end

function remove_symbol_type(e::ExprType) where {ExprType}
    expr = deepcopy(e)
    if expr == :(x::Symbol)
        return :(x)
    elseif typeof(expr) == Expr 
        for (i,arg) in enumerate(expr.args)
            if arg == :(x::Symbol)
                expr.args[i] = :(x)
            elseif typeof(arg) == Expr
                expr.args[i] = remove_symbol_type(arg)
            end
        end
    end
    return expr
end

end