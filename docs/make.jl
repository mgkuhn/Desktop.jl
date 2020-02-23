using Documenter, Desktop

makedocs(;
    modules=[Desktop],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
    ],
    repo="https://github.com/mgkuhn/Desktop.jl/blob/{commit}{path}#L{line}",
    sitename="Desktop.jl",
    authors="Markus Kuhn",
    assets=String[],
)

deploydocs(;
    repo="github.com/mgkuhn/Desktop.jl",
)
