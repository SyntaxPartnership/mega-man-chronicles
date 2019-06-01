extends Node

var debug_stats = 0
var debug_menu = 0

#Player Variables
var player = 0
var p1_id = 0
var p2_id = 0
var p1_life = 280
var p2_life = 280
var p1_weap = 0
var p2_weap = 0
var palette = [Color(000000), Color(000000), Color(000000)]

#Global Level Flags
var icey = false
var low_grav = false

#Level/Continue Point IDs
var level_id = 0
var cont_id = 0
var boss = false

#Stage Cleared Flags
var intro_clear = false
var boss1_clear = false
var boss2_clear = false
var boss3_clear = false
var boss4_clear = false
var boss5_clear = false
var boss6_clear = false
var boss7_clear = false
var boss8_clear = false
var wily1_clear = false
var wily2_clear = false
var wily3_clear = false
var wily4_clear = false

#Strider's location and health
var location = 0
var str_health = 280
var rescued = false

