//*****************************
/// \author Sébastien Lemoine
/// \date Septembre 2014
/// \brief Fonctions nécessaires à l'indexation de la documentation
//******************************

//****************************************************************************
/// \fn indexer_Fichier(stcDoc, debugActif, targetPath)
/// \brief Indexe un fichier
/// \param [in] stcDoc  \c Structure    Documentation
/// \param [in] debugActif  \c Booléen    Afficher plus d'info en console
/// \param [in] targetPath  \c String    Chemin du répertoire courant
/// \param [out] stcDoc  \c Structure    Documentation
//*****************************************************************************
function indexer_Fichier(stcDoc, debugActif, targetPath)
    // Ouvrir le fichier
    // Chemin
    cheminFichierCourant = strcat([targetPath,'\', ...
                stcDoc.fichiers.tab(stcDoc.fichiers.indexFichierCourant).nom]);
    // Ouvrir
    [fd, err] = mopen(cheminFichierCourant,'r'); // Ouverture du fichier
    if err == 0 then
        // Copier
        contenu = mgetl(cheminFichierCourant);  // Lecture du fichier
        // Fermer
        mclose(cheminFichierCourant);  // Fermeture du fichier
        indexer_Ligne(contenu, stcDoc, debugActif);
    else
        nom = stcDoc.fichiers.tab(stcDoc.fichiers.indexFichierCourant).nom;
        printf("Erreur \t Erreur %i dans l''ouverture du fichier %s\n",err,nom);
    end

    [stcDoc] = return(stcDoc);
endfunction



