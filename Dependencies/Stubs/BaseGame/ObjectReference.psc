; Minimal stub for CI builds
Scriptname ObjectReference extends Form Hidden

Function Disable(bool abFadOut = false) native
Function DisableNoWait(bool abFadOut = false) native
Function Enable(bool abFadIn = false) native
Function EnableNoWait(bool abFadIn = false) native
Function MoveTo(ObjectReference akTarget, float afXOffset = 0.0, float afYOffset = 0.0, float afZOffset = 0.0, bool abMatchRotation = true) native
Function Reset() native

Event OnActivate(ObjectReference akActionRef)
EndEvent

Event OnInit()
EndEvent
