echo "I will now combine the table files from the simulation"
echo "combine robots to obot_combined.csv"
tail -n +7 input/LC_karate_robot_influentials_pr_cl.table.csv > output/robot_combined.csv
tail -n +8 input/LC_karate_robot_nearby_pr_cl.table.csv >> output/robot_combined.csv
tail -n +8 input/LC_karate_robot_random_pr_cl.table.csv >> output/robot_combined.csv

tail -n +8 input/LC_karate_robot_influentials_be_ra.table.csv >> output/robot_combined.csv
tail -n +8 input/LC_karate_robot_nearby_be_ra.table.csv >> output/robot_combined.csv
tail -n +8 input/LC_karate_robot_random_be_ra.table.csv >> output/robot_combined.csv

echo "combine humans to human_combined.csv"
tail -n +7 input/LC_karate_humans_influentials.table.csv > output/human_combined.csv
tail -n +8 input/LC_karate_humans_nearby.table.csv >> output/human_combined.csv
tail -n +8 input/LC_karate_humans_random.table.csv >> output/human_combined.csv
echo "we shoudld be done now"


echo "delete combined.sqlite"
rm output/combined.sqlite

echo "create and impot into output/combined.sqlite"
sqlite3 "output/combined.sqlite" <<!
.mode csv
.import output/human_combined.csv human_combined
.import output/robot_combined.csv robot_combined
!