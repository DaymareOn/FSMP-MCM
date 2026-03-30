; Minimal stub for CI builds
Scriptname Debug Hidden

Function MessageBox(string asMessageBoxText) native global
Function Notification(string asNotificationText) native global
Function Trace(string asTextToPrint, int aiSeverity = 0) native global
Function TraceStack(string asTextToPrint = "Tracing stack on request", int aiSeverity = 0) native global
bool Function TraceUser(string asUserLog, string asTextToPrint, int aiSeverity = 0) native global
