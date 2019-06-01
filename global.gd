extends Node

var debug_stats = 0
var debug_menu = 0

#Player Variables
var player = 0
var player_id = [0, 0]
var player_life = [280, 280]
var player_weap = [0, 0]
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

#Master Weapon flags and energy. First number determines if the weapon has been acquired or not. rp_coil will always be set to true at the start of the game.
var rp_coil = [true, 280, 280]
var rp_jet = [false, 280, 280]
var weapon1 = [false, 280, 280]
var weapon2 = [false, 280, 280]
var weapon3 = [false, 280, 280]
var weapon4 = [false, 280, 280]
var weapon5 = [false, 280, 280]
var weapon6 = [false, 280, 280]
var weapon7 = [false, 280, 280]
var weapon8 = [false, 280, 280]
var beat = [false, 280, 280]
var tango = [false, 280, 280]
var reggae = [false, 280, 280]