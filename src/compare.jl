"""
    jaccard(A::T, B::T) where {T <: TernaryHV} -> Float64

Compute Jaccard coefficient between 2 hypervectors
"""
function computejaccard(A::T, B::T; kwargs...) where {T <: TernaryHV}
    num = A.v' * B.v
    den = sum(abs2, A.v) + sum(abs2, B.v) - num
    return clamp(num / den, 0.0, 1.0) # FIX: remove the need for clamping values
end

"""
    ani(A::T, B::T, k::Int, distance::Bool) where {T <: TernaryHV} -> Float64

Compute Average Nucleotide Identity (ANI) for two hypervectors and a given _k_-mer size.
"""
function computeani(A::T, B::T; kmersize::Int) where {T <: TernaryHV}
    tc = computejaccard(A, B)
    return clamp(1 + 1 / kmersize * log((2 * tc) / (1 + tc)), 0.0, 1.0)
end

"""
    computecontainment(A::T, B::T) where {T <: TernaryHV} -> Float64

Compute Jaccard containment between 2 hypervectors
"""
function computecontainment(A::T, B::T; kwargs...) where {T <: TernaryHV}
    num = A.v' * B.v
    return clamp(num / sum(abs2, A.v), 0.0, 1.0)
end


"""
    compare(; kwargs...)

Compare sketch hypervectors for distance matrix calculation
"""
function compare(;
        input::String,
        kmersize::Integer = -1,
        output::String = "auto",
        method::Symbol = :jaccard,
        distance::Bool = false,
        ani::Bool = false,
        verbose::Bool = false
    )
    @debug "Checking `compare` inputs"
    verbose && @show input
    verbose && @show kmersize
    verbose && @show output
    verbose && @show method
    verbose && @show ani
    verbose && @show verbose

    @assert distance != ani "Can't compute distance and ANI/AAI together"
    method = (ani && method != :jaccard) ? (
            @warn "ANI only computable from Jaccard index, forcing --method to be :jaccard"; :jaccard
        ) : method
    verbose && @show method
    output = output == "auto" ? input * ".compare" : output
    methodfunc = if ani
        computeani
    elseif method == :jaccard
        computejaccard
    elseif method == :containment
        computecontainment
    end

    @debug "Reading sketch hypervectors from $(input)"
    H_entry, args = read_hvs(input; verbose = verbose)
    kmersize = if kmersize == 0
        parse(Int, args[:kmersize])
    else
        kmersize
    end
    verbose && @show kmersize
    @assert distance || ani && kmersize != 0 "Need valid k-mer size to compute ANI"

    @debug "Comparing the sketch hypervectors"
    entries = keys(H_entry) |> collect |> sort
    M = Matrix{Float64}(undef, length(entries), length(entries))
    I = collect(eachindex(entries))
    numcomparisons = method == :containment ? length(I)^2 : (length(I) * length(I) - 1) ÷ 2
    verbose && @show numcomparisons
    pbar = verbose ? Progress(numcomparisons; desc = "Comparing sketch hypervectors", showspeed = true) : nothing
    @threads for i in I
        tocompare = method == :containment ? I : I[begin:i]
        for j in tocompare
            M[i, j] = M[j, i] = methodfunc(H_entry[entries[i]], H_entry[entries[j]]; kmersize = kmersize)
            verbose && next!(pbar)
        end
    end

    @debug "Writing sketches to file $output"
    return save(
        :compare,
        Dict(zip(entries, Vector.(eachrow(M))));
        input = input,
        kmer = kmersize,
        output = output,
        method = method,
        distance = distance,
        ani = ani,
        verbose = verbose,
    )
end
