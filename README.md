******************************************************************************************************
	SUPERVISION TEMPS-REEL DES CONSOMMATIONS ELECTRIQUES DOMESTIQUES
		!!! Gratuit pour une utilisation non commerciale !!!!!
		!!! Free for non commercial use !!!!!!
******************************************************************************************************

********************************************
RPi.SuivitTRElec
Initié en septembre 2013

Auteur:
	Sébastien Lemoine	seb.lemoine@sfr.fr
Co-auteurs:
	Manu
Remerciements:
	Coco
	Julie
	Nico
	Marc BRUNELLO	
	Sam
********************************************


********************************************
	DESCRIPTION
********************************************
A ce jour (Juin 2014):
- Acquisition matérielle depuis le compteur en tête d'installation, installé par EDF
- Acquisition (RS232) et enregistrement dans fichiers .txt sur Raspberry-Pi (R-Pi)
- Traitements avancés avec Scilab (hors ligne, i.e. déporté sur une machine plus performante)

A terme (évolutions):
- Enregistrement dans une BASE DE DONNEES et AFFICHAGE WEB sur R-Pi
- Enrichissement des traitements avancés avec Scilab


********************************************
	ARBORESCENCE
   (à ré-agencer)
********************************************
	Répertoire			Description
-----------------------------------------------------------------------------------------
+ Code					Sources du code C tournant sur la R-Pi
 + Compteur_Linky		Projet Codeblock (.cbp), Projet doxygen (.dxgn)
  - Sources			Sources
  + Doxygen			Documentation
   - html				Documentation HTML générée
   - Images			Objets nécessaires à la documentation du code
  + Releves			Relevés bruts et tracés obtenus, depuis différents compteurs
						  (3 Base, 1 Heures Creuses Heures Pleines (HCHP))
   - Fichiers txt		Données brutes
   - Variables			Données exportées et tracées avec Scilab
- Documents			Documentation divers (projet, outils, pilotes, BOM, Datasheets, ...)
- FTP					Script FTP pour automatiser le téléchargement des relevés depuis la R-Pi
+ Scilab				Scripts Scilab (tracer une ou plusieurs courbes, traitement du signal)
						  Projet Doxygen (.dxgn) -> NE MARCHE PAS
 - Sources				Scripts Scilab

