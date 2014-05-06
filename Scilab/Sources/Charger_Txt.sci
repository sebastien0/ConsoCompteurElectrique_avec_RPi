//*****************************
/// \file Charger_Txt.sci
/// \author Sébastien Lemoine
/// \date Avril 2014
/// \brief Fonctions pour importer un fichier texte .txt
//******************************

//****************************************************************************
/// \brief Importe les données depuis un fichier .txt
/// \param [in] dataPath    \c string  Chemin d'accès au répertoire où lire les fichiers .txt
/// \return cheminFichier     \c string     Pointeur du fichier ouvert
/// \return Gbl_CreationTxt     \c string     Tableau de date et heures de création
/// \return Gbl_Heure   \c TabString   Horodatage des relevés
/// \return Gbl_Papp    \c TabDouble   Mesures de la puissance apparente
/// \return Gbl_Index0  \c double   Index d'énergie au 1er échantillon du relevé
/// \return Gbl_Index   \c TabDouble Différence d'index d'énergie par rapport à \c Gbl_Index0
/// \return Gbl_NumCompteur     \c string  Numéro du compteur
/// \return Gbl_Config  \c TabDouble   Tableau contenant la configuration du compteur
//****************************************************************************
function cheminFichier = Charger_Txt(dataPath)
    // Selection du fichier à traiter
    cheminFichier = uigetfile(["*.txt"],dataPath, ...
    "Choisir le fichier à ouvrir", %f);
    
    // Si un fichier est bien sélectionné
    if (cheminFichier ~= "") then
        // Initialisation des variables
        fichierOuvert = 1;
        tempsExecution = 0;
        progression = -1;
        tempsRestant = 0;
        tempsRestant_1 = 0;
        
        printf("Ouverture du fichier %s \n", cheminFichier);
        BarreProgression = progressionbar('Import en cours: 0% fait');
        tic;

        fichier = mopen(cheminFichier,'r'); // Ouverture du fichier
        donnee = mgetl(cheminFichier);  // Lecture du fichier
        mclose(cheminFichier);  // Fermeture du fichier
        
        // ***** Identification configuration Base ou HPHC ********************
        configuration(donnee);  // Retourne: titres, configBase_N, configHPHC_N

        // ******* Obtention de la date et l'heure ****************************
        //Date du relevé
        Creation = msscanf(donnee(1,1),'%s %s %s %s');
        CreationTxt(1) = msscanf(Creation(1,3),'%s');
        CreationTxt(2) = msscanf(Creation(1,4),'%s');
    
        // Numéro du compteur
        temp = msscanf(donnee(3,1),'%s n°%s');
        NumCompteur = temp(1,2);
        clear temp;
    
        printf("\nRelevé créé le %s à %s par le compteur n°%s\n", ...
        CreationTxt(1), CreationTxt(2), NumCompteur);
        
        // *** Extraction des données *****************************************
        printf("Extraction et mise en forme des données ...\n");
        
        // En-tête des colonnes
        if configBase_N == 0 then
            donnee_mesure(1,:) = titres;
        elseif configHPHC_N == 0 then
            donnee_mesure(1,:) = [titres(1) titres(3)+" "+titres(4) ...
            titres(5)+" "+titres(6) titres(7)];
        end
        
        // Extraction des données, création des matrices
        // Retourne:
        //  BASE:
        //      Papp, index_Base, Base, nbrLignes, HEURE, Config, 
        //      donnee_mesure, tempsExecution, tempsRestant_1
        // HCHP:
        //      index_Hpleines, Hpleines, index_Hcreuses, Hcreuses, 
        //      nbrLignes, HEURE, Config, donnee_mesure, tempsExecution,
        //      tempsRestant_1
        extraction(configBase_N, configHPHC_N, donnee_mesure, donnee);

        CreationTxt(3) = msscanf(donnee_mesure(nbrLignes-1,HEURE),'%s');
        CreationTxt(4) = nom_jour(CreationTxt(1));
        
        tempsExecution = tempsExecution + toc();
        printf("Fin du traitement en %d secondes\n", ceil(tempsExecution));
        printf("\nErreur sur l''estimation du temps restant : %.1f%% \n\n",...
        ((tempsExecution - tempsRestant_1) / tempsRestant_1)*100);  //DEBUG
    else
        fichierOuvert = 0;
        Config = zeros(1,2);
        printf("Aucun fichier sélectionné\n");
    end
    
    // ****** Retour des variables ********************************************
    if fichierOuvert <> 0 then
        Heure = donnee_mesure(2:nbrLignes,1);
        if configBase_N == 0 then
            index0 = index_Base;
        elseif configHPHC_N == 0 then
            index0 = [index_Hpleines, index_Hcreuses]
            Base = [Hpleines Hcreuses];
            Papp = Puissance_HCHP(Heure, Base);
        else
            CreationTxt = zeros(1);
            donnee_mesure = zeros(1);
            Papp = zeros(1);
            Base = zeros(1);
            NumCompteur = zeros(1);
            index0 = 0;
        end
        close(BarreProgression);
    else
        Heure = zeros(1);
        CreationTxt = zeros(1);
        donnee_mesure = zeros(1);
        Papp = zeros(1);
        Base = zeros(1);
        NumCompteur = zeros(1);
        index0 = 0;
     end
     
    [Gbl_CreationTxt, Gbl_Heure, Gbl_Papp, Gbl_Index0, Gbl_Index, Gbl_NumCompteur, ...
    Gbl_Config] = resume (CreationTxt, Heure, Papp, index0, Base,...
     NumCompteur, Config);
