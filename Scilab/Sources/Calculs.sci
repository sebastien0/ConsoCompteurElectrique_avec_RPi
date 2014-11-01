//*****************************
/// \author Sébastien Lemoine
/// \date Avril 2014
/// \brief Outils de calculs
//******************************

//****************************************************************************
/// \fn configuration(donnee)
/// \brief Détecter la configuration du compteur
/// \param [in] donnee    \c TabString  Fichier texte reconstitué
/// \param [out] titres  \c TabString    Entête des colonnes
/// \param [out] configBase_N    \c double   Configuration du compteur en BASE
/// \param [out] configHPHC_N    \c double   Configuration du compteur en HCHP
//*****************************************************************************
function configuration(donnee)
    // Lecture des en-têtes de colonnes
    try
        titres = msscanf(donnee(5,1),'%s %s %s %s %s %s %s');
     catch
        try
            titres = msscanf(donnee(5,1),'%s %s %s %s');
        catch
            disp(lasterror());
        end
    end
    
    // Détectionde la configuration en Base ou HCHP
    temp = titres(3);
    configBase_N = strcmp('Base',temp); // =0 si compteur en Base 
    if configBase_N <> 0 then
        temp = titres(3) + titres(4);
    else
        printf("Compteur configuré en Base\n");
    end

    configHPHC_N = strcmp('Hcreuses',temp); // =0 si compteur en HCHP 
    if configHPHC_N == 0 then
        printf("Compteur configuré en HCHP\n");
    end

    // Retour des variables
    [titres, configBase_N, configHPHC_N] = resume(titres, configBase_N, configHPHC_N);
endfunction


//****************************************************************************
/// \fn [duree, moyenne] = HeuresFonctionnement(stcReleve, opt_moyInact)
/// \brief Calculer le nombre d'heure de fonctionnement. \n 
///     Temps compatibilisé dès que Papp >= moyenne(Papp)
/// \param [in] stcReleve   \c Structure    Relevé
/// \param [in optionnel] opt_moyInact   \c string  si = 1 alors calculer la moyenne sur un temps d'inactivié
/// \param [out] duree    \c TabDouble  Temps écoulé, au format [h m s]
/// \param [out] moyenne    \c double   Moyenne de \c Papp
//*****************************************************************************
function [duree, moyenne] = HeuresFonctionnement(stcReleve, opt_moyInact)
    tempsTotal = 0;
    duree = zeros(1,3);

    if argn(2) == 2 then // Moyenne sur une période inactive
    // Formule inactivité = [moy(Papp(1:n)) / moy(Papp(1:2*n))] > 90%
        for (borne = 100:100:ceil(stcReleve.nbrLignes*0.1))
            maxMoy1 = 1 * borne;
            maxMoy2 = 2 * borne;
            
            moyenne1 = mean(stcReleve.papp(1:maxMoy1));
            moyenne2 = mean(stcReleve.papp(1:maxMoy2));
            if (abs(moyenne1/moyenne2) > 0.90) then
                moyenne = moyenne2;
            end
         end
     
    else    // Moyenne
        moyenne = mean(stcReleve.papp);
    end

    // Temps cumulé en secondes
    for (ligne = 2:stcReleve.nbrLignes-1)
        if (stcReleve.papp(ligne) >= moyenne & stcReleve.papp(ligne-1) >= moyenne) then
            tempsTotal = tempsTotal + difTemps(stcReleve.heure(ligne-1), ...
                                        stcReleve.heure(ligne));
        end
    end
    // Décomposition en h, m, s avec affichage console
    duree = conversion_temps(tempsTotal, 1);
endfunction


//****************************************************************************
/// \fn Dtemps = difTemps(heure1, heure2)
/// \brief Calculer la différence de temps entre 2 instants
/// \param [in]    heure1   \c String   Instant n°1 au format hh:mm:ss
/// \param [in]    heure2   \c String   Instant n°2 au format hh:mm:ss, (heure2 > heure1)
/// \return   Dtemps    \c Double  Différence de temps entre les 2 instants, en seconde
//*****************************************************************************
function Dtemps = difTemps(heure1, heure2)
    heure_1 = msscanf(heure1(1),"%d:%d:%d");
    heure_2 = msscanf(heure2(1),"%d:%d:%d");
    
    if heure_2(3) > heure_1(3) then
        Dtemps = heure_2(3) - heure_1(3);
    elseif (heure_2(2) > heure_1(2)) then
        Dtemps = (heure_2(2) - heure_1(2))*60 + heure_2(3) - heure_1(3);
    else
        Dtemps = (heure_2(1) - heure_1(1))*3600 +(heure_2(2) - heure_1(2))*60 ...
                + heure_2(3) - heure_1(3);
    end
    
    // Debug
    if Dtemps < 0 then
        printf("\nheure_1 = %i \nheure_2 = %d \nDtemps = %d\n",heure_1(3), ...
        heure_2(3), Dtemps);
    end
