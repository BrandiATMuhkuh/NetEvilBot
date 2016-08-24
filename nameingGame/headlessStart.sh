#
# netlogo settings
## --speadsheet: We use spreacsheet instead of table since it is only written when everything has finished not while caculating

#!/bin/bash
# Use > 1 to consume two arguments per pass in the loop (e.g. each
# argument has a corresponding value to go with it).
# Use > 0 to consume one or more arguments per pass in the loop (e.g.
# some arguments don't have a corresponding value to go with it such
# as in the --default example).
# note: if this is set to > 0 the /etc/hosts part is not recognized ( may be a bug )

#Forrest Original Typical Behaviors
# LC_target_random_hires
# LC_target_influentials_hires
# LC_target_nearby_hires


MYPWD=$(pwd)
MYNPROC=$(nproc)
NETVERSION='orignalFromForrest'
BEHAVIOR='LC_adhealthcomm3_influentials_hires'

while [[ $# > 1 ]]
do
key="$1"


case $key in
    -b|--behavior)
    BEHAVIOR="$2"
    shift # past argument
    ;;
    -v|--version)
    NETVERSION="$2"
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

#echo $NETVERSION
#echo $BEHAVIOR

#exit

COMMAND="${MYPWD}/netlogo-5.3.1-64/app/netlogo-headless.sh \
--model ${MYPWD}/languagecascades/OxfordLanguageCascades.nlogo \
--experiment ${BEHAVIOR} \
--table ${MYPWD}/outputFolder/${BEHAVIOR}.table.csv \
--threads $MYNPROC"

echo "Running this command: $COMMAND"
eval $COMMAND
