//*****************************
/// \author Sébastien Lemoine
/// \date Avril 2014
/// \brief Fonctions pour importer un fichier .txt
/// Importation matricielle (<> line par ligne) => Gain de temps considérable
//******************************


//****************************************************************************
/// \fn erreur = Importer_Txt(dataPath2Read, isDEBUG)
/// \brief Importe les données depuis un fichier .txt
/// \param [in] dataPath2Read    \c string  Chemin d'accès au répertoire où lire les fichiers .txt
/// \param [in] isDEBUG   \c Booléen   Passer en mode DEBUG (+ d'info console)
/// \param [out] stcReleve   \c structure   Relevé, si fichier sélectionné
/// \param [out] stcStatistiques    \c structure     Statistiques, si fichier sélectionné
/// \return erreur     \c Booléen     %t si pas de fichier sélectionné
//****************************************************************************
function erreur = Importer_Txt(dataPath2Read, isDEBUG)
    erreur = %t;    //Pas de fichier sélectionné
    caractereAChercher = 9; //Tabulation, valeur en décimale, utiliser ascii()
    // Selection du fichier à traiter
    cheminFichier = uigetfile(["*.txt"],dataPath2Read, ...
    "Choisir le fichier à ouvrir", %f);

    // Fichier sélectionné
    if (cheminFichier ~= "") then
        tic;
        // Initialisation des variables
        erreur = %f;
        MAXERREURLIGNE = 10;    // Tolérence aux lignes incorrectes
        fichierOuvert = 1;
        tempsExecution = 0;
        progression = 0;
        tempsRestant = 0;
        tempsRestant_1 = 0;
        lignesEnTete = 6;
        stcPosiTab = struct("lignesEnTete", lignesEnTete);
        
        stcStatistiques = struct('nomPC', "Seb");  // Nom de PC servant à l'importation
        
        // ****** Ouverture Fichier *****
        nomFichier = part(cheminFichier, ...
                     (length(dataPath2Read)+2):length(cheminFichier));
        printf("Ouverture du fichier ''%s'' \n", nomFichier);
        BarreProgression = progressionbar('Import en cours: Calcul du temps restant...');
        fichier = mopen(cheminFichier,'r'); // Ouverture du fichier
        donnee = mgetl(cheminFichier);  // Lecture du fichier
        mclose(cheminFichier);  // Fermeture du fichier


        // *** Extraction des données *****************************************
        printf("Extraction et mise en forme des données ...\n");
        stcReleve = struct("nbrLignes", dimensions(donnee,"ligne")-6);  //Jusqu'à la fin des données

