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
#include <stdio.h> //added Nitin
#include <sys/types.h>
#include <sys/stat.h>

#include <iostream>
#include <string>

#include <cstdlib> // added Nitin

#include "DataType.h"
#include "FileIO.h"

using namespace std;

const string FileIO::TRAINING_LABEL_NAME = "train-labels-idx1-ubyte";
const string FileIO::TRAINING_IMG_NAME = "train-images-idx3-ubyte";

const string FileIO::TEST_LABEL_NAME = "t10k-labels-idx1-ubyte";
const string FileIO::TEST_IMG_NAME = "t10k-images-idx3-ubyte";

void FileIO::readLabelFile( const BOOL doTraining/* true if training, false if testing */, const string dirPath, vector<U8>& v_label ) {
	string filePath;
	U8* p_data;
	size_t readSize;

	U32* p_uintData;
	U8* p_ucharData;

	U32 numImgs;

	if( doTraining == true ) {
		filePath = dirPath + FileIO::TRAINING_LABEL_NAME;
	}
	else {
		filePath = dirPath + FileIO::TEST_LABEL_NAME;
	}
	readSize = FileIO::readFile( filePath, &p_data );

	if( readSize < sizeof( U32 ) * 2 ) {
		cout << "invalid file size." << endl;
		exit( -1 );
	}

	p_uintData = ( U32* )p_data;

	if( FileIO::bigToLittleEndian( p_uintData[0] ) != FileIO::LABEL_MAGIC_NUMBER ) {
		cout << "invalid magic number." << endl;
		exit( -1 );
	}

	numImgs = FileIO::bigToLittleEndian( p_uintData[1] );

	p_uintData += 2;

	if( readSize != ( sizeof( U32 ) * 2 + numImgs * sizeof( U8 ) ) ) {
		cout << "invalid file size." << endl;
		exit( -1 );
	}

	p_ucharData = ( U8* )p_uintData;

	v_label.assign( p_ucharData, p_ucharData + numImgs );

	delete[] p_data;

	return;
}

void FileIO::readImgFile( const BOOL doTraining/* true if training, false if testing */, const string dirPath, vector<Img>& v_img ) {
	string filePath;
	U8* p_data;
	size_t readSize;

	U32* p_uintData;
	U8* p_ucharData;

	U32 numImgs;
	U32 numRows;
	U32 numCols;

	if( doTraining == true ) {
		filePath = dirPath + FileIO::TRAINING_IMG_NAME;
	}
	else {
		filePath = dirPath + FileIO::TEST_IMG_NAME;
	}
	readSize = FileIO::readFile( filePath, &p_data );

	if( readSize < sizeof( U32 ) * 4 ) {
		cout << "invalid file size." << endl;
		exit( -1 );
	}

	p_uintData = ( U32* )p_data;

	if( FileIO::bigToLittleEndian( p_uintData[0] ) != FileIO::IMG_MAGIC_NUMBER ) {
		cout << "invalid magic number." << endl;
		exit( -1 );
	}

	numImgs = FileIO::bigToLittleEndian( p_uintData[1] );

	numRows = FileIO::bigToLittleEndian( p_uintData[2] );

	numCols = FileIO::bigToLittleEndian( p_uintData[3] );

	p_uintData += 4;

	if( readSize != ( sizeof( U32 ) * 4 + numImgs * numRows * numCols * sizeof( U8 ) ) ) {
		cout << "invalid file size." << endl;
		exit( -1 );
	}

	p_ucharData = ( U8* )p_uintData;

	v_img.resize( numImgs );
	for( U32 i = 0 ; i < numImgs ; i++ ) {
		const U8* p_imgData = p_ucharData + ( numRows * numCols * sizeof( U8 ) ) * i;
		Img& img = v_img[i];
		img.init( numRows * numCols * sizeof( U8 ), p_imgData );
	}

	delete[] p_data;

	return;
}

size_t FileIO::readFile( const string fileName, U8** pp_data ) {
	struct stat fileStat;
	FILE* p_file;
	size_t readSize;
	S32 ret;

	ret = stat( fileName.c_str(), &fileStat );
	if( ret != 0 ) {
		cout << "stat failure." << endl;
	}

	*pp_data = new U8[fileStat.st_size];

	p_file = fopen( fileName.c_str(), "r" );
	if( p_file == NULL ) {
		cout << "fopen failure." << endl;
	}

	readSize = fread( *pp_data, sizeof( U8 ), fileStat.st_size, p_file );
	if( readSize != fileStat.st_size ) {
		cout << "fread failure." << endl;
		exit( -1 );
	}

	ret = fclose( p_file );
	if( ret != 0 ) {
		cout << "fclose failure." << endl;
		exit( -1 );
	}

	return readSize;
}

U32 FileIO::bigToLittleEndian( const U32 big ) {
	U32 ret;
	const U8* p_ubyte = ( const U8* )&big;
	ret = ( p_ubyte[3] << 0 ) | ( p_ubyte[2] << 8 ) | ( p_ubyte[1] << 16 ) | ( p_ubyte[0] << 24 );
	return ret;
}

