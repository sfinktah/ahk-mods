;
; AutoHotkey Macro
;
; Version 1.1
;
; What's new
;
; *1.1*
;     Added ability to drive car into LSC (there's one that is aligned the same as
;     as the target garage).  To get the alignment correct, copy the XML segment below
;     to the bottom of your SavedMapLocations.xml (before the last line).
;
;     Hotkey: Shift+Alt+L
;	
; *1.0*
; Steal a car, drive it into garage, and spawn during animation
;
; Hotkey: Control+Shift+T
;
; Requirements: 
;   * A south-east facing garage (Unit 76 Greenwhich Parkway, South Los Santos)
;   * Two "Teleport Favourite" destinations (added so they are the last two favourites)
;      1. A location in front of the garage, but far enough not to trigger entry
;      2. A location at the start of a stretch of straight road that heads South-West
;   * Spawn Settings (all options enabled, alter to taste)
;
; My last three entries from menyooStuff/SavedMapLocations.xml:
;
;	<Loc name="LSC - Aligned">
;		<X>-1135.99683</X>
;		<Y>-1982.42749</Y>
;		<Z>12.5638161</Z>
;	</Loc>
;	<Loc name="T3">
;		<X>-1081.10559</X>
;		<Y>-2226.67554</Y>
;		<Z>12.6672812</Z>
;	</Loc>
;	<Loc name="T2">
;		<X>-864.96875</X>
;		<Y>-2055.76855</Y>
;		<Z>8.62090492</Z>
;	</Loc>
;
; Internal Process for stealing car
;   * Teleport into Closest Vehicle
;   * Teleport to a stretch of road
;   * Set a waypoint South-West of current location
;   * Auto Drive to waypoint to align car
;   * Teleport to location outside garage (now aligned for entry)
;   * Drive Forwards
;   * Invoke Vehicle Spawn while animation plays
;

#SingleInstance force
#NoEnv  			; Recommended for performance and compatibility with future AutoHotkey releases.
SetWorkingDir %A_ScriptDir%  	; Ensures a consistent starting directory.
SendMode Event ; This is the default mode anyway

; from https://autohotkey.com/board/topic/102689-help-run-as-administrator-run-as-administrator-script-inside-current-script/
if !A_IsAdmin 
{
	try  Run *RunAs "%A_ScriptFullPath%"
	catch {
		MsgBox This script probably needs to be Run As Administrator
	}
}

~F5::
SoundBeep, 440, 100
Reload
Return

#IfWinActive ahk_exe GTA5.exe ; Disables hotkeys when alt-tabbed or GTA is closed.

; ## Menyoo (Main Menu) Command List

Settings:
	Send {Down}
MiscOptions:
	Send {Down}
LightingOptions:
	Send {Down}
ObjectSpooner:
	Send {Down}
TimeOptions:
	Send {Down}
WeatherOptions:
	Send {Down}
WeaponOptions:
	Send {Down}
TeleportOptions:
	Send {Down}
VehicleOptions:
	Send {Down}
PlayerOptions:
	Send {Down}
GeneralOnlineOptions:
	Send {Down}
AllOnlinePlayers:
	Send {Down}
OnlinePlayers:
	; This is the top option, and doesn't need a {Down} to get to
	; Send {Down}
	Send {Enter} ; Send Enter to finish selection
return


; Car Stealing!
; Trigger by pressing Control + Shift + T
^+t::

; Steal nearest car
; SetKeyDelay, 250, -1 ; Default Key Delay (slowed down for test/demo)
Gosub MenyooPrep
Gosub VehicleOptions
; Send {Down 1} ; If we were already in a car, we'd need to skip over Repair
Send {Enter} ; Teleport Into Closest Vehicle
Sleep 1000

; ; Clear possible previous occupant
; Gosub MenyooPrep
; Gosub MiscOptions
; Send {Up 5}{Enter} ; Clear Area
; Send {Enter}15{Enter} ; Range To Clear "15"
; Send {Down 2}{Enter} ; Peds

Sleep 3000 ; A bit more time incase the car is hard to start


Gosub AlignCar
Sleep 1000 ; Theatrical pause

; Teleport to Garage Entry
Gosub TeleportFavourites
Send {Up}{Up}{Enter}{F8}
Sleep 1000

; Drive forward 
SetKeyDelay, -1, 1500 ; 1.5 seconds of forward driving
Send W
SetKeyDelay, 25, 5 ; Need to speed things up for spawning

; Spawn car during animation
Gosub MenyooPrep
Gosub VehicleOptions
Send {Down 2}{Enter} ; Vehicle Spawner
Send {Down 4}{Enter} ; Super
Send {Down 7}{Enter} ; Sultan RS

return

; Driving into LSC!

+!L::
SetKeyDelay, 25, 5 ; Need to speed things up for spawning
Gosub AlignCar
Sleep 3000 

; Teleport to LSC
SetKeyDelay, 25, 5 ; Need to speed things up for spawning
Gosub TeleportFavourites
Send {Up}{Up}{Up}{Enter}{F8}
; Sleep 500

; Drive forward 
SetKeyDelay, 300, 300 ; Attempt to drive in slowly for a bit
Send WWWWWWW
SetKeyDelay, -1, 2500 ; 1.5 seconds of forward driving at max
Send W
SetKeyDelay, 25, 5 ; Reset delays to something normal

; We should be in LSC's menu now.
return


; Helper Functions
TeleportPrep:
Gosub MenyooPrep
Gosub TeleportOptions
return

MenyooPrep:
SoundBeep, 750, 100
setkeydelay, KeySendDelay, KeyPressDuration 
Send {Backspace 10}{Enter}{F8}
Send {Backspace 10}{F8}
sleep, IntMenuDelay
return

MenyooMiscSettings:
Send {Up 2}{Enter}
sleep, IntMenuDelay
return

MenyooVehicleOptions:
Send {Down 4}{Enter}
sleep, IntMenuDelay
return

TeleportFavourites:
Gosub TeleportPrep
Send {Up}{Enter}
return

AlignCar:
; Teleport to start of road
Gosub TeleportFavourites
Send {Up}{Enter}{F8}

; Open Map
SetKeyDelay, 500, -1
Send {Escape}
Send {Enter}

; Zoom In 
SetKeyDelay, 25, 2000
Send {PgUp}

; Move Cursor South-West (Down + Left)
SetKeyDelay, 25, 500
Send S
Send A

; Set Waypoint
SetKeyDelay, 25, 25
Send {Enter}

; Exit Menu 
Send {Escape}{Escape}
Sleep 500

; Invoke AutoDrive
; SetKeyDelay, 250, -1 ; Default Key Delay (slowed down for test/demo)
SetKeyDelay, 25, 5 ; Need to speed things up for spawning
Gosub MenyooPrep
Gosub VehicleOptions
Send {Down 9}{Enter} ; AutoDrive
Send {Enter} ; Go To Waypoint

; Wait for car to arrive (may need to allow for U-Turn)
Sleep 5000 ; Can shorten or lengthen delay as required (milliseconds)
Send {F8} ; Close Menyoo (Not needed, more for visual indication)
return 
