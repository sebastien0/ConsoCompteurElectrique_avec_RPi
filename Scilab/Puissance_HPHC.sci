

function Puissance_HCHP ()
    clc
    clear Puiss;
    
    HEURECREUSE = 1;   // Colonne contenant l'index Heure Creuse
    HEUREPLEINE = 2;   // Colonne contenant l'index Heure Pleine
    
    nbrLignes = size(Gbl_donnee_mesure);
    nbrLignes = nbrLignes(1)-1;
    
    Puiss = ones(nbrLignes-5);
    Energie_1 = 0;
    
    for Energie_1 = 2 : nbrLignes-4
        Energie_2 = Energie_1 + 1;
        temp_1 = msscanf(Gbl_donnee_mesure(Energie_1,1),'%d:%d:%d');
        temp_1 = temp_1(2)*60+temp_1(3);
        temp_2 = msscanf(Gbl_donnee_mesure(Energie_2,1),'%d:%d:%d');
        temp_2 = temp_2(2)*60+temp_2(3);
        Dtemp = temp_2 - temp_1;
        // Heures Pleines
        if Dtemp <> 0 then
            tempHP = (Gbl_Index(Energie_2,HEUREPLEINE) - Gbl_Index(Energie_1, HEUREPLEINE)) / Dtemp;
            tempHC = (Gbl_Index(Energie_2,HEURECREUSE) - Gbl_Index(Energie_1, HEURECREUSE)) / Dtemp;
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
endfunction

Puiss = [PuissHC PuissHP];
plot(Puiss);
