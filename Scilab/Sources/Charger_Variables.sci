//*****************************
/// \file Charger_Variables.sci
/// \author Sébastien Lemoine
/// \date Avril 2014
/// \brief Fonctions pour importer un fichier binaire .sod
//******************************

//****************************************************************************
/// \fn erreur = charger_variables(dataPath2Save)
/// \brief Charger les variables dans l'environnement depuis un fichier .sod
/// \param [in] dataPath2Save string Chemin d'accès au répertoire où lire les fichiers .sod
/// \return stcReleve      \c Structure     Structure du relevé
/// \return stcStatistiques   \c Structure  Structure de statistiques
//*****************************************************************************
function erreur = charger_variables(dataPath2Save)
    cheminFichier = uigetfile(["*.sod"],dataPath2Save,...
     "Choisir le fichier à ouvrir", %f);
        
    // Si un fichier est bien sélectionné
    if (cheminFichier ~= "") then
        nomFichier = part(cheminFichier, ...
                     (length(dataPath2Save)+2):length(cheminFichier));
        printf("Chargement du fichier %s \n", nomFichier);
        load(cheminFichier);

        // Configuration du compteur
        if (stcReleve.isConfigBase | stcReleve.isConfigHCHP) then
            erreur = %f;

            // Affichage en console des info du compteur
            info_compteur(stcReleve);
            
            [stcReleve, stcStatistiques] = resume (stcReleve, stcStatistiques);
        else
            erreur = %t;
            printf("Configuration du compteur non reconnue\n");
        end
    else
        erreur = %t;
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
