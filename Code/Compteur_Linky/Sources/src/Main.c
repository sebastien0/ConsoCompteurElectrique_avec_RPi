/** **************************
* \file Main.c
* \author Sébastien Lemoine
* \date Octobre 2013
* \brief Appelle acquerir() pour réaliser le traitement
******************************/

/** **************************
* \attention Utiliser minicom avant de démarrer le programme. \n
* <tt> minicom -b 1200 -o -D /dev/ttyAMA0 </tt>
*
*@mainpage Projet d'acquisition et d'enregistrement des informations issues d'un compteur électrique \n
* Apperçu du projet :
* \image html Illustration.jpg
******************************/

#include <stdio.h>
#include "Acquerir.h"

/** ***************************
* \fn int main()
* \return 0
******************************/
int main(){
	short finir = 0;

	printf("\n**************************************************\n");
    printf("* Console de suivit pour la reception, le decodage et ");
    printf("l'enregitrement des donnees recues du compteur\n");
    printf("* Sebastien Lemoine - Octobre 2013\n");
    printf("**************************************************\n");


	// ***** Fonctionner tant que l'utilisateur n'a pas demandé l'arrêt ****************
	#ifdef DEBUG	
	finir = acquerir();

	#else
	while (finir == 0){
		finir = acquerir();
	}
	#endif

    // ************* Fin du programme ***********
    printf("Info \t Fin du programme \n\n");

	exit(EXIT_SUCCESS);
}
