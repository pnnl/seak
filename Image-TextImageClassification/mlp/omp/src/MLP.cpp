// -*-Mode: C++;-*-

//*BeginCopyright************************************************************
//
// $HeadURL$
// $Id$
//
//---------------------------------------------------------------------------
// SEAK: Suite for Embedded Applications and Kernels (hpc.pnnl.gov/SEAK/)
//---------------------------------------------------------------------------
//
// Copyright ((c)) 2016, Battelle Memorial Institute
//
// 1. Battelle Memorial Institute (hereinafter Battelle) hereby grants
//    permission to any person or entity lawfully obtaining a copy of
//    this software and associated documentation files (hereinafter "the
//    Software") to redistribute and use the Software in source and
//    binary forms, with or without modification.  Such person or entity
//    may use, copy, modify, merge, publish, distribute, sublicense,
//    and/or sell copies of the Software, and may permit others to do so,
//    subject to the following conditions:
//    
//    * Redistributions of source code must retain the above copyright
//      notice, this list of conditions and the following disclaimers.
//
//    * Redistributions in binary form must reproduce the above copyright
//      notice, this list of conditions and the following disclaimer in
//      the documentation and/or other materials provided with the
//      distribution.
//
//    * Other than as used herein, neither the name Battelle Memorial
//      Institute or Battelle may be used in any form whatsoever without
//      the express written consent of Battelle.
//
//    * Redistributions of the software in any form, and publications
//      based on work performed using the software should include the
//      following citation as a reference:
//            
//        Nitin A. Gawande, Seunghwa Kang, Joseph B. Manzano, Nathan
//        R. Tallent, Darren J. Kerbyson, Adolfy Hoisie.  "SEAK
//        Specification." Pacific Northwest National Laboratory. May,
//        2016, http://hpc.pnnl.gov/SEAK/
//
// 2. THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
//    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
//    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
//    FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL BATTELLE
//    OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
//    SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
//    LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF
//    USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//    ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
//    OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
//    OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
//    SUCH DAMAGE.
//
//*EndCopyright**************************************************************

#include <omp.h>

#include <math.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/time.h>

#include <iostream>
#include <string>

#include <cstdlib> // added Nitin

#include "DataType.h"
#include "MLP.h"

using namespace std;

void MLP::initNetwork( const vector<S32>& v_layerWidth ) {
	S32 maxThreads = omp_get_max_threads();

	assert( v_layerWidth.size() >= 2 );

	this->vv_outputVector.resize( maxThreads );
	this->vv_nodeErrorVector.resize( maxThreads );
	for( S32 i = 0 ; i < maxThreads ; i++ ) {
		this->vv_outputVector[i].resize( v_layerWidth.size() );
		this->vv_nodeErrorVector[i].resize( v_layerWidth.size() );
		for( S32 j = 0 ; j < ( S32 )v_layerWidth.size() ; j++ ) {
			Vector& outputVector = this->vv_outputVector[i][j];
			Vector& nodeErrorVector = this->vv_nodeErrorVector[i][j];
			outputVector.v_val.assign( v_layerWidth[j], 0.0 );
			nodeErrorVector.v_val.assign( v_layerWidth[j], 0.0 );
		}
	}

#if USE_BIAS
	this->v_biasVector.resize( v_layerWidth.size() );
	this->p_biasVectorLocks = new omp_lock_t[v_layerWidth.size()];
#endif
	this->v_weightMatrix.resize( v_layerWidth.size() );
	this->vp_weightMatrixRowLocks.assign( v_layerWidth.size(), NULL );

	for( S32 i = 0 ; i < ( S32 )v_layerWidth.size() ; i++ ) {
		if( i > 0 ) {/* if not the input layer */
			S32 fanIn = v_layerWidth[i - 1];
			S32 fanOut = v_layerWidth[i];
			REAL scale = 0.05;/* initialize the MLP edge weights to a small random numbers in the range of [-0.05,0.05] with the uniform distribution */

#if USE_BIAS
			Vector& biasVector = this->v_biasVector[i];
			biasVector.v_val.assign( v_layerWidth[i], 0.0 );
			for( S32 j = 0  ; j < ( S32 )biasVector.v_val.size() ; j++ ) {
				biasVector.v_val[j] = 0.0;
			}
			omp_init_lock( &( this->p_biasVectorLocks[i] ) );
#endif

			Matrix2D& weightMatrix = this->v_weightMatrix[i];
			weightMatrix.init( fanOut/* numRows */, fanIn/* numCols */, 0.0 );
			for( S32 ii = 0 ; ii < ( S32 )weightMatrix.vv_val.size() ; ii++ ) {
				for( S32 jj = 0 ; jj < weightMatrix.vv_val[ii].size() ; jj++ ) {
					weightMatrix.vv_val[ii][jj] = ( ( ( REAL )rand() / RAND_MAX ) * 2.0 - 1.0 ) * scale;
				}
			}

			this->vp_weightMatrixRowLocks[i] = new omp_lock_t[fanOut];
			for( S32 ii = 0 ; ii < fanOut ; ii++ ) {
				omp_init_lock( &( this->vp_weightMatrixRowLocks[i][ii] ) );
			}
		}
	}

	return;
}

