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

#ifndef _SAR_PARAMS_H_
#define _SAR_PARAMS_H_

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
 * N_RANGE : Number of range cells
 * N_PULSES : Number of pulses
 * BP_NPIX_X / BP_NPIX_Y : Number of output pixels for the backprojection
 *      kernel in the x and y dimension, respectively
 * PFA_NOUT_RANGE / PFA_NOUT_AZIMUTH : Number of output samples from
 *      the PFA range and azimuth interpolation kernels, respectively
 */

#if INPUT_SIZE == INPUT_SIZE_SMALL
    #define N_RANGE (512)
    #define N_PULSES (512)
    #define BP_NPIX_X (512)
    #define BP_NPIX_Y (512)
    #define PFA_NOUT_RANGE (512)
    #define PFA_NOUT_AZIMUTH (512)
#elif INPUT_SIZE == INPUT_SIZE_MEDIUM
    #define N_RANGE (1024)
    #define N_PULSES (1024)
    #define BP_NPIX_X (1024)
    #define BP_NPIX_Y (1024)
    #define PFA_NOUT_RANGE (1024)
    #define PFA_NOUT_AZIMUTH (1024)
#elif INPUT_SIZE == INPUT_SIZE_LARGE
    #define N_RANGE (2048)
    #define N_PULSES (2048)
    #define BP_NPIX_X (2048)
    #define BP_NPIX_Y (2048)
    #define PFA_NOUT_RANGE (2048)
    #define PFA_NOUT_AZIMUTH (2048)
#else
    #error "Unhandled value for INPUT_SIZE"
#endif

/* Upsampling factor used to upsample range prior to backprojection. */
#define RANGE_UPSAMPLE_FACTOR (8)

#define N_RANGE_UPSAMPLED  (N_RANGE * RANGE_UPSAMPLE_FACTOR)

/* Number of points to use in the truncated sinc interpolation. */
#define T_PFA (13)

#endif /* _SAR_PARAMS_H_ */
