/** **********************************************************************
* \file Decoder_Trames.c
* \author Sébastien Lemoine
* \date Mai 2013
* \brief Fonctions de décodage des trames et de vérification du Checksum
**************************************************************************/

#include "Decoder_Trames.h"

/** **********************************************************************
* \fn void Decode_Trame_Brute (char *tab_recu_brut,char *Motdetat, char *Adeco,char *Optarif,
*    char *Isousc, char *Base, char *Hchc, char *Hchp,char *Ptec, char *Iinst, char *Imax,
*    char *Papp, char *Hhphc, char *Checksum, short *Statu_chcksm)
* \brief Décode et interprète l'étiquette \n
*   Retourne les valeurs des étiquettes correspondantes, le Cheksum
*    et la validité de la donnée
* \param [in] tab_recu_brut  Pointeur vers un tableau contenant la trame brute reçue du compteur
* \param [out] Motdetat   Pointeur vers un tableau contenant la valeur de Motdetat
* \param [out] Adeco   Pointeur vers un tableau contenant la valeur de Adeco
* \param [out] Optarif   Pointeur vers un tableau contenant la valeur de Optarif
* \param [out] Isousc   Pointeur vers un tableau contenant la valeur de Isousc
* \param [out] Base   Pointeur vers un tableau contenant la valeur de Base
* \param [out] Hchc   Pointeur vers un tableau contenant la valeur de Hchc
* \param [out] Hchp   Pointeur vers un tableau contenant la valeur de Hchp
* \param [out] Ptec   Pointeur vers un tableau contenant la valeur de Ptec
* \param [out] Iinst  Pointeur vers un tableau contenant la valeur de Iinst
* \param [out] Imax   Pointeur vers un tableau contenant la valeur de Imax
* \param [out] Papp   Pointeur vers un tableau contenant la valeur de Papp
* \param [out] Hhphc  Pointeur vers un tableau contenant la valeur de Hhphc
* \param [out] Checksum   Pointeur vers un tableau contenant la valeur de Checksum
* \param [out] Statu_chcksm   Pointeur vers un tableau contenant la valeur de Statu_chcksm
*************************************************************************/
void Decode_Trame_Brute (char *tab_recu_brut,char *Motdetat, char *Adeco,char *Optarif,char *Isousc,
                         char *Base, char *Hchc, char *Hchp,char *Ptec, char *Iinst, char *Imax,
                         char *Papp, char *Hhphc, char *Checksum, short *Statu_chcksm){
    int indice =0;
    int indice_deb=0;

    // Parcour du tab_recu_brut jusqu'à la fin
    while(tab_recu_brut[indice] != '\0'){
        // Identification de l'étiquette puis sauvegarde de la valeur
        indice_deb = indice;
        // MOTDETAT
        if (tab_recu_brut[indice] == 'M' && tab_recu_brut[indice+1] == 'O'){
            indice = Extraire (tab_recu_brut, indice, 9, Motdetat);
            Checksum[IND_MOTDETAT] = tab_recu_brut[indice];
            Statu_chcksm[IND_MOTDETAT] = Statu_Checksum(tab_recu_brut,indice_deb, indice);
        }
        // ADECO
        else if (tab_recu_brut[indice] == 'A' && tab_recu_brut[indice+1] == 'D'){
            indice = Extraire (tab_recu_brut, indice, 5, Adeco);
            Checksum[IND_ADECO] = tab_recu_brut[indice];
            Statu_chcksm[IND_ADECO] = Statu_Checksum(tab_recu_brut,indice_deb, indice);
        }
        // OPTARIF
        else if (tab_recu_brut[indice] == 'O' && tab_recu_brut[indice+1] == 'P'){
            indice = Extraire (tab_recu_brut, indice, 8, Optarif);
            Checksum[IND_OPTARIF] = tab_recu_brut[indice];
            Statu_chcksm[IND_OPTARIF] = Statu_Checksum(tab_recu_brut,indice_deb, indice);
        }
        // BASE
        else if (tab_recu_brut[indice] == 'B' &&
                 tab_recu_brut[indice+1] == 'A'){
//&&             tab_recu_brut[indice+6] == '0'){
	    /** ****
	    * \bug	Suppression de la condition 
	    *	tab_recu_brut[indice+6] == '0'
	    *
	    ***********/
            indice = Extraire (tab_recu_brut, indice, 5, Base);
            Checksum[IND_BASE] = tab_recu_brut[indice];
            Statu_chcksm[IND_BASE] = Statu_Checksum(tab_recu_brut,indice_deb, indice);
        }

        else if (tab_recu_brut[indice] == 'I'){
            switch (tab_recu_brut[indice+1]){
                // ISOUSC
                case 'S':
                    indice = Extraire (tab_recu_brut, indice, 7, Isousc);
                    Checksum[IND_ISOUSC] = tab_recu_brut[indice];
                    Statu_chcksm[IND_ISOUSC] = Statu_Checksum(tab_recu_brut,indice_deb, indice);
                    break;
                // IINST
                case 'I':
                    indice = Extraire (tab_recu_brut, indice, 6, Iinst);
                    Checksum[IND_IINST] = tab_recu_brut[indice];
                    Statu_chcksm[IND_IINST] = Statu_Checksum(tab_recu_brut,indice_deb, indice);
                    break;
                // IMAX
                case 'M':
                    indice = Extraire (tab_recu_brut, indice, 5, Imax);
                    Checksum[IND_IMAX] = tab_recu_brut[indice];
                    Statu_chcksm[IND_IMAX] = Statu_Checksum(tab_recu_brut,indice_deb, indice);
                    break;
                default:
                    indice++;
            }
        }
        else if (tab_recu_brut[indice] == 'H'){
             switch (tab_recu_brut[indice+3]){
                 // HCHC
                 case 'C':
                    indice = Extraire (tab_recu_brut, indice, 5, Hchc);
                    Checksum[IND_HCHC] = tab_recu_brut[indice];
                    Statu_chcksm[IND_HCHC] = Statu_Checksum(tab_recu_brut,indice_deb, indice);
                    break;
                 // HCHP
                 case 'P':
                    indice = Extraire (tab_recu_brut, indice, 5, Hchp);
                    Checksum[IND_HCHP] = tab_recu_brut[indice];
                    Statu_chcksm[IND_HCHP] = Statu_Checksum(tab_recu_brut,indice_deb, indice);
                    break;
                // HHPHC
                case 'H':
                    indice = Extraire (tab_recu_brut, indice, 6, Hhphc);
                    Checksum[IND_HHPHC] = tab_recu_brut[indice];
                    Statu_chcksm[IND_HHPHC] = Statu_Checksum(tab_recu_brut,indice_deb, indice);
                    break;
                default:
                    indice++;
             }
        }
        else if (tab_recu_brut[indice] == 'P'){
            switch (tab_recu_brut[indice+1]){
                // PTEC
                case 'T':
                    indice = Extraire (tab_recu_brut, indice, 5, Ptec);
                    Checksum[IND_PTEC] = tab_recu_brut[indice];
                    Statu_chcksm[IND_PTEC] = Statu_Checksum(tab_recu_brut,indice_deb, indice);
                    break;
                // PAPP
                case 'A':
                    indice = Extraire (tab_recu_brut, indice, 5, Papp);
                    Checksum[IND_PAPP] = tab_recu_brut[indice];
                    Statu_chcksm[IND_PAPP] = Statu_Checksum(tab_recu_brut,indice_deb, indice);
                    break;
                default:
                    indice++;
            }
        }
        else{
            indice++;
        }
    }
}

