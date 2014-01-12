function ChargerTxt (dataPath)
    // Selection du fichier à traiter
    cheminFichier = uigetfile(["*.txt"],dataPath, ...
    "Choisir le fichier à ouvrir", %f);
    
    // Si un fichier est bien sélectionné
    if (cheminFichier ~= "") then
        // Initialisation des variables
        fichierOuvert = 1;
        tempsExecution = 0;
        progression = -1;
        
        printf("Ouverture du fichier %s \n", cheminFichier);
        BarreProgression = progressionbar('Import en cours: 0% fait');
        tic;

        fichier = mopen(cheminFichier,'r'); // Ouverture du fichier
        donnee = mgetl(cheminFichier);  // Lecture du fichier
        mclose(cheminFichier);  // Fermeture du fichier
        
        // ***** Identification configuration Base ou HPHC ********************
        configuration(donnee);

        
        // ******* Obtention de la date et l'heure ****************************
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
        
        //Date du relevé
        Creation = msscanf(donnee(1,1),'%s %s %s %s');
        CreationDateTxt = msscanf(Creation(1,3),'%s');
        CreationHeureTxt = msscanf(Creation(1,4),'%s');
    
        // Numéro du compteur
        temp = msscanf(donnee(3,1),'%s n°%s');
        NumCompteur = temp(1,2);
        clear temp;
    
        printf("\nRelevé créé le %s à %s par le compteur n°%s\n", ...
        CreationDateTxt, CreationHeureTxt, NumCompteur);
        
        // *** Conversion des donnée de chaine de caractère en valeur numérique *******
        printf("Extraction et mise en forme des données ...\n");
        
        // En tête des colonnes
        if configBase_N == 0 then
            donnee_mesure = msscanf(donnee(offset,1),'%s %s %s %s');
        elseif configHPHC_N == 0 then
            temp = msscanf(donnee(offset,1),'%s %s %s %s %s %s %s');
            donnee_mesure = [temp(1) temp(3)+" "+temp(4) temp(5)+" "+ ...
            temp(6) temp(7)];
            clear temp;
        end

        nbrLignes = size(donnee)-1;
        nbrLignes = nbrLignes(1,1)-offset;
        
        //Création de matrices vides
        donnee_mesure(nbrLignes,:) = ["" "" "" ""];
        if configBase_N == 0 then
            Papp = zeros(nbrLignes,1);
            Base = zeros(nbrLignes,1);
        elseif configHPHC_N == 0 then
            Hpleines = zeros(nbrLignes,1);
            Hcreuses = zeros(nbrLignes,1);
        end

        for ligne = 1:(nbrLignes-1)
            // Barre de progression
            if (floor(ligne*100/nbrLignes) > progression) then
                // Calcul du temps restant
                progression = progression + 1;
                tempsExecution = tempsExecution + toc();
                tic;
                // Ajuster le coef (145 - progression) pour approximer le temps réel écoulé
                tempsRestant = (tempsExecution / (progression + 1)) * ...
                 (145 - progression);
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
                        Base(ligne-1,1) = evstr(donnee_mesure(ligne,BASE));
                        //Invalide(ligne-1,1) = evstr(donnee_mesure(ligne,INVALIDE));
                    end
                    
                elseif configHPHC_N == 0 then
                    if (donnee_mesure(ligne,HEUREPLEINE) <> "-" & ...
                        donnee_mesure(ligne,HEURECREUSE) <> "-") then
                        if ligne == 2 then  // TODO: à MAJ lorsque le programme R-Pi sera mis à jour
                            index_Hpleines = evstr(donnee_mesure(2,HEUREPLEINE));
                            index_Hcreuses = evstr(donnee_mesure(2,HEURECREUSE));
                        else
                            Hpleines(ligne-1,1) = evstr(donnee_mesure(ligne,HEUREPLEINE)) - index_Hpleines;
                            Hcreuses(ligne-1,1) = evstr(donnee_mesure(ligne,HEURECREUSE)) - index_Hcreuses;
                        end
                        //Invalide(ligne-1,1) = evstr(donnee_mesure(ligne,INVALIDE));
                    else
                        //Recopier la valeur de l'échantillon précédent pour ne pas avoir de 0 dans le tableau
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
        
        FermetureHeureTxt = msscanf(donnee_mesure(nbrLignes-1,HEURE),'%s');
        
        CreationTxt = [CreationDateTxt; CreationHeureTxt; FermetureHeureTxt];
        Config = [configBase_N configHPHC_N 0];
        
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
            //NOP
        elseif configHPHC_N == 0 then
            Base = [Hpleines Hcreuses];
            Papp = zeros(1);
        else
            CreationTxt = zeros(1);
            donnee_mesure = zeros(1);
            Papp = zeros(1);
            Base = zeros(1);
            NumCompteur = zeros(1);
        end
        close(BarreProgression);
    else
        Heure = zeros(1);
        CreationTxt = zeros(1);
        donnee_mesure = zeros(1);
        Papp = zeros(1);
        Base = zeros(1);
        NumCompteur = zeros(1);
    end
    
    [Gbl_CreationTxt, Gbl_Heure, Gbl_Papp, Gbl_Index, Gbl_NumCompteur, ...
    Gbl_Config] = resume (CreationTxt, Heure, Papp, Base, NumCompteur, Config);
endfunction


//* ***************************************************************************
//*
//*
//*
//*****************************************************************************
function configuration(donnee)
    // Lecture des en-têtes de colonnes
    try
        titres = msscanf(donnee(5,1),'%s %s %s %s %s %s %s');
    catch
        try
            titres = msscanf(donnee(5,1),'%s %s %s %s');
        catch
            disp(lasterror());
        end
    end
    
    // Détectionde la configuration en Base ou HCHP
    temp = titres(3);
    configBase_N = strcmp('Base',temp); // =0 si compteur en Base 
    if configBase_N <> 0 then
        temp = titres(3) + titres(4);
    else
        printf("Compteur configuré en Base\n");
    end

    configHPHC_N = strcmp('Hcreuses',temp); // =0 si compteur en HCHP 
    if configHPHC_N == 0 then
        printf("Compteur configuré en HCHP\n");
    end

    // Retour des variables
    [titres, configBase_N, configHPHC_N] = resume(titres, configBase_N, configHPHC_N);
endfunction


    
//* ***************************************************************************
//*
//*
//*
//*****************************************************************************
function SauveVariables (filePath)
    originPath = pwd();
    // Enregistrement des variables dans Releves_aaaa-mm-jj.sod
    temp = msscanf(Gbl_CreationTxt(1), '%c%c%c%c / %c%c / %c%c');
    temp = [temp(1)+temp(2)+temp(3)+temp(4) temp(5)+temp(6) temp(7)+temp(8)];
//    filePath = dataPath+"\Releves_"+temp(1)+"-"+temp(2)+"-"+temp(3)+".sod";
    cd(filePath);
    fileName = Gbl_NumCompteur + "_"+temp(1)+"-"+temp(2)+"-"+temp(3)+".sod";
    save(fileName,"Gbl_CreationTxt", "Gbl_Heure", "Gbl_Papp", "Gbl_Index", ...
    "Gbl_NumCompteur", "Gbl_Config");
   
   cd(originPath);
    printf("Variables sauvegardées dans %s\\%s\n", pwd(), fileName);
endfunction
