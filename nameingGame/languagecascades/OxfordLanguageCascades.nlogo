extensions [ palette nw ]
 
breed [ nodes node ]

nodes-own
[ 
  grammar
  grammar-bias
  indiv-categoricalness-angle  ; controls the amount of categoricalness in each individual's production function
  spoken-val
  
  search-visited?  ; used for keeping track of progress in a breadth-first-search,
                   ; not crucial to model behavior, just for computing network metrics
  network-node-id
  is-robot ;define if node is robot or not
  robot-connection; defines how many robots are connected to this node
]

globals [ 
  seed 
  initial-fraction-influenced-by-minority
  outbreak-starting-nodes
  
  desired-instigator-degree  ; only used in the SETUP-NETWORK-WITH-INSTIGATOR-DEGREE procedure
  ]

to setup [ rseed ]
  ;; (for this model to work with NetLogo's new plotting features,
  ;; __clear-all-and-reset-ticks should be replaced with clear-all at
  ;; the beginning of your setup procedure and reset-ticks at the end
  ;; of the procedure.)
  __clear-all-and-reset-ticks
  if (rseed != false)
  [
    set seed rseed
    random-seed seed
  ]
  with-local-randomness [  
   ; ask patches [set pcolor cyan - 3 ]  
    ask patches [ set pcolor white ]
    ]
  ifelse (network-type = "from-file")
  [  load-network network-filename ]
  [
    setup-nodes number-of-nodes

    if (network-type = "random")
    [ setup-random-network ]
    if (network-type = "spatial")
    [  setup-spatially-clustered-network ]
    if (network-type = "preferential")
    [  setup-preferential-network nodes average-node-degree ]
    
    
  ]
    
  ifelse (start-target = "influentials")
  [
    let sortednodes sort-by [[count link-neighbors] of ?1 > [count link-neighbors] of ?2 ] nodes
    repeat start-target-rank
     [ set sortednodes but-first sortednodes ]
    set outbreak-starting-nodes (turtle-set sublist sortednodes 0 num-start-with-G1) 
    ask outbreak-starting-nodes [ set grammar 1.0 ]
  ][
    set outbreak-starting-nodes n-of num-start-with-G1 nodes 
    ask outbreak-starting-nodes
    [
      set grammar 1.0
    ]
  ]

  ; if there is more than one node from which the new grammar might spread, we pick one randomly
  let start-node max-one-of nodes [ grammar ]
  setup-biases nodes start-node false


  with-local-randomness [
    set initial-fraction-influenced-by-minority sum [ count link-neighbors ] of nodes with [ grammar > 0.5 ] / (2 * count links )

    if visuals?
    [
      ask nodes 
      [ 
        color-by-grammar 
        size-by-degree
      ]
      ask links [ set color gray + 2 ]
    ]
  ]
  with-local-randomness [  ;since this was added later, don't want it to influence seeds from before
    ask nodes [
      set indiv-categoricalness-angle categoricalness-angle
    ]
  ]
  
  
  ;add robots
  robot-setup-nodes number-of-nodes / 4
  robot-add-nodes "random" 5
end

to-report file-get-next-noncomment-line 
  let line file-read-line
  while [first line = "#" and not file-at-end?]
  [
    set line file-read-line
  ]
  if file-at-end?
  [
    report ""
  ]
  report line
end

to load-network [ fname ]
  file-open fname
  let num-nodes read-from-string file-get-next-noncomment-line
  let num-links read-from-string file-get-next-noncomment-line
  
  let node-list []

  set-default-shape nodes "circle"
    
  create-nodes num-nodes [
    ;set label (length node-list) set label-color black
    set network-node-id length node-list
    set node-list lput self node-list    
    ; for visual reasons, we don't put any nodes *too* close to the edges
    setxy random-xcor * .95 random-ycor * .95
    set grammar 0.0
  ]
  let ignore file-read-line ; #links
  repeat num-links
  [
    let id1 file-read
    let id2 file-read
    ask (item id1 node-list)
    [
      create-link-with (item id2 node-list)
    ]
  ]
  file-close
  
  if visuals? [
;    with-local-randomness [ repeat 100 [ do-network-layout nodes  ]] 
  ]
end


to-report uniform-symmetric-bias-list [ len ]
  let bias-list n-values floor (len / 2) [ -0.5 + random-float 1.0 ]
  set bias-list sentence bias-list (map [ 0 - ? ] bias-list )
  if (length bias-list != len)
    [ set bias-list fput 0 bias-list ]
  report bias-list
end

to-report random-normal-cutoff [ avg stdev xmin xmax ]
  let x random-normal avg stdev
  while [ x < xmin or x > xmax ] 
  [ set x random-normal avg stdev ]
  report x
end

to-report normal-symmetric-bias-list [ len ]
  let stdev 10 ^ bias-stdev-log10
  let bias-list n-values floor (len / 2) [ random-normal-cutoff 0 stdev -0.5 0.5 ]
  set bias-list sentence bias-list (map [ 0 - ? ] bias-list )
  if (length bias-list != len)
    [ set bias-list fput 0 bias-list ]
  report bias-list
end

to setup-nodes [ num-nodes ]
  set-default-shape nodes "circle"
    
  create-nodes num-nodes
  [
    ; for visual reasons, we don't put any nodes *too* close to the edges
    setxy random-xcor * .95 random-ycor * .95
    set grammar 0.0
    set is-robot false ;define if node is robot or not
    set robot-connection 0; number of robots connected to this node
  ]
end

to robot-setup-nodes [ num-nodes ]
  set-default-shape nodes "square"
  create-nodes num-nodes
  [
    ; for visual reasons, we don't put any nodes *too* close to the edges
    setxy random-xcor * .95 random-ycor * .95
    set size 1
    set color green
    set grammar 0.0
    set is-robot true;define if node is robot or not
    set robot-connection 0; number of humans connected to this node
  ]
end

to robot-add-nodes [ connection-type node-numbers]
  ;"random"
  
  
  ;this will connect all robot nodes with a random not robot node that has no robot
  ask nodes with [is-robot = false and robot-connection = 0]
  [
    ;let human myself 
    let thiswho who
    
    if (one-of nodes with [is-robot = true and robot-connection = 0] != nobody)[
      ask one-of nodes with [is-robot = true and robot-connection = 0]
      [
        create-link-with myself
        set robot-connection 1
        
        ask node thiswho [
          set robot-connection 1
          ]
        
        ]
      ]      
    ]

  
  ;show [who] of nodes with [is-robot = false] ;all not robot nodes
  if (connection-type = "random")
  [
    
    
    
    ]
  
end

to setup-biases [ thenodes start-node reverse-order? ]
  ;; kill everyone not in the giant component... ??
  with-local-randomness [ ask nodes with [ nw:distance-to start-node = false ] [ die ] ]
      
  let bias-list false ; this will cause an error if bias-dist wasn't a valid choice.
  if (bias-dist = "flat")
  [ set bias-list n-values (count thenodes) [ global-bias ]  ]
  if (bias-dist = "uniform-symmetric")
  [ set bias-list uniform-symmetric-bias-list (count thenodes) ]
  if (bias-dist = "normal-symmetric")
  [ set bias-list normal-symmetric-bias-list (count thenodes) ]

  let nodelist [self] of thenodes
  if (bias-target = "influentials")
  [
    set bias-list sort bias-list
    set nodelist sort-by [[count link-neighbors] of ?1 < [count link-neighbors] of ?2 ] thenodes
  ]
  if (bias-target = "nearby")
  [
    set bias-list sort bias-list
    set nodelist sort-by [[nw:distance-to start-node] of ?1 > [nw:distance-to start-node] of ?2 ] thenodes
  ]
  if (reverse-order?) 
    [ set bias-list reverse bias-list ]
  foreach nodelist
  [
    ask ?
    [
      set grammar-bias first bias-list
      set bias-list but-first bias-list
    ]
  ]
end

to setup-random-network
  ask nodes [ 
    ask nodes with [who > [who] of myself ]
    [
      if (random-float 1.0 < (average-node-degree / (number-of-nodes - 1) ))
      [ create-link-with myself ]
    ]
  ]
  if visuals?
  [
     repeat 40 [ do-network-layout nodes ]  
     rescale-network-to-world
  ]
end

to setup-spatially-clustered-network
  let num-links (average-node-degree * number-of-nodes) / 2
  while [count links < num-links ]
  [
    ask one-of nodes
    [
      let choice (min-one-of ((other turtles) with [ not link-neighbor? myself ]) [ distance myself ])
      if (choice != nobody)
        [ create-link-with choice ]
    ]
  ]
  ; make the network look a little prettier
  if visuals?
  [
     repeat 10 [ do-network-layout nodes ]  
     rescale-network-to-world
  ]
end


to setup-preferential-network [ thenodes avg-node-deg ]
  link-preferentially thenodes (avg-node-deg / 2)
  
  ; make the network look a little prettier
  if visuals?
  [
     with-local-randomness [
       layout-radial thenodes links (max-one-of thenodes [ count link-neighbors ] )
     ]
     repeat 10 [ do-network-layout thenodes ]  
     rescale-network-to-world
  ]
end

; The parameter k is the number of edges to add at each step (e.g. k=1 builds a tree)
;  (if k has a fractional part, then we probabilistically add either floork or floork + 1 edges)
;  k MUST be 1 or greater, otherwise there are errors!
to link-preferentially [ nodeset k ]
  let floork (floor k)
  let fractionk (k - floork)
  let nodelist sort nodeset

  let neighborchoicelist sublist nodelist 0 floork
  
  ask item floork nodelist
  [ 
    create-links-with turtle-set neighborchoicelist 
    set neighborchoicelist sentence (n-values floork [ self ] ) neighborchoicelist
  ]
  
  foreach sublist nodelist (floork + 1) (length nodelist)
  [
    ask ?
    [
      let tempneighborlist neighborchoicelist
      let mydegree floork + ifelse-value ((who > floork + 1) and (random-float 1.0 < fractionk)) [ 1 ] [ 0 ]
      repeat mydegree
      [
        let neighbor one-of tempneighborlist
        set tempneighborlist remove neighbor tempneighborlist 
        set neighborchoicelist fput neighbor neighborchoicelist
        create-link-with neighbor
      ]
      set neighborchoicelist sentence (n-values mydegree [ self ] ) neighborchoicelist
    ]
  ]
end


to do-network-layout [ thenodes ]
   with-local-randomness [
     layout-spring thenodes links 0.3 1 * (world-width / (sqrt number-of-nodes)) 0.9
   ]
end

to rescale-network-to-world
    with-local-randomness [
      let minx (min [ xcor ] of nodes)
      let miny (min [ ycor ] of nodes)
      let cw (max [ xcor ] of nodes) - minx
      let ch (max [ ycor ] of nodes) - miny
      ask nodes [ 
        set xcor (xcor - minx) / cw * (world-width - 1) + min-pxcor
        set ycor (ycor - miny) / ch * (world-height - 1) + min-pycor
      ]
    ]
end

to go
  ask nodes [ speak ]
  ask nodes [ learn ]
;; this would be a different type of scheduling, where high degree nodes
;; are 'learning' much more quickly than the rest of the agents.
;; if we delete this stuff, also delete "learn-from" procedure down below!
;  ask links [
;    ask both-ends [
;      speak
;      learn-from other-end
;    ]
;  ]
  
  if visuals?
  [
    with-local-randomness [
      ask nodes [ color-by-grammar ]
    ]
    update-plot
  ]
  tick
end

to size-by-degree
  set size 0.3 * sqrt (count link-neighbors + 1)
end

to color-by-grammar
  ;set color scale-color yellow grammar 0 1.000000001
  set color palette:scale-gradient [[0 100 200] [225 0 0]] grammar 0 1.000000001
