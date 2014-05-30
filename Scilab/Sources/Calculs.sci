//*****************************
/// \file Calculs.sci
/// \author Sébastien Lemoine
/// \date Avril 2014
/// \brief Outils de calculs
//******************************

//****************************************************************************
// \fn configuration(donnee)
/// \brief Détecter la configuration du compteur

/// \param [in] donnee    \c TabString  Fichier texte reconstitué
/// \return titres  \c TabString    Entête des colonnes
/// \return configBase_N    \c double   Configuration du compteur en BASE
/// \return configHPHC_N    \c double   Configuration du compteur en HCHP
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
// \fn [duree, moyenne] = HeuresFonctionnement()
/// \brief Calculer le nombre d'heure de fonctionnement. \n 
///     Temps compatibilisé dès que Papp >= moyenne(Papp)

/// \details Les variables globales \c Gbl_Papp et \c Gbl_Heure sont utilisées
/// \param [out] duree    \c TabDouble  Temps écoulé, au format [h m s]
/// \param [out] moyenne    \c double   Moyenne de \c Papp
//*****************************************************************************
function [duree, moyenne] = HeuresFonctionnement()
    tempsTotal = 0;
    moyenne = 0;
    duree = zeros(1,3);
    
   //Nombre de ligne
    nbrLignes = min(size(Gbl_Papp),size(Gbl_Heure))-1;
    nbrLignes = nbrLignes(1,1);

    // Moyenne sur une période inactive
    // inactivité = [moy(Papp(1:n)) / moy(Papp(1:2n))] > 90%
//    for (borne = 100:100:ceil(nbrLignes*0.1))
//        maxMoy1 = 1 * borne;
//        maxMoy2 = 2 * borne;
//        
//        moyenne1 = mean(Gbl_Papp(1:maxMoy1));
//        moyenne2 = mean(Gbl_Papp(1:maxMoy2));
//        if (abs(moyenne1/moyenne2) > 0.90) then
//            moyenne = moyenne2;
//        end
//     end
     
     // Autre méthode
//    moyenne = mean(Gbl_Papp(1:ceil(nbrLignes*0.1)));
    moyenne = mean(Gbl_Papp);

    // Temps cumulé en secondes
    for (ligne = 2:nbrLignes-1)
        if (Gbl_Papp(ligne) >= moyenne & Gbl_Papp(ligne-1) >= moyenne) then
            tempsTotal = tempsTotal + difTemps(Gbl_Heure(ligne-1), ...
                                        Gbl_Heure(ligne));
        end
    end
    
    // Temps en heure, minutes & secondes
    if tempsTotal > 3600 then
        duree(1) = floor(tempsTotal/3600);
        duree(2) = floor(modulo(tempsTotal,3600)/60);
        duree(3) = modulo(tempsTotal - duree(1)*3600 - duree(2)*60, 60);
        printf("Durée des consommations hors veilles = %ih%im%is\n", ...
                duree(1), duree(2),duree(3));
    // Temps en minutes & secondes
    elseif tempsTotal > 60 then
        duree(1) = 0;
        duree(2) = floor(tempsTotal/60);
        duree(3) = modulo(tempsTotal,60);
        printf("Durée des consommations hors veilles = %im%is\n", ...
                duree(2),duree(3));
    // Temps en secondes
    else
        duree(1) = 0;
        duree(2) = 0;
        duree(3) = tempsTotal;
        printf("Durée des consommations hors veilles = %is\n", duree(3));
    end
endfunction


//****************************************************************************
// \fn Dtemps = difTemps(heure1, heure2)
/// \brief Calculer la différence de temps entre 2 instants
/// \param [out]    Dtemps    \c Double  Différence de temps entre les 2 instants, en seconde
/// \param [in]    heure1   \c String   Instant n°1 au format hh:mm:ss
/// \param [in]    heure2   \c String   Instant n°2 au format hh:mm:ss, (heure2 > heure1)
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
    
    if Dtemps < 0 then
        printf("\nheure_1 = %i \nheure_2 = %d \nDtemps = %d\n",heure_1(3), ...
        heure_2(3), Dtemps);
    end
