/** **********************************************************************
* \file Sortir.h
* \author Sébastien Lemoine
* \date Novembre 2013
* \brief Gestion de lecture du buffer de saisie clavier
* \headerfile ""
**************************************************************************/

#ifndef Sortir
#define Sortir

	#include <stdio.h>
	#include <stdlib.h>
	#include <sys/time.h>
	#include <sys/types.h>
	#include <unistd.h>

	extern short sortieDemandee(int timeoutSec, int timeoutUsec);

#endif
