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

// *** Importer le fichier txt ***************
ChargerTxt(dataPath);
// Retourne: Gbl_CreationTxt, Gbl_donnee_mesure, Gbl_Papp, Gbl_Index, Gbl_NumCompteur, Gbl_Config

if Gbl_Config (1) == 0 then
    Config = 1;
elseif Gbl_Config (2) == 0 then
    Config = 2;
else
    Config = 0;
end

// *** Tracer la Papp ou les index *****************
tracerGraph(Gbl_Index, Gbl_NumCompteur, "Index des consommations Heures pleines et creuses", Config);
// Illustrations sur le graph
if Config == 2 then
    legend(["Index heures creuses"; "Index heures pleines"]);
end
