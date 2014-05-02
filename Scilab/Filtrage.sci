//* ***************************************************************************
//* Filtrage par moyenne glissante
//* Retourne le signal filtré selon le nombre d'échantillons "periode"
//*
//*****************************************************************************
function signal_f = moyenneGlissante(signal, periode)
    nbrLignes = size(signal);
    nbrLignes = nbrLignes(1);

    // Initialiser à 0 pour conserver les même dimensions que signal
    signal_f(1:periode-1) = 0;
    
    // Effectuer le moyennage glissant
    for i = periode:nbrLignes
        signal_f(i) = mean(signal(i-periode+1:i));
    end
endfunction
