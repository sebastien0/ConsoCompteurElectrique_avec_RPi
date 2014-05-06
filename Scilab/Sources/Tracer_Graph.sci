//*****************************
/// \file Tracer_Graph.sci
/// \author Sébastien Lemoine
/// \date Avril 2014
/// \brief Fonctions pour tracer les graphiques
//******************************

//****************************************************************************
/// \brief Afficher les abscisses en temps
/// \param [in] nbrLignes    \c double  Nombre d'abscisses
/// \param [in] fenetre    \b TBC Objet graphique
/// \param [in] graphique    \b TBC Objet graphique
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


//****************************************************************************
/// \brief Mise en forme du graphique
/// \param [in] graphique    \b TBC Objet graphique
/// \param [in] fenetre    \b TBC Objet graphique
//*****************************************************************************
function mise_en_forme(graphique, fenetre)
    set(graphique,"grid",[1 1]);    // Grid on
    
    //*********************************************************************
    /// \TODO: 
    /// - Obtenir la taille de la fenêtre pour ajuster au mieux
    /// - Raffraichir l'affichage si la taille change (plein écran/réduit)
    /// UTILISER event handler functions 
    /// (http://help.scilab.org/docs/5.3.3/en_US/eventhandlerfunctions.html) 
    /// pour avoir un zoom dynamique.
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

//****************************************************************************
/// \brief Tracer une courbe
/// \param [in] data2plot    \c double  Tableau des données à tracer
/// \param [in] NumCompteur    \c   string Numéro du compteur
/// \param [in] Titre    \c string  Titre du graphique \TODO obsolète
//*****************************************************************************
function tracer_Graph(data2plot, NumCompteur, Titre)
    // **** Tracer la puissance en fonction du temps **********************
    nbrLignes = size(data2plot);
    nbrLignes = nbrLignes(1);
    
    nbrTab = size(data2plot);
    nbrTab = nbrTab(2);
    if nbrTab <= 5 then
        
        // Définition des couleurs pour les graphs
        couleur(1) = 'r';
        couleur(2) = 'c';
        couleur(3) = 'g';
        couleur(4) = 'y';
        couleur(5) = 'm';
    
            // Possibilité de tracer 2 courbes superposées (Papp et moyenne par ex)
        if nbrTab == 1 then
            plot(data2plot, 'r');
        else
            for i=1:nbrTab
                plot(data2plot(:,i),couleur(i));
            end
        end
        fenetre = gcf();
        graphique = gca();
        
        puissMoyStr = puissMoyenne();
        //Ajouter le quadrillage, les titres, ...
        titre = ["Relevé du " + Gbl_CreationTxt(4) + " " + Gbl_CreationTxt(1) ...
                 + " de " + Gbl_CreationTxt(2) + " à " + Gbl_CreationTxt(3) + ...
                " par le compteur n° " + NumCompteur;...
                "Puissance active, moyenne = " + puissMoyStr];
        // Titre du graphique
        xtitle(titre,"Heure","Puissance en VA");
        mise_en_forme(graphique, fenetre);
            
        //*********************************************************************
        /// TODO: 
        /// - Obtenir la taille de la fenêtre pour ajuster au mieux
        /// - Raffraichir l'affichage si la taille change (plein écran/réduit)
        /// UTILISER event handler functions 
        /// (http://help.scilab.org/docs/5.3.3/en_US/eventhandlerfunctions.html) 
        /// pour avoir un zoom dynamique.
        //*************************************************************************
    
        // Ajouter les heures sur les abscisses
        heures_Abscisses(nbrLignes, fenetre, graphique);

        printf("Puissance active moyenne = %s\n", puissMoyStr);
        printf("Puissance apparente tracée\n");
    else
        printf("Trop de graph à tracer. Corriger le 1er argument! \n");
    end
endfunction


