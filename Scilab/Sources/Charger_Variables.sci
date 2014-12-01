//*****************************
/// \author Sébastien Lemoine
/// \date Avril 2014
/// \brief Fonctions pour importer un fichier binaire .sod
//******************************

//****************************************************************************
/// \fn erreur = charger_variables(dataPath2Save)
/// \brief Charger les variables dans l'environnement depuis un fichier .sod
/// \param [in] dataPath2Save \c string Chemin d'accès où lire les fichiers .sod
/// \return erreur  \c Booléen  %t si aucun fichier sélectionné ou config non connue
/// \param [out] stcReleve      \c Structure     Relevé
/// \param [out] stcStatistiques   \c Structure  Statistiques
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
    
        // Si relevé composé de structure (pas de retrocompatibilité)
        if exists('stcReleve') == 1  then
            // Configuration du compteur
            if (stcReleve.isConfigBase | stcReleve.isConfigHCHP) then
                erreur = %f;
    
                // Affichage en console des info du compteur
                info_compteur(stcReleve);
                
                [stcReleve, stcStatistiques] = resume (stcReleve, stcStatistiques);
            else
                erreur = %t;
                printf("Erreur! \t Configuration du compteur non reconnue\n");
            end
        else
            printf("Erreur! \t Ancien format de données, importer le fichier csv ou texte pour le convertir automatiquement\n");
        end
    else
        erreur = %t;
        printf("Erreur! \t Aucun fichier sélectionné\n");
    end
endfunction


//****************************************************************************
/// \fn info_compteur(stcReleve)
/// \brief Afficher en console les informations du compteur (nom, numéro, config, jour,  date et heures du relevé
/// \param [in] stcReleve     \c Structure  Relevé
//*****************************************************************************
function info_compteur(stcReleve)
    printf("Compteur ''%s'' n°%s, configuré en %s\n", ...
            stcReleve.residence, stcReleve.numCompteur,...
            stcReleve.config);

    printf("Relevé créé le %s %s de %s à %s\n\n", ...
            stcReleve.jour, stcReleve.date, stcReleve.heureDebut, ...
            stcReleve.heureFin);
endfunction