// Modif du 10/11 suite au relevé Lyon\Releve_2013-11-06.txt
//        dernLigne = stcReleve.nbrLignes + 5;
//        ligneImax = dernLigne+1;
        stcPosiTab.dernLigne = stcReleve.nbrLignes + 4;
        ligneImax = stcPosiTab.dernLigne+2;
        
        // ***** En-tête et pied de fichier *****
        //Date et Heure du relevé
        // Date et heure de l'importation
        tempDate = getdate();
        stcStatistiques.dateImportation = strcat([string(tempDate(1)), '/', ...
           nombre_2_Chiffres(tempDate(2)), '/', nombre_2_Chiffres(tempDate(6))]);
        stcStatistiques.heureImportation = strcat([nombre_2_Chiffres(tempDate(7)), ':', ...
           nombre_2_Chiffres(tempDate(8)), ':', nombre_2_Chiffres(tempDate(9))]);
        // Numéro du compteur
        temp = msscanf(donnee(3),'%s n°%s');
        stcReleve.numCompteur = temp(2);
        stcReleve.residence = nom_compteur(stcReleve.numCompteur);
        // Date et heures du relevé
        temp = msscanf(donnee(1),'%s %s %s %s');
        tempDate = datenum(strtod(part(temp(3),1:4)), ...
                           strtod(part(temp(3),6:7)), ...
                           strtod(part(temp(3),9:10)));
        [N, stcReleve.jour] = weekday(tempDate,'long');
        stcReleve.date = strcat([part(temp(3),1:4), '/', part(temp(3),6:7), ...
                                '/', part(temp(3),9:10)]);
        temp = msscanf(donnee(6),'%s %s %s %s');
        stcReleve.heureDebut = temp(1);

        temp = msscanf(donnee(stcPosiTab.dernLigne),'%s %s %s %s');
        stcReleve.heureFin = temp(1);
        clear temp;
        clear tempDate;
        

        // ***** Détection de la configuration *****
        posiCaract = LocaliserCaractere(donnee(5),caractereAChercher);
        tmpConfig = part(donnee(5),posiCaract(3)+2:posiCaract(3)+5);
        if tmpConfig == "Base" then
            stcReleve.config = "Base";
            stcReleve.isConfigBase = %t;
            stcReleve.isConfigHCHP = %f;
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
        tmpPosiTab = LocaliserCaractere(donnee(stcPosiTab.lignesEnTete),caractereAChercher);
        // Positions des valeurs
        stcPosiTab.heureFin = tmpPosiTab(1)-2;
        stcPosiTab.pappDebut = tmpPosiTab(1)+2;
        stcPosiTab.pappFin = tmpPosiTab(2)-2;
        if stcReleve.isConfigBase then  // Base
            stcPosiTab.indexDebut = tmpPosiTab(2)+2;
            stcPosiTab.indexFin = tmpPosiTab(3);
        elseif stcReleve.isConfigHCHP then  // HCHP
            stcPosiTab.HCDebut = tmpPosiTab(2)+2;
            stcPosiTab.HCFin = tmpPosiTab(3)-2;
            stcPosiTab.HPDebut = tmpPosiTab(3)+2;
            // Si colonne invalide remplie
            if size(tmpPosiTab,1) == 4 then
                stcPosiTab.indexFin = tmpPosiTab(4);
            else
                stcPosiTab.indexFin = tmpPosiTab(4)-2;
            end
        end

        stcPosiTab.nbrIteration = floor(stcReleve.nbrLignes/99);

        stcReleve.papp = zeros(stcReleve.nbrLignes,1);
        stcReleve.heure(stcReleve.nbrLignes) = "";


        // ********************************
        // *********** Base ***************
        // ********************************
        if stcReleve.isConfigBase then
            stcReleve.index = zeros(stcReleve.nbrLignes,1);
            // ***** Index énergies à t0 *****
            Indexer_Trame_Base (donnee(lignesEnTete), stcPosiTab);
            stcReleve.index0 = strtod(tmpReleve(3));
        
            // ***** Extraction des points *****
            // Rafraichissement de l'avancement tous les %
            for indexLigne = 1 : 99
                stcPosiTab.indexLigne = indexLigne;
                erreur = indexerPartie(donnee, stcPosiTab, stcReleve);
                // Terminer la fonction
                if erreur then
                    printf("ERREUR \t Fin de l''indexation\n");
                    return;
                end
                barre_Progression(stcStatistiques, ...
                            stcPosiTab.nbrIteration*indexLigne, progression);
                sleep(5);  // Pause de 5ms
            end
            // Nombre de lignes restantes
            erreur = indexerPartie(donnee, stcPosiTab, stcReleve, ...
                    stcPosiTab.nbrIteration*indexLigne, stcPosiTab.dernLigne-5);
            // Terminer la fonction
            if erreur then
                printf("ERREUR \t Fin de l''indexation\n");
                return;
            end
            barre_Progression(stcStatistiques, stcPosiTab.dernLigne, progression);


            // Mise en forme de l'index
            cptLigneErreur = normaliser_index(stcReleve.index, ...
                            stcReleve.index0, MAXERREURLIGNE);
            stcReleve.index(:,1) = index;
            //Signaler trop d'erreur consécutives
            if cptLigneErreur > MAXERREURLIGNE then
                printf("ATTENTION \t Trop d''erreurs consecutives sur l''energie (%i)\n",cptLigneErreur);
            end

        // ********************************
        // *********** HCHP ***************
        // ********************************
        elseif stcReleve.isConfigHCHP then
            stcReleve.index = zeros(stcReleve.nbrLignes,2);
            // ***** Index énergies à t0 *****
            Indexer_Trame_HCHP (donnee(lignesEnTete), stcPosiTab);
            stcReleve.index0(1) = evstr(tmpReleve(3));
            stcReleve.index0(1,2) = evstr(tmpReleve(4));
            tempIndex0 = stcReleve.index0;

            // ***** Extraction des points *****
            // Rafraichissement de l'avancement tous les %
            for indexLigne = 1 : 99
                stcPosiTab.indexLigne = indexLigne;
                erreur = indexerPartie(donnee, stcPosiTab, stcReleve);
                // Terminer la fonction
                if erreur then
                    printf("ERREUR \t Fin de l''indexation\n");
                    return;
                end
                barre_Progression(stcStatistiques, ...
                            stcPosiTab.nbrIteration*indexLigne, progression);
                sleep(5);  // Pause de 5ms
            end
            // Nombre de lignes restantes
            erreur = indexerPartie(donnee, stcPosiTab, stcReleve, ...
                    stcPosiTab.nbrIteration*indexLigne, stcPosiTab.dernLigne-3);
            // Terminer la fonction
            if erreur then
                printf("ERREUR \t Fin de l''indexation\n");
                return;
            end
            barre_Progression(stcStatistiques, stcPosiTab.dernLigne, progression);


            // Mise en forme des index
            cptLigneErreur(1) = normaliser_index(stcReleve.index(:,1), ...
                                stcReleve.index0(1), MAXERREURLIGNE);
            stcReleve.index(:,1) = index;
            cptLigneErreur(2) = normaliser_index(stcReleve.index(:,2), ...
                                stcReleve.index0(2), MAXERREURLIGNE);
            stcReleve.index(:,2) = index;
            // Signaler trop d'erreur consécutives
            if cptLigneErreur > MAXERREURLIGNE then
                printf("ATTENTION \t Trop d''erreurs consecutives sur l''energie (%i)\n",cptLigneErreur);
            end
        end

        // ********************************
        // *********** COMMUN *************
        // ********************************
        // Calcul puissance moyenne et recomposition puissance
        stcReleve.pappMoy = mean(stcReleve.papp);
        if isnan(stcReleve.pappMoy) then
            if stcReleve.isConfigHCHP then
                printf("Puissance absente, recalcul en cours a partir de l''energie...\n");
                Puissance_HCHP(stcReleve);
            else
                printf("Erreur dans la puissance, tentative de réparation en cours...\n");
                for index = 2 : stcReleve.nbrLignes
                    if isnan(stcReleve.papp(index)) then
                        stcReleve.papp(index) = stcReleve.papp(index-1);
                    end
                end
            end
            stcReleve.pappMoy = mean(stcReleve.papp);
        end

        // Extraction IMAX
        try
            posiCaract = LocaliserCaractere(donnee(ligneImax),caractereAChercher);
            stcReleve.iMax = evstr(part(donnee(ligneImax), ...
                                        posiCaract(3):length(donnee(ligneImax))));
        catch
            stcReleve.iMax = 0;
            printf("Pied de fichier manquant, IMAX non trouvé\n");
        end
        
        stcStatistiques.tempsTotal = toc();
        close(BarreProgression);

        // ***** Retourne *****
        [stcReleve, stcStatistiques] = resume(stcReleve, stcStatistiques);
    end
