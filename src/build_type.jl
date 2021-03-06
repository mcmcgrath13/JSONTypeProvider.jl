# top type - unifying a type with top yeilds the type
struct Top end

# get the type from a named tuple, given a name
get_type(NT, k) = hasfield(NT, k) ? fieldtype(NT, k) : Nothing

# unify two types to a single type
unify(a, b) = unify(b, a)
unify(a::Type{T}, b::Type{S}) where {T,S} = Base.promote_typejoin(T, S)
unify(a::Type{T}, b::Type{S}) where {T,S<:T} = T
unify(a::Type{Top}, b::Type{T}) where {T} = T

function unify(
    a::Type{NamedTuple{A,T}},
    b::Type{NamedTuple{B,S}},
) where {A,T<:Tuple,B,S<:Tuple}
    c = Dict()
    for (k, v) in zip(A, fieldtypes(a))
        c[k] = unify(v, get_type(b, k))
    end

    for (k, v) in zip(B, fieldtypes(b))
        if !haskey(c, k)
            c[k] = unify(v, Nothing)
        end
    end

    return NamedTuple{tuple(keys(c)...),Tuple{values(c)...}}
end

unify(a::Type{Vector{T}}, b::Type{Vector{S}}) where {T,S} = Vector{unify(T, S)}

# parse json into a type
function build_type(o::JSON3.Object)
    d = Dict()
    for (k, v) in o
        d[k] = build_type(v)
    end

    return NamedTuple{tuple(keys(d)...),Tuple{values(d)...}}
end

function build_type(a::JSON3.Array)
    t = Set([])
    nt = Top
    for item in a
        it = build_type(item)
        if it <: NamedTuple
            nt = unify(nt, it)
        else
            push!(t, build_type(item))
        end
    end

    return Vector{foldl(unify, t; init = Union{nt})}
end

build_type(x::T) where {T} = T
