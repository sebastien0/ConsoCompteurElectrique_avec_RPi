/** **********************************************************************
* \file Fonctions_Extract.c
* \author Sébastien Lemoine
* \date Août 2013
* \brief Fonctions permettant d'extraire une trame complète
*   dénommée \p frame de la trame reçue du compteur
**************************************************************************/

#include "Fonctions_Extract.h"

static char *_charSearch(int intToSearch, char *begin, int size);

/** **************************
* \fn static char *_charSearch(int intToSearch, char *begin, int size)
* \brief recherche un entier depuis \p *begin sur \p size caractères
* \param [in] intToSearch    Entier à rechercher
* \param [in] *begin    Pointeur de la première cellule où démarer la recherche
* \param [in] size  Entier renseignant le nombre de caractères sur
*   lesquels effectuer la recherche
* \return Le pointeur contenant l'entier recherché
******************************/
static char *_charSearch(int intToSearch, char *begin, int size){
    int i;
    for(i = 0; i < size; i++) {
        if (begin[i] == intToSearch)
            return &(begin[i]);
    }
    return NULL;
}

/** **************************
* \fn void extract(char *tabRecu, char *frame)
* \brief Fonction permettant de rechercher et copier \p tab_recu
*   compris entre \p STX et \p ETX dans \p frame
* \param [in] *tabRecu    Pointeur du tableau source
* \param [in] *frame    Pointeur de la trame générée
******************************/
void extract(char *tabRecu, char *frame){
    static char *endFrame = NULL;

	endFrame = _charSearch(ETX, tabRecu, 180);	// Recherche de ETX

	int size = endFrame - tabRecu;	// Taille d'une seule trame

	// Copie de la trame sans ses balises
    memcpy(frame, &tabRecu[2], endFrame - &tabRecu[2]);
	frame[size] = '\0';
//	printf("frame [extract] = %s\n",frame);
}
