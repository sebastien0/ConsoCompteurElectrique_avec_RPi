
// Chez Jef:
// Réel 2014-08-16 18h26
// R-pi 2014-08-08 21h33
// Diff = +8jours - 3h07
// Modifier_Horodatage(Gbl_Heure, [-3 -7 0])

function Modifier_Horodatage(Heure, offset)
INDSECONDES = 3;
INDMINUTES = 2;
INDHEURES = 1;

longueur = dimensions(Heure, "ligne");   // dimension

for ligne = 1:longueur
//    printf("Ligne: %d \t Heure(ligne): %s\n", ligne, Heure(ligne));
    tempHeure = msscanf(Heure(ligne),'%d:%d:%d');
    // Offset de temps
    tempHeure(INDSECONDES) = tempHeure(INDSECONDES) + offset(INDSECONDES);    // Secondes
    tempHeure(INDMINUTES) = tempHeure(INDMINUTES) + offset(INDMINUTES);    // Minutes
    tempHeure(INDHEURES) = tempHeure(INDHEURES) + offset(INDHEURES);    // Heures
    
    if tempHeure(INDSECONDES) < 0 then
        tempHeure(INDMINUTES) = tempHeure(INDMINUTES) - 1;
        tempHeure(INDSECONDES) = tempHeure(INDSECONDES) + 60;
    end
    
    if tempHeure(INDMINUTES) < 0 then
        tempHeure(INDHEURES) = tempHeure(INDHEURES) - 1;
        tempHeure(INDMINUTES) = tempHeure(INDMINUTES) + 60;
    end
    
    if tempHeure(INDHEURES) < 0 then
       tempHeure(INDHEURES) = tempHeure(INDHEURES) + 24;
    end
//    printf("\t\t Heure: %.2d:%.2d:%.2d\n", tempHeure(1), tempHeure(INDMINUTES), tempHeure(INDSECONDES));
    Heure(ligne) = msprintf('%.2d:%.2d:%.2d',tempHeure(1), tempHeure(INDMINUTES), tempHeure(INDSECONDES));
end

[Gbl_Heure] = resume(Heure);
endfunction