endfunction

//****************************************************************************
/// \brief Affiche la barre de progression \n Calcul la progression et estime 
/// le temps restant \n Est appelée à chaque nouveau pourcent réalisé
/// \param [in] ligne   \c double   Ligne courante
/// \param [in] nbrLignes   \c double   Nombre total de ligne
/// \param [in] progression \c double   \b TBC Compteur d'avancement
/// \param [in] tempsExecution  \c double   Temps écoulé
/// \param [in] tempsRestant    \c double   Temps restant estimé
/// \param [in] tempsRestant_1  \c double   Temps restant estimé au %% précédent
//*****************************************************************************
function barre_Progression(ligne, nbrLignes, progression, tempsExecution, ...
            tempsRestant, tempsRestant_1)
    // Calcul du temps restant
    progression = progression + 1;
    tempsExecution = tempsExecution + toc();
    tic;

     tempsRestant = tempsExecution * (100-progression) / progression;
     // Prise en compte des derniers traitements; valeur arbitraire
     tempsRestant = 1.03 * tempsRestant;
     
    if (progression == 0 | tempsRestant > tempsRestant_1) then
        disp("TempsRestant estimé : "+ string(ceil(tempsRestant))); // DEBUG
        tempsRestant_1 = tempsRestant;
    end
    
    // Affichage du pourcentage d'avancement et temps restant
    if tempsRestant < 60 then
        progressionbar(BarreProgression, 'Import en cours, ' + ...
        string(floor(ligne*100/nbrLignes)) + ...
        '% fait. Temps restant : ' + ...
        string(round(tempsRestant)) + 's');
    else
        tempTRestant = [floor(tempsRestant/60) ...
        round(modulo(round(tempsRestant),60))];
        progressionbar(BarreProgression, 'Import en cours, ' + ...
        string(floor(ligne*100/nbrLignes)) + ...
        '% fait. Temps restant : ' + string(tempTRestant(1)) + ...
        'min '+ string(tempTRestant(2)) + 's');
    end
    
    [ligne, nbrLignes, progression, tempsExecution, tempsRestant, ...
    tempsRestant_1] = resume(ligne, nbrLignes, progression, tempsExecution, ...
    tempsRestant, tempsRestant_1);
endfunction

//****************************************************************************
/// \brief Extrait les données depuis le fichier texte \n
/// Fonction d'extraction à proprement parler
/// \param [in] configBase_N    \c double   Configuration du compteur en Base
/// \param [in] configHPHC_N    \c double   Configuration du compteur en HPHC
/// \param [in] donnee_mesure    \c TabString   Remise en forme du fichier texte ouvert (plusieurs colonnes)
/// \param [in] donnee    \c TabString   Fichier texte ouvert (1 colonne)

/// Retourne en permanence:
/// \li \return nbrLignes   \c double   Nombre de lignes
/// \li \return HEURE   \c TabString    Timestamp des relevés
/// \li \return Config  \c TabDouble    Configuration BASE ou HPHC
/// \li \return tempsExecution  \c double   Temps écoulé
/// \li \return tempsRestant_1  \c double   Temps restant estimé au %% précédent
/// \todo \c tempsRestant_1 osbolète, à supprimer ?!

