//*****************************
/// \author Sébastien Lemoine
/// \date Avril 2014
/// \brief Fonctions pour importer un fichier .txt
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
            stcPosiTab.HCDebut = tmpPosiTab(2)-1;
            stcPosiTab.HCFin = tmpPosiTab(3)-2;
            stcPosiTab.HPDebut = tmpPosiTab(3)-1;
            stcPosiTab.indexFin = tmpPosiTab(4);
        end

        stcPosiTab.nbrIteration = floor(stcReleve.nbrLignes/99);

        stcReleve.papp = zeros(stcReleve.nbrLignes,1);
        stcReleve.heure(stcReleve.nbrLignes) = "";

        /// \todo Essayer avec une matrice.
        ///  Ex: stcReleve.heure=part(donnee(lignesEnTete:dernLigne,1:8))

        // ****************
        // ***** Base *****
        // ****************
        if stcReleve.isConfigBase then
            stcReleve.index = zeros(stcReleve.nbrLignes,1);
            // ***** Index énergies à t0 *****
            Indexer_Trame_Base (donnee(lignesEnTete), stcPosiTab);
            stcReleve.index0 = strtod(tmpReleve(3));
        
            // ***** Extraction des points *****
            // Rafraichissement de l'avancement tous les %
            // Pour un nombre de lignes entier
            for indexLigne = 1 : 99
                stcPosiTab.indexLigne = indexLigne;
                erreur = indexerPartie(donnee, stcPosiTab, stcReleve);
                // Sortir de la boucle
                if erreur then
                    if isDEBUG then
                        printf("Erreur \t Lignes entre %i et %i mal interpretee(s).", ...
                        stcPosiTab.nbrIteration*indexLigne-1, stcPosiTab.nbrIteration*indexLigne);
                    end
                    indexLigne = stcPosiTab.dernLigne;
                end
                barre_Progression(stcStatistiques, ...
                            stcPosiTab.nbrIteration*indexLigne, progression);
                sleep(5);  // Pause de 5ms
            end

            // Nombre de lignes restantes
            erreur = indexerPartie(donnee, stcPosiTab, stcReleve, ...
                    stcPosiTab.nbrIteration*indexLigne, stcPosiTab.dernLigne-3)
            barre_Progression(stcStatistiques, stcPosiTab.dernLigne, progression);

            // Mise en forme de l'index
            cptLigneErreur = 0;
            for ligne = 1 : size(stcReleve.index,1)
                // Si Not A Number alors valeur précédente
                if isnan(stcReleve.index(ligne)) then
                    stcReleve.index(ligne) = stcReleve.index(ligne-1);
                else
                    // Normalisation sur la journée
                    stcReleve.index(ligne) = stcReleve.index(ligne) - stcReleve.index0;
                    if stcReleve.index(ligne) < 0 then
                        stcReleve.index(ligne) = stcReleve.index(ligne-1);
                        // Comptabiliser le nombre d'erreur consécutives
                        cptLigneErreur = cptLigneErreur +1;
                    elseif cptLigneErreur < MAXERREURLIGNE then
                        cptLigneErreur = 0;
                    end
                end
            end
            //Signaler trop d'erreur consécutives
            if cptLigneErreur > MAXERREURLIGNE then
                printf("ATTENTION \t Trop d''erreurs consecutives sur l''energie (%i)",cptLigneErreur);
            end

        // ****************
        // ***** HCHP *****
        // ****************
        elseif stcReleve.isConfigHCHP then
            stcReleve.index = zeros(stcReleve.nbrLignes,2);
            // ***** Index énergies à t0 *****
            Indexer_Trame_HCHP (donnee(lignesEnTete), stcPosiTab);
            stcReleve.index0(1) = strtod(tmpReleve(3));
            stcReleve.index0(1,2) = strtod(tmpReleve(4));
            tempIndex0 = stcReleve.index0;
        
            // ***** Extraction des points *****
            // Rafraichissement de l'avancement tous les %
            // Pour un multiple entier de lignes
            for indexLigne = 1: 99
                for ligne = ((indexLigne-1)*nbrIteration+stcPosiTab.lignesEnTete) : ...
                            (indexLigne*nbrIteration+stcPosiTab.lignesEnTete-1)
                    try
                        Indexer_Trame_HCHP (donnee(ligne), stcPosiTab);
                        stcReleve.heure(ligne-5) = tmpReleve(1);
                        stcReleve.papp(ligne-5) = strtod(tmpReleve(2));
                        tmpEnergie = [strtod(tmpReleve(3)) strtod(tmpReleve(4))];
                        if (size(tmpEnergie,2) == 2 & tmpEnergie > 1) then
                            stcReleve.index(ligne-5,1) = tmpEnergie(1) - ...
                                                        tempIndex0(1);
                            stcReleve.index(ligne-5,2) = tmpEnergie(2) - ...
                                                        tempIndex0(2);
                            // Ajout du 07/12/14. Si relevé incorrecte, 
                            //ne pas avoir de valeur négative
                            if stcReleve.index(ligne-5,1) < 0 then
                                stcReleve.index(ligne-5,1) = ...
                                                    stcReleve.index(ligne-6,1);
                            end
                            if stcReleve.index(ligne-5,2) < 0 then
                                stcReleve.index(ligne-5,2) = ...
                                                    stcReleve.index(ligne-6,2);
                            end
                        else
                            stcReleve.index(ligne-5,1) = stcReleve.index(ligne-6,1);
                            stcReleve.index(ligne-5,2) = stcReleve.index(ligne-6,2);
                        end

                    catch
                        printf("Attention! \t Ligne n°%i mal interpretee\n",...
                                ligne+stcPosiTab.lignesEnTete);
                            // Recopier les valeurs précédentes
                            // Incrémenter d'une seconde
                            ligne = Gerer_Trame_Invalide(stcReleve, cptLigneErreur, ligne);
                            // Sortir de la boucle
                            if erreur then
                                ligne = dernLigne;
                            end
                    end
                end
                barre_Progression(stcStatistiques, ligne, progression);
                sleep(5);  // Pause de 5ms
            end
            
            // Nombre de lignes restantes
            for ligne = ligne : stcPosiTab.dernLigne
                try
                    Indexer_Trame_HCHP (donnee(ligne), stcPosiTab);
                    stcReleve.heure(ligne-5) = tmpReleve(1);
                    stcReleve.papp(ligne-5) = strtod(tmpReleve(2));
                    tmpEnergie = [strtod(tmpReleve(3)) strtod(tmpReleve(4))];
                    if (size(tmpEnergie,2) == 2 & tmpEnergie > 1) then
                        stcReleve.index(ligne-5,1) = tmpEnergie(1) - ...
                                                    tempIndex0(1);
                        stcReleve.index(ligne-5,2) = tmpEnergie(2) - ...
                                                    tempIndex0(2);
                    else
                        stcReleve.index(ligne-5,1) = stcReleve.index(ligne-6,1);
                        stcReleve.index(ligne-5,2) = stcReleve.index(ligne-6,2);
                    end

                catch
                    printf("Attention! \t Ligne n°%i mal interpretee\n",...
                            ligne+stcPosiTab.lignesEnTete);
                        // Recopier les valeurs précédentes
                        // Incrémenter d'une seconde
                        ligne = Gerer_Trame_Invalide(stcReleve, cptLigneErreur, ligne);
                        // Sortir de la boucle
                        if erreur then
                            ligne = dernLigne;
                        end
                    end
            end
            barre_Progression(stcStatistiques, ligne, progression);
        end
        
        // Calcul puissance moyenne et recomposition de la puissance
        stcReleve.pappMoy = mean(stcReleve.papp);
        if stcReleve.pappMoy == 0 then
            printf("Puissance absente, recalcule a partir de l''energie en cours...\n");
            Puissance_HCHP(stcReleve);
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
/// \fn erreur = indexerPartie(donnee, stcPosiTab, stcReleve, opt_ligneDeb, opt_ligneFin)
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
        Indexer_Trame_Base (donnee(ligneDeb+5:ligneFin+5), stcPosiTab);
        stcReleve.heure(ligneDeb:ligneFin) = tmpReleve(:,1);
        stcReleve.papp(ligneDeb:ligneFin) = strtod(tmpReleve(:,2));
        stcReleve.index(ligneDeb:ligneFin) = strtod(tmpReleve(:,3));

    catch
        /// \todo le passer en fonction pour le mutualiser à toutes les boucles for
        printf("Attention! \t Ligne mal interpretee\n");
        // Recopier les valeurs précédentes
        // Incrémenter d'une seconde
