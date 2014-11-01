//*****************************
/// \author Sébastien Lemoine
/// \date Septembre 2014
/// \brief Fonctions de statistique de code
//******************************

//****************************************************************************
/// \fn Tracer_Duree_Chargement(stcStatistiques)
/// \brief Trace le temps restant estimé et le temps total écoulé
/// \param [in] stcStatistiques    \c structure   Structure de statisques
//*****************************************************************************
function Tracer_Duree_Chargement(stcStatistiques)
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


/// \stc stcStatistiques.   \c Structure    Statistiques sur l'importation
///       dateImportation     \c String   Date
///       heureImportation    \c String   Heure
///       nomPC           \c String   Nom du PC
///       tempsTotal      \c Double   Temps de traitement
///       tabTempsRestant     \c tabDouble[]    Temps restant successif estimé
///       nbBoucleCentDenum   \c Double   Nombre d'itérations pour optimiser le rafraichissement de la barre d'avancement
///       tempsIntermediaire  \c Double   Temps de la boucle nbBoucleCentDenum
///       numCompteur         \c String   Numéro du compteur
///       config      \c String   Configuration du compteur
///       date        \c String   Date
///       heure       \c String   Heure de début
///       nbrLignes   \c Double   Nombre d'échantillons

