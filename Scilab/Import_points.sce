clear all;
clc;

//*** Chargement de l'environnement ***********
// Répertoire par défaut
fnctPath= "E:\Documents\Documents\Divers\Communication cpt Linky\Scilab";
dataPath = "E:\Documents\Documents\Divers\Communication cpt Linky\Code\Compteur Linky\Compteur_Linky\Relevés";

// Variables globales
global CreationTxt;
global Papp;
global donnee_mesure;

// Charger les functions
exec(fnctPath+"\ChargerTxt.sci");
exec(fnctPath+"\tracerGraph.sci");
//deff('ChargerTxt(dataPath)',"ChargerTxt(dataPath)");   // Importer le fichier texte
//deff('tracerGraph()',"tracerGraph");  //Tracer la courbe

//*** Traitement ***************
ChargerTxt(dataPath);
tracerGraph();