//****************************************************************************
/// \brief Tracer 2 courbes. \n Puissance peut contenir 1 ou plusieurs tableaux
/// \param [in] Puissance    \c double  Tableau des données Puissance à tracer
/// \param [in] Index    \c string  Tableau des données Index à tracer
/// \param [in] NumCompteur    \c   string Numéro du compteur
//*****************************************************************************
//Puissance = [Gbl_Papp tabMoy]; Index = Gbl_Index; NumCompteur = Gbl_NumCompteur;
function tracer_2_Graph(Puissance, Index, NumCompteur)
    nbrLignes = size(Index);
    nbrLignes = nbrLignes(1);
    
    nbrTab = size(Puissance);
    nbrTab = nbrTab(2);
    if nbrTab <= 5 then
        
        // Définition des couleurs pour les graphs
        couleur(1) = 'r';
        couleur(2) = 'c';
        couleur(3) = 'g';
        couleur(4) = 'y';
        couleur(5) = 'm';
        
        //*** Puissance ******************
        subplot(211);
        // Possibilité de tracer 2 courbes superposées (Papp et moyenne par ex)
        if nbrTab == 1 then
            plot(Puissance, 'r');
        else
            for i=1:nbrTab
                plot(Puissance(:,i),couleur(i));
            end
        end
        
        graphique = gca();
        fenetre = gcf();
        
        puissMoyStr = puissMoyenne();
        //Ajouter le quadrillage, les titres, ...
        titre = ["Relevé du " + Gbl_CreationTxt(4) + " " + Gbl_CreationTxt(1) ...
                 + " de " + Gbl_CreationTxt(2) + " à " + Gbl_CreationTxt(3) + ...
                " par le compteur n° " + NumCompteur;...
                "Puissance active, moyenne = " + puissMoyStr];
        // Titre du graphique
        xtitle(titre,"Heure","Puissance en VA");
        mise_en_forme(graphique, fenetre);
        // Ajouter les heures sur les abscisses
        heures_Abscisses(nbrLignes, fenetre, graphique);
        
        //*** Index *********************
        subplot(212);
        plot(Index);
        
        graphique = gca();
        fenetre = gcf();

        // Configuration
        config = size(Gbl_Index0);
        config = config(1,2);
        
        energieStr = energie(nbrLignes, config);
        //Ajouter le quadrillage, les titres, ...
        // Base
        if config == 1 then
            titre = ["Index des consommations";
                     "Index à " + Gbl_CreationTxt(2) + " = " + energieStr(1,1)];
        // HPHC
        elseif config == 2 then
            titre = ["Index des consommations";
                     "Index à " + Gbl_CreationTxt(2) + " : HC = " + ...
                     energieStr(1,1)+ " HP = " + energieStr(2,1)];
        end
        xtitle(titre, "Heure", "Variation d''index en Wh");
        mise_en_forme(graphique, fenetre);
       
        // Ajouter les heures sur les abscisses
        heures_Abscisses(nbrLignes, fenetre, graphique);
        tailleIndex = size(Index);
        if tailleIndex(2) > 1 then
            legende = legend(["Index heures creuses"; "Index heures pleines"],2);
            legende.font_size = 3;
        end
        
        printf("Puissance active moyenne = %s\n", puissMoyStr);
        // Base
        if config == 1 then
            printf("Energie à %s = %s\nEnergie à %s = %s\n", Gbl_CreationTxt(2), ...
                   energieStr(1), Gbl_CreationTxt(3), energieStr(2));
        // HPHC
        elseif config == 2 then
            printf("Index à %s : HC = %s \t HP = %s\nIndex à %s : HC = %s \t HP = %s\n",...
                   Gbl_CreationTxt(2), energieStr(1,1),energieStr(2,1), Gbl_CreationTxt(3), ...
                   energieStr(1,2),energieStr(2,2));
        end
        printf("Graphiques tracés\n");
    else
        printf("Trop de graph à tracer. Corriger le 1er argument! \n");
    end
endfunction
