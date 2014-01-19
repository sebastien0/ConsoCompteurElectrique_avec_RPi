//* ***************************************************************************
//* Tracer une courbe
//*
//*
//*****************************************************************************
function tracer_Graph(data2plot, NumCompteur, Titre)
    // **** Tracer la puissance en fonction du temps **********************
    nbrLignes = size(data2plot);
    nbrLignes = nbrLignes(1);
    
    plot(data2plot, 'r');
    fenetre = gcf();
    graphique = gca();
    
    mise_en_forme(graphique, fenetre, Titre, "Puissance en VA");
        
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
    printf("Puissance apparente tracée\n");
endfunction

//* ***************************************************************************
//* Afficher les abscisses en temps
//*
//*
//*****************************************************************************
function heures_Abscisses(nbrLignes, fenetre, graphique)
    //Obtenir le pas du quadrillage vertical
//    if fenetre.figure_size(1) <= 700 then
//        x_pas = size(graphique.x_ticks.locations);
//        x_pas = x_pas(1);
//    else
        x_pas = 17;   //Affichage plein écran
//    end
    increment = floor(nbrLignes/x_pas);
    
    for i = 1:(x_pas+1)
        locations_labels(i)= (i-1)*increment;
        noms_labels(i) = Gbl_Heure((i-1)*(increment-1)+1);
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
//titre1 = "Puissance apparente"; titre2 = "Puissance en VA";
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
    fenetre.figure_size = floor(fenetre.figure_size*1.1);

    //Augmenter la taille des textes
    graphique.title.font_size = 3;
    graphique.x_label.font_size = 2;
    graphique.y_label.font_size = 2;
    // Ajustement de la zone d'affichage
    graphique.tight_limits = "on";
    graphique.data_bounds(1,2) = 0;
    // multiple de 200 pour affichage en réduit
    ordonneeMax = graphique.data_bounds(2,2);
    if ordonneeMax < 500 then
        graphique.data_bounds(2,2) = ceil(ordonneeMax*1.2) - ...
         modulo(ceil(ordonneeMax*1.2),5);
    else
        graphique.data_bounds(2,2) = ceil(graphique.data_bounds(2,2)/200 + ...
    1)*200;
        end
endfunction


//* ***************************************************************************
//* Tracer 2 courbes
//*
//*
//*****************************************************************************
//Puissance = Gbl_Papp; Index = Gbl_Index; NumCompteur = Gbl_NumCompteur;
function tracer_2_Graph(Puissance, Index, NumCompteur)
    nbrLignes = size(Index);
    nbrLignes = nbrLignes(1);
    
    //*** Puissance ******************
    subplot(211);
    plot(Puissance, 'r');
    
    graphique = gca();
    fenetre = gcf();
    //Ajouter le quadrillage, les titres, ...
    mise_en_forme(graphique, fenetre, "Puissance apparente", "Puissance en VA");
    // Ajouter les heures sur les abscisses
    heures_Abscisses(nbrLignes, fenetre, graphique);
    
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
    tailleIndex = size(Index);
    if tailleIndex(2) > 1 then
        legende = legend(["Index heures creuses"; "Index heures pleines"],2);
        legende.font_size = 3;
    end
    printf("Graphiques tracés\n");
endfunction
