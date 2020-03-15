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

/**BeginCopyright************************************************************
 *
 * $HeadURL$
 * $Id$
 *
 *---------------------------------------------------------------------------
 * Part of PERFECT Benchmark Suite (hpc.pnnl.gov/projects/PERFECT/)
 *---------------------------------------------------------------------------
 *
 * Copyright ((c)) 2014, Battelle Memorial Institute
 * Copyright ((c)) 2014, Georgia Tech Research Corporation
 * All rights reserved.
 *
 * 1. Battelle Memorial Institute (hereinafter Battelle) and Georgia Tech
 *    Research Corporation (GTRC) hereby grant permission to any person
 *    or entity lawfully obtaining a copy of this software and associated
 *    documentation files (hereinafter "the Software") to redistribute
 *    and use the Software in source and binary forms, with or without
 *    modification.  Such person or entity may use, copy, modify, merge,
 *    publish, distribute, sublicense, and/or sell copies of the
 *    Software, and may permit others to do so, subject to the following
 *    conditions:
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
 *      Institute nor Battelle may be used in any form whatsoever without
 *      the express written consent of Battelle.
 * 
 *      Other than as used herein, neither the name Georgia Tech Research
 *      Corporation nor GTRC may not be used in any form whatsoever
 *      without the express written consent of GTRC.
 * 
 *    * Redistributions of the software in any form, and publications
 *      based on work performed using the software should include the
 *      following citation as a reference:
 * 
 *      Kevin Barker, Thomas Benson, Dan Campbell, David Ediger, Roberto
 *      Gioiosa, Adolfy Hoisie, Darren Kerbyson, Joseph Manzano, Andres
 *      Marquez, Leon Song, Nathan R. Tallent, and Antonino Tumeo.
 *      PERFECT (Power Efficiency Revolution For Embedded Computing
 *      Technologies) Benchmark Suite Manual. Pacific Northwest National
 *      Laboratory and Georgia Tech Research Institute, December 2013.
 *      http://hpc.pnnl.gov/projects/PERFECT/
 *
 * 2. THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 *    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 *    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 *    FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
 *    BATTELLE, GTRC, OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 *    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 *    (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 *    SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 *    HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 *    STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *    ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 *    OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 **EndCopyright*************************************************************/

#include <stdlib.h>
#include <stdio.h>
#include <math.h>

#include "wami_lucas_kanade.h"

void
warp_image (fltPixel_t *Iin, int nCols, int nRows, float *W_xp, fltPixel_t *Iout)
{
   int x, y;
   float compb0, compb1;
   int index = 0;

   compb0 = W_xp[2];
   compb1 = W_xp[5];

#pragma omp parallel for private(y,x) 
   for (y = 1; y <= nRows; y++) {
      float compa0, compa1;
      compa0 = W_xp[1] * ((float) y) + compb0;
      compa1 = W_xp[4] * ((float) y) + compb1;

      for (x = 1; x <= nCols; x++) {
         float Tlocalx, Tlocaly;
         Tlocalx = W_xp[0] * ((float) x) + compa0;
         Tlocaly = W_xp[3] * ((float) x) + compa1;

#ifdef _USE_OPENMP
         Iout[(y-1)*nCols+ (x-1)] = interpolate (Tlocalx, Tlocaly, nCols, nRows, Iin);
#else
         Iout[index] = interpolate (Tlocalx, Tlocaly, nCols, nRows, Iin);
         index++;
#endif
      }
   }
}

void
steepest_descent (fltPixel_t *gradX_warped, fltPixel_t *gradY_warped, int nCols, int nRows, fltPixel_t *I_steepest)
{
   int y;
   int x;
#pragma omp parallel for private(y,x)
   for (y = 0; y < nRows; y++) {
      for (x = 0; x < nCols; x++) {
         float Jacobian_x[6], Jacobian_y[6];
         int index, j_index;
         int k;
         index = y * nCols + x;

         Jacobian_x[0] = (float) x;
         Jacobian_x[1] = 0.0;
         Jacobian_x[2] = (float) y;
         Jacobian_x[3] = 0.0;
         Jacobian_x[4] = 1.0;
         Jacobian_x[5] = 0.0;

         Jacobian_y[0] = 0.0;
         Jacobian_y[1] = (float) x;
         Jacobian_y[2] = 0.0;
         Jacobian_y[3] = (float) y;
         Jacobian_y[4] = 0.0;
         Jacobian_y[5] = 1.0;

         for (k = 0; k < 6; k++) {
            j_index = (6 * y * nCols) + (nCols * k) + x;
            I_steepest[j_index] = (Jacobian_x[k] * gradX_warped[index]) + (Jacobian_y[k] * gradY_warped[index]);
         }
      }
   }
}

void
hessian (fltPixel_t *I_steepest, int nCols, int nRows, int np, float *H)
{
   int y;
   for (y = 0; y < nRows; y++) {
      int i,j;
#pragma omp parallel for private(i,j) 
      for (i = 0; i < np; i++) {
         for (j = 0; j < np; j++) {
            float total = 0.0;
            int x;
            for (x = 0; x < nCols; x++) {
               int index1 = (6 * y * nCols) + (nCols * i) + x;
               int index2 = (6 * y * nCols) + (nCols * j) + x;
               total += I_steepest[index1] * I_steepest[index2];
            }
            H[6*i + j] += total;
         }
      }
   }
}

