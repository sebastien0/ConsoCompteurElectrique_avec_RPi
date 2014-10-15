//*****************************
/// \author Sébastien Lemoine
/// \date Avril 2014
/// \brief Fonctions de filtrage de signal
//******************************

//****************************************************************************
/// \fn signal_f = moyenneGlissante(signal, fenetre)
/// \brief Filtrage par moyenne glissante
/// \param [in] signal    \c TabDouble  Signal à filtrer (dimensions n)
/// \param [in] fenetre     \c double   Fenetre sur laquelle moyenner le signal
/// \return signal_f   \c TabDouble(n)    Signal filtré
//*****************************************************************************
function signal_f = moyenneGlissante(signal, fenetre)
    nbrLignes = dimensions(signal,"ligne");

    // Initialiser à 0 pour conserver les même dimensions que signal
    signal_f(1:fenetre-1) = 0;
    
    // Effectuer le moyennage glissant
    for i = fenetre:nbrLignes
        signal_f(i) = mean(signal(i-fenetre+1:i));
    end
endfunction
