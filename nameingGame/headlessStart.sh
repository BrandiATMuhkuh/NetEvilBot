#
# netlogo settings
## --speadsheet: We use spreacsheet instead of table since it is only written when everything has finished not while caculating

MYPWD=$(pwd)
MYNPROC=$(nproc)
NETVERSION='orignalFromForrest/'
EXP='LC_adhealthcomm3_influentials_hires'

/home/jbr134/opt/netlogo/app/netlogo-headless.sh \
--model ${MYPWD}/${NETVERSION}languagecascades/OxfordLanguageCascades.nlogo \
--experiment ${EXP} \
--spreadsheet ${MYPWD}/outputFolder/${EXP}.csv \
--threads $MYNPROC
