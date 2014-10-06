/** **************************
* \file Acquerir.c
* \author Sébastien Lemoine
* \date Octobre 2013
* \brief Conversion des données reçues du compteur dans un fichier texte
*   avec horodatage de celles-ci
*
* \details Programme réalisant: \n
*   \li La configuration de l'UART \n
*   \li La réception des données reçue sur l'UART \n
*   \li Leur décodage \n
*   \li L'enregistrement périodique dans un fichier texte \n
*   \li S'arrêter à la fin de la journée
******************************/

#include "Acquerir.h"
#include "Sortir.h"

/** ***************************
* \fn short acquerir()
* \brief Permet l'acquisition sur une journée
*
* \todo Remplacer \p nombre_decriture par 3 points se réécrivants \n
* A intégrer dans la condition d'enregistrement par minute ?!
* \code
* printf("Info \t En cours .\r");	//...
* printf("Info \t En cours ..\r");	//...
* printf("Info \t En cours ...\r");	//...
* \endcode
******************************/
short acquerir(void){
    // ***************** Déclarations **********************************
	char *frame = NULL;
	char *tabRecu = NULL;
	int fd = 0;

    char Motdetat[7]="-";
    char Adeco[13]="-";
    char Optarif[5]="-";
    char Isousc[3]="-";
    char Base[10]="-";
    char Hchc[10]="-";
    char Hchp[10]="-";
    char Ptec[5]="-";
    char Iinst[4]="-";
    char Imax[4]="-";
    char Papp[6]="-";
    char Hhphc[2]="-";
    char Checksum[12]={'-'};
    short Statu_chcksm[12]={9};
    char temp[160] = "-";
    short erreur = 1;
    FILE* fichier = NULL;
    char nom_fichier[40] = "99.txt";
    char DateHeure[20] = {"9"};
    short config_base = FAUX;
    short invalide = -1;
	char minSuivante = '0';
	char heureSuivante = '0';
	char heureCourante[9]={'0'};
	// si DEBUG alors 2 minutes après le démarrage
	char heureArret[9]={"23:59:58"};
	short finir = 0;

//	#ifdef DEBUG
//	unsigned int nmbreEcriture =0;
//	#endif

	/****************** Réception des données *****************/
	// ***** Ouverture UART ********************************
	/**
	* \todo Configurer l'UART par le programme, s'inspirer de
	*   https://projects.drogon.net/raspberry-pi/wiringpi/serial-library/
	* \code
	*   struct termios options ;
    *   tcgetattr (fd, &options) ;   // Read current options
    *   options.c_cflag &= ~CSIZE ;  // Mask out size
    *   options.c_cflag |= CS7 ;     // Or in 7-bits
    *   options.c_cflag |= PARENB ;  // Enable Parity - even by default
    *   tcsetattr (fd, &options) ;   // Set new options
	* \endcode
	*******/
	fd = openUARTFd();
	printf("Info \t UART opened\n");
	while (Adeco[0] == '-') {
		// ***** Lectures du buffer de l'UART **********************
		tabRecu = malloc(181);
		frame = malloc(152);
		readFrame(fd, tabRecu);	// Obtenir une trame avec STX en tabRecu[0]

		extract(tabRecu, frame);	// Copier dans frame une trame sans ses balises
		free(tabRecu);

		/************* Affichage de la trame reçue *********************/
		//printf("Info \t Trame recue du compteur\n%s \n\n",frame);


		/************* Décodage de la trame *******************/
		Decode_Trame_Brute (frame, Motdetat, Adeco, Optarif,
		Isousc, Base, Hchc, Hchp, Ptec, Iinst, Imax, Papp,
		Hhphc, Checksum, Statu_chcksm);
	}

	printf("Info \t Identifiant compteur : %s\n",Adeco);

	// Detection de la configuration du compteur: Base ou Heures Creuses - Heures Pleines
	if (Base[0] != '-'){
	    config_base = VRAI;
	    printf("Info \t Compteur configure en : Base\n");
		// Initialisé à -1; 2 erreurs remontées pour HCHC et HCHP
	    invalide = Synthese_Checksum (Statu_chcksm)-9;
	}
	else{
	    printf("Info \t Compteur configure en : Heures Creuses - Heures Pleines\n");
		// Initialisé à -1; 1 erreur remontée pour BASE
	    invalide = Synthese_Checksum (Statu_chcksm)-10;
	}

	/************* Initialiser le fichier et son contenu ***********/
	Horodate(DateHeure,DATEHEURE);
	printf("Info \t Date et heure du releve : \t %s", DateHeure);
	erreur = fichier_init(fichier, nom_fichier, Adeco, config_base);
	printf("Info \t Creation du fichier : \t %s\n",nom_fichier);

	#ifdef DEBUG
	// Heure d'arrêt = 2 minutes après le démarrage
	memcpy(heureArret, &DateHeure[11], 8);
	if (heureArret[4] + 2 > '9') {
		heureArret[4] = '1';
		heureArret[3] = heureArret[3] +1;
		if (heureArret[3] > '5'){
			heureArret[3] = '0';
			heureArret[1] = heureArret[1]+1;
		}
	}
	else
		heureArret[4] = heureArret[4] + 2;
	#endif

	// Si pas d'erreur à l'ouverture alors écriture dans le fichier
	if (erreur != 0)
	    printf("Erreur \t %s \t Impossible d'editer le fichier \t %s\n",
		heureCourante, nom_fichier);
	else {
	    /**** Ecriture de la première trame ***********************/
	    fichier = fopen(nom_fichier, "a");
	    Horodate(DateHeure,HEURE);
//		printf("invalide : %i\t Papp : %s\n", invalide, Papp);	// DEBUG
		gestionInvalide (temp, config_base, invalide, DateHeure,
		Papp, Base, Hchc, Hchp);
		// Ecrire dans le fichier
	    fprintf(fichier,temp);

		free(frame);

		// Fonctionement pendant 1 jour
	    Horodate(DateHeure,HEURE);
		// Heure courante
		memcpy (heureCourante, DateHeure, 8);

		#ifdef DEBUG
		// Heure d'arrêt définie dans la déclaration
		printf("Info \t %s \t Heure d'arret : %s\n", heureCourante, heureArret);
		#endif

		// Prochaine minute où faire l'enregistrement dans le fichier
		minSuivante = heureCourante[4]+1;
		if (minSuivante > '9')
			minSuivante = '0';

        // Prochaine heure où enregistrer l'index
        heureSuivante = heureCourante[1]+1;
        if (heureSuivante > '9')
            heureSuivante = '0';

		printf("Note \t *** Pour quitter saisir q puis faire entree *** \n");

		// Tant que Heure courante != Heure d'arrêt ou demande d'arrêt par l'utilisateur
		while (((heureCourante[0] != heureArret[0]) || (heureCourante[1] != heureArret[1]) || (heureCourante[3] != heureArret[3]) || (heureCourante[4] != heureArret[4]) || (heureCourante[6] != heureArret[6]) || ((heureCourante[7] != heureArret[7]) && (heureCourante[7] != heureArret[7]+1))) &&
(finir == 0)){
			// L'utilisateur doit saisir q ou Q pour terminer le programme
			finir = sortieDemandee(0, 10);	// timeout de 10 us

			/**** Traitement d'une nouvelle trame ***********************/
			// ***** Lectures du buffer de l'UART **********************
			tabRecu = malloc(181);
			frame = malloc(152);
			readFrame(fd, tabRecu);	// Obtenir une trame avec STX en tabRecu[0]

			extract(tabRecu, frame);	// Copier dans frame une trame sans ses balises
			free(tabRecu);

			// Obtenir l'heure
			Horodate(DateHeure,HEURE);
			memcpy (heureCourante, DateHeure, 8);

			//Decoder la trame
			Decode_Trame_Brute (frame, Motdetat, Adeco, Optarif,
			Isousc, Base, Hchc, Hchp, Ptec, Iinst, Imax, Papp,
			Hhphc, Checksum, Statu_chcksm);

			// Synthétiser le Checksum
			if (config_base == VRAI)
			    invalide = Synthese_Checksum (Statu_chcksm)-9;
			else
			    invalide = Synthese_Checksum (Statu_chcksm)-10;

//			printf("invalide : %i\t Papp : %s\n", invalide, Papp);	// DEBUG

			free(frame);

			// Ajout de l'index toutes les heures sinon seulement Papp
			if (heureCourante[1] == heureSuivante){
				// Prochaine heure où enregistrer l'index
				heureSuivante = heureCourante[1]+1;
				if (heureSuivante > '9')
					heureSuivante = '0';

				// Préparer l'écriture avec le ou les index
				gestionInvalide (temp, config_base, invalide, DateHeure,
				Papp, Base, Hchc, Hchp);
				#ifdef DEBUG
				printf("Info \t %s \t Ajout de l'index %s \n",
				heureCourante, Base);
				#endif
			}
			else {
				// Préparer l'écriture de la Puissance Apparente seule
				if (config_base == VRAI && invalide == 0)
					sprintf(temp,"%s \t %s\r\n", DateHeure,Papp);
				else if (config_base == VRAI && invalide != 0)
					sprintf(temp,"%s \t %s \t\t\t %i\r\n", DateHeure,Papp,invalide);
				else if (invalide == 0)
					sprintf(temp,"%s \t %s\r\n", DateHeure,Papp);
				else
					sprintf(temp,"%s \t %s \t\t\t\t\t %i\r\n", DateHeure,Papp, invalide);
			}

			// Ecrire dans le fichier
			fprintf(fichier,temp);

/*			#ifdef DEBUG
			nmbreEcriture = nmbreEcriture + 1;
			printf("Info \t %s \t Nombre ecriture : %i\n",heureCourante, nmbreEcriture);
			#endif
*/

			// Fermeture du fichier pour "vider la RAM dans le fichier"
			if (heureCourante[4] == minSuivante){
			    fclose(fichier); // Fermer le fichier
			    fichier = fopen(nom_fichier, "a");	// Ouvre le fichier en "ajout"

				// Prochaine minute où faire l'enregistrement
				minSuivante = heureCourante[4]+1;
				if (minSuivante > '9')
					minSuivante = '0';

                #ifdef DEBUG
				printf("Info \t %s \t Fichier %s mis a jour\n",heureCourante, nom_fichier);
				#endif
			}
		}

		/**** Ajouter Index sur la dernière trame ***********************/
		tabRecu = malloc(181);
        frame = malloc(152);
        readFrame(fd, tabRecu);	// Obtenir une trame avec STX en tabRecu[0]
        extract(tabRecu, frame);	// Copier dans frame une trame sans ses balises
        free(tabRecu);

        // Obtenir l'heure
        Horodate(DateHeure,HEURE);
        memcpy (heureCourante, DateHeure, 8);

        //Decoder la trame
        Decode_Trame_Brute (frame, Motdetat, Adeco, Optarif,
        Isousc, Base, Hchc, Hchp, Ptec, Iinst, Imax, Papp,
        Hhphc, Checksum, Statu_chcksm);

        // Synthétiser le Checksum
        if (config_base == VRAI)
            invalide = Synthese_Checksum (Statu_chcksm)-9;
        else
            invalide = Synthese_Checksum (Statu_chcksm)-10;
//			printf("invalide : %i\t Papp : %s\n", invalide, Papp);	// DEBUG
        free(frame);

        // Préparer l'écriture avec le ou les index
        gestionInvalide (temp, config_base, invalide, DateHeure,
        Papp, Base, Hchc, Hchp);

        // Ecrire dans le fichier
        fprintf(fichier,temp);

        /**** Ajouter le mot d'état et le courant max ***********************/
		sprintf(temp,"\nMotdetat \t %s \t Imax \t %s\r\n", Motdetat,Imax);
		fprintf(fichier,temp);

	    fclose(fichier); // Fermer le fichier

		/***** Fermeture UART ********************************/
		closeUARTFd(fd);
		printf("Info \t %s \t UART closed\n", heureCourante);

		usleep(500000);	// Pause 1/2s pour terminer la journée
	}

	return finir;
}

