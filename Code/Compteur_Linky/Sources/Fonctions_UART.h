/** **********************************************************************
* \file Fonctions_UART.h
* \author Sébastien Lemoine
* \date Septembre 2013
* \brief Permet de gérer l'accès à l'UART
* \headerfile ""
**************************************************************************/

#ifndef Fonctions_UART
#define Fonctions_UART

	#include <stdio.h>
	#include <stdlib.h>
	// Fonction Open pour /dev/ttyAMA0
	#include <sys/types.h>
	#include <sys/stat.h>
	#include <fcntl.h>
	// Pour configurer la liaison UART
	#include <termios.h>
	// Fonction Read
	#include <unistd.h>
	// Fonction memcpy
	#include <string.h>


    /// Ressource matériel de l'UART
	#define UART_FILE_PATH	"/dev/ttyAMA0"
	/// Start of TeXt
	#define STX		2
	/// End of TeXt
	#define ETX		3


	extern int openUARTFd();
	extern void closeUARTFd(int UARTFd);
	extern void readFrame(int fd, char *tabRecu);

#endif
