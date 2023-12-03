Scriptname FSMPMPlayerScript extends ReferenceAlias  

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
