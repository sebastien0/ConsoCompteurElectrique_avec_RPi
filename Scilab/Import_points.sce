clear;
close;
clc;

//*** Chargement de l'environnement ***********
// Répertoires par défaut
fnctPath = "E:\Documents\Documents\Divers\Communication cpt Linky\Scilab";
dataPath = "E:\Documents\Documents\Divers\Communication cpt Linky\Code\Compteur Linky\Compteur_Linky\Relevés";

// Charger les functions dans l'environnement
exec(fnctPath+"\ChargerTxt.sci");
exec(fnctPath+"\tracerGraph.sci");

//*** Effectuer le traitement ***************
ChargerTxt(dataPath);
// Retourne: Gbl_CreationTxt, Gbl_donnee_mesure, Gbl_Hpleines ou Papp, Gbl_Hcreuses ou Base, Gbl_NumCompteur
tracerGraph([Gbl_Hcreuses, Gbl_Hpleines], Gbl_NumCompteur, "Index des consommations Heures pleines et creuses");
legend(['Index heures creuses';'Index heures pleines']);
