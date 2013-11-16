/** **********************************************************************
* \file Fonctions_Extract.h
* \author Sébastien Lemoine
* \date Août 2013
* \brief Déclaration des fonctions permettant d'extraire une trame complète
*   dénommée frame de la trame reçue du compteur
* \headerfile ""
**************************************************************************/

#ifndef Fonctions_Extract
#define Fonctions_Extract

	#include <stdio.h>
	#include <stdlib.h>
	// Fonction memcpy
	#include <string.h>

	/// Start of TeXt
	#define STX		2
	/// End of TeXt
	#define ETX		3

	extern void extract(char *tabRecu, char *frame);

#endif
