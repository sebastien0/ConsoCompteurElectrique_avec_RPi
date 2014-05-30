//*****************************
/// \file Tracer_Graph.sci
/// \author Sébastien Lemoine
/// \date Avril 2014
/// \brief Fonctions pour tracer les graphiques
//******************************

//****************************************************************************
// \fn heures_Abscisses(nbrLignes, fenetre, graphique)
/// \brief Afficher les abscisses en temps, distribution par rapport 
///  à la taille de l'écran
/// \param [in] nbrLignes    \c double  Nombre d'abscisses
/// \param [in] fenetre    \b TBC Objet graphique
/// \param [in] graphique    \b TBC Objet graphique
//*****************************************************************************
function heures_Abscisses(nbrLignes, fenetre, graphique, temps)
    //Obtenir le pas du quadrillage vertical
    largeurEcran = get(0, "screensize_pt");  // Dimensions écran PC
    largeurEcran = largeurEcran(3);
    
    // Pas de distribution
    if largeurEcran <= 1000 then
        x_pas = 24 / largeurEcran * 1080;
    else
        x_pas = 24;   //Affichage plein écran
    end
    increment = floor(nbrLignes/x_pas);
    
    // Extraction des heures correspondant aux pas calculés
    for i = 1:(x_pas+1)
        locations_labels(i)= (i-1)*increment;
        temp = temps((i-1)*(increment-1)+1);
        // Ne conserver que le format hh:mm
        noms_labels(i) = part(temp,1:5);
    end
    
    // Effectuer la mise à jour des abscisses
    graphique.x_ticks = tlist(["ticks" "locations" "labels"],...
    locations_labels, noms_labels);
endfunction


//****************************************************************************
// \fn mise_en_forme(graphique, fenetre)
/// \brief Mise en forme du graphique
/// \param [in] graphique    \b TBC Objet graphique
/// \param [in] fenetre    \b TBC Objet graphique
// TODO: passer la couleur de fond en argument optionnel: argn()
//*****************************************************************************
function mise_en_forme(graphique, fenetre)
    set(graphique,"grid",[1 1]);    // Grid on
    
    //*********************************************************************
    /// \todo 
    /// - Obtenir la taille de la fenêtre pour ajuster au mieux
    /// - Raffraichir l'affichage si la taille change (plein écran/réduit)
    /// UTILISER event handler functions 
    /// (http://help.scilab.org/docs/5.3.3/en_US/eventhandlerfunctions.html) 
    /// pour avoir un zoom dynamique.
    //*************************************************************************

    fenetre.figure_name = "Graphiques";
//    fenetre.figure_size = floor(fenetre.figure_size*1.1);

    //Arrière plan des courbes en gris clair
    graphique.background=color('gray80');   // Gris clair = 95
    //Augmenter la taille des textes
    graphique.title.font_size = 3;
    graphique.x_label.font_size = 2;
    graphique.y_label.font_size = 2;
    // Ajustement de la zone d'affichage
    graphique.tight_limits = "on";
    graphique.data_bounds(1,2) = 0;
    // Ajuster la marge au-dessus des ordonnées
    ordonneeMax = graphique.data_bounds(2,2);
    if ordonneeMax <= 750 then
        graphique.data_bounds(2,2) = ceil(ordonneeMax*1.2) - ...
         modulo(ceil(ordonneeMax*1.2),5);
    else
        graphique.data_bounds(2,2) = ceil(graphique.data_bounds(2,2)/200 + ...
    1)*200;
        end
endfunction

//****************************************************************************
// \fn tracer_Graph(data2plot, NumCompteur, Titre)
/// \brief Tracer une courbe
/// \param [in] data2plot    \c double  Tableau des données à tracer
/// \param [in] NumCompteur    \c   string Numéro du compteur
/// \param [in] Titre    \c string  Titre du graphique
/// \todo le paramètre \c Titre est obsolète, à supprimer!
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
        /// todo: 
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
// \fn tracer_2_Graph(Puissance, Index, NumCompteur)
/// \brief Tracer 2 courbes. \n Puissance peut contenir 1 ou plusieurs tableaux
/// \param [in] Puissance    \c Tab_double  Données Puissance à tracer
/// \param [in] Index    \c Tab_string  Données Index à tracer
/// \param [in] NumCompteur    \c string    Numéro du compteur
//*****************************************************************************
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

//****************************************************************************
// TODO renseigner le chapeau
// \fn tracer_D_Graph(data2plot, jour)
/// \brief Tracer une courbe
/// \param [in] data2plot    \c double  Tableau des données à tracer
/// \param [in] NumCompteur    \c   string Numéro du compteur
//*****************************************************************************
function tracer_D_Graph(data2plot, jour, heure)
    nmbrMax = 8;
    // Longueur de l'enregistrement
    nbrLignes = longueur(data2plot);
    
    // Nombre d'enregistrements
    nbrTab = largeur(data2plot);
    strTabLegend = string((1:nbrTab)');

    if nbrTab <= nmbrMax then
        // Définition des couleurs pour les graphs
        couleur(1) = 'r';
        couleur(2) = 'c';
        couleur(3) = 'g';
        couleur(4) = 'b';
        couleur(5) = 'm';
        couleur(6) = 'k';
        couleur(7) = 'y';
        couleur(8) = 'w';

        // Tracer plusieurs courbes superposées
        if nbrTab == 1 then
            plot(data2plot, 'r');
        else
            for i=1:nbrTab
                plot(data2plot(:,i),couleur(i));
            end
        end
        
        // Titre du graphique avec les jours de tous les relevés
        releves(1,1) = "Relevés du :";
        // 1 ligne
        if nbrTab <= 4 then
            for i = 1:nbrTab
                releves(2,i) = msprintf(' %d - %s  %s   ', ...
                                        i, jour(1,i), jour(2,i));
            end
        // 2 lignes
        else
            nmbrParLigne = ceil(nbrTab/2);
            for i = 1:nmbrParLigne
                releves(2,i) = msprintf(' %d - %s  %s   ', ...
                                        i, jour(1,i), jour(2,i));
            end
            for i = nmbrParLigne+1:nbrTab
                releves(3,i-nmbrParLigne) = msprintf(' %d - %s  %s   ', ...
                                            i, jour(1,i), jour(2,i));
            end
        end

        //Ajouter le quadrillage, les titres, ...
        xtitle(releves,"Heure","Puissance en VA");
        
        fenetre = gcf();
        graphique = gca();
//pause   // Continuer en saisissant "resume" en console
        mise_en_forme(graphique, fenetre);

//  Problème sur l'affichage: légende sans texte => juste couleur dans l'ordre
        legende = legend(strTabLegend,"in_upper_left");
        legende.font_size = 3;
    
        // Ajouter les heures sur les abscisses
        heures_Abscisses(nbrLignes, fenetre, graphique, heure);
        
        printf("Puissance apparente tracée\n");
    else
        printf("Erreur \t Trop de graph à tracer, %d max\n", nmbrMax);
    end
endfunction
