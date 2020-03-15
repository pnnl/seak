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
#include <string.h>
#include <assert.h>
#include <unistd.h>
#include <sys/time.h>
#include <omp.h>

#include "stap_params.h"
#include "stap_utils.h"
#include "stap_apply_weighting.h"

#include "../../../lib/timing/timer.h"

#define ENABLE_CORRECTNESS_CHECKING

#if INPUT_SIZE == INPUT_SIZE_SMALL
   static const char *input_filename = "small_input.bin";
   static const char *kernel2_output_filename = "small_kernel2_output.bin";
   static const char *kernel3_output_filename = "small_kernel3_output.bin";
   static const char *steering_vector_filename = "small_steering_vectors.bin";
#elif INPUT_SIZE == INPUT_SIZE_MEDIUM
   static const char *input_filename = "medium_input.bin";
   static const char *kernel2_output_filename = "medium_kernel2_output.bin";
   static const char *kernel3_output_filename = "medium_kernel3_output.bin";
   static const char *steering_vector_filename = "medium_steering_vectors.bin";
#elif INPUT_SIZE == INPUT_SIZE_LARGE
   static const char *input_filename = "large_input.bin";
   static const char *kernel2_output_filename = "large_kernel2_output.bin";
   static const char *kernel3_output_filename = "large_kernel3_output.bin";
   static const char *steering_vector_filename = "large_steering_vectors.bin";
#else
   #error "Unhandled value for INPUT_SIZE"
#endif

int main(int argc, char **argv)
{
   complex (*datacube)[N_DOP][N_RANGE] = NULL;
   complex (*adaptive_weights)[N_BLOCKS][N_STEERING][N_CHAN*TDOF] = NULL;
   complex (*steering_vectors)[N_CHAN*TDOF] = NULL;
   complex (*output)[N_DOP][N_RANGE] = NULL;
   char *input_directory = NULL;

#ifdef ENABLE_CORRECTNESS_CHECKING
   complex (*gold_output)[N_DOP][N_RANGE] = NULL;
#endif

   const size_t num_datacube_elements = N_CHAN * N_DOP * N_RANGE;
   const size_t num_adaptive_weight_elements = N_DOP * N_BLOCKS *
        N_STEERING * (N_CHAN*TDOF);
   const size_t num_steering_vector_elements = N_STEERING *
        (N_CHAN*TDOF);
   const size_t num_output_elements = N_STEERING *
        N_DOP * N_RANGE;
    
   if (argc < 2)
   {
      fprintf(stderr, "%s <directory-containing-input-files>\n", argv[0]);
      exit(EXIT_FAILURE);
   }
   input_directory = argv[1];

   datacube = XMALLOC(sizeof(complex) * num_datacube_elements);
   adaptive_weights = XMALLOC(sizeof(complex) * num_adaptive_weight_elements);
   steering_vectors = XMALLOC(sizeof(complex) * num_steering_vector_elements);
   output = XMALLOC(sizeof(complex) * num_output_elements);

#ifdef ENABLE_CORRECTNESS_CHECKING
   gold_output = XMALLOC(sizeof(complex) * num_output_elements);
#endif

   printf("Loading input files from %s...\n", input_directory);

   read_complex_data_file(
        (complex *) datacube,
        input_filename,
        input_directory,
        num_datacube_elements);

   read_complex_data_file(
        (complex *) steering_vectors,
        steering_vector_filename,
        input_directory,
        num_steering_vector_elements);

   read_complex_data_file(
        (complex *) adaptive_weights,
        kernel2_output_filename,
        input_directory,
        num_adaptive_weight_elements);

#ifdef ENABLE_CORRECTNESS_CHECKING
   read_complex_data_file(
        (complex *) gold_output,
        kernel3_output_filename,
        input_directory,
        num_output_elements);
#endif

   tic ();
   printf("Calling OMP STAP Kernel 3 -- adaptive weighting / inner products...\n");
   /* Kernel 3: Adaptive Weighting (Inner Products) */
   stap_apply_weighting(
            output,
            datacube,
            adaptive_weights,
            steering_vectors);
   PRINT_STAT_DOUBLE ("CPU time using func toc -  ", toc ());

#ifdef ENABLE_CORRECTNESS_CHECKING
   {
      double snr;
      printf("\nComputing correctness metrics...\n");
      snr = calculate_snr(
            (complex *) gold_output,
            (complex *) output,
            num_output_elements);
      printf("\tSNR after STAP kernel 3 : %.2f dB\n", snr);
   }
   FREE_AND_NULL(gold_output);
#endif

   FREE_AND_NULL(datacube);
   FREE_AND_NULL(adaptive_weights);
   FREE_AND_NULL(steering_vectors);
   FREE_AND_NULL(output);

   return 0;
}

