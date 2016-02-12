MYPWD=$(pwd)
MYNPROC=$(nproc)

/home/jbr134/opt/netlogo/app/netlogo-headless.sh \
--model ${MYPWD}/orignalFromForrest/languagecascades/OxfordLanguageCascades.nlogo \
--experiment LC_adhealthcomm3_influentials_hires \
--table - \
--threads $MYNPROC
