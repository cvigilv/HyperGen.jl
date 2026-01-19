"""
    combine(; kwargs...)

Combine sketch hypervectors.
"""
function combine(;
        inputs::Vector{String},
        output::String = "auto",
        method::Symbol = :bindsequence,
        verbose::Bool = false
    )
    @debug "Checking `combine` inputs"
    verbose && @show inputs
    verbose && @show output
    verbose && @show method
    verbose && @show verbose

    output = output == "auto" ? inputs[1] * ".combine" : output
    verbose && @show output

    @assert method ∈ [:bind, :bundle, :bindsequence, :bundlesequence]
    methodfunc = Dict(
        :bind => bind,
        :bundle => bundle,
        :bindsequence => bindsequence,
        :bundlesequence => bundlesequence,
    )[method]

    @debug "Reading sketch hypervectors from input files"
    H = Dict{String, Dict{String, TernaryHV}}()
    for f in inputs
        verbose && @show f
        H[f] = first(read_hvs(f; verbose = verbose))
    end
    verbose && display(Dict(k => length(v) for (k, v) in H))

    incommon = intersect([keys(v) for (k, v) in H]...)
    verbose && display(incommon)

    H_combined = Dict{String, TernaryHV}()
    for id in incommon
        H_combined[id] = methodfunc([v[id] for (k, v) in H])
    end
    verbose && display(H_combined)

    @debug "Writing combined sketches to file $output"
    return save(
        :combine,
        H_combined;
        inputs = repr(inputs),
        output = output,
        method = method,
        verbose = verbose
    )
end
