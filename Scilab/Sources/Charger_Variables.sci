//*****************************
/// \file Charger_Variables.sci
/// \author Sébastien Lemoine
/// \date Avril 2014
/// \brief Fonctions pour importer un fichier binaire .sod
//******************************

//****************************************************************************
/// \brief Charger les variables dans l'environnement depuis un fichier .sod
/// \param [in] dataPath2Save string Chemin d'accès au répertoire où lire les fichiers .sod
/// \return Gbl_CreationTxt     \c string     Tableau de date et heures de création
/// \return Gbl_Heure   \c string   Tableau d'horodatage des relevés
/// \return Gbl_Papp    \c double   Tableau des valeurs de la puissance
/// \return Gbl_Index0  \c double   Index d'énergie au 1er échantillon du relevé
/// \return Gbl_Index   \c double Tableau des index d'énergie
/// \return Gbl_NumCompteur     \c string  Numéro du compteur
/// \return Gbl_Config  \c double   Tableau contenant la configuration du compteur
//*****************************************************************************
function charger_variables(dataPath2Save)
    cheminFichier = uigetfile(["*.sod"],dataPath2Save,...
     "Choisir le fichier à ouvrir", %f);
        
    // Si un fichier est bien sélectionné
    if (cheminFichier ~= "") then
        nomFichier = part(cheminFichier, ...
                     (length(dataPath2Save)+2):length(cheminFichier));
        printf("Chargement du fichier %s \n", nomFichier);
        load(cheminFichier);

        // Configuration du compteur
        if (Gbl_Config(1) == 0 | Gbl_Config(2) == 0) then
            if Gbl_Config(1) == 0 then
                Config = 1;
                texteConfig = "Base";
            elseif Gbl_Config(2) == 0 then
                Config = 2;
                texteConfig = "HCHP";
            end

            // Affichage en console des info du compteur
            info_compteur(Gbl_NumCompteur, Gbl_CreationTxt, texteConfig);
            
            [Gbl_CreationTxt, Gbl_Heure, Gbl_Papp, Gbl_Index0, Gbl_Index, ...
            Gbl_NumCompteur, Gbl_Config] = resume (Gbl_CreationTxt, Gbl_Heure, ...
            Gbl_Papp, Gbl_Index0, Gbl_Index, Gbl_NumCompteur, Gbl_Config);
        else
            Config = 0;
            printf("Configuration du compteur non reconnue\n");
        end
    else
        Config = -1;
        printf("Aucun fichier sélectionné\n");
    end
endfunction


//****************************************************************************
/// \fn info_compteur(numCompteur, creationTxt)
/// \brief Afficher en console les informations du compteur (nom, numéro, config, jour,  date et heures du relevé
/// \param [in] numCompteur     \c string  Numéro du compteur
/// \param [in] CreationTxt     \c tabString(3)     Tableau de date et heures de création
/// \param [in optionnel] texteConfig  \c string   Configuration du compteur
//*****************************************************************************
function info_compteur(stcReleve)
    printf("Compteur ''%s'' n°%s, configuré en %s\n", ...
            stcReleve.residence, stcReleve.numCompteur,...
            stcReleve.config);

    printf("Relevé créé le %s %s de %s à %s\n\n", ...
            stcReleve.jour, stcReleve.date, stcReleve.heureDebut, ...
            stcReleve.heureFin);
endfunction