endfunction

//* ***************************************************************************
//* Créer une matrice constante
//* Retourne une matrice de dimensions (nbrLignes, 1) = nombre
// TODO Chapeau à remplir
//*****************************************************************************
function tab = matrice(tabEntree, nombre)
    nbrLignes = size(tabEntree);
    nbrLignes = nbrLignes(1,1);
    
    tab = ones(nbrLignes, 1)*nombre;
endfunction


//* ***************************************************************************
//* Retourne le nom du jour de dateReleve
//* dateReleve au format "aaaa/mm/jj"
// TODO Chapeau à remplir
//*****************************************************************************
function nom = nom_jour(dateReleve)
    // Obtention du nom du jour du relevé
    tempDate = msscanf(dateReleve,"%d/%d/%d");
    dateReleve = datenum(tempDate(1),tempDate(2),tempDate(3));
    [N, nom] = weekday(dateReleve,'long');
endfunction

//* ***************************************************************************
/// \fn puissMoyStr = puiss_Moyenne()
/// \brief Retourne la puissance moyenne avec l'unité appropriée
/// \param [in global] Gbl_Papp    \c double   Tableau, données à moyenner
/// \param [out] puissMoyStr    \c string   Valeur moyenne
//*****************************************************************************
function puissMoyStr = puiss_Moyenne()
    // Calcul de la puissance moyenne
    puissMoy = mean(Gbl_Papp);
   // Mise en forme de la puissance moyenne
    if puissMoy > 1000 then   // Affichage en kWh
        puissMoyStr = msprintf("%.1f kW", puissMoy/1000);
    else   // Affichage en W
        puissMoyStr = msprintf("%.1f W", puissMoy);
    end
endfunction


//* ***************************************************************************
/// \fn energieStr = energie(nbrLignes, config)
/// \brief Retourne les énergies de début et de fin au format string avec l'unité
/// \param [in global] Gbl_Index    \c double   Tableau, Index d'énergie
/// \param [in] nbrLignes   \c double   Longueur de Gbl_Index
/// \param [in] config  \c double   Configuration du compteur
// TODO config est obsolète, utiliser dimensions("colonnes")
/// \param [out] energieStr \c string   Tableau avec les index initiaux et finaux
//*****************************************************************************
function energieStr = energie(obs_nbrLignes, obs_config)
    nbrLignes = dimensions(Gbl_Index, "ligne");
    config = dimensions(Gbl_Index, "colonne");
    energieStr(1,1) = msprintf("%.1f kWh", Gbl_Index0(1)/1000);
    energieStr(1,2) = msprintf("%.1f kWh", ...
                (Gbl_Index0(1) + Gbl_Index(nbrLignes-2,1))/1000);
    if config == 2 then
        energieStr(2,1) = msprintf("%.1f kWh", Gbl_Index0(2)/1000);
        energieStr(2,2) = msprintf("%.1f kWh", ...
                    (Gbl_Index0(2) + Gbl_Index(nbrLignes-2,2))/1000);
    end
endfunction


//* ***************************************************************************
/// \fn nombre = dimensions(data,choix)
/// \brief Retourne la longueur ou la largeur du tableau (nombre de lignes ou colonnes)
/// \param [in] data    \c double   Tableau à tester
/// \param [in] choix   \c string   Dimensions à extraire: "ligne" ou "colonne"
/// \param [out] nbrLignes  \c double   Nombre de lignes/colonne de \c data. -1 = erreur
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


//* ***************************************************************************
/// \fn nom = nom_compteur(numCompteur)
/// \brief Retourne le nom du compteur à partir de son numéro
/// \param [in] numCompteur \c string   Numéro du compteur
/// \param [out] nom    \c  string  Nom du compteur
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
