extends Node

var debug_stats = 0
var debug_menu = 0

#Player Variables
var player = 0
var player_id = [0, 1]
var player_life = [140, 280]
var player_weap = [0, 0]
var lives = 2
var bolts = 0
var etanks = 0
var mtanks = 0

#Global Level/Option Flags
var icey = false
var low_grav = false
var sound = 100
var music = 100
var res = 3
var f_screen = false
var quick_swap = false

#Level/Continue Point IDs
var level_id = 0
var cont_id = 0
var boss = false

var temp_items = {}
#Update list with permanent items.
var perma_items = {
	'ebalancer' : true
	}

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
var rp_coil = [true, 140, 140]
var rp_jet = [true, 140, 140]
var weapon1 = [true, 140, 140]
var weapon2 = [true, 140, 140]
var weapon3 = [true, 140, 140]
var weapon4 = [true, 140, 140]
var weapon5 = [true, 140, 140]
var weapon6 = [true, 140, 140]
var weapon7 = [true, 140, 140]
var weapon8 = [true, 140, 140]
var beat = [true, 140, 140]
var tango = [true, 140, 140]
var reggae = [true, 140, 140]

#Color values. Based on the realnes.aseprite palette included in the file heirarchy.

#Colors to be replaced using the shader.
var t_color1 = Color('#0f0f0f')
var t_color2 = Color('#414141')
var t_color3 = Color('#737373')
var t_color4 = Color('#00ff1b')

#Transparent color
var trans = Color('#00000000')

#Some colors are darker than others. The higher the number, the darker that particular shade is.
var grey3 = Color('#2c2c2c')
var grey2 = Color('#606060')
var grey1 = Color('#788084')
var grey0 = Color('#bcc0c4')

var turq3 = Color('#004058')
var turq2 = Color('#008894')
var turq1 = Color('#00e8e4')
var turq0 = Color('#00f8fc')

var jungle3 = Color('#005800')
var jungle2 = Color('#00a848')
var jungle1 = Color('#58f89c')
var jungle0 = Color('#b0f0d8')

var green3 = Color('#006800')
var green2 = Color('#00a800')
var green1 = Color('#58d858')
var green0 = Color('#b8f878')

var lime3 = Color('#007800')
var lime2 = Color('#00b800')
var lime1 = Color('#bcf818')
var lime0 = Color('#dcf878')

var yellow3 = Color('#503000')
var yellow2 = Color('#ac8000')
var yellow1 = Color('#fcb800')
var yellow0 = Color('#fcd884')

var brown3 = Color('#8c1800')
var brown2 = Color('#e46018')
var brown1 = Color('#fca048')
var brown0 = Color('#fce0b4')

var red3 = Color('#ac1000')
var red2 = Color('#fc3800')
var red1 = Color('#fc7858')
var red0 = Color('#f4d0b4')

var pink3 = Color('#ac0028')
var pink2 = Color('#e40060')
var pink1 = Color('#fc589c')
var pink0 = Color('#f4c0e0')

var magenta3 = Color('#94008c')
var magenta2 = Color('#dc00d4')
var magenta1 = Color('#fc78fc')
var magenta0 = Color('#fcb8fc')

var purple3 = Color('#4028c4')
var purple2 = Color('#6848fc')
var purple1 = Color('#9c78fc')
var purple0 = Color('#dcb8fc')

var rblue3 = Color('#0000c4')
var rblue2 = Color('#0088fc')
var rblue1 = Color('#6888fc')
var rblue0 = Color('#bcb8fc')

var blue3 = Color('#0000fc')
var blue2 = Color('#0078fc')
var blue1 = Color('#38c0fc')
var blue0 = Color('#a4e8fc')

var black = Color('#000000')
var white = Color('#fcf8fc')