endfunction


//****************************************************************************
/// \fn cptLigneErreur = normaliser_index(index, index0, MAXERREURLIGNE)
/// \brief Soustraire index0 à index avec une gestion des valeurs nulles, 
/// négatives ou Not A Number (NAN)
/// \param [in] index   \c tabDouble    tableau d'énergie
/// \param [in] index0  \c double   Energie initiale
/// \param [in] MAXERREURLIGNE  \c double   Nombre d'erreurs successives maximale
/// \param [out] index  \c tabDouble   Tableau d'énergie normalisé
/// \return cptLigneErreur  \c double   Nombre d'erreurs successives rencontré
//*****************************************************************************
function cptLigneErreur = normaliser_index(index, index0, MAXERREURLIGNE)
    cptLigneErreur = 0;

    for ligne = 1 : size(index,1)
        // Si Not A Number alors valeur précédente
        if isnan(index(ligne)) then
            index(ligne) = index(ligne-1);
        else
            // Normalisation sur la journée
            index(ligne) = index(ligne) - index0;
            if index(ligne) < 0 then
                index(ligne) = index(ligne-1);
                // Comptabiliser le nombre d'erreur consécutives
                cptLigneErreur = cptLigneErreur +1;
            elseif cptLigneErreur < MAXERREURLIGNE then
                cptLigneErreur = 0;
            end
        end
    end

    [index] = resume(index);
endfunction


