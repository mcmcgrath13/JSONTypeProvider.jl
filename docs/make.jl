using JSONTypeProvider
using Documenter

makedocs(;
    modules=[JSONTypeProvider],
    authors="mcmcgrath13 <m.c.mcgrath13@gmail.com> and contributors",
    repo="https://github.com/mcmcgrath13/JSONTypeProvider.jl/blob/{commit}{path}#L{line}",
    sitename="JSONTypeProvider.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://mcmcgrath13.github.io/JSONTypeProvider.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/mcmcgrath13/JSONTypeProvider.jl",
    devbranch = "main"
)
