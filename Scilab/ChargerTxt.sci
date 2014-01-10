function ChargerTxt (dataPath)
    // Selection du fichier à traiter
    cheminFichier = uigetfile(["*.txt"],dataPath, "Choisir le fichier à ouvrir", %f);
    
    // Si un fichier est bien sélectionné
    if (cheminFichier ~= "") then
        fichierOuvert = 1;
        disp("Ouverture du fichier " + cheminFichier);
        BarreProgression = progressionbar('Import en cours: 0% fait');
        tic;

        fichier = mopen(cheminFichier,'r'); // Ouverture du fichier
        donnee = mgetl(cheminFichier);  // Lecture du fichier
        mclose(cheminFichier);  // Fermeture du fichier
        
        // ***** Identification configuration Base ou HPHC ********************
        try
            titres = msscanf(donnee(5,1),'%s %s %s %s %s %s %s');
        catch
            try
                titres = msscanf(donnee(5,1),'%s %s %s %s');
            catch
                disp(lasterror());
            end
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
        if configHPHC_N == 0 then
            disp("Compteur configuré en HCHP");
        end
        
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
    
        disp("Relevé créé le " + CreationDateTxt + " à " + CreationHeureTxt + " par le compteur n°" + NumCompteur);
        
        // *** Conversion des donnée de chaine de caractère en valeur numérique *******
        disp("Extraction et mise en forme des données ...");
        
        // En tête des colonnes
        if configBase_N == 0 then
            donnee_mesure = msscanf(donnee(offset,1),'%s %s %s %s');
        elseif configHPHC_N == 0 then
            temp = msscanf(donnee(offset,1),'%s %s %s %s %s %s %s');
            donnee_mesure = [temp(1) temp(3)+" "+temp(4) temp(5)+" "+temp(6) temp(7)];
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
            progressionbar(BarreProgression, 'Import en cours, ' + string(round(ligne*100/nbrLignes)) + '% fait');
            // TODO: temps restant approximatif

            // Reconstitution des colonnes
            try
                if configBase_N == 0 then
                    donnee_mesure(ligne+1,:) = [msscanf(donnee(offset+ligne,1),'%s %s %s') ""];
                elseif configHPHC_N == 0 then
                    temp = [msscanf(donnee(offset+ligne,1),'%s %s %s %s %s')];
                    donnee_mesure(ligne+1,:) = [temp(1) temp(3) temp(4) temp(5)];
                    clear temp;
                end
            catch
                if configBase_N == 0 then
                    donnee_mesure(ligne+1,:) = [msscanf(donnee(offset+ligne,1),'%s %s') donnee_mesure(ligne,BASE) ""];
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
        end

        // Courant max de la journée
        try
            ligne = offset+ligne+2;
            Imax = msscanf(donnee(ligne,1),'%s %s %s %s');
            Imax = evstr(Imax(IMAX));
            disp("Courant max sur la journée: " + string(Imax) + " A");
        catch
        end
        
        FermetureHeureTxt = msscanf(donnee_mesure(nbrLignes-1,HEURE),'%s');
        
        CreationTxt = [CreationDateTxt; CreationHeureTxt; FermetureHeureTxt];
        Config = [configBase_N configHPHC_N 0];
        
        disp("Fin du traitement en " + string(ceil(toc())) + " secondes");
    else
        fichierOuvert = 0;
        Config = zeros(1,2);
        disp("Aucun fichier sélectionné");
    end
    
    // ****** Retour des variables ********************************************
    if fichierOuvert <> 0 then
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
        CreationTxt = zeros(1);
        donnee_mesure = zeros(1);
        Papp = zeros(1);
        Base = zeros(1);
        NumCompteur = zeros(1);
    end
    
    [Gbl_CreationTxt, Gbl_donnee_mesure, Gbl_Papp, Gbl_Index, Gbl_NumCompteur, Gbl_Config] = resume (CreationTxt, donnee_mesure, Papp, Base, NumCompteur, Config);
endfunction
    
function SauveVariables (filePath)
    originPath = pwd();
    // Enregistrement des variables dans Releves_aaaa-mm-jj.sod
    temp = msscanf(Gbl_CreationTxt(1), '%c%c%c%c / %c%c / %c%c');
    temp = [temp(1)+temp(2)+temp(3)+temp(4) temp(5)+temp(6) temp(7)+temp(8)];
//    filePath = dataPath+"\Releves_"+temp(1)+"-"+temp(2)+"-"+temp(3)+".sod";
    cd(filePath);
    fileName = "Releves_"+temp(1)+"-"+temp(2)+"-"+temp(3)+".sod";
    save(fileName,"Gbl_CreationTxt", "Gbl_donnee_mesure", "Gbl_Papp", "Gbl_Index", "Gbl_NumCompteur", "Gbl_Config");
   
   cd(originPath);
    disp("Variables sauvegardées dans " + pwd() + "\" + fileName);
endfunction