//****************************************************************************
/// \fn erreur = indexerPartie(donnee, stcPosiTab, stcReleve, opt_ligneDeb, opt_ligneFin)
/// \brief Indexer donnee de manière matricielleet partielle. Les bornes sont 
/// définies par opt_ligneDeb et opt_ligneFin ou calculée à partir de stcPosiTab
/// \param [in] donnee  \c tabString    Contenu du fichier texte
/// \param [in] stcPosiTab  \c  Structure Position des valeurs 
/// \param [in] stcReleve   \c  Structure Relevé
/// \param [in optionnel]   opt_ligneDeb    \c double   Ligne de début; obligatoirement utilisé avec opt_ligneFin
/// \param [in optionnel]   opt_ligneFin    \c double ligne de fin; obligatoirement utilisé avec opt_ligneDeb
/// \param [out] stcReleve  \c  Structure   Relevé
/// \return erreur  \c Booléen %t si erreur dans l'interprétation des lignes
//*****************************************************************************
function erreur = indexerPartie(donnee, stcPosiTab, stcReleve, opt_ligneDeb, opt_ligneFin)
    if argn(2) == 3 then
        ligneDeb = (stcPosiTab.indexLigne-1)*stcPosiTab.nbrIteration + ...
                stcPosiTab.lignesEnTete -5;
        ligneFin = stcPosiTab.indexLigne*stcPosiTab.nbrIteration + ...
                stcPosiTab.lignesEnTete - 6;
    else
        ligneDeb = opt_ligneDeb;
        ligneFin = opt_ligneFin;
    end
    
    try
        if stcReleve.isConfigBase then
            Indexer_Trame_Base (donnee(ligneDeb+5:ligneFin+5), stcPosiTab);
            stcReleve.index(ligneDeb:ligneFin) = strtod(tmpReleve(:,3));

        elseif stcReleve.isConfigHCHP then
            Indexer_Trame_HCHP (donnee(ligneDeb+5:ligneFin+5), stcPosiTab);
            stcReleve.index(ligneDeb:ligneFin,1) = strtod(tmpReleve(:,3));
            stcReleve.index(ligneDeb:ligneFin,2) = strtod(tmpReleve(:,4));
        end

        stcReleve.heure(ligneDeb:ligneFin) = tmpReleve(:,1);
        stcReleve.papp(ligneDeb:ligneFin) = strtod(tmpReleve(:,2));
    catch
        printf("ERREUR \t Lignes entre %i et %i mal interpretee(s)\n", ...
                ligneDeb, ligneFin);
        erreur = %t;
    end

    [stcReleve] =  resume(stcReleve);
endfunction


//****************************************************************************
/// \fn barre_Progression(stcStatistiques, ligne, progression)
/// \brief Rafraichit la barre de progression \n Calcul la progression et estime 
/// le temps restant; est appelée à chaque nouveau pourcent réalisé
/// \param [in] stcStatistiques   \c structure   Statistiques de progression
/// \param [in] ligne   \c double   Ligne courante
/// \param [in] progression \c double   Compteur d'avancement (nombre de fois 
///     où la fonction est apellée)
/// \param [out] progression    \c double   Compteur d'avancement
/// \param [out] stcStatistiques    \c structure   Statistiques de progression
//*****************************************************************************
function barre_Progression(stcStatistiques, ligne, progression)
    // Calcul du temps restant
    stcStatistiques.tempsTotal = toc();
    progression = progression + 1;
    stcStatistiques.tabTempsRestant(progression) = stcStatistiques.tempsTotal ...
                                            * (100-progression) / progression;
    
    // Affichage du pourcentage d'avancement et temps restant
    if stcStatistiques.tabTempsRestant(progression) < 60 then
        progressionbar(BarreProgression, 'Import en cours, ' + ...
        string(floor(ligne*100/stcStatistiques.nbrLignes)) + ...
        '% fait. Temps restant : ' + ...
        string(round(stcStatistiques.tabTempsRestant(progression))) + 's');
    else
        tempTempsRestant = [floor(stcStatistiques.tabTempsRestant(progression)/60) ...
        round(modulo(round(stcStatistiques.tabTempsRestant(progression)),60))];
        progressionbar(BarreProgression, 'Import en cours, ' + ...
        string(floor(ligne*100/stcStatistiques.nbrLignes)) + ...
        '% fait. Temps restant : ' + string(tempTempsRestant(1)) + ...
        'min '+ string(nombre_2_Chiffres(tempTempsRestant(2))) + 's');
    end
    
    [progression, stcStatistiques] = resume(progression, stcStatistiques);
endfunction


//*****************************************************************************
/// \fn Sauve_Variables(filePath, stcReleve, stcStatistiques)
/// \brief Enregistre les variables stcReleve et stcStatistiques dans un 
///     fichier 'Releves_aaaa-mm-jj.sod' dans le répertoire filePath
/// \param [in] filePath    \c string   Chemin où enregistrer le fichier
/// \param [in] stcReleve   \c Structure    Relevé
/// \param gobal stcStatistiques \c Structure    Statistiques
//*****************************************************************************
function Sauve_Variables(filePath, stcReleve)
    originPath = pwd();
    // Enregistrement des variables dans Releves_aaaa-mm-jj.sod
    dateReleve = msscanf(stcReleve.date, '%c%c%c%c / %c%c / %c%c');
    dateReleve = [strcat([dateReleve(1), dateReleve(2), dateReleve(3), ...
                  dateReleve(4)]) strcat([dateReleve(5),dateReleve(6)]) ...
                  strcat([dateReleve(7),dateReleve(8)])];

    cd(filePath);
    fileName = strcat([stcReleve.numCompteur,"_",dateReleve(1),"-",dateReleve(2)...
    ,"-",dateReleve(3),".sod"]);
    save(fileName, "stcReleve", "stcStatistiques");
   
    printf("Variables sauvegardées dans %s\\%s\n", filePath, fileName);
    cd(originPath);