end

to color-by-grammar-bias
  ;set color scale-color red grammar-bias -0.50000001 .500000001
  set color palette:scale-gradient [[0 100 200] [225 0 0]] grammar-bias -0.50000001 .500000001
end

;; NOTE: this function is the "cognitive logistic" function, although note that
;; the paper uses the "beta" bias term to describe the inflection point of the
;; clog function, so a negative bias value is in FAVOR of the innovation,
;; but this NetLogo model uses a positive bias value to be in FAVOR of the innovation,
;; and a negative bias value to be against.
to-report sigmoid-func [ x inflection-angle beta-bias ]
  ; this is a sigmoid-type function [0,1] --> [0,1] with parameters:
  ;    x: input
  ;    inflection-angle: degree of nonlinearity (45 = linear, 90 = step function)
  ;    beta-bias: determines (repelling) fixed point: x' = 0.5 - beta-bias
  if inflection-angle = 90 [report ifelse-value (x < (0.5 - beta-bias)) [0.0] [1.0]]
  if inflection-angle = 45 [report x] ; linear!
  ifelse (beta-bias < -0.5) [ set beta-bias -0.5 ]
  [ if (beta-bias > 0.5) [ set beta-bias 0.5 ]]
  let gamma 2 * ((tan inflection-angle) - 1)
  let left-term (x * exp(gamma * (x + beta-bias)))
  let right-term ((1.0 - x) * exp(gamma * (1.0 - (x + beta-bias))))
  report (left-term / (left-term + right-term))
end



to speak
  let prob (sigmoid-func grammar indiv-categoricalness-angle (global-bias + grammar-bias))
  set spoken-val ifelse-value (random-float 1.0 < prob) [ 1 ] [ 0 ]
end

to learn
  if (not any? link-neighbors)
    [ stop ]
  let new-gram (learning-rate * mean [ spoken-val ] of link-neighbors) + (1 - learning-rate) * grammar 
  ifelse (new-gram > 1) 
    [ set new-gram 1 ]
    [ if (new-gram < 0) [ set new-gram 0 ] ]
  set grammar new-gram
end

;; This procedure would be useful, if we decided to use the different update scheduling mentioned in
;; the GO procedure, wherein high degree nodes do a lot more speaking *AND* learning than other nodes.
;to learn-from [ othernode ]
;  let new-gram (learning-rate * [ spoken-val ] of othernode) + (1 - learning-rate) * grammar 
;  ifelse (new-gram > 1) 
;    [ set new-gram 1 ]
;    [ if (new-gram < 0) [ set new-gram 0 ] ]
;  set grammar new-gram
;end


to update-plot
  with-local-randomness [
    set-current-plot "Grammar State"
    set-current-plot-pen "state"
    plot mean [ grammar ] of nodes
    set-current-plot-pen "spoken"
    plot mean [ spoken-val ] of nodes
  ]
end

to-report converged?
  ; if the chance of the out-lier node producing a minority-grammar
  ;    token in the next 10,000 time steps is safely less than 0.01%, then stop.
    if not any? nodes [ report false ]
    report ((min [ grammar ] of nodes) > (1 - 1E-8) or (max [ grammar ] of nodes) < 1E-8)
end

;; The following several procedures are not necessary for the running of the model, but may be
;; useful for measuring the model, BehaviorSpace experiments, etc.

to-report cascaded?
  ifelse (converged? and mean [grammar] of nodes > 0.5) 
    [ report 1 ] 
    [ report 0 ]
end

to-report cascaded90?
  ifelse (mean [grammar] of nodes > 0.9)
  [ report 1 ] 
  [ report 0 ]
end

to-report communityA
  report nodes with [ who < (count nodes / 2) ]
end

to-report communityB
  report nodes with [ who >= (count nodes / 2) ]
end

to-report degree-distribution
  report reverse sort [ count link-neighbors ] of nodes
end

;; reports the node that started the outbreak. if there are multiple starting nodes, 
;; the node with the highest degree is returned.
to-report instigator 
  report max-one-of outbreak-starting-nodes [count link-neighbors]
end

to-report degree-of-instigator
  report [count link-neighbors] of instigator
end

to-report rank-of-instigator
  report position instigator (sort-by [ [count link-neighbors ] of ?1 > [count link-neighbors] of ?2 ] nodes)
end

to-report closeness-centrality ;; NODE procedure
  report nw:closeness-centrality
end

to-report betweenness-centrality ;; NODE procedure
  report nw:betweenness-centrality
end

to-report eigenvector-centrality ;; NODE procedure
  report nw:eigenvector-centrality
end

to-report clustering-coefficient ;; NODE procedure
  report nw:clustering-coefficient
end

to-report avg-neighbor-degree;; NODE procedure
  report mean [count link-neighbors] of link-neighbors
end

;; This procedure will keep generating network topologies until we generate
;; one that has at least one node that is the degree we are interested in, which
;; we will choose to be the "instigator" of the change.  This way we will more easily
;; be able to calculate the probability of a cascade for any given node degree...
to setup-network-with-instigator-degree [ instigator-degree ]
  ;; (for this model to work with NetLogo's new plotting features,
  ;; __clear-all-and-reset-ticks should be replaced with clear-all at
  ;; the beginning of your setup procedure and reset-ticks at the end
  ;; of the procedure.)
  __clear-all-and-reset-ticks
  let myseed new-seed
  random-seed myseed
  while [not any? (nodes with [ count link-neighbors = instigator-degree ]) ]
  [
    setup false
  ]
  set seed myseed
  random-seed seed
  set desired-instigator-degree instigator-degree
  ask nodes [ set grammar 0 ]
  
  let start-node one-of nodes with [ count link-neighbors = instigator-degree ]
  
  set outbreak-starting-nodes (turtle-set start-node)
  ask outbreak-starting-nodes
  [
    set grammar 1.0
  ]
  
  setup-biases nodes start-node false
  
  
  with-local-randomness [
    set initial-fraction-influenced-by-minority sum [ count link-neighbors ] of nodes with [ grammar > 0.5 ] / (2 * count links )

    if visuals?
    [
      ask nodes 
      [ 
        color-by-grammar 
        size-by-degree
      ]
      ask links [ set color gray + 2 ]
    ]
  ] 
end

to-report unique-filename
  report (word "DAT" 
    "_" network-type
    "_N" (precision number-of-nodes 0)
    "_AD" (precision average-node-degree 0)
    "_B" bias-target
    "_S" start-target
    "_" (precision start-target-rank 0)
    "_" (precision num-start-with-G1 0)
    "_" (precision desired-instigator-degree 0) 
    "_" (precision categoricalness-angle 2)
    "_" (precision learning-rate 3)
    "_" seed 
    ".data"
    )
end

to-report gamma-from-categoricalness [ cat ]
  if (cat = 100) [ report "inf" ]
  report (cat / (100 - cat))
end

to save-network-and-results [ fname ]
  file-open fname
  file-print (word "# $START$ " fname)  ; "#" comments to be compatable with networkx edgelist file format
  file-print (word "# categoricalness-angle " categoricalness-angle) 
  file-print (word "# cascaded? " cascaded?) 
  file-print (word "# cascaded90? " cascaded90?)
  file-print (word "# converged? " converged?)
  file-print (word "# finalmeangrammar " (mean [grammar] of nodes))
  file-print (word "# instigator " ([who] of instigator))
  file-print (word "# finaltick " ticks)
  file-print (word "# finalstate " map [[grammar] of ?] (sort nodes))
  file-print "# "
  foreach (sort links)
  [
    ask ? [
      file-print (word ([who] of end1) " " ([who] of end2))
    ]
  ]
  file-close
end

;; NOTE: in the following procedures, the "0 - grammar-bias" is to account for the 
;; fact that in the paper the "beta" bias term describes the inflection point of the
;; production function, so a negative bias value is in FAVOR of the innovation,
;; but this NetLogo model uses a positive bias value to be in FAVOR of the innovation,
;; and a negative bias value to be against.
to-report most-favorable-bias-in-population
  report first (sort [0 - grammar-bias] of nodes)
end

to-report second-most-favorable-bias-in-population
  report item 1 (sort [0 - grammar-bias] of nodes)
end

to-report instigator-bias
  report [0 - grammar-bias] of instigator
end

to-report instigator-best-neighbor-bias
  report [min ([0 - grammar-bias] of link-neighbors)] of instigator
end
  
to-report instigator-worst-neighbor-bias
  report [min ([0 - grammar-bias] of link-neighbors)] of instigator
end

to-report instigator-mean-neighbor-bias
  report [mean ([0 - grammar-bias] of link-neighbors)] of instigator
end

to color-network-by-data-list [ datalist ]
  let index 0
  let min-val min datalist
  let max-val max datalist
  foreach datalist [
    let color-val ?
    ask nodes with [ network-node-id = index ]
    [
      set color palette:scale-gradient [[0 0 0] [0 255 0]] color-val min-val (max-val + .00000001)
    ]
    set index index + 1
  ]
end

to temp-color-coding
  ; addhealth comm3 nearby, phi60, omplete cascade freq
  ; max of 33
;  color-network-by-data-list [0 0 1 14 4 0 2 1 14 0 0 0 1 0 0 0 1 0 0 0 2 0 0 2 0 0 0 0 0 0 33 19] 


  ; addhealth comm3 nearby, phi60, dominance cascade freq
  ; max of 560
;  color-network-by-data-list [3 13 59 560 29 12 9 2 243 227 10 0 1 0 0 0 1 0 16 0 2 0 62 25 0 9 9 6 68 5 40 23]
  
  ; addhealth comm3 nearby, phi60, survival cascade freq
  ; max of 2122
;  color-network-by-data-list [880 1654 127 560 67 18 9 2 243 227 10 401 6 5 0 0 2 0 16 2122 195 0 62 25 0 214 9 1275 68 118 204 23]
  
  ; addhealth comm3 influentials/hubs, phi60, survival cascade freq
  ; max of 101
  color-network-by-data-list [0 0 0 101 0 0 1 0 11 23 10 0 0 0 0 0 0 1 0 0 0 0 7 3 0 0 0 0 2 0 0 2]
  
end
@#$#@#$#@
GRAPHICS-WINDOW
250
10
667
448
18
18
11.0
1
10
1
1
1
0
0
0
1
-18
18
-18
18
1
1
1
ticks
30.0

