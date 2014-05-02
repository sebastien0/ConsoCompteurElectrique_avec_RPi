clear;
close;
clc;

//*** Chargement de l'environnement *******************************************
// Répertoires par défaut
fnctPath = pwd();
projectPath = strncpy(pwd(),length(pwd())-length("\Scilab"));
dataPath2Read = projectPath + "\Code\Compteur_Linky\Releves";
dataPath2Save = dataPath2Read + "\Variables";

// Charger les fonctions dans l'environnement
exec(fnctPath+"\Charger_Txt.sci");
exec(fnctPath+"\Tracer_Graph.sci");
exec(fnctPath+"\Puissance_HPHC.sci");
exec(fnctPath+"\Charger_Variables.sci");
exec(fnctPath+"\Calculs.sci");
exec(fnctPath+"\Filtrage.sci");

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
        close;
        printf("\nChargement d''un fichier texte\n");
        // *** Importer le fichier txt ***************
        cheminFichier = Charger_Txt(dataPath2Read);
        // Retourne: Gbl_CreationTxt, Gbl_Heure, Gbl_Papp, Gbl_Index0, 
        //           Gbl_Index, Gbl_NumCompteur, Gbl_Config
        if (cheminFichier <> "" & (Gbl_Config(1) == 0 | ...
            Gbl_Config(2) == 0)) then
            //Sauvegarder les variables globales
            // TODO: sélection du répertoire ?!
            Sauve_Variables(dataPath2Save);
        end

    //*************************************************************************
    //* 2   Charger un fichier de données
    //*************************************************************************
    elseif choix == "2" then
        close;
        printf("\nChargement d''un fichier de données\n\n");
        charger_variables(dataPath2Save);

    //*************************************************************************
    //* 3   Tracer la Puissance apparente
    //*************************************************************************
    elseif choix == "3" then
        close;
        printf("\nTracer la puissance apparente\n");
        try
            size(Gbl_Papp);
            erreur = 0;
        catch
            printf("Erreur! \t Importer d''abord des données, choix 1 ou 2.\n");
            erreur = 1;
        end

        if (erreur == 0 & (Gbl_Config(1) == 0 | Gbl_Config(2) == 0)) then
            [duree, moyenne] = HeuresFonctionnement();
            tabMoy = matrice(Gbl_Papp, moyenne);
            tracer_Graph([Gbl_Papp tabMoy], Gbl_NumCompteur,"Puissance apparente");
        else
            printf("Erreur! \t Aucune donnée valide à tracer\n");
        end

    //*************************************************************************
    //* 4   Tracer la Puissance apparente et les Index
    //*************************************************************************
    elseif choix == "4" then
        close;
        printf("\nTracer la puissance apparente et les index\n");
        try
            size(Gbl_Papp);
            size(Gbl_Index);
            erreur = 0;
        catch
            printf("Erreur! \t Importer d''abord des données, choix 1 ou 2.\n");
            erreur = 1;
        end
        
        if (erreur == 0 & (Gbl_Config(1) == 0 | Gbl_Config(2) == 0)) then
            [duree, moyenne] = HeuresFonctionnement();
            tabMoy = matrice(Gbl_Papp, moyenne);
            tracer_2_Graph([Gbl_Papp tabMoy], Gbl_Index, Gbl_NumCompteur);

        else
            printf("Erreur! \t Aucune donnée valide à tracer\n");
        end

    //*************************************************************************
    //* 0   Quitter
    //*************************************************************************
    elseif (choix == "0" | (choix == [] & size(choix) == [0 0])) then
            printf("\nFin de l''application\n");

    //*************************************************************************
    //*    Défaut
    //*************************************************************************
    else
        printf("Erreur! \t Mauvaise saisie. \n...
        \t Validez en cliquant sur OK et non ENTREE\n");
    end
end
