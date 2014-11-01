//*****************************
/// \author Sébastien Lemoine
/// \date Octobre 2014
/// \brief Fonctions nécessaires à la génération de la documentation
//******************************

//****************************************************************************
/// \fn creer_Documentation(stcDoc, nomProjet, nomFichier, debugActif)
/// \brief Exporte dans un fichier texte la documentation du projet
/// \param [in] stcDoc  \c Structure    Documentation
/// \param [in] nomProjet  \c String    Titre inscrit dans le document
/// \param [in] nomFichier  \c String    Nom du fichier généré
/// \param [in] debugActif  \c Booléen    Vrai pour afficher plus d'info en console
//*****************************************************************************
function creer_Documentation(stcDoc, nomProjet, nomFichier, debugActif)
    // Créer et ouvrir le fichier
    [fd, err] = mopen(nomFichier, 'wt');

    // Remplir fichier
    if err == 0 then
        mfprintf(fd,"Documentation du projet: %s\n",nomProjet);
        // Date et heure
        tempDate = getdate();
        mfprintf(fd,"Générée le %i-%s-%s %s:%s:%s\n",tempDate(1), ...
            nombre_2_Chiffres(tempDate(2)), nombre_2_Chiffres(tempDate(6)),...
            nombre_2_Chiffres(tempDate(7)), nombre_2_Chiffres(tempDate(8)),...
            nombre_2_Chiffres(tempDate(9)));

        mfprintf(fd,"\n********* BUG ********************\n");
        if stcDoc.bug.nbr == 0 then
            mfprintf(fd,"Aucun BUG remonté\n");
        else
            ecrireTab(fd, stcDoc.bug);
        end

        mfprintf(fd,"\n********* TODO ********************\n");
        if stcDoc.todo.nbr == 0 then
            mfprintf(fd,"Aucun TODO remonté\n");
        else
            ecrireTab(fd, stcDoc.todo);
        end
        
        mfprintf(fd,"\n********* STRUCTURES ********************\n");
        if stcDoc.stc.nbr == 0 then
            mfprintf(fd,"Aucune structure remontée\n");
        else
            ecrireTab(fd, stcDoc.stc,%t);
        end
    
        mfprintf(fd,"\n********* FICHIERS & FONCTIONS ********************\n");
        ecrireTabFnct(fd, stcDoc.fichiers, debugActif);

        mfprintf(fd,"\n--- Fin de la documentation ----");
        // Fermer fichier
        mclose(fd);

    else
        printf("Erreur \t Impossible d''ouvrir le fichier %s\n",nomFichier);
    end
endfunction

//****************************************************************************
/// \fn ecrireTab(fd, stcDocPartiel, opt_Stc)
/// \brief Ecrire le contenu de stcDocPartiel dans le fichier
/// \param [in] fd  \c FileDesciptor    Fichier de sortie
/// \param [in] stcDocPartiel  \c Structure    Documentation de type BUG, TODO, STC
/// \param [in] opt_Stc  \c Booléen    Si présent, stcDocPartiel traité comme STC
//*****************************************************************************
function ecrireTab(fd, stcDocPartiel, opt_Stc)
    // Parcourir toutes les entrées
    for i=1:stcDocPartiel.nbr
        stcTxt = stcDocPartiel.tab(i);
        // Nom de la structure
        if argn(2) == 3 then
            mfprintf(fd,"%i - %s\n", i, stcTxt.nom);
            mfprintf(fd,"%sFichier: %s\n",indenter(1), stcTxt.fichier);
        else
            mfprintf(fd,"%i - %s\n", i, stcTxt.fichier);
        end
        mfprintf(fd,"%sLigne: %i\n",indenter(1),stcTxt.ligne);
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
/// \param [in] stcDoc  \c Structure    Documentation de type FICHIERS
/// \param [in] debugActif  \c Booléen    Vrai pour afficher plus d'info en console
//*****************************************************************************
function ecrireTabFnct(fd, stcDocPartiel, debugActif)
    // Parcourir toutes les entrées
    /// \todo Trier les fonctions par nom et non par ordre d'apparition
    ///        Une ébauche de code ci-dessous
    // Trier les noms des fonctions par ordre croissant
//    listeNomsFonctions = stcDoc.fichiers.tab(stcDoc.fichiers.indexFichierCourant).tabFonctions.nom;
//    for i=1:dimensions(listeNomsFonctions,"ligne");
//        strListeNomsFonctions(i) = string(listeNomsFonctions(i));
//    end
//    listeNomsFonctionsTrie = gsort(strListeNomsFonctions,'lr','i');

    for i=1:stcDocPartiel.nbr
        try
            stcFichier = stcDocPartiel.tab(i);
            // *************** Fichier ***************
            mfprintf(fd,"%i - %s\n", i, stcFichier.nom);
            if stcFichier.auteur <> [] then
                // Affichage sur plusieurs lignes
                for k = 1 : dimensions(stcFichier.auteur,"ligne")
                    mfprintf(fd,"%s%s\n", indenter(1), stcFichier.auteur(k));
                end
            end
            if stcFichier.date <> [] then
                mfprintf(fd,"%s%s\n", indenter(1), stcFichier.date);
            end
            if stcFichier.version <> [] then
                mfprintf(fd,"%sVersion: %s\n", indenter(1), stcFichier.version);
            end
            if stcFichier.resume <> [] then
                mfprintf(fd,"%sRésumé: %s\n", indenter(1), stcFichier.resume(1));
                // Affichage sur plusieurs lignes
                if dimensions(stcFichier.resume,"ligne") > 1 then
                    for k = 2 : dimensions(stcFichier.resume,"ligne")
                        mfprintf(fd,"%s%s\n", indenter(1), stcFichier.resume(k));
                    end
                end
            end
            
            // *************** Fonctions ***************
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
                // Ligne
                mfprintf(fd,"%sLigne: %d\n",indenter(3),stcTxtFonction.ligne);
                // Résumé
                // Affichage sur plusieurs lignes
                mfprintf(fd,"%sRésumé: %s\n",indenter(3),stcTxtFonction.resume(1));
                if dimensions(stcTxtFonction.resume,"ligne") > 1 then
                    for k = 2 : dimensions(stcTxtFonction.resume,"ligne")
                        mfprintf(fd,"%s%s\n",indenter(3),stcTxtFonction.resume(k));
                    end
                end
                // Proto
                mfprintf(fd,"%s%s\n",indenter(3),stcTxtFonction.proto);
                // Parametres
                if stcTxtFonction.nbrparam > 0 then
                    for k = 1:stcTxtFonction.nbrparam
                        mfprintf(fd,"%sParam: %s\n",indenter(4),...
                            stcTxtFonction.tabparam(k).descr);
                    end
                end
                // Retourne
                if stcTxtFonction.nbrreturn > 0 then
                    for k = 1:stcTxtFonction.nbrreturn
                        mfprintf(fd,"%sRetourne: %s\n",indenter(4),...
                            stcTxtFonction.return(k).descr);
                    end
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
