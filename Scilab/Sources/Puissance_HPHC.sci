//*****************************
/// \author Sébastien Lemoine
/// \date Avril 2014
/// \brief Fonctions dans le cas d'une configuration HCHP
//******************************

//****************************************************************************
/// \fn Puissance_HCHP(stcReleve, etapeTotale)
/// \brief Reconstituer la puissance apparente depuis les index HC et HP
/// Filtrage glissant sur 40 échantillons
/// \param [in] stcReleve   \c structure   Relevé
/// \param [in] etapeTotale \c String   Nombre total de phases d'indexation
/// \param [out] stcReleve   \c structure   Relevé avec la papp différent de 0
//*****************************************************************************
function Puissance_HCHP(stcReleve, etapeTotale)
    HEURECREUSE = 1;   // Colonne contenant l'index Heure Creuse
    HEUREPLEINE = 2;   // Colonne contenant l'index Heure Pleine
    progression = 0;
    multipleLigne = floor((stcReleve.nbrLignes-1)/99);

    for increment = 0:98
       for ligne = 2 : multipleLigne
           Energie_1 = multipleLigne*increment + ligne;
            //Différence de temps entre les 2 échantillons
            Energie_2 = Energie_1 + 1;
            temp_1 = stcReleve.heure(Energie_1-1);
            temp_2 = stcReleve.heure(Energie_2-1);
            Dtemp = difTemps(temp_1,temp_2);
    
            //Puissance
            if Dtemp > 0 then
                tempHP = (stcReleve.index(Energie_2, HEUREPLEINE) - ...
                          stcReleve.index(Energie_1, HEUREPLEINE)) / Dtemp;
                tempHC = (stcReleve.index(Energie_2, HEURECREUSE) - ...
                          stcReleve.index(Energie_1, HEURECREUSE)) / Dtemp;
                if tempHP < 0 then
                    tempHP = 0;
                end
                if tempHC < 0 then
                    tempHC = 0;
                end
                PuissHP(Energie_1-1) = tempHP;
                PuissHC(Energie_1-1) = tempHC;
            else
                PuissHP(Energie_1-1) = 0;
                PuissHC(Energie_1-1) = 0;
            end
        end
    barre_Progression(stcStatistiques, Energie_1, progression, ["4",etapeTotale]);
    end

    for Energie_1 = Energie_1 : stcReleve.nbrLignes-1
        //Différence de temps entre les 2 échantillons
        Energie_2 = Energie_1 + 1;
        temp_1 = stcReleve.heure(Energie_1-1);
        temp_2 = stcReleve.heure(Energie_2-1);
        Dtemp = difTemps(temp_1,temp_2);

        //Puissance
        if Dtemp > 0 then
            tempHP = (stcReleve.index(Energie_2, HEUREPLEINE) - ...
                      stcReleve.index(Energie_1, HEUREPLEINE)) / Dtemp;
            tempHC = (stcReleve.index(Energie_2, HEURECREUSE) - ...
                      stcReleve.index(Energie_1, HEURECREUSE)) / Dtemp;
            if tempHP < 0 then
                tempHP = 0;
            end
            if tempHC < 0 then
                tempHC = 0;
            end
            PuissHP(Energie_1-1) = tempHP;
            PuissHC(Energie_1-1) = tempHC;
        else
            PuissHP(Energie_1-1) = 0;
            PuissHC(Energie_1-1) = 0;
        end
    end
    barre_Progression(stcStatistiques, Energie_1, progression, ["4",etapeTotale]);
    
    stcReleve.papp = (PuissHC+PuissHP)*3600;

    // Filtrer le signal sur 40 échantillons ~ 1min
    stcReleve.papp = moyenneGlissante(stcReleve.papp, 40);
    
    [stcReleve] = resume(stcReleve);
endfunction
