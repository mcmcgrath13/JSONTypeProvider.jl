function to_ast(::Type{T}) where {T}
    io = IOBuffer()
    print(io, T)
    str = String(take!(io))
    ast = Meta.parse(str)
    return ast
end

function to_pascal_case(s::Symbol)
    str = String(s)
    new_str = ""
    next_upper = true
    for letter in str
        if next_upper
            new_str *= uppercase(letter)
            next_upper = false
        elseif letter == '_'
            next_upper = true
        else
            new_str *= letter
        end
    end

    if new_str[end] == 's'
        new_str = new_str[1:end-1]
    end

    return Symbol(new_str)
end

function write_exprs(exprs::Vector, fname::AbstractString)
    open(fname, "w") do io
        for expr in exprs
            str = repr(expr)[3:end-1] # removes :( and )
            str = replace(str, "\n  " => "\n")
            write(io, str)
            write(io, "\n\n")
        end
    end
end

function to_exprs(t, n)
    exprs = []
    to_expr(t, n, exprs)
    return exprs
end

function to_expr(::Type{NamedTuple{N,T}}, root_name::Symbol, exprs) where {N,T<:Tuple}
    sub_exprs = []
    for (n, t) in zip(N, T.types)
        push!(sub_exprs, to_field_expr(t, n, exprs))
    end
    struct_name = to_pascal_case(root_name)
    push!(exprs, Expr(:struct, false, struct_name, Expr(:block, sub_exprs...)))
    return struct_name
end

function to_expr(::Type{Array{T,N}}, root_name::Symbol, exprs) where {T<:NamedTuple,N}
    return to_expr(T, root_name, exprs)
end

function to_expr(t::Type{T}, root_name::Symbol, exprs) where {T}
    if T isa Union
        return Expr(
            :curly,
            :Union,
            to_expr(t.a, root_name, exprs),
            to_expr(t.b, root_name, exprs),
        )
    else
        return to_ast(T)
    end
end

# given the type of a field of a struct, return a node for that field's name/type
function to_field_expr(t::Type{NamedTuple{N,T}}, root_name::Symbol, exprs) where {N,T}
    to_expr(t, root_name, exprs)
    return Expr(:(::), root_name, to_pascal_case(root_name))
end

function to_field_expr(::Type{Array{T,N}}, root_name::Symbol, exprs) where {T,N}
    return Expr(:(::), root_name, Expr(:curly, :Array, to_expr(T, root_name, exprs), 1))
end

function to_field_expr(::Type{T}, root_name, exprs) where {T}
    Expr(:(::), root_name, to_expr(T, root_name, exprs))
end

str_code = """
struct MyStruct
    a::Int
    b::OtherType
    c::Vector{Int,1}
end
"""