void MLP::cleanupNetwork( void ) {
	for( S32 i = 1 ; i < ( S32 )this->v_biasVector.size() ; i++ ) {
		omp_destroy_lock( &( this->p_biasVectorLocks[i] ) );
	}
	delete[] this->p_biasVectorLocks;

	for( S32 i = 1 ; i < ( S32 )this->v_weightMatrix.size() ; i++ ) {
		for( S32 j = 0 ; j < ( S32 )this->v_weightMatrix[i].vv_val.size() ; j++ ) {
			omp_destroy_lock( &( this->vp_weightMatrixRowLocks[i][j] ) );
		}
		delete[] this->vp_weightMatrixRowLocks[i];
	}

	return;
}

void MLP::trainNetwork( const S32 numRounds, const S32 miniBatchSize, const REAL alpha, const vector<U8>& v_label, const vector<Img>& v_img ) {
	vector<S32> v_idx;
	U32 seed = 0;

	v_idx.resize( miniBatchSize );

	for( S32 round = 0 ; round < numRounds ; round++ ) {
#if USE_BIAS
		vector<Vector> v_biasVectorDelta;
#endif
		vector<Matrix2D> v_weightMatrixDelta;
#if TRACK_COST
		REAL totCost = 0.0;
#endif

		struct timeval tv0;
		struct timeval tv1;

		gettimeofday( &tv0, NULL );

#if USE_BIAS
		v_biasVectorDelta.resize( this->v_biasVector.size() );
		#pragma omp parallel for
		for( S32 i = 1 ; i < ( S32 )v_biasVectorDelta.size() ; i++ ) {
			const Vector& biasVector = this->v_biasVector[i];
			Vector& biasVectorDelta = v_biasVectorDelta[i];
			biasVectorDelta.init( biasVector.v_val.size(), 0.0 );
		}
#endif

		v_weightMatrixDelta.resize( this->v_weightMatrix.size() );
		#pragma omp parallel for
		for( S32 i = 1 ; i < ( S32 )v_weightMatrixDelta.size() ; i++ ) {
			const Matrix2D& weightMatrix = this->v_weightMatrix[i];
			Matrix2D& weightMatrixDelta = v_weightMatrixDelta[i];
			assert( weightMatrix.vv_val.size() > 0 );
			weightMatrixDelta.init( weightMatrix.vv_val.size(), weightMatrix.vv_val[0].size(), 0.0 );
		}

		/* select the minibatch */

		for( S32 i = 0 ; i < miniBatchSize ; i++ ) {
			v_idx[i] = ( S32 )( rand_r( &seed ) % v_img.size() );
		}

		/* loop over the minibatch */

		#pragma omp parallel
		{
			S32 tid = omp_get_thread_num();
			vector<Vector>& v_outputVector = this->vv_outputVector[tid];
			vector<Vector>& v_nodeErrorVector = this->vv_nodeErrorVector[tid];
			REAL tmpTotCost = 0.0;

			#pragma omp for
			for( S32 i = 0 ; i < ( S32 )v_idx.size() ; i++ ) {
				const Img& img = v_img[v_idx[i]];
				const U8& label = v_label[v_idx[i]];

				/* forward propagation */

				assert( v_outputVector.size() > 0 );
				assert( v_outputVector[0].v_val.size() == img.v_data.size() );
				for( S32 j = 0 ; j < ( S32 )v_outputVector[0].v_val.size() ; j++ ) {
					v_outputVector[0].v_val[j] = ( REAL )img.v_data[j];
				}
				MLP::normalize( v_outputVector[0] );

				/* this loop cannot be parallelized */
				for( S32 j = 1 ; j < ( S32 )v_outputVector.size() ; j++ ) {
					this->v_weightMatrix[j].matVecMult( v_outputVector[j - 1], v_outputVector[j] );
#if USE_BIAS
					v_outputVector[j].increment( this->v_biasVector[j] );
#endif
					if( j == ( S32 )( v_outputVector.size() - 1 ) ) {/* output layer */
						MLP::activateOutput( v_outputVector[j] );
					}
					else {/* hidden layer */
						MLP::activateHidden( v_outputVector[j] );
					}
				}

				/* backward propagation */

				/* this loop cannot be parallelized */
				for( S32 j = ( S32 )( v_outputVector.size() - 1 ) ; j > 0 ; j-- ) {
					if( j == ( S32 )( v_outputVector.size() - 1 ) ) {/* output layer */
						for( S32 k = 0 ; k < ( S32 )v_outputVector[j].v_val.size() ; k++ ) {
							REAL t_k;

							/* partial cost / partial z_k = y_k - t_k */

							if( k == ( S32 )label ) {
								t_k= 1.0;
#if TRACK_COST
								tmpTotCost += -1.0 * log( v_outputVector[j].v_val[k] );
#endif
							}
							else {
								t_k=  0.0;
							}

							v_nodeErrorVector[j].v_val[k]/* partial cost / partial z_k */ = v_outputVector[j].v_val[k] - t_k;
						}
					}
					else {/* hidden layer */
						Vector diffVec;

						this->v_weightMatrix[j + 1].transposedMatVecMult( v_nodeErrorVector[j + 1], v_nodeErrorVector[j] );

						diffVec.init( v_nodeErrorVector[j].v_val.size(), 0.0 );
						for( S32 k = 0 ; k < ( S32 )diffVec.v_val.size() ; k++ ) {
							diffVec.v_val[k] = v_outputVector[j].v_val[k];
						}
						MLP::diffActivationHidden( diffVec );

						v_nodeErrorVector[j].hadamardProduct( diffVec );
					}

#if USE_BIAS
					Vector& biasVectorDelta = v_biasVectorDelta[j];
					assert( biasVectorDelta.v_val.size() == v_nodeErrorVector[j].v_val.size() );
					omp_set_lock( &( this->p_biasVectorLocks[j] ) );
					biasVectorDelta.increment( v_nodeErrorVector[j] );
					omp_unset_lock( &( this->p_biasVectorLocks[j] ) );
#endif

					Matrix2D& weightMatrixDelta = v_weightMatrixDelta[j];
					for( S32 ii = 0 ; ii < ( S32 )weightMatrixDelta.vv_val.size() ; ii++ ) {
						omp_set_lock( &( this->vp_weightMatrixRowLocks[j][ii] ) );
						for( S32 jj = 0 ; jj < weightMatrixDelta.vv_val[ii].size() ; jj++ ) {
							weightMatrixDelta.vv_val[ii][jj] += v_nodeErrorVector[j].v_val[ii] * v_outputVector[j - 1].v_val[jj];
						}
						omp_unset_lock( &( this->vp_weightMatrixRowLocks[j][ii] ) );
					}
				}
			}

			#pragma omp atomic
			totCost += tmpTotCost;
		}

#if USE_BIAS
		/* update biases */

		#pragma omp parallel for
		for( S32 i = 1 ; i < ( S32 )this->v_biasVector.size() ; i++ ) {
			Vector& biasVectorDelta = v_biasVectorDelta[i];
			Vector& biasVector = this->v_biasVector[i];
			biasVectorDelta.scale( alpha * -1.0 );
			biasVector.increment( biasVectorDelta );
		}
#endif

		/* update weight matrices */

		#pragma omp parallel for
		for( S32 i = 1 ; i < ( S32 )this->v_weightMatrix.size() ; i++ ) {
			Matrix2D& weightMatrixDelta = v_weightMatrixDelta[i];
			Matrix2D& weightMatrix = this->v_weightMatrix[i];
			weightMatrixDelta.scale( alpha * -1.0 );
			weightMatrix.increment( weightMatrixDelta );
		}

		gettimeofday( &tv1, NULL );

#if TRACK_COST
		cout << "round " << round + 1 << "/" << numRounds << " alpha=" << alpha << " cost = " << totCost / ( REAL )miniBatchSize << " time=" << ( ( tv1.tv_sec - tv0.tv_sec ) * 1.0e6 + ( tv1.tv_usec - tv0.tv_usec ) ) / 1.0e6 << " seconds." << endl;
#else
		cout << "round " << round << "/" << numRounds << " alpha=" << alpha << " time=" << ( ( tv1.tv_sec - tv0.tv_sec ) * 1.0e6 + ( tv1.tv_usec - tv0.tv_usec ) ) / 1.0e6 << " seconds." << endl;
#endif
	}

	return;
}

