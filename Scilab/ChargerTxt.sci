function ChargerTxt (dataPath)
    // Selection du fichier à traiter
    cheminFichier = uigetfile(["*.txt"],dataPath, "Choisir le fichier à ouvrir", %f);
    
    // Si un fichier est bien sélectionné
    if (cheminFichier ~= "") then
        disp("Ouverture du fichier " + cheminFichier);
        tic;

        fichier = mopen(cheminFichier,'r'); // Ouverture du fichier
        donnee = mgetl(cheminFichier);  // Lecture du fichier
        mclose(cheminFichier);  // Fermeture du fichier
        
        // ***** Identification configuration Base ou HPHC ********************
        try
            titres = msscanf(donnee(5,1),'%s %s %s %s %s %s %s');
        catch
            titres = msscanf(donnee(5,1),'%s %s %s %s');
        end
        temp = titres(3);
        configBase_N = strcmp('Base',temp); // =0 si compteur en Base 
        if configBase_N <> 0 then
            temp = titres(3) + titres(4);
        else
            disp("Compteur configuré en Base");
        end
        configHPHC_N = strcmp('Hcreuses',temp); // =0 si compteur en HCHP 
        clear temp;
        if configHPHC_N = 0 then
            disp("Compteur configuré en HCHP");
        end
        
        // ******* Obtention de la date et l'heure ****************************
        offset = 5; // Ligne des en-tête de colonnes
        HEURE = 1;  // Colonne contenant l'heure
        IMAX = 4;   // Colonne contenant le courant max journalier
        INVALIDE = 4;   // Colonne contenant l'invalidité de la trame
        if configBase_N = 0 then
            PAPP = 2;   // Colonne contenant la puissance apparente
            BASE = 3;   // Colonne contenant l'index Base
        elseif configHPHC_N then
            HEURECREUSE = 2;   // Colonne contenant l'index Heure Creuse
            HEUREPLEINE = 3;   // Colonne contenant l'index Heure Pleine
        end
        
        //Date du relevé
        Creation = msscanf(donnee(1,1),'%s %s %s %s');
        CreationDateTxt = msscanf(Creation(1,3),'%c%c%c%c/%c%c/%c%c');
        CreationDateTxt = CreationDateTxt(1) + CreationDateTxt(2) + CreationDateTxt(3) + CreationDateTxt(4)+ "/" + CreationDateTxt(5) + CreationDateTxt(6) + "/" + CreationDateTxt(7) + CreationDateTxt(8);
        
        CreationHeureTxt = msscanf(Creation(1,4),'%c%c:%c%c:%c%c');
        CreationHeureTxt = CreationHeureTxt(1) + CreationHeureTxt(2) + ":" + CreationHeureTxt(3) + CreationHeureTxt(4) + ":" + CreationHeureTxt(5) + CreationHeureTxt(6);
    
        // Numéro du compteur
        temp = msscanf(donnee(3,1),'%s %s');
        NumCompteur = temp(1,2);
        clear temp;
    
        disp("Relevé créé le " + CreationDateTxt + " à " + CreationHeureTxt + " par le compteur " + NumCompteur);
        
        // *** Conversion des donnée de chaine de caractère en valeur numérique *******
        disp("Extraction des données ...");
        
        // En tête des colonnes
        if configBase_N = 0 then
            donnee_mesure = msscanf(donnee(offset,1),'%s %s %s %s');
        elseif configHPHC_N = 0 then
            temp = msscanf(donnee(offset,1),'%s %s %s %s %s %s %s');
            donnee_mesure = [temp(1) temp(3)+" "+temp(4) temp(5)+" "+temp(6) temp(7)];
            clear temp;
        end

        nbrLignes = size(donnee)-1;
        nbrLignes = nbrLignes(1,1)-offset;
        for ligne = 1:(nbrLignes-1)
            // Récupération de la Puissance et des Index
            try
                if configBase_N = 0 then
                    donnee_mesure(ligne+1,:) = [msscanf(donnee(offset+ligne,1),'%s %s %s') ""];
                elseif configHPHC_N = 0 then
                    temp = [msscanf(donnee(offset+ligne,1),'%s %s %s %s %s')];
                    donnee_mesure(ligne+1,:) = [temp(1) temp(3) temp(4) temp(5)];
                    clear temp;
                end
            catch
                if configBase_N = 0 then
                    donnee_mesure(ligne+1,:) = [msscanf(donnee(offset+ligne,1),'%s %s') donnee_mesure(ligne,BASE) ""];
                elseif configHPHC_N = 0 then
                    temp = [msscanf(donnee(offset+ligne,1),'%s %s %s %s')];
                    donnee_mesure(ligne+1,:) = [temp(1) temp(2) temp(3) ""];
                    clear temp;
            end
        end

        // Courant max de la journée
        try
            ligne = offset+ligne+2;
            Imax = msscanf(donnee(ligne,1),'%s %s %s %s');
            Imax = evstr(Imax(IMAX));
            disp("Courant max sur la journée: " + string(Imax) + " A");
        catch
        end
        sleep(1);   //Pause 1ms
                
        // *** Convertir les nombres au format string en double ***************
        disp("Mise en forme des données ...");
        for ligne = 2:nbrLignes-1
            if configBase_N = 0 then
                if donnee_mesure(ligne,PAPP) <> "-" then
                    Papp(ligne-1,1) = evstr(donnee_mesure(ligne,PAPP));
                    Base(ligne-1,1) = evstr(donnee_mesure(ligne,BASE));
                    //Invalide(ligne-1,1) = evstr(donnee_mesure(ligne,INVALIDE));
                end
                
            elseif configHPHC_N = 0 then
                if (donnee_mesure(ligne,HEUREPLEINE) <> "-" & donnee_mesure(ligne,HEURECREUSE) <> "-") then
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
        
        temp = msscanf(donnee_mesure(ligne,HEURE),'%c%c:%c%c:%c%c');
        FermetureHeureTxt = temp(1) + temp(2) + ":" + temp(3) + temp(4) + ":" + temp(5) + temp(6);
        clear temp;
        
        CreationTxt(1) = CreationDateTxt;
        CreationTxt(2) = CreationHeureTxt;
        CreationTxt(3) = FermetureHeureTxt;
        
        Gbl_Config = [configBase_N configHPHC_N];
        
        disp("Fin du traitement en " + string(toc()) + " secondes");
    end
    
    // ****** Retour des variables ********************************************
    // Retourner Gbl_Index = Base ou Gbl_Index = [Hpleines Hcreuses]
    if configBase_N = 0 then
        [Gbl_CreationTxt, Gbl_donnee_mesure, Gbl_Papp, Gbl_Base, Gbl_NumCompteur, Gbl_Config] = resume (CreationTxt, donnee_mesure, Papp, Base, NumCompteur);
    elseif configHPHC_N = 0 then
        [Gbl_CreationTxt, Gbl_donnee_mesure, Gbl_Hpleines, Gbl_Hcreuses, Gbl_NumCompteur, Gbl_Config] = resume (CreationTxt, donnee_mesure, Hpleines, Hcreuses, NumCompteur);
    end
endfunction
    
