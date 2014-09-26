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
/// \param [out] strContenu
//*****************************************************************************
function Indexer_Ligne(contenu, stcDoc, tabBalises)
    indexFichier = stcDoc.fichiers.indexFichierCourant;
    nomFichier = stcDoc.fichiers.tab(indexFichier).nom;

//    for indexLigne = 1:dimensions(contenu, "ligne")
    for indexLigne = 1:10
        if  grep(contenu(indexLigne),"/// ") == 1 then
            strContenu = extraire_Balise(contenu(indexLigne));
            // si le nom de la balise est reconnue alors extract sinon erreur
            // Todo
            if strContenu.nom == tabBalises(1) then
                stcDoc.todo.nbr = stcDoc.todo.nbr + 1;
                stcDoc.todo.tab(stcDoc.todo.nbr) = strContenu.descr;
            // Bug
            elseif strContenu.nom == tabBalises(2) then
                stcDoc.bug.nbr = stcDoc.bug.nbr + 1;
                stcDoc.bug.tab(stcDoc.bug.nbr) = strContenu.descr;
            // File
            elseif strContenu.nom == tabBalises(3) then
                // Nom du fichier déjà connu
            // Author
            elseif strContenu.nom == tabBalises(4) then
                stcDoc.fichiers.tab(indexFichier).auteur = strContenu.descr;
            // Date
            elseif strContenu.nom == tabBalises(5) then
                stcDoc.fichiers.tab(indexFichier).date = strContenu.descr;
            // Brief
            elseif strContenu.nom == tabBalises(6) then
                stcDoc.fichiers.tab(indexFichier).resume = strContenu.descr;
            // Fonction
            elseif strContenu.nom == tabBalises(7) then
                nbrFonctions = stcDoc.fichiers.tab(indexFichier).nbrFonctions +1;
                stcDoc.fichiers.tab(indexFichier).nbrFonctions = nbrFonctions;
                stcDoc.fichiers.tab(indexFichier).tabFonctions(...
                                nbrFonctions).proto = strContenu.descr;
                stcDoc.fichiers.tab(indexFichier).tabFonctions(...
                                nbrFonctions).nbrparam = 0;
            // Param
             elseif strContenu.nom == tabBalises(8) then
                nbrparam = stcDoc.fichiers.tab(indexFichier).tabFonctions(...
                                nbrFonctions).nbrparam +1;
                stcDoc.fichiers.tab(indexFichier).tabFonctions(...
                                nbrFonctions).nbrparam = nbrparam;
                stcDoc.fichiers.tab(indexFichier).tabFonctions(...
                                nbrFonctions).param(nbrparam) = strContenu.descr;
            // Return
            elseif strContenu.nom == tabBalises(9) then
                stcDoc.fichiers.tab(indexFichier).retourne = strContenu.descr;
            // Version
            elseif strContenu.nom == tabBalises(10) then
                stcDoc.fichiers.tab(indexFichier).version = strContenu.descr;
            // Balise non reconnue
            else
                printf("Erreur \t Fichier ''%s'', ligne %d: Balise non reconnue",...
                        nomFichier, indexLigne);
            end
        end
    end
    
    [stcDoc] = resume(stcDoc);
endfunction



//****************************************************************************
// \fn strContenu = extraire_Balise(contenuLigne)
/// \brief Localise et extrait le nom de la balise et sa description
/// \param [in] contenuLigne    \c string   Ligne à analyser
/// \return strContenu    \c structure    Nom et description de la balise
//*****************************************************************************
function strContenu = extraire_Balise(contenuLigne)
    strContenu = struct("nom","");
    finContenu = length(contenuLigne);
    
    // Localiser nom balise et description
    debutPosNom = strcspn(contenuLigne,"\")+2;
    // Si '\' trouvé
    if debutPosNom < finContenu then
        finPosNom = strcspn(part(contenuLigne,debutPosNom:finContenu),' ')+debutPosNom;
        
        // Extraire nom et description
        strContenu.nom = part(contenuLigne,debutPosNom:finPosNom-1);
        strContenu.descr = part(contenuLigne,finPosNom+1:finContenu);
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
