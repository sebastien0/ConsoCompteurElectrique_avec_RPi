/** **********************************************************************
* \file LireEcrire.c
* \author Sébastien Lemoine
* \date Mai 2013
* \brief Fonctions permettant la gestion de fichiers
**************************************************************************/

#include "LireEcrire.h"
#include "Horodater.h"

/** **************************
* \fn short fichier_init(FILE* fichier, char *nom_fichier, char* Adeco, short config_base)
* \brief Configurer la création du fichier \p nom_fichier dans le répertoire du projet \n
*   Formate le fichier en écrivant la date, le numéro du compteur et les têtes de colonnes
*
* \param [in] fichier    Pointeur qui retourne vers le fichier généré
* \param [out] nom_fichier    Pointeur qui retourne vers un tableau de \p char contenant le nom de fichier généré
* \param [in] Adeco  Pointeurs vers un tableau de \p char contenant le numéro du compteur
* \param [in] config_base    Variable permettant de formater le tableau de sortie selon Base ou Heures Creuses - Heures Pleines \n
*   \li \p 1 correspond à une configuration Base \n
*   \li \p 0 correspond à une configuration Heures Creuses - Heures Pleines
*
* \return Une variable d'erreur due à la création du fichier \n
*   \li \p 0 Pas d'erreur à la création \n
*   \li \p 1 Erreur à la création
******************************/
short fichier_init(FILE* fichier, char *nom_fichier, char* Adeco, short config_base){
    short erreur = 1;
    char DateHeure[20] = {"9"};
    char temp[80] = "-";

    /** *****
    * \todo N'appeler qu'une seule fois Horodate() et utiliser memcpy tel que:
    * \code
    *   Horodate(DateHeure,DATEHEURE);
    *   memcpy(temp,DateHeure,8);
    *   temp[8] = '\0';
    *   sprintf(nom_fichier, "Releve_%s.txt",temp);
    *   sprintf(temp,"Creation le %s \r\nCompteur n°%s\r\n\r\n", DateHeure, Adeco);
    * \endcode
    ********/
    // Obtenir la date et l'heure puis générer le nom du fichier et l'initialiser
    Horodate(DateHeure,DATE);
    sprintf(nom_fichier, "Releve_%s.txt",DateHeure);

    //Obtenir la date et l'heure
    Horodate(DateHeure,DATEHEURE);

    // Ouverture et écriture
	// \r\n retour à la ligne compréhensible sous Windows
    sprintf(temp,"Creation le %s \r\nCompteur n°%s\r\n\r\n", DateHeure, Adeco);

    erreur = fichier_creer(fichier, nom_fichier,temp);

    if (erreur == 0){
        if (config_base == 1)
            sprintf(temp,"Heure \t\t Papp \t Base \t\t Invalide\r\n");
        else
            sprintf(temp,"Heure \t\t Papp \t H creuses \t\t H pleines \t\t Invalide \r\n");

        fichier = fopen(nom_fichier, "a");
        fprintf(fichier,temp);
        fclose(fichier); // Fermer le fichier
    }
    return erreur;
}

/** **************************
* \fn short fichier_creer(FILE* fichier, char *nom_fichier, char *donnees)
* \brief Créer le fichier \p nom_fichier dans le répertoire d'éxécution
*
* \param [in] fichier    Pointeur qui retourne vers le fichier généré
* \param [in] nom_fichier    Pointeur qui retourne vers un tableau contenant le nom de fichier généré
*
* \param [in] donnees  Pointeurs vers un tableau contenant les premières informations a écrire dans le fichier
* \return Une variable d'erreur retournée par la création du fichier \n
*   \li \p 0 Pas d'erreur à la création \n
*   \li \p 1 Erreur à la création
******************************/
short fichier_creer(FILE* fichier, char *nom_fichier, char *donnees){
    short etat =1;

    fichier = fopen(nom_fichier, "w");

    if (fichier != NULL){
        fprintf(fichier,donnees);
        fclose(fichier); // Fermer le fichier
        etat = 0;
    }
    return etat;
}
