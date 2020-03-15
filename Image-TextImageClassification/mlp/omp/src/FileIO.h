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

#ifndef __FILE_IO_H__
#define __FILE_IO_H__

#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>

#include <iostream>
#include <string>
#include <vector>

#include "DataType.h"

class FileIO {
public:
	static const U32 LABEL_MAGIC_NUMBER = 2049;
	static const U32 IMG_MAGIC_NUMBER = 2051;

	static const std::string TRAINING_LABEL_NAME;
	static const std::string TRAINING_IMG_NAME;

	static const std::string TEST_LABEL_NAME;
	static const std::string TEST_IMG_NAME;

public:
	static void readLabelFile( const BOOL doTraining/* true if training, false if testing */, const std::string dirPath, std::vector<U8>& v_label );
	static void readImgFile( const BOOL doTraining/* true if training, false if testing */, const std::string dirPath, std::vector<Img>& v_img );

private:
	static size_t readFile( const std::string filePath, U8** pp_data );
	static U32 bigToLittleEndian( U32 big );
};

#endif/* #ifndef __FILE_IO_H__ */

