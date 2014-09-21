//*****************************
/// \file Charger_Txt.sci
/// \author Sébastien Lemoine
/// \date Avril 2014
/// \brief Fonctions pour importer un fichier texte .txt
//******************************

//****************************************************************************
/// \brief Affiche la barre de progression \n Calcul la progression et estime 
/// le temps restant \n Est appelée à chaque nouveau pourcent réalisé
/// \param [in] ligne   \c double   Ligne courante
/// \param [in] stcStatistiques   \c structure   Structure de statistique d'avancement
/// \param [in] progression \c double   Compteur d'avancement (nombre de fois 
///     où la fonction est apellée)
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


    // Courant max de la journée
    try
        ligne = offset+ligne+2;
        Imax = msscanf(donnee(ligne,1),'%s %s %s %s');
        Imax = evstr(Imax(IMAX));
        printf("Courant max sur la journée: %dA\n", Imax);
    catch
    end

    
//*****************************************************************************
/// \brief Enregistre les variables dans un fichier .sod
/// \param [in] filePath    \c string   Chemin où enregistrer le fichier
/// Les variables suivantes sont sauvegardées:
/// \li \var stcReleve
/// \li \var stcStatistiques
//*****************************************************************************
function Sauve_Variables (filePath, stcReleve, stcStatistiques)
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
/// \brief A partir de l'en-tête du tableau, retourne la position 
///  des tabulations et la configuration
/// \param [in] trame    \c string   Trame à analyser
/// \return tmpConfig \c string  Configuration du compteur
/// \return tmpPosiTab \c tableau double  Position des tabulations
//*****************************************************************************
function posiCaract = LocaliserCaractere(trame,caractere)
    j= 0;
    for i = 1:length(trame)
        if ascii(part(trame, i)) == caractere then
            j = j+1;
            posiCaract(j) = i;
        end
    end
    posiCaract(j+1) = length(trame);
    return posiCaract;
endfunction

//*****************************************************************************
/// \brief Retourne les valeurs dans une trame BASE
/// \param [in] trame    \c string   Trame à analyser
/// \param [in] stcPosiTab  \c structure    Position des valeurs
/// \param [in] stcReleve   \c pointeur structure    Structure où enregistrer les valeurs
/// \return tmpReleve \c tableau string  Valeurs
//*****************************************************************************
function Indexer_Trame_Base (trame, stcPosiTab)
    heure = part(trame, 1:stcPosiTab.heureFin);
    papp = part(trame, stcPosiTab.pappDebut:stcPosiTab.pappFin);
    index = part(trame, stcPosiTab.indexDebut:stcPosiTab.indexFin);
    [tmpReleve] = resume([heure papp index]);
endfunction

//*****************************************************************************
/// \brief Retourne les valeurs dans une trame HCHP
/// \param [in] trame    \c string   Trame à analyser
/// \param [in] stcPosiTab  \c structure    Position des valeurs
/// \param [in] stcReleve   \c pointeur structure    Structure où enregistrer les valeurs
/// \return tmpReleve \c tableau string  Valeurs
//*****************************************************************************
function Indexer_Trame_HCHP (trame, stcPosiTab)
    heure = part(trame, 1:stcPosiTab.heureFin);
    papp = part(trame, stcPosiTab.pappDebut:stcPosiTab.pappFin);
    indexHC = part(trame, stcPosiTab.HCDebut:stcPosiTab.HCFin);
    indexHP = part(trame, stcPosiTab.HPDebut:stcPosiTab.indexFin);
    [tmpReleve] = resume([heure papp indexHC indexHP]);
endfunction


