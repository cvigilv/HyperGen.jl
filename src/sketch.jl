"""
    canonicalize(kmer::String)::String

Returns the lexicographically smaller of a k-mer and its reverse complement.
This ensures that a k-mer and its reverse complement are treated as the same.
"""
function canonicalize(kmer::String)::String
    complement = Dict('A' => 'T', 'T' => 'A', 'G' => 'C', 'C' => 'G')
    rev_comp = String([complement[c] for c in reverse(kmer)])
    return min(kmer, rev_comp)
end

"""
	getalphabet(kind::Symbol) -> Char[]

Returns the list of valid characters for a given alphabet.
"""
function getalphabet(kind::Symbol)
    if kind == :nt
        return ['A', 'C', 'T', 'G']
    elseif kind == :aa
        return ['A', 'R', 'N', 'D', 'C', 'E', 'Q', 'G', 'H', 'I', 'L', 'K', 'M', 'F', 'P', 'S', 'T', 'W', 'Y', 'V']
    end
    @error "Unknown alphabet, must be 'nt' (nucleotides) or 'aa' (amino acids)"
    return []
end

"""
    getkmers(sequence::AbstractString, k::Int, alphabet::Symbol, canonical::Bool = true) -> Vector{String}

Extract all k-mers from a sequence.
"""
function getkmers(sequence::AbstractString, k::Int, alphabet::Symbol, canonical::Bool = true)
    if length(sequence) < k
        return Iterators.Stateful([])
    end
    kmer_iter = (uppercase(sequence[i:(i + k - 1)]) for i in 1:(length(sequence) - k + 1))
    valid_kmers = Iterators.filter(kmer -> !any(c -> c ∉ getalphabet(alphabet), kmer), kmer_iter)
    return (canonical ? canonicalize(kmer) : kmer for kmer in valid_kmers)
end

"""
    sketch(input::String, args...)

Sketching command.

Executes the protocol proposed in "HyperGen: compact and efficient genome sketching using hyperdimensional vectors
(Xu et al., 2024)".
"""
function sketch(;
        input::String,
        output::String = "auto",
        scale::Integer = 1_500,
        kmersize::Int = 11,
        dims::Integer = 4_096,
        canonical::Bool = true,
        alphabet::Symbol = :nt,
        seed::Integer = 42,
        normalize::Bool = false,
        verbose::Bool = false,
        kwargs...
    )

    @debug "Checking 'sketch' parameters\nOriginal parameters:"
    verbose && @show input
    verbose && @show output
    verbose && @show scale
    verbose && @show kmersize
    verbose && @show dims
    verbose && @show canonical
    verbose && @show alphabet
    verbose && @show normalize
    verbose && @show seed
    verbose && @show verbose
    @assert kmersize > 0 "K-mer size must be greater than 0"
    @assert scale > 0 "Scale must be greater than 0"
    @assert dims > 0 "Hypervector dimension must be greater than 0"
    @assert alphabet ∈ [:nt, :aa] "Invalid alphabet. Support for nucleotides (:nt) and amino acids (:aa) is implemented"

    output = output == "auto" ? input * ".sketch" : output
    canonical = alphabet == :aa ? false : canonical
    normalizefunc = normalize ? LinearAlgebra.normalize : identity
    verbose && @show output
    verbose && @show canonical

    @debug "Loading dataset"
    numentries, stream = stream_fasta(input)
    verbose && @show numentries
    verbose && @show stream

    @debug "Generating sketch hypervector representation"
    # TODO: Think on how to accept streams of text, accept directories, and stream outputs
    pbar = verbose ? Progress(numentries, desc = "", showspeed = true; enabled = verbose) : nothing
    H_entry = Dict{String, TernaryHV}()
    for record in stream
        kmers = getkmers(sequence(record), kmersize, alphabet, canonical)
        hashes = hash.(kmers, Ref(seed))
        M = maximum(hashes)
        sketch = (h for h in hashes if h < M / scale)
        H_entry[identifier(record)] = sum(h -> HV(dims; seed = h), sketch) |> normalizefunc
        verbose && next!(
            pbar;
            desc = "Finished $(identifier(record)): Sketch size = $(length(hashes))/$(length(collect(sketch)))"
        )
    end
    verbose && first(H_entry, 10)

    @debug "Writing sketches to file $output"
    return save(
        :sketch,
        H_entry;
        input = input,
        output = output,
        scale = scale,
        kmersize = kmersize,
        dims = dims,
        canonical = canonical,
        alphabet = alphabet,
        normalize = normalize,
        seed = seed,
        verbose = verbose
    )
end
