/** **********************************************************************
* \file Decoder_Trames.h
* \author Sébastien Lemoine
* \date Mai 2013
* \brief Déclaration des fonctions de décodage des trames et de vérification du Checksum
* \headerfile ""
**************************************************************************/

#ifndef Decoder_Trames
#define Decoder_Trames

	/// Indice de la valeur Mot d'état
	#define IND_MOTDETAT    0
	/// Indice de la valeur ADresse COmpteur
	#define IND_ADECO       1
	/// Indice de la valeur OPtion TARIFaire
	#define IND_OPTARIF     2
	/// Indice de la valeur Intensité SOUScrite
	#define IND_ISOUSC      3
	/// Indice de l'index Base
	#define IND_BASE        4
	/// Indice de l'index Heure Creuse
	#define IND_HCHC        5
	/// Indice de l'index Heure Pleine
	#define IND_HCHP        6
	/// Indice de la Période Tarifaire En Cours
	#define IND_PTEC        7
	/// Indice de la valeur Intensité INSTantannée
	#define IND_IINST       8
	/// Indice de la valeur Intensité MAXimale de la journée
	#define IND_IMAX        9
	/// Indice  de la Puissance APParente
	#define IND_PAPP        10
	/// Indice de l'Horaire Heures Pleines Heures Creuses
	#define IND_HHPHC       11


	extern void Decode_Trame_Brute (char *tab_recu_brut,char *Motdetat,
		char *Adeco,char *Optarif,char *Isousc, char *Base, char *Hchc,
		char *Hchp,char *Ptec,char *Iinst, char *Imax, char *Papp,
		char *Hhphc, char *Checksum, short *Statu_chcksm);

	extern int Extraire (char *tab_recu_brut,int indice, int offset, char *valeur);

	extern short Statu_Checksum(char *tab_recu_brut, int indice_deb, int indice_fin);

	extern short Synthese_Checksum (short* Statu_checksum);

#endif
