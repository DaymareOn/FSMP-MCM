Scriptname FSMPMPlayerScript extends ReferenceAlias  

;DayCharactersQuest Property CharactersQuest Auto

Event OnInit()
    Debug.Trace("FSMPM - Initing")
	Register()
EndEvent

Function Register()
    Debug.Trace("FSMPM - Registering")
EndFunction

Function Unregister()
    Debug.Trace("FSMPM - Unregistering")
EndFunction
