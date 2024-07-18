using Documenter, Desktop

makedocs(;
    format=Documenter.HTML(;
        canonical="https://mgkuhn.github.io/Desktop.jl",
        repolink="https://github.com/mgkuhn/Desktop.jl",
        edit_link="master",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
    sitename="Desktop.jl",
    authors="Markus Kuhn",
)

deploydocs(;
    repo="github.com/mgkuhn/Desktop.jl",
)
