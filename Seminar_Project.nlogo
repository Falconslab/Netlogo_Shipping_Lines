; use extention
extensions [ gis ]

;declaration of global variables
globals [
  countries-dataset
  should-draw-country-labels
  isBlocked
  waiting
  blockageLength
  waitlength
  cost
  cost2
  diverted
  Arrived?
  passcount
]

;declare breeds
breed [country-labels country-label]
breed [ships ship]
breed [ports port]
breed [waypoints waypoint]

; setup method draws countries, spawns ports and waypoints and the links inbetween each
to setup
  clear-all
  ; Load the countries dataset
  set countries-dataset gis:load-dataset "data/countries.shp"
  ;set cities-dataset gis:load-dataset "data/cities.shp"
  ; Set the world envelope to the countries dataset's envelope
  gis:set-world-envelope (gis:envelope-of countries-dataset)

  ; Check setting restricitons and raise an error
  if freeatday < blockedatday [
    error "The blockade needs to happen before it can be lifted"
    ]
  if blockedatday = 16 or blockedatday = 15 [
    error "The blockage cant be happening while the vessle is in the canal"
  ]


  ; call necessary functions
  draw-countries
  spawn-ports
  spawn-waypoints
  spawn-lanes
  connect-ports

  ; Set variables

  ; 0 = false 1 = true
  set isBlocked  0
  set waiting 0
  set diverted 0

  set passcount 0

  decide-wait-length
  decide-blockage-length
  set cost 0
  set cost2 0


  ;clear and reset plots
  clear-all-plots
  set-current-plot "CostIndex 2"
  plot-pen-up
  set-current-plot "Costindex"

  reset-ticks

end

to go
  ;Check if a Ship exists else remind user to spawn new ship
    ifelse count ships = 0 [
    print "Please spawn new Ship"
  ][

  ;Stop after two runs
  if passcount = 2[
    stop
  ]

  ;Error handling
  if passcount = 99[

    plot-pen-up
    set-current-plot "CostIndex 2"
    plot-pen-down
    clear-plot
    update-plots
    set passcount 1
  ]


  ; Calculate costs and advance tick depending on current run iteration
  if passcount = 0[
    set cost cost + costperday
    tick
  ]
    if passcount = 1[
    set cost2 cost2 + costperday
    tick
  ]

    if passcount = 0[
    set cost cost + costperday
    tick
  ]
    if passcount = 1[
    set cost2 cost2 + costperday
    tick
  ]

  ;  Set Canal to blocked if requirements are met, set color to yellow and delete not used links to prevent ship from taking the wrong course
  ifelse ((ticks >= blockedatday) and (ticks < freeatday))[
    set isBlocked 1
    ]
  [
        set isBlocked 0
    ask waypoint 9[
      set color yellow
      ]
    if(diverted = 0)[
      ask waypoint 8[
        create-link-with waypoint 7
        create-link-with waypoint 9[
          ask links [
            set color red
            set thickness 1
          ]
        ]
      ]
    ]
   ]

  ;reduce blocking length
  if isBlocked = 1 [
    set blockageLength  blockageLength - 1
    ask waypoint 9[
      set color red
      ]
    ask waypoint 8[
      ask my-links[die]
    ]
  ]




   ; if ship is in front of the canal check whether it needs to wait or follow the diversion line
    ask ships[
      if xcor = 50 and ycor = 15 and isBlocked = 1 and waiting = 1[
         set waitlength waitlength - 2
         if waitlength <= 0[
           set waiting 0
         ]
         stop
      ]
      ifelse xcor = 50 and ycor = 15 and isBlocked = 1 and waiting = 0[
        plot-diversion
        follow-line
      ]
      [
        follow-line
      ]
    ]

  ; Check if ship arrived at its destination port
  check-if-arrived
  ]
end



; Uses Gis to draw the countries
to draw-countries
  gis:set-drawing-color green
  gis:draw countries-dataset 1
end

; Spawn start and destination port
to spawn-ports

  create-ports 1[
    set xcor 5
    set ycor 50
    set shape "crate"
    set size 5
    set color pink
  ]
  create-ports 1[
    set xcor 99
    set ycor 22
    set shape "crate"
    set size 5
    set color pink
  ]
end


