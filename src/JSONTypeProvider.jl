module JSONTypeProvider

import JSON3

@static if Base.VERSION < v"1.2"
    function hasfield(::Type{T}, name::Symbol) where T
        return name in fieldnames(T)
    end
end

include("build_type.jl")
include("write_type.jl")

end