//        ligne = Gerer_Trame_Invalide(stcReleve, cptLigneErreur, ligne);
    end

    [stcPosiTab, stcReleve] =  resume(stcPosiTab, stcReleve);
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
/// \return posiCaract \c tabDouble  Position des tabulations
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
/// \param [out] tmpReleve \c tabString(3)  Valeurs Heure, Papp, Index
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
/// \param [out] tmpReleve \c tabString(4)  Valeurs Heure, Papp, IndexHC, IndexHP
//*****************************************************************************
function Indexer_Trame_HCHP (trame, stcPosiTab)
    heure = part(trame, 1:stcPosiTab.heureFin);
    papp = part(trame, stcPosiTab.pappDebut:stcPosiTab.pappFin);
    indexHC = part(trame, stcPosiTab.HCDebut:stcPosiTab.HCFin);
    indexHP = part(trame, stcPosiTab.HPDebut:stcPosiTab.indexFin);
    [tmpReleve] = resume([heure papp indexHC indexHP]);
endfunction


//*****************************************************************************
/// \fn ligne = Gerer_Trame_Invalide(stcReleve, cptLigneErreur, ligne);
/// \brief 
/// \param [in] 
/// \param [in] 
/// \param [out] 
//*****************************************************************************
function ligne = Gerer_Trame_Invalide(stcReleve, cptLigneErreur, ligne)
    MAXERREURLIGNE = 10;    // Tolérence aux lignes incorrectes
    cptLigneErreur = cptLigneErreur +1;
    
    if cptLigneErreur >= MAXERREURLIGNE then
        printf("Erreur! \t Trop de lignes successives en erreur\nFin du programme");
        ligne = stcPosiTab.dernLigne;  // Sortir des boucles
        erreur = %t;
    else
        // Incrémenter d'une seconde et gestion du débordement
        strHeure = stcReleve.heure(ligne-5);
        tempValeur = {" "," "," "," "," "," "," "," "};
        tempValeur(8) = string(strtod(part(strHeure,8))+1);
        /// \todo Reprendre/mutualiser la gestion du débordement d'heure
        indiceDebHeure = 8;
        indiceFinHeure = 7;
        if strtod(tempValeur) > 9 then
            tempValeur(8) = "0";
            tempValeur(7) = string(strtod(part(strHeure,7))+1);
            indiceDebHeure = 7;
            indiceFinHeure = 6;
            if strtod(tempValeur(7)) > 5 then
                tempValeur(7) = "0";
                tempValeur(6) = ":";
                tempValeur(5) = string(strtod(part(strHeure,5))+1);
                indiceDebHeure = 5;
                indiceFinHeure = 4;
                if strtod(tempValeur(5)) > 9 then
                    tempValeur(5) = "0";
                    tempValeur(4) = string(strtod(part(strHeure,4))+1);
                    indiceDebHeure = 4;
                    indiceFinHeure = 3;
                    if strtod(tempValeur(4)) > 5 then
                        tempValeur(4) = "0";
                        tempValeur(2) = string(strtod(part(strHeure,2))+1);
                        indiceDebHeure = 2;
                        indiceFinHeure = 1;
                        if strtod(tempValeur(2)) > 9 then
                            tempValeur(2) = "0";
                            tempValeur(1) = string(strtod(part(strHeure,1))+1);
                            indiceDebHeure = 1;
                            indiceFinHeure = 0;
                            if (strtod(tempValeur(1)) > 2 & strtod(tempValeur(1)) > 3) then
                                tempValeur(1) = "0";
                            end
                            strHeure = tempValeur;
                        end
                    end
                end
            end
        end
        if indiceFinHeure <> 0 then
            strTempValeur = strcat([tempValeur(1),tempValeur(2),tempValeur(3),...
                tempValeur(4),tempValeur(5),tempValeur(6),...
                tempValeur(7),tempValeur(8)]);
            strHeure = strcat([part(strHeure,1:indiceFinHeure),...
                part(strTempValeur,indiceDebHeure:8)]);
        end

        stcReleve.heure(ligne-5) = strHeure;
        stcReleve.papp(ligne-5) = stcReleve.papp(ligne-6);
        // Gestion de BASE et HPHC
        stcReleve.index(ligne-5,:) = stcReleve.index(ligne-6,:);
    end
        
    [stcReleve, erreur, cptLigneErreur] = resume(stcReleve, erreur, cptLigneErreur);
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