; Spawn waypoint flags
to spawn-waypoints
  ;China to Eritrea
  create-waypoints 1 [
    set xcor 100
    set ycor 16
    set shape "flag"
    set color yellow
    set size 3
  ]
  create-waypoints 1 [
    set xcor 96
    set ycor 6
    set shape "flag"
    set color yellow
    set size 3
  ]
  create-waypoints 1 [
    set xcor 88
    set ycor 10
    set shape "flag"
    set color yellow
    set size 3
  ]
  create-waypoints 1 [
    set xcor 77
    set ycor 7
    set shape "flag"
    set color yellow
    set size 3
  ]
  create-waypoints 1 [
    set xcor 65
    set ycor 11
    set shape "flag"
    set color yellow
    set size 3
  ]
  create-waypoints 1 [
    set xcor 50
    set ycor 15
    set shape "flag"
    set color yellow
    set size 3
  ]
  create-waypoints 1 [
    set xcor 37
    set ycor 19
    set shape "flag"
    set color yellow
    set size 3
  ]

  ;Suez to Gibralta
  create-waypoints 1 [
    set xcor 31
    set ycor 31
    set shape "triangle 2"
    set color yellow
    set size 5
  ]
  create-waypoints 1 [
    set xcor 19
    set ycor 33
    set shape "flag"
    set color yellow
    set size 3
  ]
  create-waypoints 1 [
    set xcor 10
    set ycor 38
    set shape "flag"
    set color yellow
    set size 3
  ]
  create-waypoints 1 [
    set xcor -3
    set ycor 37
    set shape "flag"
    set color yellow
    set size 3
  ]

  ;Africa to Portugal
  create-waypoints 1 [
    set xcor 44
    set ycor 5
    set shape "flag"
    set color yellow
    set size 3
  ]
  create-waypoints 1 [
    set xcor 38
    set ycor -4
    set shape "flag"
    set color yellow
    set size 3
  ]
  create-waypoints 1 [
    set xcor 37
    set ycor -12
    set shape "flag"
    set color yellow
    set size 3
  ]
  create-waypoints 1 [
    set xcor 34
    set ycor -18
    set shape "flag"
    set color yellow
    set size 3
  ]
  create-waypoints 1 [
    set xcor 28
    set ycor -26
    set shape "flag"
    set color yellow
    set size 3
  ]
  create-waypoints 1 [
    set xcor 19
    set ycor -29
    set shape "flag"
    set color yellow
    set size 3
  ]
  create-waypoints 1 [
    set xcor 10
    set ycor -21
    set shape "flag"
    set color yellow
    set size 3
  ]create-waypoints 1 [
    set xcor -3
    set ycor -13
    set shape "flag"
    set color yellow
    set size 3
  ]
  create-waypoints 1 [
    set xcor -13
    set ycor -1
    set shape "flag"
    set color yellow
    set size 3
  ]
  create-waypoints 1 [
    set xcor -18
    set ycor 12
    set shape "flag"
    set color yellow
    set size 3
  ]
  create-waypoints 1 [
    set xcor -18
    set ycor 25
    set shape "flag"
    set color yellow
    set size 3
  ]




  ; Coast of Portugal
  create-waypoints 1 [
    set xcor -13
    set ycor 37
    set shape "flag"
    set color yellow
    set size 3
  ]
  create-waypoints 1 [
    set xcor -8
    set ycor 45
    set shape "flag"
    set color yellow
    set size 3
  ]
  create-waypoints 1 [
    set xcor -1
    set ycor 48
    set shape "flag"
    set color yellow
    set size 3
  ]
end



; Set links between waypoints
to spawn-lanes
  let current-waypoints-count  0

  ask waypoint 2[
    repeat 5[
      let current-waypoints  waypoint (who + current-waypoints-count)
      let next-waypoints waypoint (who + 1 + current-waypoints-count)
      set current-waypoints-count current-waypoints-count + 1
      if is-turtle? next-waypoints [
        ask current-waypoints [
          create-link-with next-waypoints
          ask links [
            set color red
            set thickness 1
          ]
        ]
      ]
    ]
  ]




  ask waypoint 2[
    repeat 5[
      let current-waypoints  waypoint (who + current-waypoints-count)
      let next-waypoints waypoint (who + 1 + current-waypoints-count)
      set current-waypoints-count current-waypoints-count + 1
      if is-turtle? next-waypoints [
        ask current-waypoints [
          create-link-with next-waypoints
          ask links [
            set color red
            set thickness 1
          ]
        ]
      ]
    ]

    let current-waypoints waypoint (12)
    let next-waypoints waypoint (24)
    if is-turtle? next-waypoints [
      ask current-waypoints [
        create-link-with next-waypoints
        ask links [
          set color red
          set thickness 1
        ]
      ]
    ]
  ]




  ask waypoint 24[
    set current-waypoints-count 0
    repeat 3[
      let current-waypoints  waypoint (who + current-waypoints-count)
      let next-waypoints waypoint (who + 1 + current-waypoints-count)
      set current-waypoints-count current-waypoints-count + 1
      if is-turtle? next-waypoints [
        ask current-waypoints [
          create-link-with next-waypoints
          ask links [
            set color red
            set thickness 1
          ]
        ]
      ]
    ]
  ]

