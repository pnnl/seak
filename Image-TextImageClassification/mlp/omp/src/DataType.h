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

#ifndef __DATA_TYPE_H__
#define __DATA_TYPE_H__

#include <assert.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>

#include <iostream>
#include <string>
#include <vector>

#define U8 unsigned char
#define S8 char
#define U16 unsigned short
#define S16 short
#define U32 unsigned int
#define S32 int
#define U64 unsigned long long
#define S64 long long

#define REAL double

#define BOOL U8

#define INVALID_IDX -1

class Img {
public:
	std::vector<U8> v_data;

public:
	Img( void ) {
		/* nothing to do */
	}

	Img( const S32 numBytes, const U8* p_data ) {
		v_data.assign( p_data, p_data + numBytes - 1 );
	}

	~Img( void ) {
		/* nothing to do */
	}

	void init( const S32 numBytes, const U8* p_data ) {
		v_data.assign( p_data, p_data + numBytes );
		return;
	}
};

class Node {
public:
	static const S32 NODE_TYPE_INPUT = 0;
	static const S32 NODE_TYPE_HIDDEN = 1;
	static const S32 NODE_TYPE_OUTPUT = 2;

	S32 type;
	REAL output;
};

class Vector {
public:
	std::vector<REAL> v_val;

public:
	Vector( void ) {
		/* nothing to do */
	}

	Vector( const S32 length, const REAL initVal ) {
		this->init( length, initVal );
	}

	~Vector( void ) {
		/* nothing to do */
	}

	void init( const S32 length, const REAL initVal ) {
		this->v_val.assign( length, initVal );
		return;
	}

	void hadamardProduct( const Vector& vector ) {
		for( S32 i = 0 ; i < ( S32 )this->v_val.size() ; i++ ) {
			this->v_val[i] *= vector.v_val[i];
		}
	}

	void increment( const Vector& vector ) {
		assert( this->v_val.size() == vector.v_val.size() );
		for( S32 i = 0 ; i < this->v_val.size() ; i++ ) {
			this->v_val[i] += vector.v_val[i];
		}
		return;
	}

	void scale( const REAL val ) {
		for( S32 i = 0 ; i < this->v_val.size() ; i++ ) {
			this->v_val[i] *= val;
		}
		return;
	}
};

class Matrix2D {
public:
	std::vector<std::vector<REAL> > vv_val;

public:
	Matrix2D( void ) {
		/* nothing to do */
	}

	Matrix2D( const S32 numRows, const S32 numCols, const REAL initVal ) {
		this->init( numRows, numCols, initVal );
	}

	~Matrix2D( void ) {
		/* nothing to do */
	}

	void init( const S32 numRows, const S32 numCols, const REAL initVal ) {
		this->vv_val.resize( numRows );
		for( S32 i = 0 ; i < numRows ; i++ ) {
			this->vv_val[i].assign( numCols, initVal );
		}
		return;
	}

	void matVecMult( const Vector& vecIn, Vector& vecOut ) const {
		assert( vecOut.v_val.size() == this->vv_val.size() );
		assert( this->vv_val.size() > 0 );
		assert( vecIn.v_val.size() == this->vv_val[0].size() );
		for( S32 i = 0 ; i < ( S32 )this->vv_val.size() ; i++ ) {
			REAL& val = vecOut.v_val[i];
			val = 0.0;
			for( S32 j = 0 ; j < ( S32 )this->vv_val[0].size() ; j++ ) {
				val += this->vv_val[i][j] * vecIn.v_val[j];
			}
		}
		return;
	}

	void transposedMatVecMult( const Vector& vecIn, Vector& vecOut ) const {
		assert( this->vv_val.size() > 0 );
		assert( vecOut.v_val.size() == this->vv_val[0].size() );
		assert( vecIn.v_val.size() == this->vv_val.size() );
		for( S32 i = 0 ; i < this->vv_val[0].size() ; i++ ) {
			REAL& val = vecOut.v_val[i];
			val = 0.0;
			for( S32 j = 0 ; j < this->vv_val.size() ; j++ ) {
				val += this->vv_val[j][i] * vecIn.v_val[j];
			}
		}
		return;
	}

	void increment( const Matrix2D& mat ) {
		assert( this->vv_val.size() == mat.vv_val.size() );
		for( S32 i = 0 ; i < this->vv_val.size() ; i++ ) {
			assert( this->vv_val[i].size() == mat.vv_val[i].size() );
			for( S32 j = 0 ; j < this->vv_val[i].size() ; j++ ) {
				this->vv_val[i][j] += mat.vv_val[i][j];
			}
		}
		return;
	}

	void scale( const REAL val ) {
		for( S32 i = 0 ; i < this->vv_val.size() ; i++ ) {
			for( S32 j = 0 ; j < this->vv_val[i].size() ; j++ ) {
				this->vv_val[i][j] *= val;
			}
		}
		return;
	}
};

#endif/* #ifndef __DATA_TYPE_H__ */

