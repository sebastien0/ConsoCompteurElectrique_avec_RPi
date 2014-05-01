//* ***************************************************************************
//* Calculer le nombre d'heure de fonctionnement
//* Critère fonctionnement = Gbl_Papp > moyenne(Gbl_Papp)
//* Retourne duree [heures minutes secondes]
//*
//*****************************************************************************
function duree = HeuresFonctionnement()
    tempsTotal = 0;
    
   //Nombre de ligne
    nbrLignes = min(size(Gbl_Papp),size(Gbl_Heure))-1;
    nbrLignes = nbrLignes(1,1);

    // Moyenne sur une période inactive
    // inactivité = [moy(Papp(1:n)) / moy(Papp(1:2n))] > 9%
//    for (borne = 100:100:10000)
//        maxMoy1 = 1 * borne;
//        maxMoy2 = 2 * borne;
//        
//        moyenne1 = mean(Gbl_Papp(1:maxMoy1));
//        moyenne2 = mean(Gbl_Papp(1:maxMoy2));
//        if (abs(moyenne1/moyenne2) > 0.99) then
//            moyenne = moyenne2;
//        end
//     end
     
    moyenne = mean(Gbl_Papp);

    // Temps cumulé en secondes
    for (ligne = 2:nbrLignes-1)
        if (Gbl_Papp(ligne) >= moyenne & Gbl_Papp(ligne-1) >= moyenne) then
            tempsTotal = tempsTotal + difTemps(Gbl_Heure(ligne-1), ...
                                        Gbl_Heure(ligne));
        end
    end
    
    // Temps en minutes & secondes
    if tempsTotal > 3600 then
        heure = floor(tempsTotal/3600);
        minutes = floor(modulo(tempsTotal,3600)/60);
        secondes = modulo(tempsTotal-heure*3600-minutes*60,60);
        duree = [heure minutes secondes];
        printf("Durée = %ih%im%is",duree(1), duree(2),duree(3));
    elseif tempsTotal > 60 then
        heure = 0;
        minutes = floor(tempsTotal/60);
        secondes = modulo(tempsTotal,60);
        duree = [heure minutes secondes];
        printf("Durée = %i''%i",duree(2),duree(3));
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
