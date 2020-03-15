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

#include "sar_utils.h"
#include <stdio.h>
#include <math.h>
#include <assert.h>
#include <string.h>

complex cconj(complex x)
{
    complex xconj = x;
    xconj.im *= -1.0f;
    return xconj;
}

complex cmult(complex lhs, complex rhs)
{
    complex prod;
    prod.re = lhs.re * rhs.re - lhs.im * rhs.im;
    prod.im = lhs.re * rhs.im + lhs.im * rhs.re;
    return prod;
}

double calculate_snr(
    const complex *reference,
    const complex *test,
    size_t num_elements)
{
    double num = 0.0, den = 0.0;
    size_t i;

    for (i = 0; i < num_elements; ++i)
    {
        den += (reference[i].re - test[i].re) *
               (reference[i].re - test[i].re);
        den += (reference[i].im - test[i].im) *
               (reference[i].im - test[i].im);
        num += reference[i].re * reference[i].re +
               reference[i].im * reference[i].im;
    }

    if (den == 0)
    {
        /* 
         * The test and reference sets are identical. Just
         * return a large number (in dB) rather than +infinity.
         */
        return 140.0;
    }
    else
    {
        return 10.0*log10(num/den);
    }
}

void *xmalloc(size_t size, const char *file, int line)
{
    void *x = malloc(size);
    if (x == NULL)
    {
        fprintf(stderr, "Error: memory allocation of size %lu at %s:%d.\n",
            size, file, line);
        exit(EXIT_FAILURE);
    }
    return x;
}

void concat_dir_and_filename(
    char dir_and_filename[MAX_DIR_AND_FILENAME_LEN],
    const char *directory,
    const char *filename)
{
    assert(dir_and_filename != NULL);
    assert(directory != NULL);
    assert(filename != NULL);

    /* C89 lacks snprintf */
    if (strlen(directory) + strlen(filename) + 2 > MAX_DIR_AND_FILENAME_LEN)
    {
        fprintf(stderr, "Error: input directory (%s) too long.\n",
            directory);
        exit(EXIT_FAILURE);
    }
    dir_and_filename[0] = '\0';
    strncpy(dir_and_filename, directory, MAX_DIR_AND_FILENAME_LEN-1);
    dir_and_filename[MAX_DIR_AND_FILENAME_LEN-1] = '\0';
    strncat(dir_and_filename, "/",
        MAX_DIR_AND_FILENAME_LEN - strlen(dir_and_filename) - 1);
    strncat(dir_and_filename, filename,
        MAX_DIR_AND_FILENAME_LEN - strlen(dir_and_filename) - 1);
}

uint32_t find_endianess(){
        uint64_t len = 0x0123456789abcdefULL;
        end_convert_t test;
        test.whole = len;
        if(test.bytes[0] == 0x01)
           return BENDIAN;
        return LENDIAN;
}

uint16_t convert_le_16(unsigned char *num){
        uint16_t val = 0;
        val = (val | num[1]) << 8;
        val |= num[0];
        return val;
}

uint32_t convert_le_32(unsigned char *num){
        uint32_t val = 0;
        val = (val | num[3]) << 8;
        val = (val | num[2]) << 8;
        val = (val | num[1]) << 8;
        val = (val | num[0]);
        return val;
}

uint64_t convert_le_64(unsigned char *num){
        uint64_t val = 0;
        val = (val | num[7]) << 8;
        val = (val | num[6]) << 8;
        val = (val | num[5]) << 8;
        val = (val | num[4]) << 8;
        val = (val | num[3]) << 8;
        val = (val | num[2]) << 8;
        val = (val | num[1]) << 8;
        val = (val | num[0]);
        return val;
}

void read_data_file(
    char *data,
    const char *filename,
    const char *directory,
    size_t num_bytes)
{
    size_t nread = 0;
    FILE *fp = NULL;
    char dir_and_filename[1024];
    uint32_t fg;

    assert(data != NULL);
    assert(filename != NULL);
    assert(directory != NULL);

    concat_dir_and_filename(
        dir_and_filename,
        directory,
        filename);

    fp = fopen(dir_and_filename, "rb");
    if (fp == NULL)
    {
        fprintf(stderr, "Error: Unable to open input file %s for reading.\n",
            dir_and_filename);
        exit(EXIT_FAILURE);
    }

    nread = fread(data, sizeof(char), num_bytes, fp);
    if (nread != num_bytes)
    {
        fprintf(stderr, "Error: read failure on %s. "
            "Expected %lu bytes, but only read %lu.\n",
            dir_and_filename, num_bytes, nread);
        fclose(fp);
        exit(EXIT_FAILURE);
    }        

    fclose(fp);
}
