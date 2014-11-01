//*****************************
/// \author Sébastien Lemoine
/// \date Mai 2014
/// \brief Utilisation de l'algorithme du GLR de Brandt
//******************************

//*****************************************************************************
// * Mise en oeuvre
exec("GlrBrandtMoy.sci");
// h = 4; Nest = 10; Ndmax = 0;
h = 6; Nest = 10; Ndmax = 0;    // Dans le cas des communs
//h = 6; Nest = 10; Ndmax = 0;    // Dans le cas des communs
//x = Gbl_Papp(1:10000);    // Fenetre pour la mise au point
nbrLignes = size(Gbl_Papp);
nbrLignes = nbrLignes(1);
x = Gbl_Papp(1:(nbrLignes - Nest));
tic;
[g,mc,kd,krmv] = GlrBrandtMoy(x,h,Nest,Ndmax);
toc
reglerFctDeci(x, h, g, mc);
//*****************************************************************************


//*****************************************************************************
/// \fn [g,mc,kd,krmv] = GlrBrandtMoy(x,h,Nest,Ndmax)
/// \brief GLR DE BRANDT POUR SAUT DE MOYENNE
///        (détecter un saut de moyenne de valeur inconnue)
/// \author P. Granjon - pierre.granjon@grenoble-inp.fr - Grenoble INP, Ense3, Gipsa-Lab
/// \param [in] x   \c tabDouble    Signal gaussien
/// \param [in] h   \c double   Seuil pour le critère d'arrêt
/// \param [in] Nest    \c double   Taille fixe de la fenêtre d'estimation de m1
/// \param [in] Ndmax   \c double   Nombre max de détections (infini si nul)
// \return g    \c tabDouble    Vecteur fonction de décision
// \return mc   \c tabDouble    Vecteur moyenne constante par morceaux estimé
// \return kd   \c tabDouble    Vecteur instants de détection de la rupture
// \return krmv    \c tabDouble Vecteur estimateurs du MV des instants de rupture
//*****************************************************************************
function [g,mc,kd,krmv] = GlrBrandtMoy(x,h,Nest,Ndmax)
    //Gestion nombre de détections infini
    if Ndmax == 0 then
        Ndmax = length(x)+1;
    end
    
    //Initialisations générales
    Nd = 0;           //nombre de détections
    kd = length(x);   //instants de détection
    krmv = length(x); //instants de rupture
    
    //Algo échantillon k0=k=1
    k0=1;k=1;//instant initial
    //init estimation moyenne et variance récursive
    m(k0)=x(k0);     //moyenne
    mo2(k0)=x(k0)^2; //moment d'ordre 2
    v(k0)=0;        //variance
    //fonction de décision
    g(k0)=0;
    
    //Algo échantillon k>=2
    while k < length(x) & Nd < Ndmax
        
// Ajout Seb
        v(k) = 0;
        while v(k) == 0 do 
            k=k+1;
            //Estimation récursive moyenne et variance courantes
            m(k)=((k-k0)*m(k-1)+x(k))/(k-k0+1);
            mo2(k)=((k-k0)*mo2(k-1)+x(k)^2)/(k-k0+1);
            v(k)=(k-k0+1)/(k-k0)*(mo2(k)-(m(k))^2);
        end
// Fin ajout seb

        //fonction de décision nulle a priori
        g(k)=0;
        if (k>k0+1) then //attente pour RAZ de g(k)
            //Pour les N premiers échantillons après init, GLR classique
            if (k<Nest+k0) then 
                //Estimation kr et m1 les + vraisemblables
                for j=k0+1:k
                    m1(j)=mean(x(j:k));
                    rupture(j)=(k-j+1)/(j-k0)*(m(k)-m1(j))^2;
                end
                [maxi,krmvtest]=max(rupture(k0+1:k));
                krmvtest=krmvtest+k0;
                //Calcul de la fonction de décision
                g(k)=(k-k0+1)*(k-krmvtest+1)/(krmvtest-k0)*...
                     (m(k)-m1(krmvtest))^2/(2*v(k));
                //Test d'arrêt sur g
                if (g(k)>h) then
                    Nd=Nd+1;          //nbr de détections
                    kd(Nd)=k;         //instant de détection
                    krmv(Nd)=krmvtest;//instant de rupture estimé
                    k0=k;m(k0)=x(k0);mo2(k0)=x(k0)^2;//réinitit algo (sauf v(k))
                end
            else //Pour les échantillons suivants, GLR de Brandt
                //Estimation de m1 sur fenêtre fixe de taille N = GLR de Brandt
                m1=mean(x(k-Nest+1:k));
                //Calcul de la fonction de décision
                g(k)=(k-k0+1)*Nest/(k-Nest+1-k0)*(m(k)-m1)^2/(2*v(k));
                //Test d'arrêt sur g
                if (g(k)>h)
                    Nd=Nd+1;          //nbr de détections
                    kd(Nd)=k;         //instant de détection
                    //recherche de l'instant de rupture entre k-N+1 et k par MV
                    for j=k-Nest+1:k
                        m1(j)=mean(x(j:k));
                        rupture(j)=(k-j+1)/(j-k0)*(m(k)-m1(j))^2;
                    end
                    [maxi,krmvtest]=max(rupture(k-Nest+1:k));
                    krmv(Nd)=krmvtest+k-Nest;//instant de rupture estimé
                    k0=k;m(k0)=x(k0);mo2(k0)=x(k0)^2;//réinitit algo (sauf v(k))
                end
            end
        end
    end
    
    //vecteur moyenne constante par morceaux estimé
    if Nd==0 then
        mc=mean(x(1:k))*ones(1,k);
    elseif Nd==1 then
        mc=[mean(x(1:krmv(1)-1))*ones(1,krmv(1)-1) mean(x(krmv(1):k))*...
            ones(1,k-krmv(1)+1)];
    else
        mc=[mean(x(1:krmv(1)-1))*ones(1,krmv(1)-1)];
        for ii=2:Nd
            mc=[mc mean(x(krmv(ii-1):krmv(ii)-1))*ones(1,krmv(ii)-krmv(ii-1))];
        end
        mc=[mc mean(x(krmv(Nd):k))*ones(1,k-krmv(Nd)+1)];
    end
endfunction


//*****************************************************************************
/// \fn reglerFctDeci(x, h, g, mc)
/// \brief Réglage de la fonction de décision en traçant les grandeurs utiles
/// \param [in] x   \c tabDouble    Signal gaussien
/// \param [in] h   \c double   Seuil pour le critère d'arrêt
/// \param [in] g    \c tabDouble    Vecteur fonction de décision
/// \param [in] mc   \c tabDouble    Vecteur moyenne constante par morceaux estimé
//*****************************************************************************
function reglerFctDeci(x, h, g, mc)
    // Signal & signal moyenné par morceaux
    subplot(211);
    plot(x,'b');
    plot(mc,'r');
    
    // Fonction de décision et seuil
    subplot(212);
    plot(g,'b');
    nbrLignes = size(x);
    nbrLignes = nbrLignes(1);
    htrace = h*ones(nbrLignes,1);
    plot(htrace,'g');
endfunction
