//*****************************
/// \author Sébastien Lemoine
/// \date Aout 2014
/// \brief Fonction annexes pour le traitement de données
//******************************

//****************************************************************************
/// \fn Heure = Modifier_Horodatage(Heure, offset)
/// \brief Ajouter ou supprimer un décalage temporel pour un relevé
/// \param [in] Heure  \c tabString    Heure du relevé
/// \param [in] offset  \c tabDouble(3)    Décalage [hh,mm,ss]
/// \return Heure \c tabString     Heure du relevé avec le décalage
//*****************************************************************************
function Heure = Modifier_Horodatage(Heure, offset)
    INDSECONDES = 3;
    INDMINUTES = 2;
    INDHEURES = 1;
    
    longueur = dimensions(Heure, "ligne");   // dimension
    Heure(longueur) = "";
    
    for ligne = 1:longueur
    //    printf("Ligne: %d \t Heure(ligne): %s\n", ligne, Heure(ligne));
        tempHeure = evstr([part(Heure(ligne),1:2),part(Heure(ligne),4:5),...
                     part(Heure(ligne),7:8)]);
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
    //    printf("\t\t Heure: %.2d:%.2d:%.2d\n", tempHeure(INDHEURES), tempHeure(INDMINUTES), tempHeure(INDSECONDES));
        Heure(ligne) = msprintf('%.2d:%.2d:%.2d',tempHeure(INDHEURES), ...
                                tempHeure(INDMINUTES), tempHeure(INDSECONDES));
    end
endfunction