//****************************************************************************
/// \fn indexer_Ligne(contenu, stcDoc, debugActif)
/// \brief Idexe les lignes d'un fichier
/// \param [in] contenu \c tabString    Fichier courant ouvert dans Scilab
/// \param [in] stcDoc \c Structure    Documentation
/// \param [in] debugActif  \c Booléen    Afficher plus d'info en console
/// \param [out] stcDoc \c Structure    Documentation
//*****************************************************************************
function indexer_Ligne(contenu, stcDoc, debugActif)
    indexFichier = stcDoc.fichiers.indexFichierCourant;
    nomFichier = stcDoc.fichiers.tab(indexFichier).nom;
    stcDoc.fichiers.tab(stcDoc.fichiers.indexFichierCourant).nbr = 0;
    stcDoc.stc.nbr == 0;
    tabBalises = liste_Nom_Balises();
    
    // Initialisation
    stcContenu_1 = struct("nom","");
    estFonction = %f;
    nbrFonctions = 0;
    indexLigne = 1;
    
    while (indexLigne <= dimensions(contenu, "ligne"))
    //      for indexLigne = 1:3
        try
            // 2ème condition pour éviter d'indexer la ligne elle-même
            if (grep(contenu(indexLigne),"/// ") == 1 &...
                grep(contenu(indexLigne),"grep(contenu") <> 1) then
                stcContenu = extraire_Balise(contenu(indexLigne));
                // Si pas de balise alors texte sur plusieurs lignes
                if ~stcContenu.contientBalise then
                    stcContenu.nom = stcContenu_1.nom;
                end
                // si le nom de la balise est reconnue alors extract sinon erreur
                
                // *************** Todo***************
                if convstr(stcContenu.nom,'u') == convstr(tabBalises(1),'u') then
                    if ~stcContenu.contientBalise then
                        indexLigne = description_sur_lignes(contenu, ...
                                    indexLigne, stcContenu_1.descr);
                    else
                        stcDoc.todo.nbr = stcDoc.todo.nbr + 1;
                        stcDoc.todo.tab(stcDoc.todo.nbr).fichier = nomFichier;
                        stcDoc.todo.tab(stcDoc.todo.nbr).ligne = indexLigne;
                    end
                    stcDoc.todo.tab(stcDoc.todo.nbr).descr = stcContenu.descr;
    
                // *************** Bug ***************
                elseif convstr(stcContenu.nom,'u') == convstr(tabBalises(2),'u') then
                    if ~stcContenu.contientBalise then
                        indexLigne = description_sur_lignes(contenu, ...
                                    indexLigne, stcContenu_1.descr);
                    else
                        stcDoc.bug.nbr = stcDoc.bug.nbr + 1;
                        stcDoc.bug.tab(stcDoc.bug.nbr).fichier = nomFichier;
                        stcDoc.bug.tab(stcDoc.bug.nbr).ligne = indexLigne;
                    end
                    stcDoc.bug.tab(stcDoc.bug.nbr).descr = stcContenu.descr;

                // *************** Warning ***************
                elseif convstr(stcContenu.nom,'u') == convstr(tabBalises(11),'u') then
                    if ~stcContenu.contientBalise then
                        indexLigne = description_sur_lignes(contenu, ...
                                    indexLigne, stcContenu_1.descr);
                    else
                        stcDoc.warn.nbr = stcDoc.warn.nbr + 1;
                        stcDoc.warn.tab(stcDoc.warn.nbr).fichier = nomFichier;
                        stcDoc.warn.tab(stcDoc.warn.nbr).ligne = indexLigne;
                    end
                    stcDoc.warn.tab(stcDoc.warn.nbr).descr = stcContenu.descr;

                // *************** Version ***************
                elseif stcContenu.nom == tabBalises(3) then
                    stcDoc.fichiers.tab(indexFichier).version = stcContenu.descr;
                
                // *************** Author ***************
                elseif stcContenu.nom == tabBalises(4) then
                    if ~stcContenu.contientBalise then
                        indexLigne = description_sur_lignes(contenu, ...
                                    indexLigne, stcContenu_1.descr);
                    end
                    stcDoc.fichiers.tab(indexFichier).auteur = stcContenu.descr;
               
                // *************** Date ***************
                elseif stcContenu.nom == tabBalises(5) then
                    stcDoc.fichiers.tab(indexFichier).date = stcContenu.descr;

                // *************** Brief ***************
                elseif stcContenu.nom == tabBalises(6) then
                    // Brief d'une fonction
                    if estFonction then
                        // Attrapper erreur si \fn manquant
                        try
                            // Sur plusieurs lignes
                            if ~stcContenu.contientBalise then
                                indexLigne = description_sur_lignes(contenu, ...
                                    indexLigne, stcContenu_1.descr);
                            end
                            stcDoc.fichiers.tab(indexFichier).tabFonctions(...
                                    nbrFonctions).resume = stcContenu.descr;
                        catch
                            printf("Erreur \t Ligne %d: Balise ''fonction'' manquante\n",...
                                    indexLigne);
                        end
    
                    // Brief du fichier
                    else
                        // Sur plusieurs lignes
                       if ~stcContenu.contientBalise then
                          indexLigne = description_sur_lignes(contenu, ...
                                    indexLigne, stcContenu_1.descr);
                        end
                        stcDoc.fichiers.tab(indexFichier).resume = stcContenu.descr;
                        if stcDoc.fichiers.tab(indexFichier) == [] then
                            stcDoc.fichiers.tab(indexFichier).date="";
                            stcDoc.fichiers.tab(indexFichier).version="";
                        end
                    end
                
                // *************** Fonction ***************
                elseif stcContenu.nom == tabBalises(7) then
                    // Initialisation
                    estFonction = %t;
                    nbrFonctions = stcDoc.fichiers.tab(indexFichier).nbr +1;
                    stcDoc.fichiers.tab(indexFichier).nbr = nbrFonctions;
                    // Nom
                    // Si première fonction du fichier
                    if nbrFonctions == 1 then
                        stcDoc.fichiers.tab(indexFichier).tabFonctions(...
                                nbrFonctions) = struct("nom","");
                    end
                    if grep(stcContenu.descr,'(') == 1 then
                        nom = part(stcContenu.descr, 1:strcspn(stcContenu.descr,'('));
                            if grep(nom,'=') == 1 then
                                nom = part(nom,strcspn(stcContenu.descr,'=')+2:length(nom));
                            end
                    else
                        printf("Erreur \t Ligne %d: prototype mal interprété\n",...
                               indexLigne);
                        nom = "";
                    end
                    
                    stcDoc.fichiers.tab(indexFichier).tabFonctions(...
                                    nbrFonctions).nom = nom;
                    // Résumé
                    stcDoc.fichiers.tab(indexFichier).tabFonctions(...
                                nbrFonctions).resume="";
                    // Param
                    stcDoc.fichiers.tab(indexFichier).tabFonctions(...
                                nbrFonctions).nbrparam = 0;
                    stcDoc.fichiers.tab(indexFichier).tabFonctions(...
                                nbrFonctions).tabparam = struct("descr","");
                    // Retourne
                    stcDoc.fichiers.tab(indexFichier).tabFonctions(...
                                    nbrFonctions).nbrreturn = 0;
                    stcDoc.fichiers.tab(indexFichier).tabFonctions(...
                                nbrFonctions).return = struct("descr","");
                    // Proto
                    stcDoc.fichiers.tab(indexFichier).tabFonctions(...
                                    nbrFonctions).proto = stcContenu.descr;
                    // Ligne
                    stcDoc.fichiers.tab(indexFichier).tabFonctions(...
                                    nbrFonctions).ligne = indexLigne;

                // *************** Param ***************
                elseif stcContenu.nom == tabBalises(8) then
                    nbrparam = stcDoc.fichiers.tab(indexFichier).tabFonctions(...
                                nbrFonctions).nbrparam;
                 // Sur plusieurs lignes
                    if ~stcContenu.contientBalise then
                        indexLigne = description_sur_lignes(contenu, ...
                                    indexLigne, stcContenu_1.descr);
                    else
                        nbrparam = nbrparam +1;
                        stcDoc.fichiers.tab(indexFichier).tabFonctions(...
                                        nbrFonctions).nbrparam = nbrparam;
                    end
                    stcDoc.fichiers.tab(indexFichier).tabFonctions(...
                        nbrFonctions).tabparam(nbrparam).descr = stcContenu.descr;
                
                // *************** Return ***************
                elseif stcContenu.nom == tabBalises(9) then
                    nbrreturn = stcDoc.fichiers.tab(indexFichier).tabFonctions(...
                                nbrFonctions).nbrreturn;
                    // Sur plusieurs lignes
                    if ~stcContenu.contientBalise then
                        indexLigne = description_sur_lignes(contenu, ...
                                    indexLigne, stcContenu_1.descr);
                    else
                        nbrreturn = nbrreturn +1;
                        stcDoc.fichiers.tab(indexFichier).tabFonctions(...
                            nbrFonctions).nbrreturn = nbrreturn;
                    end
                    stcDoc.fichiers.tab(indexFichier).tabFonctions(...
                            nbrFonctions).return(nbrreturn).descr = stcContenu.descr;

                // *************** Structure ***************
                elseif convstr(stcContenu.nom,'u') == convstr(tabBalises(10),'u') then
                    // Si première structure
                    if stcDoc.stc.nbr == 0 then
                        stcDoc.stc.tab(stcDoc.stc.nbr) = struct("nom","");
                    end
                    // Sur plusieurs lignes
                    if ~stcContenu.contientBalise then
                        indexLigne = description_sur_lignes(contenu, ...
                                    indexLigne, stcContenu_1.descr);
                    else
                        stcDoc.stc.nbr = stcDoc.stc.nbr + 1;
                        stcDoc.stc.tab(stcDoc.stc.nbr).fichier = nomFichier;
                        stcDoc.stc.tab(stcDoc.stc.nbr).ligne = indexLigne;
                        // Composition du nom
                        tailleNom = strcspn(stcContenu.descr,'.');
                        if tailleNom < length(stcContenu.descr) then
                            nom = part(stcContenu.descr, 1:tailleNom);
                            stcContenu.descr = strcat(["    ", stcContenu.descr]);
                         else
                            printf("Erreur \t Ligne %d: Structure mal interprétée\n",...
                                    indexLigne);
                            nom = "";
                        end
                        stcDoc.stc.tab(stcDoc.stc.nbr).nom = nom;
                    end
                    stcDoc.stc.tab(stcDoc.stc.nbr).descr = stcContenu.descr;

                // *************** Balise non reconnue ***************
                else
                    printf("Erreur \t Ligne %d: Balise non reconnue\n",indexLigne);
                end
                // Sauvegarde de l'indexation courante
                stcContenu_1 = stcContenu;
            end
        catch
            printf("Erreur \t Problème avec le fichier ''%s'' à la ligne %i\n",...
                    nomFichier, indexLigne);
            if  debugActif then
                pause
            end
        end
        indexLigne = indexLigne +1;
    end
    
    [stcDoc] = resume(stcDoc);
