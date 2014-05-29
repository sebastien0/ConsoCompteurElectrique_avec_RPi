//********************
// Etude des habitudes
//*******************
clear;
close;
clc;

//*** Chargement de l'environnement *******************************************
// Répertoires par défaut
/// Chemin du répertoire courant, repertoire parent du projet Scilab
fnctPath = pwd();
/// Chemin du répertoire parent du projet Compteur Electronique
projectPath = strncpy(fnctPath,length(fnctPath)-length("\Scilab\Sources"));
/// Chemin du répertoire où lire les fichiers .sod
dataPath = projectPath + "\Code\Compteur_Linky\Releves\Variables";
// Charger les fonctions pour tracer les graphiques
exec(fnctPath+"\Tracer_Graph.sci");


//*** Début du programme *******************************************************
printf("*************************************************************\n");
printf("Programme pour étudier des points communs sur les relevés\n");
printf("Choisir le(s) fichier(s) à charger\n");
printf("*************************************************************\n\n");

//TODO Choix: combien de fichier à charger

// Importer les tableaux Gbl_Heure, Gbl_Papp et Gbl_CreationTxt
cheminFichier = uigetfile(["*.sod"],dataPath, ...
    "Choisir le fichier à ouvrir", %f);
    
// Si un fichier est bien sélectionné
// TODO et fichiers chargées <= nmbre fichier à charger
if (cheminFichier ~= "") then
    printf("Import du fichier %s \n", cheminFichier);
    load(cheminFichier);
    
    // Les sauvegarder dans des variables généralistes Heure, Papp et Jour
    i =1;
    Heure(:,i) = Gbl_Heure;
    Papp(:,i) = Gbl_Papp;
    Jour(1,i) = Gbl_CreationTxt(4);
    Jour(2,i) = Gbl_CreationTxt(1);
    
    // tracer par semaine ou par jour
    // TODO choix du tracé par jour identique ou par semaine
    
    // Tracer les courbes avec une couleur différentes
    printf("Tracé en cours ...\n");
    tracer_D_Graph(Papp, Jour, Heure);   // max 5 courbes
    
else
    printf("Aucun fichier sélectionné\n");
end