/** **********************************************************************
* \fn int Extraire (char *tab_recu_brut,int indice, int offset, char *valeur)
* \brief Extraire de la trame brute la valeur correspondante à l'etiquette
* \param [in] tab_recu_brut  Pointeur vers un tableau contenant la trame brute reçue du compteur
* \param [in] indice Indice de la première cellule où commencer l'extraction
* \param [in] offset Longueur de l'étiquette
* \param [out] valeur Pointeur vers un tableau contenant la valeur correspondant à l'étiquette
* \return L'indice de la dernière cellule parcourue
*************************************************************************/
int Extraire (char *tab_recu_brut,int indice, int offset, char *valeur){
    int i=0;

    while(tab_recu_brut[indice+offset+i] != ' '){
        valeur[i] = tab_recu_brut[indice+offset+i];
        i++;
    }
    i++;
    return (indice+i+offset);
}


/** **********************************************************************
* \fn short Statu_Checksum(char *tab_recu_brut, int indice_deb, int indice_fin)
* \brief Calcul du Checksum \n
*   Retourne un entier de statu si le checksum calculé correspond à celui reçu
* \param [in] tab_recu_brut  Pointeur vers un tableau contenant la trame brute reçue du compteur
* \param [in] indice_deb Indice de la première cellule où commencer le calcul du checksum
* \param [in] indice_fin Indice de la dernière cellule où terminer le calcul du checksum
* \return La validité de la donnée reçue \n
*  \p 1 si donnée valide \n
*  \p 0 si donnée invalide
*************************************************************************/
short Statu_Checksum(char *tab_recu_brut, int indice_deb, int indice_fin){
    // Calcul du Checksum du début de l'étiquette jusqu'au dernier espace avant le checksum
    int i=0;
    short statu = 0;
    unsigned int cpt=0;
    char checksum_calc = '-';

    // 1.	On fait tout d'abord la somme des codes ASCII de tous ces caractères
    // Etiquette + <HT> (0x09) + Donnée + <HT> (0x09)
    for(i=indice_deb;i<indice_fin-1;i++){
        cpt = cpt + tab_recu_brut[i];
    }

    /* 2.	Pour éviter d'introduire des fonctions ASCII (0x00 à 0x1F), on ne conserve que les
    * six bits de poids faible du résultat obtenu (cette opération se traduit par un ET logique
    * entre la somme précédemment calculée et 0x3F).
    * 3.	Enfin, on ajoute 0x20.    */
    checksum_calc = (cpt & 0x3F)+ 0x20;

    // Comparaison du Checksum calculé et reçu
    if (checksum_calc == tab_recu_brut[indice_fin])
        statu = 1;  // Donnée valide
    else
        statu = 0;  // Donnée invalide

    return statu;
}

/** **********************************************************************
* \fn short Synthese_Checksum (short* Statu_checksum)
* \brief Synthèse des Checksums
* \param [in] Statu_checksum  Pointeur vers un tableau contenant la valeur de Statu_chcksm
* \return Le résultat de la somme des checksums
*************************************************************************/
short Synthese_Checksum (short* Statu_checksum){
    short synthese = 0;
    short i=0;

    for(i=0;i<12-1;i++){
        synthese = synthese + Statu_checksum[i];
    }
    return synthese;
}
