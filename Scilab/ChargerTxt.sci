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
        
        // ******* Obtention de la date et l'heure ************************************
        offset = 5; // Ligne des en-tête de colonnes
        HEURE = 1;  // Colonne contenant l'heure
        PAPP = 2;   // Colonne contenant la puissance apparente
        BASE = 3;   // Colonne contenant l'index Base
        IMAX = 4;   // Colonne contenant le courant max journalier
        INVALIDE = 4;   // Colonne contenant l'invalidité de la trame
        
        //Date du relevé
        Creation = msscanf(donnee(1,1),'%s %s %s %s');
        CreationDateTxt = msscanf(Creation(1,3),'%c%c%c%c/%c%c/%c%c');
        CreationDateTxt = CreationDateTxt(1) + CreationDateTxt(2) + CreationDateTxt(3) + CreationDateTxt(4)+ "/" + CreationDateTxt(5) + CreationDateTxt(6) + "/" + CreationDateTxt(7) + CreationDateTxt(8);
        
        CreationHeureTxt = msscanf(Creation(1,4),'%c%c:%c%c:%c%c');
        CreationHeureTxt = CreationHeureTxt(1) + CreationHeureTxt(2) + ":" + CreationHeureTxt(3) + CreationHeureTxt(4) + ":" + CreationHeureTxt(5) + CreationHeureTxt(6);
    
        disp("Relevé créé le " + CreationDateTxt + " à " + CreationHeureTxt);
        
        // *** Conversion des donnée de chaine de caractère en valeur numérique *******
        disp("Extraction des données ...");
        donnee_mesure = msscanf(donnee(offset,1),'%s %s %s %s');  // En têtes
        nbrLignes = size(donnee)-1;
        nbrLignes = nbrLignes(1,1)-offset;
        for ligne = 1:(nbrLignes-1)
            // Récupération de la Puissance et dess Index
            try
                donnee_mesure(ligne+1,:) = [msscanf(donnee(offset+ligne,1),'%s %s %s') ""];
            catch
                donnee_mesure(ligne+1,:) = [msscanf(donnee(offset+ligne,1),'%s %s') donnee_mesure(ligne,BASE) ""];
            end
        end
        // Courrant max de la journée
        ligne = offset+ligne+2;
        Imax = msscanf(donnee(ligne,1),'%s %s %s %s');
        Imax = evstr(Imax(IMAX));
        disp("Courant max sur la journée: " + string(Imax) + " A");
        sleep(1);   //Pause 1ms
                
        // *** Convertir les nombres au format string en double ***********************
        disp("Mise en forme des données ...");
        for ligne = 2:nbrLignes-1
            if donnee_mesure(ligne,PAPP) <> "-" then
                Papp(ligne-1,1) = evstr(donnee_mesure(ligne,PAPP));
                Base(ligne-1,1) = evstr(donnee_mesure(ligne,BASE));
            //    Invalide(ligne-1,1) = evstr(donnee_mesure(ligne,INVALIDE));
            end
        end
        temp = msscanf(donnee_mesure(ligne,HEURE),'%c%c:%c%c:%c%c');
        FermetureHeureTxt = temp(1) + temp(2) + ":" + temp(3) + temp(4) + ":" + temp(5) + temp(6);
        
        CreationTxt(1) = CreationDateTxt;
        CreationTxt(2) = CreationHeureTxt;
        CreationTxt(3) = FermetureHeureTxt;
        
        disp("Fin du traitement en " + string(toc()) + " secondes");
    end
endfunction
    
