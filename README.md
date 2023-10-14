<!-- -*-Mode: markdown;-*- -->
<!-- $Id$ -->

Suite for Embedded Applications and Kernels (SEAK)
=============================================================================

**Home**:
  - https://hpc.pnnl.gov/SEAK/
  - https://github.com/pnnl/seak

**Abstract**: The SEAK Suite is collection of constraining problems for
common embedded computing challenges. A constraining problem is a
mission-centric and goal-oriented problem specifications that separate
problem-domain constraints from solution implementations so as to
encourage creative solutions that meet goals but that may deviate from
standard implementations.

**About**: Many applications of high performance embedded computing
are limited by performance or power bottlenecks. Consider a mobile
imaging system that recognizes faces from an array of cameras. Because
face recognition is a computationally intensive task, potential
solutions may not fit within the mobile system's power and size
envelope. Suppose the system's designer desires the most power
efficient face recognition *solution* that satisfies a given real-time
constraint. That is, the solution may use *any* algorithm on *any*
architecture that meets the given correctness, time, and power
constraints. To solicit the best solutions, how should the designer
capture the key input and output requirements without biasing toward
specific algorithms or architectures?

The SEAK benchmark suite generalizes this question. The benchmark
suite is a collection of *constraining problems* for common embedded
computing challenges.  A constraining problem is a goal-oriented
problem specification that separate problem-domain constraints from
solution implementations so as to encourage creative solutions that
meet goals but that may deviate from standard implementations.
Further, a constraining problem is defined so as to facilitate
rigorous, objective, end-user evaluation for their solutions.

To avoid biasing solutions toward existing algorithms, SEAK
constraining problems use a *mission-centric* (abstracted from a
particular algorithm) and goal-oriented (functional) specification. To
encourage solutions that are any combination of software or hardware,
we use an end-user black-box evaluation that can capture tradeoffs
between performance, power, accuracy, size, and weight. The tradeoffs
are especially informative for procurement decisions. We call our
benchmarks *future proof* because each mission-centric interface and
evaluation remains useful despite shifting algorithmic preferences.

This distribution contains the SEAK constraining problems. A
constraining problem consists of a specification document and a source
code distribution. The specification document (a) justifies each
problem, (b) describes input and output requirements, and (c) details
evaluation criteria for correctness, performance, and power. The
source code repository contains input generators and correctness
checkers. Although the specification does not require reference
implementations, when available we include representative solutions to
use as reference implementations.


**Citation**:
  > Nathan R. Tallent, Joseph B. Manzano, Nitin A. Gawande, Seunghwa Kang, Darren J. Kerbyson, Adolfy Hoisie, and Joseph K. Cross. Algorithm and architecture independent benchmarking with SEAK. In Proc. of the 30th IEEE Intl Parallel and Distributed Processing Symp. IEEE Computer Society, May 2016. https://doi.org/10.1109/IPDPS.2016.25


**Contacts**: (_firstname_._lastname_@pnnl.gov)
  - Joseph Manzano
  - Nathan R. Tallent


**Contributors**:
  - Nitin A. Gawande (PNNL)
  - Seunghwa Kang (PNNL)
  - Joseph B. Manzano (PNNL)
  - Nathan R. Tallent (PNNL)
  - Darren J. Kerbyson (PNNL)
  - Adolfy Hoisie (PNNL)


Details
=============================================================================

**SEAK Specification**:
  - doc/SEAK-Specification.pdf (https://gitlab.pnnl.gov/perf-lab/seak/seak-suite/-/blob/master/doc/SEAK-Specification.pdf)
  - Nitin A. Gawande, Seunghwa Kang, Joseph B. Manzano, Nathan R. Tallent, Darren J. Kerbyson, Adolfy Hoisie.  "SEAK Specification." Pacific Northwest National Laboratory. May 2016.


Preparing large files
=============================================================================

*Note*: For migration to GitHub, the sample input/output files over 100 MB have been split. 

To recover them:
```sh
  for fnm_first in $(find . -name "*.split-aa") ; do
    fnm_base=${fnm_first%.split-aa}
    echo "*** Building ${fnm_base}"
    cat ${fnm_base}.split-* > ${fnm_base}
  done
  ```

To clean them:
  ```sh
  find . -name "*.bin" -size +100M -exec rm '{}' \;
  ```

To generate them:
  ```sh
  find . -name "*.bin" -size +100M -exec split -b 99MiB  '{}' '{}'.split- \;
  ```
