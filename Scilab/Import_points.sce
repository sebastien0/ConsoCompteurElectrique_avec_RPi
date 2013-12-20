clear all;
clc;

//*** Chargement de l'environnement ***********
// Répertoires par défaut
fnctPath = "E:\Documents\Documents\Divers\Communication cpt Linky\Scilab";
dataPath = "E:\Documents\Documents\Divers\Communication cpt Linky\Code\Compteur Linky\Compteur_Linky\Relevés";

// Variables globales
global CreationTxt;
global Papp;
global donnee_mesure;

// Charger les functions dans l'environnement
exec(fnctPath+"\ChargerTxt.sci");
exec(fnctPath+"\tracerGraph.sci");

//*** Effectuer le traitement ***************
ChargerTxt(dataPath);
tracerGraph();
