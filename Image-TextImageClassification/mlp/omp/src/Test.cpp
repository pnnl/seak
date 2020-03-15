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

#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/time.h>

#include <iostream>
#include <string>

#include <cstdlib> // added Nitin

#include "DataType.h"
#include "FileIO.h"
#include "MLP.h"

using namespace std;

#if INPUT_SIZE == INPUT_SIZE_SMALL
static const S32 NUM_TRAINING_ROUNDS = 10;
#elif INPUT_SIZE == INPUT_SIZE_MEDIUM
static const S32 NUM_TRAINING_ROUNDS = 1000;
#elif INPUT_SIZE == INPUT_SIZE_LARGE
static const S32 NUM_TRAINING_ROUNDS = 10000;
#else
   #error "Unhandled value for INPUT_SIZE"
#endif

static const S32 MINI_BATCH_SIZE = 100;
static REAL ALPHA = 0.0001;/* learning rate */
static const S32 NUM_HIDDEN_LAYERS = 5;
static const S32 A_NUM_NODES_IN_HIDDEN_LAYER[NUM_HIDDEN_LAYERS] = { 2500, 2000, 1500, 1000, 500 };

S32 main( S32 argc, S8* ap_args[] ) {
	vector<S32> v_layerWidth;

	vector<U8> v_trainingLabel;
	vector<Img> v_trainingImg;

	vector<U8> v_testLabel;
	vector<Img> v_testImg;

	string dirPath;

	MLP mlp;

	struct timeval tv0;
	struct timeval tv1;
	struct timeval tv2;
	struct timeval tv3;
	struct timeval tv4;
	struct timeval tv5;
	struct timeval tv6;

	if( argc != 2 ) {
		cout << "usage: " << ap_args[0] << " input_path" << endl;
		exit( -1 );
	}

	dirPath.assign( ap_args[1] );
	dirPath += "/";

	gettimeofday( &tv0, NULL );

	/* read training labels & images */

	cout << "reading training data." << endl;

	FileIO::readLabelFile( true/* doTraining */, dirPath, v_trainingLabel );
	FileIO::readImgFile( true/* doTraining */, dirPath, v_trainingImg );
	if( v_trainingLabel.size() != v_trainingImg.size() ) {
		cout << "# labels != # images." << endl;
		exit( -1 );
	}

	gettimeofday( &tv1, NULL );

	cout << "file I/O (training) took " << ( ( tv1.tv_sec - tv0.tv_sec ) * 1.0e6 + ( tv1.tv_usec - tv0.tv_usec ) ) / 1.0e6 << " seconds." << endl;

	/* read test labels & images */

	cout << "reading test data." << endl;

	FileIO::readLabelFile( false/* doTraining */, dirPath, v_testLabel );
	FileIO::readImgFile( false/* doTraining */, dirPath, v_testImg );
	if( v_testLabel.size() != v_testImg.size() ) {
		cout << "# labels != # images." << endl;
		exit( -1 );
	}

	gettimeofday( &tv2, NULL );

	cout << "file I/O (test) took " << ( ( tv2.tv_sec - tv1.tv_sec ) * 1.0e6 + ( tv2.tv_usec - tv1.tv_usec ) ) / 1.0e6 << " seconds." << endl;

	/* initialize the neural network */

	cout << "initializing the network." << endl;

	v_layerWidth.resize( 1 + NUM_HIDDEN_LAYERS + 1 );
	v_layerWidth[0] = 28 * 28;/* image size = 28 * 28 */
	for( S32 i = 1 ; i < 1 + NUM_HIDDEN_LAYERS ; i++ ) {
		v_layerWidth[i] = A_NUM_NODES_IN_HIDDEN_LAYER[i - 1];
	}
	v_layerWidth.back() = 10;/* 0 ~ 9 */

	mlp.initNetwork( v_layerWidth );

	gettimeofday( &tv3, NULL );

	cout << "initialization took " << ( ( tv3.tv_sec - tv2.tv_sec ) * 1.0e6 + ( tv3.tv_usec - tv2.tv_usec ) ) / 1.0e6 << " seconds." << endl;

	/* train the neural network */

	cout << "training the network." << endl;

	mlp.trainNetwork( NUM_TRAINING_ROUNDS, MINI_BATCH_SIZE, ALPHA, v_trainingLabel, v_trainingImg );

	gettimeofday( &tv4, NULL );

	cout << "training took " << ( ( tv4.tv_sec - tv3.tv_sec ) * 1.0e6 + ( tv4.tv_usec - tv3.tv_usec ) ) / 1.0e6 << " seconds." << endl;

	/* test the neural netowrk */

	cout << "testing the network." << endl;

	mlp.testNetwork( v_testLabel, v_testImg );

	gettimeofday( &tv5, NULL );

	cout << "testing took " << ( ( tv5.tv_sec - tv4.tv_sec ) * 1.0e6 + ( tv5.tv_usec - tv4.tv_usec ) ) / 1.0e6 << " seconds." << endl;

	/* clean-up the neural network */

	mlp.cleanupNetwork();

	gettimeofday( &tv6, NULL );

	cout << "clean-up took " << ( ( tv6.tv_sec - tv5.tv_sec ) * 1.0e6 + ( tv6.tv_usec - tv5.tv_usec ) ) / 1.0e6 << " seconds." << endl;

	return 0;
}