/// Dans le cas d'une configuation en BASE, retourne aussi :
/// \li \return Papp    \c TabDouble    Mesures de la puissance apparente
/// \li \return index_Base  \c double    Index d'énergie au 1er échantillon du relevé
/// \li \return Base  \c TabDouble    Différence d'index d'énergie par rapport à \c index_Base
/// \li \return donnee_mesure    \c TabString   Remise en forme du fichier texte ouvert (plusieurs colonnes)
/// \todo \c donnee_mesure ne doit pas être retourné !!

/// Dans le cas d'une configuation en HPHC, retourne aussi :
/// \li \return index_Hpleines  \c double   Index d'énergie au 1er échantillon en HP du relevé
/// \li \return Hpleines  \c TabDouble    Différence d'index d'énergie par rapport à \c index_Hpleines
/// \li \return index_Hcreuses  \c double   Index d'énergie au 1er échantillon en HC du relevé
/// \li \return Hcreuses  \c TabDouble    Différence d'index d'énergie par rapport à \c index_Hcreuses
/// \li \return donnee_mesure    \c TabString   Remise en forme du fichier texte ouvert (plusieurs colonnes)
/// \todo \c donnee_mesure ne doit pas être retourné !!
//*****************************************************************************
function extraction(configBase_N, configHPHC_N, donnee_mesure, donnee)
    progression = 0;
    offset = 5; // Ligne des en-tête de colonnes
    HEURE = 1;  // Colonne contenant l'heure
    IMAX = 4;   // Colonne contenant le courant max journalier
    INVALIDE = 4;   // Colonne contenant l'invalidité de la trame
    if configBase_N == 0 then
        PAPP = 2;   // Colonne contenant la puissance apparente
        BASE = 3;   // Colonne contenant l'index Base
    elseif configHPHC_N == 0 then
        HEURECREUSE = 2;   // Colonne contenant l'index Heure Creuse
        HEUREPLEINE = 3;   // Colonne contenant l'index Heure Pleine
    end
    
    nbrLignes = size(donnee)-1;
    nbrLignes = nbrLignes(1,1)-offset;
    
    // Création de matrices vides
    donnee_mesure(nbrLignes,:) = ["" "" "" ""];
    if configBase_N == 0 then
        Papp = zeros(nbrLignes,1);
        Base = zeros(nbrLignes,1);
    elseif configHPHC_N == 0 then

        Hpleines = zeros(nbrLignes,1);
        Hcreuses = zeros(nbrLignes,1);
    end
    
    // Parcour des lignes du fichier
    for ligne = 1:(nbrLignes-1)
        // Barre de progression
        if (floor(ligne*100/nbrLignes) > progression) then
            barre_Progression(ligne, nbrLignes, progression, tempsExecution, ...
        tempsRestant, tempsRestant_1);
        end
    
        // Reconstitution des colonnes
        try
            if configBase_N == 0 then
                donnee_mesure(ligne+1,:) = [msscanf(donnee(offset+ligne,1),...
                '%s %s %s') ""];
            elseif configHPHC_N == 0 then
                temp = [msscanf(donnee(offset+ligne,1),'%s %s %s %s %s')];
                donnee_mesure(ligne+1,:) = [temp(1) temp(3) temp(4) temp(5)];
                clear temp;
            end
        catch
            if configBase_N == 0 then
                donnee_mesure(ligne+1,:) = [msscanf(donnee(offset+ligne,1),...
                '%s %s') donnee_mesure(ligne,BASE) ""];
            elseif configHPHC_N == 0 then
                temp = [msscanf(donnee(offset+ligne,1),'%s %s %s %s')];
                donnee_mesure(ligne+1,:) = [temp(1) temp(2) temp(3) ""];
                clear temp;
            else
                disp(lasterror());
            end
        end
        
        // Conversion des chaines de caractères en nombre
        if ligne >= 2 then
            if configBase_N == 0 then
                if donnee_mesure(ligne,PAPP) <> "-" then
                    Papp(ligne-1,1) = evstr(donnee_mesure(ligne,PAPP));
                    // Enregistrement de la différence d'index
                    if ligne == 2 then
                        index_Base = evstr(donnee_mesure(ligne,BASE));
                    end
                    Base(ligne-1,1) = evstr(donnee_mesure(ligne,BASE)) ...
                                        - index_Base;
                    //Recopier la valeur de l'échantillon précédent
                    if Base(ligne-1,1) < 0 then
                        Base(ligne-1,1) = Base(ligne-2,1);
                    end
                    
                    //Invalide(ligne-1,1) = evstr(donnee_mesure(ligne,INVALIDE));
                end
                
            elseif configHPHC_N == 0 then
                if (donnee_mesure(ligne,HEUREPLEINE) <> "-" & ...
                    donnee_mesure(ligne,HEURECREUSE) <> "-") then
                    // Enregistrement de la différence d'index
                    if ligne == 2 then  // TODO: à MAJ lorsque le programme R-Pi sera mis à jour
                        index_Hpleines = evstr(donnee_mesure(2,HEUREPLEINE));
                        index_Hcreuses = evstr(donnee_mesure(2,HEURECREUSE));
                    end
                    Hpleines(ligne-1,1) = evstr(donnee_mesure(ligne,HEUREPLEINE)) ...
                                            - index_Hpleines;
                    Hcreuses(ligne-1,1) = evstr(donnee_mesure(ligne,HEURECREUSE)) ...
                                            - index_Hcreuses;

                    //Invalide(ligne-1,1) = evstr(donnee_mesure(ligne,INVALIDE));
                else
                    //Recopier la valeur de l'échantillon précédent
                    Hpleines(ligne-1,1) = Hpleines(ligne-2,1);
                    Hcreuses(ligne-1,1) = Hcreuses(ligne-2,1);
                end
            end
        end
    end
    
    // Courant max de la journée
    try
        ligne = offset+ligne+2;
        Imax = msscanf(donnee(ligne,1),'%s %s %s %s');
        Imax = evstr(Imax(IMAX));
        printf("Courant max sur la journée: %dA\n", Imax);
    catch
    end
    
    // Affichage des index
    if configBase_N == 0 then
        printf("Index à %s : %dkWh\n",donnee_mesure(2,HEURE),index_Base/1000);
    elseif configHPHC_N == 0 then
        printf("Index à %s :\n HC: %dkWh\n HP: %dkWh\n",...
                donnee_mesure(2,HEURE),index_Hcreuses/1000,index_Hpleines/1000);
    end
    
    Config = [configBase_N configHPHC_N];

    // Retourne
    if configBase_N == 0 then
        [Papp, index_Base, Base, nbrLignes, HEURE, Config, donnee_mesure, ...
        tempsExecution, tempsRestant_1] = resume(Papp, index_Base, Base, ...
        nbrLignes, HEURE, Config, donnee_mesure, tempsExecution, tempsRestant_1);
    elseif configHPHC_N == 0 then
        [index_Hpleines, Hpleines, index_Hcreuses, Hcreuses, nbrLignes, ...
        HEURE, Config, donnee_mesure, tempsExecution, tempsRestant_1] = ...
        resume(index_Hpleines, Hpleines, index_Hcreuses, Hcreuses, ...
        nbrLignes, HEURE, Config, donnee_mesure, tempsExecution, ...
        tempsRestant_1);
    else
        [nbrLignes, HEURE, Config, tempsExecution, tempsRestant_1] = ...
        resume(nbrLignes, HEURE, Config, donnee_mesure, tempsExecution, ...
        tempsRestant_1);
    end
