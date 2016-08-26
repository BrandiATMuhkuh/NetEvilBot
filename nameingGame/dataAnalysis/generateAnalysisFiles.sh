
RANDON=0
LIMIT=1000

#forrest/LC_target_nearby_hires.stripped.csv
echo "generate Robot nearby and save it unser forrest/LC_target_nearby_hires.stripped.csv"
STATEMENT='select 
"categoricalness-angle" as phi, 
"degree-of-instigator" as degree,
"[step]" as convergence_time, 
"0" as "cascaded?",
"1" as "converged?",
"mean [grammar] of nodes" as mean_grammar 
from robot_combined where "bias-target" like "%near%"'
if [ $RANDON -eq 1 ] 
then
  STATEMENT="$STATEMENT ORDER BY RANDOM() limit $LIMIT"
fi


sqlite3 "output/combined.sqlite" <<!
.headers on
.mode csv
.out "forrest/LC_target_nearby_hires.stripped.csv"
$STATEMENT;
!

#forrest/LC_target_influentials_hires.stripped.csv
echo "generate Robot nearby and save it unser forrest/LC_target_influentials_hires.stripped.csv"
STATEMENT='select 
"categoricalness-angle" as phi, 
"degree-of-instigator" as degree,
"[step]" as convergence_time, 
"0" as "cascaded?",
"1" as "converged?",
"mean [grammar] of nodes" as mean_grammar 
from robot_combined where "bias-target" like "%influentials%"'
if [ $RANDON -eq 1 ] 
then
  STATEMENT="$STATEMENT ORDER BY RANDOM() limit $LIMIT"
fi

sqlite3 "output/combined.sqlite" <<!
.headers on
.mode csv
.out "forrest/LC_target_influentials_hires.stripped.csv"
$STATEMENT;
!

#forrest/LC_target_random_hires.stripped.csv
echo "generate Robot nearby and save it unser forrest/LC_target_random_hires.stripped.csv"
STATEMENT='select 
"categoricalness-angle" as phi, 
"degree-of-instigator" as degree,
"[step]" as convergence_time, 
"0" as "cascaded?",
"1" as "converged?",
"mean [grammar] of nodes" as mean_grammar 
from robot_combined where "bias-target" like "%none%"'
if [ $RANDON -eq 1 ] 
then
  STATEMENT="$STATEMENT ORDER BY RANDOM() limit $LIMIT"
fi

sqlite3 "output/combined.sqlite" <<!
.headers on
.mode csv
.out "forrest/LC_target_random_hires.stripped.csv"
$STATEMENT;
!