******************************************************************************************************
	SUPERVISION TEMPS-REEL DES CONSOMMATIONS ELECTRIQUES DOMESTIQUES
		!!! Gratuit pour une utilisation non commerciale !!!!!
		!!! Free for non commercial use !!!!!!
******************************************************************************************************

<<<<<<< HEAD
<img src="https://github.com/sebastien0/ConsoCompteurElectrique_avec_RPi/blob/master/Code/Compteur_Linky/Doxygen/Images/Illustration.jpg" height="500px">
=======
<img src="https://github.com/sebastien0/ConsoCompteurElectrique_avec_RPi/blob/master/Code/Compteur_Linky/Doxygen/Images/Illustration.jpg" height="230px">
>>>>>>> 1e8c339c092339f7ec09b38550980a3edabc4971

********************************************
ConsoCompteurElectrique_avec_RPi
Initié en septembre 2013

Auteur:
	Sébastien Lemoine

Co-auteurs:
	Manu

Remerciements:
	Coco
	Julie L.
	Nico D.
	Marc Brunello
	Samuel P.
	Pierre V.
********************************************


********************************************
	DESCRIPTION
********************************************
A ce jour (Janvier 2015):
- Acquisition matérielle depuis le compteur en tête d'installation, installé par EDF/ERDF
- Acquisition (RS232) et enregistrement dans fichiers .txt sur Raspberry-Pi (R-Pi)
- Traitements avancés avec Scilab (hors ligne, i.e. déporté sur une machine plus performante)

A terme (évolutions):
- Enregistrement dans une BASE DE DONNEES
- AFFICHAGE WEB depuis la R-Pi
- Enrichissement des traitements avancés avec Scilab


********************************************
	ARBORESCENCE
   (à ré-agencer)
	Répertoire			Description
-----------------------------------------------------------------------------------------
+ Affichage distant		Sources pour l'IHM html
+ Code					Sources du code C tournant sur la R-Pi
 + Compteur_Linky		Projet Codeblock (.cbp), Projet doxygen (.dxgn)
  + Doxygen			Documentation
   - html			Documentation HTML générée
   - Images			Objets nécessaires à la documentation du code
  + Sources			Sources et makefile
   - bin			Executable
   - build			Objets de compilation
   - inc			Includes (sources .h)
   - src			Source (sources .c)
+ Documents			Documentation divers (Description projet, outils, pilotes, BOM, Datasheets, ...)
 - Datasheets
 - Drivers-Bibliothèques
+ Releves			Relevés bruts et tracés obtenus, depuis différents compteurs
						  (3 Base, 1 Heures Creuses Heures Pleines (HCHP))
   - Fichiers csv		Données brutes au format .csv
   - Fichiers txt		Données brutes au format .txt 
   - Variables			Données exportées et tracées avec Scilab
+ Scilab				Scripts Scilab + documentation générée
 - Documentation		Scripts de documentation
 - Sources				Scripts pour importer, tracer les courbes ou réaliser du traitement du signal


 --- Fin de fichier ---