endfunction
    
//*****************************************************************************
/// \brief Enregistre les variables dans un fichier .sod
/// \param [in] filePath    \c string   Chemin où enregistrer le fichier
/// Les variables suivantes sont sauvegardées
/// \li \var Gbl_CreationTxt
/// \li \var Gbl_NumCompteur
/// \li \var Gbl_Heure
/// \li \var Gbl_Papp
/// \li \var Gbl_Index
/// \li \var Gbl_Config
/// \li \var Gbl_Index0
//*****************************************************************************
function Sauve_Variables (filePath)
    originPath = pwd();
    // Enregistrement des variables dans Releves_aaaa-mm-jj.sod
    dateReleve = msscanf(Gbl_CreationTxt(1), '%c%c%c%c / %c%c / %c%c');
    dateReleve = [dateReleve(1)+dateReleve(2)+dateReleve(3)+dateReleve(4) dateReleve(5)+dateReleve(6) dateReleve(7)+dateReleve(8)];

    cd(filePath);
    fileName = strcat([Gbl_NumCompteur,"_",dateReleve(1),"-",dateReleve(2)...
    ,"-",dateReleve(3),".sod"]);
    save(fileName, "Gbl_CreationTxt", "Gbl_Heure", "Gbl_Papp", "Gbl_Index", ...
    "Gbl_NumCompteur", "Gbl_Config", "Gbl_Index0");
   
    printf("Variables sauvegardées dans %s\\%s\n", pwd(), fileName);
    cd(originPath);
endfunction
