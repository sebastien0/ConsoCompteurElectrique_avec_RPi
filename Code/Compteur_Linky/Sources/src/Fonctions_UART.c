/** **********************************************************************
* \file Fonctions_UART.c
* \author Emmanuel Carré
* \author Sébastien Lemoine
* \date Septembre 2013
* \brief Permet de gérer l'accès à l'UART
**************************************************************************/

#include "Fonctions_UART.h"

/** **************************
* \fn int openUARTFd()
* \brief Ouvrir le buffer de l'UART \p UART_FILE_PATH en lecture seule
* \return Le file descriptor du buffer de l'UART
******************************/
int openUARTFd(){
    int fd = open(UART_FILE_PATH, O_RDONLY);
    if (fd == -1)
        printf("Open failed: %s\n", UART_FILE_PATH);
    return fd;
}


/** **************************
* \fn void closeUARTFd(int UARTFd)
* \brief Fermer le buffer de l'UART
* \param[in] UARTFd le file descriptor du buffer de l'UART
******************************/
void closeUARTFd(int UARTFd){
    int res = close(UARTFd);
    if (res != 0)
        printf("Close failed: %s\n", UART_FILE_PATH);
}


/** **************************
* \fn void readFrame(int fd, char *tabRecu)
* \brief Lit jusqu'à 179 caractères reçu sur l'UART à partir de \p STX \n
*   Attend le caractère \p STX avec une pause de 2ms. \n
*   Puis attend 1.4s le temps de recevoir l'intégralité de
*   la trame avec un peu plus de caractères \n
*   Effectue la copie dans \p tabRecu
*
* \param[in] fd File descriptor du buffer de l'UART
* \param[out] *tabRecu  Pointeur du tableau où écrire les caractères reçus
******************************/
void readFrame(int fd, char *tabRecu){
    int bytesRead = 0;

    //Attente de recevoir STX
	while (tabRecu[0] != STX) {
		usleep(2000);	// 2ms
		bytesRead = read(fd, tabRecu, 1);
	}

    // Copier à partir de STX jusqu'à 179 caractères
	if (tabRecu[0] == STX){
		// Pause de 1.4s pour recevoir toute la trame
		sleep(1);
		usleep(400000);
		// Acquérir l'intégralité de la trame
		bytesRead = read(fd, &tabRecu[1], 179);
		// Ajouter fin de chaine de caractère
		tabRecu[bytesRead+1]='\0';
		// Afficher la trame reçue
//		printf("tabRecu = \n%s\n",tabRecu);
	}
}

