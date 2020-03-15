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

#ifndef __MLP_H__
#define __MLP_H__

#include <omp.h>

#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>

#include <iostream>
#include <string>
#include <vector>

#include "DataType.h"

#define USE_BIAS 1
#define TRACK_COST 1

class MLP {
public:
	void initNetwork( const std::vector<S32>& v_layerWidth );
	void cleanupNetwork( void );
	void trainNetwork( const S32 numRounds, const S32 miniBatchSize, const REAL alpha, const std::vector<U8>& v_label, const std::vector<Img>& v_img );
	void testNetwork( const std::vector<U8>& v_label, const std::vector<Img>& v_img );

private:
	std::vector<std::vector<Vector> > vv_outputVector;/* [tid][layer] */
	std::vector<std::vector<Vector> > vv_nodeErrorVector;/* [tid][layer] */
#if USE_BIAS
	std::vector<Vector> v_biasVector;/* [layer] */
#endif
	std::vector<Matrix2D> v_weightMatrix;/* [layer] */

	omp_lock_t* p_biasVectorLocks;/* [layer] */
	std::vector<omp_lock_t*> vp_weightMatrixRowLocks;/* [layer][row] */

private:
	static void normalize( Vector& vector );
	static void activateHidden( Vector& vector );
	static void activateOutput( Vector& vector );/* softmax */
	static void diffActivationHidden( Vector& vector );
};

#endif/* #ifndef __MLP_H__ */

