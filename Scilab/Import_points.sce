clear;
close;
clc;

//*** Chargement de l'environnement *******************************************
// Répertoires par défaut
fnctPath = pwd();
dataPath2Read = "E:\Documents\Documents\Divers\Communication cpt Linky\Code\Compteur_Linky\Relevés";
dataPath2Save = "E:\Documents\Documents\Divers\Communication cpt Linky\Code\Compteur_Linky\Relevés\Variables";

// Charger les fonctions dans l'environnement
exec(fnctPath+"\Charger_Txt.sci");
exec(fnctPath+"\Tracer_Graph.sci");
exec(fnctPath+"\Puissance_HPHC.sci");
exec(fnctPath+"\Charger_Variables.sci");

//*** Début du programme *******************************************************
printf("*************************************************************\n");
printf("Programme de gestion des données acquise avec la Raspberry-Pi\n");
printf("Saisissez votre choix puis valier par OK (et non ENTREE)\n");
printf("*************************************************************\n\n");

choix = "-1";
while(choix <> "0" & choix <> []) do
    choix = x_dialog(["Que voulez-vous faire?";"";...
    "1   Charger un fichier texte";"2   Charger un fichier de données";...
    "3   Tracer la puissance apparente";"4   Tracer la Papp et les index";...
    "0 ou CANCEL   Quitter"],"1");
    
    //*************************************************************************
    //* 1   Charger un fichier texte
    //*************************************************************************
    if choix == "1" then
        printf("Chargement d''un fichier texte\n");
        // *** Importer le fichier txt ***************
        cheminFichier = Charger_Txt(dataPath2Read);
        // Retourne: Gbl_CreationTxt, Gbl_Heure, Gbl_Papp, Gbl_Index, 
        //           Gbl_NumCompteur, Gbl_Config
        if (cheminFichier <> "" & (Gbl_Config(1) == 0 | Gbl_Config(2) == 0)) then
            //Sauvegarder les variables globales
            // TODO: sélection du répertoire ?!
            Sauve_Variables(dataPath2Save);
        end

    //*************************************************************************
    //* 2   Charger un fichier de données
    //*************************************************************************
    elseif choix == "2" then
        printf("Chargement d''un fichier de données\n\n");
        charger_variables(dataPath2Save);

    //*************************************************************************
    //* 3   Tracer la Puissance apparente
    //*************************************************************************
    elseif choix == "3" then
        close;
        printf("Tracer la puissance apparente\n");
        if (Gbl_Config(1) == 0 | Gbl_Config(2) == 0) then
            tracer_Graph(Gbl_Papp, Gbl_NumCompteur,"Puissance apparente");
        else
            printf("Aucune donnée valide à tracer\n");
        end

    //*************************************************************************
    //* 4   Tracer la Puissance apparente et les Index
    // TODO: vérifier l'existence des variables avant de commencer
    //*************************************************************************
    elseif choix == "4" then
        close;
        printf("Tracer la puissance apparente et les index\n");
        if (Gbl_Config(1) == 0 | Gbl_Config(2) == 0) then
            tracer_2_Graph(Gbl_Papp, Gbl_Index, Gbl_NumCompteur);
        else
            printf("Aucune donnée valide à tracer\n");
        end

    //*************************************************************************
    //* 0   Quitter
    //*************************************************************************
    elseif size(choix) == [1 1] then
        if choix == "0" then
            printf("Fin de l''application\n");
        end
    elseif (choix == [] & size(choix) == [0 0]) then
        printf("Fin de l''application\n");

    //*************************************************************************
    //*    Défaut
    //*************************************************************************
    else
        printf("Mauvaise saisie, validez en cliquant sur OK et non ENTREE\n");
    end
end
