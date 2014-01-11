function tracerGraph(data2plot, NumCompteur, Titre, Config)
    if Config <> 0 then
        // **** Tracer la puissance en fonction du temps ******************************
        disp("Tracer le graph ...");
        nbrLignes = size(data2plot);
        nbrLignes = nbrLignes(1);
        
        plot(data2plot);
        set(gca(),"grid",[1 1]);    // Grid on
        if Config == 1 then
            xtitle([Titre;"Relevé du " + Gbl_CreationTxt(1) + " de " + ...
        Gbl_CreationTxt(2) + " à " + Gbl_CreationTxt(3);"Par le compteur " + NumCompteur],"Heure","Puissance en VA");
        
        elseif Config == 2 then
            xtitle([Titre;"Relevé du " + Gbl_CreationTxt(1) + " de " + ...
        Gbl_CreationTxt(2) + " à " + Gbl_CreationTxt(3);"Par le compteur " + NumCompteur],"Heure","Variation d''index en Wh");
        end
    
        //*************************************************************************
        //* TODO: 
        //* - Obtenir la taille de la fenêtre pour ajuster au mieux
        //* - Raffraichir l'affichage si la taille change (plein écran/réduit)
        // UTILISER event handler functions (http://help.scilab.org/docs/5.3.3/en_US/eventhandlerfunctions.html) pour avoir un zoom dynamique.
        //*************************************************************************
    
        fenetre = gcf();
        if Config == 1 then
            fenetre.figure_name = "Puissance apparente";
        elseif Config == 2 then
            fenetre.figure_name = "Index des heures pleines";
        end
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
        graphique.data_bounds(2,2) = ceil(graphique.data_bounds(2,2)/200 + 1)*200;
    
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
            noms_labels(i) = Gbl_Heure((i)*increment);
        end
        
        // Effectuer la mise à jour des abscisses
        graphique.x_ticks = tlist(["ticks" "locations" "labels"],locations_labels,noms_labels);
        
        disp("Graph tracé");

    else
        disp("Erreur de config");
    end
endfunction
