/** **************************
* \file Sortir.c
* \author Sébastien Lemoine
* \date Novembre 2013
* \brief Gestion de lecture du buffer de saisie clavier
******************************/

#include "Sortir.h"

/** ***************************
* \fn short sortieDemandee(int timeoutSec, int timeoutUsec)
* \brief Lit le buffer de saisie clavier avec un timout. \n
*	Retourne un entier de statu
* * \author Inspiré du \c man de \c select()
*
* \param [in] timeoutSec   Entier du timeout en seconde
* \param [in] timeoutUsec   Entier du timeout en micro seconde
* \return Retourne un entier selon :
*	\li	\c -1	si erreur. Code d'erreur contenu dans errno
*	\li	\c 0	si pas de caractère ou mauvais caractère saisi
*	\li	\c 1	si q ou Q saisi
******************************/
short sortieDemandee(int timeoutSec, int timeoutUsec)
{
	fd_set rfds;
	struct timeval tv;
	char saisie[5]={0};
	int retval;

	// Watch stdin (fd 0) to see when it has input
	FD_ZERO(&rfds);
	FD_SET(0, &rfds);

	// Wait up to timeoutSec seconds and timeoutUsec
	tv.tv_sec = timeoutSec;
	tv.tv_usec = timeoutUsec;

	retval = select(1, &rfds, NULL, NULL, &tv);
	// Don't rely on the value of tv now!

	if (retval == -1) {
		perror("select()");	// Erreur contenue dans errno
		return -1;
	}
	else if (retval){
//		printf("Data is available now.\n");
		/* FD_ISSET(0, &rfds) will be true. */
		read(0,saisie,5);	// Lire le buffer
		if (saisie[0] == 'q' || saisie[0] == 'Q'){
			printf("Info \t Demande d'arret prise en compte\n");
			return 1;
		}
		else {
			// reconfigurer la lecture avec timeout pour la prochaine itération
			printf("Attention \t Pour quitter, saisir q puis faire entree\n");
			tv.tv_sec = timeoutSec;
			tv.tv_usec = timeoutUsec;
			FD_ZERO(&rfds);
			FD_SET(0, &rfds);
			return 0;
		}
	}
	else {
//		printf("No data within %d seconds.\n", timeoutSec);
		// reconfigurer la lecture avec timeout pour la prochaine itération
		tv.tv_sec = timeoutSec;
		tv.tv_usec = timeoutUsec;
		FD_ZERO(&rfds);
		FD_SET(0, &rfds);
		return 0;
	}
//	return -1;
}