end


; Set new links between the waypoints if the diversion route is taken
to plot-diversion
  set diverted 1
  ask waypoint 10 [ask my-links[die]]
  ask waypoint 12 [ask my-links[die]]

  let current-waypoints-count  0

  ask waypoint 7[
    create-link-with waypoint 13[
      ask links [
        set color red
        set thickness 1
      ]
    ]
  ]

;connect waypoints from waypoint 13 on
  ask waypoint 13[
    repeat 11[
      let current-waypoints  waypoint (who + current-waypoints-count)
      let next-waypoints waypoint (who + 1 + current-waypoints-count)
      set current-waypoints-count current-waypoints-count + 1
      if is-turtle? next-waypoints [
        ask current-waypoints [
          create-link-with next-waypoints
          ask links [
            set color red
            set thickness 1
            ]
        ]
      ]
    ]
  ]

end






; Connect 'port' agents with nearest 'waypoint' agent
to connect-ports
  ask port 0[
    create-link-with waypoint 26
      ask links [
        set color red
        set thickness 1
      ]
    ]


  ask port 1[
    create-link-with waypoint 2
    ask links [
      set color red
      set thickness 1
    ]
  ]


end


; spawns ship agent and sets wait and blockage length for the next run
to spawn-ships

  if count ships = 0
  [
    create-ships 1[
      set xcor 99
      set ycor 22
      set shape "containership"
      set size 10
    ]
    decide-wait-length
  decide-blockage-length
  ]
end


;caluclate waiting lenght depending on given settings
to decide-wait-length
  set waitlength waitmin + (random (waitmax - waitmin))
end

;calculate blocking length depending on given settings
to decide-blockage-length
  set blockageLength freeatday - blockedatday
  set waiting 1
end

; function for ship to follow the waypoints to its destination
to follow-line

  ask ships[
    ;if ship is at the start port move to first waypoint
    ifelse xcor = 99 and ycor = 22 [
      move-to waypoint 2
    ]
    ;else move to the closest waypoint with which a connections exists but was not visited already
    [
    let current-waypoint-cor [ (list xcor ycor)] of waypoints in-radius 3
    let current-waypoint waypoints with [xcor = first item 0 current-waypoint-cor and ycor = last item 0 current-waypoint-cor ]
    let curr-waypoint  one-of current-waypoint
    let destination-waypoint-end2 [[ (list xcor ycor)] of end2] of links with [end1 = curr-waypoint]

    ;if no additional waypoint is available the ship either reached the end or an error has occured
    ifelse destination-waypoint-end2 = [] [
      ifelse xcor = -1 and ycor = 48 [
          move-to port 0
          set Arrived? true
        ]
        [
          error "No available Waypoint!"
        ]
      ]
      [
        let dest-port one-of waypoints with [xcor = first item 0 destination-waypoint-end2 and ycor = last item 0 destination-waypoint-end2 ]
        move-to dest-port
      ]
    ]

  ]


end



to check-if-arrived
    if Arrived? = true[
    Ask ships[
      die
    ]
    reset-ticks
    set Arrived? false
    set diverted 0
    let waypointcount 2
    repeat 25[
      ask waypoint waypointcount[
        ask my-links[
          die
        ]
      ]
      set waypointcount waypointcount + 1
    ]

    spawn-lanes
    connect-ports

    set isBlocked  0
    set waiting 0
    set diverted 0

    ifelse(passcount = 0)[
      set cost cost - POT
      update-plots
      set passcount 99
    ]
    [
      set cost2 cost2 - POT
      update-plots
      set passcount 2
    ]

  ]
end




