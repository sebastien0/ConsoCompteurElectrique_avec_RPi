function ChargerTxt (dataPath)
    // Selection du fichier à traiter
    cheminFichier = uigetfile(["*.txt"],dataPath, "Choisir le fichier à ouvrir", %f);
    
    // Si un fichier est bien sélectionné
    if (cheminFichier ~= "") then
        disp(cheminFichier,"Ouverture du fichier:");
        tic;
        // Ouverture du fichier
        fichier=mopen(cheminFichier,'r');
        // Lecture du fichier
        donnee=mgetl(cheminFichier);
        // Fermeture du fichier
        mclose(cheminFichier);
        
        // ******* Obtention de la date et l'heure ************************************
        offset = 4; // 1ère ligne de données
        HEURE = 1;  // Colonne contenant l'heure
        PAPP = 2;   // Colonne contenant la puissance apparente
        BASE = 3;   // Colonne contenant l'index Base
        INVALIDE = 4;   // Colonne contenant l'invalidité de la trame
        
        //Date du relevé
        Creation = msscanf(donnee(1,1),'%s %s %s %s');
        CreationDateTxt = msscanf(Creation(1,3),'%c%c%c%c/%c%c/%c%c');
        CreationDateTxt = CreationDateTxt(1) + CreationDateTxt(2) + CreationDateTxt(3) + CreationDateTxt(4)+ "/" + CreationDateTxt(5) + CreationDateTxt(6) + "/" + CreationDateTxt(7) + CreationDateTxt(8);
        
        CreationHeureTxt = msscanf(Creation(1,4),'%c%c:%c%c:%c%c');
        CreationHeureTxt = CreationHeureTxt(1) + CreationHeureTxt(2) + ":" + CreationHeureTxt(3) + CreationHeureTxt(4) + ":" + CreationHeureTxt(5) + CreationHeureTxt(6);
    
        disp((CreationDateTxt + " " + CreationHeureTxt),"Date et heure de création:");
        
        // *** Conversion des donnée de chaine de caractère en valeur numérique *******
        disp("Extraction des données ...");
        donnee_mesure = msscanf(donnee(4,1),'%s %s %s %s');  // En têtes
        nbrLignes = size(donnee)-1;
        nbrLignes = nbrLignes(1,1)-offset;
        for ligne = 2:nbrLignes
        // ATTENTION, tel quel on ne récupère pas les Index ni invalide
            donnee_mesure(ligne,:) = msscanf(donnee(offset+ligne,1),'%s %s');
        end
        sleep(1);   //Pause 1ms
                
        // *** Convertir les nombres au format string en double ***********************
        disp("Mise en forme des données ...");
        for ligne = 2:nbrLignes-1
            if donnee_mesure(ligne,PAPP) <> "-" then
            //    Base(ligne-1,1) = evstr(donnee_mesure(ligne,BASE));
                Papp(ligne-1,1) = evstr(donnee_mesure(ligne,PAPP));
            //    Invalide(ligne-1,1) = evstr(donnee_mesure(ligne,INVALIDE));
            end
        end
        temp = msscanf(donnee_mesure(ligne,HEURE),'%c%c:%c%c:%c%c');
        //Imax = evstr(donnee_mesure(ligne,IMAX));    // Courrant max de la journée
        
        FermetureHeureTxt = temp(1) + temp(2) + ":" + temp(3) + temp(4) + ":" + temp(5) + temp(6);
        
        CreationTxt(1) = CreationDateTxt;
        CreationTxt(2) = CreationHeureTxt;
        CreationTxt(3) = FermetureHeureTxt;
        
        disp("Pret à tracer",toc(),"Fin du traitement en secondes");
    end
endfunction
    
