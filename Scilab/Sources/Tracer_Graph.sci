//*****************************
/// \author Sébastien Lemoine
/// \date Avril 2014
/// \brief Fonctions pour tracer les graphiques
//******************************

//****************************************************************************
/// \fn heures_Abscisses(nbrLignes, fenetre, graphique, temps)
/// \brief Afficher les abscisses en temps, distribution par rapport 
///  à la taille de l'écran
/// \param [in] nbrLignes    \c double  Nombre d'abscisses
/// \param [in] fenetre    \b TBC Objet graphique
/// \param [in] graphique    \b TBC Objet graphique
/// \param [in] temps    \c tabString  Heure
/// \todo Retirer 'fenetre' => inutilisé
/// \todo utiliser 'dimensions' au lieu de passer nbrLignes en paramètre
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

//*********************************************************************
/// \TODO 
/// - Raffraichir l'affichage si la taille change (plein écran/réduit)
/// UTILISER event handler functions 
/// (http://help.scilab.org/docs/5.3.3/en_US/eventhandlerfunctions.html) 
/// pour avoir un zoom dynamique.
//*************************************************************************

//****************************************************************************
/// \fn mise_en_forme(graphique, fenetre, opt_BackgndCouleur)
/// \brief Mise en forme du graphique
/// \param [in] graphique    \b TBC Objet graphique
/// \param [in] fenetre    \b TBC Objet graphique
/// \param [in opt] opt_BackgndCouleur  \c string   Couleur de fond, à renseigner depuis help color_list (si non utilisé alors couleur de fond = gris)
//*****************************************************************************
function mise_en_forme(graphique, fenetre, opt_BackgndCouleur)
    set(graphique,"grid",[1 1]);    // Grid on
    
    fenetre.figure_name = "Graphiques";

    //Arrière plan des courbes
    if  argn(2) == 3 then
        graphique.background=color(opt_BackgndCouleur);
    else
        graphique.background=color('gray95');
    end
    //Augmenter la taille des textes
    graphique.title.font_size = 3;
    graphique.x_label.font_size = 2;
    graphique.y_label.font_size = 2;
    // Ajustement de la zone d'affichage
    graphique.tight_limits = "on";
    graphique.data_bounds(1,2) = 0;
    
    // Ajuster l'espace graphique au-dessus des ordonnées
    ordonneeMax = graphique.data_bounds(2,2);
    // x1.2 puis tronque au multiple de 10W inférieur
    if ordonneeMax <= 500 then
        graphique.data_bounds(2,2) = ceil(ordonneeMax*1.2) - ...
         modulo(ceil(ordonneeMax*1.2),10);

    // x1.2 puis tronque au multiple de 50W inférieur
    elseif ordonneeMax <= 1000 then
        graphique.data_bounds(2,2) = ceil(ordonneeMax*1.2) - ...
        modulo(ceil(ordonneeMax*1.2),50);

    else    // Arrondi à 200W au dessus
        graphique.data_bounds(2,2) = ceil(graphique.data_bounds(2,2)/200 + ...
    1)*200;
        end
endfunction

//****************************************************************************
/// \fn tracer_Graph(data2plot, NumCompteur)
/// \brief Tracer une courbe avec son titre
/// \param [in] data2plot    \c tabDouble  Données à tracer
/// \param [in] NumCompteur    \c String    Numéro du compteur
//*****************************************************************************
function tracer_Graph(data2plot, NumCompteur)
    // **** Tracer la puissance en fonction du temps **********************
    nbrLignes = dimensions(data2plot, "ligne");
    nbrTab  = dimensions(data2plot, "colonne");
    nmbrMax = 8;
    
    if nbrTab <= nmbrMax then
        couleur = couleur_plot(); // liste de couleur pour la fonction plot
        for i=1:nbrTab
            plot(data2plot(:,i),couleur(i));
        end
        
        fenetre = gcf();
        graphique = gca();
        
        puissMoyStr = puiss_Moyenne();
        //Ajouter le quadrillage, les titres, ...
        titre = msprintf("Relevé du %s %s de %s à %s par le compteur n°%s ...
                \nPuissance active, moyenne = %s", Gbl_CreationTxt(4), ...
                Gbl_CreationTxt(1), Gbl_CreationTxt(2), Gbl_CreationTxt(3),...
                NumCompteur, puissMoyStr);
        // Titre du graphique
        xtitle(titre,"Heure","Puissance en VA");
        mise_en_forme(graphique, fenetre);
    
        // Ajouter les heures sur les abscisses
        heures_Abscisses(nbrLignes, fenetre, graphique, stcReleve.heure);

        printf("Puissance active moyenne = %s\n", puissMoyStr);
        printf("Puissance apparente tracée\n");
    else
        printf("Trop de graph à tracer. Corriger le 1er argument! \n");
    end
endfunction


