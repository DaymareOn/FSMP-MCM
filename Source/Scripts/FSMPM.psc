Scriptname FSMPM extends SKI_ConfigBase
{Splash-only remnant of the former FSMP MCM.
FSMP 4 moved all configuration to the SKSE Menu Framework menu, but Skyrim destroys a
save-game when an esp it references is removed. Players updating mid-playthrough from
FSMP 3.x therefore keep the esp, and this script reduces its menu to a single splash
page: the FSMP logo and a line pointing to the new menu. Nothing is configured here.}

FSMPMPlayerScript Property FSMPM_PlayerScript Auto
{Filled by "FSMPM - The FSMP MCM.esp". Kept so the esp finds the property on existing saves.}

; Script version. Above the last full MCM version (310), so a save made with the full
; MCM runs OnVersionUpdate() exactly once when it first loads with this stub.
int Function GetVersion()
	Return 400
EndFunction

; First registration of the menu on a save that never had the full MCM.
Event OnConfigInit()
	initConfig()
EndEvent

; Runs once on saves updating from the full MCM. The full MCM kept a JContainers map
; alive in the co-save (retained with the tag "FSMP MCM"); release it so it does not
; stay in the save forever. JContainers was a hard requirement of the full MCM, so it
; is installed on any save where this update path runs.
event OnVersionUpdate(int NewVersion)
	if (CurrentVersion > 0 && CurrentVersion < 400)
		JValue.releaseObjectsWithTag("FSMP MCM")
	endif
endEvent

; On every game load, re-apply the stub state: a save made with the full MCM still
; carries the full menu's page list in its stored Pages array until we overwrite it.
event OnGameReload()
	parent.OnGameReload()
	initConfig()
endEvent

; Names the menu and removes all pages. Assigning a never-initialized array sets Pages
; to None, which SkyUI displays as a menu without a page list: only the splash page.
function initConfig()
	ModName = "FSMP"
	String[] noPages
	Pages = noPages
endfunction

; The single splash page: the FSMP logo, with the pointer to the new menu in the title
; bar above it. The menu panel hides the whole option list while custom content is
; displayed (ConfigPanel.loadCustomContent sets _optionsList._visible = false), so the
; title bar is the only text that can appear together with the logo.
Event OnPageReset(String aPage)
	SetTitleText("Use the SKSE Menu Framework menu")
	LoadCustomContent("FSMP/Logo.dds")
EndEvent
