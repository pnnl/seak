# -*-Mode: makefile;-*-

#*BeginCopyright*************************************************************
#
# $HeadURL: https://svn.pnl.gov/svn/hpcgroup/projects/DARPA/SEAK/Makefile $
# $Id$
#
#***************************************************************EndCopyright*

MK_SUBDIRS =

include Makefile-template.mk

#****************************************************************************

all.local :
	@echo "Please see the reference implementations for individual"
	@echo "constraininig problems. (A unified build does not make sense.)"

.PHONY : help