to draw/clear-country-labels
  if-else should-draw-country-labels = 1 [
    set should-draw-country-labels 0
    ask country-labels [ die ]
  ] [
    set should-draw-country-labels 1
    foreach gis:feature-list-of countries-dataset [ this-country-vector-feature ->
      let centroid gis:location-of gis:centroid-of this-country-vector-feature
      ; centroid will be an empty list if it lies outside the bounds
      ; of the current NetLogo world, as defined by our current GIS
      ; coordinate transformation
      if not empty? centroid
      [ create-country-labels 1
        [ set xcor item 0 centroid
          set ycor item 1 centroid
          set size 0
          set label gis:property-value this-country-vector-feature "CNTRY_NAME"
        ]
      ]
    ]
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
1272
580
-1
-1
3.2835
1
10
1
1
1
0
1
1
1
-160
160
-85
85
0
0
1
ticks
30.0

BUTTON
67
10
130
43
NIL
setup
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
53
457
145
490
NIL
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

SLIDER
15
110
187
143
costperday
costperday
0
30000
15000.0
1000
1
NIL
HORIZONTAL

SLIDER
15
151
187
184
blockedatday
blockedatday
0
11
0.0
1
1
NIL
HORIZONTAL

SLIDER
16
192
188
225
freeatday
freeatday
0
50
41.0
1
1
NIL
HORIZONTAL

SLIDER
16
234
188
267
waitmax
waitmax
0
100
0.0
1
1
NIL
HORIZONTAL

PLOT
1285
12
1865
233
CostIndex
time
cost
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot cost"

SLIDER
17
275
189
308
waitmin
waitmin
0
100
0.0
1
1
NIL
HORIZONTAL

SLIDER
15
68
187
101
POT
POT
0
6000000
540000.0
10000
1
NIL
HORIZONTAL

PLOT
1285
245
1864
464
CostIndex 2
time
cost
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot cost2"

BUTTON
53
506
153
539
NIL
spawn-ships
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
1385
492
1442
537
Profit 1
cost * -1
0
1
11

MONITOR
1719
494
1776
539
Profit 2
cost2 * -1
0
1
11

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
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

containership
false
9
Rectangle -13840069 true false 60 180 150 210
Rectangle -7500403 true false 225 270 240 285
Rectangle -7500403 true false 240 255 255 270
Rectangle -7500403 true false 255 240 270 255
Rectangle -7500403 true false 60 270 225 285
Rectangle -7500403 true false 45 255 60 270
Rectangle -7500403 true false 30 240 45 255
Rectangle -7500403 true false 255 210 270 240
Rectangle -7500403 true false 30 210 45 240
Rectangle -7500403 true false 45 210 255 225
Rectangle -7500403 true false 240 135 255 210
Rectangle -7500403 true false 195 135 240 150
Rectangle -7500403 true false 195 150 210 210
Rectangle -11221820 true false 210 150 225 165
Rectangle -11221820 true false 210 165 225 180
Rectangle -7500403 true false 225 150 240 210
Rectangle -7500403 true false 210 195 225 210
Rectangle -7500403 true false 210 180 225 195
Rectangle -7500403 true false 30 195 90 210
Rectangle -7500403 true false 30 180 75 195
Rectangle -2674135 true false 60 150 150 180
Rectangle -10899396 true false 180 240 255 255
Rectangle -7500403 true false 45 225 255 240
Rectangle -7500403 true false 45 240 180 255
Rectangle -7500403 true false 60 255 240 270
Rectangle -1 true false 120 180 150 195
Rectangle -1184463 true false 120 150 150 165

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

crate
false
0
Rectangle -7500403 true true 45 45 255 255
Rectangle -16777216 false false 45 45 255 255
Rectangle -16777216 false false 60 60 240 240
Line -16777216 false 180 60 180 240
Line -16777216 false 150 60 150 240
Line -16777216 false 120 60 120 240
Line -16777216 false 210 60 210 240
Line -16777216 false 90 60 90 240
Polygon -7500403 true true 75 240 240 75 240 60 225 60 60 225 60 240
Polygon -16777216 false false 60 225 60 240 75 240 240 75 240 60 225 60

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

sailboat side
false
0
Line -16777216 false 0 240 120 210
Polygon -7500403 true true 0 239 270 254 270 269 240 284 225 299 60 299 15 254
Polygon -1 true false 15 240 30 195 75 120 105 90 105 225
Polygon -1 true false 135 75 165 180 150 240 255 240 285 225 255 150 210 105
Line -16777216 false 105 90 120 60
Line -16777216 false 120 45 120 240
Line -16777216 false 150 240 120 240
Line -16777216 false 135 75 120 60
Polygon -7500403 true true 120 60 75 45 120 30
Polygon -16777216 false false 105 90 75 120 30 195 15 240 105 225
Polygon -16777216 false false 135 75 165 180 150 240 255 240 285 225 255 150 210 105
Polygon -16777216 false false 0 239 60 299 225 299 240 284 270 269 270 254

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

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

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.3.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
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
0
@#$#@#$#@
