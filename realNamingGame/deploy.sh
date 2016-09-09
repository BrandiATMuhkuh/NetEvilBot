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

conditions[0]="experiment_classroom"
conditions[1]="experiment_classroom"
conditions[2]="experiment_classroom"
conditions[3]="experiment_classroom"
conditions[4]="experiment_classroom"
conditions[5]="experiment_classroom"


#for i in "${servers[@]}"
for (( c=0; c<1; c++ ))
do


	if [ "$BEHAVIOR" == "download" ]
	then
		echo "Download from server to server: ${servers[$c]}"
		RUNTHIS="scp -r $username@${servers[$c]}:~/realNamingGame/${conditions[$c]}.table.csv runs/${timestamp}_${conditions[$c]}.$c.csv"
		echo $RUNTHIS
		eval $RUNTHIS


	elif [ "$BEHAVIOR" == "deploy" ]
	then
	   echo "I start deploying now!"

		 echo "Connect to server: ${servers[$c]}"
		 echo "Create 'outputFolder' if not existing"
		 ssh "$username@${servers[$c]}" 'mkdir realNamingGame'

		 echo "Upload MyNamingGame.nlogo"
		 scp -r "AdHealthForNetLogo" "$username@${servers[$c]}:~/realNamingGame/"
		 scp "MyNamingGame.nlogo" "$username@${servers[$c]}:~/realNamingGame/MyNamingGame.nlogo"

		 echo "start screen and process on remote server"
		 ssh "$username@${servers[$c]}" "screen -d -m -S jbrandserver bash -c './headlessStart_naming.sh -b ${conditions[$c]}'"


	else
	   echo "specify deploy or downlaod"
	fi


done
