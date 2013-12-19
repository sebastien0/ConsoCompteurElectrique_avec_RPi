function tracerGraph(CreationTxt, Papp, donnee_mesure)
// **** Tracer la puissance en fonction du temps ******************************
    nbrLignes = size(Papp);
    nbrLignes = nbrLignes(1);
    
    plot(Papp);
    set(gca(),"grid",[1 1]);    // Grid on
    xtitle(["Puissance au cours de la journée";"Relevé du " + CreationDateTxt + " de " + ...
    CreationHeureTxt + " à " + FermetureHeureTxt],"Heure","Puissance en VA");
        
    //*************************************************************************
    //* TODO: 
    //* - Obtenir la taille de la fenêtre pour ajuster au mieux
    //* - Raffraichir l'affichage si la taille change (plein écran/réduit)
    // UTILISER event handler functions (http://help.scilab.org/docs/5.3.3/en_US/eventhandlerfunctions.html) pour avoir un zoom dynamique.
    //*************************************************************************
    clear noms_labels;
    clear locations_labels;
       
    fenetre = gcf();
    fenetre.figure_name = "Puissance apparente";
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
    if fenetre.figure_size(1) <= 700 then
        x_pas = size(graphique.x_ticks.locations);
        x_pas = x_pas(1);
    else
        x_pas = 17;   //Affichage plein écran
    end
    increment = floor(nbrLignes/x_pas);

    for i = 1:(x_pas+1)
        locations_labels(i)= (i-1)*increment;
        noms_labels(i) = donnee_mesure((i-1)*increment+2);
    end
    
    // Effectuer la mise à jour des abscisses
    graphique.x_ticks = tlist(["ticks" "locations" "labels"],locations_labels,noms_labels);
endfunction
