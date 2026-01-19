using ArgParse
using Logging

function setup_argparse()
    cli = ArgParseSettings(
        add_help = true,
        add_version = true,
        description = "Compact and Efficient Genome Sketching using Hyperdimensional Vectors (in Julia)",
        epilog = "Copyright (C) 2025 Carlos Vigil-Vásquez (carlos.vigil.v@gmail.com). Permission to copy and modify is granted under the MIT license",
        help_width = 80,
        prog="hypergenjl",
        version = VERSION,
    )

    @add_arg_table cli begin
        "sketch"
        help = "Sketch sequences into hypervectors"
        action = :command
        "compare"
        help = "Compare sketches hypervectors"
        action = :command
        "combine"
        help = "Combine sketches hypervectors"
        action = :command
        "search"
        help = "Search sequences in sketch hypervectors"
        action = :command
        "tree"
        help = "Compute phylogenetic tree from distance / ANI matrix"
        action = :command
        "--verbose", "-V"
        help = "Increase verbosity of program"
        action = :store_true
    end

    @add_arg_table cli["sketch"] begin
        "input"
        action = :store_arg
        arg_type = String
        required = true
        help = "Input FASTA file to sketch"
        "output"
        action = :store_arg
        arg_type = String
        default = "auto"
        help = "Output sketch hypervectors in PHYLIP format"
        "--scale"
        action = :store_arg
        arg_type = Int
        default = 1_500
        range_tester = (x -> x > 0)
        help = "Sketch scale factor; must be greater than 0"
        "--kmersize"
        action = :store_arg
        arg_type = Int
        default = 11
        range_tester = (x -> x > 0)
        help = "K-mer size; must be greater than 0"
        "--dims"
        action = :store_arg
        arg_type = Int
        default = 4_096
        range_tester = (x -> x > 0)
        help = "Hypervector dimension; must be greater than 0"
        "--alphabet"
        action = :store_arg
        arg_type = Symbol
        default = :nt
        range_tester = (x -> x ∈ [:nt, :aa])
        help = "Type of sequences to sketch; must be one of :nt (nucleotides) or :aa (amino acids)"
        "--seed"
        action = :store_arg
        arg_type = UInt
        default = 42
        help = "Hashing seed"
        "--canonical"
        action = :store_true
        help = "Use canonical k-mers"
        "--normalize"
        action = :store_true
        help = "Normalize hypervectors before combining"
    end

    @add_arg_table cli["compare"] begin
        "input"
        action = :store_arg
        arg_type = String
        required = true
        help = "Input file with sketch hypervectors in PHYLIP format"
        "output"
        action = :store_arg
        arg_type = String
        default = "auto"
        help = "Output file with distance matrix; if 'auto', append arguments to `input`"
        "--kmersize"
        action = :store_arg
        arg_type = Int
        default = 0
        help = "K-mer size, used for calculating ANI. If '0', determine from input file"
        "--method"
        action = :store_arg
        arg_type = Symbol
        default = :jaccard
        range_tester = (x -> x ∈ [:jaccard, :containment])
        help = "Method to compute distance; must be one of :jaccard or :containment"
    end

    add_arg_group!(cli["compare"], "comparison arguments", exclusive = true, required = true)
    @add_arg_table! cli["compare"] begin
        "--distance"
        action = :store_true
        help = "Compute distance from sketches"
        "--ani"
        action = :store_true
        help = "Compute ANI from sketches"
    end

    @add_arg_table cli["combine"] begin
        "inputs"
        action = :store_arg
        arg_type = String
        required = true
        nargs = '+'
        help = "Input file with sketch hypervectors in PHYLIP format"
        "--output", "-o"
        action = :store_arg
        arg_type = String
        default = "auto"
        help = "Output file with combined sketch hypervectors in PHYLIP format; if 'auto', append '.combined'"
        "--method"
        action = :store_arg
        arg_type = Symbol
        default = :bindsequence
        help = "Encoder used for combining sketches; must be one of :bundle, :bind, :bundlesequence, or :bindsequence"
    end

    @add_arg_table cli["tree"] begin
        "input"
        action = :store_arg
        arg_type = String
        required = true
        help = "Input file with distance matrix"
        "output"
        action = :store_arg
        arg_type = String
        default = "auto"
        help = "Output file with tree in Newick format; if 'auto', append '.nw'"
        "--method"
        action = :store_arg
        arg_type = Symbol
        default = :nj
        range_tester = (x -> x ∈ [:nj, :fastnj, :upgma])
        help = "Method used for tree reconstruction; must be one of :nj, :fastnj, or :upgma"
        "--distance"
        action = :store_true
        help = "Compute distance matrix from input, i.e. 1 - M_{i,j}"
    end

    return cli
end

function main(args)
    println("HyperGen.jl  - v$(VERSION)")
    parsed = parse_args(args, setup_argparse(); as_symbols = true)
    parsed[:verbose] && global_logger(ConsoleLogger(stderr, Debug))
    try
        command = parsed[:_COMMAND_]
        if command == :sketch
            success = sketch(; parsed[command]..., verbose = parsed[:verbose])
        elseif command == :compare
            success = compare(; parsed[command]..., verbose = parsed[:verbose])
        elseif command == :combine
            success = combine(; parsed[command]..., verbose = parsed[:verbose])
        elseif command == :search
            @error "Not implemented"
        elseif command == :tree
            success = tree(; parsed[command]..., verbose = parsed[:verbose])
        end
        return success ? 0 : 1
    catch e
        if parsed[:verbose]
            showerror(stderr, e, catch_backtrace())
        else
            println(stderr, "Error: $e")
        end
        return 1
    end

    return 0
end

@main
