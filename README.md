# JSONTypeProvider

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://mcmcgrath13.github.io/JSONTypeProvider.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://mcmcgrath13.github.io/JSONTypeProvider.jl/dev)
[![Build Status](https://github.com/mcmcgrath13/JSONTypeProvider.jl/workflows/CI/badge.svg)](https://github.com/mcmcgrath13/JSONTypeProvider.jl/actions)
[![Coverage](https://codecov.io/gh/mcmcgrath13/JSONTypeProvider.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/mcmcgrath13/JSONTypeProvider.jl)

An F# inspire type provider to JSON.  Given a JSON3 Object or Array, create a type from it and write it to file.

```julia
import JSON3
import JSONTypeProvider

json = JSON3.read(read("test/menu.json", String)) # either a JSON.Array or JSON.Object

# build a type for the JSON
raw_json_type = JSONTypeProvider.build_type(json)
# result:
# NamedTuple{(:menu,),Tuple{NamedTuple{(:header, :items),Tuple{String,Array{Union{Nothing, NamedTuple{(:id, :label),Tuple{String,Union{Nothing, String}}}},1}}}}}

# turn the type into struct expressions, including replacing sub types with references to a struct
json_exprs = JSONTypeProvider.to_exprs(raw_json_type, :MyStruct)
# result:
# 3-element Array{Any,1}:
# :(struct Item
#      id::String
#      label::Union{Nothing, String}
#  end)
# :(struct Menu
#      header::String
#      items::Array{Union{Nothing, Item}, 1}
#  end)
# :(struct MyStruct
#      menu::Menu
#  end)

# write the types to a file, then can be edited/included as needed
JSONTypeProvider.write_exprs(json_exprs)
```

For example, the file `test/menu.json`:

```json
{
  "menu": {
    "header": "SVG\\tViewer\\u03b1",
    "items": [
      {
        "id": "Open"
      },
      {
        "id": "OpenNew",
        "label": "Open New"
      },
      {
        "id": "ZoomIn",
        "label": "Zoom In"
      },
      null,
      {
        "id": "Help"
      },
      {
        "id": "About",
        "label": "About Adobe SVG Viewer..."
      }
    ]
  }
}
```

is parsed into the following types:

```julia
struct Item
    id::String
    label::Union{Nothing, String}
end

struct Menu
    header::String
    items::Array{Union{Nothing, Item}, 1}
end

struct MyStruct
    menu::Menu
end
```
