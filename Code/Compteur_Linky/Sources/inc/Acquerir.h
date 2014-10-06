/** **********************************************************************
* \file Acquerir.h
* \author Sébastien Lemoine
* \date Octobre 2013
* \brief Programme réalisant l'acquisiton sur une journée
* \headerfile ""
**************************************************************************/

#ifndef Acquerir
#define Acquerir
	
	/** ***
	* Définir \p DEBUG ajoute les fonctionnalitées suivantes : \n
	*   \li Modifie l'heure d'arrêt \n
	*   \li Affiche l'heure d'arrêt en console \n
	*   \li Affiche le nombre de trames traitées \n
	*   \li Signale en console lorsque le fichier \p nom_fichier
	*   est mis à jour (toutes les minutes) \n
	*   \li Affiche le nombre de trames traitées losrque que le
	*   fichier est fermé à \p heureArret
	************************/
	#define DEBUG	// Debug

	#include <stdio.h>

	#include "Decoder_Trames.h"
	#include "Horodater.h"
	#include "LireEcrire.h"
	#include "Fonctions_UART.h"
	#include "Fonctions_Extract.h"

	/// Vrai
	#define	VRAI	1
	/// Faux
	#define	FAUX	0

	extern short acquerir(void);
	extern void gestionInvalide (char *temp, int config_base, int invalide,
	char *DateHeure, char *Papp, char *Base, char *Hchc, char *Hchp);

#endif
