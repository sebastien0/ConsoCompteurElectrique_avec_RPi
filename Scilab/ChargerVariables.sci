//* ***************************************************************************
//* Charger les variables dans l'environnement depuis un fichier .sod
//*
//*
//*****************************************************************************
function Config = charger_variables(dataPath2Save)
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
            
            printf("\nRelevé créé le %s de %s à %s par le compteur n°%s\n", ...
        Gbl_CreationTxt(1), Gbl_CreationTxt(2), Gbl_CreationTxt(3), Gbl_NumCompteur);
        else
            Config = 0;
            printf("Configuration du compteur non reconnue\n");
        end
    else
        printf("Aucun fichier sélectionné\n");
    end
endfunction
