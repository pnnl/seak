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

#ifndef _SAR_UTILS_H_
#define _SAR_UTILS_H_

#include <stdlib.h>
#include <math.h>

#ifndef M_PI
    #define M_PI 3.14159265358979323846
#endif

#define SPEED_OF_LIGHT (3.0e8)

typedef struct _complex { float re, im; } complex;

typedef struct _position
{
    double x, y, z;
} position;

/* complex conjugate */
complex cconj(complex x);

/* complex multiplication */
complex cmult(complex lhs, complex rhs);

/* Added little endian to big endian conversion */

#define BENDIAN 0
#define LENDIAN 1

#include <stdint.h>
#include <inttypes.h>

typedef union __end_convert_t{
        unsigned char bytes[8];
        uint16_t quaters[4];
        uint32_t half[2];
        uint64_t whole;
} end_convert_t;

uint32_t find_endianess();
uint16_t convert_le_16(unsigned char *num);
uint32_t convert_le_32(unsigned char *num);
uint64_t convert_le_64(unsigned char *num);

/* calculate the decibel scale signal-to-error ratio */
double calculate_snr(
    const complex *reference,
    const complex *test,
    size_t num_elements);

#define MAX_DIR_AND_FILENAME_LEN (1024)

/* appends filename to directory */
void concat_dir_and_filename(
    char dir_and_filename[MAX_DIR_AND_FILENAME_LEN],
    const char *directory,
    const char *filename);

/* reads input data files */
void read_data_file(
    char *data,
    const char *filename,
    const char *directory,
    size_t num_bytes);

/* error checked memory allocation */
#define XMALLOC(size) xmalloc(size, __FILE__, __LINE__)
void *xmalloc(size_t size, const char *file, int line);

#define FREE_AND_NULL(x) \
    do { \
        if (x) { free(x); } \
        x = NULL; \
    } while (0); 
        
#endif /* _SAR_UTILS_H_ */
