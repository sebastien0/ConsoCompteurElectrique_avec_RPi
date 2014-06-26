@echo off
echo #################################################
echo %TIME%   Telechargement des fichiers
echo #################################################

REM Télécharger tous les fichiers d'un repertoire
mkdir FichiersTelecharges
ftp -i -s:test_PCSeb.txt
REM ftp -i -s:FTP_R-Pi.txt

echo %TIME%   Fichiers recupere(s)

REM ne conserver que les fichiers .txt
cd FichiersTelecharges
for /f "delims==" %%F in ('dir /b *') do (
REM	echo Nom fichier : %%F
REM	echo Extension fichier : %%~xF
	if not "%%~xF" ==".txt" (
		del %%F
REM		echo fichier %%F supprime
	)
)

echo %TIME%   Fin du programme

pause

