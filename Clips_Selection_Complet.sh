#!/bin/bash
############################################################################## 
#                                                                            #
#	SHELL: !/bin/bash       version 4                                        #
#									                                         #
#	NOM: u2pitchjami						                                 #
#									                                         #
#	            							                                 #
#									                                         #
#	DATE: 01/09/2024	           				                             #
#								                                    	     #
#	BUT: Sélectionne les fichiers flac techno/house	: scan complet           #
#									                                         #
############################################################################## 

#définition des variables
SCRIPT_DIR=$(dirname "$(realpath "$0")")
source ${SCRIPT_DIR}/.config.cfg
if [ -d ${SCRIPT_DIR}/TEMP ]
then
rm -r ${SCRIPT_DIR}/TEMP
fi
mkdir ${SCRIPT_DIR}/TEMP
if [ ! -d $DOSLOG ]
then
mkdir $DOSLOG
fi
if [ ! -f $FICHIERRECAP ]
then
touch $FICHIERRECAP
echo "titre;RSGain" >> $FICHIERRECAP
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
touch $LOG
touch $LOGNONOK
touch $LOGPASGENRE
touch $LOGPASGENREALBUM
touch $LOGACHECKER
touch $LOGAJOUTS
echo "[`date`] - Let's go" | tee -a $LOG

