//*****************************
/// \file Fonctions_Documenter.sci
/// \author Sébastien Lemoine
/// \date Septembre 2014
/// \brief Fonctions nécessaires à la génération de la documentation
//******************************

//****************************************************************************
// \fn indexLigne = Indexer_Ligne(contenu,indexLigne)
/// \brief Idexe les lignes d'un fichier
/// \param [in] contenu
/// \param [in] indexLigne
/// \param [out] indexLigne
/// \param [out] stcContenu
//*****************************************************************************
function Indexer_Ligne(contenu, stcDoc, tabBalises)
    indexFichier = stcDoc.fichiers.indexFichierCourant;
    nomFichier = stcDoc.fichiers.tab(indexFichier).nom;
    // Indexation précédente
    stcContenu_1 = struct("nom","");
    estFonction = %f;

    for indexLigne = 1:dimensions(contenu, "ligne")
        if grep(contenu(indexLigne),"/// ") == 1 then
            stcContenu = extraire_Balise(contenu(indexLigne));
            if ~stcContenu.contientBalise then
                stcContenu.nom = stcContenu_1.nom;
                stcContenu.est2Lignes = %t;
            else
                stcContenu.est2Lignes = %f;
            end
            // si le nom de la balise est reconnue alors extract sinon erreur
            // Todo
            if stcContenu.nom == tabBalises(1) then
                if stcContenu.est2Lignes then
                    // Concaténer avec la ligne précédente
                    temp = stcDoc.todo.tab(stcDoc.todo.nbr);
                    stcContenu.descr = descr_2_Lignes (temp, stcContenu);
                else
                    stcDoc.todo.nbr = stcDoc.todo.nbr + 1;
                    stcDoc.todo.tab(stcDoc.todo.nbr) = stcContenu.descr;
                end
            // Bug
            elseif stcContenu.nom == tabBalises(2) then
                stcDoc.bug.nbr = stcDoc.bug.nbr + 1;
                stcDoc.bug.tab(stcDoc.bug.nbr) = stcContenu.descr;
            // File
            elseif stcContenu.nom == tabBalises(3) then
                // Nom du fichier déjà connu
            // Author
            elseif stcContenu.nom == tabBalises(4) then
                stcDoc.fichiers.tab(indexFichier).auteur = stcContenu.descr;
            // Date
            elseif stcContenu.nom == tabBalises(5) then
                stcDoc.fichiers.tab(indexFichier).date = stcContenu.descr;
            // Brief
            elseif stcContenu.nom == tabBalises(6) then
                // Brief d'une fonction
                if estFonction then
                    // Sur plusieurs lignes
                    if stcContenu.est2Lignes then
                        // Concaténer avec la ligne précédente
                        temp = stcDoc.fichiers.tab(...
                                indexFichier).tabFonctions(nbrFonctions).resume;
                        stcContenu.descr = descr_2_Lignes (temp, stcContenu);
                    end
                    stcDoc.fichiers.tab(indexFichier).tabFonctions(...
                                nbrFonctions).resume = stcContenu.descr;
                // Brief du fichier
                else
                    // Sur plusieurs lignes
                    if stcContenu.est2Lignes then
                        // Concaténer avec la ligne précédente
                        temp1 = stcDoc.fichiers.tab(indexFichier).resume;
                        temp2 = stcContenu.descr;
                        stcContenu.descr = strcat([temp1, temp2]);
                    end
                    stcDoc.fichiers.tab(indexFichier).resume = stcContenu.descr;
                end
            // Fonction
            elseif stcContenu.nom == tabBalises(7) then
                nbrFonctions = stcDoc.fichiers.tab(indexFichier).nbrFonctions +1;
                stcDoc.fichiers.tab(indexFichier).nbrFonctions = nbrFonctions;
                stcDoc.fichiers.tab(indexFichier).tabFonctions(...
                                nbrFonctions).proto = stcContenu.descr;
                stcDoc.fichiers.tab(indexFichier).tabFonctions(...
                                nbrFonctions).nbrparam = 0;
                estFonction = %t;
            // Param
             elseif stcContenu.nom == tabBalises(8) then
                nbrparam = stcDoc.fichiers.tab(indexFichier).tabFonctions(...
                                nbrFonctions).nbrparam +1;
                stcDoc.fichiers.tab(indexFichier).tabFonctions(...
                                nbrFonctions).nbrparam = nbrparam;
                stcDoc.fichiers.tab(indexFichier).tabFonctions(...
                                nbrFonctions).param(nbrparam) = stcContenu.descr;
            // Return
            elseif stcContenu.nom == tabBalises(9) then
                stcDoc.fichiers.tab(indexFichier).retourne = stcContenu.descr;
            // Version
            elseif stcContenu.nom == tabBalises(10) then
                stcDoc.fichiers.tab(indexFichier).version = stcContenu.descr;
            // Balise non reconnue
            else
                printf("Erreur \t Fichier ''%s'', ligne %d: Balise non reconnue",...
                        nomFichier, indexLigne);
            end
            // Sauvegarde de l'indexation courante
            stcContenu_1 = stcContenu;
        end
    end
    
    [stcDoc] = resume(stcDoc);
