/** **********************************************************************
* \file Horodater.h
* \author Sébastien Lemoine
* \date Mai 2013
* \brief Permet de récupérer la date et/ou l'heure du système
* \headerfile ""
**************************************************************************/

#ifndef Horodater
#define Horodater

    #include <time.h>
    #include <stdio.h>

    /// Retourner la date et l'heure
    #define DATEHEURE   0
    /// Retourner seulement la date
    #define DATE        1
    /// Retourner seulement l'heure
    #define HEURE       2

    extern void Horodate(char *Temps, short choix);

#endif
