/* -*-Mode: C;-*- */

/**BeginCopyright************************************************************
 *
 * $HeadURL$
 * $Id$
 *
 *---------------------------------------------------------------------------
 * SEAK: Suite for Embedded Applications and Kernels (hpc.pnnl.gov/SEAK/)
 *---------------------------------------------------------------------------
 *
 * Copyright ((c)) 2016, Battelle Memorial Institute
 *
 * 1. Battelle Memorial Institute (hereinafter Battelle) hereby grants
 *    permission to any person or entity lawfully obtaining a copy of
 *    this software and associated documentation files (hereinafter "the
 *    Software") to redistribute and use the Software in source and
 *    binary forms, with or without modification.  Such person or entity
 *    may use, copy, modify, merge, publish, distribute, sublicense,
 *    and/or sell copies of the Software, and may permit others to do so,
 *    subject to the following conditions:
 *    
 *    * Redistributions of source code must retain the above copyright
 *      notice, this list of conditions and the following disclaimers.
 *
 *    * Redistributions in binary form must reproduce the above copyright
 *      notice, this list of conditions and the following disclaimer in
 *      the documentation and/or other materials provided with the
 *      distribution.
 *
 *    * Other than as used herein, neither the name Battelle Memorial
 *      Institute or Battelle may be used in any form whatsoever without
 *      the express written consent of Battelle.
 *
 *    * Redistributions of the software in any form, and publications
 *      based on work performed using the software should include the
 *      following citation as a reference:
 *            
 *        Nitin A. Gawande, Seunghwa Kang, Joseph B. Manzano, Nathan
 *        R. Tallent, Darren J. Kerbyson, Adolfy Hoisie.  "SEAK
 *        Specification." Pacific Northwest National Laboratory. May,
 *        2016, http://hpc.pnnl.gov/SEAK/
 *
 * 2. THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 *    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 *    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 *    FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL BATTELLE
 *    OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 *    SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 *    LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF
 *    USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 *    ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 *    OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
 *    OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 *    SUCH DAMAGE.
 *
 **EndCopyright*************************************************************/

#ifndef _STAP_PARAMS_H_
#define _STAP_PARAMS_H_

#define INPUT_SIZE_SMALL 1
#define INPUT_SIZE_MEDIUM 2
#define INPUT_SIZE_LARGE 3

#ifndef INPUT_SIZE
    #define INPUT_SIZE INPUT_SIZE_MEDIUM
#endif

/*
 * We statically define the data cube dimensions and algorithm parameters
 * in order to support any tools that may require or benefit from
 * such patterns.  The dimensions can be adjusted by specifying
 * INPUT_SIZE during compilation.
 *
 * The following parameters depend upon the input sample size:
 * 
 * N_CHAN : Number of antenna channels; L from the documentation.
 * N_RANGE : Number of range cells; N from the documentation.
 * TRAINING_BLOCK_SIZE : Number of range cells per training block;
 *                       N_R from the documentation.
 * N_BLOCKS : Number of total training blocks
 * N_PULSES : Number of pulses per CPI; P from the documentation.
 * N_DOP : Number of Doppler bins after Doppler processing;
 *         K from the documentation. N_DOP should be a power of two
 *         and >= N_PULSES.
 * TDOF : Number of temporal degrees of freedom. This corresponds to Q
 *        from the RT_STAP documentation and is three for third-order
 *        post-Doppler processing.
 * N_STEERING : Number of steering directions; D from the documentation.
 */

#if INPUT_SIZE == INPUT_SIZE_SMALL
    #define N_CHAN (4)
    #define N_RANGE (512)
    #define TRAINING_BLOCK_SIZE (32)
    #define N_BLOCKS (N_RANGE/TRAINING_BLOCK_SIZE)
    #define N_PULSES (128)
    #define N_DOP (256)
    #define TDOF (3)
    #define N_STEERING (16)
#elif INPUT_SIZE == INPUT_SIZE_MEDIUM
    #define N_CHAN (6)
    #define N_RANGE (1024)
    #define TRAINING_BLOCK_SIZE (64)
    #define N_BLOCKS (N_RANGE/TRAINING_BLOCK_SIZE)
    #define N_PULSES (128)
    #define N_DOP (256)
    #define TDOF (3)
    #define N_STEERING (16)
#elif INPUT_SIZE == INPUT_SIZE_LARGE
    #define N_CHAN (8)
    #define N_RANGE (4096)
    #define TRAINING_BLOCK_SIZE (64)
    #define N_BLOCKS (N_RANGE/TRAINING_BLOCK_SIZE)
    #define N_PULSES (128)
    #define N_DOP (256)
    #define TDOF (3)
    #define N_STEERING (16)
#else
    #error "Unhandled value for INPUT_SIZE"
#endif
 
#endif /* _STAP_PARAMS_H_ */
