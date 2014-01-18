//* ***************************************************************************
//* Tracer une courbe
//*
//*
//*****************************************************************************
function tracer_Graph(data2plot, NumCompteur, Titre, Config)
    if Config <> 0 then
        // **** Tracer la puissance en fonction du temps **********************
        nbrLignes = size(data2plot);
        nbrLignes = nbrLignes(1);
        
        plot(data2plot);
        fenetre = gcf();
        graphique = gca();
        
        if Config == 1 then
            mise_en_forme(graphique, fenetre, Titre, "Puissance en VA");
        
        elseif Config == 2 then
            mise_en_forme(graphique, fenetre, Titre, "Variation d''index en Wh");
        end
    
        //*********************************************************************
        //* TODO: 
        //* - Obtenir la taille de la fenêtre pour ajuster au mieux
        //* - Raffraichir l'affichage si la taille change (plein écran/réduit)
        // UTILISER event handler functions 
        // (http://help.scilab.org/docs/5.3.3/en_US/eventhandlerfunctions.html) 
        // pour avoir un zoom dynamique.
        //*************************************************************************

        // Ajouter les heures sur les abscisses
        heures_Abscisses(nbrLignes, fenetre, graphique);
        printf("Graph tracé\n");
    else
        printf("Erreur de config\n");
    end
endfunction

//* ***************************************************************************
//* Afficher les abscisses en temps
//*
//*
//*****************************************************************************
function heures_Abscisses(nbrLignes, fenetre, graphique)
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
        noms_labels(i) = Gbl_Heure((i-1)*increment+2);
    end
    
    // Effectuer la mise à jour des abscisses
    graphique.x_ticks = tlist(["ticks" "locations" "labels"],...
    locations_labels, noms_labels);
endfunction


//* ***************************************************************************
//* Mise en forme du graphique
//*
//*
//*****************************************************************************
function mise_en_forme(graphique, fenetre, titre1, titre2)
    set(graphique,"grid",[1 1]);    // Grid on
    
    // Titre du graphique
    xtitle([titre1;"Relevé du " + Gbl_CreationTxt(1) + " de " + ...
    Gbl_CreationTxt(2) + " à " + Gbl_CreationTxt(3);"Par le compteur " + ...
    NumCompteur],"Heure",titre2);

    //*********************************************************************
    //* TODO: 
    //* - Obtenir la taille de la fenêtre pour ajuster au mieux
    //* - Raffraichir l'affichage si la taille change (plein écran/réduit)
    // UTILISER event handler functions 
    // (http://help.scilab.org/docs/5.3.3/en_US/eventhandlerfunctions.html) 
    // pour avoir un zoom dynamique.
    //*************************************************************************

    fenetre.figure_name = "Graphiques";
    fenetre.figure_size = floor(fenetre.figure_size*1.3);

    //Augmenter la taille des textes
    graphique.title.font_size = 3;
    graphique.x_label.font_size = 2;
    graphique.y_label.font_size = 2;
    // Ajustement de la zone d'affichage
    graphique.tight_limits = "on";
    graphique.data_bounds(1,2) = 0;
    // multiple de 500 pour affichage en réduit
    graphique.data_bounds(2,2) = ceil(graphique.data_bounds(2,2)/200 + ...
    1)*200;
endfunction


//* ***************************************************************************
//* Tracer 2 courbes
//*
//*
//*****************************************************************************
function tracer_2_Graph(Puissance, Index, NumCompteur)
    nbrLignes = size(Index);
    nbrLignes = nbrLignes(1);
    
    //*** Puissance ******************
    subplot(211);
    plot(Puissance);
    
    graphique = gca();
    fenetre = gcf();
    //Ajouter le quadrillage, les titres, ...
    mise_en_forme(graphique, fenetre, "Puissance apparente", "Puissance en VA");
    // Ajouter les heures sur les abscisses
    heuresAbscisses(nbrLignes, fenetre, graphique);
    
    //*** Index *********************
    subplot(212);
    plot(Index);
    
    graphique = gca();
    fenetre = gcf();
    //Ajouter le quadrillage, les titres, ...
    mise_en_forme(graphique, fenetre, ...
    "Index des consommations Heures pleines et creuses", ...
    "Variation d''index en Wh");
    // Ajouter les heures sur les abscisses
    heures_Abscisses(nbrLignes, fenetre, graphique);
    
    printf("Graphiques tracés\n");
endfunction
