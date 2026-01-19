# HyperGen.jl (under development)

Compact and Efficient Genome Sketching using Hyperdimensional Vectors (in Julia).

## Table of Contents

- [Installation](#installation)
- [Usage](#usage)
- [Support](#support)
- [Contributing](#contributing)

## Installation

To install HyperGen.jl, clone the repository and run the following:

```sh
git clone https://github.com/cvigilv/HyperGen.jl
make install
```

Additionally, you can install the package directly from Julia's REPL:

```julia
using Pkg
Pkg.add(url="git://github.com/cvigilv/HyperGen.jl.git")
```

## Usage

### CLI

After running the installation steps, you can use the `hypergenjl` command in your terminal.

Run the following command to see available options:

```sh
$ hypergen --help
HyperGen.jl  - v0.1.0
usage: hypergenjl [-V] [-h] {sketch|compare|combine|search|tree}

Compact and Efficient Genome Sketching using Hyperdimensional Vectors (in Julia)

commands:
  sketch         Sketch sequences into hypervectors
  compare        Compare sketches hypervectors
  combine        Combine sketches hypervectors
  search         Search sequences in sketch hypervectors
  tree           Compute phylogenetic tree from distance / ANI matrix

optional arguments:
  -V, --verbose  Increase verbosity of program
  -h, --help     show this help message and exit

Copyright (C) 2025 Carlos Vigil-Vásquez (carlos.vigil.v@gmail.com). Permission
to copy and modify is granted under the MIT license
```

### Julia API

You can also use HyperGen.jl as a Julia package. Here is a simple example of how to sketch a sequence:

**Under construction**

## Support

Please [open an issue](https://github.com/cvigilv/HyperGen.jl/issues/new) for
support.

## Contributing

Please contribute using [Github Flow](https://guides.github.com/introduction/flow/). Create a
branch, add commits, and [open a pull request](https://github.com/cvigilv/HyperGen.jl/compare/).

The repo contains a Makefile with multiple targets useful for testing and developing the
package. To see all available targets, run:

```sh
make help
```

of simply,

```sh
make
```


## Acknowledgements

This work was supported by [Universite de Lille](https://www.univ-lille.fr/) and the
[EGBSL](https://egbsl.univ-lille.fr/), in conjunction with the
[IPL](https://www.ipl.univ-lille.fr/), [University of Ghent](https://www.ugent.be/en) and
the [KERMIT](https://kermit.ugent.be/) research group.

## Citation

If you use HyperGen.jl in your research, please cite the following paper:

- Weihong Xu, Po-Kai Hsu, Niema Moshiri, Shimeng Yu, Tajana Rosing, HyperGen: compact and
  efficient genome sketching using hyperdimensional vectors, Bioinformatics, Volume 40, Issue 7,
  July 2024, btae452, https://doi.org/10.1093/bioinformatics/btae452

## License

MIT License - Refer to [[LICENSE]] for more information
