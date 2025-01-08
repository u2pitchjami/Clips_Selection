#!/bin/bash
############################################################################## 
#                                                                            #
#	SHELL: !/bin/bash       version 3.1                                      #
#									                                         #
#	NOM: u2pitchjami						                                 #
#									                                         #
#	            							                                 #
#									                                         #
#	DATE: 15/11/2024	           				                             #
#								                                    	     #
#	BUT: Sélectionne les fichiers flac techno/house	: modifs uniquement      #
#									                                         #
############################################################################## 

#définition des variables
SCRIPT_DIR=$(dirname "$(realpath "$0")")
source ${SCRIPT_DIR}/.config_update.cfg
if [ -d ${SCRIPT_DIR}/TEMP ]; then
    rm -r ${SCRIPT_DIR}/TEMP
fi
mkdir ${SCRIPT_DIR}/TEMP
if [ ! -d $DOSLOG ]; then
    mkdir $DOSLOG
fi
if [ ! -f $FICHIERRECAP ]; then
    touch $FICHIERRECAP
    echo "titre;RSGain" >> $FICHIERRECAP
fi
if [ ! -d $DIRSAV_FICHIERRECAP ]; then
	mkdir $DIRSAV_FICHIERRECAP
fi
echo 0 > ${SCRIPT_DIR}/TEMP/AAAOK
echo 0 > ${SCRIPT_DIR}/TEMP/AAAPASOK
echo 0 > ${SCRIPT_DIR}/TEMP/AAAPASGENRE
echo 0 > ${SCRIPT_DIR}/TEMP/AAAARTALB
echo 0 > ${SCRIPT_DIR}/TEMP/AAAARTALBPASGENRE
echo 0 > ${SCRIPT_DIR}/TEMP/AAAARTALBPASOK
echo 0 > ${SCRIPT_DIR}/TEMP/AAAARTALBOK
echo 0 > ${SCRIPT_DIR}/TEMP/AAAARTALBRSGAIN
echo 0 > ${SCRIPT_DIR}/TEMP/AAAARTALBLIENS
echo 0 > ${SCRIPT_DIR}/TEMP/AAAARTALBCOPIES
echo 0 > ${SCRIPT_DIR}/TEMP/AAAARTALBAJOUTS
echo -e "Sauvegarde du fichier Recap" | tee -a "${LOG}"
tar -czf ${DIRSAV_FICHIERRECAP}${BACKUP_FICHIERRECAP}.tar.gz ${FICHIERRECAP}
echo -e "Sauvegarde compressée: \e[32m${BACKUP_FICHIERRECAP}.tar.gz\e[0m\n" | tee -a "${LOG}"
echo -e "sauvegarde réalisée" | tee -a "${LOG}"
echo -e "Sauvegarde de la base beets" | tee -a "${LOG}"
tar -czf ${DIRSAV_BEETS}${BACKUP_BEETS}.tar.gz ${BASE_BEETS}
echo -e "Sauvegarde compressée: \e[32m${BACKUP_BEETS}.tar.gz\e[0m\n" | tee -a "${LOG}"
echo -e "sauvegarde réalisée" | tee -a "${LOG}"

echo -e "Modification du fichier de conf" | tee -a "${LOG}"
if [ -f $CONFIG_NORMAL ]; then
    mv "${CONFIG}" "${CONFIG_MANUEL}"
    mv "${CONFIG_NORMAL}" "${CONFIG}"
fi
source $BEETS_ENV

echo "[`date`] - Let's go" | tee -a $LOG

