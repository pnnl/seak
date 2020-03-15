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

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <assert.h>
#include <unistd.h>
#include <time.h>
#include <sys/time.h>
#include <omp.h>

#include "sar_backprojection.h"
#include "sar_utils.h"

#include "../../../../lib/timing/timer.h"

#define ENABLE_CORRECTNESS_CHECKING

#if INPUT_SIZE == INPUT_SIZE_SMALL
    static const char *output_filename = "small_kernel3_output.bin";
    static const char *golden_output_filename = 
                      "small_golden_kernel3_output.bin";
    static const char *input_filename = "small_kernel3_input.bin";
#elif INPUT_SIZE == INPUT_SIZE_MEDIUM
    static const char *output_filename = "medium_kernel3_output.bin";
    static const char *golden_output_filename = 
                      "medium_golden_kernel3_output.bin";
    static const char *input_filename = "medium_kernel3_input.bin";
#elif INPUT_SIZE == INPUT_SIZE_LARGE
    static const char *output_filename = "large_kernel3_output.bin";
    static const char *golden_output_filename = 
                      "large_golden_kernel3_output.bin";
    static const char *input_filename = "large_kernel3_input.bin";
#else
    #error "Unhandled value for INPUT_SIZE"
#endif

#define WRITE_OUTPUT_TO_DISK

static void read_bp_data_file(
   const char *input_filename,
   const char *input_directory,
   complex (*upsampled_data)[N_RANGE_UPSAMPLED],
           position *platpos,
   double *fc,
   double *R0,
   double *dR);

void convert_le_complex_array(complex *a, int size){
        int i;
        unsigned char f4 = 0;
        if(sizeof(a[0].re) == 4){
                f4 = 1;
        }
        for(i = 0; i < size; ++i)
        {
                if(f4){
                        uint32_t real, imag;
                        real = convert_le_32((unsigned char *)(&a[i].re));
                        imag = convert_le_32((unsigned char *)(&a[i].im));
                        a[i].re = *(float *)((unsigned char *)&real);
                        a[i].im = *(float *)((unsigned char *)&imag);
                }
                else{
                        uint64_t real, imag;
                        real = convert_le_64((unsigned char *)(&a[i].re));
                        imag = convert_le_64((unsigned char *)(&a[i].im));
                        a[i].re = *(float *)((unsigned char *)&real);
                        a[i].im = *(float *)((unsigned char *)&imag);
                }

        }
}


int main(int argc, char **argv)
{
   complex (*data)[N_RANGE_UPSAMPLED] = NULL;
   complex (*image)[BP_NPIX_X] = NULL;
   const char *input_directory = NULL;
   position *platpos = NULL;
#ifdef ENABLE_CORRECTNESS_CHECKING
   complex (*gold_image)[BP_NPIX_X] = NULL;
#endif
   const size_t num_data_elements = N_PULSES * N_RANGE_UPSAMPLED;
   const size_t num_image_elements = BP_NPIX_Y * BP_NPIX_X;
   const double z0 = 0.0;
   double fc, R0, dR, dxdy, ku;
   int fg;
   if (argc < 2)
   {
       fprintf(stderr, "%s <directory-containing-input-files>\n", argv[0]);
       exit(EXIT_FAILURE);
   }

   input_directory = argv[1];
   srand (time (NULL));
    
   data = XMALLOC(sizeof(complex) * num_data_elements);
   image = XMALLOC(sizeof(complex) * num_image_elements);
   platpos = XMALLOC(sizeof(position) * N_PULSES);
#ifdef ENABLE_CORRECTNESS_CHECKING
   gold_image = XMALLOC(sizeof(complex) * num_image_elements);
#endif

   read_bp_data_file(
      input_filename,
      input_directory,
      data,
      platpos,
      &fc,
      &R0,
      &dR);

#ifdef ENABLE_CORRECTNESS_CHECKING
   fg = find_endianess();
   read_data_file(
      (char *) gold_image,
      golden_output_filename,
      input_directory,
      sizeof(complex)*num_image_elements);

   if(fg == BENDIAN){
       complex *tmp = (complex *) gold_image;
       convert_le_complex_array(tmp, num_image_elements);
   }

#endif

   dxdy = dR;
   dR /= RANGE_UPSAMPLE_FACTOR;
   ku = 2.0 * M_PI * fc / SPEED_OF_LIGHT;

   printf("SAR kernel 3 parameters:\n\n");
   printf("Carrier frequency: %f GHz\n", fc/1.0e9);
   printf("Range bin resolution (native): %f m\n", dR*RANGE_UPSAMPLE_FACTOR);
   printf("Range bin resolution (upsampled): %f m\n", dR);
   printf("Image pixel spacing: %f m\n", dxdy);
   printf("Number of pulses: %d\n", N_PULSES);
   printf("Number of range bins: %d\n", N_RANGE);
   printf("Number of upsampled range bins: %d\n", N_RANGE_UPSAMPLED);
   printf("Output image dimension: %d x %d pixels\n", BP_NPIX_Y, BP_NPIX_X);

   printf("\nStarting kernel 3 (backprojection)... " );
   printf("this can take several minutes.\n");

   tic ();

   sar_backprojection(
      image,
      data,
      platpos,
      ku,
      R0,
      dR,
      dxdy,
      z0); 
   PRINT_STAT_DOUBLE ("CPU time using func toc -  ", toc ());

#ifdef WRITE_OUTPUT_TO_DISK
   {
      FILE *fp = fopen(output_filename, "wb");
      assert(fp != NULL);
      assert(fwrite(image, sizeof(complex), num_image_elements, fp) ==
             num_image_elements);
      fclose(fp);
   }
#endif

#ifdef ENABLE_CORRECTNESS_CHECKING
   {
      double snr = calculate_snr(
                   (complex *) gold_image,
                   (complex *) image,
                   num_image_elements);
      printf("\nImage correctness SNR: %.2f\n", snr);
   }
#endif
   FREE_AND_NULL(data);
   FREE_AND_NULL(image);
   FREE_AND_NULL(platpos);
#ifdef ENABLE_CORRECTNESS_CHECKING
   FREE_AND_NULL(gold_image);
#endif
   return 0;
}

