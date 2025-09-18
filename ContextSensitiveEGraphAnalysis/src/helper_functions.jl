
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

function group_by_operator_count(terms::Set{AllTypes})::Tuple{Dict{Int, Vector{AllTypes}}, Vector{Int}} where {AllTypes}
    grouped = Dict{Int, Vector{AllTypes}}()
    counts::Vector{Int} = []
    for term in terms
        count = count_operators(term)
        if haskey(grouped, count)
            push!(grouped[count], term)
        else
            push!(counts, count)
            grouped[count] = [term]
        end
    end
    return grouped, sort(counts)
end

function replace_with_symbol(e, variables)
    expr = deepcopy(e)
    for variable in variables
        if expr == variable
            return :($(QuoteNode(variable)))
        end
    end
    if typeof(expr) == Expr 
        for (i,arg) in enumerate(expr.args)
            if typeof(arg) == Expr
                expr.args[i] = replace_with_symbol(arg, variables)
            else
                for variable in variables
                    if arg == variable
                        expr.args[i] = :($(QuoteNode(variable)))
                        break
                    end
                end
            end
        end
    end
    return expr
end

function replace_back_to_expr(e, variables)
    expr = deepcopy(e)
    for variable in variables
        if expr == :($(QuoteNode(variable)))
            return variable
        end
    end
    if typeof(expr) == Expr 
        for (i,arg) in enumerate(expr.args)
            if typeof(arg) == Expr
                expr.args[i] = replace_back_to_expr(arg, variables)
            else
                for variable in variables
                    if arg == :($(QuoteNode(variable)))
                        expr.args[i] = variable
                        break
                    end
                end
            end
        end
    end
    return expr
end

function add_symbol_type(e, variables)
    expr = deepcopy(e)
    for variable in variables
        if expr == variable
            return :($(variable)::Symbol)
        end
    end
    if typeof(expr) == Expr 
        for (i,arg) in enumerate(expr.args)
            if typeof(arg) == Expr
                expr.args[i] = add_symbol_type(arg, variables)
            else
                for variable in variables
                    if arg == variable
                        expr.args[i] = :($(variable)::Symbol)
                        break
                    end
                end
            end
        end
    end
    return expr
end

function remove_symbol_type(e, variables)
    expr = deepcopy(e)
    for variable in variables
        if expr == :($(variable)::Symbol)
            return variable
        end
    end
    if typeof(expr) == Expr 
        for (i,arg) in enumerate(expr.args)
            if typeof(arg) == Expr
                expr.args[i] = remove_symbol_type(arg,variables)
            else
                for variable in variables
                    if arg == :($(variable)::Symbol)
                        expr.args[i] = variable
                        break
                    end
                end
            end
        end
    end
    return expr
end

# TODO add heuristic for choosing the best rule
# Ruler’s syntactic heuristic prefers candidates with the following characteristics (lexicographically): 
# more distinct variables, fewer constants, shorter larger side (between the two terms forming the candidate), 
# shorter smaller side, and fewer distinct operators.

#
function count_distinct_variables(lhs, rhs, vars)
    count = 0
    for v in vars
        if contains_variable(lhs, v) || contains_variable(rhs, v)
            count += 1
        end
    end
    return count
end

function count_constants(expr, vars)
    if typeof(expr) == Expr 
        count = 0
        for arg in expr.args
            if typeof(arg) == Expr
                count += count_constants(arg, vars)
            elseif typeof(expr) == Symbol && expr ∉ vars && expr != :any #TODO keep any?
                count += 1
            end
        end
        return count
    elseif typeof(expr) == Symbol && expr ∉ vars && expr != :any
        return 1
    end
    return 0
end

function compare_rules(fst1, fst2, snd1, snd2, vars)
    # First criterion: more distinct variables (so descending order)
    v1 = count_distinct_variables(fst1, fst2, vars)
    v2 = count_distinct_variables(snd1, snd2, vars)
    if v1 != v2
        return v1 > v2
    end

    # Second criterion: fewer constants
    c1 = count_constants(fst1, vars) + count_constants(fst2, vars)
    c2 = count_constants(snd1, vars) + count_constants(snd2, vars)
    if c1 != c2
        return c1 < c2
    end

    fst1_length,fst2_length = count_operators(fst1),count_operators(fst2)
    snd1_length,snd2_length = count_operators(snd1),count_operators(snd2)

    # Third criterion: shorter larger side
    fstmax = max(fst1_length, fst2_length)
    sndmax = max(snd1_length, snd2_length)
    if fstmax != sndmax
        return fstmax < sndmax
    end

    # Fourth criterion: shorter smaller side
    fstmin = min(fst1_length, fst2_length)
    sndmin = min(snd1_length, snd2_length)
    if fstmin != sndmin
        return fstmin < sndmin
    end

    return true

    # Fifth criterion: fewer distinct operators TODO
    # o1 = count_distinct_operators(rule1)
    # o2 = count_distinct_operators(rule2)
    # return o1 < o2
end

function sort_rules!(rules,vars)
    Base.sort!(rules, 
               by = r -> [replace_back_to_expr(r.lhs_original,vars), 
                          replace_back_to_expr(r.rhs_original,vars)], 
               lt = (r1, r2) -> compare_rules(r1[1],r1[2], r2[1],r2[2], vars))
end


#measure side length of operators 



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


# CVC5 functions

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


function loading_bar(current, max)
    progress = round(Int, current / max * 50)  # 50 chars wide
    bar = "[" * repeat("=", progress) * repeat(" ", 50 - progress) * "]"
    print("\rProgress: ", bar)
end

#run it on the string benchmark 
#use futures in Julia or do it on the terminal level
#limit the programs you intersect in the intersection 