#######################TRAITEMENT BEETS###################################
echo -e "[`date`] - Extractions de la base Beets :" | tee -a $LOG
beet ls -a | tr -s " " | cut -d "-" -f1 | sed '/^ $/d' | sed 's/^[ \t]*//' | sed '$d' | uniq > ${SCRIPT_DIR}/TEMP/BEETSARTISTS
#sed -i '/^ $/d' ${SCRIPT_DIR}/TEMP/BEETSARTISTS
#sed -i '$d' ${SCRIPT_DIR}/TEMP/BEETSARTISTS
beet ls -a | tr -s " " | cut -d "-" -f2 | sed '/^ $/d' | sed 's/^[ \t]*//' | sed '$d' | uniq > ${SCRIPT_DIR}/TEMP/BEETSALBUMS
#sed -i 's/^[ \t]*//' ${SCRIPT_DIR}/TEMP/BEETSALBUMS

#sed -i '$d' ${SCRIPT_DIR}/TEMP/BEETSALBUMS

BEETSNBARTISTS=$(cat ${SCRIPT_DIR}/TEMP/BEETSARTISTS | wc -l)
BEETSNBALBUMS=$(cat ${SCRIPT_DIR}/TEMP/BEETSALBUMS | wc -l)
cat "${ACHECKER}" | cut -d "/" -f 6 | cut -d "(" -f1 | sed 's/ *$//' | uniq | sed '/^ $/d' > ${SCRIPT_DIR}/TEMP/BEETSACHECKERARTISTS
cat "${ACHECKER}" | cut -d "/" -f 7 | cut -d "-" -f3 | sed 's/^ *$//' | sed 's/^[ \t]*//' | uniq | sed '/^ $/d' > ${SCRIPT_DIR}/TEMP/BEETSACHECKERALBUMS
BEETSNBACHECKERARTISTS=$(cat ${SCRIPT_DIR}/TEMP/BEETSACHECKERARTISTS | wc -l)
BEETSNBACHECKERALBUMS=$(cat ${SCRIPT_DIR}/TEMP/BEETSACHECKERALBUMS | wc -l)


echo -e "$BEETSNBARTISTS artistes pour $BEETSNBALBUMS albums" | tee -a $LOG
echo -e "A checker : $BEETSNBACHECKERARTISTS artistes et $BEETSNBACHECKERALBUMS albums" | tee -a $LOG
sleep 5
echo -e "[`date`] - Synchro MusicBrainz :" | tee -a $LOG
#for ((b=1 ;b<=$BEETSNBACHECKERALBUMS ;b++))
#do
#LIGNE=$(cat ${SCRIPT_DIR}/TEMP/BEETSACHECKERALBUMS | head -$b | tail +$b)
#NBCARLIGNE=$(echo "$LIGNE" | wc -m)
#echo "Album : $LIGNE" | tee -a $LOG
#if [[ $NBCARLIGNE -gt "3" ]]; then
#    beet -v mbsync -M "$LIGNE" >> $LOG 2>&1
#else
#    echo "trop peu de caractères, au suivant..." | tee -a $LOG
#fi
#done
#sleep 5
#echo -e "[`date`] - Mise à jour des tags pour les artistes suivants :" | tee -a $LOG
#for ((c=1 ;c<=$BEETSNBACHECKERARTISTS ;c++))
#do
#LIGNE=$(cat ${SCRIPT_DIR}/TEMP/BEETSACHECKERARTISTS | head -$c | tail +$c)
#echo "Artiste : $LIGNE" | tee -a $LOG
#beet update "$LIGNE" >> $LOG 2>&1
#done


