//*****************************
/// \author Sébastien Lemoine
/// \date Septembre 2014
/// \brief Fonctions de statistique de code
//******************************

//* ***************************************************************************
/// \fn Tracer_Duree_Chargement (stcStatistiques)
/// \brief Trace les temps restant estimé et le temps total écoulé
/// \param [in] stcStatistiques    \c structure   Structure de statisque
//*****************************************************************************
function Tracer_Duree_Chargement (stcStatistiques)
    nbrLignes = dimensions(stcStatistiques.tabTempsRestant, "ligne");
    tabTempsTotal = matrice(stcStatistiques.tempsTotal, nbrLignes);
    
    plot([stcStatistiques.tabTempsRestant tabTempsTotal]);

    legende = legend(["Temps restant estimé"; "Temps total écoulé"],"in_upper_right");
    legende.font_size = 3;
    strTitle = "Temps restant estimé";
    xtitle(strTitle,"Iteration","Temps (s)");
    
    graphique = gca();
    graphique.background=color('gray95');
    set(graphique,"grid",[1 1]);    // Grid on
    //Augmenter la taille des textes
    graphique.title.font_size = 3;
    graphique.x_label.font_size = 2;
    graphique.y_label.font_size = 2;

    fenetre = gcf();
    fenetre.figure_name = "Statistiques";
endfunction
