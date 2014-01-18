clear;
close;
clc;

//*** Chargement de l'environnement *******************************************
// Répertoires par défaut
fnctPath = pwd();
dataPath2Read = "E:\Documents\Documents\Divers\Communication cpt Linky\Code\Compteur_Linky\Relevés";
dataPath2Save = "E:\Documents\Documents\Divers\Communication cpt Linky\Code\Compteur_Linky\Relevés\Variables";

// Charger les fonctions dans l'environnement
exec(fnctPath+"\ChargerTxt.sci");
exec(fnctPath+"\tracerGraph.sci");

//*** Début du programme *******************************************************
printf("*************************************************************\n");
printf("Programme de gestion des données acquise avec la Raspberry-Pi\n");
printf("Saisissez votre choix puis valier par OK (et non ENTREE)\n");
printf("*************************************************************\n\n");

choix = "-1";
while(choix <> "0" & choix <> []) do
    choix = x_dialog(["Que voulez-vous faire?";"";"1   Charger un fichier texte";"2   Charger un fichier de données";"3   Tracer le graphique";"0 ou CANCEL   Quitter"],"1");
    
    // *** 1   Charger un fichier texte ***************************************
    if choix == "1" then
        printf("Chargement d''un fichier texte\n");
        // *** Importer le fichier txt ***************
        cheminFichier = Charger_Txt(dataPath2Read);
        // Retourne: Gbl_CreationTxt, Gbl_donnee_mesure, Gbl_Papp, Gbl_Index, Gbl_NumCompteur, Gbl_Config
        // TODO: Gbl_donnee_mesure n'est utile que pour la mise au point de Puissance_HCHP
        if (cheminFichier <> "" & (Gbl_Config(1) == 0 | Gbl_Config(2) == 0)) then
            //Sauvegarder les variables globales
            // TODO: sélection du répertoire ?!
            Sauve_Variables(dataPath2Save);
        end
        
    // *** 2   Charger un fichier de données **********************************
    elseif choix == "2" then
        printf("Chargement d''un fichier de données\n");
        cheminFichier = uigetfile(["*.sod"],dataPath2Save, "Choisir le fichier à ouvrir", %f);
        
        // Si un fichier est bien sélectionné
        if (cheminFichier ~= "") then
            load(cheminFichier);
            printf("Variables chargées\n");
        else
            printf("Aucun fichier sélectionné\n");
        end
        clear cheminFichier;
        
    //*************************************************************************
    //* 3   Tracer les graphiques 
    //*************************************************************************
    elseif choix == "3" then
        printf("Tracer le graphique\n");
        // Connaitre la configuration du compteur
        try
            if (Gbl_Config(1) == 0 | Gbl_Config(2) == 0) then
//                printf("Données valide à tracer\n");
                if Gbl_Config(1) == 0 then
                    Config = 1;
                elseif Gbl_Config(2) == 0 then
                    Config = 2;
                else
                    Config = 0;
                end
        
                // Utilise subplot pour tracer Papp et Index
                // TODO: Reprendre la création de index en Base et Papp en HCHP
//                tracer_2_Graph(Gbl_Papp, Gbl_Index, Gbl_NumCompteur);
        
                // *** Tracer la Papp *****************
                if Config == 1 then
                    tracer_Graph(Gbl_Papp, Gbl_NumCompteur,...
                     "Puissance apparente", Config);
                    
                // *** Tracer les index *****************    
                elseif Config == 2 then
                    tracer_Graph(Gbl_Index, Gbl_NumCompteur,...
                    "Index des consommations Heures pleines et creuses",...
                    Config);
                    legende = legend(["Index heures creuses";...
                    "Index heures pleines"],2);
                    legende.font_size = 3;
                end
             else
                 printf("Aucune donnée valide à tracer (depuis if)\n");
             end
        catch
            printf("Aucune donnée valide à tracer (depuis catch)\n");
            disp(lasterror());
        end

    // *** 0   Quitter ********************************************************
    elseif size(choix) == [1 1] then
        if choix == "0" then
            printf("Fin de l''application\n");
        end
    elseif (choix == [] & size(choix) == [0 0]) then
        printf("Fin de l''application\n");

    // *** Défaut *************************************************************
    else
        printf("Mauvaise saisie, validez par OK et non ENTREE\n");
    end
end
