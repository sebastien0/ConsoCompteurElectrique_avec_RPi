/** **********************************************************************
* \file Horodater.c
* \author Sébastien Lemoine
* \date Mai 2013
* \brief Permet de récupérer la date et/ou l'heure du système
**************************************************************************/

#include "Horodater.h"

/** **************************
* \fn void Horodate(char *Temps, short choix)
* \brief Récupérer et retourner la date et/ou l'heure du système. \n
* \param[out] *Temps    Pointeur vers un tableau de \p char[18] où est écrit la date et/ou l'heure
*   au format : \n
*   \li \b aa-mm-jj si \p DATE passé en paramètre \n
*   \li <b> aa-mm-jj hh:mm:ss </b> si \p DATEHEURE passé en paramètre \n
*   \li \b hh:mm:ss si \p HEURE passé en paramètre \n
* \param[in] choix  Equivalence pour n'extraire qu'une partie ou l'intégralité
*   de la date et l'heure. Le équivalence suivantes permettent de choisir
*   l'information retournée: \n
*   \li \p DATE \n
*   \li \p DATEHEURE \n
*   \li \p HEURE
******************************/
void Horodate(char *Temps, short choix){
    time_t current_time;
    struct tm *localtime (const time_t *timep);
    struct tm *DateHeure;

    time(&current_time);   // Timespamp: nombre de secondes depuis le 01/01/1970 0h0:0
    DateHeure = localtime(&current_time);   // Conversion des secondes selon la structure localtime
    // Affichage sur 2 chiffres
    if (choix == DATE)
        sprintf(Temps,"%d-%02d-%02d", 1900+(DateHeure->tm_year), DateHeure->tm_mon+1,DateHeure->tm_mday);
    else if (choix == HEURE)
        sprintf(Temps,"%02d:%02d:%02d", DateHeure->tm_hour, DateHeure->tm_min, DateHeure->tm_sec);
    else
        sprintf(Temps,"%d/%02d/%02d %02d:%02d:%02d\n", 1900+(DateHeure->tm_year), DateHeure->tm_mon+1,
                DateHeure->tm_mday, DateHeure->tm_hour, DateHeure->tm_min, DateHeure->tm_sec);
}