/** ***************************
* \fn void gestionInvalide (char *temp, int config_base, int invalide,
 char *DateHeure, char *Papp, char *Base, char *Hchc, char *Hchp)
* \brief Prépare la chaîne de caractère à écrire dans le fichier en
*   fonction de la validité de la trame et de la configuration Base ou HCHP
* \param [out] temp    Chaîne de caractère composée selon: \n
*   \li <c> DateHeure Papp Base </c>
*   \li <c> DateHeure Papp Base invalide </c>
*   \li <c> DateHeure Papp Hchc Hchp invalide </c>
*   \li <c> DateHeure Papp Hchc Hchp invalide </c>
* \param [in] config_base   Entier indiquant la configuration en Base ou HCHP
* \param [in] invalide  Entier synthétisant la validité de la trame à enregistrer
* \param [in] DateHeure Pointeur vers un tableau contenant l'heure courante
* \param [in] Papp  Pointeur vers un tableau contenant la valeur de Papp
* \param [in] Base  Pointeur vers un tableau contenant la valeur de Base
* \param [in] Hchc  Pointeur vers un tableau contenant la valeur de Hchc
* \param [in] Hchp  Pointeur vers un tableau contenant la valeur de Hchp
******************************/
void gestionInvalide (char *temp, int config_base, int invalide,
 char *DateHeure, char *Papp, char *Base, char *Hchc, char *Hchp){
	if (config_base == VRAI && invalide ==0)
		sprintf(temp,"%s \t %s \t %s\r\n",
		DateHeure,Papp,Base);
	else if (config_base == VRAI && invalide !=0)

		sprintf(temp,"%s \t %s \t %s \t %i\r\n",
		DateHeure,Papp,Base, invalide);
	else if (invalide ==0)
		sprintf(temp,"%s \t %s \t %s \t %s\r\n",
		DateHeure,Papp,Hchc,Hchp);
	else
		sprintf(temp,"%s \t %s \t %s \t %s \t %i\r\n",
		DateHeure,Papp,Hchc,Hchp, invalide);
}
