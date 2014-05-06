//* ***************************************************************************
//* Détecter la configuration du compteur
//*
//*
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

//* ***************************************************************************
//* Calculer le nombre d'heure de fonctionnement
//* Critère fonctionnement = Gbl_Papp > moyenne(Gbl_Papp)
//* Retourne duree [heures minutes secondes]
//*
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

//* ***************************************************************************
//* Calculer la différence de temps entre 2 instants
//*
//* Retourne la durée en seconde
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
//*
//* Retourne une matrice de dimensions (nbrLignes, 1) = nombre
//*****************************************************************************
function tab = matrice(tabEntree, nombre)
    nbrLignes = size(tabEntree);
    nbrLignes = nbrLignes(1,1);
    
    tab = ones(nbrLignes, 1)*nombre;
endfunction


//* ***************************************************************************
//* Retourne le nom du jour de dateReleve
//* dateReleve au format "aaaa/mm/jj"
//*
//*****************************************************************************
function nom = nom_jour(dateReleve)
    // Obtention du nom du jour du relevé
    tempDate = msscanf(dateReleve,"%d/%d/%d");
    dateReleve = datenum(tempDate(1),tempDate(2),tempDate(3));
    [N, nom] = weekday(dateReleve,'long');
endfunction

//* ***************************************************************************
//* Retourne la puissance moyenne au format string avec l'unité appropriée
//*
//*****************************************************************************
function puissMoyStr = puissMoyenne()
    // Calcul de la puissance moyenne
    puissMoy = round(mean(Gbl_Papp));
   // Mise en forme de la puissance moyenne
   // Affichage en kWh
    if puissMoy > 1000 then
        // Calcul du dixième de kWh
        dixieme = modulo(puissMoy, 1000) - modulo(modulo(puissMoy, 1000), 100)
        puissMoyStr = strcat([string(floor(puissMoy/1000)), '.', ...
        string(dixieme), 'kW']);

   // Affichage en Wh
    else
        puissMoyStr = strcat([string(round(puissMoy)), 'W']);
    end
endfunction


//* ***************************************************************************
//* Retourne les énergies de début et de fin au format string avec l'unité
//*****************************************************************************
function energieStr = energie(nbrLignes, config)
    // Base: un seul index
    if config == 1 then
      // Energie au début
        energieStr(1) = strcat([string(floor(Gbl_Index0/1000)), "kWh"]);
        // Energie à la fin
        energieStr(2) = strcat([string(ceil((Gbl_Index0 + ...
                                Gbl_Index(nbrLignes-1))/1000)), "kWh"]);

    // HCHP: 2 index
    elseif config == 2 then
        // Energie au début
        energieStr(1,1) = strcat([string(floor(Gbl_Index0(1)/1000)), "kWh"]);
        energieStr(2,1) = strcat([string(floor(Gbl_Index0(2)/1000)), "kWh"]);
        // Energie à la fin
        energieStr(1,2) = strcat([string(ceil((Gbl_Index0(1) + ...
                                Gbl_Index(nbrLignes-2,1))/1000)), "kWh"]);
        energieStr(2,2) = strcat([string(ceil((Gbl_Index0(2) + ...
                                Gbl_Index(nbrLignes-2,2))/1000)), "kWh"]);
    else
        energieStr = ["0" "0"];
    end
endfunction
