using Test
using FastmathOverlay
using InteractiveUtils

if VERSION < v"1.8.0"
    @test FastmathOverlay.functional() == false
    exit(0)
end

using CassetteOverlay
include("internal.jl")

using CassetteOverlay

const pass = @overlaypass FastmathOverlay.Contract

@testset "Contract" begin
    ir = sprint(io->code_llvm(io, pass, Tuple{typeof(*), Float64, Float64}))
    @test contains(ir, "fmul nsz contract double %0, %1")

    ir = sprint(io->code_llvm(io, pass, Tuple{typeof(*), Float32, Float32}))
    @test contains(ir, "fmul nsz contract float %0, %1")

    ir = sprint(io->code_llvm(io, pass, Tuple{typeof(+), Float64, Float64}))
    @test contains(ir, "fadd nsz contract double %0, %1")

    ir = sprint(io->code_llvm(io, pass, Tuple{typeof(+), Float32, Float32}))
    @test contains(ir, "fadd nsz contract float %0, %1")

    ir = sprint(io->code_llvm(io, pass, Tuple{typeof(-), Float64, Float64}))
    @test contains(ir, "fsub nsz contract double %0, %1")

    ir = sprint(io->code_llvm(io, pass, Tuple{typeof(-), Float32, Float32}))
    @test contains(ir, "fsub nsz contract float %0, %1")
end
