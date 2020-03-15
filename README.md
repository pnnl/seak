-*-Mode: markdown;-*-

$HeadURL$
$Id$

Suite for Embedded Applications and Kernels (SEAK)
=================================================

* URL:
	* http://hpc.pnnl.gov/SEAK/

* People:
	* Nitin A. Gawande
	* Seunghwa Kang
	* Joseph B. Manzano
	* Nathan R. Tallent
	* Darren J. Kerbyson
	* Adolfy Hoisie

* Contact: firstname.lastname@pnnl.gov

Description:
------------

Many applications of high performance embedded computing are limited by performance or power bottlenecks. Consider a mobile imaging system that recognizes faces from an array of cameras. Because face recognition is a computationally intensive task, potential solutions may not fit within the mobile system's power and size envelope. Suppose the system's designer desires the most power efficient face recognition *solution* that satisfies a given real-time constraint. That is, the solution may use *any* algorithm on *any* architecture that meets the given correctness, time, and power constraints. To solicit the best solutions, how should the designer capture the key input and output requirements without biasing toward specific algorithms or architectures?

The SEAK benchmark suite generalizes this question. The benchmark suite is a collection of *constraining problems* --- application bottlenecks --- that capture common embedded application bottlenecks. We have designed SEAK's constraining problems (a) to capture these bottlenecks in a way that encourages creative solutions; and (b) to facilitate rigorous, objective, end-user evaluation for their solutions. To avoid biasing solutions toward existing algorithms, SEAK constraining problems use a *mission-centric* (abstracted from a particular algorithm) and goal-oriented (functional) specification. To encourage solutions that are any combination of software or hardware, we use an end-user black-box evaluation that can capture tradeoffs between performance, power, accuracy, size, and weight. The tradeoffs are especially informative for procurement decisions. We call our benchmarks *future proof* because each mission-centric interface and evaluation remains useful despite shifting algorithmic preferences.

This distribution contains the SEAK constraining problems. A constraining problem consists of a specification document and a source code distribution. The specification document (a) justifies each problem, (b) describes input and output requirements, and (c) details evaluation criteria for correctness, performance, and power. The source code repository contains input generators and correctness checkers. Although the specification does not require reference implementations, when available we include representative solutions to use as reference implementations.

* SEAK Specification (within doc/ directory)

  Nitin A. Gawande, Seunghwa Kang, Joseph B. Manzano, Nathan R. Tallent, Darren J. Kerbyson, Adolfy Hoisie.  "SEAK Specification." Pacific Northwest National Laboratory. May 2016.

* Paper:

  Nathan R. Tallent, Joseph B. Manzano, Nitin A. Gawande, Seunghwa Kang, Darren J. Kerbyson, Adolfy Hoisie, and Joseph K. Cross. Algorithm and architecture independent benchmarking with SEAK. In Proc. of the 30th IEEE Intl Parallel and Distributed Processing Symp. IEEE Computer Society, May 2016.


