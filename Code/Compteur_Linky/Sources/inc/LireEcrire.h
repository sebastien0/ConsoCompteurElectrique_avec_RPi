/** **********************************************************************
* \file LireEcrire.h
* \author Sébastien Lemoine
* \date Mai 2013
* \brief Fonctions permettant la création de fichier
* \headerfile ""
**************************************************************************/

#ifndef LireEcrire
#define LireEcrire

    #include <stdio.h>

    extern short fichier_init(FILE* fichier, char *nom_fichier, char* Adeco, short config_base);
    extern short fichier_creer(FILE* fichier, char *nom_fichier, char *donnees);

#endif
