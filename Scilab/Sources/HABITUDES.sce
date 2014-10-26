//*****************************
/// \author Sébastien Lemoine
/// \date Mai 2014
/// \brief Etude des habitudes, supperpose des courbes sur un même graphique
/// \version 1.0
//******************************

clear;
close;
clc;

// DEBUG = 1 : Activer les traces pour le débug
DEBUG = 0;
//pause   // Continuer en saisissant "resume" en console

//*** Chargement de l'environnement *******************************************
// Répertoires par défaut
// Chemin du répertoire courant, repertoire parent du projet Scilab
fnctPath = pwd();
// Chemin du répertoire parent du projet Compteur Electronique
projectPath = strncpy(fnctPath,length(fnctPath)-length("\Scilab\Sources"));
// Chemin du répertoire où lire les fichiers .sod
dataPath = projectPath + "\Releves\Variables";
// Charger les fonctions de calculs
exec(fnctPath+"\Calculs.sci");
// Charger les fonctions pour tracer les graphiques
exec(fnctPath+"\Tracer_Graph.sci");


//*** Début du programme *******************************************************
printf("*************************************************************\n");
printf("Programme pour étudier des points communs sur les relevés\n");
printf("Choisir le nombre de relevé à charger puis les sélectionner\n");
printf("*************************************************************\n\n");

// Initialisation
Papp = 1;
nmbr_courbes = -1;
nmbrFichierReels = 0;
erreur = 0;

while(nmbr_courbes <> 0) do
    temp_txt = ['Choisir le nombre de courbes à charger';...
                'Annuler pour quitter'];
    nmbr_courbes = evstr(x_mdialog(temp_txt, 'Nombre de courbes (8 max)','1'));
    clear temp_txt

    if nmbr_courbes > 8 then
        erreur = 2;
    
    // Importer les différents relevés
    elseif nmbr_courbes > 0 then
        for nmbr_fichier = 1:nmbr_courbes
            // Importer les tableaux Gbl_Heure, Gbl_Papp et Gbl_CreationTxt
            txt = msprintf('%s %d\n', ...
                'Choisir le fichier à ouvrir n°',nmbr_fichier);
            printf("%s\n", txt);
            cheminFichier = uigetfile(["*.sod"], dataPath, txt, %f);
               
            // Si un fichier est bien sélectionné
            if (cheminFichier ~= "") then
                nmbrFichierReels = nmbrFichierReels +1;
                nomFichier = part(cheminFichier, ...
                             (length(dataPath)+2):length(cheminFichier));
                printf("Import du fichier %s \n", nomFichier);
                load(cheminFichier);
                
                // Sauvegarde des variables dans Heure, Papp et Jour
                if nmbrFichierReels == 1 then
                    Heure(:,1) = Gbl_Heure;
                    printf("Compteur n°%s : %s\n", ...
                            Gbl_NumCompteur, nom_compteur(Gbl_NumCompteur));
                end

                //Ajustement des matrices
                if DEBUG == 1 then
                    printf("DEBUG \t Longueur de Gbl_Papp = %d\n", ...
                    dimensions(Gbl_Papp, "ligne"));
                end
                
                if dimensions(Papp, "ligne") <> dimensions(Gbl_Papp, "ligne") then
                    Papp(1:dimensions(Gbl_Heure, "ligne")+1, ...
                        nmbrFichierReels) = Gbl_Papp(:,1);
                    Papp(dimensions(Gbl_Heure, "ligne")+2:...
                        dimensions(Heure, "ligne"),nmbrFichierReels) = 0;
                else
                    Papp(:,nmbrFichierReels) = Gbl_Papp;
                end
                
                Jour(1,nmbrFichierReels) = Gbl_CreationTxt(4);
                Jour(2,nmbrFichierReels) = Gbl_CreationTxt(1);

            else
                printf("!!  Erreur - Aucun fichier sélectionné\n");
            end
         end
        
        // Tracer les courbes supperposées
        if (nmbr_fichier == nmbr_courbes & nmbrFichierReels <> 0) then
            printf("Tracé en cours ...\n");
            tracer_D_Graph(Papp, Jour, Heure);   // attention, nombre limité
            nmbr_courbes = 0;
        end

    // Aucune courbe à importer
    else
        erreur = 1;
    end

    // Affichage des erreurs
    if erreur <> 0 then
        nmbr_courbes = 0;
    end
    
    if erreur == 1 then
        printf("!!  Erreur - Aucune courbe à importer\n");
    elseif erreur == 2 then
        printf("!!  Erreur - Importer 8 courbes au maximum\n");
    end
    
    printf("Fin du programme \n");
end