sed -i '/^[[:space:]]*$/d' "${ACHECKER}"
#######################TRAITEMENT DU FICHIER ACHECKER###################################
echo -e "[`date`] - Traitement du fichier achecker.txt :" | tee -a $LOG
NBLIGNES=$(cat "${ACHECKER}" | wc -l)
DETAIL=$(cat "${ACHECKER}")
echo "[`date`] - "$NBLIGNES" lignes à traiter" | tee -a $LOG
for ((a=1 ;a<=$NBLIGNES ;a++))
#a=0
#for LIGNE in $DETAIL
do
   #a=$(expr $a + 1 )
    LIGNE=$(cat "${ACHECKER}" | head -1 | tail +1)
    echo "[`date`] - Traitement de la ligne $a : "$LIGNE"" | tee -a $LOG
    echo "Importation auto Beets :" | tee -a $LOG
    beet import -C "$LIGNE" >> $LOG 2>&1
    #echo "     - synchro MusicBrainz :" | tee -a $LOG
    #beet mbsync -M "$LIGNE" >> $LOG 2>&1
    #echo "     - update :" | tee -a $LOG
    #beet update - "$LIGNE" >> $LOG 2>&1



        
    find "$LIGNE"/* \( -iname "*.flac" -o -iname "*.mp3" \) 2>> $LOG
#######################RECHERCHE DES FICHIERS MUSICAUX###################################            
    find "$LIGNE"/* \( -iname "*.flac" -o -iname "*.mp3" \) -print0 | while read -d $'\0' MUSIC
    do
    
        MUSICTEST=$(echo $MUSIC | tr "[:upper:]" "[:lower:]")
        CHAR="/"
        NUMCHAR=$(awk -F"${CHAR}" '{print NF-1}' <<< "${MUSIC}")
        FILE=$(echo "$MUSIC" | rev | cut -d'/' -f 1 | rev)
        FILEMP3="${FILE/flac/mp3}"
        ARTALBOLD=$ARTALB
        BASECONTROL=$(echo "$MUSIC" | cut -d'/' -f 1-5)
        echo "Traitement du fichier "$MUSICTEST"" | tee -a $LOG                     
        if [ $NUMCHAR -gt "7" ]; then
            SUPPORT=$(echo "$MUSIC" | rev | cut -d'/' -f 2 | rev)
            ALBUM=$(echo "$MUSIC" | rev | cut -d'/' -f 3 | rev)
            ALBUM2=$(echo "$ALBUM" | rev | cut -d'-' -f 1 | rev)
            ARTISTE=$(echo "$MUSIC" | rev | cut -d'/' -f 4 | rev)
            ARTALB=$(echo "$ARTISTE"/"$ALBUM"/"$SUPPORT")
        else
            ALBUM=$(echo "$MUSIC" | rev | cut -d'/' -f 2 | rev)
            ALBUM2=$(echo "$ALBUM" | rev | cut -d'-' -f 1 | rev)
            ARTISTE=$(echo "$MUSIC" | rev | cut -d'/' -f 3 | rev)
            ARTALB=$(echo "$ARTISTE"/"$ALBUM")
        fi
        if [[ "$ARTALBOLD" != "$ARTALB" ]]; then
            echo 0 > ${SCRIPT_DIR}/TEMP/AAAARTALB
            AAAARTALB=$(cat ${SCRIPT_DIR}/TEMP/AAAARTALB)
            AAAARTALB=$(expr $AAAARTALB + 1 )
        else
            AAAARTALB=$(expr $AAAARTALB + 1 )
        fi
        
        if [ $NUMCHAR -gt "5" ]; then
            if [[ "$MUSICTEST" == *.flac ]]; then
                GENREBRUT=$(metaflac --show-tag=genre "$MUSIC" 2> >(tee -a $LOG))
                REPLAYGAIN=$(metaflac --show-tag=replaygain_track_gain "$MUSIC")
            elif [[ "$MUSICTEST" == *.mp3 ]]; then
                GENREBRUT=$(mp3info -p%g "$MUSIC" 2> >(tee -a $LOG))
                REPLAYGAIN=$(ffprobe -v error -of csv=s=x:p=0 -show_entries format_tags=replaygain_track_gain "$MUSIC")
            fi
            GENRE=$(echo "$GENREBRUT" | tr '[:upper:]' '[:lower:]')
            if [ -z "$GENRE" ]; then
                AAAPASGENRE=$(cat ${SCRIPT_DIR}/TEMP/AAAPASGENRE)
                AAAPASGENRE=$(expr $AAAPASGENRE + 1 )
                echo $AAAPASGENRE > ${SCRIPT_DIR}/TEMP/AAAPASGENRE
                echo "$MUSIC" >> "$LOGPASGENRE"
                AAAARTALBPASGENRE=$(cat ${SCRIPT_DIR}/TEMP/AAAARTALBPASGENRE)
                AAAARTALBPASGENRE=$(expr $AAAARTALBPASGENRE + 1 )
                echo $AAAARTALBPASGENRE > ${SCRIPT_DIR}/TEMP/AAAARTALBPASGENRE
                echo "Aucun genre spécifié" | tee -a $LOG
                if [ $AAAARTALBPASGENRE -eq 1  ]; then
                    echo "$ARTALB" >> "$LOGPASGENREALBUM"
                fi
            elif [[ "$GENRE" == *"techno"* || "$GENRE" == *"house"* || "$GENRE" == *"trance"* || "$GENRE" == *"house"* || "$GENRE" == *"edm"* || "$GENRE" == *"dance"* || "$GENRE" == *"psychedelic"* || "$GENRE" == *"rave"* || "$GENRE" == *"space"* ]]; then
                AAAOK=$(cat ${SCRIPT_DIR}/TEMP/AAAOK)
                AAAOK=$(expr $AAAOK + 1 )
                echo $AAAOK > ${SCRIPT_DIR}/TEMP/AAAOK
                AAAARTALBOK=$(cat ${SCRIPT_DIR}/TEMP/AAAARTALBOK)
                AAAARTALBOK=$(expr $AAAARTALBOK + 1 )
                echo $AAAARTALBOK > ${SCRIPT_DIR}/TEMP/AAAARTALBOK
                echo "Genre correspondant" | tee -a $LOG
                echo "test replaygain $REPLAYGAIN"
                if [ -z "$REPLAYGAIN" ]; then
                    echo "Aucun ReplayGain, calcul de celui ci..." | tee -a $LOG
                    rsgain custom -Ss i "$MUSIC" 2>&1 | tee -a $LOG
                    AAAARTALBAJOUTS=$(cat ${SCRIPT_DIR}/TEMP/AAAARTALBAJOUTS)
                    AAAARTALBAJOUTS=$(expr $AAAARTALBAJOUTS + 1 )
                    echo $AAAARTALBAJOUTS > ${SCRIPT_DIR}/TEMP/AAAARTALBAJOUTS
                fi
                if [[ "$MUSICTEST" == *.flac ]]; then
                    REPLAYGAIN=$(metaflac --show-tag=replaygain_track_gain "$MUSIC")
                elif [[ "$MUSICTEST" == *.mp3 ]]; then
                    REPLAYGAIN=$(ffprobe -v error -of csv=s=x:p=0 -show_entries format_tags=replaygain_track_gain "$MUSIC")
                fi
                if [ -n "$REPLAYGAIN" ]; then
                    AAAARTALBRSGAIN=$(cat ${SCRIPT_DIR}/TEMP/AAAARTALBRSGAIN)
                    AAAARTALBRSGAIN=$(expr $AAAARTALBRSGAIN + 1 )
                    echo $AAAARTALBRSGAIN > ${SCRIPT_DIR}/TEMP/AAAARTALBRSGAIN
                    echo "Replaygain calculé : $REPLAYGAIN" | tee -a $LOG
                    SCENEIN=$(grep -e "^${FILE}" "${FICHIERRECAP}")
                    if [[ ! -n $SCENEIN ]]; then
                        REPLAYGAINFILE=$(echo "$REPLAYGAIN" | cut -d "=" -f2)
                        echo "${FILE};$REPLAYGAINFILE" >> ${FICHIERRECAP}
                        echo "Replaygain ajouté au fichier Recap" | tee -a $LOG
                    fi
                fi

                if [ ! -d "${BASE2}/${ARTALB}" ]; then
                    mkdir -p "${BASE2}/${ARTALB}"
                    echo "Liens et répertoires absents, création de ceux ci..." | tee -a $LOG
                fi
                if [ ! -d "${BASE3}/${ARTALB}" ]; then
                    
                    mkdir -p "${BASE3}/${ARTALB}"
                fi
                if [ ! -h "${BASE2}/${ARTALB}/${FILE}" ]; then
                    ln -s "${BASESERVEUR}/${ARTALB}/${FILE}" "${BASE2}/${ARTALB}/${FILE}" 2> >(tee -a $LOG)
                    AAAARTALBAJOUTS=$(cat ${SCRIPT_DIR}/TEMP/AAAARTALBAJOUTS)
                    AAAARTALBAJOUTS=$(expr $AAAARTALBAJOUTS + 1 )
                    echo $AAAARTALBAJOUTS > ${SCRIPT_DIR}/TEMP/AAAARTALBAJOUTS
                    
                fi
                if [ -f "${BASE2}/${ARTALB}/${FILE}" ]; then
                    AAAARTALBLIENS=$(cat ${SCRIPT_DIR}/TEMP/AAAARTALBLIENS)
                    AAAARTALBLIENS=$(expr $AAAARTALBLIENS + 1 )
                    echo $AAAARTALBLIENS > ${SCRIPT_DIR}/TEMP/AAAARTALBLIENS
                    echo "Création du lien ok" | tee -a $LOG
                fi
                if [[ ! -f "${BASE3}/${ARTALB}/${FILE}" && ! -f "${BASE3}/${ARTALB}/${FILEMP3}" ]]; then
                    cp "${BASESERVEUR}/${ARTALB}/${FILE}" "${BASE3}/${ARTALB}/${FILE}" 2> >(tee -a $LOG)
                    AAAARTALBAJOUTS=$(cat ${SCRIPT_DIR}/TEMP/AAAARTALBAJOUTS)
                    AAAARTALBAJOUTS=$(expr $AAAARTALBAJOUTS + 1 )
                    echo $AAAARTALBAJOUTS > ${SCRIPT_DIR}/TEMP/AAAARTALBAJOUTS
                fi
                if [[ -f "${BASE3}/${ARTALB}/${FILE}" || -f "${BASE3}/${ARTALB}/${FILEMP3}" ]]; then
                    AAAARTALBCOPIES=$(cat ${SCRIPT_DIR}/TEMP/AAAARTALBCOPIES)
                    AAAARTALBCOPIES=$(expr $AAAARTALBCOPIES + 1 )
                    echo $AAAARTALBCOPIES > ${SCRIPT_DIR}/TEMP/AAAARTALBCOPIES
                    echo "Création du fichier ok" | tee -a $LOG
                fi
            else
                AAAPASOK=$(cat ${SCRIPT_DIR}/TEMP/AAAPASOK)
                AAAPASOK=$(expr $AAAPASOK + 1 )
                #echo $AAAPASOK > ${SCRIPT_DIR}/TEMP/AAAPASOK
                AAAARTALBPASOK=$(cat ${SCRIPT_DIR}/TEMP/AAAARTALBPASOK)
                AAAARTALBPASOK=$(expr $AAAARTALBPASOK + 1 )
                #echo $AAAARTALBPASOK > ${SCRIPT_DIR}/TEMP/AAAARTALBPASOK
                echo "Genre non sélectionné" | tee -a $LOG
                if [[ ! -f "$LOGNONOK" ]]; then
                    touch "$LOGNONOK"
                fi
                if [ $(grep -c "*$ARTIST*$ALBUM2*" "$LOGNONOK") -lt "1" ]; then
                    echo "$ARTALB" >> "$LOGNONOK"
                    
                fi
            fi

            NBARTALB=$(find "$BASECONTROL/$ARTALB"/* \( -iname "*.flac" -o -iname "*.mp3" \) | wc -l)
            AAAARTALBPASOK=$(cat ${SCRIPT_DIR}/TEMP/AAAARTALBPASOK)
            AAAARTALBOK=$(cat ${SCRIPT_DIR}/TEMP/AAAARTALBOK)
            AAAARTALBPASGENRE=$(cat ${SCRIPT_DIR}/TEMP/AAAARTALBPASGENRE)

            if [[ "$NBARTALB" == "$AAAARTALB" ]]; then
                if [[ "$AAAARTALBOK" == "$NBARTALB" ]]; then
                    AAAARTALBCOPIES=$(cat ${SCRIPT_DIR}/TEMP/AAAARTALBCOPIES)
                    AAAARTALBLIENS=$(cat ${SCRIPT_DIR}/TEMP/AAAARTALBLIENS)
                    AAAARTALBRSGAIN=$(cat ${SCRIPT_DIR}/TEMP/AAAARTALBRSGAIN)
                    if [[ "$AAAARTALBCOPIES" == "$AAAARTALBOK" && "$AAAARTALBLIENS" == "$AAAARTALBOK" && "$AAAARTALBRSGAIN" == "$AAAARTALBOK" ]]; then
                        echo "[`date`] - "$ARTALB" : tout est OK" | tee -a $LOG
                    else
                        echo "[`date`] - "$ARTALB" : "$NBARTALB" titres, "$AAAARTALBLIENS" liens, "$AAAARTALBCOPIES" copies et $AAAARTALBRSGAIN Rsgain" | tee -a $LOG
                    fi
                elif [[ "$AAAARTALBOK" -ge "1" ]]; then
                    echo "[`date`] - "$ARTALB" : "$NBARTALB" titres, "$AAAARTALBOK" OK, "$AAAARTALBPASOK" non sélectionnés et "$AAAARTALBPASGENRE" sans genre" | tee -a $LOG
                    echo "pour "$AAAARTALBOK" titres OK, "$AAAARTALBLIENS" liens, "$AAAARTALBCOPIES" copies et $AAAARTALBRSGAIN Rsgain" | tee -a $LOG
                    if [[ "$AAAARTALBCOPIES" != "$AAAARTALBOK" || "$AAAARTALBLIENS" != "$AAAARTALBOK" || "$AAAARTALBRSGAIN" != "$AAAARTALBOK" ]]; then
                        echo "$ARTALB" >> "$LOGACHECKER"
                        echo "pour "$AAAARTALBOK" titres OK, "$AAAARTALBLIENS" liens, "$AAAARTALBCOPIES" copies et $AAAARTALBRSGAIN Rsgain" | tee -a $LOGACHECKER
                    fi               
                elif [[ "$AAAARTALBPASGENRE" == "$NBARTALB" ]]; then
                    echo "[`date`] - "$ARTALB" : Aucun Genre défini" | tee -a $LOG
                elif [[ "$AAAARTALBPASOK" == "$NBARTALB" ]]; then
                    echo "[`date`] - "$ARTALB" : non sélectionné" | tee -a $LOG
                fi
                AAAARTALBAJOUTS=$(cat ${SCRIPT_DIR}/TEMP/AAAARTALBAJOUTS)
                if [[ "$AAARTALBAJOUTS" -ge "1" ]]; then
                    echo "[`date`] - "$ARTALB" : $AAARTALBAJOUTS ajouts" | tee -a $LOGAJOUTS
                fi
                echo 0 > ${SCRIPT_DIR}/TEMP/AAAARTALBAJOUTS
                echo 0 > ${SCRIPT_DIR}/TEMP/AAAARTALB
                echo 0 > ${SCRIPT_DIR}/TEMP/AAAARTALBPASGENRE
                echo 0 > ${SCRIPT_DIR}/TEMP/AAAARTALBPASOK
                echo 0 > ${SCRIPT_DIR}/TEMP/AAAARTALBOK
                echo 0 > ${SCRIPT_DIR}/TEMP/AAAARTALBRSGAIN
                echo 0 > ${SCRIPT_DIR}/TEMP/AAAARTALBLIENS
                echo 0 > ${SCRIPT_DIR}/TEMP/AAAARTALBCOPIES
            fi
        fi   
    done
    echo "${LIGNE}"
    sed -i '1d' "${ACHECKER}"
done
echo $AAA
echo "[`date`] - OK terminé, voici le résultat :" | tee -a $LOG
AAAOK=$(cat ${SCRIPT_DIR}/TEMP/AAAOK)
AAAPASOK=$(cat ${SCRIPT_DIR}/TEMP/AAAPASOK)
AAAPASGENRE=$(cat ${SCRIPT_DIR}/TEMP/AAAPASGENRE)
TOTAL=$(expr $AAAPASOK + $AAAOK + $AAAPASGENRE )
PCOK=$((AAAOK *100 / TOTAL))
PCPG=$((AAAPASGENRE *100 / TOTAL))
echo "[`date`] - Pour $TOTAL fichiers" | tee -a $LOG
echo "[`date`] - $AAAOK fichiers sélectionnés ($PCOK %)" | tee -a $LOG
echo "[`date`] - $AAAPASGENRE fichiers avec aucun genre spécifié ($PCPG %)" | tee -a $LOG
echo "" | tee -a $LOG

shuf -n 50 ${SCRIPT_DIR}/TEMP/BEETSARTISTS >> ${SCRIPT_DIR}/TEMP/BEETSACHECKERARTISTS
shuf -n 100 ${SCRIPT_DIR}/TEMP/BEETSALBUMS >> ${SCRIPT_DIR}/TEMP/BEETSACHECKERALBUMS
BEETSNBACHECKERARTISTS=$(cat ${SCRIPT_DIR}/TEMP/BEETSACHECKERARTISTS | wc -l)
BEETSNBACHECKERALBUMS=$(cat ${SCRIPT_DIR}/TEMP/BEETSACHECKERALBUMS | wc -l)


echo -e "[`date`] - Synchro MusicBrainz pour 100 albums aléatoires :" | tee -a $LOG
for ((b=1 ;b<=$BEETSNBACHECKERALBUMS ;b++))
do
LIGNE=$(cat ${SCRIPT_DIR}/TEMP/BEETSACHECKERALBUMS | head -$b | tail +$b)
NBCARLIGNE=$(echo "$LIGNE" | wc -m)
echo "Album : $LIGNE" | tee -a $LOG
if [[ $NBCARLIGNE -gt "3" ]]; then
    beet -v mbsync -M "$LIGNE" #>> $LOG 2>&1
else
    echo "trop peu de caractères, au suivant..." | tee -a $LOG
fi
done
echo -e "[`date`] - Mise à jour des tags pour les artistes suivants :" | tee -a $LOG
for ((c=1 ;c<=$BEETSNBACHECKERARTISTS ;c++))
do
LIGNE=$(cat ${SCRIPT_DIR}/TEMP/BEETSACHECKERARTISTS | head -$c | tail +$c)
echo "Artiste : $LIGNE"
beet update "$LIGNE" #>> $LOG 2>&1
done
echo -e "[`date`] - Extraction Beets des albums à importer manuellement :" | tee -a $LOG
grep "^skip" /home/pipo/bin/logs/beets/beet.log | cut -c6- >> /home/pipo/bin/recap_music/beets_manuel.txt
echo "" > /home/pipo/bin/logs/beets/beet.log
echo -e "Fichier disponible dans le dossier recap_music :" | tee -a $LOG
echo "[`date`] - Voilà c'est fini, bisous" | tee -a $LOG
#echo "" > $ACHECKER
rm -r ${SCRIPT_DIR}/TEMP