void MLP::testNetwork( const vector<U8>& v_label, const vector<Img>& v_img ) {
	S32 numErr = 0;

	assert( v_label.size() == v_img.size() );
	#pragma omp parallel
	{
		S32 tid = omp_get_thread_num();
		vector<Vector>& v_outputVector = this->vv_outputVector[tid];
		S32 tmpNumErr = 0;

		#pragma omp for
		for( S32 i = 0 ; i < ( S32 )v_label.size() ; i++ ) {
			const Img& img = v_img[i];
			const U8& label = v_label[i];
			REAL maxVal = 0.0;
			S32 maxIdx = INVALID_IDX;

			/* forward propagation */

			assert( v_outputVector.size() > 0 );
			assert( v_outputVector[0].v_val.size() == img.v_data.size() );
			for( S32 j = 0 ; j < ( S32 )v_outputVector[0].v_val.size() ; j++ ) {
				v_outputVector[0].v_val[j] = ( REAL )img.v_data[j];
			}
			MLP::normalize( v_outputVector[0] );

			/* this loop cannot be parallelized */
			for( S32 j = 1 ; j < ( S32 )v_outputVector.size() ; j++ ) {
				this->v_weightMatrix[j].matVecMult( v_outputVector[j - 1], v_outputVector[j] );
#if USE_BIAS
				v_outputVector[j].increment( this->v_biasVector[j] );
#endif
				if( j == ( S32 )( v_outputVector.size() - 1 ) ) {/* output layer */
					MLP::activateOutput( v_outputVector[j] );
				}
				else {/* hidden layer */
					MLP::activateHidden( v_outputVector[j] );
				}
			}

			/* find the node with the maximum probability estimation value */

			assert( v_outputVector.back().v_val.size() == 10 );/* 0 to 9 */
			for( S32 j = 0 ; j < ( S32 )v_outputVector.back().v_val.size() ; j++ ) {
				if( v_outputVector.back().v_val[j] > maxVal ) {
					maxVal = v_outputVector.back().v_val[j];
					maxIdx = j;
				}
			}
			assert( maxIdx != INVALID_IDX );

			/* check the result */

			if( maxIdx != ( S32 )label ) {
				tmpNumErr++;
			}
		}

		#pragma omp atomic
		numErr += tmpNumErr;
	}

	cout << "error rate = " << ( ( REAL )numErr / ( REAL )v_img.size() ) * 100.0 << "%." << endl;

	return;
}

