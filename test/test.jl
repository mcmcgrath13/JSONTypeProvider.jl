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
