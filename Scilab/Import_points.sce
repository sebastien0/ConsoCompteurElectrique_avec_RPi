clear;
close;
clc;

//*** Chargement de l'environnement *******************************************
// Répertoires par défaut
fnctPath = "E:\Documents\Documents\Divers\Communication cpt Linky\Scilab";
dataPath2Read = "E:\Documents\Documents\Divers\Communication cpt Linky\Code\Compteur_Linky\Relevés";
dataPath2Save = "E:\Documents\Documents\Divers\Communication cpt Linky\Code\Compteur_Linky\Relevés\Variables";

// Charger les fonctions dans l'environnement
exec(fnctPath+"\ChargerTxt.sci");
exec(fnctPath+"\tracerGraph.sci");

//*** Début du programme *******************************************************
disp("Programme de gestion des données acquise avec la Raspberry-Pi");
disp("Saisissez votre choix puis valier par OK (et non ENTREE)");

choix = "-1";
while(choix <> "0" & choix <> []) do
    choix = x_dialog(["Que voulez-vous faire?";"";"1   Charger un fichier texte";"2   Charger un fichier de données";"3   Tracer le graphique";"0 ou CANCEL   Quitter"],"0");
    
    // *** 1   Charger un fichier texte ***************************************
    if choix == "1" then
        disp("Chargement d''un fichier texte");
        // *** Importer le fichier txt ***************
        ChargerTxt(dataPath2Read);
        // Retourne: Gbl_CreationTxt, Gbl_donnee_mesure, Gbl_Papp, Gbl_Index, Gbl_NumCompteur, Gbl_Config
    
        //Sauvegarder les variables globales
        SauveVariables(dataPath2Save);
    
    // *** 2   Charger un fichier de données **********************************
    elseif choix == "2" then
        disp("Chargement d''un fichier de données");
        cheminFichier = uigetfile(["*.sod"],dataPath2Save, "Choisir le fichier à ouvrir", %f);
        
        // Si un fichier est bien sélectionné
        if (cheminFichier ~= "") then
            load(cheminFichier);
            disp("Variables chargées");
        else
            disp("Aucun fichier sélectionné");
        end
        clear cheminFichier;
        
    // *** 3   Tracer les graphiques ******************************************
    elseif choix == "3" then
        disp("Tracer le graphique");
        // Connaitre la configuration du compteur
        if Gbl_Config (1) == 0 then
            Config = 1;
        elseif Gbl_Config (2) == 0 then
            Config = 2;
        else
            Config = 0;
        end

        // *** Tracer la Papp *****************
        if Config == 1 then
            tracerGraph(Gbl_Papp, Gbl_NumCompteur, "Index de la puissance", Config);
            
        // *** Tracer les index *****************    
        elseif Config == 2 then
            tracerGraph(Gbl_Index, Gbl_NumCompteur, "Index des consommations Heures pleines et creuses", Config);
            legende = legend(["Index heures creuses"; "Index heures pleines"],2);
            legende.font_size = 3;
        end

    // *** 0   Quitter ********************************************************
    elseif size(choix) == [1 1] then
        if choix == "0" then
            disp("Fin de l''application");
        end
    elseif (choix == [] & size(choix) == [0 0]) then
        disp("Fin de l''application");

    // *** Défaut *************************************************************
    else
        disp("Mauvaise saisie, validez par OK et non ENTREE");
    end
end
