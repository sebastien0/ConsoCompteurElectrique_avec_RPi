//*****************************
/// \file DOCUMENTER.sce
/// \author Sébastien Lemoine
/// \date Septembre 2014
/// \brief Indexer tous les fichiers pour générer une stcDocumentation type Doxygen
///     (Doxygen n'est pas capable de traiter les fichiers Scilab ou Mathlab)
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

tabBalises = liste_Nom_Balises();

//******* Inder les fichiers ************
//for i =1 : dimensions(listeNomFichiers, "ligne")
stcDoc.fichiers = struct("indexFichierCourant",0);
for stcDoc.fichiers.indexFichierCourant = 1 : 2
    stcDoc.fichiers.nbrFichiers = dimensions(listeNomFichiers, "ligne");
    stcDoc.fichiers.tab(stcDoc.fichiers.indexFichierCourant).nom = ...
                listeNomFichiers(stcDoc.fichiers.indexFichierCourant);
    //Ouvrir chaque fichier
    cheminFichierCourant = strcat([fnctPath,'\', ...
                stcDoc.fichiers.tab(stcDoc.fichiers.indexFichierCourant).nom]);
    mopen(cheminFichierCourant,'r'); // Ouverture du fichier
    stcFichierCourant = struct("contenu", "");
    contenu = mgetl(cheminFichierCourant);  // Lecture du fichier
    stcFichierCourant.contenu = contenu;
    clear contenu;
    mclose(cheminFichierCourant);  // Fermeture du fichier
    stcFichierCourant.nbrLignes = dimensions(stcFichierCourant.contenu, "ligne");
    
    //Parcourir toutes les lignes
     stcFichierCourant.indexLigne = 1;
//    while indexLigne <=  stcFichierCourant.nbrLignes do
    while stcFichierCourant.indexLigne < 10 do
//         stcFichierCourant = Indexer_Ligne(stcFichierCourant, stcDoc.fichiers, tabBalises);
         Indexer_Ligne(stcFichierCourant, stcDoc.fichiers, tabBalises);
        
    end
end
//******* Fichier de sortie ************
//Exporter la structure dans un ficheir CSV?!


