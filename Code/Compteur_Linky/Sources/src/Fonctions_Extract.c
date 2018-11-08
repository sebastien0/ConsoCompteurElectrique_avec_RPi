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
* \par Historique
*	Circonscription de l'erreur causant le segfault
******************************/
void extract(char *tabRecu, char *frame){
    static char *endFrame = NULL;

	endFrame = _charSearch(ETX, tabRecu, 180);	// Recherche de ETX

	int size = endFrame - tabRecu;	// Taille d'une seule trame

	// Copie de la trame sans ses balises
	// 152  est la taille du malloc de 'frame' + 3 caracteres
	if (endFrame - &tabRecu[2] <= 0)
    {
        printf("Error \t ETX before STX (segfault error avoid)\n");
        frame[size] = '\0';
    }
    else if((size <= (152+3)) && (endFrame != NULL))
	{
	    //printf("\nDebug \t tabRecu in extract() :|%s| \n",frame);
        //printf("Debug \t longeur endFrame - &tabRecu[2]: %i\n", endFrame - &tabRecu[2]);
        memcpy(frame, &tabRecu[2], endFrame - &tabRecu[2]); /// \BUG améliorer la gestion de endFrame - &tabRecu[2] <= 0; i.e. lorsque ETX est avant STX
	    frame[size] = '\0';
	    //printf("Debug \t frame in extract() :|%s| \n",frame);
	}
	else
	{
		tabRecu[181]='\0';	// Au cas où, pour eviter BUG
		printf("Error \t trame recue incorrecte : %s\n",tabRecu);
	}
}
