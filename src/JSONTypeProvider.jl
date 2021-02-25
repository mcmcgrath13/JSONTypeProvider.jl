module JSONTypeProvider

import JSON3

@static if Base.VERSION < v"1.2"
    function hasfield(::Type{T}, name::Symbol) where T
        return name in fieldnames(T)
    end
    fieldtypes(::Type{T}) where {T} = Tuple(fieldtype(T, i) for i = 1:fieldcount(T))
end

include("build_type.jl")
include("write_type.jl")

end
