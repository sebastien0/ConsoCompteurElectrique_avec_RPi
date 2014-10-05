//*****************************
/// \author Sébastien Lemoine
/// \date Avril 2014
/// \brief Fonctions de filtrage de signal
//******************************

//****************************************************************************
/// \fn heures_Abscisses(nbrLignes, fenetre, graphique)
/// \brief Filtrage par moyenne glissante
/// \param [out] signal_f   \c TabDouble    Signal filtré
/// \param [in] signal    \c TabDouble  Nombre d'abscisses
/// \param [in] fenetre     \c double   Fenetre sur laquelle moyenner le signal
//*****************************************************************************
function signal_f = moyenneGlissante(signal, fenetre)
    nbrLignes = dimensions(signal,"ligne");

    // Initialiser à 0 pour conserver les même dimensions que signal
    signal_f(1:fenetre-1) = 0;
    
    // Effectuer le moyennage glissant
    for i = fenetre:nbrLignes
//        signal_f(i) = mean(signal(fenetre+1:i));
        signal_f(i) = mean(signal(i-fenetre+1:i));
    end
endfunction
