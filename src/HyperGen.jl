module HyperGen

using .Threads
using Printf
using Dates
using FASTX
using HyperdimensionalComputing
using LinearAlgebra
using NeighborJoining
using AbstractTrees
using NewickTree
using Clustering
using Logging
using ProgressMeter
using Random

const VERSION = "0.1.0"

export sketch, compare, combine, search, tree

include("utils.jl")
include("io.jl")
include("sketch.jl")
include("compare.jl")
include("combine.jl")
include("search.jl")
include("tree.jl")
include("cli.jl")

end
