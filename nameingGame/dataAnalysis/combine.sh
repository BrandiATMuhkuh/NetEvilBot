echo "I will now combine the table files from the simulation"
echo "combine robots to obot_combined.csv"
tail -n +7 input/LC_karate_robot_influentials.table.csv > output/robot_combined.csv
tail -n +8 input/LC_karate_robot_nearby.table.csv >> output/robot_combined.csv
tail -n +8 input/LC_karate_robot_random.table.csv >> output/robot_combined.csv

echo "combine humans to human_combined.csv"
tail -n +7 input/LC_karate_humans_influentials.table.csv > output/human_combined.csv
tail -n +8 input/LC_karate_humans_nearby.table.csv >> output/human_combined.csv
tail -n +8 input/LC_karate_humans_random.table.csv >> output/human_combined.csv
echo "we shoudld be done now"