void convert_le_position_array(position *a, int size){
	int i;
	unsigned char f4 = 0;
	if(sizeof(a[0].x) == 4){
		f4 = 1;
	}
	for(i = 0; i < size; ++i)
	{
		if(f4){
			uint32_t xx, yy, zz; 
			xx = convert_le_32((unsigned char *)(&a[i].x));
			yy = convert_le_32((unsigned char *)(&a[i].y));
			zz = convert_le_32((unsigned char *)(&a[i].z));
			a[i].x = *(double *)(&xx);
			a[i].y = *(double *)(&yy);
			a[i].z = *(double *)(&zz);

		}
		else{
			uint64_t xx, yy, zz;
			xx = convert_le_64((unsigned char *)(&a[i].x));
			yy = convert_le_64((unsigned char *)(&a[i].y));
			zz = convert_le_64((unsigned char *)(&a[i].z));
			a[i].x = *(double *)(&xx);
			a[i].y = *(double *)(&yy);
			a[i].z = *(double *)(&zz);
		}
	}
}

void read_bp_data_file(
   const char *input_filename,
   const char *input_directory,
   complex (*upsampled_data)[N_RANGE_UPSAMPLED],
            position *platpos,
   double *fc,
   double *R0,
   double *dR)
{
   FILE *fp = NULL;
   const size_t num_data_elements = N_RANGE_UPSAMPLED*N_PULSES;
   char dir_and_filename[MAX_DIR_AND_FILENAME_LEN];
   size_t n;
   assert(input_filename != NULL);
   assert(input_directory != NULL);
   assert(upsampled_data != NULL);
   assert(platpos != NULL);
   assert(fc != NULL);
   assert(R0 != NULL);
   assert(dR != NULL);
   uint32_t fg;
   
   fg = find_endianess();
   
   concat_dir_and_filename(
      dir_and_filename,
      input_directory,
      input_filename);
   fp = fopen(dir_and_filename, "rb");
   if (fp == NULL)
   {
      fprintf(stderr, "Error: Unable to open input file %s.\n",
              input_filename);
      exit(EXIT_FAILURE);
   }
   if (fread(fc, sizeof(double), 1, fp) != 1)
   {
      fprintf(stderr, "Error: Unable to read parameter fc from %s.\n",
              input_filename);
      exit(EXIT_FAILURE);
   }
   if (fread(R0, sizeof(double), 1, fp) != 1)
   {
      fprintf(stderr, "Error: Unable to read parameter R0 from %s.\n",
              input_filename);
      exit(EXIT_FAILURE);
   }
   if (fread(dR, sizeof(double), 1, fp) != 1)
   {
      fprintf(stderr, "Error: Unable to read parameter dR from %s.\n",
              input_filename);
      exit(EXIT_FAILURE);
   }
   if(fg == BENDIAN){
      if(sizeof(double) == 4){
	     uint32_t tmp = convert_le_32(((unsigned char *)fc));
	     *fc = *((double *)(&tmp));
	     tmp = convert_le_32(((unsigned char *)R0));
	     *R0 = *((double *)(&tmp));
	     tmp = convert_le_32(((unsigned char *)dR));
	     *dR = *((double *)(&tmp));
      }
      else{
	     uint64_t tmp = convert_le_64(((unsigned char *)fc));
	     *fc = *((double *)(&tmp));
	     tmp = convert_le_64(((unsigned char *)R0));
	     *R0 = *((double *)(&tmp));
	     tmp = convert_le_64(((unsigned char *)dR));
	     *dR = *((double *)(&tmp));	   
      }
   }
   if (fread(platpos, sizeof(position), N_PULSES, fp) != N_PULSES)
   {
      fprintf(stderr, "Error: Unable to read platform positions from %s.\n",
              input_filename);
      exit(EXIT_FAILURE);
   }
   if ((n = fread(upsampled_data, sizeof(complex), num_data_elements, fp)) !=
        num_data_elements)
   {
      fprintf(stderr, "Error: Unable to read phase history data from %s.\n",
              input_filename);
      exit(EXIT_FAILURE);
   }
   if(fg == BENDIAN){
     convert_le_complex_array(upsampled_data, num_data_elements);
     convert_le_position_array(platpos, N_PULSES);
   }
   fclose(fp);
}