endfunction

//****************************************************************************
/// \fn tab = matrice(nombre, nbrLignes)
/// \brief Retourne une matrice constante (= nombre), de dimensions nbrLignes
/// \param [in] nombre    \c Double  Valeur de la constante
/// \param [in] nbrLignes    \c Double  Nombre de ligne de la matrice retournée
/// \param [out] tab    \c tabDouble(nbrLignes)  Matrice constante
//*****************************************************************************
function tab = matrice(nombre, nbrLignes)
    tab = ones(nbrLignes, 1)*nombre;
endfunction


//****************************************************************************
/// \fn nom = nom_jour(dateReleve)
/// \brief Retourne le nom du jour de dateReleve
/// \param [in]     dateReleve  \c string   Date du jour, au format "aaaa/mm/jj"
/// \return    nom \c string   Nom du jour
//*****************************************************************************
function nom = nom_jour(dateReleve)
    tempDate = msscanf(dateReleve,"%d/%d/%d");
    dateReleve = datenum(tempDate(1),tempDate(2),tempDate(3));
    [N, nom] = weekday(dateReleve,'long');
endfunction

//****************************************************************************
/// \fn puissMoyStr = puiss_Moyenne(puissMoy)
/// \brief Retourne la puissance moyenne avec l'unité appropriée
/// \param [in] puissMoy    \c double   Puissance moyenne
/// \return puissMoyStr    \c string   Valeur moyenne avec l'unité
//*****************************************************************************
function puissMoyStr = puiss_Moyenne(puissMoy)
    if puissMoy > 1000 then   // Affichage en kWh
        puissMoyStr = msprintf("%.1f kW", puissMoy/1000);
    else   // Affichage en W
        puissMoyStr = msprintf("%.1f W", puissMoy);
    end
endfunction

//****************************************************************************
/// \fn energieStr = energie(stcReleve)
/// \brief Retourne les énergies de début et de fin au format string avec l'unité
/// \param [in] stcReleve.    \c Strcuture   Relevé
/// \return energieStr \c tabString   Tableau avec les index initiaux et finaux
//*****************************************************************************
function energieStr = energie(stcReleve)
    energieStr(1,1) = msprintf("%.1f kWh", stcReleve.index0(1)/1000);
    energieStr(1,2) = msprintf("%.1f kWh", ...
                (stcReleve.index0(1) + stcReleve.index(stcReleve.nbrLignes,1))/1000);

    if stcReleve.isConfigHCHP then
        energieStr(2,1) = msprintf("%.1f kWh", stcReleve.index0(2)/1000);
        energieStr(2,2) = msprintf("%.1f kWh", ...
                    (stcReleve.index0(2) + stcReleve.index(stcReleve.nbrLignes,2))/1000);
    end
endfunction


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
/// \fn nom = nom_compteur(numCompteur)
/// \brief Retourne le nom du compteur à partir de son numéro
/// \param [in] numCompteur \c string   Numéro du compteur
/// \return nom    \c  string  Nom du compteur
//*****************************************************************************
function nom = nom_compteur(numCompteur)
    select numCompteur
    case "271067018318" then
        nom = "Lyon - Communs";
    case "049701078744" then
        nom = "Mont-Saxonnex";
    case "271067095836" then
        nom = "Lyon - Seb & Julie";
    case "059922013742" then
        nom = "Claix";
    else
        nom = "Inconnu";
    end
endfunction


//****************************************************************************
/// \fn duree = conversion_temps(tempsSecondes, opt_affichage)
/// \brief Converti un temps en secondes en heures, minutes, secondes
/// \param [in] tempsSecondes   \c double   Temps à convertir (en s)
/// \param [in optionnel] opt_affichage   \c Boléen   %t pour afficher la valeur en console
/// \return duree    \c  tabDouble(3)  Temps décomposé en [h m s]
//*****************************************************************************
function duree = conversion_temps(tempsSecondes, opt_affichage)
    // Temps heures, minutes & secondes
    if tempsSecondes > 3600 then
        duree(1) = floor(tempsSecondes/3600);
        duree(2) = floor(modulo(tempsSecondes,3600)/60);
        duree(3) = modulo(tempsSecondes - duree(1)*3600 - duree(2)*60, 60);
        texte = msprintf("%ih%im%is", duree(1), duree(2),duree(3));

    // Temps en minutes & secondes
    elseif tempsSecondes > 60 then
        duree(1) = 0;
        duree(2) = floor(tempsSecondes/60);
        duree(3) = modulo(tempsSecondes,60);
        texte = msprintf("%im%is\n", duree(2), duree(3));

    // Temps en secondes
    else
        duree(1) = 0;
        duree(2) = 0;
        duree(3) = tempsSecondes;
        texte = msprintf("%is", duree(3));
    end
    
    if argn(2) == 2 then
        printf("Durée des consommations hors veilles = %s\n", texte);
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
