#!/bin/bash
############################################################################## 
#                                                                            #
#	SHELL: !/bin/bash       version 2.5                                      #
#									                                         #
#	NOM: BEUGNET							                                 #
#									                                         #
#	PRENOM: Thierry							                                 #
#									                                         #
#	DATE: 22/08/2024	           				                             #
#								                                    	     #
#	BUT: Sélectionne les fichiers flac techno/house	                         #
#									                                         #
############################################################################## 

#définition des variables
source .config.cfg


echo 0 > AAAOK
echo 0 > AAAPASOK
echo 0 > AAAPASGENRE
touch $LOG
touch $LOGNONOK
touch $LOGPASGENRE
touch $LOGPASGENREALBUM
echo "[`date`] - Let's go" | tee -a $LOG

echo "Liste des fichiers sans aucun genre spécifié : " >> $LOGPASGENRE
echo "Liste des albums sans aucun genre spécifié : " >> $LOGPASGENREALBUM
find "$BASE"/* \( -iname "*.flac" -o -iname "*.mp3" \) -print0 | while read -d $'\0' MUSIC
    do
        MUSICTEST=$(echo $MUSIC | tr "[:upper:]" "[:lower:]")
        if [[ "$MUSICTEST" == *.flac ]]
            then
                GENREBRUT=$(metaflac --show-tag=genre "$MUSIC" 2> >(tee -a $LOG))
        elif [[ "$MUSICTEST" == *.mp3 ]]
            then
                GENREBRUT=$(mp3info -p%g "$MUSIC" 2> >(tee -a $LOG))
        fi
        GENRE=$(echo "$GENREBRUT" | tr '[:upper:]' '[:lower:]')
        CHAR="/"
        NUMCHAR=$(awk -F"${CHAR}" '{print NF-1}' <<< "${MUSIC}")
        FILE=$(echo "$MUSIC" | rev | cut -d'/' -f 1 | rev)
        NAME=$(echo "$FILE" | cut -d'.' -f 1)
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
        if [ -z "$GENRE" ] #Si genre introuvable
            then
            AAAPASGENRE=$(cat AAAPASGENRE)
            AAAPASGENRE=$(expr $AAAPASGENRE + 1 )
            echo $AAAPASGENRE > AAAPASGENRE
            echo $MUSIC >> $LOGPASGENRE
            if [ $(grep -c "*$ARTIST*$ALBUM2*" "$LOGPASGENREALBUM") -lt 1  ]
                then
                echo "$ARTALB" >> "$LOGPASGENREALBUM"
                echo "[`date`] - "$ARTALB" : Aucun Genre défini" | tee -a $LOG
            fi
        elif [[ "$GENRE" == *"techno"* || "$GENRE" == *"house"* || "$GENRE" == *"trance"* || "$GENRE" == *"house"* || "$GENRE" == *"electronic"* || "$GENRE" == *"edm"* || "$GENRE" == *"dance"* || "$GENRE" == *"psychedelic"* || "$GENRE" == *"rave"* || "$GENRE" == *"space"* ]]
            then
            AAAOK=$(cat AAAOK)
            AAAOK=$(expr $AAAOK + 1 )
            echo $AAAOK > AAAOK
            rsgain custom -Ss i "$MUSIC" 2>&1 | tee -a $LOG
            if [ ! -d "${BASE2}/${ARTALB}" ]
                then
                mkdir -p "${BASE2}/${ARTALB}"
                ln -s "${BASESERVEUR}/${ARTISTE}/${ALBUM}/${FILE}" "${BASE2}/${ARTALB}/${FILE}" 2> >(tee -a $LOG)
                echo "[`date`] - "$ARTALB" : OK" | tee -a $LOG
                mkdir -p "${BASE3}/${ARTALB}"
                if [[ "$MUSICTEST" == *.flac ]]
                    then
		            cp "${BASESERVEUR}/${ARTISTE}/${ALBUM}/${FILE}" "${BASE3}/${ARTALB}/${FILE}"
                    ##lame -b 320 "${BASESERVEUR}/${ARTISTE}/${ALBUM}/${FILE}" "${BASE3}/${ARTALB}/${NAME}.mp3" 2> >(tee -a $LOG)
                    ##echo "[`date`] - Album converti en mp3" | tee -a $LOG
                else
                    cp "${BASESERVEUR}/${ARTISTE}/${ALBUM}/${FILE}" "${BASE3}/${ARTALB}/${FILE}"
                fi
            else
                if [ ! -f "${BASE2}/${ARTALB}/${FILE}" ]
                    then
                    ln -s "${BASESERVEUR}/${ARTISTE}/${ALBUM}/${FILE}" "${BASE2}/${ARTALB}/${FILE}" 2> >(tee -a $LOG)
                    if [[ "$MUSICTEST" == *.flac ]]
                        then
		                cp "${BASESERVEUR}/${ARTISTE}/${ALBUM}/${FILE}" "${BASE3}/${ARTALB}/${FILE}"
                        ##lame -b 320 "${BASESERVEUR}/${ARTISTE}/${ALBUM}/${FILE}" "${BASE3}/${ARTALB}/${NAME}.mp3" 2> >(tee -a $LOG)
                    else
                        cp "${BASESERVEUR}/${ARTISTE}/${ALBUM}/${FILE}" "${BASE3}/${ARTALB}/${FILE}"
                    fi
                fi
            fi
        else
            AAAPASOK=$(cat AAAPASOK)
            AAAPASOK=$(expr $AAAPASOK + 1 )
            echo $AAAPASOK > AAAPASOK
            if [ $(grep -c "*$ARTIST*$ALBUM2*" "$LOGNONOK") -lt 1 ]
                then
                echo "$ARTALB" >> "$LOGNONOK"
                echo "[`date`] - "$ARTALB" : non sélectionné" | tee -a $LOG
            fi
        fi
    done
echo
echo "[`date`] - OK terminé, voici le résultat :" | tee -a $LOG
AAAOK=$(cat AAAOK)
AAAPASOK=$(cat AAAPASOK)
AAAPASGENRE=$(cat AAAPASGENRE)
TOTAL=$(expr $AAAPASOK + $AAAOK + $AAAPASGENRE )
PCOK=$((AAAOK *100 / TOTAL))
PCPG=$((AAAPASGENRE *100 / TOTAL))
echo "[`date`] - Pour $TOTAL fichiers" | tee -a $LOG
echo "[`date`] - $AAAOK fichiers sélectionnés ($PCOK %)" | tee -a $LOG
echo "[`date`] - $AAAPASGENRE fichiers avec aucun genre spécifié ($PCPG %)" | tee -a $LOG
echo "" | tee -a $LOG
echo "[`date`] - Voilà c'est fini, bisous" | tee -a $LOG
rm AAA*
