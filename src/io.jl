using FASTX

"""
    stream_fasta(path::String) -> (count, FASTX.FASTAReader)

Open a FASTA file, count the number of entries to validate, and return a streaming reader.
Throws an error if the file cannot be read.
"""
function stream_fasta(path::String)
    try
        numentries = open(FASTA.Reader, path) do reader
            count(_ -> true, reader)
        end
        return (numentries, open(FASTAReader, path))
    catch e
        error("Failed to read FASTA file: $(e)")
    end
end

function _save(command, values; kwargs...)
    try
        open(kwargs[:output], "w+") do io
            @debug "Writing parameters header"
            println(io, "# HyperGen.jl - v$(VERSION)")
            println(io, "#+$(rpad("version:", 16))$(VERSION)")
            println(io, "#+$(rpad("date:", 16))$(Dates.now())")
            println(io, "#+$(rpad("command:", 16))$(string(command))")
            for (k, v) in kwargs
                kwargs[:verbose] && string(k), string(v)
                println(io, "#+$(rpad(string(k) * ":", 16))$(string(v))")
            end
            sortedkeys = keys(values) |> collect |> sort
            @showprogress "Writing sketch hypervectors to file" enabled = kwargs[:verbose] for k in sortedkeys
                v = values[k]
                s = join([k, join(v, " ")], '\t')
                println(io, s)
            end
        end
        return true
    catch e
        error("Failed to write sketch hypervectors to file: $(e)")
    end
    return false
end

function save(command::Symbol, hvs::Dict{String, TernaryHV}; kwargs...)
    return _save(command, Dict(id => hv.v for (id, hv) in hvs); kwargs...)
end

function save(command::Symbol, vals::Dict{String, Vector{Float64}}; kwargs...)
    return _save(command, vals; kwargs...)
end

function savenw(command, tree; kwargs...)
    try
        open(kwargs[:output], "w+") do io
            @debug "Writing parameters header"
            println(io, "# HyperGen.jl - v$(VERSION)")
            println(io, "#+$(rpad("version:", 16))$(VERSION)")
            println(io, "#+$(rpad("date:", 16))$(Dates.now())")
            println(io, "#+$(rpad("command:", 16))$(string(command))")
            for (k, v) in kwargs
                kwargs[:verbose] && string(k), string(v)
                println(io, "#+$(rpad(string(k) * ":", 16))$(string(v))")
            end
            println(io, tree)
        end
        return true
    catch e
        error("Failed to write tree to file: $(e)")
    end
    return false
end


"""
    read_hvs(path::String, kwargs...) -> (Dict{String,TernaryHV}, Dict{Symbol,String})

Read sketch hypervectors and arguments to memory.
"""
function read_hvs(path::String; kwargs...)
    getarg(str::String) = startswith(str, "#+") && lstrip(str, collect("#+")) |> split
    args = Dict{Symbol, Any}()
    hvs = Dict{String, TernaryHV}()
    try
        open(path, "r") do io
            readline(io)
            for line in eachline(io)
                argval = getarg(line)
                if argval != false
                    args[Symbol(argval[1][begin:(end - 1)])] = string(argval[2])
                else
                    id, hv = begin
                        id, hv = split(line, "\t") .|> string
                        (id, TernaryHV(parse.(Int, split(hv))))
                    end
                    hvs[id] = hv
                end
            end
        end
        kwargs[:verbose] && display("Loaded sketch hypervectors constructed with the following arguments:")
        kwargs[:verbose] && display(args)
        kwargs[:verbose] && display(hvs)
        return (hvs, args)
    catch e
        error("Failed to read sketch hypervector file: $(e)")
    end
end


function read_matrix(path::String; kwargs...)
    getarg(str::String) = startswith(str, "#+") && lstrip(str, collect("#+")) |> split
    args = Dict{Symbol, Any}()
    lut = Vector{String}()
    M = Vector{Vector{Float32}}()
    try
        open(path, "r") do io
            readline(io)
            for line in eachline(io)
                argval = getarg(line)
                if argval != false
                    args[Symbol(argval[1][begin:(end - 1)])] = string(argval[2])
                else
                    id, vals = begin
                        id, vals = split(line, "\t") .|> string
                        (id, parse.(Float64, split(vals)))
                    end
                    push!(lut, id)
                    push!(M, vals)
                end
            end
        end
        kwargs[:verbose] && display("Loaded sketch hypervectors constructed with the following arguments:")
        kwargs[:verbose] && display(args)
        return (lut, reduce(vcat, M'), args)
    catch e
        error("Failed to read sketch hypervector file: $(e)")
    end
end