void MLP::normalize( Vector& vector ) {
	for( S32 i = 0 ; i < ( S32 )vector.v_val.size() ; i++ ) {
		vector.v_val[i] = vector.v_val[i] / 127.5 - 1.0;
	}
	return;
}

void MLP::activateHidden( Vector& vector ) {
	for( S32 i = 0 ; i < ( S32 )vector.v_val.size() ; i++ ) {
		vector.v_val[i] = 1.7159 * tanh( 0.6666 * vector.v_val[i] );
	}
	return;
}

void MLP::activateOutput( Vector& vector ) {/* softmax */
	REAL denom = 0.0;
	for( S32 i = 0 ; i < ( S32 )vector.v_val.size() ; i++ ) {
		denom += exp( vector.v_val[i] );
	}
	assert( denom > 0.0 );
	for( S32 i = 0 ; i < ( S32 )vector.v_val.size() ; i++ ) {
		vector.v_val[i] = exp( vector.v_val[i] ) / denom;
	}
	return;
}

void MLP::diffActivationHidden( Vector& vector ) {
	for( S32 i = 0 ; i < ( S32 )vector.v_val.size() ; i++ ) {
		REAL sech = 2.0 / ( exp( 0.6666 * vector.v_val[i] ) + exp( -0.6666 * vector.v_val[i] ) );
		vector.v_val[i] = 1.7159 * 0.6666 * sech * sech;
	}
	return;
}