endfunction


//*****************************************************************************
/// \fn posiCaract = LocaliserCaractere(trame,caractere)
/// \brief A partir de l'en-tête du tableau, retourne la position 
///  des tabulations et la configuration
/// \param [in] trame    \c string   Trame à analyser
/// \param [in optionnel] opt_sens \c booléen   Si présent, parcourt de la fin au début
/// \return posiCaract  \c tabDouble  Position des tabulations
//*****************************************************************************
function posiCaract = LocaliserCaractere(trame, caractere, opt_sens)
    j= 0;
    if argn(2) == 2 then
        for i = 1:length(trame)
            if ascii(part(trame, i)) == caractere then
                j = j+1;
                posiCaract(j) = i;
            end
        end
    else
        i = length(trame);
        while i > 0
            if ascii(part(trame, i)) == caractere then
                j = j+1;
                posiCaract(j) = i;
            end
            i = i -1;
        end
    end
    posiCaract(j+1) = length(trame);
endfunction


//*****************************************************************************
/// \fn Indexer_Trame_Base (trame, stcPosiTab)
/// \brief Retourne les valeurs dans une trame BASE
/// \param [in] trame    \c string   Trame à analyser
/// \param [in] stcPosiTab  \c structure    Position des valeurs
/// \param [out] tmpReleve  \c tabString(3)  Valeurs Heure, Papp, Index
/// \todo Mutualiser avec Indexer_Trame_HCHP
//*****************************************************************************
function Indexer_Trame_Base (trame, stcPosiTab)
    tabFin = size(trame,1);
    heure(tabFin) = "";
    papp(tabFin) = "";
    index(tabFin) = "";
    
    heure = part(trame, 1:stcPosiTab.heureFin);
    papp = part(trame, stcPosiTab.pappDebut:stcPosiTab.pappFin);
    index = part(trame, stcPosiTab.indexDebut:stcPosiTab.indexFin);
    [tmpReleve] = resume([heure papp index]);
endfunction


//*****************************************************************************
/// \fn Indexer_Trame_HCHP (trame, stcPosiTab)
/// \brief Retourne les valeurs dans une trame HCHP
/// \param [in] trame    \c string   Trame à analyser
/// \param [in] stcPosiTab  \c structure    Position des valeurs
/// \param [out] tmpReleve  \c tabString(4)  Valeurs Heure, Papp, IndexHC, IndexHP
/// \todo A supprimer une fois mutualisé avec Indexer_Trame_Base
//*****************************************************************************
function Indexer_Trame_HCHP (trame, stcPosiTab)
    heure = part(trame, 1:stcPosiTab.heureFin);
    papp = part(trame, stcPosiTab.pappDebut:stcPosiTab.pappFin);
    indexHC = part(trame, stcPosiTab.HCDebut:stcPosiTab.HCFin);
    indexHP = part(trame, stcPosiTab.HPDebut:stcPosiTab.indexFin);
    [tmpReleve] = resume([heure papp indexHC indexHP]);
endfunction


/// \stc stcPosiTab.    \c Structure    Position des valeurs dans le fichier
///       heureFin     \c double   Fin de l'heure
///       pappDebut    \c double   Début de la Papp
///       pappFin      \c double   Fin de la Papp
///       indexDebut   \c double   Si Base, début index 
///       indexFin     \c double   Si Base, fin index
///       HCDebut    \c double   Si HCHP, début index HC
///       HCFin      \c double   Si HCHP, Fin index HC
///       HPDebut    \c double   Si HCHP, début index HP
///       indexFin   \c double   Si HCHP, fin index HP
///       dernLigne     \c double   Dernière ligne de valeurs dans donnee
///       lignesEnTete  \c double   Première ligne de valeurs dans donnee
///       nbrIteration  \c double   Nombre de lignes par itération
///       indexLigne    \c double   Numéro courant de paquet par pas de 
/// "nbrIteration" lignes

