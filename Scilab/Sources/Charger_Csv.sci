//*****************************
/// \author Sébastien Lemoine
/// \date Novembre 2014
/// \brief Fonctions pour importer un fichier .csv
//******************************

//****************************************************************************
/// \fn erreur = Importer_Csv(dataPath2Read, isDEBUG)
/// \brief Importe les données depuis un fichier .csv
/// \param [in] dataPath2Read    \c string  Chemin d'accès au répertoire où lire les fichiers .txt
/// \param [in] isDEBUG   \c Booléen   Passer en mode DEBUG (+ d'info console)
/// \param [out] stcReleve   \c structure   Relevé, si fichier sélectionné
/// \param [out] stcStatistiques    \c structure     Statistiques, si fichier sélectionné
/// \return erreur     \c Booléen     %t si pas de fichier sélectionné
/// \todo A finir de développer
//****************************************************************************
function erreur = Importer_Csv(dataPath2Read, isDEBUG)
    erreur = %t;    //Pas de fichier sélectionné
//    printf("Erreur! \t Fonction non implementee pour le moment.\n");

    caractereAChercher = ascii(";"); //Valeur en décimale, utiliser ascii()
    // Selection du fichier à traiter
    cheminFichier = uigetfile(["*.csv"],dataPath2Read, ...
    "Choisir le fichier à ouvrir", %f);

     // Fichier sélectionné
    if (cheminFichier ~= "") then
        tic;
        // Initialisation des variables
        erreur = %f;
        cptLigneErreur = 0;
        fichierOuvert = 1;
        tempsExecution = 0;
        progression = 0;
        tempsRestant = 0;
        tempsRestant_1 = 0;
        lignesEnTete = 4;
        ligneOffset = 3;
        
        stcStatistiques = struct('nomPC', "Seb");  // Nom du PC servant à l'importation
        
        // ****** Ouverture Fichier *****
        posiCaract = LocaliserCaractere(cheminFichier,ascii('\'), %t);
        nomFichier = part(cheminFichier,posiCaract(1)+1:posiCaract(dimensions(posiCaract,"ligne")));
        printf("Ouverture du fichier ''%s'' \n", nomFichier);
        BarreProgression = progressionbar('Import en cours: Calcul du temps restant...');
        fichier = mopen(cheminFichier,'r'); // Ouverture du fichier
        donnee = mgetl(cheminFichier);  // Lecture du fichier
        mclose(cheminFichier);  // Fermeture du fichier


        // *** Extraction des données *****************************************
        printf("Extraction et mise en forme des données ...\n");
        stcReleve = struct('nbrLignes', dimensions(donnee,"ligne")-4);  //Jusqu'à la fin des données
        dernLigne = stcReleve.nbrLignes + ligneOffset;
        ligneImax = dernLigne+1;
        
        // ***** En-tête et pied de fichier *****
        //Date et Heure du relevé
        // Date et heure de l'importation
        tempDate = getdate();
        stcStatistiques.dateImportation = strcat([string(tempDate(1)), '/', ...
           nombre_2_Chiffres(tempDate(2)), '/', nombre_2_Chiffres(tempDate(6))]);
        stcStatistiques.heureImportation = strcat([nombre_2_Chiffres(tempDate(7)), ':', ...
           nombre_2_Chiffres(tempDate(8)), ':', nombre_2_Chiffres(tempDate(9))]);
        // Numéro du compteur
        posiCaract = LocaliserCaractere(donnee(2),caractereAChercher);
        stcReleve.numCompteur = part(donnee(2),posiCaract(1)+1:posiCaract(2)-1);
        stcReleve.residence = nom_compteur(stcReleve.numCompteur);
        // Courant souscrit
        stcReleve.iSouscr = evstr(part(donnee(2),posiCaract(3)+1:posiCaract(4)));
        
        // Date et heures du relevé
        posiCaract = LocaliserCaractere(donnee(1),caractereAChercher);
        stcReleve.date = part(donnee(1),posiCaract(1)+1:posiCaract(2));
        tempDate = datenum(evstr(part(stcReleve.date,1:4)), ...
                           evstr(part(stcReleve.date,6:7)), ...
                           evstr(part(stcReleve.date,9:10)));
        [N, stcReleve.jour] = weekday(tempDate,'long');
        
        posiCaract = LocaliserCaractere(donnee(4),caractereAChercher);
        stcReleve.heureDebut = part(donnee(4),1:posiCaract(1)-1);

        posiCaract = LocaliserCaractere(donnee(dernLigne),caractereAChercher);
        stcReleve.heureFin = part(donnee(dernLigne),1:posiCaract(1)-1);
        clear tempDate;


        // ***** Détection de la configuration *****
        posiCaract = LocaliserCaractere(donnee(ligneOffset),caractereAChercher);
        tmpConfig = part(donnee(ligneOffset), ...
                        posiCaract(2)+1:posiCaract(ligneOffset));
        if tmpConfig == "Base" then
            stcReleve.config = "Base";
            stcReleve.isConfigBase = %t;
            stcReleve.isConfigHCHP = %f;
        /// \todo Gérer la synthaxe HCHP
        elseif tmpConfig == "H cr" then
            stcReleve.config = "HCHP";
            stcReleve.isConfigBase = %f;
            stcReleve.isConfigHCHP = %t;
        else
            stcReleve.isConfigBase = %f;
            stcReleve.isConfigHCHP = %f;
        end
        
        // Affichage en console des info du compteur
        info_compteur(stcReleve);
        printf("Import en cours, soyez patient ...\n");
        
        // Structure pour les statistique d'importation
        stcStatistiques.numCompteur = stcReleve.numCompteur;
        stcStatistiques.config = stcReleve.config;
        stcStatistiques.date = stcReleve.date;
        stcStatistiques.heure = stcReleve.heureDebut;
        stcStatistiques.nbrLignes = stcReleve.nbrLignes;
        stcStatistiques.tempsTotal = 0;
        stcStatistiques.tabTempsRestant(1) = 0;

        // ***** Indentation du tableau *****
        tmpPosiTab = LocaliserCaractere(donnee(lignesEnTete),caractereAChercher);
        // Positions des valeurs
        stcPosiTab = struct("heureFin",tmpPosiTab(1)-1);
        stcPosiTab.pappDebut = tmpPosiTab(1)+1;
        stcPosiTab.pappFin = tmpPosiTab(2)-1;
        if stcReleve.isConfigBase then  // Base
            stcPosiTab.indexDebut = tmpPosiTab(2)+1;
            stcPosiTab.indexFin = tmpPosiTab(3);
        elseif stcReleve.isConfigHCHP then  // HCHP
            stcPosiTab.HCDebut = tmpPosiTab(2)-1;
            stcPosiTab.HCFin = tmpPosiTab(3)-1;
            stcPosiTab.HPDebut = tmpPosiTab(3)-1;
            stcPosiTab.indexFin = tmpPosiTab(4);
        end
        
        // Recherche d'une combinaison optimale de "progression" et "centiemeMax"
        // pour avoir un nombre d'itération >=90 et < 99
        // Cela permet de mettre à jour la barre d'avancement à chaque pourcent
        stcStatistiques.nbBoucleCentDenum = 0;
        denominateur = 100;
        centiemeMax = floor(stcReleve.nbrLignes/denominateur);
        while (centiemeMax <= 94 | centiemeMax > 99) do
            if (centiemeMax < 99) then
                denominateur = ceil(denominateur /2);
                centiemeMax = floor(stcReleve.nbrLignes/denominateur);
                if (centiemeMax > 99) then
                    denominateur = ceil(denominateur *1.5);
                    centiemeMax = floor(stcReleve.nbrLignes/denominateur);
                end
            else
                denominateur = ceil(denominateur *10);
                centiemeMax = floor(stcReleve.nbrLignes/denominateur);
            end
            stcStatistiques.nbBoucleCentDenum = stcStatistiques.nbBoucleCentDenum +1;
        end
        
        stcStatistiques.tempsIntermediaire = toc();
        tic();
        stcReleve.papp = zeros(stcReleve.nbrLignes,1);
        stcReleve.heure(stcReleve.nbrLignes) = "";
        
        // ****************
        // ***** Base *****
        // ****************
        if stcReleve.isConfigBase then
            stcReleve.index = zeros(stcReleve.nbrLignes,1);
            // ***** Index énergies à t0 *****
            Indexer_Trame_Base (donnee(lignesEnTete), stcPosiTab);
            stcReleve.index0 = evstr(tmpReleve(3));
            
            // ***** Extraction des points *****
            // Rafraichissement de l'avancement tous les %
            // Pour un nombre de lignes entier
            for centieme = 1: (centiemeMax-1)
                for ligne = ((centieme-1)*denominateur+lignesEnTete) : ...
                            (centieme*denominateur+lignesEnTete-1)
                    try
                        Indexer_Trame_Base (donnee(ligne), stcPosiTab);
                        stcReleve.heure(ligne-ligneOffset) = tmpReleve(1);
                        stcReleve.papp(ligne-ligneOffset) = evstr(tmpReleve(2));
                        tmpEnergie = evstr(tmpReleve(3));
                        if (tmpEnergie == [] | tmpEnergie == 1 ) then
                            stcReleve.index(ligne-ligneOffset) = ...
                                                stcReleve.index(ligne-4);
                        else
                            stcReleve.index(ligne-ligneOffset) = ...
                                                tmpEnergie - stcReleve.index0;
                        end
                        cptLigneErreur = 0; // RAZ du compteur d'erreur successives
                    catch
                        /// \todo le passer en fonction pour le mutualiser à toutes les boucles for
                        printf("Attention! \t Ligne n°%i mal interpretee\n",...
                                ligne+lignesEnTete);
                            // Recopier les valeurs précédentes
                            // Incrémenter d'une seconde
                            ligne = Gerer_Trame_Invalide(stcReleve, cptLigneErreur, ligne, dernLigne);
                    end
                end
                barre_Progression(stcStatistiques, ligne, progression);
                sleep(5);  // Pause de 5ms
            end
            
            // Nombre de lignes restantes
            for ligne = ligne : dernLigne
                Indexer_Trame_Base (donnee(ligne), stcPosiTab);
                stcReleve.heure(ligne-ligneOffset) = tmpReleve(1);
                stcReleve.papp(ligne-ligneOffset) = evstr(tmpReleve(2));
                tmpEnergie = evstr(tmpReleve(3));
                if (tmpEnergie == [] | tmpEnergie == 1) then
                    stcReleve.index(ligne-ligneOffset) = ...
                                        stcReleve.index(ligne-6);
                else
                    stcReleve.index(ligne-ligneOffset) = ...
                                        tmpEnergie - stcReleve.index0;
                end
            end
            barre_Progression(stcStatistiques, ligne, progression);
        end
        
        // ****************
        // ***** HCHP *****
        // ****************
        
        
        // Puissance moyenne et IMAX
        stcReleve.pappMoy = mean(stcReleve.papp);
        try
            posiCaract = LocaliserCaractere(donnee(ligneImax),caractereAChercher);
            stcReleve.iMax = evstr(part(donnee(ligneImax), ...
                                        posiCaract(3):posiCaract(4)));
        catch
            stcReleve.iMax = 0;
            printf("Pied de fichier manquant, IMAX non trouvé\n");
        end
        
        stcStatistiques.tempsTotal = toc() + stcStatistiques.tempsIntermediaire;
        close(BarreProgression);
        
        // ***** Retourne *****
        [stcReleve, stcStatistiques] = resume(stcReleve, stcStatistiques);
    end
endfunction