echo "Liste des fichiers sans aucun genre spécifié : " >> $LOGPASGENRE
echo "Liste des albums sans aucun genre spécifié : " >> $LOGPASGENREALBUM
find $BASE/* \( -iname "*.flac" -o -iname "*.mp3" \) -print0 | while read -d $'\0' MUSIC
    do
        MUSICTEST=$(echo $MUSIC | tr "[:upper:]" "[:lower:]")
        if [[ "$MUSICTEST" == *.flac ]]
            then
                GENREBRUT=$(metaflac --show-tag=genre "$MUSIC" 2> >(tee -a $LOG))
                REPLAYGAIN=$(metaflac --show-tag=replaygain_track_gain "$MUSIC")
        elif [[ "$MUSICTEST" == *.mp3 ]]
            then
                GENREBRUT=$(mp3info -p%g "$MUSIC" 2> >(tee -a $LOG))
                REPLAYGAIN=$(ffprobe -v error -of csv=s=x:p=0 -show_entries format_tags=replaygain_track_gain "$MUSIC")
        fi
        GENRE=$(echo "$GENREBRUT" | tr '[:upper:]' '[:lower:]')
        CHAR="/"
        NUMCHAR=$(awk -F"${CHAR}" '{print NF-1}' <<< "${MUSIC}")
        FILE=$(echo "$MUSIC" | rev | cut -d'/' -f 1 | rev)
        FILEMP3="${FILE/flac/mp3}"
        ARTALBOLD=$ARTALB
        BASECONTROL=$(echo "$MUSIC" | cut -d'/' -f 1-5)
        if [ $NUMCHAR -gt "7" ]
            then
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
        if [[ "$ARTALBOLD" != "$ARTALB" ]]
            then
            echo 0 > ${SCRIPT_DIR}/TEMP/AAAARTALB
            AAAARTALB=$(cat ${SCRIPT_DIR}/TEMP/AAAARTALB)
            #echo "AAAARTALB00 : $AAAARTALB"
            AAAARTALB=$(expr $AAAARTALB + 1 )
            #echo "AAAARTALB : $AAAARTALB"
        else
            AAAARTALB=$(expr $AAAARTALB + 1 )
            #echo "AAAARTALB2 : $AAAARTALB"
        fi






        if [ -z "$GENRE" ] #Si genre introuvable
            then
            AAAPASGENRE=$(cat ${SCRIPT_DIR}/TEMP/AAAPASGENRE)
            AAAPASGENRE=$(expr $AAAPASGENRE + 1 )
            echo $AAAPASGENRE > ${SCRIPT_DIR}/TEMP/AAAPASGENRE
            #echo AAAPASGENRE : $AAAPASGENRE
            echo $MUSIC >> $LOGPASGENRE
            AAAARTALBPASGENRE=$(cat ${SCRIPT_DIR}/TEMP/AAAARTALBPASGENRE)
            AAAARTALBPASGENRE=$(expr $AAAARTALBPASGENRE + 1 )
            echo $AAAARTALBPASGENRE > ${SCRIPT_DIR}/TEMP/AAAARTALBPASGENRE
            #echo "AAAARTALBPASGENRE : $AAAARTALBPASGENRE"

            if [ $AAAARTALBPASGENRE -eq 1  ]
                then
                echo "$ARTALB" >> "$LOGPASGENREALBUM"
                
            fi
        elif [[ "$GENRE" == *"techno"* || "$GENRE" == *"house"* || "$GENRE" == *"trance"* || "$GENRE" == *"edm"* || "$GENRE" == *"dance"* || "$GENRE" == *"psychedelic"* || "$GENRE" == *"rave"* || "$GENRE" == *"space"* ]]
            then
            AAAOK=$(cat ${SCRIPT_DIR}/TEMP/AAAOK)
            AAAOK=$(expr $AAAOK + 1 )
            echo $AAAOK > ${SCRIPT_DIR}/TEMP/AAAOK
            AAAARTALBOK=$(cat ${SCRIPT_DIR}/TEMP/AAAARTALBOK)
            AAAARTALBOK=$(expr $AAAARTALBOK + 1 )
            echo $AAAARTALBOK > ${SCRIPT_DIR}/TEMP/AAAARTALBOK
            #echo "AAAARTALBOK : $AAAARTALBOK"
            if [ -z "$REPLAYGAIN" ]
                then
                rsgain custom -Ss i "$MUSIC" 2>&1 | tee -a $LOG
                AAAARTALBAJOUTS=$(cat ${SCRIPT_DIR}/TEMP/AAAARTALBAJOUTS)
                AAAARTALBAJOUTS=$(expr $AAAARTALBAJOUTS + 1 )
                echo $AAAARTALBAJOUTS > ${SCRIPT_DIR}/TEMP/AAAARTALBAJOUTS
            fi
            if [[ "$MUSICTEST" == *.flac ]]
                then
                REPLAYGAIN=$(metaflac --show-tag=replaygain_track_gain "$MUSIC")
            elif [[ "$MUSICTEST" == *.mp3 ]]
                then
                REPLAYGAIN=$(ffprobe -v error -of csv=s=x:p=0 -show_entries format_tags=replaygain_track_gain "$MUSIC")
            fi
            if [ -n "$REPLAYGAIN" ]
                then
                AAAARTALBRSGAIN=$(cat ${SCRIPT_DIR}/TEMP/AAAARTALBRSGAIN)
                AAAARTALBRSGAIN=$(expr $AAAARTALBRSGAIN + 1 )
                echo $AAAARTALBRSGAIN > ${SCRIPT_DIR}/TEMP/AAAARTALBRSGAIN
                #echo "AAAARTALBRSGAIN : $AAAARTALBRSGAIN"
                SCENEIN=$(grep -e "^${FILE}" "${FICHIERRECAP}")
                                    if [[ ! -n $SCENEIN ]]
                                        then
                                        REPLAYGAINFILE=$(echo "$REPLAYGAIN" | cut -d "=" -f2)
                                        echo "${FILE};$REPLAYGAINFILE" >> ${FICHIERRECAP}
                                        echo "Replaygain ajouté au fichier Recap" | tee -a $LOG
                                    fi
            fi
        
            if [ ! -d "${BASE2}/${ARTALB}" ]
                then
                mkdir -p "${BASE2}/${ARTALB}"
                
            fi
            if [ ! -d "${BASE3}/${ARTALB}" ]
                then
                
                mkdir -p "${BASE3}/${ARTALB}"
            fi
            if [ ! -h "${BASE2}/${ARTALB}/${FILE}" ]
                then
                ln -s "${BASESERVEUR}/${ARTALB}/${FILE}" "${BASE2}/${ARTALB}/${FILE}" 2> >(tee -a $LOG)
                AAAARTALBAJOUTS=$(cat ${SCRIPT_DIR}/TEMP/AAAARTALBAJOUTS)
                AAAARTALBAJOUTS=$(expr $AAAARTALBAJOUTS + 1 )
                echo $AAAARTALBAJOUTS > ${SCRIPT_DIR}/TEMP/AAAARTALBAJOUTS
            fi
            if [[ -f "${BASE2}/${ARTALB}/${FILE}" ]]
                then
                AAAARTALBLIENS=$(cat ${SCRIPT_DIR}/TEMP/AAAARTALBLIENS)
                AAAARTALBLIENS=$(expr $AAAARTALBLIENS + 1 )
                echo $AAAARTALBLIENS > ${SCRIPT_DIR}/TEMP/AAAARTALBLIENS
                #echo "AAAARTALBLIENS : $AAAARTALBLIENS"
            fi
            if [[ ! -f "${BASE3}/${ARTALB}/${FILE}" && ! -f "${BASE3}/${ARTALB}/${FILEMP3}" ]]
                then
                cp "${BASESERVEUR}/${ARTALB}/${FILE}" "${BASE3}/${ARTALB}/${FILE}" 2> >(tee -a $LOG)
                AAAARTALBAJOUTS=$(cat ${SCRIPT_DIR}/TEMP/AAAARTALBAJOUTS)
                AAAARTALBAJOUTS=$(expr $AAAARTALBAJOUTS + 1 )
                echo $AAAARTALBAJOUTS > ${SCRIPT_DIR}/TEMP/AAAARTALBAJOUTS
            fi
            if [[ -f "${BASE3}/${ARTALB}/${FILE}" || -f "${BASE3}/${ARTALB}/${FILEMP3}" ]]
                then
                AAAARTALBCOPIES=$(cat ${SCRIPT_DIR}/TEMP/AAAARTALBCOPIES)
                AAAARTALBCOPIES=$(expr $AAAARTALBCOPIES + 1 )
                echo $AAAARTALBCOPIES > ${SCRIPT_DIR}/TEMP/AAAARTALBCOPIES
                #echo "AAAARTALBCOPIES : $AAAARTALBCOPIES"
            fi
                
            
        else
            AAAPASOK=$(cat ${SCRIPT_DIR}/TEMP/AAAPASOK)
            AAAPASOK=$(expr $AAAPASOK + 1 )
            #echo $AAAPASOK > ${SCRIPT_DIR}/TEMP/AAAPASOK
            AAAARTALBPASOK=$(cat ${SCRIPT_DIR}/TEMP/AAAARTALBPASOK)
            AAAARTALBPASOK=$(expr $AAAARTALBPASOK + 1 )
            #echo $AAAARTALBPASOK > ${SCRIPT_DIR}/TEMP/AAAARTALBPASOK
            if [ $(grep -c "*$ARTIST*$ALBUM2*" "$LOGNONOK") -lt 1 ]
                then
                echo "$ARTALB" >> "$LOGNONOK"
                
            fi
        fi
        NBARTALB=$(find "$BASECONTROL/$ARTALB"/* \( -iname "*.flac" -o -iname "*.mp3" \) | wc -l)
        AAAARTALBPASOK=$(cat ${SCRIPT_DIR}/TEMP/AAAARTALBPASOK)
        AAAARTALBOK=$(cat ${SCRIPT_DIR}/TEMP/AAAARTALBOK)
        AAAARTALBPASGENRE=$(cat ${SCRIPT_DIR}/TEMP/AAAARTALBPASGENRE)
        
        if [[ "$NBARTALB" == "$AAAARTALB" ]]
            then
            if [[ "$AAAARTALBOK" == "$NBARTALB" ]]
                then
                AAAARTALBCOPIES=$(cat ${SCRIPT_DIR}/TEMP/AAAARTALBCOPIES)
                AAAARTALBLIENS=$(cat ${SCRIPT_DIR}/TEMP/AAAARTALBLIENS)
                AAAARTALBRSGAIN=$(cat ${SCRIPT_DIR}/TEMP/AAAARTALBRSGAIN)
                if [[ "$AAAARTALBCOPIES" == "$AAAARTALBOK" && "$AAAARTALBLIENS" == "$AAAARTALBOK" && "$AAAARTALBRSGAIN" == "$AAAARTALBOK" ]]
                    then
                    echo "[`date`] - "$ARTALB" : tout est OK" | tee -a $LOG
                else
                    echo "[`date`] - "$ARTALB" : "$NBARTALB" titres, "$AAAARTALBLIENS" liens, "$AAAARTALBCOPIES" copies et $AAAARTALBRSGAIN Rsgain" | tee -a $LOG
                fi
            elif [[ "$AAAARTALBOK" -ge "1" ]]
                then
                echo "[`date`] - "$ARTALB" : "$NBARTALB" titres, "$AAAARTALBOK" OK, "$AAAARTALBPASOK" non sélectionnés et "$AAAARTALBPASGENRE" sans genre" | tee -a $LOG
                echo "pour "$AAAARTALBOK" titres OK, "$AAAARTALBLIENS" liens, "$AAAARTALBCOPIES" copies et $AAAARTALBRSGAIN Rsgain" | tee -a $LOG
                if [[ "$AAAARTALBCOPIES" != "$AAAARTALBOK" || "$AAAARTALBLIENS" != "$AAAARTALBOK" || "$AAAARTALBRSGAIN" != "$AAAARTALBOK" ]]
                    then
                    echo "$ARTALB" >> "$LOGACHECKER"
                    echo "pour "$AAAARTALBOK" titres OK, "$AAAARTALBLIENS" liens, "$AAAARTALBCOPIES" copies et $AAAARTALBRSGAIN Rsgain" | tee -a $LOGACHECKER
                fi               
            elif [[ "$AAAARTALBPASGENRE" == "$NBARTALB" ]]
                then
                echo "[`date`] - "$ARTALB" : Aucun Genre défini" | tee -a $LOG
            elif [[ "$AAAARTALBPASOK" == "$NBARTALB" ]]
                then
                echo "[`date`] - "$ARTALB" : non sélectionné" | tee -a $LOG
            fi
            AAAARTALBAJOUTS=$(cat ${SCRIPT_DIR}/TEMP/AAAARTALBAJOUTS)
            if [[ "$AAARTALBAJOUTS" -ge "1" ]]
            then
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
    done






echo
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
echo "[`date`] - Voilà c'est fini, bisous" | tee -a $LOG
rm -r ${SCRIPT_DIR}/TEMP