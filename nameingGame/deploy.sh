BEHAVIOR='dontknow'
timestamp=`date +"%s"`


while [[ $# > 0 ]]
do
key="$1"


case $key in
    --download)
    BEHAVIOR="download"
    shift # past argument
    ;;
    --deploy)
    BEHAVIOR="deploy"
    shift # past argument
    ;;
    --default)
    DEFAULT=YES
    ;;
    *)
            # unknown option
    ;;
esac
shift # past argument or value
done

if [ "$BEHAVIOR" == "dontknow" ]
then
  echo "please write"
	echo "'--deploy' for deployment"
	echo "'--download' to download"
	exit
fi


if [ "$BEHAVIOR" == "download" ]
then
	 echo "I will now download the data. Make sure you dont have the same data already."
	 read -n 1 -p "Continute[y/n]" goon
	 echo ''

	 if [ "$goon" == "y" ]
	 then
		 echo "lets download"
	 else
		 echo "I'll stop now!"
		 exit
	 fi
 fi


#exit



echo "lets deploy on all server"

username="jbrandsetter"
servers[0]="mace.phon.ox.ac.uk"
servers[1]="bay.phon.ox.ac.uk"
servers[2]="saffron.phon.ox.ac.uk"
servers[3]="cumin.phon.ox.ac.uk"
servers[4]="wasabi.phon.ox.ac.uk"
servers[5]="clove.phon.ox.ac.uk"

conditions[0]="LC_karate_humans_random"
conditions[1]="LC_karate_humans_nearby"
conditions[2]="LC_karate_humans_influentials"
conditions[3]="LC_karate_robot_random"
conditions[4]="LC_karate_robot_nearby"
conditions[5]="LC_karate_robot_influentials"


#for i in "${servers[@]}"
for (( c=3; c<6; c++ ))
do


	if [ "$BEHAVIOR" == "download" ]
	then
		echo "Download from server to server: ${servers[$c]}"
		RUNTHIS="scp -r $username@${servers[$c]}:~/outputFolder/${conditions[$c]}.csv outputFolder/${timestamp}_${conditions[$c]}.csv"
		echo $RUNTHIS
		eval $RUNTHIS


	elif [ "$BEHAVIOR" == "deploy" ]
	then
	   echo "I start deploying now!"

		 echo "Connect to server: ${servers[$c]}"
		 echo "Create 'outputFolder' if not existing"
		 ssh "$username@${servers[$c]}" 'mkdir outputFolder'

		 echo "Upload OxfordLanguageCascades.nlogo"
		 scp -r "languagecascades" "$username@${servers[$c]}:~/"

		 echo "start screen and process on remote server"
		 ssh "$username@${servers[$c]}" "screen -d -m -S jbrandserver bash -c './headlessStart.sh -b ${conditions[$c]}'"


	else
	   echo "specify deploy or downlaod"
	fi


done