endfunction



//****************************************************************************
/// \fn stcContenu = extraire_Balise(contenuLigne)
/// \brief Localise et extrait le nom de la balise et sa description
/// \param [in] contenuLigne    \c string   Ligne à analyser
/// \return stcContenu    \c structure    Nom et description de la balise
//*****************************************************************************
function stcContenu = extraire_Balise(contenuLigne)
    stcContenu = struct("contientBalise",%f);
    finContenu = length(contenuLigne);
    
    // Localiser nom balise et description
    debutPosNom = strcspn(contenuLigne,"\")+2;
                    
    // Nouvelle balise
    // Si '\' trouvé
    if (debutPosNom < finContenu) then
        finPosNom = strcspn(part(contenuLigne,debutPosNom:finContenu),' ') + ...
                    debutPosNom - 1;
        // Il s'agit d'une balise
        if est_Mot_Contenu(convstr(liste_Nom_Balises(),'u'),...
            convstr(part(contenuLigne, debutPosNom:finPosNom),'u')) then
            // Extraire nom et description
            stcContenu.contientBalise = %t;
            stcContenu.nom = part(contenuLigne,debutPosNom:finPosNom);
            stcContenu.descr = part(contenuLigne,finPosNom+2:finContenu);
        // Signe de mise en forme
        else
            debutPos = posi_Dern_Slash(contenuLigne, finContenu)+1;
            stcContenu.descr = part(contenuLigne,debutPos:finContenu);
        end
    // Suite d'un commentaire
    else
        stcContenu.nom = "";
        debutPos = posi_Dern_Slash(contenuLigne, finContenu)+1;
        stcContenu.descr = part(contenuLigne, debutPos:finContenu);
    end
endfunction


//****************************************************************************
/// \fn estcontenu = est_Mot_Contenu(tableau, mot)
/// \brief Test l'existence d'un mot dans un tableau
/// \param [in] tableau    \c tabString   Tableau contenant le mot recherché
/// \param [in] mot    \c String   Mot recherché
/// \return estcontenu    \c booléen    Vrai si 'mot' appartient à 'tableau'
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
/// \fn tabBalises = liste_Nom_Balises()
/// \brief Tableau contenant la liste des balises
/// Liste des balises traitées, au format '/// \balise ' avec un espace obligatoire après le mot clef:
/// - todo
/// - bug
/// - version
/// - author
/// - date
/// - brief
/// - fn
/// - param
/// - return
/// - stc
/// - warning
/// \return tabBalises    \c tabString    Liste des noms de balise
//*****************************************************************************
function tabBalises = liste_Nom_Balises()
    tabBalises(1) = "todo";
    tabBalises(2) = "bug";
    tabBalises(3) = "version";
    tabBalises(4) = "author";
    tabBalises(5) = "date";
    tabBalises(6) = "brief";
    tabBalises(7) = "fn";
    tabBalises(8) = "param";
    tabBalises(9) = "return";
    tabBalises(10) = "stc";
    tabBalises(11) = "warning";
endfunction

//****************************************************************************
/// \fn dernPosi = posiDernAntiSlash(contenuLigne, finContenu)
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
/// \fn temp12 = descr_2_Lignes (textePrecedent, temp2, opt_multiLignes)
/// \brief Concaténer temp2 avec textePrecedent
/// \param [in] textePrecedent \c String    Texte original
/// \param [in] temp2 \c String     Texte à ajouter
/// \param [in] opt_multiLignes \c boolen   Si présent, temp2 est ajouté sur une nouvelle ligne
/// \return temp12    \c tabString[]    Chaine concaténée, sur une ligne ou de dimensions textePrecedent + 1
//*****************************************************************************
function temp12 = descr_2_Lignes (textePrecedent, temp2, opt_multiLignes)
    // Sur plusieurs lignes
    if argn(2) == 3 then
        if textePrecedent == "" then
            temp12 = temp2;
        else
            temp12 = textePrecedent;
            temp12(dimensions(textePrecedent,"ligne")+1,1) = temp2;
        end
    // Sur une seule ligne
    else
        temp12 = strcat([textePrecedent, temp2]);
    end
endfunction


//****************************************************************************
/// \fn listeNomFichiers = supr_Fichiers_Temp(tempListeNomFichiers)
/// \brief Retirer de la liste des fichiers ceux contenant '~'
/// \param [in] tempListeNomFichiers \c tabString[]    Liste des noms de fichiers
/// \return listeNomFichiers    \c tabString[]    Liste des noms de fichiers
//*****************************************************************************
function listeNomFichiers = supr_Fichiers_Temp(tempListeNomFichiers)
    j=1;
    for i = 1:dimensions(tempListeNomFichiers,'ligne')
        if grep(tempListeNomFichiers(i),'~') <> 1 then
            listeNomFichiers(j)=tempListeNomFichiers(i);
            j=j+1;
        end
    end
endfunction


//****************************************************************************
/// \fn indexLigne = description_sur_lignes(contenu, indexLigneE, textePrecedent)
/// \brief Indexe une balise sur plusieurs lignes
/// \param [in] contenu \c String   Fichier à indexer
/// \param [in] indexLigneE \c Double   Ligne courante
/// \param [in] textePrecedent \c String   Description de la balise (1ère ligne)
/// \param [out] stcContenu \c Structure    Propriétés de la balise
/// \return indexLigne    \c Double    Dernière ligne contenant le descriptif de la balise
//*****************************************************************************
function indexLigne = description_sur_lignes(contenu, indexLigneE, textePrecedent)
    indexLigne = indexLigneE;
    // Concaténer avec les lignes précédentes
    continuer = %t;
    while (grep(contenu(indexLigne),"/// ") == 1 &...
            grep(contenu(indexLigne),"grep(contenu") <> 1 & continuer)
        stcContenu = extraire_Balise(contenu(indexLigne));
        continuer = ~stcContenu.contientBalise;
        if continuer then
            textePrecedent = descr_2_Lignes(textePrecedent, stcContenu.descr, %f);

            indexLigne = indexLigne+1;
            if indexLigne > dimensions(contenu,"ligne") then
                indexLigne = indexLigne -1;
                continuer = %f;
                printf("Attention \t Laisser 2 lignes vide à la fin du fichier\n");
            end
        end
    end
    stcContenu.descr = textePrecedent;
    indexLigne = indexLigne-1;
    
    [stcContenu] = resume(stcContenu);
endfunction


/// \stc stcContenu.    \c Structure    Structure temporaire pour la documentation de chaque balise
///         nom         \c String       Nom de la balise
///         descr       \c tabString    Description
///         contientBalise  \c Booléen  Vrai si la ligne courante contient une balise reconnue

/// \stc stcContenu_1.   \c Structure    Copie de l'état précédent de stcContenu
