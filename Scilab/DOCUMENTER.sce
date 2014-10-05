//*****************************
/// \file DOCUMENTER.sce
/// \author Sébastien Lemoine
/// \date Septembre 2014
/// \brief Indexer tous les fichiers pour générer une stcDocumentation type Doxygen
///     (Doxygen n'est pas capable de traiter les fichiers Scilab ou Mathlab)
/// \version 0.1
//******************************

/// \BUG -Test- Aucun bug!

clear
clc
//*** Chargement de l'environnement *******************************************
// Répertoires par défaut
// Chemin du répertoire courant, repertoire parent du projet Scilab
parentPath = pwd();
fnctPath = strcat([parentPath,"\Sources"]);

// Dupliquer le fichier courant pour pouvoir l'indexer, il est supprimé à la fin
nomFichierParent = listfiles("*.sce");

cd(fnctPath);

// Charger les fonctions de calculs
exec("Calculs.sci");
// Charger les fonctions pour documenter
exec("Fonctions_Documenter.sci");

//*** Début du programme *******************************************************
printf("*************************************************************\n");
printf("Generer la documentation du projet courant\nChemin: ''%s''\n", fnctPath);
printf("*************************************************************\n\n");

//Suprimer les fichiers temporaire (conteneant '~')
nomFichierParent = supr_Fichiers_Temp(nomFichierParent);
nomFichierParent = strcat(["cp_", nomFichierParent]);
[status, message] = copyfile(parentPath+"\"+nomFichierParent, ...
                             fnctPath+"\"+nomFichierParent);
if status <> 1 then
   printf("Erreur \t La copie de ''%s'' s''est mal deroulee:\n%s\n", ...
        nomFichierParent, message);
end

// Lister les fichiers dans le répertoire courant
listeNomFichiers = listfiles(["*.sci","*.sce"]);
//Suprimer les fichiers temporaire (conteneant '~')
listeNomFichiers = supr_Fichiers_Temp(listeNomFichiers);
//Trier les noms de fichiers par ordre croissant
listeNomFichiers = gsort(listeNomFichiers,'lr','i');
// Permet d'avoir toutes les info d'un fichier (nom, date, ...)
//stcFichier = dir(listeNomFichiers(i));

// Tableau des balises indéxées
tabBalises = liste_Nom_Balises();

// Initalisation
//Nombre de fichiers
stcDoc.fichiers = struct("nbrFichiers", dimensions(listeNomFichiers, "ligne"));
// Nombre de todo
stcDoc.todo.nbr = 0;
// Nombre de bug
stcDoc.bug.nbr = 0;

//******* Indexer les fichiers ************
printf("Info \t %i fichiers a indexer\n", stcDoc.fichiers.nbrFichiers);
for indexFichier = 1 : stcDoc.fichiers.nbrFichiers
    stcDoc.fichiers.indexFichierCourant = indexFichier;
    // Nom du fichier
    stcDoc.fichiers.tab(stcDoc.fichiers.indexFichierCourant).nom = ...
                listeNomFichiers(stcDoc.fichiers.indexFichierCourant);
    printf("Info \t Traitement du fichier n°%i : %s\n", indexFichier, ...
                stcDoc.fichiers.tab(stcDoc.fichiers.indexFichierCourant).nom);
    indexer_Fichier(tabBalises, stcDoc);
    nbrFonctions = stcDoc.fichiers.tab(...
                            stcDoc.fichiers.indexFichierCourant).nbrFonctions;
    if nbrFonctions == 0 then
       printf("Attention \t Aucune fonction detecte\n");
    end
    sleep(500); // Pause 0.5s
end
printf("Fin de l''indexation des fichiers \n");

// Suppression du fichier dupliqué
if ~deletefile(nomFichierParent) then
    printf("Erreur \t Supprimez manuellement le fichier ''%s''\n", ...
            fnctPath+"\"+nomFichierParent);
end

//******* Sauvegarder les données ************
save(fnctPath+"\temp_Documentation.sod",'stcDoc');
printf("Donnees sauvegardées dans ''%s''\n", fnctPath+"\temp_Documentation.sod");

//******* Fichier de sortie ************
//Exporter la structure dans un ficheir CSV?!

printf("Fin de la documentation\n");
cd(parentPath);