endfunction



//****************************************************************************
// \fn stcContenu = extraire_Balise(contenuLigne)
/// \brief Localise et extrait le nom de la balise et sa description
/// \param [in] contenuLigne    \c string   Ligne à analyser
/// \return stcContenu    \c structure    Nom et description de la balise
//*****************************************************************************
function stcContenu = extraire_Balise(contenuLigne)
    stcContenu = struct("contientBalise",%f);
    finContenu = length(contenuLigne);
    
    // Localiser nom balise et description
    debutPosNom = strcspn(contenuLigne,"\")+2;
    // Si '\' trouvé
    if debutPosNom < finContenu then
        finPosNom = strcspn(part(contenuLigne,debutPosNom:finContenu),' ')+debutPosNom;
        
        // Extraire nom et description
        stcContenu.contientBalise = %t;
        stcContenu.nom = part(contenuLigne,debutPosNom:finPosNom-1);
        stcContenu.descr = part(contenuLigne,finPosNom+1:finContenu);
    else
        stcContenu.nom = "";
        debutPos = posi_Dern_Slash(contenuLigne, finContenu);
        stcContenu.descr = part(contenuLigne, debutPos+1:finContenu);
    end
endfunction


//****************************************************************************
// \fn estcontenu = est_Mot_Contenu(tableau, mot)
/// \brief Test l'existance d'un mot dans un tableau
/// \param [in] tableau    \c tabString   Tableau contenant le mot recherché
/// \param [in] mot    \c String   Mot recherché
/// \param [out] estcontenu    \c booléen    True si mot appartient à tableau
//*****************************************************************************
function estcontenu = est_Mot_Contenu(tableau, mot)
    estcontenu = %f;
    for index = 1:dimensions(tableau,"ligne");
        if mot == tableau(index) then
            estcontenu = %t;
            return
        end
    end
endfunction


//****************************************************************************
// \fn tabBalises = liste_Nom_Balises()
/// \brief Tableau contenant la liste des balises
/// \return [out] tabBalises    \c tabString    Liste des noms de balise
//*****************************************************************************
function tabBalises = liste_Nom_Balises()
    tabBalises(1) = "todo";
    tabBalises(2) = "bug";
    tabBalises(3) = "file";
    tabBalises(4) = "author";
    tabBalises(5) = "date";
    tabBalises(6) = "brief";
    tabBalises(7) = "fn";
    tabBalises(8) = "param";
    tabBalises(9) = "return";
    tabBalises(10) = "version";
endfunction

//****************************************************************************
// \fn dernPosi = posiDernAntiSlash(contenuLigne, finContenu)
/// \brief Detecte la position de "///"
/// \return dernPosi    \c double    position du 3ème '/'
//*****************************************************************************
function dernPosi = posi_Dern_Slash(contenuLigne, finContenu)
    for i = 1:finContenu-2
        if part(contenuLigne,i:i+2) == "///" then
            dernPosi = i+2;
            return
        end
    end
endfunction


//****************************************************************************
// \fn temp12 = descr_2_Lignes (temp1, stcContenu)
/// \brief Concaténer temp1 avec stcContenu.descr
/// \return temp12    \c string    Chaine concaténée
//*****************************************************************************
function temp12 = descr_2_Lignes (temp1, stcContenu)
    temp1 = stcDoc.fichiers.tab(...
            indexFichier).tabFonctions(nbrFonctions).resume;
    temp2 = stcContenu.descr;
    temp12 = strcat([temp1, temp2]);
    return
endfunction
