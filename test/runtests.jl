using Desktop
using Test

@testset "Desktop.jl" begin
    @test hasdesktop() in (true, false)
end
