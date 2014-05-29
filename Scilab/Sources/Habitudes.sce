//********************
// Etude des habitudes
//*******************
clear;
close;
clc;

// DEBUG = 1 : Activer les traces pour le débug
DEBUG = 0;

//*** Chargement de l'environnement *******************************************
// Répertoires par défaut
/// Chemin du répertoire courant, repertoire parent du projet Scilab
fnctPath = pwd();
/// Chemin du répertoire parent du projet Compteur Electronique
projectPath = strncpy(fnctPath,length(fnctPath)-length("\Scilab\Sources"));
/// Chemin du répertoire où lire les fichiers .sod
dataPath = projectPath + "\Code\Compteur_Linky\Releves\Variables";
// Charger les fonctions de calculs
exec(fnctPath+"\Calculs.sci");
// Charger les fonctions pour tracer les graphiques
exec(fnctPath+"\Tracer_Graph.sci");


//*** Début du programme *******************************************************
printf("*************************************************************\n");
printf("Programme pour étudier des points communs sur les relevés\n");
printf("Choisir le nombre de relevé à charger puis les sélectionner\n");
printf("*************************************************************\n\n");

nmbr_courbes = -1;
nmbrFichierReels = 0;
erreur = 0;
while(nmbr_courbes <> 0) do
    temp_txt = ['Choisir le nombre de courbes à charger (8 max)';...
                'Annuler pour quitter'];
    nmbr_courbes = evstr(x_mdialog(temp_txt, 'Nombre de courbes','1'));
    clear temp_txt

    if nmbr_courbes >= 8 then
        erreur = 2;
    elseif nmbr_courbes > 0 then
        // Initialisation
//        Papp = ones(1,nmbr_courbes);
        Papp = 1;
        
        for nmbr_fichier = 1:nmbr_courbes
            // Importer les tableaux Gbl_Heure, Gbl_Papp et Gbl_CreationTxt
            txt = msprintf('%s %d\n', ...
                'Choisir le fichier à ouvrir n°',nmbr_fichier);
            printf("%s\n", txt);    //TODO renseigner le nom et non le chemin
            cheminFichier = uigetfile(["*.sod"], dataPath, txt, %f);
                
            // Si un fichier est bien sélectionné
            if (cheminFichier ~= "") then
                nmbrFichierReels = nmbrFichierReels +1;
                printf("Import du fichier %s \n", cheminFichier);
                load(cheminFichier);
                
                // Sauvegarde des variables dans Heure, Papp et Jour
                if nmbrFichierReels == 1 then
                    Heure(:,1) = Gbl_Heure;
                end
                //Ajustement des matrices
                if DEBUG == 1 then
                    printf("DEBUG \t Longueur de Gbl_Papp = %d\n", ...
                    longueur(Gbl_Papp));
                end
                
                if longueur(Papp) <> longueur(Gbl_Papp) then
                    Papp(1:longueur(Gbl_Heure)+1,nmbrFichierReels) = Gbl_Papp(:,1);
                    Papp(longueur(Gbl_Heure)+2:longueur(Heure),nmbrFichierReels) = 0;
                else
                    Papp(:,nmbrFichierReels) = Gbl_Papp;
                end
                
                Jour(1,nmbrFichierReels) = Gbl_CreationTxt(4);
                Jour(2,nmbrFichierReels) = Gbl_CreationTxt(1);

            else
                printf("!!  Erreur - Aucun fichier sélectionné\n");
            end
         end
            
        if (nmbr_fichier == nmbr_courbes & nmbrFichierReels <> 0) then
            // Tracer des courbes, avec une couleur différentes
            // TODO: Reprendre l'affichage lors 8 > taille écran
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
