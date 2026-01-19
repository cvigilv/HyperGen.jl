HV(D::Int = 10_000; seed = nothing) = TernaryHV(rand(MersenneTwister(seed), (-1, 1), D))
