using Test
import FastmathOverlay.Internal: StackedMethodTable

Base.Experimental.@MethodTable(LayerMT)
import Core.Compiler: findsup, findall, isoverlayed

OverlayMT() = Core.Compiler.OverlayMethodTable(Base.get_world_counter(), LayerMT)
StackedMT() = StackedMethodTable(Base.get_world_counter(), LayerMT)

@testset "Unoverlayed" begin
    o_sin = findsup(Tuple{typeof(sin), Float64}, OverlayMT())
    s_sin = findsup(Tuple{typeof(sin), Float64}, StackedMT())
    @test s_sin == o_sin 

    o_sin = findall(Tuple{typeof(sin), Float64}, OverlayMT())
    s_sin = findall(Tuple{typeof(sin), Float64}, StackedMT())
    @test o_sin.matches.matches == s_sin.matches.matches
    @test o_sin.overlayed == s_sin.overlayed
    @test o_sin.overlayed == false
end

Base.Experimental.@overlay LayerMT function sin(x::Float64)
end

@testset "Overlayed" begin
    o_sin = findsup(Tuple{typeof(sin), Float64}, OverlayMT())
    s_sin = findsup(Tuple{typeof(sin), Float64}, StackedMT())
    @test s_sin == o_sin 

    o_sin = findall(Tuple{typeof(sin), Float64}, OverlayMT())
    s_sin = findall(Tuple{typeof(sin), Float64}, StackedMT())
    @test o_sin.matches.matches == s_sin.matches.matches
    @test o_sin.overlayed == s_sin.overlayed
    @test o_sin.overlayed == true
end