BUTTON
15
340
80
373
setup
;; (for this model to work with NetLogo's new plotting features,\n  ;; __clear-all-and-reset-ticks should be replaced with clear-all at\n  ;; the beginning of your setup procedure and reset-ticks at the end\n  ;; of the procedure.)\n  __clear-all-and-reset-ticks\nsetup new-seed
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
85
340
145
373
go
go\nif (converged?) [ stop ]
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
685
55
955
245
Grammar State
time
grammar
0.0
52.0
0.0
1.0
true
true
"" ""
PENS
"spoken" 1.0 0 -8630108 true "" ""
"state" 1.0 0 -16777216 true "" ""

SLIDER
15
125
215
158
number-of-nodes
number-of-nodes
10
500
10
1
1
NIL
HORIZONTAL

SLIDER
15
390
215
423
categoricalness-angle
categoricalness-angle
45
90
60
0.25
1
NIL
HORIZONTAL

SLIDER
15
160
215
193
average-node-degree
average-node-degree
2
10
3.2
0.2
1
NIL
HORIZONTAL

SLIDER
15
255
215
288
num-start-with-G1
num-start-with-G1
0
number-of-nodes
1
1
1
NIL
HORIZONTAL

SLIDER
15
425
215
458
learning-rate
learning-rate
0
1
0.1
0.01
1
NIL
HORIZONTAL

MONITOR
865
10
955
55
max-grammar
max [ grammar ] of nodes
4
1
11

MONITOR
770
10
865
55
mean-grammar
mean [ grammar ] of nodes
4
1
11

BUTTON
150
340
215
373
step
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
685
10
770
55
min-grammar
min [grammar] of nodes
4
1
11

SLIDER
685
260
845
293
global-bias
global-bias
-0.5
0.5
0
0.001
1
NIL
HORIZONTAL

CHOOSER
40
10
185
55
network-type
network-type
"spatial" "random" "preferential" "from-file"
2

SLIDER
685
405
845
438
bias-stdev-log10
bias-stdev-log10
-5
1
1
0.25
1
NIL
HORIZONTAL

BUTTON
534
450
624
483
layout
with-local-randomness \n[ do-network-layout nodes display ] 
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
865
325
955
370
mean-bias
mean [grammar-bias] of nodes
10
1
11

BUTTON
384
450
509
483
color-by-bias
with-local-randomness \n[ ask nodes [ color-by-grammar-bias ] ]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SWITCH
264
450
369
483
visuals?
visuals?
0
1
-1000

CHOOSER
685
350
845
395
bias-dist
bias-dist
"flat" "uniform-symmetric" "normal-symmetric"
1

MONITOR
865
270
955
315
min-bias
min [grammar-bias] of nodes
4
1
11

CHOOSER
685
300
845
345
bias-target
bias-target
"influentials" "nearby" "none"
1

CHOOSER
40
205
185
250
start-target
start-target
"influentials" "none"
0

SLIDER
15
290
215
323
start-target-rank
start-target-rank
0
number-of-nodes - num-start-with-G1
0
1
1
NIL
HORIZONTAL

BUTTON
384
485
509
518
color-by-grammar
ask nodes [ color-by-grammar ]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
695
450
831
495
measured avg deg
2 * count links / (count nodes)
3
1
11

MONITOR
840
450
915
495
gamma
2 * (tan categoricalness-angle - 1)
3
1
11

CHOOSER
5
70
245
115
network-filename
network-filename
false "AdHealthForNetLogo/comm2.txt" "AdHealthForNetLogo/comm3.txt" "AdHealthForNetLogo/comm37.txt" "AdHealthForNetLogo/comm55.txt" "AdHealthForNetLogo/comm63.txt"
0

MONITOR
700
500
792
545
NIL
count nodes
0
1
11

@#$#@#$#@
## NOTES

* distributing bias "nearby" doesn't work properly when the network is not connected.  
*

## WHAT IS IT?

This is a linguistics model about how a language change may (or may not) diffuse through a social network.  The key research question that it is interested in investigating is this:  How can initially rare grammar variants become dominant in a population, without any global bias in their favor?  It is known that such changes can and do occur in the real world - but what conditions are necessary to produce this behavior?  This model demonstrates that the behavior can be reproduced through the use of simple cognitively-motivated agent rules combined with a social network structure and certain distributions of heterogeneous bias in the population.  The language cascade occurs despite the fact that all of the agents' biases sum to 0.

While the model was developed for linguistics, there are potentially useful lessons to be learned about the interactions of heterogeneous agents in a social network, which may perhaps be applied to other disciplines, such epidemiology, or the diffusion of innovation in marketing.

## HOW IT WORKS

In this model, there are two opposing grammar variants (G0 and G1) in the population.  Each agent's grammar value lies on the range between 0.0 and 1.0.  The value 0.0 means that the agent only speaks grammar variant G0, whereas 1.0 means that the agent only speaks grammar variant G1.  For grammar values between 0.0 and 1.0, an agent may speak either G0 or G1, with some probability.  The probability is determined by a "production function", the shape of which depends on the CATEGORICALNESS parameter, as well as a 'bias' which can vary between agents (this 'bias' may be distributed in various ways, as shall be discussed in more detail later).  It is called a "production" function because it maps a tendency toward one grammar or another into a probability of producing a token for one grammar or the other.  If CATEGORICALNESS = 0, the production function is linear, meaning that agents produce G1 tokens with probability given directly by their grammar value, and G0 tokens otherwise.  If CATEGORICALNESS > 0  
the production function is nonlinear (in particular, sigmoidal).   The agent's bias determines the point at which the production function crosses the line Y = X, which may be considered repelling point, because if the agent's grammar value is below this repelling point and the agent were talking only to itself, it would eventually end up with grammar value 0.0, but if the grammar value started above this point, it would eventually end up at grammar value 1.0.  The larger the CATEGORICALNESS parameter, the closer the sigmoidal production function is to a step function, and at CATEGORICALNESS = 100, the production function actually becomes a step function.  This means that if the agents grammar value is above a point (determined by its bias) it will only speak G1, and if it is below that point, it will only speak G0.  In this case, agents are completely categorical about their speech, and are unwilling to mix the usage of two the two competing grammars.

Over time each agent updates the state of its internal grammar value based on the tokens it is hearing from neighboring agents in the social network.  More specifically, in each tick, each agent first produces a single token probabilistically, based on their grammar state and their production function.  Each agent then updates their grammar state to be closer to the mean grammar value that they heard from all of their neighbors.  We use what is sometimes called "alpha learning", whereby the new grammar state is a weighted average  of the old grammar state with the mean of all the tokens produced by the neighbors.  Thus, high degree nodes (agents) in the network (which we refer to as "influentials") are considered to be "heard" by many more nodes than low-degree nodes.  However, the LEARNING-RATE (rate of change from the current grammar state toward the perceived grammar of the neighbors) of all of the nodes is the same.

As an example, an agent that start with grammar value 1.0 will certainly produce a G1 grammar token in the first tick of the model.  After one tick, it may have heard G0 tokens from their neighbors, and have adjusted their grammar value downward, meaning that the probability of producing G1 is no longer 100%.  However, if the LEARNING-RATE is not too large, the agent's grammar value will probably still be quite high, which corresponds to a high likelihood of producing a G1 token in the next tick.  However, over time the grammar value may undergo significant changes.

## HOW TO USE IT / MODEL PARAMETERS

While the basic mechanics of the model are described simply above, there are numerous parameters, and ways to initialize or setup the model, to address different questions.  
Here is a brief explanation of each parameter of control for the model, and how they related to the initialization and running of the model.

The social network structure (NETWORK-TYPE) may be initialized in several ways:
 * "spatial" causes nearby agents (in Euclidean space) to be linked together
 * "random" refers to Erdos-Renyi random graphs
 * "preferential" refers to the Barabasi-Albert preferential attachment method of creating scale-free networks.  The method has been extended slightly to handle the creation of networks with odd average degree, by probabilistically choosing to add either K or K+1 edges as each new node is attached to the network.
 * "two-communities" consists of two "preferential" networks loosely connected to each other by some number of links (specified by the INTERCOMMUNITYLINKS parameter).

The network is created with the specified NUMBER-OF-NODES and AVERAGE-NODE-DEGREE.

By default, nodes start with an internal grammar value of 0.0, meaning they have no chance of ever using variant G1.  The NUM-START-WITH-G1 parameter, however, controls the number of nodes in the network that start with grammar value 1.0.  

If START-TARGET = "none", the agents are randomly chosen to start with grammar value 1.0.  But if START-TAGET = "influentials", then the 1.0 grammar value is assigned by starting with the START-TARGET-RANK most influential agent and going down in order.  For instance, if START-TARGET-RANK = 9, and NUM-START-WITH-G1 = 3, then the 10th, 11th, and 12th most influential agents (highest-degree nodes) will be assigned grammar value 1.0.

Each agent is assigned a bias toward one grammar variant or the other. The bias can  range from +0.5 (strongly supporting G1) to -0.5 (strongly supporting G0).  If BIAS-DIST = "flat", then all agents are assigned the same bias.  If BIAS-DIST = "uniform-symmetric", then the biases are chosen symmetrically in pairs (X and -X) from a uniform distribution between -0.5 and 0.5.  If BIAS-DIST = "normal-symmetric", then the biases are chosen symmetrically in pairs (X and -X) from a normal distribution, centered around 0, and with the log (base 10) of the standard deviation given by BIAS-STDEV-LOG10 parameter.  The distribution is truncated at -0.5 and 0.5 (if a value is out of range, we redraw from the distribution).

Additionally, all agents' biases are affected by the GLOBAL-BIAS parameter.

The BIAS-TARGET parameter controls how bias is distributed in the social network.  If BIAS-TARGET = "none", then bias is randomly distributed.  If BIAS-TARGET = "nearby", then bias is distributed in sorted order (positive bias down to negative) starting with the most influential agent, down to the least influential agent.  If BIAS-TARGET = "nearby", then bias is distributed in sorted order outward from a random one of the agents that is starting with the G1 grammar.  This last method has the effect of creating a very favorable initial audience for this G1 speakers, and (from our experiments) appears to greatly improve the chances of a language cascade.

The preceding discussion is most relevant for the "spatial", "random", and "preferential" network types.  The grammar states and biases for the "two-communities" network-type are initialized according to different rules.  In this case, two "preferential" network communities are created - one consisting initially of all G0 speakers and the other consisting of all G1 speakers.  The COMA-START and COMB-START parameters control whether the bias is distributed in such a way that the community is more ripe for a language cascade to occur, or more resistant against change to the status quo.  More specifically, in each community, the biases are distributed outward from a random node in sorted order (either up, or down, depending). In Community A, if the bias is distributed outward starting with positive bias (supporting G1) down to negative bias, then the network will be more "ripe" for a G1 cascade.  On the other hand, distributing bias from negative bias (supporting G0) outward to positive bias will create a configuration that is more resistant to change.  For Community B (which starts with G1 prevalent) the situation is reversed, but otherwise exactly the same.  

The links between these two communities are chosen based on the COMA-BRIDGE-BIAS and COMB-BRIDGE-BIAS parameters.  If COMA-BRIDGE-BIAS = 0, then the agents in Community A that are most biased towards G0 will be chosen as "bridge" nodes - meaning they will be linked to the other community.  If COMA-BRIDGE-BIAS = 1, then the agents most biased towards G1 will be bridge nodes.  Similarly, COMB-BRIDGE-BIAS determines which nodes will be bridge nodes in Community B.

As mentioned above, the CATEGORICALNESS parameter affects the degree to which nodes are willing to speak the two grammar variants interchangeably, rather than having a stronger preference to speak consistently, or semi-categorically.

The LEARNING-RATE parameter controls the rate at which agents speaking affects other agents internal grammar values.  The grammar value of each agent is updated by a weighted sum of the old grammar value and the mean heard grammar of its neighbors. The LEARNING-RATE is the weight given to new data, while (1 - LEARNING-RATE) is the weight given to the old grammar value.

The PROBABALISTIC-SPEECH? parameter controls whether agents always speak 0 or 1 tokens probabilistically (ON), or else speak the real-valued numbers between 0 and 1 produced by their production functions (OFF).  The default is for PROBABALISTIC-SPEECH? to be ON.  However, turning it OFF could correspond to a longer iterated batch learning process.  In many ways, turning it OFF has the effect of removing some noise from the system, and causing faster convergence to an equilibrium.  However, the noise *can* be crucial in certain situations, and the behavior will be different.  There may be some interesting avenues for further research here...

The VISUALS? parameter turns on or off the visual display.  Turning VISUALS? OFF can help speed up the runs when running experiments.  It will not effect the outcome of the model at all.

The COLOR-BY-BIAS and COLOR-BY-GRAMMAR buttons affect the visualization of the network, scaling low values (0.0 grammar, or -0.5 bias) to black, and high values (1.0 grammar, 0.5 bias) to white.

The LAYOUT button can be used to try to improve the visual aesthetics of the network layout.  Note that this only affects visualization, and does not affect the model itself.

The SETUP button initializes the model, and the GO button runs the simulation until it has converged (or forever, if it does not converge).  The STEP button goes one tick at a time.

Various monitors show statistics (min, max, mean) for the grammar values or grammar biases.  The "GRAMMAR STATE" plot also plots the mean internal grammar value of the agents over time, as well as the mean spoken value.

## THINGS TO NOTICE

## THINGS TO TRY

## EXTENDING THE MODEL

## RELATED MODELS

Language Change (by Celina Troutman)

## CREDITS AND REFERENCES

Written by Forrest Stonedahl, in collaboration with Janet Pierrehumbert and Robert Daland.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.2.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="bigsweep" repetitions="100" runMetricsEveryStep="false">
    <setup>setup new-seed</setup>
    <go>go</go>
    <timeLimit steps="10000"/>
    <exitCondition>converged?</exitCondition>
    <metric>cascaded?</metric>
    <metric>cascaded90?</metric>
    <metric>converged?</metric>
    <metric>round (mean [grammar] of nodes)</metric>
    <metric>mean [grammar] of nodes</metric>
    <metric>standard-deviation [grammar] of nodes</metric>
    <metric>min [grammar] of nodes</metric>
    <metric>max [grammar] of nodes</metric>
    <metric>count nodes with [ grammar &gt; 0.5 ]</metric>
    <metric>initial-fraction-influenced-by-minority</metric>
    <metric>seed</metric>
    <enumeratedValueSet variable="bias-target">
      <value value="&quot;influentials&quot;"/>
      <value value="&quot;nearby&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-node-degree">
      <value value="2"/>
      <value value="3"/>
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-nodes">
      <value value="64"/>
      <value value="128"/>
      <value value="256"/>
      <value value="512"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-target-rank">
      <value value="0"/>
      <value value="1"/>
      <value value="3"/>
      <value value="7"/>
      <value value="15"/>
      <value value="31"/>
      <value value="63"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-target">
      <value value="&quot;influentials&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-start-with-G1">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="network-type">
      <value value="&quot;preferential&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="learning-rate">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="categoricalness">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global-bias">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bias-dist">
      <value value="&quot;uniform-symmetric&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="visuals?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probabilistic-speech?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bias-stdev-log10">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="ranksweep256" repetitions="100" runMetricsEveryStep="false">
    <setup>setup new-seed</setup>
    <go>go</go>
    <timeLimit steps="10000"/>
    <exitCondition>converged?</exitCondition>
    <metric>cascaded?</metric>
    <metric>cascaded90?</metric>
    <metric>converged?</metric>
    <metric>round (mean [grammar] of nodes)</metric>
    <metric>mean [grammar] of nodes</metric>
    <metric>standard-deviation [grammar] of nodes</metric>
    <metric>min [grammar] of nodes</metric>
    <metric>max [grammar] of nodes</metric>
    <metric>count nodes with [ grammar &gt; 0.5 ]</metric>
    <metric>initial-fraction-influenced-by-minority</metric>
    <metric>seed</metric>
    <metric>item start-target-rank degree-distribution</metric>
    <metric>degree-distribution</metric>
    <enumeratedValueSet variable="bias-target">
      <value value="&quot;nearby&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-node-degree">
      <value value="4"/>
      <value value="5"/>
      <value value="6"/>
      <value value="7"/>
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-nodes">
      <value value="256"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-target-rank">
      <value value="0"/>
      <value value="1"/>
      <value value="3"/>
      <value value="7"/>
      <value value="15"/>
      <value value="31"/>
      <value value="63"/>
      <value value="127"/>
      <value value="255"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-target">
      <value value="&quot;influentials&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-start-with-G1">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="network-type">
      <value value="&quot;preferential&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="learning-rate">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="categoricalness">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global-bias">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bias-dist">
      <value value="&quot;uniform-symmetric&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="visuals?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probabilistic-speech?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bias-stdev-log10">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="baseline" repetitions="100" runMetricsEveryStep="false">
    <setup>setup new-seed</setup>
    <go>go</go>
    <timeLimit steps="10000"/>
    <exitCondition>converged?</exitCondition>
    <metric>cascaded?</metric>
    <metric>cascaded90?</metric>
    <metric>converged?</metric>
    <metric>round (mean [grammar] of nodes)</metric>
    <metric>mean [grammar] of nodes</metric>
    <metric>standard-deviation [grammar] of nodes</metric>
    <metric>min [grammar] of nodes</metric>
    <metric>max [grammar] of nodes</metric>
    <metric>count nodes with [ grammar &gt; 0.5 ]</metric>
    <metric>initial-fraction-influenced-by-minority</metric>
    <metric>seed</metric>
    <metric>first ([count link-neighbors] of outbreak-starting-nodes)</metric>
    <metric>first ([grammar-bias] of outbreak-starting-nodes)</metric>
    <enumeratedValueSet variable="bias-target">
      <value value="&quot;none&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-node-degree">
      <value value="2"/>
      <value value="3"/>
      <value value="4"/>
      <value value="5"/>
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-nodes">
      <value value="64"/>
      <value value="128"/>
      <value value="256"/>
      <value value="512"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-target-rank">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-target">
      <value value="&quot;none&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-start-with-G1">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="network-type">
      <value value="&quot;preferential&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="learning-rate">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="categoricalness">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global-bias">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bias-dist">
      <value value="&quot;uniform-symmetric&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="visuals?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probabilistic-speech?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bias-stdev-log10">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="randomgraph" repetitions="100" runMetricsEveryStep="false">
    <setup>setup new-seed</setup>
    <go>go</go>
    <timeLimit steps="10000"/>
    <exitCondition>converged?</exitCondition>
    <metric>cascaded?</metric>
    <metric>cascaded90?</metric>
    <metric>converged?</metric>
    <metric>round (mean [grammar] of nodes)</metric>
    <metric>mean [grammar] of nodes</metric>
    <metric>standard-deviation [grammar] of nodes</metric>
    <metric>min [grammar] of nodes</metric>
    <metric>max [grammar] of nodes</metric>
    <metric>count nodes with [ grammar &gt; 0.5 ]</metric>
    <metric>(count nodes with [ grammar &gt; 0.5 ]) / (count nodes)</metric>
    <metric>initial-fraction-influenced-by-minority</metric>
    <metric>seed</metric>
    <metric>first ([count link-neighbors] of outbreak-starting-nodes)</metric>
    <enumeratedValueSet variable="bias-target">
      <value value="&quot;nearby&quot;"/>
      <value value="&quot;influentials&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-node-degree">
      <value value="2"/>
      <value value="3"/>
      <value value="4"/>
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-nodes">
      <value value="64"/>
      <value value="128"/>
      <value value="256"/>
      <value value="512"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-target-rank">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-target">
      <value value="&quot;none&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-start-with-G1">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="network-type">
      <value value="&quot;random&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="learning-rate">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="categoricalness">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global-bias">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bias-dist">
      <value value="&quot;uniform-symmetric&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="visuals?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probabilistic-speech?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bias-stdev-log10">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="ranksweep256fine" repetitions="50" runMetricsEveryStep="false">
    <setup>setup new-seed</setup>
    <go>go</go>
    <timeLimit steps="10000"/>
    <exitCondition>converged?</exitCondition>
    <metric>cascaded?</metric>
    <metric>cascaded90?</metric>
    <metric>converged?</metric>
    <metric>round (mean [grammar] of nodes)</metric>
    <metric>mean [grammar] of nodes</metric>
    <metric>standard-deviation [grammar] of nodes</metric>
    <metric>min [grammar] of nodes</metric>
    <metric>max [grammar] of nodes</metric>
    <metric>count nodes with [ grammar &gt; 0.5 ]</metric>
    <metric>initial-fraction-influenced-by-minority</metric>
    <metric>seed</metric>
    <metric>[count link-neighbors] of instigator</metric>
    <metric>[closeness-centrality] of instigator</metric>
    <metric>degree-distribution</metric>
    <enumeratedValueSet variable="bias-target">
      <value value="&quot;nearby&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-node-degree">
      <value value="2"/>
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-nodes">
      <value value="256"/>
    </enumeratedValueSet>
    <steppedValueSet variable="start-target-rank" first="0" step="1" last="255"/>
    <enumeratedValueSet variable="start-target">
      <value value="&quot;influentials&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-start-with-G1">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="network-type">
      <value value="&quot;preferential&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="learning-rate">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="categoricalness">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global-bias">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bias-dist">
      <value value="&quot;uniform-symmetric&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="visuals?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probabilistic-speech?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bias-stdev-log10">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="degreesweep256" repetitions="10" runMetricsEveryStep="false">
    <setup>setup-network-with-instigator-degree desired-instigator-degree</setup>
    <go>go</go>
    <timeLimit steps="10000"/>
    <exitCondition>converged?</exitCondition>
    <metric>cascaded?</metric>
    <metric>cascaded90?</metric>
    <metric>converged?</metric>
    <metric>round (mean [grammar] of nodes)</metric>
    <metric>mean [grammar] of nodes</metric>
    <metric>standard-deviation [grammar] of nodes</metric>
    <metric>min [grammar] of nodes</metric>
    <metric>max [grammar] of nodes</metric>
    <metric>count nodes with [ grammar &gt; 0.5 ]</metric>
    <metric>initial-fraction-influenced-by-minority</metric>
    <metric>seed</metric>
    <metric>rank-of-instigator</metric>
    <metric>[closeness-centrality] of instigator</metric>
    <metric>degree-distribution</metric>
    <enumeratedValueSet variable="bias-target">
      <value value="&quot;nearby&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-node-degree">
      <value value="4"/>
    </enumeratedValueSet>
    <steppedValueSet variable="desired-instigator-degree" first="1" step="1" last="64"/>
    <enumeratedValueSet variable="number-of-nodes">
      <value value="256"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-target-rank">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-target">
      <value value="&quot;influentials&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-start-with-G1">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="network-type">
      <value value="&quot;preferential&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="learning-rate">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="categoricalness">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global-bias">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bias-dist">
      <value value="&quot;uniform-symmetric&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="visuals?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probabilistic-speech?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bias-stdev-log10">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="june2010_gammadegreesweep" repetitions="10" runMetricsEveryStep="false">
    <setup>setup-network-with-instigator-degree desired-instigator-degree</setup>
    <go>go</go>
    <timeLimit steps="10000"/>
    <exitCondition>converged?</exitCondition>
    <metric>cascaded?</metric>
    <metric>cascaded90?</metric>
    <metric>converged?</metric>
    <metric>round (mean [grammar] of nodes)</metric>
    <metric>mean [grammar] of nodes</metric>
    <metric>standard-deviation [grammar] of nodes</metric>
    <metric>min [grammar] of nodes</metric>
    <metric>max [grammar] of nodes</metric>
    <metric>count nodes with [ grammar &gt; 0.5 ]</metric>
    <metric>initial-fraction-influenced-by-minority</metric>
    <metric>seed</metric>
    <metric>degree-of-instigator</metric>
    <metric>rank-of-instigator</metric>
    <metric>[closeness-centrality] of instigator</metric>
    <metric>[betweenness-centrality] of instigator</metric>
    <metric>[avg-neighbor-degree] of instigator</metric>
    <enumeratedValueSet variable="bias-target">
      <value value="&quot;nearby&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-node-degree">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="categoricalness">
      <value value="0"/>
      <value value="50"/>
      <value value="83.3333333"/>
      <value value="92.307692308"/>
      <value value="100"/>
    </enumeratedValueSet>
    <steppedValueSet variable="desired-instigator-degree" first="1" step="1" last="64"/>
    <enumeratedValueSet variable="number-of-nodes">
      <value value="256"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-target-rank">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-target">
      <value value="&quot;influentials&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-start-with-G1">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="network-type">
      <value value="&quot;preferential&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="learning-rate">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global-bias">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bias-dist">
      <value value="&quot;uniform-symmetric&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="visuals?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probabilistic-speech?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bias-stdev-log10">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="june2010_hetgamma" repetitions="100" runMetricsEveryStep="false">
    <setup>setup-network-with-instigator-degree desired-instigator-degree</setup>
    <go>go</go>
    <final>save-network-and-results (word "odata/" unique-filename)</final>
    <timeLimit steps="10000"/>
    <exitCondition>converged?</exitCondition>
    <metric>cascaded?</metric>
    <metric>cascaded90?</metric>
    <metric>converged?</metric>
    <metric>round (mean [grammar] of nodes)</metric>
    <metric>mean [grammar] of nodes</metric>
    <metric>standard-deviation [grammar] of nodes</metric>
    <metric>min [grammar] of nodes</metric>
    <metric>max [grammar] of nodes</metric>
    <metric>count nodes with [ grammar &gt; 0.5 ]</metric>
    <metric>count nodes with [ grammar &gt; 0.9 ]</metric>
    <metric>initial-fraction-influenced-by-minority</metric>
    <metric>seed</metric>
    <metric>degree-of-instigator</metric>
    <metric>rank-of-instigator</metric>
    <metric>[closeness-centrality] of instigator</metric>
    <metric>[betweenness-centrality] of instigator</metric>
    <metric>[eigenvector-centrality] of instigator</metric>
    <metric>[clustering-coefficient] of instigator</metric>
    <metric>[avg-neighbor-degree] of instigator</metric>
    <metric>unique-filename</metric>
    <enumeratedValueSet variable="heterogeneous-categoricalness?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bias-target">
      <value value="&quot;none&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-node-degree">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="categoricalness">
      <value value="-1"/>
    </enumeratedValueSet>
    <steppedValueSet variable="desired-instigator-degree" first="1" step="1" last="64"/>
    <enumeratedValueSet variable="number-of-nodes">
      <value value="256"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-target-rank">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-target">
      <value value="&quot;none&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-start-with-G1">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="network-type">
      <value value="&quot;preferential&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="learning-rate">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global-bias">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bias-dist">
      <value value="&quot;flat&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="visuals?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probabilistic-speech?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bias-stdev-log10">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="june2010_gammadegreesweepinf" repetitions="10" runMetricsEveryStep="false">
    <setup>setup-network-with-instigator-degree desired-instigator-degree</setup>
    <go>go</go>
    <final>save-network-and-results (word "odata2/" unique-filename)</final>
    <timeLimit steps="10000"/>
    <exitCondition>converged?</exitCondition>
    <metric>cascaded?</metric>
    <metric>cascaded90?</metric>
    <metric>converged?</metric>
    <metric>round (mean [grammar] of nodes)</metric>
    <metric>mean [grammar] of nodes</metric>
    <metric>standard-deviation [grammar] of nodes</metric>
    <metric>min [grammar] of nodes</metric>
    <metric>max [grammar] of nodes</metric>
    <metric>count nodes with [ grammar &gt; 0.5 ]</metric>
    <metric>count nodes with [ grammar &gt; 0.9 ]</metric>
    <metric>initial-fraction-influenced-by-minority</metric>
    <metric>seed</metric>
    <metric>degree-of-instigator</metric>
    <metric>rank-of-instigator</metric>
    <metric>[closeness-centrality] of instigator</metric>
    <metric>[betweenness-centrality] of instigator</metric>
    <metric>[eigenvector-centrality] of instigator</metric>
    <metric>[clustering-coefficient] of instigator</metric>
    <metric>[avg-neighbor-degree] of instigator</metric>
    <metric>unique-filename</metric>
    <enumeratedValueSet variable="heterogeneous-categoricalness?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bias-target">
      <value value="&quot;influentials&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-node-degree">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="categoricalness">
      <value value="0"/>
      <value value="50"/>
      <value value="83.3333333"/>
      <value value="92.307692308"/>
      <value value="100"/>
    </enumeratedValueSet>
    <steppedValueSet variable="desired-instigator-degree" first="1" step="1" last="64"/>
    <enumeratedValueSet variable="number-of-nodes">
      <value value="256"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-target-rank">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-target">
      <value value="&quot;influentials&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-start-with-G1">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="network-type">
      <value value="&quot;preferential&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="learning-rate">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global-bias">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bias-dist">
      <value value="&quot;uniform-symmetric&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="visuals?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probabilistic-speech?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bias-stdev-log10">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="LC_target_random" repetitions="100" runMetricsEveryStep="false">
    <setup>setup-network-with-instigator-degree desired-instigator-degree</setup>
    <go>go</go>
    <final>save-network-and-results (word "odata_rand/" unique-filename)</final>
    <timeLimit steps="10000"/>
    <exitCondition>converged?</exitCondition>
    <metric>cascaded?</metric>
    <metric>cascaded90?</metric>
    <metric>converged?</metric>
    <metric>round (mean [grammar] of nodes)</metric>
    <metric>mean [grammar] of nodes</metric>
    <metric>standard-deviation [grammar] of nodes</metric>
    <metric>min [grammar] of nodes</metric>
    <metric>max [grammar] of nodes</metric>
    <metric>count nodes with [ grammar &gt; 0.5 ]</metric>
    <metric>count nodes with [ grammar &gt; 0.9 ]</metric>
    <metric>initial-fraction-influenced-by-minority</metric>
    <metric>seed</metric>
    <metric>degree-of-instigator</metric>
    <metric>rank-of-instigator</metric>
    <metric>[closeness-centrality] of instigator</metric>
    <metric>[betweenness-centrality] of instigator</metric>
    <metric>[eigenvector-centrality] of instigator</metric>
    <metric>[clustering-coefficient] of instigator</metric>
    <metric>[avg-neighbor-degree] of instigator</metric>
    <metric>unique-filename</metric>
    <enumeratedValueSet variable="heterogeneous-categoricalness?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bias-target">
      <value value="&quot;none&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-node-degree">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="categoricalness-angle">
      <value value="45"/>
      <value value="56.25"/>
      <value value="67.5"/>
      <value value="78.75"/>
      <value value="90"/>
    </enumeratedValueSet>
    <steppedValueSet variable="desired-instigator-degree" first="1" step="1" last="55"/>
    <enumeratedValueSet variable="number-of-nodes">
      <value value="256"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-target-rank">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-target">
      <value value="&quot;influentials&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-start-with-G1">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="network-type">
      <value value="&quot;preferential&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="learning-rate">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global-bias">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bias-dist">
      <value value="&quot;uniform-symmetric&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="visuals?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probabilistic-speech?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bias-stdev-log10">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="LC_target_influentials" repetitions="100" runMetricsEveryStep="false">
    <setup>setup-network-with-instigator-degree desired-instigator-degree</setup>
    <go>go</go>
    <final>save-network-and-results (word "odata_inf/" unique-filename)</final>
    <timeLimit steps="10000"/>
    <exitCondition>converged?</exitCondition>
    <metric>cascaded?</metric>
    <metric>cascaded90?</metric>
    <metric>converged?</metric>
    <metric>round (mean [grammar] of nodes)</metric>
    <metric>mean [grammar] of nodes</metric>
    <metric>standard-deviation [grammar] of nodes</metric>
    <metric>min [grammar] of nodes</metric>
    <metric>max [grammar] of nodes</metric>
    <metric>count nodes with [ grammar &gt; 0.5 ]</metric>
    <metric>count nodes with [ grammar &gt; 0.9 ]</metric>
    <metric>initial-fraction-influenced-by-minority</metric>
    <metric>seed</metric>
    <metric>degree-of-instigator</metric>
    <metric>rank-of-instigator</metric>
    <metric>[closeness-centrality] of instigator</metric>
    <metric>[betweenness-centrality] of instigator</metric>
    <metric>[eigenvector-centrality] of instigator</metric>
    <metric>[clustering-coefficient] of instigator</metric>
    <metric>[avg-neighbor-degree] of instigator</metric>
    <metric>unique-filename</metric>
    <enumeratedValueSet variable="heterogeneous-categoricalness?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bias-target">
      <value value="&quot;influentials&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-node-degree">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="categoricalness-angle">
      <value value="45"/>
      <value value="56.25"/>
      <value value="67.5"/>
      <value value="78.75"/>
      <value value="90"/>
    </enumeratedValueSet>
    <steppedValueSet variable="desired-instigator-degree" first="1" step="1" last="55"/>
    <enumeratedValueSet variable="number-of-nodes">
      <value value="256"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-target-rank">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-target">
      <value value="&quot;influentials&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-start-with-G1">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="network-type">
      <value value="&quot;preferential&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="learning-rate">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global-bias">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bias-dist">
      <value value="&quot;uniform-symmetric&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="visuals?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probabilistic-speech?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bias-stdev-log10">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="LC_target_nearby" repetitions="100" runMetricsEveryStep="false">
    <setup>setup-network-with-instigator-degree desired-instigator-degree</setup>
    <go>go</go>
    <final>save-network-and-results (word "odata_nearby/" unique-filename)</final>
    <timeLimit steps="10000"/>
    <exitCondition>converged?</exitCondition>
    <metric>cascaded?</metric>
    <metric>cascaded90?</metric>
    <metric>converged?</metric>
    <metric>round (mean [grammar] of nodes)</metric>
    <metric>mean [grammar] of nodes</metric>
    <metric>standard-deviation [grammar] of nodes</metric>
    <metric>min [grammar] of nodes</metric>
    <metric>max [grammar] of nodes</metric>
    <metric>count nodes with [ grammar &gt; 0.5 ]</metric>
    <metric>count nodes with [ grammar &gt; 0.9 ]</metric>
    <metric>initial-fraction-influenced-by-minority</metric>
    <metric>seed</metric>
    <metric>degree-of-instigator</metric>
    <metric>rank-of-instigator</metric>
    <metric>[closeness-centrality] of instigator</metric>
    <metric>[betweenness-centrality] of instigator</metric>
    <metric>[eigenvector-centrality] of instigator</metric>
    <metric>[clustering-coefficient] of instigator</metric>
    <metric>[avg-neighbor-degree] of instigator</metric>
    <metric>unique-filename</metric>
    <enumeratedValueSet variable="heterogeneous-categoricalness?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bias-target">
      <value value="&quot;nearby&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-node-degree">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="categoricalness-angle">
      <value value="45"/>
      <value value="56.25"/>
      <value value="67.5"/>
      <value value="78.75"/>
      <value value="90"/>
    </enumeratedValueSet>
    <steppedValueSet variable="desired-instigator-degree" first="1" step="1" last="55"/>
    <enumeratedValueSet variable="number-of-nodes">
      <value value="256"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-target-rank">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-target">
      <value value="&quot;influentials&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-start-with-G1">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="network-type">
      <value value="&quot;preferential&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="learning-rate">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global-bias">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bias-dist">
      <value value="&quot;uniform-symmetric&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="visuals?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probabilistic-speech?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bias-stdev-log10">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="LC_homogenous_bias" repetitions="100" runMetricsEveryStep="false">
    <setup>setup-network-with-instigator-degree desired-instigator-degree</setup>
    <go>go</go>
    <final>save-network-and-results (word "odata_hbias/" unique-filename)</final>
    <timeLimit steps="10000"/>
    <exitCondition>converged?</exitCondition>
    <metric>cascaded?</metric>
    <metric>cascaded90?</metric>
    <metric>converged?</metric>
    <metric>round (mean [grammar] of nodes)</metric>
    <metric>mean [grammar] of nodes</metric>
    <metric>standard-deviation [grammar] of nodes</metric>
    <metric>min [grammar] of nodes</metric>
    <metric>max [grammar] of nodes</metric>
    <metric>count nodes with [ grammar &gt; 0.5 ]</metric>
    <metric>count nodes with [ grammar &gt; 0.9 ]</metric>
    <metric>initial-fraction-influenced-by-minority</metric>
    <metric>seed</metric>
    <metric>degree-of-instigator</metric>
    <metric>rank-of-instigator</metric>
    <metric>[closeness-centrality] of instigator</metric>
    <metric>[betweenness-centrality] of instigator</metric>
    <metric>[eigenvector-centrality] of instigator</metric>
    <metric>[clustering-coefficient] of instigator</metric>
    <metric>[avg-neighbor-degree] of instigator</metric>
    <metric>unique-filename</metric>
    <enumeratedValueSet variable="heterogeneous-categoricalness?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bias-target">
      <value value="&quot;none&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-node-degree">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="categoricalness-angle">
      <value value="45"/>
      <value value="56.25"/>
      <value value="67.5"/>
      <value value="78.75"/>
      <value value="90"/>
    </enumeratedValueSet>
    <steppedValueSet variable="desired-instigator-degree" first="1" step="1" last="55"/>
    <enumeratedValueSet variable="number-of-nodes">
      <value value="256"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-target-rank">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-target">
      <value value="&quot;influentials&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-start-with-G1">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="network-type">
      <value value="&quot;preferential&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="learning-rate">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global-bias">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bias-dist">
      <value value="&quot;flat&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="visuals?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probabilistic-speech?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bias-stdev-log10">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="LC_target_influentials_finegamma" repetitions="100" runMetricsEveryStep="false">
    <setup>setup-network-with-instigator-degree desired-instigator-degree</setup>
    <go>go</go>
    <final>save-network-and-results (word "odata_inffine/" unique-filename)</final>
    <timeLimit steps="10000"/>
    <exitCondition>converged?</exitCondition>
    <metric>cascaded?</metric>
    <metric>cascaded90?</metric>
    <metric>converged?</metric>
    <metric>round (mean [grammar] of nodes)</metric>
    <metric>mean [grammar] of nodes</metric>
    <metric>standard-deviation [grammar] of nodes</metric>
    <metric>min [grammar] of nodes</metric>
    <metric>max [grammar] of nodes</metric>
    <metric>count nodes with [ grammar &gt; 0.5 ]</metric>
    <metric>count nodes with [ grammar &gt; 0.9 ]</metric>
    <metric>initial-fraction-influenced-by-minority</metric>
    <metric>seed</metric>
    <metric>degree-of-instigator</metric>
    <metric>rank-of-instigator</metric>
    <metric>[closeness-centrality] of instigator</metric>
    <metric>[betweenness-centrality] of instigator</metric>
    <metric>[eigenvector-centrality] of instigator</metric>
    <metric>[clustering-coefficient] of instigator</metric>
    <metric>[avg-neighbor-degree] of instigator</metric>
    <metric>unique-filename</metric>
    <enumeratedValueSet variable="heterogeneous-categoricalness?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bias-target">
      <value value="&quot;influentials&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-node-degree">
      <value value="4"/>
    </enumeratedValueSet>
    <steppedValueSet variable="categoricalness-angle" first="45" step="5" last="90"/>
    <steppedValueSet variable="desired-instigator-degree" first="1" step="1" last="55"/>
    <enumeratedValueSet variable="number-of-nodes">
      <value value="256"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-target-rank">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-target">
      <value value="&quot;influentials&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-start-with-G1">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="network-type">
      <value value="&quot;preferential&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="learning-rate">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global-bias">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bias-dist">
      <value value="&quot;uniform-symmetric&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="visuals?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probabilistic-speech?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bias-stdev-log10">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="LC_target_nearby_finegamma" repetitions="20" runMetricsEveryStep="false">
    <setup>setup-network-with-instigator-degree desired-instigator-degree</setup>
    <go>go</go>
    <final>save-network-and-results (word "odata_nearbyfine/" unique-filename)</final>
    <timeLimit steps="10000"/>
    <exitCondition>converged?</exitCondition>
    <metric>cascaded?</metric>
    <metric>cascaded90?</metric>
    <metric>converged?</metric>
    <metric>round (mean [grammar] of nodes)</metric>
    <metric>mean [grammar] of nodes</metric>
    <metric>standard-deviation [grammar] of nodes</metric>
    <metric>min [grammar] of nodes</metric>
    <metric>max [grammar] of nodes</metric>
    <metric>count nodes with [ grammar &gt; 0.5 ]</metric>
    <metric>count nodes with [ grammar &gt; 0.9 ]</metric>
    <metric>initial-fraction-influenced-by-minority</metric>
    <metric>seed</metric>
    <metric>degree-of-instigator</metric>
    <metric>rank-of-instigator</metric>
    <metric>[closeness-centrality] of instigator</metric>
    <metric>[betweenness-centrality] of instigator</metric>
    <metric>[eigenvector-centrality] of instigator</metric>
    <metric>[clustering-coefficient] of instigator</metric>
    <metric>[avg-neighbor-degree] of instigator</metric>
    <metric>unique-filename</metric>
    <enumeratedValueSet variable="heterogeneous-categoricalness?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bias-target">
      <value value="&quot;nearby&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-node-degree">
      <value value="4"/>
    </enumeratedValueSet>
    <steppedValueSet variable="categoricalness-angle" first="45" step="5" last="90"/>
    <steppedValueSet variable="desired-instigator-degree" first="1" step="1" last="55"/>
    <enumeratedValueSet variable="number-of-nodes">
      <value value="256"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-target-rank">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-target">
      <value value="&quot;influentials&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-start-with-G1">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="network-type">
      <value value="&quot;preferential&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="learning-rate">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global-bias">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bias-dist">
      <value value="&quot;uniform-symmetric&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="visuals?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probabilistic-speech?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bias-stdev-log10">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="LC_target_random_finegamma" repetitions="100" runMetricsEveryStep="false">
    <setup>setup-network-with-instigator-degree desired-instigator-degree</setup>
    <go>go</go>
    <final>save-network-and-results (word "odata_randfine/" unique-filename)</final>
    <timeLimit steps="10000"/>
    <exitCondition>converged?</exitCondition>
    <metric>cascaded?</metric>
    <metric>cascaded90?</metric>
    <metric>converged?</metric>
    <metric>round (mean [grammar] of nodes)</metric>
    <metric>mean [grammar] of nodes</metric>
    <metric>standard-deviation [grammar] of nodes</metric>
    <metric>min [grammar] of nodes</metric>
    <metric>max [grammar] of nodes</metric>
    <metric>count nodes with [ grammar &gt; 0.5 ]</metric>
    <metric>count nodes with [ grammar &gt; 0.9 ]</metric>
    <metric>initial-fraction-influenced-by-minority</metric>
    <metric>seed</metric>
    <metric>degree-of-instigator</metric>
    <metric>rank-of-instigator</metric>
    <metric>[closeness-centrality] of instigator</metric>
    <metric>[betweenness-centrality] of instigator</metric>
    <metric>[eigenvector-centrality] of instigator</metric>
    <metric>[clustering-coefficient] of instigator</metric>
    <metric>[avg-neighbor-degree] of instigator</metric>
    <metric>unique-filename</metric>
    <enumeratedValueSet variable="heterogeneous-categoricalness?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bias-target">
      <value value="&quot;none&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-node-degree">
      <value value="4"/>
    </enumeratedValueSet>
    <steppedValueSet variable="categoricalness-angle" first="45" step="5" last="90"/>
    <steppedValueSet variable="desired-instigator-degree" first="1" step="1" last="55"/>
    <enumeratedValueSet variable="number-of-nodes">
      <value value="256"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-target-rank">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-target">
      <value value="&quot;influentials&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-start-with-G1">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="network-type">
      <value value="&quot;preferential&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="learning-rate">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global-bias">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bias-dist">
      <value value="&quot;uniform-symmetric&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="visuals?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probabilistic-speech?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bias-stdev-log10">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="LC_target_random_hires" repetitions="10" runMetricsEveryStep="false">
    <setup>setup-network-with-instigator-degree desired-instigator-degree</setup>
    <go>go</go>
    <final>save-network-and-results (word "odata_randhr/" unique-filename)</final>
    <timeLimit steps="10000"/>
    <exitCondition>converged?</exitCondition>
    <metric>cascaded?</metric>
    <metric>cascaded90?</metric>
    <metric>converged?</metric>
    <metric>round (mean [grammar] of nodes)</metric>
    <metric>mean [grammar] of nodes</metric>
    <metric>standard-deviation [grammar] of nodes</metric>
    <metric>min [grammar] of nodes</metric>
    <metric>max [grammar] of nodes</metric>
    <metric>count nodes with [ grammar &gt; 0.5 ]</metric>
    <metric>count nodes with [ grammar &gt; 0.9 ]</metric>
    <metric>initial-fraction-influenced-by-minority</metric>
    <metric>seed</metric>
    <metric>degree-of-instigator</metric>
    <metric>rank-of-instigator</metric>
    <metric>[closeness-centrality] of instigator</metric>
    <metric>[betweenness-centrality] of instigator</metric>
    <metric>[eigenvector-centrality] of instigator</metric>
    <metric>[clustering-coefficient] of instigator</metric>
    <metric>[avg-neighbor-degree] of instigator</metric>
    <metric>unique-filename</metric>
    <enumeratedValueSet variable="heterogeneous-categoricalness?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bias-target">
      <value value="&quot;none&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-node-degree">
      <value value="4"/>
    </enumeratedValueSet>
    <steppedValueSet variable="categoricalness-angle" first="45" step="1" last="90"/>
    <steppedValueSet variable="desired-instigator-degree" first="1" step="1" last="55"/>
    <enumeratedValueSet variable="number-of-nodes">
      <value value="256"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-target-rank">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-target">
      <value value="&quot;influentials&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-start-with-G1">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="network-type">
      <value value="&quot;preferential&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="learning-rate">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global-bias">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bias-dist">
      <value value="&quot;uniform-symmetric&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="visuals?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probabilistic-speech?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bias-stdev-log10">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="LC_target_influentials_hires" repetitions="10" runMetricsEveryStep="false">
    <setup>setup-network-with-instigator-degree desired-instigator-degree</setup>
    <go>go</go>
    <final>save-network-and-results (word "odata_infhr/" unique-filename)</final>
    <timeLimit steps="10000"/>
    <exitCondition>converged?</exitCondition>
    <metric>cascaded?</metric>
    <metric>cascaded90?</metric>
    <metric>converged?</metric>
    <metric>round (mean [grammar] of nodes)</metric>
    <metric>mean [grammar] of nodes</metric>
    <metric>standard-deviation [grammar] of nodes</metric>
    <metric>min [grammar] of nodes</metric>
    <metric>max [grammar] of nodes</metric>
    <metric>count nodes with [ grammar &gt; 0.5 ]</metric>
    <metric>count nodes with [ grammar &gt; 0.9 ]</metric>
    <metric>initial-fraction-influenced-by-minority</metric>
    <metric>seed</metric>
    <metric>degree-of-instigator</metric>
    <metric>rank-of-instigator</metric>
    <metric>[closeness-centrality] of instigator</metric>
    <metric>[betweenness-centrality] of instigator</metric>
    <metric>[eigenvector-centrality] of instigator</metric>
    <metric>[clustering-coefficient] of instigator</metric>
    <metric>[avg-neighbor-degree] of instigator</metric>
    <metric>unique-filename</metric>
    <enumeratedValueSet variable="heterogeneous-categoricalness?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bias-target">
      <value value="&quot;influentials&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-node-degree">
      <value value="4"/>
    </enumeratedValueSet>
    <steppedValueSet variable="categoricalness-angle" first="45" step="1" last="90"/>
    <steppedValueSet variable="desired-instigator-degree" first="1" step="1" last="55"/>
    <enumeratedValueSet variable="number-of-nodes">
      <value value="256"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-target-rank">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-target">
      <value value="&quot;influentials&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-start-with-G1">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="network-type">
      <value value="&quot;preferential&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="learning-rate">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global-bias">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bias-dist">
      <value value="&quot;uniform-symmetric&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="visuals?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probabilistic-speech?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bias-stdev-log10">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="LC_target_nearby_hires" repetitions="10" runMetricsEveryStep="false">
    <setup>setup-network-with-instigator-degree desired-instigator-degree</setup>
    <go>go</go>
    <final>save-network-and-results (word "odata_nearbyhr/" unique-filename)</final>
    <timeLimit steps="10000"/>
    <exitCondition>converged?</exitCondition>
    <metric>cascaded?</metric>
    <metric>cascaded90?</metric>
    <metric>converged?</metric>
    <metric>round (mean [grammar] of nodes)</metric>
    <metric>mean [grammar] of nodes</metric>
    <metric>standard-deviation [grammar] of nodes</metric>
    <metric>min [grammar] of nodes</metric>
    <metric>max [grammar] of nodes</metric>
    <metric>count nodes with [ grammar &gt; 0.5 ]</metric>
    <metric>count nodes with [ grammar &gt; 0.9 ]</metric>
    <metric>initial-fraction-influenced-by-minority</metric>
    <metric>seed</metric>
    <metric>degree-of-instigator</metric>
    <metric>rank-of-instigator</metric>
    <metric>[closeness-centrality] of instigator</metric>
    <metric>[betweenness-centrality] of instigator</metric>
    <metric>[eigenvector-centrality] of instigator</metric>
    <metric>[clustering-coefficient] of instigator</metric>
    <metric>[avg-neighbor-degree] of instigator</metric>
    <metric>unique-filename</metric>
    <enumeratedValueSet variable="heterogeneous-categoricalness?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bias-target">
      <value value="&quot;nearby&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-node-degree">
      <value value="4"/>
    </enumeratedValueSet>
    <steppedValueSet variable="categoricalness-angle" first="45" step="1" last="90"/>
    <steppedValueSet variable="desired-instigator-degree" first="1" step="1" last="55"/>
    <enumeratedValueSet variable="number-of-nodes">
      <value value="256"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-target-rank">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-target">
      <value value="&quot;influentials&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-start-with-G1">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="network-type">
      <value value="&quot;preferential&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="learning-rate">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global-bias">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bias-dist">
      <value value="&quot;uniform-symmetric&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="visuals?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probabilistic-speech?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bias-stdev-log10">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="LC_adhealthcomm3_nearby_phi60" repetitions="1000" runMetricsEveryStep="false">
    <setup>setup-network-with-instigator-degree desired-instigator-degree</setup>
    <go>go</go>
    <timeLimit steps="10000"/>
    <exitCondition>converged?</exitCondition>
    <metric>cascaded?</metric>
    <metric>cascaded90?</metric>
    <metric>converged?</metric>
    <metric>round (mean [grammar] of nodes)</metric>
    <metric>mean [grammar] of nodes</metric>
    <metric>standard-deviation [grammar] of nodes</metric>
    <metric>min [grammar] of nodes</metric>
    <metric>max [grammar] of nodes</metric>
    <metric>count nodes with [ grammar &gt; 0.5 ]</metric>
    <metric>count nodes with [ grammar &gt; 0.9 ]</metric>
    <metric>initial-fraction-influenced-by-minority</metric>
    <metric>seed</metric>
    <metric>([network-node-id] of instigator)</metric>
    <metric>degree-of-instigator</metric>
    <metric>rank-of-instigator</metric>
    <metric>[closeness-centrality] of instigator</metric>
    <metric>[betweenness-centrality] of instigator</metric>
    <metric>[eigenvector-centrality] of instigator</metric>
    <metric>[clustering-coefficient] of instigator</metric>
    <metric>[avg-neighbor-degree] of instigator</metric>
    <metric>unique-filename</metric>
    <metric>most-favorable-bias-in-population</metric>
    <metric>second-most-favorable-bias-in-population</metric>
    <metric>instigator-bias</metric>
    <metric>instigator-best-neighbor-bias</metric>
    <metric>instigator-worst-neighbor-bias</metric>
    <metric>instigator-mean-neighbor-bias</metric>
    <enumeratedValueSet variable="bias-target">
      <value value="&quot;nearby&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="categoricalness-angle">
      <value value="60"/>
    </enumeratedValueSet>
    <steppedValueSet variable="desired-instigator-degree" first="1" step="1" last="11"/>
    <enumeratedValueSet variable="num-start-with-G1">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="network-type">
      <value value="&quot;from-file&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="network-filename">
      <value value="&quot;AdHealthForNetLogo/comm3.txt&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="learning-rate">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global-bias">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bias-dist">
      <value value="&quot;uniform-symmetric&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="visuals?">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="LC_adhealthcomm3_random_phi60" repetitions="1000" runMetricsEveryStep="false">
    <setup>setup-network-with-instigator-degree desired-instigator-degree</setup>
    <go>go</go>
    <timeLimit steps="10000"/>
    <exitCondition>converged?</exitCondition>
    <metric>cascaded?</metric>
    <metric>cascaded90?</metric>
    <metric>converged?</metric>
    <metric>round (mean [grammar] of nodes)</metric>
    <metric>mean [grammar] of nodes</metric>
    <metric>standard-deviation [grammar] of nodes</metric>
    <metric>min [grammar] of nodes</metric>
    <metric>max [grammar] of nodes</metric>
    <metric>count nodes with [ grammar &gt; 0.5 ]</metric>
    <metric>count nodes with [ grammar &gt; 0.9 ]</metric>
    <metric>initial-fraction-influenced-by-minority</metric>
    <metric>seed</metric>
    <metric>([network-node-id] of instigator)</metric>
    <metric>degree-of-instigator</metric>
    <metric>rank-of-instigator</metric>
    <metric>[closeness-centrality] of instigator</metric>
    <metric>[betweenness-centrality] of instigator</metric>
    <metric>[eigenvector-centrality] of instigator</metric>
    <metric>[clustering-coefficient] of instigator</metric>
    <metric>[avg-neighbor-degree] of instigator</metric>
    <metric>unique-filename</metric>
    <metric>most-favorable-bias-in-population</metric>
    <metric>second-most-favorable-bias-in-population</metric>
    <metric>instigator-bias</metric>
    <metric>instigator-best-neighbor-bias</metric>
    <metric>instigator-worst-neighbor-bias</metric>
    <metric>instigator-mean-neighbor-bias</metric>
    <enumeratedValueSet variable="bias-target">
      <value value="&quot;none&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="categoricalness-angle">
      <value value="60"/>
    </enumeratedValueSet>
    <steppedValueSet variable="desired-instigator-degree" first="1" step="1" last="11"/>
    <enumeratedValueSet variable="num-start-with-G1">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="network-type">
      <value value="&quot;from-file&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="network-filename">
      <value value="&quot;AdHealthForNetLogo/comm3.txt&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="learning-rate">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global-bias">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bias-dist">
      <value value="&quot;uniform-symmetric&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="visuals?">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="LC_adhealthcomm3_influentials_phi60" repetitions="1000" runMetricsEveryStep="false">
    <setup>setup-network-with-instigator-degree desired-instigator-degree</setup>
    <go>go</go>
    <timeLimit steps="10000"/>
    <exitCondition>converged?</exitCondition>
    <metric>cascaded?</metric>
    <metric>cascaded90?</metric>
    <metric>converged?</metric>
    <metric>round (mean [grammar] of nodes)</metric>
    <metric>mean [grammar] of nodes</metric>
    <metric>standard-deviation [grammar] of nodes</metric>
    <metric>min [grammar] of nodes</metric>
    <metric>max [grammar] of nodes</metric>
    <metric>count nodes with [ grammar &gt; 0.5 ]</metric>
    <metric>count nodes with [ grammar &gt; 0.9 ]</metric>
    <metric>initial-fraction-influenced-by-minority</metric>
    <metric>seed</metric>
    <metric>([network-node-id] of instigator)</metric>
    <metric>degree-of-instigator</metric>
    <metric>rank-of-instigator</metric>
    <metric>[closeness-centrality] of instigator</metric>
    <metric>[betweenness-centrality] of instigator</metric>
    <metric>[eigenvector-centrality] of instigator</metric>
    <metric>[clustering-coefficient] of instigator</metric>
    <metric>[avg-neighbor-degree] of instigator</metric>
    <metric>unique-filename</metric>
    <metric>most-favorable-bias-in-population</metric>
    <metric>second-most-favorable-bias-in-population</metric>
    <metric>instigator-bias</metric>
    <metric>instigator-best-neighbor-bias</metric>
    <metric>instigator-worst-neighbor-bias</metric>
    <metric>instigator-mean-neighbor-bias</metric>
    <enumeratedValueSet variable="bias-target">
      <value value="&quot;influentials&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="categoricalness-angle">
      <value value="60"/>
    </enumeratedValueSet>
    <steppedValueSet variable="desired-instigator-degree" first="1" step="1" last="11"/>
    <enumeratedValueSet variable="num-start-with-G1">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="network-type">
      <value value="&quot;from-file&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="network-filename">
      <value value="&quot;AdHealthForNetLogo/comm3.txt&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="learning-rate">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global-bias">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bias-dist">
      <value value="&quot;uniform-symmetric&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="visuals?">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="LC_adhealthcomm3_nearby_hires" repetitions="100" runMetricsEveryStep="false">
    <setup>setup-network-with-instigator-degree desired-instigator-degree</setup>
    <go>go</go>
    <timeLimit steps="10000"/>
    <exitCondition>converged?</exitCondition>
    <metric>cascaded?</metric>
    <metric>cascaded90?</metric>
    <metric>converged?</metric>
    <metric>round (mean [grammar] of nodes)</metric>
    <metric>mean [grammar] of nodes</metric>
    <metric>standard-deviation [grammar] of nodes</metric>
    <metric>min [grammar] of nodes</metric>
    <metric>max [grammar] of nodes</metric>
    <metric>count nodes with [ grammar &gt; 0.5 ]</metric>
    <metric>count nodes with [ grammar &gt; 0.9 ]</metric>
    <metric>initial-fraction-influenced-by-minority</metric>
    <metric>seed</metric>
    <metric>([network-node-id] of instigator)</metric>
    <metric>degree-of-instigator</metric>
    <metric>rank-of-instigator</metric>
    <metric>[closeness-centrality] of instigator</metric>
    <metric>[betweenness-centrality] of instigator</metric>
    <metric>[eigenvector-centrality] of instigator</metric>
    <metric>[clustering-coefficient] of instigator</metric>
    <metric>[avg-neighbor-degree] of instigator</metric>
    <metric>unique-filename</metric>
    <enumeratedValueSet variable="bias-target">
      <value value="&quot;nearby&quot;"/>
    </enumeratedValueSet>
    <steppedValueSet variable="categoricalness-angle" first="45" step="1" last="90"/>
    <steppedValueSet variable="desired-instigator-degree" first="1" step="1" last="11"/>
    <enumeratedValueSet variable="num-start-with-G1">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="network-type">
      <value value="&quot;from-file&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="network-filename">
      <value value="&quot;AdHealthForNetLogo/comm3.txt&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="learning-rate">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global-bias">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bias-dist">
      <value value="&quot;uniform-symmetric&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="visuals?">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="LC_adhealthcomm3_random_hires" repetitions="100" runMetricsEveryStep="false">
    <setup>setup-network-with-instigator-degree desired-instigator-degree</setup>
    <go>go</go>
    <timeLimit steps="10000"/>
    <exitCondition>converged?</exitCondition>
    <metric>cascaded?</metric>
    <metric>cascaded90?</metric>
    <metric>converged?</metric>
    <metric>round (mean [grammar] of nodes)</metric>
    <metric>mean [grammar] of nodes</metric>
    <metric>standard-deviation [grammar] of nodes</metric>
    <metric>min [grammar] of nodes</metric>
    <metric>max [grammar] of nodes</metric>
    <metric>count nodes with [ grammar &gt; 0.5 ]</metric>
    <metric>count nodes with [ grammar &gt; 0.9 ]</metric>
    <metric>initial-fraction-influenced-by-minority</metric>
    <metric>seed</metric>
    <metric>([network-node-id] of instigator)</metric>
    <metric>degree-of-instigator</metric>
    <metric>rank-of-instigator</metric>
    <metric>[closeness-centrality] of instigator</metric>
    <metric>[betweenness-centrality] of instigator</metric>
    <metric>[eigenvector-centrality] of instigator</metric>
    <metric>[clustering-coefficient] of instigator</metric>
    <metric>[avg-neighbor-degree] of instigator</metric>
    <metric>unique-filename</metric>
    <enumeratedValueSet variable="bias-target">
      <value value="&quot;none&quot;"/>
    </enumeratedValueSet>
    <steppedValueSet variable="categoricalness-angle" first="45" step="1" last="90"/>
    <steppedValueSet variable="desired-instigator-degree" first="1" step="1" last="11"/>
    <enumeratedValueSet variable="num-start-with-G1">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="network-type">
      <value value="&quot;from-file&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="network-filename">
      <value value="&quot;AdHealthForNetLogo/comm3.txt&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="learning-rate">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global-bias">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bias-dist">
      <value value="&quot;uniform-symmetric&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="visuals?">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="LC_adhealthcomm3_influentials_hires" repetitions="100" runMetricsEveryStep="false">
    <setup>setup-network-with-instigator-degree desired-instigator-degree</setup>
    <go>go</go>
    <timeLimit steps="10000"/>
    <exitCondition>converged?</exitCondition>
    <metric>cascaded?</metric>
    <metric>cascaded90?</metric>
    <metric>converged?</metric>
    <metric>round (mean [grammar] of nodes)</metric>
    <metric>mean [grammar] of nodes</metric>
    <metric>standard-deviation [grammar] of nodes</metric>
    <metric>min [grammar] of nodes</metric>
    <metric>max [grammar] of nodes</metric>
    <metric>count nodes with [ grammar &gt; 0.5 ]</metric>
    <metric>count nodes with [ grammar &gt; 0.9 ]</metric>
    <metric>initial-fraction-influenced-by-minority</metric>
    <metric>seed</metric>
    <metric>([network-node-id] of instigator)</metric>
    <metric>degree-of-instigator</metric>
    <metric>rank-of-instigator</metric>
    <metric>[closeness-centrality] of instigator</metric>
    <metric>[betweenness-centrality] of instigator</metric>
    <metric>[eigenvector-centrality] of instigator</metric>
    <metric>[clustering-coefficient] of instigator</metric>
    <metric>[avg-neighbor-degree] of instigator</metric>
    <metric>unique-filename</metric>
    <enumeratedValueSet variable="bias-target">
      <value value="&quot;influentials&quot;"/>
    </enumeratedValueSet>
    <steppedValueSet variable="categoricalness-angle" first="45" step="1" last="90"/>
    <steppedValueSet variable="desired-instigator-degree" first="1" step="1" last="11"/>
    <enumeratedValueSet variable="num-start-with-G1">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="network-type">
      <value value="&quot;from-file&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="network-filename">
      <value value="&quot;AdHealthForNetLogo/comm3.txt&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="learning-rate">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global-bias">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bias-dist">
      <value value="&quot;uniform-symmetric&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="visuals?">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="LC_varylearningrate_nearby_phi60_deg10" repetitions="100" runMetricsEveryStep="false">
    <setup>setup-network-with-instigator-degree desired-instigator-degree</setup>
    <go>go</go>
    <timeLimit steps="10000"/>
    <exitCondition>converged?</exitCondition>
    <metric>cascaded?</metric>
    <metric>cascaded90?</metric>
    <metric>converged?</metric>
    <metric>round (mean [grammar] of nodes)</metric>
    <metric>mean [grammar] of nodes</metric>
    <metric>standard-deviation [grammar] of nodes</metric>
    <metric>min [grammar] of nodes</metric>
    <metric>max [grammar] of nodes</metric>
    <metric>count nodes with [ grammar &gt; 0.5 ]</metric>
    <metric>count nodes with [ grammar &gt; 0.9 ]</metric>
    <metric>initial-fraction-influenced-by-minority</metric>
    <metric>seed</metric>
    <metric>degree-of-instigator</metric>
    <metric>rank-of-instigator</metric>
    <metric>[closeness-centrality] of instigator</metric>
    <metric>[betweenness-centrality] of instigator</metric>
    <metric>[eigenvector-centrality] of instigator</metric>
    <metric>[clustering-coefficient] of instigator</metric>
    <metric>[avg-neighbor-degree] of instigator</metric>
    <metric>unique-filename</metric>
    <enumeratedValueSet variable="bias-target">
      <value value="&quot;nearby&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-node-degree">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="categoricalness-angle">
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="desired-instigator-degree">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-nodes">
      <value value="256"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-target-rank">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-target">
      <value value="&quot;influentials&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-start-with-G1">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="network-type">
      <value value="&quot;preferential&quot;"/>
    </enumeratedValueSet>
    <steppedValueSet variable="learning-rate" first="0" step="0.01" last="1"/>
    <enumeratedValueSet variable="global-bias">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bias-dist">
      <value value="&quot;uniform-symmetric&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="visuals?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bias-stdev-log10">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="make_representative_S_adoption_curves" repetitions="100" runMetricsEveryStep="true">
    <setup>setup new-seed</setup>
    <go>go</go>
    <timeLimit steps="10000"/>
    <exitCondition>converged?</exitCondition>
    <metric>mean [ grammar ] of nodes</metric>
    <metric>mean [ spoken-val ] of nodes</metric>
    <enumeratedValueSet variable="average-node-degree">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-target-rank">
      <value value="-1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="categoricalness-angle">
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bias-dist">
      <value value="&quot;uniform-symmetric&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global-bias">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-start-with-G1">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="learning-rate">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="visuals?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="network-type">
      <value value="&quot;preferential&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bias-target">
      <value value="&quot;nearby&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-nodes">
      <value value="256"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-target">
      <value value="&quot;none&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bias-stdev-log10">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="make_representative_S_adoption_curves_just_deg_4" repetitions="100" runMetricsEveryStep="true">
    <setup>setup-network-with-instigator-degree 4</setup>
    <go>go</go>
    <timeLimit steps="10000"/>
    <exitCondition>converged?</exitCondition>
    <metric>mean [ grammar ] of nodes</metric>
    <metric>mean [ spoken-val ] of nodes</metric>
    <metric>converged?</metric>
    <enumeratedValueSet variable="average-node-degree">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-target-rank">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="categoricalness-angle">
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bias-dist">
      <value value="&quot;uniform-symmetric&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global-bias">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-start-with-G1">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="learning-rate">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="visuals?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="network-type">
      <value value="&quot;preferential&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bias-target">
      <value value="&quot;nearby&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-nodes">
      <value value="256"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-target">
      <value value="&quot;none&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bias-stdev-log10">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="more_adoption_curves_supplement_nearby" repetitions="100" runMetricsEveryStep="true">
    <setup>setup-network-with-instigator-degree desired-instigator-degree</setup>
    <go>go</go>
    <timeLimit steps="10000"/>
    <exitCondition>converged?</exitCondition>
    <metric>mean [ grammar ] of nodes</metric>
    <metric>mean [ spoken-val ] of nodes</metric>
    <enumeratedValueSet variable="average-node-degree">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-target-rank">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bias-dist">
      <value value="&quot;uniform-symmetric&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global-bias">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-start-with-G1">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="learning-rate">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="visuals?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="network-type">
      <value value="&quot;preferential&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bias-target">
      <value value="&quot;nearby&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-nodes">
      <value value="256"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-target">
      <value value="&quot;none&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bias-stdev-log10">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="desired-instigator-degree">
      <value value="2"/>
      <value value="4"/>
      <value value="10"/>
      <value value="25"/>
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="categoricalness-angle">
      <value value="45"/>
      <value value="50"/>
      <value value="60"/>
      <value value="70"/>
      <value value="80"/>
      <value value="90"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="more_adoption_curves_supplement_inf" repetitions="100" runMetricsEveryStep="true">
    <setup>setup-network-with-instigator-degree desired-instigator-degree</setup>
    <go>go</go>
    <timeLimit steps="10000"/>
    <exitCondition>converged?</exitCondition>
    <metric>mean [ grammar ] of nodes</metric>
    <metric>mean [ spoken-val ] of nodes</metric>
    <enumeratedValueSet variable="average-node-degree">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-target-rank">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bias-dist">
      <value value="&quot;uniform-symmetric&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global-bias">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-start-with-G1">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="learning-rate">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="visuals?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="network-type">
      <value value="&quot;preferential&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bias-target">
      <value value="&quot;influentials&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-nodes">
      <value value="256"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-target">
      <value value="&quot;none&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bias-stdev-log10">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="desired-instigator-degree">
      <value value="2"/>
      <value value="4"/>
      <value value="10"/>
      <value value="25"/>
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="categoricalness-angle">
      <value value="45"/>
      <value value="50"/>
      <value value="60"/>
      <value value="70"/>
      <value value="80"/>
      <value value="90"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="more_adoption_curves_supplement_random" repetitions="100" runMetricsEveryStep="true">
    <setup>setup-network-with-instigator-degree desired-instigator-degree</setup>
    <go>go</go>
    <timeLimit steps="10000"/>
    <exitCondition>converged?</exitCondition>
    <metric>mean [ grammar ] of nodes</metric>
    <metric>mean [ spoken-val ] of nodes</metric>
    <enumeratedValueSet variable="average-node-degree">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-target-rank">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bias-dist">
      <value value="&quot;uniform-symmetric&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global-bias">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-start-with-G1">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="learning-rate">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="visuals?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="network-type">
      <value value="&quot;preferential&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bias-target">
      <value value="&quot;none&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-nodes">
      <value value="256"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-target">
      <value value="&quot;none&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bias-stdev-log10">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="desired-instigator-degree">
      <value value="2"/>
      <value value="4"/>
      <value value="10"/>
      <value value="25"/>
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="categoricalness-angle">
      <value value="45"/>
      <value value="50"/>
      <value value="60"/>
      <value value="70"/>
      <value value="80"/>
      <value value="90"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="TEMP" repetitions="1" runMetricsEveryStep="true">
    <setup>setup-network-with-instigator-degree desired-instigator-degree</setup>
    <go>go</go>
    <timeLimit steps="10000"/>
    <exitCondition>converged?</exitCondition>
    <metric>mean [ grammar ] of nodes</metric>
    <metric>mean [ spoken-val ] of nodes</metric>
    <enumeratedValueSet variable="average-node-degree">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-target-rank">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bias-dist">
      <value value="&quot;uniform-symmetric&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global-bias">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-start-with-G1">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="learning-rate">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="visuals?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="network-type">
      <value value="&quot;preferential&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bias-target">
      <value value="&quot;nearby&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-nodes">
      <value value="256"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-target">
      <value value="&quot;none&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bias-stdev-log10">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="desired-instigator-degree">
      <value value="2"/>
      <value value="4"/>
      <value value="10"/>
      <value value="25"/>
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="categoricalness-angle">
      <value value="45"/>
      <value value="50"/>
      <value value="60"/>
      <value value="70"/>
      <value value="80"/>
      <value value="90"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
1
@#$#@#$#@
