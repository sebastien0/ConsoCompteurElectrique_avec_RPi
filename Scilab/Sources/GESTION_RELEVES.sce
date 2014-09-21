//*****************************
/// \file GESTION_RELEVES.sce
/// \author Sébastien Lemoine
/// \date Avril 2014
/// \brief Gestion de l'IHM et de l'envrionnement pour un post 
/// traitement des relevés
//******************************

clear;
close;
clc;

// DEBUG = %t : Activer les traces pour le débug
isDEBUG = %f;
//pause   // Continuer en saisissant "resume" en console
erreur = %t;

//*** Chargement de l'environnement *******************************************
// Répertoires par défaut
/// Chemin du répertoire courant, repertoire parent du projet Scilab
fnctPath = pwd();
/// Chemin du répertoire parent du projet Compteur Electronique
projectPath = strncpy(pwd(),length(pwd())-length("\Scilab\Sources"));
/// Chemin du répertoire où lire les fichiers .txt
dataPath2Read = projectPath + "\Code\Compteur_Linky\Releves";
/// Chemin du répertoire où écrire / lire les fichiers .sod
dataPath2Save = dataPath2Read + "\Variables";

// Charger les fonctions dans l'environnement
// Charger les fonctions pour importer un fichier .txt
exec(fnctPath+"\Charger_Txt.sci"); 
// Charger les fonctions pour tracer les graphiques
exec(fnctPath+"\Tracer_Graph.sci");
// Charger les fonctions pour reconstituer les puissances depuis 
// les index d'énergie
exec(fnctPath+"\Puissance_HPHC.sci");
// Charger les fonctions pour importer un fichier binaire .sod
exec(fnctPath+"\Charger_Variables.sci");
// Charger les fonctions de calculs
exec(fnctPath+"\Calculs.sci");
// Charger les fonctions de filtrage
exec(fnctPath+"\Filtrage.sci");
// Charger les fonctions de traitement de signal
//exec(fnctPath+"\GlrBrandtMoy.sci");
// Charger les fonctions de filtrage
exec(fnctPath+"\Modifier_Horodatage.sci");
// Charger les fonctions de statistiques
exec(fnctPath+"\Statistiques.sci");

//*** Début du programme *******************************************************
printf("*************************************************************\n");
printf("Programme de gestion des données acquises avec la Raspberry-Pi\n");
printf("Saisissez votre choix puis valier par OK\n");
printf("*************************************************************\n\n");


choix = -1;
while(choix <> 0 & choix <> []) do
    temp_txt = ["Que voulez-vous faire?";"";...
                "1   Charger un fichier texte";...
                "2   Charger un fichier de données";...
                "3   Tracer la puissance apparente";...
                "4   Tracer la Papp et les index";...
                "0 ou CANCEL   Quitter"];
    choix = evstr(x_mdialog(temp_txt, 'Choix (0 à 4)','1'));
    clear temp_txt
    
    //*************************************************************************
    //* 1   Charger un fichier texte
    //*************************************************************************
    if choix == 1 then
        close;
        printf("\nChargement d''un fichier texte\n");
        // *** Importer le fichier txt ***************
        cheminFichier = Importer_Txt(dataPath2Read, isDEBUG);
        // Retourne: erreur, (stcReleve, stcStatistiques)

        if ~erreur then
          // Modifier l'horodatage
            choixHorodatage = x_mdialog('Modifier l''horodatage ?', 'Choix (y ou n)','n');
            if choixHorodatage == 'y'
                //TODO 
                //Modifier_Horodatage(stcReleve.heure, [-3 -7 0])  // Uniquement MAJ de Gbl_Heure
            end
    
            //Sauvegarder les variables globales
            Sauve_Variables(dataPath2Save, stcReleve, stcStatistiques);

        else
             printf("Aucun fichier sélectionné\n");
        end


    //*************************************************************************
    //* 2   Charger un fichier de données
    //*************************************************************************
    elseif choix == 2 then
        close;
        printf("\nChargement d''un fichier de données\n\n");
        erreur = charger_variables(dataPath2Save);

    //*************************************************************************
    //* 3   Tracer la Puissance apparente
    //*************************************************************************
    elseif choix == 3 then
        close;
        printf("\nTracer la puissance apparente\n");
        
        if erreur then
            printf("Erreur! \t Importer d''abord des données, choix 1 ou 2.\n");
        elseif (~erreur & (stcReleve.isConfigBase | stcReleve.isConfigHCHP)) then
            if stcReleve.numCompteur == ""049701078744"" then
                [stcReleve.dureeFonctionnement, stcReleve.pappMoy] = ...
                HeuresFonctionnement(stcReleve);
             end
            tracer_Graph([Gbl_Papp tabMoy], Gbl_NumCompteur);
        else
            printf("Erreur! \t Aucune donnée valide à tracer\n");
        end

    //*************************************************************************
    //* 4   Tracer la Puissance apparente et les Index
    //*************************************************************************
    elseif choix == 4 then
        close;
        printf("\nTracer la puissance apparente et les index\n");
        if erreur then
            printf("Erreur! \t Importer d''abord des données, choix 1 ou 2.\n");
        elseif (~erreur & (stcReleve.isConfigBase | stcReleve.isConfigHCHP)) then
            // Comptabiliser les heures de fonctionnement (Lyon communs)
            if stcReleve.numCompteur == "271067018318" then
                [stcReleve.dureeFonctionnement, stcReleve.pappMoy] = ...
                HeuresFonctionnement(stcReleve);
            else
                 stcReleve.pappMoy = mean(stcReleve.papp);
            end
            tracer_2_Graph(stcReleve, %t);
        else
            printf("Erreur! \t Aucune donnée valide à tracer\n");
        end

    //*************************************************************************
    //* 5   Développment en cours
    //*************************************************************************
//    elseif choix == 5 then


    //*************************************************************************
    //* 0   Quitter
    //*************************************************************************
    elseif (choix == 0 | (choix == [] & size(choix) == [0 0])) then
            printf("\nFin de l''application\n");

    //*************************************************************************
    //*    Défaut
    //*************************************************************************
    else
        printf("Erreur! \t Mauvaise saisie. \n...
        \t Validez en cliquant sur OK\n");
    end
end
