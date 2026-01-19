"""
    newick(clust, tiplabels::AbstractVector{String}) -> String

Return Newick representation of phylogenetic tree
"""
function newick(clust::NJClust, tiplabels::AbstractVector{String})
    return newickstring(clust, tiplabels)
end

function newick(clust::Hclust, tiplabels::AbstractVector{String})
    tree = convert(Node, clust)
    map(l -> NewickTree.setname!(l, tiplabels[l.id]), getleaves(tree))
    return nwstr(tree)
end

"""
    UPGMA(D::Matrix{<:Number}) -> Hclust

Computes the unweighted pair group method with arithmetic mean tree from distance matrix.
"""
function UPGMA(D::Matrix{<:Number})
    return Clustering.hclust(D, linkage = :average, branchorder = :optimal)
end

"""
    tree(; kwargs...) -> Bool

Tree subcommand. Constructs phylogenetic tree from input data

"""
function tree(;
        input::String,
        output::String = "auto",
        method::Symbol = :nj,
        distance::Bool = false,
        verbose::Bool = false
    )
    @debug "Checking 'tree' parameters\nOriginal parameters:"
    verbose && @show input
    verbose && @show output
    verbose && @show method
    verbose && @show distance
    verbose && @show verbose

    @assert method ∈ [:nj, :fastnj, :upgma]
    output = output == "auto" ? input * ".nw" : output
    methodfunc = Dict(:nj => regNJ, :fastnj => fastNJ, :upgma => UPGMA)[method]
    verbose && @show output
    verbose && @show methodfunc

    @debug "Loading dataset"
    lut, M, _ = read_matrix(input; verbose = verbose)
    @assert M == M' ("Distance matrix is not symmetrical, can't continue"; return false)
    M = distance ? (@info "Computed distance from input matrix"; 1 .- M) : M

    @debug "Constructing tree"
    nw = newick(methodfunc(M), lut)

    return savenw(
        :tree,
        nw;
        input = input,
        output = output,
        method = method,
        distance = distance,
        verbose = verbose
    )
end
