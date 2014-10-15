//*****************************
/// \author Sébastien Lemoine
/// \date Octobre 2014
/// \brief Fonctions nécessaires à la génération de la documentation
//******************************

//****************************************************************************
/// \fn creer_Documentation(stcDoc, nomProjet, nomFichier, debugActif)
/// \brief Exporte dans un fichier texte la documentation du projet
/// \param [in] stcDoc  \c Structure    Documentation
/// \param [in] debugActif  \c Booléen    Afficher plus d'info en console
//*****************************************************************************
function creer_Documentation(stcDoc, nomProjet, nomFichier, debugActif)
    // Créer et ouvrir le fichier
    [fd, err] = mopen(nomFichier, 'wt');

    // Remplir fichier
    if err == 0 then
        mfprintf(fd,"Documentation du projet: %s\n",nomProjet);
        // Date et heure
        tempDate = getdate();
        mfprintf(fd,"Générée le %i-%s-%s\n",tempDate(1), ...
            nombre_2_Chiffres(tempDate(2)), nombre_2_Chiffres(tempDate(6)));

        mfprintf(fd,"\n********* BUG **********\n");
        if stcDoc.bug.nbr == 0 then
            mfprintf(fd,"Aucun BUG remonté\n");
        else
            ecrireTab(fd, stcDoc.bug);
        end

        mfprintf(fd,"\n********* TODO **********\n");
        if stcDoc.todo.nbr == 0 then
            mfprintf(fd,"Aucun TODO remonté\n");
        else
            ecrireTab(fd, stcDoc.todo);
        end
    
        mfprintf(fd,"\n********* FONCTIONS **********\n");
        ecrireTabFnct(fd, stcDoc.fichiers);

        mfprintf(fd,"\n--- Fin de la documentation ----");
        // Fermer fichier
        mclose(fd);

    else
        printf("Erreur \t Impossible d''ouvrir le fichier %s\n",nomFichier);
    end
endfunction

//****************************************************************************
/// \fn ecrireTab(fd, stcDocPartiel)
/// \brief Ecrire dans le fichier le contenu de stcDocPartiel
/// \param [in] fd  \c FileDesciptor    Fichier de sortie
/// \param [in] stcDoc  \c Structure    Documentation
//*****************************************************************************
function ecrireTab(fd, stcDocPartiel)
    // Parcourir toutes les entrées
    for i=1:stcDocPartiel.nbr
        stcTxt = stcDocPartiel.tab(i);
        mfprintf(fd,"%i - %s\n", i, stcTxt.fichier);
        mfprintf(fd,"%sLigne %i\n",indenter(1),stcTxt.ligne);
        // Si description sur plusieurs lignes
        for j = 1:dimensions(stcTxt.descr,"ligne") 
            mfprintf(fd,"%s%s\n",indenter(1),stcTxt.descr(j));
        end
    end
endfunction


//****************************************************************************
/// \fn strEspaces = indenter(niveau)
/// \brief Retourne un nombre d'espace multiple du niveau de profondeur
/// \param [in] niveau  \c double    Niveau de profondeur
/// \return strEspaces  \c string   Chaine d'espaces
//*****************************************************************************
function strEspaces = indenter(niveau)
    strEspaces = "";
    for i = 1:niveau
        strEspaces =  strcat([strEspaces, "   "]);
    end
endfunction

//****************************************************************************
/// \fn ecrireTabFnct(fd, stcDocPartiel, debugActif)
/// \brief Ecrire dans le fichier le contenu de stcDocPartiel
/// \param [in] fd  \c FileDesciptor    Fichier de sortie
/// \param [in] stcDoc  \c Structure    Documentation
/// \param [in] debugActif  \c Booléen    Afficher plus d'info en console
//*****************************************************************************
function ecrireTabFnct(fd, stcDocPartiel, debugActif)
    // Parcourir toutes les entrées
    /// \todo Trier les fonctions par nom et non par ordre d'apparition
    for i=1:stcDocPartiel.nbr
        try
            stcFichier = stcDocPartiel.tab(i);
            // Fichier
            mfprintf(fd,"%i - %s\n", i, stcFichier.nom);
            if stcFichier.auteur <> [] then
                mfprintf(fd,"%s%s\n", indenter(1), stcFichier.auteur);
            end
            if stcFichier.date <> [] then
                mfprintf(fd,"%s%s\n", indenter(1), stcFichier.date);
            end
            if stcFichier.version <> [] then
                mfprintf(fd,"%sVersion %s\n", indenter(1), stcFichier.version);
            end
            if stcFichier.resume <> [] then
                mfprintf(fd,"%s%s\n", indenter(1), stcFichier.resume);
            end
            
            //Fonctions
            for j = 1:stcFichier.nbr
                stcTxtFonction = stcFichier.tabFonctions(j);
                // Noms
                // 1ère lettre en majuscule
                posi=1;
                while part(stcTxtFonction.nom,posi) == ' '
                    posi=posi+1;
                end
                txt = convstr(part(stcTxtFonction.nom,posi),'u');
                txt = strcat([txt, part(stcTxtFonction.nom, ...
                            posi+1:length(stcTxtFonction.nom))]);
    
                mfprintf(fd,"%s%i - %s\n",indenter(2),j,txt);
                mfprintf(fd,"%sLigne %d\n",indenter(3),stcTxtFonction.ligne);
                mfprintf(fd,"%s%s\n",indenter(3),stcTxtFonction.resume);
                mfprintf(fd,"%s%s\n",indenter(3),stcTxtFonction.proto);
                // Parametres
                if stcTxtFonction.nbrparam > 0 then
                    for k = 1:stcTxtFonction.nbrparam
                        mfprintf(fd,"%s%s\n",indenter(4),stcTxtFonction.param(k));
                    end
                end
                // Retourne
                if stcTxtFonction.retourne <> "" then
                    mfprintf(fd,"%s%s\n",indenter(4),stcTxtFonction.retourne);
                    /// \todo Si plusieurs 'retourne', décomenter le code
        //            for k = 1:stcTxtFonction.nbrRetourne
        //                mfprintf(fd,"%s%s\n",indenter(3), ...
        //                          stcTxtFonction.tabRetourne(k));
        //            end
                end
            end
        catch
            printf("Erreur \t Problème avec le fichier ''%s''\n",stcFichier.nom);
            if  debugActif then
                pause
            end
        end
    end
endfunction
