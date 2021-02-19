using JSONTypeProvider
using Test
import JSON3

@testset "JSONTypeProvider.jl" begin
    json = JSON3.read(read("menu.json", String)) # either a JSON.Array or JSON.Object

    # build a type for the JSON
    raw_json_type = JSONTypeProvider.build_type(json)
    @test raw_json_type <: NamedTuple

    # turn the type into struct expressions, including replacing sub types with references to a struct
    json_exprs = JSONTypeProvider.to_exprs(raw_json_type, :MyStruct)
    @test length(json_exprs) == 3

    # write the types to a file, then can be edited/included as needed
    path = mktempdir()
    file = joinpath(path, "test.jl")
    JSONTypeProvider.write_exprs(json_exprs, file)
    lines = readlines(file)
    @test length(lines) > 3

    json_arr = JSON3.read(read("menu.json", String)) # either a JSON.Array or JSON.Object

    # build a type for the JSON
    raw_json_arr_type = JSONTypeProvider.build_type(json_arr)
    @test raw_json_type <: NamedTuple

    # turn the type into struct expressions, including replacing sub types with references to a struct
    json_arr_exprs = JSONTypeProvider.to_exprs(raw_json_arr_type, :MyStruct)
    @test length(json_exprs) == 3

    # write the types to a file, then can be edited/included as needed
    file_arr = joinpath(path, "test_arr.jl")
    JSONTypeProvider.write_exprs(json_arr_exprs, file_arr)
    arr_lines = readlines(file_arr)
    @test length(lines) > 3
    @test arr_lines == lines

end
