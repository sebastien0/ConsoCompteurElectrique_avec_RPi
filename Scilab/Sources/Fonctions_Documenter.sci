//*****************************
/// \file Fonctions_Documenter.sci
/// \author Sébastien Lemoine
/// \date Septembre 2014
/// \brief Fonctions nécessaires à la génération de la documentation
//******************************

//****************************************************************************
// \fn indexLigne = Indexer_Ligne(contenu,indexLigne)
/// \brief Identifie si la ligne (ou les suivantes dans le cas d'un paragraphe) 
///     est à indexer. Retourne la ligne suivante à indexer et le contenu indexé
/// \param [in] contenu
/// \param [in] indexLigne
/// \param [out] indexLigne
/// \param [out] strContenu
//*****************************************************************************
function Indexer_Ligne(stcFichierCourant, stcDocFichier, tabBalises)
    // Initialiser le nombre de fonctions
    try
        temp = stcDocFichier.tab(stcDocFichier.indexFichierCourant).nbrFonctions;
    catch
        stcDocFichier.tab(stcDocFichier.indexFichierCourant).nbrFonctions = 0;
    end
    
    // Ligne à indexer
    /// TODO : Bug avec grep
//    if  (grep(stcFichierCourant.contenu(stcFichierCourant.indexLigne),"/// ") == 1) then
//        strContenu = balise(stcFichierCourant);
//        // si nom balise reconnu alors sauv sinon erreur
////        if est_Mot_Contenu(tabBalises, strContenu.nom) then
//        // Auteur
//        if strContenu.nom == tabBalises(4) then
//            stcDocFichiers.tab(stcDocFichiers.indexFichierCourant).auteur = strContenu.descr;
//        // Date
//        elseif strContenu.nom == tabBalises(5) then
//            stcDocFichiers.tab(stcDocFichiers.indexFichierCourant).date = strContenu.descr;
//        // Résumé
//        elseif strContenu.nom == tabBalises(6) then
//            stcDocFichiers.tab(stcDocFichiers.indexFichierCourant).resume = strContenu.descr;
//        // Fonction
//        elseif strContenu.nom == tabBalises(7) then
//            stcDocFichiers.tab(stcDocFichiers.indexFichierCourant).nbrFonctions = stcDocFichiers.tab(stcDocFichiers.indexFichierCourant).nbrFonctions +1;
//            stcDocFichiers.tab(stcDocFichiers.indexFichierCourant).tabFonctions(stcDocFichiers.tab(stcDocFichiers.indexFichierCourant).nbrFonctions).proto = strContenu.descr;
//        // Balise non reconnue
//        else
//            printf("Erreur \t Fichier ''%s'', ligne %d: Balise non reconnue",...
//                    stcDocFichiers.tab(stcDocFichiers.indexFichierCourant).nom,...
//                    stcFichierCourant.indexLigne);
//        end
//        stcFichierCourant.indexLigne = stcFichierCourant.indexLigne+1;
//    
//    // Paragraphe à indexer
//    elseif  (grep(stcFichierCourant.contenu(stcFichierCourant.indexLigne),"//* " == 1))  then
//        printf("Paragraphe a indexer trouve\n");
//
//
//        stcFichierCourant.indexLigne = stcFichierCourant.indexLigne+1;
//    // Aucun contenu à indexer
//    else
        stcFichierCourant.indexLigne = stcFichierCourant.indexLigne+1;
//    end
    
    [stcFichierCourant, stcDocFichier] = resume(stcFichierCourant, stcDocFichier);
endfunction



//****************************************************************************
// \fn contenu = balise(contenuLigne)
/// \brief Localise et extrait le nom de la balise et sa description
/// \param [in] contenuLigne    \c string   Ligne à analyser
/// \param [out] contenu    \c structure    Nom et description de la balise
//*****************************************************************************
function strContenu = balise(stcFichierCourant)
    contenuLigne = stcFichierCourant.contenu(stcFichierCourant.indexLigne);
    finContenu = length(contenuLigne);
    
    // Localiser nom balise et description
    debutPosNom = strcspn(contenuLigne,"\")+2;

    finPosNom = strcspn(part(contenuLigne,debutPosNom:finContenu),' ')+debutPosNom;
    // Extraire nom et description
    strContenu = struct("nom", part(contenuLigne,debutPosNom:finPosNom-1));
    strContenu.descr = part(contenuLigne,finPosNom+1:finContenu);
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
//    tabBalises(10) = "";
//    tabBalises(11) = "";
endfunction
