//*****************************
/// \file DOCUMENTER.sce
/// \author Sébastien Lemoine
/// \date Septembre 2014
/// \brief Indexer tous les fichiers pour générer une stcDocumentation type Doxygen
///     (Doxygen n'est pas capable de traiter les fichiers Scilab ou Mathlab)
/// \version 0.1
//******************************

clear
clc
//*** Chargement de l'environnement *******************************************
// Répertoires par défaut
// Chemin du répertoire courant, repertoire parent du projet Scilab
fnctPath = pwd();

// Charger les fonctions de calculs
exec(fnctPath+"\Calculs.sci");
// Charger les fonctions pour documenter
exec(fnctPath+"\Fonctions_Documenter.sci");

// Lister les fichiers dans le répertoire courant
listeNomFichiers = listfiles("*.sci","*.sce");
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

//******* Inder les fichiers ************
//for stcDoc.fichiers.indexFichierCourant = 1 : stcDoc.fichiers.nbrFichiers
for indexFichier = 1 : 1
    stcDoc.fichiers.indexFichierCourant = indexFichier;
    // Nom du fichier
    stcDoc.fichiers.tab(stcDoc.fichiers.indexFichierCourant).nom = ...
                listeNomFichiers(stcDoc.fichiers.indexFichierCourant);
    // Nombre de fonctions
    stcDoc.fichiers.tab(stcDoc.fichiers.indexFichierCourant).nbrFonctions = 0;

    // Ouvrir le fichier
    // Chemin
    cheminFichierCourant = strcat([fnctPath,'\', ...
                stcDoc.fichiers.tab(stcDoc.fichiers.indexFichierCourant).nom]);
    // Ouvrir
    mopen(cheminFichierCourant,'r'); // Ouverture du fichier
    // Copier
    stcFichierCourant = struct("contenu", "");
    contenu = mgetl(cheminFichierCourant);  // Lecture du fichier
    // Fermer
    mclose(cheminFichierCourant);  // Fermeture du fichier

// Si NOK alors faire une sous structure (du fichier) et la reporter dans la structure principale
     Indexer_Ligne(contenu, stcDoc, tabBalises);
        
end
//******* Fichier de sortie ************
//Exporter la structure dans un ficheir CSV?!


