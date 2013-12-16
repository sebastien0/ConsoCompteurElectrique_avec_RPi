clear;
clc;
// ************ Ouvertrue du fichier de point **********************************
// Répertoire par défaut
repertoire= "E:\Documents\Documents\Divers\Communication cpt Linky\Code\Compteur Linky\Compteur_Linky\Relevés";
// Selection du fichier à traiter
cheminFichier = uigetfile(["*.txt"],repertoire, "Choisir le fichier à ouvrir", %f);

// Si un fichier est bien sélectionné
if (cheminFichier ~= "") then
    disp(cheminFichier,"Ouverture du fichier");
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
    //CreationDate = evstr(CreationDateTxt);
    //CreationHeure = evstr(CreationHeureTxt);
    // Convertion date et heure d'une chaine de caractères en nombres
    //DateCreation = datenum(CreationDate(1,1)*1000+CreationDate(1,2)*100+..
    //CreationDate(1,3)*10+CreationDate(1,4),CreationDate(1,5)*10+CreationDate(1,6),...
    //CreationDate(1,7)*10+CreationDate(1,8),...
    //CreationHeure(1,1)*10+CreationHeure(1,2),CreationHeure(1,3)*10+...
    //CreationHeure(1,4),CreationHeure(1,5)*10+CreationHeure(1,6));
    //disp(round(datevec(DateCreation)),"Date et heure de création:");
    disp((CreationDateTxt + " " + CreationHeureTxt),"Date et heure de création:");
    
    // *** Conversion des donnée de chaine de caractère en valeur numérique *******
    disp("Extraction des données");
    donnee_mesure=msscanf(donnee(4,1),'%s %s %s %s');  // En têtes
    nbrLignes = size(donnee)-1;
    nbrLignes = nbrLignes(1,1)-offset;
    for ligne = 2:nbrLignes
    // ATTENTION, tel quel on ne récupère pas les Index ni invalide
        donnee_mesure(ligne,:)=msscanf(donnee(offset+ligne,1),'%s %s');
    end
    
    // *** Convertir les nombres au format string en double ***********************
    disp("Mise en forme des données");
    for ligne = 2:nbrLignes-1
        if donnee_mesure(ligne,PAPP) <> "-" then
        //    Base(ligne-1,1) = evstr(donnee_mesure(ligne,BASE));
            Papp(ligne-1,1) = evstr(donnee_mesure(ligne,PAPP));
        //    Invalide(ligne-1,1) = evstr(donnee_mesure(ligne,INVALIDE));
            temp = msscanf(donnee_mesure(ligne,HEURE),'%c%c:%c%c:%c%c');
            HeureEchantillon(ligne-1,:) = evstr(strcat(temp(1,:)));
//        sleep(50); //50ms
        end
    end
    //Imax = evstr(donnee_mesure(ligne,IMAX));    // Courrant max de la journée
    
    FermetureHeureTxt = temp(1) + temp(2) + ":" + temp(3) + temp(4) + ":" + temp(5) + temp(6);
    
    //clear CreationDate;
    //clear CreationHeure;
    //clear donnee;
    //clear temp;
    //clear donnee_mesure;
        
    disp("Pret à tracer",toc(),"Fin du traitement en secondes");
    
    // **** Tracer la puissance en fonction du temps ******************************
    plot(Papp);
    set(gca(),"grid",[1 1]);    // Grid on
    xtitle(["Puissance au cours de la journée";"Relevé du " + CreationDateTxt + " de " + ...
    CreationHeureTxt + " à " + FermetureHeureTxt],"Heure","Puissance en VA");
    
    // **** Ajouter les heures en abscisses ***********
    //* TODO: 
    //* - Obtenir la taille de la fenêtre pour ajuster au mieux
    //* - Raffraichir l'affichage si la taille change (plein écran/réduit)
    //*************************************************************************
    clear noms_labels;
    clear locations_labels;
       
    // TODO: UTILISER event handler functions (http://help.scilab.org/docs/5.3.3/en_US/eventhandlerfunctions.html) pour avoir un zoom dynamique.
    fenetre = gcf();
    fenetre.figure_name = "Puissance apparente"
    fenetre.figure_size = floor(fenetre.figure_size*1.3);
    
    graphique = gca();
    //Augmenter la taille des textes
    graphique.title.font_size = 3;
    graphique.x_label.font_size = 2;
    graphique.y_label.font_size = 2;
    // Ajustement de la zone d'affichage
    graphique.tight_limits = "on";
    graphique.data_bounds(1,2) = 0;
    // multiple de 500 pour affichage en réduit
    graphique.data_bounds(2,2) = ceil(graphique.data_bounds(2,2)/200)*200;

    //Obtenir le pas du quadrillage vertical
    if fenetre.figure_size(1) <=700 then
        x_pas = size(graphique.x_ticks.locations);
        x_pas = x_pas(1);
    else
        x_pas = 10;   //Affichage plein écran
    end
    increment = floor(nbrLignes/x_pas);

    for i = 1:(x_pas+1)
        locations_labels(i)= (i-1)*increment;
        noms_labels(i) = donnee_mesure((i-1)*increment+2);
    end
    
    // Effectuer la mise à jour des abscisses
    graphique.x_ticks = tlist(["ticks" "locations" "labels"],locations_labels,noms_labels);


end
resume;
