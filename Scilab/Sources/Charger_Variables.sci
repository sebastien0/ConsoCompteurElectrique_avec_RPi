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
        printf("Chargement du fichier %s \n", cheminFichier);
        load(cheminFichier);

        // Configuration du compteur
        if (Gbl_Config(1) == 0 | Gbl_Config(2) == 0) then
            if Gbl_Config(1) == 0 then
                Config = 1;
                printf("Compteur configuré en Base\n");
            elseif Gbl_Config(2) == 0 then
                Config = 2;
                printf("Compteur configuré en HCHP\n");
            end
            
            printf("Relevé créé le %s %s de %s à %s par le compteur n°%s\n\n", ...
            Gbl_CreationTxt(4),Gbl_CreationTxt(1), Gbl_CreationTxt(2), ...
            Gbl_CreationTxt(3), Gbl_NumCompteur);
            
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
