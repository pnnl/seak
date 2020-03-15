# -*-Mode: makefile;-*-

#*BeginCopyright*************************************************************
#
# $HeadURL$
# $Id$
#
#----------------------------------------------------------------------------
# SEAK: Suite for Embedded Applications and Kernels (hpc.pnnl.gov/SEAK/)
#----------------------------------------------------------------------------
#
# Copyright ((c)) 2016, Battelle Memorial Institute
#
# 1. Battelle Memorial Institute (hereinafter Battelle) hereby grants
#    permission to any person or entity lawfully obtaining a copy of
#    this software and associated documentation files (hereinafter "the
#    Software") to redistribute and use the Software in source and
#    binary forms, with or without modification.  Such person or entity
#    may use, copy, modify, merge, publish, distribute, sublicense,
#    and/or sell copies of the Software, and may permit others to do so,
#    subject to the following conditions:
#    
#    * Redistributions of source code must retain the above copyright
#      notice, this list of conditions and the following disclaimers.
#
#    * Redistributions in binary form must reproduce the above copyright
#      notice, this list of conditions and the following disclaimer in
#      the documentation and/or other materials provided with the
#      distribution.
#
#    * Other than as used herein, neither the name Battelle Memorial
#      Institute or Battelle may be used in any form whatsoever without
#      the express written consent of Battelle.
#
#    * Redistributions of the software in any form, and publications
#      based on work performed using the software should include the
#      following citation as a reference:
#            
#        Nitin A. Gawande, Seunghwa Kang, Joseph B. Manzano, Nathan
#        R. Tallent, Darren J. Kerbyson, Adolfy Hoisie.  "SEAK
#        Specification." Pacific Northwest National Laboratory. May,
#        2016, http://hpc.pnnl.gov/SEAK/
#
# 2. THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
#    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
#    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
#    FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL BATTELLE
#    OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
#    SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
#    LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF
#    USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
#    ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
#    OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
#    OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
#    SUCH DAMAGE.
#
#*EndCopyright***************************************************************

INPUT_SIZE ?= 

CC ?= gcc
CXX ?= g++
#CFLAGS ?= -std=gnu99 -pedantic -Wall -O3 -fopenmp -DINPUT_SIZE=INPUT_SIZE_$(INPUT_SIZE) -fopenmp -D_USE_OPENMP
CXXFLAGS ?= -std=gnu99 -pedantic -Wall -O3 -fopenmp -DINPUT_SIZE=INPUT_SIZE_$(INPUT_SIZE) -fopenmp -D_USE_OPENMP

#****************************************************************************

exe1 = augreal-mlp

libdir = ../../../lib
mlp_libdir = 

libs   = $(libdir)/libtiming.a

$(exe1)_SRCS = src/Test.cpp src/MLP.cpp src/FileIO.cpp
#$(exe1)_CFLAGS = -I$(libdir) -I$(mlp_libdir) 
$(exe1)_CXXFLAGS = -I$(libdir) -I$(mlp_libdir) 
$(exe1)_LDFLAGS =
$(exe1)_LIBS = $(libs)
$(exe1)_LDADD = -lm -lrt

#****************************************************************************

MK_SUBDIRS =

MK_PROGRAMS_CXX = $(exe1)

include ../../../../Makefile-template.mk

#****************************************************************************

indir = ../inout

all.local : $(libs)

clean.local:
	$(RM) $(exe1) *.bin
	$(MAKE) -C $(libdir) clean
#	$(MAKE) -C $(mlp_libdir) clean

check.local :
	./$(exe1) $(indir)

$(libs) :
	$(MAKE) -C $(libdir)
#	$(MAKE) -C $(mlp_libdir) INPUT_SIZE=$(INPUT_SIZE)

