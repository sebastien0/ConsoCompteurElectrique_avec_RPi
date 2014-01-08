clear;
close;
clc;

//*** Chargement de l'environnement ***********
// Répertoires par défaut
fnctPath = "E:\Documents\Documents\Divers\Communication cpt Linky\Scilab";
dataPath2Read = "E:\Documents\Documents\Divers\Communication cpt Linky\Code\Compteur_Linky\Relevés";
dataPath2Save = "E:\Documents\Documents\Divers\Communication cpt Linky\Code\Compteur_Linky\Relevés\Variables";

// Charger les functions dans l'environnement
exec(fnctPath+"\ChargerTxt.sci");
exec(fnctPath+"\tracerGraph.sci");

// TODO: Demander à l'utilisateur s'il s'agit d'un nouvel import ou d'un chargement

// *** Importer le fichier txt ***************
ChargerTxt(dataPath2Read);
// Retourne: Gbl_CreationTxt, Gbl_donnee_mesure, Gbl_Papp, Gbl_Index, Gbl_NumCompteur, Gbl_Config

//Sauvegarder les variables globales
SauveVariables(dataPath2Save);

// Connaitre la configuration du compteur
if Gbl_Config (1) == 0 then
    Config = 1;
elseif Gbl_Config (2) == 0 then
    Config = 2;
else
    Config = 0;
end

// *** Tracer la Papp ou les index *****************
if Config == 1 then
    tracerGraph(Gbl_Papp, Gbl_NumCompteur, "Index de la puissance", Config);
elseif Config == 2 then
    tracerGraph(Gbl_Index, Gbl_NumCompteur, "Index des consommations Heures pleines et creuses", Config);
    legende = legend(["Index heures creuses"; "Index heures pleines"],2);
    legende.font_size = 3;
end
