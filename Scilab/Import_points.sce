clear all;
clc;

//*** Chargement de l'environnement ***********
// Répertoire par défaut des fonctions
fnctPath= "E:\Documents\Documents\Divers\Communication cpt Linky\Scilab";
    
// Charger les functions
//exec(fnctPath+"\ChargerTxt.sci");
//exec(fnctPath+"\tracerGraph.sci");
deff('[CreationTxt, Papp, donnee_mesure] = ChargerTxt()',"ChargerTxt");   // Importer le fichier texte
deff('tracerGraph(CreationTxt, Papp, donnee_mesure)',"tracerGraph");  //Tracer la courbe

//*** Traitement ***************
global CreationTxt;
global Papp;
global donnee_mesure;


[CreationTxt1, Papp1, donnee_mesure1] = ChargerTxt();
tracerGraph(CreationTxt1, Papp1, donnee_mesure1);

resume;
