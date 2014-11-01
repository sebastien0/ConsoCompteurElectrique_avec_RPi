//*****************************
/// \author Sébastien Lemoine
/// \date Avril 2014
/// \brief Outils de traitement
//******************************

//****************************************************************************
/// \fn nombre = dimensions(data,choix)
/// \brief Retourne la longueur ou la largeur du tableau (nombre de lignes ou colonnes)
/// \param [in] data    \c tableau   Tableau à mesurer
/// \param [in] choix   \c string   Dimensions à extraire: "ligne" ou "colonne"
/// \return nombre  \c double   Nombre de lignes/colonnes. Retourne -1 si erreur
//*****************************************************************************
function nombre = dimensions(data,choix)
    nombre = size(data);
    if choix == "ligne" then
        nombre = nombre(1);
    elseif choix == "colonne" then
        nombre = nombre(2);
    else
        nombre = -1;
    end
endfunction

//****************************************************************************
/// \fn strNombre = nombre_2_Chiffres(nombre)
/// \brief Retourne un nombre sur 2 chiffres
/// \param [in] nombre  \c Double   Nombre à convertir
/// \return strNombre   \c String   Nombre sur au moins 2 chiffres
//****************************************************************************
function strNombre = nombre_2_Chiffres(nombre)
    if nombre < 10 then
        strNombre = strcat(['0', string(nombre)]);
    else
        strNombre = string(nombre);
    end
endfunction