//****************************************************************************
/// \brief Importe les données depuis un fichier .txt
/// \param [in] dataPath    \c string  Chemin d'accès au répertoire où lire les fichiers .txt
/// \param [in] DEBUG   \c double   Afficher des informations en console pour le debug
/// \return cheminFichier     \c string     Pointeur du fichier ouvert
/// \return erreur     \c double     Erreur lors de l'execution
/// \return stcReleve   \c structure   
/// \return stcStatistiques    \c structure     
//****************************************************************************
function cheminFichier = Importer_Txt(dataPath2Read, isDEBUG)
    caractereAChercher = 9; //Tabulation, valeur en décimale, utiliser ascii()
    // Selection du fichier à traiter
    cheminFichier = uigetfile(["*.txt"],dataPath2Read, ...
    "Choisir le fichier à ouvrir", %f);
    
    // Fichier sélectionné
    if (cheminFichier ~= "") then
        tic;
        // Initialisation des variables
        fichierOuvert = 1;
        tempsExecution = 0;
        progression = 0;
        tempsRestant = 0;
        tempsRestant_1 = 0;
        lignesEnTete = 6;
        
        nomPC = "Seb";  // Nom de PC servant à l'importation
        
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
        dernLigne = stcReleve.nbrLignes + 5;
        ligneImax = dernLigne+1;
        
        // ***** En-tête et pied de fichier *****
        //Date et Heure du relevé
        // Date et heure de l'importation
        tempDate = getdate();
        stcStatistiques = struct("dateImportation", strcat([string(tempDate(1)), '/', ...
           nombre_2_Chiffres(tempDate(2)), '/', nombre_2_Chiffres(tempDate(6))]));
        stcStatistiques.heureImportation = strcat([nombre_2_Chiffres(tempDate(7)), ':', ...
           nombre_2_Chiffres(tempDate(8)), ':', nombre_2_Chiffres(tempDate(9))]);
        // Numéro du compteur
        temp = msscanf(donnee(3),'%s n°%s');
        stcReleve.numCompteur = temp(2);
        stcReleve.residence = nom_compteur(stcReleve.numCompteur);
        // Date et heures du relevé
        temp = msscanf(donnee(1),'%s %s %s %s');
        tempDate = datenum(evstr(part(temp(3),1:4)), ...
                           evstr(part(temp(3),6:7)), ...
                           evstr(part(temp(3),9:10)));
        [N, stcReleve.jour] = weekday(tempDate,'long');
        stcReleve.date = strcat([part(temp(3),1:4), '/', part(temp(3),6:7), ...
                                '/', part(temp(3),9:10)]);
        temp = msscanf(donnee(6),'%s %s %s %s');
        stcReleve.heureDebut = temp(1);
        temp = msscanf(donnee(dernLigne),'%s %s %s %s');
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
        //TODO indiquer les variables
        stcStatistiques.numCompteur = stcReleve.numCompteur;
        stcStatistiques.config = stcReleve.config;
        stcStatistiques.nomPC = nomPC;
        stcStatistiques.date = stcReleve.date;
        stcStatistiques.heure = stcReleve.heureDebut;
        stcStatistiques.nbrLignes = stcReleve.nbrLignes;
        stcStatistiques.tempsTotal = 0;
        stcStatistiques.tabTempsRestant(1) = 0;
        
        // ***** Indentation du tableau *****
        tmpPosiTab = LocaliserCaractere(donnee(lignesEnTete),caractereAChercher);
        // Positions des valeurs
        stcPosiTab = struct("heureFin",tmpPosiTab(1)-2);
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
                    Indexer_Trame_Base (donnee(ligne), stcPosiTab);
                    stcReleve.heure(ligne-5) = tmpReleve(1);
                    stcReleve.papp(ligne-5) = evstr(tmpReleve(2));
                    tmpEnergie = evstr(tmpReleve(3));
                    if (tmpEnergie == [] | tmpEnergie == 1 ) then
                        stcReleve.index(ligne-5) = stcReleve.index(ligne-6);
                    else
                        //***************************
                        stcReleve.index(ligne-5) = tmpEnergie - stcReleve.index0;
                    end
                end
                barre_Progression(stcStatistiques, ligne, progression);
                sleep(5);  // Pause de 5ms
            end
            
            // Nombre de lignes restantes
            for ligne = ligne : dernLigne
                Indexer_Trame_Base (donnee(ligne), stcPosiTab);
                stcReleve.heure(ligne-5) = tmpReleve(1);
                stcReleve.papp(ligne-5) = evstr(tmpReleve(2));
                tmpEnergie = evstr(tmpReleve(3));
                if (tmpEnergie == [] | tmpEnergie == 1) then
                    stcReleve.index(ligne-5) = stcReleve.index(ligne-6);
                else
                    stcReleve.index(ligne-5) = tmpEnergie - stcReleve.index0;
                end
            end
            barre_Progression(stcStatistiques, ligne, progression);

        // ****************
        // ***** HCHP *****
        // ****************
        elseif stcReleve.isConfigHCHP then
            stcReleve.index = zeros(stcReleve.nbrLignes,2);
            // ***** Index énergies à t0 *****
            Indexer_Trame_HCHP (donnee(lignesEnTete), stcPosiTab);
            stcReleve.index0(1) = evstr(tmpReleve(3));
            stcReleve.index0(1,2) = evstr(tmpReleve(4));
        
            // ***** Extraction des points *****
            // Rafraichissement de l'avancement tous les %
            
            // Pour un multiple entier de lignes
            for centieme = 1:centiemeMax
                for ligne = (centieme-1)*denominateur+lignesEnTete : ...
                            centieme*denominateur+lignesEnTete-1
                    Indexer_Trame_HCHP (donnee(ligne), stcPosiTab);
                    stcReleve.heure(ligne-5) = tmpReleve(1);
                    stcReleve.papp(ligne-5) = evstr(tmpReleve(2));
                    tmpEnergie = [evstr(tmpReleve(3)) evstr(tmpReleve(4))];
                    if tmpEnergie == [] then
                        stcReleve.index(ligne-5,1) = stcReleve.index(ligne-6,1);
                        stcReleve.index(ligne-5,2) = stcReleve.index(ligne-6,2);
                    else
                        stcReleve.index(ligne-5,1) = tmpEnergie(1) - stcReleve.index0(1);
                        stcReleve.index(ligne-5,2) = tmpEnergie(2) - stcReleve.index0(2);
                    end
                end
                barre_Progression(stcStatistiques, ligne, progression);
                sleep(5);  // Pause de 5ms
            end
            
            // Nombre de lignes restantes
            for ligne = ligne : dernLigne
                Indexer_Trame_HCHP (donnee(ligne), stcPosiTab);
                stcReleve.heure(ligne-5) = tmpReleve(1);
                stcReleve.papp(ligne-5) = evstr(tmpReleve(2));
                tmpEnergie = [evstr(tmpReleve(3)) evstr(tmpReleve(4))];
                if tmpEnergie == [] then
                    stcReleve.index(ligne-5,1) = stcReleve.index(ligne-6,1);
                    stcReleve.index(ligne-5,2) = stcReleve.index(ligne-6,2);
                else
                    stcReleve.index(ligne-5,1) = tmpEnergie(1) - stcReleve.index0(1);
                    stcReleve.index(ligne-5,2) = tmpEnergie(2) - stcReleve.index0(2);
                end
            end
            barre_Progression(stcStatistiques, ligne, progression);
        end
        
        // Puissance moyenne et IMAX
        stcReleve.pappMoy = mean(stcReleve.papp);
        try
            posiCaract = LocaliserCaractere(donnee(ligneImax),caractereAChercher);
            stcReleve.iMax = evstr(part(donnee(ligneImax), ...
                                        posiCaract(3):length(donnee(ligneImax))));
        catch
            stcReleve.iMax = 0;
            printf("Pied de fichier manquant, IMAX non trouvé\n");
        end
        
        stcStatistiques.tempsTotal = toc() + stcStatistiques.tempsIntermediaire;
        close(BarreProgression);

        // ***** Retourne *****
        [stcReleve, stcStatistiques, erreur] = ...
                                      resume(stcReleve, stcStatistiques, %f);
    else
        [erreur] = resume(%t);    //Pas de fichier sélectionné
    end
endfunction
