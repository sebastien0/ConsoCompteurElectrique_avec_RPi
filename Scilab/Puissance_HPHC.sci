//* ***************************************************************************
//* Reconstituer la puissance apparente depuis les index HC et HP
//*
//*
//*****************************************************************************
function Papp = Puissance_HCHP (Heure, Index)
    HEURECREUSE = 1;   // Colonne contenant l'index Heure Creuse
    HEUREPLEINE = 2;   // Colonne contenant l'index Heure Pleine
    
    nbrLignes = size(Heure);
    nbrLignes = nbrLignes(1)-1;
    
    Puiss = ones(nbrLignes-5);
    Energie_1 = 0;
    
    for Energie_1 = 2 : nbrLignes-1
        //Différence de temps entre les 2 échantillons
        Energie_2 = Energie_1 + 1;
        temp_1 = msscanf(Heure(Energie_1-1,1),'%d:%d:%d');
        temp_1 = temp_1(2)*60+temp_1(3);
        temp_2 = msscanf(Heure(Energie_2-1,1),'%d:%d:%d');
        temp_2 = temp_2(2)*60+temp_2(3);
        Dtemp = temp_2 - temp_1;

        //Puissance
        if Dtemp <> 0 then
            tempHP = (Index(Energie_2,HEUREPLEINE) - ...
                      Index(Energie_1, HEUREPLEINE)) / Dtemp;
            tempHC = (Index(Energie_2,HEURECREUSE) - ...
                      Index(Energie_1, HEURECREUSE)) / Dtemp;
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
    
    Papp = (PuissHC+PuissHP)*3600;

    // Filtrer le signal sur 40 échantillons ~ 1min
    Papp = moyenneGlissante(Papp, 40);
endfunction
