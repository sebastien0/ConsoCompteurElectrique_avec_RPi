//*****************************
/// \author Sébastien Lemoine
/// \date Avril 2014
/// \version 1.0
/// \brief Gestion de l'IHM et de l'environnement pour un post- 
/// traitement des relevés
//******************************

clear;
close;
clc;

// DEBUG = %t : Activer les traces pour le débug
isDEBUG = %t;
//pause   // Continuer en saisissant "resume" en console
erreur = %t;

//*** Chargement de l'environnement *******************************************
// Répertoires par défaut
// Chemin du répertoire courant, repertoire parent du projet Scilab
fnctPath = pwd();
// Chemin du répertoire parent du projet Compteur Electronique
projectPath = strncpy(pwd(),length(pwd())-length("\Scilab\Sources"));
// Chemin du répertoire où lire les fichiers .txt
dataPath2Read = projectPath + "\Releves";
// Chemin du répertoire où écrire/lire les fichiers .sod
dataPath2Save = dataPath2Read + "\Variables";

// Charger les fonctions dans l'environnement
// Charger les fonctions pour importer un fichier .csv
exec(fnctPath+"\Charger_Csv.sci"); 
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

choix = 1;
while((choix > 0 & choix <= 5 | choix == 9) & choix <> []) do
    temp_txt = ["Que voulez-vous faire?";"";...
                "1   Charger un fichier csv";...
                "2   Modifier l''horodatage";...
                "3   Charger un fichier de données";...
                "4   Tracer la puissance apparente";...
                "5   Tracer la Papp et les index";...
                "9   Charger un fichier texte";...
                "0 ou CANCEL   Quitter"];
    choix = evstr(x_mdialog(temp_txt, 'Choix (0 à 5)','1'));

    //*************************************************************************
    //* 1   Charger un fichier csv
    //*************************************************************************
    if choix == 1 then
        close;
        printf("\nChargement d''un fichier CSV\n");
        // *** Importer le fichier csv ***************
        erreur = Importer_Csv(dataPath2Read, isDEBUG);
        // Retourne: stcReleve, stcStatistiques
        
        //Sauvegarder les variables
        if ~erreur then
            Sauve_Variables(dataPath2Save, stcReleve);
        end

    //*************************************************************************
    //* 2   Modifier l'horodatage
    //*************************************************************************
    elseif choix == 2 then
        if erreur then
            printf("Erreur! \t Importer d''abord des données, choix 1 ou 9.\n");
        else
          // Modifier l'horodatage
            offset = evstr(x_mdialog('Indiquer l''offset à appliquer:',...
                                    '[hh mm ss]',['0' '0' '0']));
            Modifier_Horodatage(stcReleve.heure, offset);
    
            //Sauvegarder les variables
            Sauve_Variables(dataPath2Save, stcReleve);
        end

    //*************************************************************************
    //* 3   Charger un fichier de données
    //*************************************************************************
    elseif choix == 3 then
        close;
        printf("\nChargement d''un fichier de données\n\n");
        erreur = charger_variables(dataPath2Save);

    //*************************************************************************
    //* 4   Tracer la Puissance apparente
    //*************************************************************************
    elseif choix == 4 then
        close;
        printf("\nTracer la puissance apparente\n");

        if erreur then
            printf("Erreur! \t Importer d''abord des données, choix 1 ou 9.\n");
        elseif (stcReleve.isConfigBase | stcReleve.isConfigHCHP) then
            // Comptabiliser les heures de fonctionnement
            if stcReleve.numCompteur == ""049701078744"" then
                [stcReleve.dureeFonctionnement, stcReleve.pappMoy] = ...
                HeuresFonctionnement(stcReleve);
             end
            tracer_Graph([Gbl_Papp tabMoy], Gbl_NumCompteur);
        else
            printf("Erreur! \t Aucune donnée valide à tracer\n");
        end

    //*************************************************************************
    //* 5   Tracer la Puissance apparente et les Index
    //*************************************************************************
    elseif choix == 5 then
        close;
        printf("\nTracer la puissance apparente et les index\n");

        if erreur then
            printf("Erreur! \t Importer d''abord des données, choix 1 ou 9.\n");
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
    //* 9   Charger un fichier texte
    //*************************************************************************
    elseif choix == 9 then
        close;
        printf("\nChargement d''un fichier texte\n");
        
        // *** Importer le fichier txt ***************
        erreur = Importer_Txt(dataPath2Read, isDEBUG);
        // Retourne: stcReleve, stcStatistiques

        //Sauvegarder les variables
        if ~erreur then
            Sauve_Variables(dataPath2Save, stcReleve);
        end

    //*************************************************************************
    //* 0   Quitter
    //*************************************************************************
    elseif (choix < 0 | choix > 5 | choix <> 9) then
            printf("\nFin de l''application\n");

    //*************************************************************************
    //*    Défaut
    //*************************************************************************
    else
        printf("Erreur! \t Mauvaise saisie. \n...
        \t Validez en cliquant sur OK\n");
    end
end


/// \stc stcReleve.     \c Structure    Relevé
///       numCompteur \c String   Numéro du compteur
///       residence   \c String   Nom du domicile
///       config   \c String   Configuration du compteur
///       pSouscr  \c String   Puissance souscrite
///       jour     \c String   Nom du jour
///       date     \c String   Date
///       heureDebut  \c String   Heure de début
///       heureFin    \c string   Heure de fin
///       isConfigBase    \c Booléen  Vrai, configuré en Base
///       isConfigHCHP    \c Booléen  Vrai, configuré en HCHP
///       nbrLignes   \c Double   Nombre d'échantillons
///       nbrIndex    \c Double   Nombre d'index d'énergie
///       papp    \c tabDouble[nbrLignes]     Puissance
///       heure   \c tabDouble[nbrLignes]     Heure
///       index   \c tabDouble[nbrLignes][nbrIndex]     Energies
///       index0  \c tabDouble[nbrIndex]   Energies au début du relevé
///       pappMoy \c double  Puissance moyenne
///       iMax    \c double  Courant max
///       dureeFonctionnement \c double Si compteur 049701078744 alors contient le temps de fonctionnement

