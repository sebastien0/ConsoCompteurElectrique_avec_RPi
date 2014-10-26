//*****************************
/// \author Sébastien Lemoine
/// \date Septembre 2014
/// \brief Indexer tous les fichiers pour générer une documentation type Doxygen
/// \version 1.0
//******************************

/// \todo Devellopper une fonction pour indexer les csv
/// \todo Reprendre les noms de la sous-structure "tabFonctions" et "todo"

/// \stc stcDoc.      \c Structure    Documentation
///         todo.     \c Structure    A faire
///            nbr    \c double       Nombre de todo
///            tabTodo.    \c tabStructure[nbr]     Liste des à faire
///               fichier  \c String   Nom du fichier
///               ligne    \c double   Numéro de ligne
///               descr    \c String   Description des à faire
///          bug.     \c Structure    Bug
///            nbr    \c double       Nombre de bug
///            tabBug.     \c tabStructure[nbr]     Liste des bug
///                fichier  \c String   Nom du fichier
///                ligne    \c double   Numéro de ligne
///                descr    \c String   Description des bug
///           fichiers.     \c Structure    Fichiers et Fonctions
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
///                     nom     \c String   Nom de la fonction
///                     resume  \c String   Résumé de la fonction
///                     nbrParam    \c Double   Nombre de paramètres
///                     tabParam    \c tabString[nbrParam]    Noms des paramètres
///                     nbrReturn   \c Double   Nombre de retour
///                     tabReturn      \c tabString[nbrReturn]  Noms des retours


clear
clc

//*** Chargement de l'environnement *******************************************
// Répertoires par défaut
// Chemin du répertoire courant, repertoire parent du projet Scilab
parentPath = pwd();
fnctPath = strcat([parentPath,"\Sources"]);
srcPath = strcat([parentPath,"\Documentation"]);

//*** CONFIGURATION MANUELLE *******************************************
targetPath = fnctPath;  // Chemin du répertoire cible (à indexer)
nomFichier = "Documentation.txt";   // Nom du fichier
debugActif = %t;    // Activer le debug


// Liste des fichiers dans le répertoire
nomFichierParent = listfiles("*.sce");

cd(srcPath);
// Charger les fonctions pour documenter
exec("Documenter_Indexer.sci");
exec("Documenter_Generer.sci");

/// \todo Recopier le fichier Calculs.sci dans l'arborecence de la documentation
cd(fnctPath);
// Charger les fonctions de calculs
exec("Calculs.sci");

//*** Début du programme *******************************************************
printf("*************************************************************\n");
printf("Générer la documentation du projet courant\nChemin: ''%s''\n", targetPath);
printf("*************************************************************\n\n");

// Suprimer les fichiers temporaire de la liste (conteneant '~')
nomFichierParent_init = supr_Fichiers_Temp(nomFichierParent);
nomFichierParent = nomFichierParent_init;
// Dupliquer le fichier courant pour pouvoir l'indexer, il est supprimé à la fin
[status, message] = copyfile(parentPath+"\"+nomFichierParent_init, ...
                             srcPath+"\"+nomFichierParent);
if status <> 1 then
   printf("Erreur \t La copie de ''%s'' s''est mal deroulée:\n%s\n", ...
        nomFichierParent, message);
end

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
//Nombre de fichiers
stcDoc.fichiers = struct("nbr", dimensions(listeNomFichiers, "ligne"));
stcDoc.todo.nbr = 0;
stcDoc.bug.nbr = 0;

//******* Indexer les fichiers ************
printf("Info \t %i fichiers à indexer\n", stcDoc.fichiers.nbr);
for indexFichier = 1 : stcDoc.fichiers.nbr
    stcDoc.fichiers.indexFichierCourant = indexFichier;
    stcDoc.fichiers.tab(stcDoc.fichiers.indexFichierCourant).nom = ...
                listeNomFichiers(stcDoc.fichiers.indexFichierCourant);
    printf("Info \t Traitement du fichier n°%i : %s\n", indexFichier, ...
                stcDoc.fichiers.tab(stcDoc.fichiers.indexFichierCourant).nom);
    indexer_Fichier(stcDoc, debugActif);
    nbrFonctions = stcDoc.fichiers.tab(...
                            stcDoc.fichiers.indexFichierCourant).nbr;
    if nbrFonctions == 0 then
       printf("Attention \t Aucune fonction détectée\n");
    end
    sleep(500); // Pause 0.5s
end
printf("\nFin de l''indexation des fichiers \n");

// Suppression du fichier dupliqué
if ~deletefile(srcPath+"\"+nomFichierParent) then
    printf("Erreur \t Supprimez manuellement le fichier ''%s''\n", ...
            srcPath+"\"+nomFichierParent);
end

cd(parentPath);
//******* Sauvegarder les données ************
if debugActif then
    save('temp_Documentation.sod','stcDoc');
    printf("Donnees sauvegardées dans ''%s''\n", "temp_Documentation.sod");
end

//******* Fichier de sortie ************
printf("\nExportation de la documentation dans ''%s''\n","Documentation.txt");
/// \todo Exporter la structure stcDoc dans un fichier CSV au lieu du .txt?!
creer_Documentation(stcDoc,...
                    "R-Pi. Suivit Temps-Réel des consommations électriques",...
                    nomFichier, debugActif);

printf("\nGénération de la documentation terminé\n");
printf("*************************************************************");
