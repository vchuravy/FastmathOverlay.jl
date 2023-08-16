module FastmathOverlay

@static if VERSION < v"1.8.0"

functional() = false

else

functional() = true

include("internal.jl")
import .Internal: StackedMethodTable

Base.Experimental.@MethodTable(Contract)

Base.Experimental.@overlay Contract function Base.:*(a::Float64, b::Float64)
    @inline
    Base.llvmcall("""
        %x = fmul contract nsz double %0, %1 
        ret double %x 
    """, Float64, Tuple{Float64, Float64}, a, b) 
end

Base.Experimental.@overlay Contract function Base.:*(a::Float32, b::Float32)
    @inline
    Base.llvmcall("""
        %x = fmul contract nsz float %0, %1 
        ret float %x 
    """, Float32, Tuple{Float32, Float32}, a, b) 
end

Base.Experimental.@overlay Contract function Base.:+(a::Float64, b::Float64)
    @inline
    Base.llvmcall("""
        %x = fadd contract nsz double %0, %1 
        ret double %x 
    """, Float64, Tuple{Float64, Float64}, a, b) 
end

Base.Experimental.@overlay Contract function Base.:+(a::Float32, b::Float32)
    @inline
    Base.llvmcall("""
        %x = fadd contract nsz float %0, %1 
        ret float %x 
    """, Float32, Tuple{Float32, Float32}, a, b) 
end

Base.Experimental.@overlay Contract function Base.:-(a::Float64, b::Float64)
    @inline
    Base.llvmcall("""
        %x = fsub contract nsz double %0, %1 
        ret double %x 
    """, Float64, Tuple{Float64, Float64}, a, b) 
end

Base.Experimental.@overlay Contract function Base.:-(a::Float32, b::Float32)
    @inline
    Base.llvmcall("""
        %x = fsub contract nsz float %0, %1 
        ret float %x 
    """, Float32, Tuple{Float32, Float32}, a, b) 
end

contract(world, parent) = StackedMethodTable(world, Contract, parent)

end # VERSION < v"1.8.0"
end # module FastmathOverlay
