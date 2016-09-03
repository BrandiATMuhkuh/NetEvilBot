select 
CAST("Robots?" as integer) as robots, 
"Centrality",  
avg("[step]") as steps, 
avg("stat_gen_robot_percent") as "xxxp",
avg("stat_1000_robot_percent") as "1000p",  
avg("stat_2500_robot_percent") as "2500p",  
avg("stat_5000_robot_percent") as "5000p",  
avg("stat_1000_remaining_colors") as "1000c",  
avg("stat_2500_remaining_colors") as "2500c",  
avg("stat_5000_remaining_colors") as "5000c"
from runs 
group by "Robots?", "Centrality"
ORDER BY "robots" ASC