//****************************************************************************
/// \fn tracer_2_Graph(stcReleve, optTracerPmoy)
/// \brief Tracer plusieurs courbes (Puissance et Energie) de couleurs différentes
/// \param [in] stcReleve    \c Structure  Relevé (Papp de dimensions max: [8,n])
/// \param [in] optTracerPmoy    \c Boléen  Si présent, tracer Pmoy sur le graphique
//*****************************************************************************
function tracer_2_Graph(stcReleve, optTracerPmoy)
    tabMoy = matrice(stcReleve.nbrLignes, stcReleve.pappMoy);
    nbrTab = dimensions(stcReleve.papp, "colonne");
    nmbrMax = 8;

    if nbrTab <= nmbrMax then
        //*** Puissance ******************
        subplot(211);
        couleur = couleur_plot(); // liste de couleur pour la fonction plot
        if argn(2) == 2 then
            plot(stcReleve.papp, couleur(1));
            plot(matrice(stcReleve.pappMoy, stcReleve.nbrLignes), couleur(2));
        else
            for i=1:nbrTab
                plot(stcReleve.papp(:,i),couleur(i));
            end
        end
        
        graphique = gca();
        fenetre = gcf();
        
        puissMoyStr = puiss_Moyenne(stcReleve.pappMoy);
        //Ajouter le quadrillage, les titres, ...
        titre = msprintf("Relevé du %s %s de %s à %s par le compteur n°%s ...
                \nPuissance active, moyenne = %s", stcReleve.jour, ...
                stcReleve.date, stcReleve.heureDebut, stcReleve.heureFin, ...
                stcReleve.numCompteur, puissMoyStr);

        // Titre du graphique
        xtitle(titre,"Heure","Puissance en VA");
        mise_en_forme(graphique, fenetre);
        // Ajouter les heures sur les abscisses
        heures_Abscisses(stcReleve.nbrLignes, fenetre, graphique, stcReleve.heure);
        
        //*** Index *********************
        subplot(212);
        plot(stcReleve.index);
        
        graphique = gca();
        fenetre = gcf();

        energieStr = energie(stcReleve);

        //Ajouter le quadrillage, les titres, ...
        // Base
        if stcReleve.isConfigBase then
            titre = msprintf("Index des consommations \nIndex à %s = %s", ...
                    stcReleve.heureDebut, energieStr(1,1));
        // HPHC
        elseif stcReleve.isConfigHCHP then
            titre = msprintf("Index des consommations \nIndex à %s : ...
                    HC = %s  Hp = %s", stcReleve.heureDebut, ...
                    energieStr(1,1), energieStr(2,1));
        end

        xtitle(titre, "Heure", "Variation d''index en Wh");
        mise_en_forme(graphique, fenetre);
       
        // Ajouter les heures sur les abscisses
        heures_Abscisses(stcReleve.nbrLignes, fenetre, graphique, stcReleve.heure);
        tailleIndex = dimensions(stcReleve.index, "colonne");
        if tailleIndex > 1 then
            legende = legend(["Index heures pleines"; "Index heures creuses"],2);
            legende.font_size = 3;
        end
        
        printf("Puissance active moyenne = %s\n", puissMoyStr);
        // Base
        if stcReleve.isConfigBase then
            printf("Energie à %s = %s\nEnergie à %s = %s\n", stcReleve.heureDebut, ...
                   energieStr(1), stcReleve.heureFin, energieStr(2));
        // HPHC
        elseif stcReleve.isConfigHCHP then
            printf("Index à %s : HC = %s \t HP = %s\nIndex à %s : ...
            HC = %s \t HP = %s\n",stcReleve.heureDebut, energieStr(1,1),...
            energieStr(2,1), stcReleve.heureFin, energieStr(1,2),...
            energieStr(2,2));
        end
        printf("Graphiques tracés\n");
    else
        printf("Trop de graph à tracer. Corriger le 1er argument! \n");
    end
endfunction

//****************************************************************************
/// \fn tracer_D_Graph(data2plot, jour, heure)
/// \brief Tracer des courbes supperposées; limitées à 8 courbes
/// \param [in] data2plot    \c tabDouble  Tableau, données à tracer (ordonnées)
/// \param [in] jour    \c tabString   Jours et dates de création
/// \param [in] heure   \c tabString   Instant des échantillons (abscisses)
//*****************************************************************************
function tracer_D_Graph(data2plot, jour, heure)
    nmbrMax = 8;    // 8 couleurs différentes disponibles
    // Longueur de l'enregistrement
    nbrLignes = dimensions(data2plot, "ligne");
    // Nombre d'enregistrements
    nbrTab = dimensions(data2plot, "colonne");
    strTabLegend = string((1:nbrTab)');

    if nbrTab <= nmbrMax then
        couleur = couleur_plot(); // liste de couleur pour la fonction plot
        for i=1:nbrTab
            plot(data2plot(:,i),couleur(i));
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
        mise_en_forme(graphique, fenetre, 'gray80');

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


//****************************************************************************
/// \fn couleur = couleur_plot()
/// \brief Crée un tableau comportant les lettre des couleurs pour plot(). Limitation à 8 couleurs
/// \return couleur    \c tabString  Abbréviation des couleurs
//*****************************************************************************
function couleur = couleur_plot()
    couleur(1) = 'r';
    couleur(2) = 'c';
    couleur(3) = 'g';
    couleur(4) = 'b';
    couleur(5) = 'm';
    couleur(6) = 'k';
    couleur(7) = 'y';
    couleur(8) = 'w';
endfunction
