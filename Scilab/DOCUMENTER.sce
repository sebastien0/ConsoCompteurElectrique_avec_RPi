//*****************************
/// \author Sébastien Lemoine
/// \date Septembre 2014
/// \brief Indexer un répertoire contenant des fichiers Scilab et générer une documentation à plat.
///  Editer manuellement le fichier pour sélectionner le répertoire cible
/// \version 1.0
//******************************

/// \todo Générer une documentation HTML (type Doxygen)

clear
clc

//*** Chargement de l'environnement *******************************************
// Répertoires par défaut
// Chemin du répertoire courant, repertoire parent du projet Scilab
parentPath = pwd();
srcPath = strcat([parentPath,"\Documentation"]);


//*** CONFIGURATION MANUELLE *******************************************
// Chemin du répertoire à documenter
//targetPath = strcat([parentPath,"\Sources"]);
targetPath = strcat([parentPath,"\Documentation"]); // Documenter la documentation
nomFichier = "Documentation_Projet.txt";    // Nom du fichier de sortie
titreProjet = "R-Pi. Suivit Temps-Réel des consommations électriques";
debugActif = %t;    // Activer le debug
//*** Fin configuration manuelle *******************************************


documentationRecursive = targetPath == srcPath

// Charger les fonctions pour documenter
exec(srcPath+"\Documenter_Indexer.sci");
exec(srcPath+"\Documenter_Generer.sci");
exec(srcPath+"\Outils.sci");

//*** Début du programme *******************************************************
printf("*************************************************************\n");
printf("Générer la documentation du projet courant\nChemin: ''%s''\n", targetPath);
printf("*************************************************************\n\n");

if documentationRecursive then
    nomFichierPrincipal = "DOCUMENTER.sce";
    nomFichier = "Documentation_de_la_doc.txt";
    titreProjet = "Documentation de l''outil de documentation";
    // Dupliquer le fichier courant pour pouvoir l'indexer, il est supprimé à la fin
    [status, message] = copyfile(parentPath+"\"+nomFichierPrincipal, ...
                                 targetPath+"\"+nomFichierPrincipal);
    if status <> 1 then
       printf("Erreur \t La copie de ''%s'' s''est mal deroulée:\n%s\n", ...
            nomFichierPrincipal, message);
    end
end

cd(targetPath);
// Lister les fichiers dans le répertoire courant
listeNomFichiers = listfiles("*.sce");
listeNomFichiers_bis = listfiles("*.sci");
//Suprimer les fichiers temporaire (conteneant '~')
listeNomFichiers = supr_Fichiers_Temp(listeNomFichiers);
listeNomFichiers_bis = supr_Fichiers_Temp(listeNomFichiers_bis);
//Trier les noms de fichiers par ordre croissant
listeNomFichiers = gsort(listeNomFichiers,'lr','i');
listeNomFichiers_bis = gsort(listeNomFichiers_bis,'lr','i');
//Réunir les 2 listes
listeNomFichiers = cat(1, listeNomFichiers, listeNomFichiers_bis);
// Permet d'avoir toutes les info d'un fichier (nom, date, ...)
//stcFichier = dir(listeNomFichiers(i));

// Initalisation
stcDoc.fichiers = struct("nbr", dimensions(listeNomFichiers, "ligne"));
stcDoc.todo.nbr = 0;
stcDoc.bug.nbr = 0;
stcDoc.stc.nbr = 0;

//******* Indexer les fichiers ************
printf("Info \t %i fichiers à indexer\n", stcDoc.fichiers.nbr);
for indexFichier = 1 : stcDoc.fichiers.nbr
    stcDoc.fichiers.indexFichierCourant = indexFichier;
    stcDoc.fichiers.tab(stcDoc.fichiers.indexFichierCourant).nom = ...
                listeNomFichiers(stcDoc.fichiers.indexFichierCourant);
    printf("Info \t Traitement du fichier n°%i : %s\n", indexFichier, ...
                stcDoc.fichiers.tab(stcDoc.fichiers.indexFichierCourant).nom);
    indexer_Fichier(stcDoc, debugActif, targetPath);
    nbrFonctions = stcDoc.fichiers.tab(...
                            stcDoc.fichiers.indexFichierCourant).nbr;
    if nbrFonctions == 0 then
       printf("Attention \t Aucune fonction détectée\n");
    end
    printf("Info \t OK\n");
    sleep(500); // Pause 0.5s
end
printf("\nFin de l''indexation des fichiers \n");

if documentationRecursive then
    // Suppression du fichier dupliqué
    if ~deletefile(srcPath+"\"+nomFichierPrincipal) then
        printf("Erreur \t Supprimez manuellement le fichier ''%s''\n", ...
                srcPath+"\"+nomFichierPrincipal);
    end
end

cd(parentPath);
//******* Sauvegarder les données ************
if debugActif then
    nomFichierBinaire = strcat(["temp_",...
                                part(nomFichier,1:length(nomFichier)-4),...
                                ".sod"]);
    save(nomFichierBinaire,'stcDoc');
    printf("Donnees sauvegardées dans ''%s''\n", nomFichierBinaire);
end

//******* Fichier de sortie ************
printf("\nExportation de la documentation dans ''%s''\n",nomFichier);
creer_Documentation(stcDoc, titreProjet, nomFichier, debugActif);

printf("\nGénération de la documentation terminé\n");
printf("*************************************************************");



/// \stc stcDoc.      \c Structure    Documentation
///         todo.     \c Structure    'A faire'
///            nbr    \c double       Nombre de todo
///            tab.   \c tabStructure[nbr]     Liste des 'à faire'
///               fichier  \c String   Nom du fichier
///               ligne    \c double   Numéro de ligne
///               descr    \c String   Description du 'à faire'
///          bug.     \c Structure    Bug
///            nbr    \c double       Nombre de bug
///            tab.   \c tabStructure[nbr]     Liste des bug
///                fichier  \c String   Nom du fichier
///                ligne    \c double   Numéro de ligne
///                descr    \c String   Description du bug
///          fichiers.     \c Structure    Fichiers et Fonctions
///               nbr       \c double       Nombre de fichiers
///               indexFichierCourant    \c double   Utilisé lors de l'indexation
///               tab.       \c tabStructure[nbr] Documentation
///                  nom     \c String   Nom du fichier
///                  nbr     \c double   Nombre de fonctions
///                  auteur  \c String   Auteur
///                  date    \c String   Date
///                  version \c String   Version
///                  resume  \c String   Resumé du fichier
///                  tabFonctions.   \c tabStructure[nbr]    Documentation des fonctions
///                     proto        \c String   Prototype de la fonction
///                     ligne        \c Double   Ligne du fichier où est déclarée la fonction
///                     nom     \c String   Nom
///                     resume  \c String   Résumé
///                     nbrParam    \c Double   Nombre de paramètres
///                     tabParam    \c tabString[nbrParam]    Noms des paramètres
///                     nbrReturn   \c Double   Nombre de retours
///                     tabReturn      \c tabString[nbrReturn]  Noms des retours
///           stc.          \c Structure    Structures
///               nbr       \c double       Nombre de structures
///               tab.       \c tabStructure[nbr] Documentation
///                  fichier    \c String   Nom du fichier
///                  nom        \c String   Nom de la structure
///                  ligne      \c Double   Ligne du fichier où est déclarée la structure
///                  descr      \c String   Composition de la structure

