Scriptname FSMPM extends SKI_ConfigBase
import MiscUtil
import JsonUtil
import JMap

FSMPMPlayerScript Property FSMPM_PlayerScript Auto

int configMapId = 0
bool bSMPOn = true

string configFilePath = "Data/SKSE/Plugins/hdtSkinnedMeshConfigs/configs.xml"
string presetFolder = "Data/SKSE/Plugins/hdtSkinnedMeshConfigs/configsPresets"
String sLabelCommands = "Commands"
String sLabelLogs = "Logs"
String sLabelSimplification = "Simplification"
String sLabelQuality = "Performance"
String sLabelWind = "Wind"
String sLabelPresets = "Presets "; presets seems to be a lowercase papyrus keyword...
String sLabelClickMe = "Click me!"
String sLabelLoaded = "Loaded: "
String[] keys
String[] defaultValues
int[] presetsInt
string[] presetsFiles

int startIndex = 0
bool loadConfigDone = false; useless now from version 2

int Function GetVersion()
	Return 2
EndFunction

; #################################################################################################
; #################################################################################################
; Events 
; #################################################################################################
; #################################################################################################

Event OnConfigInit()
	; configMapId
	if (!JValue.isExists(1))
		configMapId = JMap.object()
		; We never release this object, we keep it in the savegame.
		JValue.retain(configMapId, "FSMP MCM")
	else
		configMapId = 1
	endif

	initConfig()
	loadConfigFile(configFilePath)
EndEvent

event OnVersionUpdate(int NewVersion)
endEvent

event OnGameReload()
	parent.OnGameReload() ; This calls OnConfigInit() and all necessary events to register the MCM, but only once during first install
	bSMPOn = true
	self.OnConfigInit()
endEvent

Event OnPageReset(String aPage)
	UnloadCustomContent()
	
	SetTitleText(aPage)
	SetCursorFillMode(TOP_TO_BOTTOM)
	SetCursorPosition(0)
	If (aPage == sLabelCommands)
		AddHeaderOption("Master switch")
		AddToggleOptionST("ToggleSMP", "smp on", bSMPOn)
		SetCursorPosition(1)
		AddHeaderOption("Console commands")
		AddTextOptionST("SMP", "smp ", sLabelClickMe)
		AddTextOptionST("SMPReset", "smp reset", sLabelClickMe)
		AddTextOptionST("SMPList", "smp list", sLabelClickMe)
		AddTextOptionST("SMPDetail", "smp detail", sLabelClickMe)
		AddTextOptionST("SMPDumptree", "smp dumptree", sLabelClickMe)
		AddTextOptionST("SMPQueryOverride", "smp QueryOverride", sLabelClickMe)
	ElseIf (aPage == sLabelSimplification)
		AddHeaderOption("Disabling some SMP")
		AddToggleOptionST("ToggleSMPHairWhenWigEquipped", "Disable SMP hair when there's a wig", JMap.getStr(configMapId, "disableSMPHairWhenWigEquipped", "") == "true")
		AddToggleOptionST("Toggle1stPersonViewPhysics", "No SMP for your PC when in 1st person view", JMap.getStr(configMapId, "disable1stPersonViewPhysics", "") == "true")
		;AddToggleOptionST("ToggleNPCFaceParts", "Enable NPC face parts", JMap.getStr(configMapId, "enableNPCFaceParts", "") == "true")
		AddEmptyOption()
		AddHeaderOption("Enabling nearest NPCs")
		AddSliderOptionST("SliderMinCullingDistance", "SMP is always on below this distance", JMap.getStr(configMapId, "minCullingDistance", 300) as float, "{0}")
		SetCursorPosition(1)
		AddHeaderOption("Disabling SMP NPCs")
		bool autoAdjust = JMap.getStr(configMapId, "autoAdjustMaxSkeletons", "") == "true"
		int autoAdjustOptionsFlag = 0
		if (!autoAdjust)
			autoAdjustOptionsFlag = 1
		endif
		AddToggleOptionST("ToggleAutoAdjustMaxSkeletons", "Auto adjust the max number of SMP NPCs", autoAdjust)
		AddSliderOptionST("SliderTimeFramePercentage", "Allowed percentage of frame time for SMP", JMap.getStr(configMapId, "percentageOfFrameTime", 30) as float, "{0}", autoAdjustOptionsFlag)
		AddSliderOptionST("SliderMaxSkeletons", "Maximum SMP NPC number", JMap.getStr(configMapId, "maximumActiveSkeletons", 40) as float, "{0}", autoAdjustOptionsFlag)
		AddSliderOptionST("SliderSampleSize", "Adjustment speed", JMap.getStr(configMapId, "sampleSize", 5) as float, "{0}", autoAdjustOptionsFlag)
	ElseIf (aPage == sLabelQuality)
		AddHeaderOption("Simulation quality")
		AddSliderOptionST("SliderNumIterations", "Simulation quality", JMap.getStr(configMapId, "numIterations", 16) as float)
		AddSliderOptionST("SliderGroupIterations", "Group simulation quality", JMap.getStr(configMapId, "groupIterations", 16) as float)
		AddToggleOptionST("ToggleGroupMLCP", "Enable a better simulation", JMap.getStr(configMapId, "groupEnableMLCP", "") == "true")
		AddSliderOptionST("SliderERP", "ERP ", JMap.getStr(configMapId, "erp", 0.2) as float, "{2}")
		AddEmptyOption()
		AddHeaderOption("Simulation frequency and slowdowns")
		AddToggleOptionST("ToggleRealTime", "Use your real time", JMap.getStr(configMapId, "useRealTime", "") == "true")
		AddSliderOptionST("SliderMinFPS", "Simulation frequency", JMap.getStr(configMapId, "min-fps", 60) as float)
		AddSliderOptionST("SliderMaxSubsteps", "Slowdowns adjustment", JMap.getStr(configMapId, "maxSubsteps", 2) as float)
		SetCursorPosition(1)
		AddHeaderOption("Limitations")
		bool clampRotations = JMap.getStr(configMapId, "clampRotations", "") == "true"
		int clampRotationsOptionsFlag = OPTION_FLAG_NONE
		int clampedResetsOptionFlag = OPTION_FLAG_NONE
		if (clampRotations)
			clampedResetsOptionFlag = OPTION_FLAG_DISABLED
		else
			clampRotationsOptionsFlag = OPTION_FLAG_DISABLED
		endif
		bool clampedResets = JMap.getStr(configMapId, "unclampedResets", "") == "true"
		int unclampedResetAngleOptionFlag = OPTION_FLAG_NONE
		if (!clampedResets || clampRotations)
			unclampedResetAngleOptionFlag = OPTION_FLAG_DISABLED
		endif
		AddToggleOptionST("ToggleClampRotations", "Limit rotations", clampRotations)
		AddSliderOptionST("SliderRotationSpeedLimit", "Rotation speed limit", JMap.getStr(configMapId, "rotationSpeedLimit", 10) as float, "{1}", clampRotationsOptionsFlag)
		AddToggleOptionST("ToggleClampedResets", "Reset SMP when rotation speed isn't limited", clampedResets, clampedResetsOptionFlag)
		AddSliderOptionST("SliderUnclampedResetAngle", "Angle at which the reset occurs", JMap.getStr(configMapId, "unclampedResetAngle", 120) as float, "{0}", unclampedResetAngleOptionFlag)
		AddEmptyOption()
		AddHeaderOption("CUDA")
		AddToggleOptionST("ToggleCuda", "Enable CUDA", JMap.getStr(configMapId, "enableCuda", "") == "true")
	ElseIf (aPage == sLabelWind)
		bool enableWind = JMap.getStr(configMapId, "enabled", "") == "true"
		int enableWindOptionsFlag = OPTION_FLAG_NONE
		if (!enableWind)
			enableWindOptionsFlag = OPTION_FLAG_DISABLED
		endif
		AddToggleOptionST("ToggleWind", "Enable FSMP-native wind", enableWind)
		AddSliderOptionST("SliderWindStrength", "Wind strength", JMap.getStr(configMapId, "windStrength", 2.0) as float, "{1}", enableWindOptionsFlag)
		AddSliderOptionST("SliderNoWindDistance", "Distance for no wind", JMap.getStr(configMapId, "distanceForNoWind", 50.0) as float, "{0}", enableWindOptionsFlag)
		AddSliderOptionST("SliderMaxWindDistance", "Distance for max wind", JMap.getStr(configMapId, "distanceForMaxWind", 2500.0) as float, "{0}", enableWindOptionsFlag)
	ElseIf (aPage == sLabelLogs)
		AddSliderOptionST("SliderLog", "Choose your log level", JMap.getStr(configMapId, "logLevel", 0) as float)
	ElseIf (aPage == sLabelPresets)
		AddHeaderOption("Load preset")
		presetsFiles = MiscUtil.FilesInFolder(presetFolder, "xml")
		string sCurrentConfig = MiscUtil.ReadFromFile(configFilePath)
		int index = 0
		While (index < presetsFiles.Length)
			string presetFile = presetsFiles[index]
			string sThatConfig = MiscUtil.ReadFromFile(presetFolder + "/" + presetFile)
			if (sThatConfig == sCurrentConfig)
				presetsInt[index] = AddTextOption(sLabelLoaded + presetFile, sLabelClickMe, OPTION_FLAG_DISABLED)
			else
				presetsInt[index] = AddTextOption(presetFile, sLabelClickMe, OPTION_FLAG_NONE)
			endif
			index += 1
		EndWhile
	Else
		SetTitleText("Faster Skinned Mesh Physics")
	EndIf
EndEvent

Event OnOptionSelect(int a_option)
	int presetFileIndex = 0
	int index = 0
	While (index < presetsInt.Length)
		if presetsInt[index] == a_option; found
			presetFileIndex = index
		endif
		; Can it happen that we don't find it?...
		index += 1
	EndWhile
	loadConfigFile(presetFolder + "/" + presetsFiles[presetFileIndex])
	ForcePageReset()
EndEvent

Event OnHighlight(int a_option)
	SetInfoText("Click on the preset, it takes several seconds")
EndEvent

; #################################################################################################
; #################################################################################################
; Functions
; #################################################################################################
; #################################################################################################

function initConfig()
	ModName = "FSMP"

	Pages = new String[8]
	Pages[0] = sLabelSimplification
	Pages[1] = sLabelQuality
	Pages[2] = sLabelWind
	Pages[3] = sLabelLogs
	Pages[4] = ""
	Pages[5] = sLabelCommands
	Pages[6] = ""
	Pages[7] = sLabelPresets

	keys = new String[25]
	keys[0] = "logLevel"; first serie
	keys[1] = "enableNPCFaceParts"; unused by FSMP...
	keys[2] = "disableSMPHairWhenWigEquipped"
	keys[3] = "clampRotations"
	keys[4] = "rotationSpeedLimit"
	keys[5] = "unclampedResets"
	keys[6] = "unclampedResetAngle"
	keys[7] = "useRealTime"
	keys[8] = "minCullingDistance"
	keys[9] = "autoAdjustMaxSkeletons"
	keys[10] = "maximumActiveSkeletons"
	keys[11] = "percentageOfFrameTime"
	keys[12] = "sampleSize"
	keys[13] = "disable1stPersonViewPhysics"
	keys[14] = "enableCuda"
	keys[15] = "numIterations"; second serie
	keys[16] = "groupIterations"
	keys[17] = "groupEnableMLCP"
	keys[18] = "erp"
	keys[19] = "min-fps"
	keys[20] = "maxSubSteps"
	keys[21] = "enabled"; third serie
	keys[22] = "windStrength"
	keys[23] = "distanceForNoWind"
	keys[24] = "distanceForMaxWind"

	defaultValues = new String[25]
	defaultValues[0] = "0"; first serie
	defaultValues[1] = "true"; unused by FSMP...
	defaultValues[2] = "true"
	defaultValues[3] = "true"
	defaultValues[4] = "10"
	defaultValues[5] = "true"
	defaultValues[6] = "130"
	defaultValues[7] = "true"
	defaultValues[8] = "300"
	defaultValues[9] = "true"
	defaultValues[10] = "10"
	defaultValues[11] = "30"
	defaultValues[12] = "5"
	defaultValues[13] = "false"
	defaultValues[14] = "true"
	defaultValues[15] = "10"; second serie
	defaultValues[16] = "4"
	defaultValues[17] = "false"
	defaultValues[18] = "0.2"
	defaultValues[19] = "60"
	defaultValues[20] = "2"
	defaultValues[21] = "true"; third serie
	defaultValues[22] = "2.0"
	defaultValues[23] = "50.0"
	defaultValues[24] = "2500"

	presetsInt = new int[50]
endfunction

function loadConfigFile(string path)
	startIndex = 0
	string sConfig = MiscUtil.ReadFromFile(path)
	int index = 0
	While (index < keys.Length)
		string value = getTagValue(keys[index], sConfig, true)
		JMap.setStr(configMapId, keys[index], value)
		index += 1
	EndWhile
	storeConfig()
endfunction

Function toggleTagWithoutStoringConfig(string tag, string toggle)
	string sOldValue = JMap.getStr(configMapId, tag, "")
	bool bNewValue = sOldValue != "true"
	SetToggleOptionValueST(bNewValue, false, toggle)
	string sNewValue = "false"
	if bNewValue
		sNewValue = "true"
	endif
	JMap.setStr(configMapId, tag, sNewValue)
EndFunction

Function toggleTag(string tag, string toggle)
	toggleTagWithoutStoringConfig(tag, toggle)
	storeConfig()
EndFunction

function setOpenedSlider(float min, float max, float interval, string tag, float startValue)
	SetSliderDialogRange(min, max)
	SetSliderDialogInterval(interval)
	SetSliderDialogStartValue(JMap.getStr(configMapId, tag, startValue) as float)
	SetSliderDialogDefaultValue(JMap.getStr(configMapId, tag, startValue) as float)
endfunction

function setIntTag(string tag, int value)
	SetSliderOptionValueST(value as float)
	JMap.setStr(configMapId, tag, value)
	storeConfig()
endfunction

function setFloatTag(string tag, float value, string formatSTring = "{0}")
	SetSliderOptionValueST(value, formatSTring)
	JMap.setStr(configMapId, tag, value)
	storeConfig()
endfunction

string Function buildConfigString()
	string result = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<configs>\n	<smp>\n"
	int index = 0
	string value = ""
	While (index < 15)
		string tag = keys[index]
		value = JMap.getStr(configMapId, tag, "")
		string ev = entaggedValue(tag, value) 
		result += "		" + ev + "\n"
		index += 1
	EndWhile
	result += "	</smp>\n	<solver>\n"
	While (index < 21)
		string tag = keys[index]
		value = JMap.getStr(configMapId, tag, "")
		string ev = entaggedValue(tag, value) 
		result += "		" + ev + "\n"
		index += 1
	EndWhile
	result += "	</solver>\n	<wind>\n"
	While (index < 25)
		string tag = keys[index]
		value = JMap.getStr(configMapId, tag, "")
		string ev = entaggedValue(tag, value) 
		result += "		" + ev + "\n"
		index += 1
	EndWhile
	result += "	</wind>\n</configs>"
	return result
endFunction

Function storeConfig()
	string result = buildConfigString()
	MiscUtil.WriteToFile(configFilePath, result, false)
	ConsoleUtil.ExecuteCommand("smp reset")
EndFunction

string Function entaggedValue(string tag, string value)
	if (value == "true")
		value = ">true<"; lowering case. Yup this is a shameful hack to avoid the shameful handling by papyrus of some specific string like 'TRUE' and 'False'...
	ElseIf (value == "false")
		value = ">false<"; lowering case
	else
		if (tag == "enabled")
			return "<enabled>"+value+"</enabled>"; lowering case
		else
			return "<"+tag+">"+value+"</"+tag+">"
		endif
	endif
	if (tag == "enabled")
		return "<enabled"+value+"/enabled>"; lowering case
	else
		return "<"+tag + value + "/" + tag+">"
	endif
EndFunction

string Function getTagValue(string tag, string sConfig, bool sequential = false)
	string startTag = "<" + tag + ">"
	string endTag = "</" + tag + ">"
	int tagLength = StringUtil.GetLength(tag)
	int startTagIndex = findStringInString(startTag, sConfig, startIndex)
	if (startTagIndex == -1); not found
		return tagDefaultValue(tag)
	endif
	int valueIndex = startTagIndex + tagLength + 2
	int endTagIndex = findStringInString(endTag, sConfig, valueIndex)
	if sequential
		startIndex = endTagIndex + tagLength + 3
	endif
	return StringUtil.Substring(sConfig, valueIndex, endTagIndex - valueIndex)
EndFunction

; This function will be called rarely, so a loop is okay
string Function tagDefaultValue(string tag)
	; TODO use this function in the menu too; will need to use a map rather than a loop
	int i = 0
	while (i < keys.Length)
		if (keys[i] == tag)
			string defaultValue = defaultValues[i]
			debug.MessageBox("This tag isn't set in the loading file: " + tag + "\nWe set it with the default value: " + defaultValue + "\nTo see the preset as loaded, you'll need to update it.")
			return defaultValue
		endif
		i = i+1
	endwhile
	return "Will probably CTD"
endfunction

int Function findStringInString(string toFind, string content, int firstIndex = 0)
	int contentIndex = firstIndex
	int toFindLength = StringUtil.GetLength(toFind)
	int contentLength = StringUtil.GetLength(content)

	int currentIndex = 0
	string[] toFindCharacters = PapyrusUtil.StringArray(toFindLength)
	while currentIndex < toFindLength
		toFindCharacters[currentIndex] = StringUtil.GetNthChar(toFind, currentIndex)
		currentIndex = currentIndex + 1
	endwhile
	
	currentIndex = 0
	while contentIndex < contentLength
		string characterFound = StringUtil.GetNthChar(content, contentIndex + currentIndex)		
		if toFindCharacters[currentIndex] == characterFound
			currentIndex += 1
			if currentIndex == toFindLength
				return contentIndex; found at position contentIndex
			endif
		else
			contentIndex += 1
			currentIndex = 0
		endif
	endwhile
	return -1; Not found
EndFunction

; #################################################################################################
; #################################################################################################
; States
; #################################################################################################
; #################################################################################################

State SliderLog
	event OnSliderOpenST()
		setOpenedSlider(0,5,1,"logLevel", 0)
	endEvent
	
	event OnSliderAcceptST(float a_value)
		setIntTag("logLevel", a_value as int)
	endEvent

	Event OnHighlightST()
		SetInfoText("0 - Fatal, 1 - Error, 2 - Warning, 3 - Message, 4 - Verbose, 5 - Debug")
	EndEvent
EndState

State SliderRotationSpeedLimit
	event OnSliderOpenST()
		setOpenedSlider(0,100,0.1,"rotationSpeedLimit", 10)
	endEvent
	
	event OnSliderAcceptST(float a_value)
		setFloatTag("rotationSpeedLimit", a_value, "{1}")
	endEvent

	Event OnHighlightST()
		SetInfoText("Rotation speed limit in radians / second")
	EndEvent
EndState

State SliderUnclampedResetAngle
	event OnSliderOpenST()
		setOpenedSlider(0,360,1,"unclampedResetAngle", 120)
	endEvent
	
	event OnSliderAcceptST(float a_value)
		setFloatTag("unclampedResetAngle", a_value)
	endEvent

	Event OnHighlightST()
		SetInfoText("The angle value in degrees at which the reset occurs")
	EndEvent
EndState

State SliderMinCullingDistance
	event OnSliderOpenST()
		setOpenedSlider(0, 10000, 1, "minCullingDistance", 300)
	endEvent
	
	event OnSliderAcceptST(float a_value)
		setFloatTag("minCullingDistance", a_value)
	endEvent

	Event OnHighlightST()
		SetInfoText("The distance from camera below which NPCs SMP is always calculated.\nThis is useful when a NPC is just behind the camera, and his cape should float in front of you.\nWithout this, as the camera doesn't see the NPC, his physics is disabled.")
	EndEvent
EndState

State SliderMaxSkeletons
	event OnSliderOpenST()
		setOpenedSlider(0,200,1,"maximumActiveSkeletons", 40)
	endEvent
	
	event OnSliderAcceptST(float a_value)
		setIntTag("maximumActiveSkeletons", a_value as int)
	endEvent

	Event OnHighlightST()
		SetInfoText("The maximum number of NPC, including your character,\nfor which physics is calculated at the same time, when automatically adjusted.")
	EndEvent
EndState

State SliderTimeFramePercentage
	event OnSliderOpenST()
		setOpenedSlider(1,1000,1,"percentageOfFrameTime", 30)
	endEvent
	
	event OnSliderAcceptST(float a_value)
		setIntTag("percentageOfFrameTime", a_value as int)
	endEvent

	Event OnHighlightST()
		SetInfoText("Allowed CPU time for SMP calculus each frame:\na percentage of 16 ms -- Example: 30% = 5ms each frame")
	EndEvent
EndState

State SliderSampleSize
	event OnSliderOpenST()
		setOpenedSlider(1,50,1,"sampleSize", 5)
	endEvent
	
	event OnSliderAcceptST(float a_value)
		setIntTag("sampleSize", a_value as int)
	endEvent

	Event OnHighlightST()
		SetInfoText("Adjustment speed -- the higher, the slower")
	EndEvent
EndState

State SliderNumIterations
	event OnSliderOpenST()
		setOpenedSlider(4,128,1,"numIterations", 16)
	endEvent
	
	event OnSliderAcceptST(float a_value)
		setIntTag("numIterations", a_value as int)
	endEvent

	Event OnHighlightST()
		SetInfoText("Simulation quality")
	EndEvent
EndState

State SliderGroupIterations
	event OnSliderOpenST()
		setOpenedSlider(0,4096,1,"groupIterations", 16)
	endEvent
	
	event OnSliderAcceptST(float a_value)
		setIntTag("groupIterations", a_value as int)
	endEvent

	Event OnHighlightST()
		SetInfoText("Group simulation quality")
	EndEvent
EndState

State SliderERP
	event OnSliderOpenST()
		setOpenedSlider(0.01, 0.99, 0.01, "erp", 0.2)
	endEvent
	
	event OnSliderAcceptST(float a_value)
		setFloatTag("erp", a_value, "{2}")
	endEvent

	Event OnHighlightST()
		SetInfoText("The error correction force applied to move the constraints-enabled bones back to where they're supposed to be.")
	EndEvent
EndState

State SliderMinFPS
	event OnSliderOpenST()
		setOpenedSlider(60,300,1,"min-fps", 60)
	endEvent
	
	event OnSliderAcceptST(float a_value)
		setIntTag("min-fps", a_value as int)
	endEvent

	Event OnHighlightST()
		SetInfoText("Simulation frequency, in simulations per second")
	EndEvent
EndState

State SliderMaxSubsteps
	event OnSliderOpenST()
		setOpenedSlider(1,60,1,"maxSubsteps", 2)
	endEvent
	
	event OnSliderAcceptST(float a_value)
		setIntTag("maxSubsteps", a_value as int)
	endEvent

	Event OnHighlightST()
		SetInfoText("The max number of simulations per frame\nThis allows to avoid calculating physics too much when fps is low.\nThere will be slowdowns when the fps is under (simulation frequency / this value).")
	EndEvent
EndState

State SliderWindStrength
	event OnSliderOpenST()
		setOpenedSlider(0, 100, 0.1, "windStrength", 2.0); FSMP allows for strength 1000...
	endEvent
	
	event OnSliderAcceptST(float a_value)
		setFloatTag("windStrength", a_value, "{1}")
	endEvent

	Event OnHighlightST()
		SetInfoText("Wind strength. 9.8 would be equivalent to gravity.")
	EndEvent
EndState

State SliderNoWindDistance
	event OnSliderOpenST()
		setOpenedSlider(0, 10000, 1, "distanceForNoWind", 50.0)
	endEvent
	
	event OnSliderAcceptST(float a_value)
		setFloatTag("distanceForNoWind", a_value)
	endEvent

	Event OnHighlightST()
		SetInfoText("How close to an obstruction for wind to be fully blocked.\nWind strength scales linearly between the distance for no wind and the distance for max wind.")
	EndEvent
EndState

State SliderMaxWindDistance
	event OnSliderOpenST()
		setOpenedSlider(0, 10000, 1, "distanceForMaxWind", 2500.0)
	endEvent
	
	event OnSliderAcceptST(float a_value)
		setFloatTag("distanceForMaxWind", a_value)
	endEvent

	Event OnHighlightST()
		SetInfoText("How far from an obstruction for wind to be not blocked.\nWind strength scales linearly between the distance for no wind and the distance for max wind. ")
	EndEvent
EndState

State ToggleNPCFaceParts
	Event OnSelectST()
		toggleTag("enableNPCFaceParts", "ToggleNPCFaceParts")
	EndEvent
	
	Event OnHighlightST()
		SetInfoText("Uncheck to disable managing NPC face parts")
	EndEvent
EndState

State ToggleSMPHairWhenWigEquipped
	Event OnSelectST()
		toggleTag("disableSMPHairWhenWigEquipped", "ToggleSMPHairWhenWigEquipped")
	EndEvent
	
	Event OnHighlightST()
		SetInfoText("Check to avoid calculating SMP hair where there is a wig on top of the hair")
	EndEvent
EndState

State ToggleClampRotations
	Event OnSelectST()
		toggleTag("clampRotations", "ToggleClampRotations")
		ForcePageReset()
	EndEvent
	
	Event OnHighlightST()
		SetInfoText("Check to limit the your character rotation speed when turning a large angle, so that it rotates slowly instead of instantly.")
	EndEvent
EndState

State ToggleClampedResets
	Event OnSelectST()
		toggleTag("unclampedResets", "ToggleClampedResets")
		ForcePageReset()
	EndEvent
	
	Event OnHighlightST()
		SetInfoText("When the rotation speed is NOT limited, and this is unchecked,\nif you do a large turn (full 180 degrees for example), physics will be calculated.\nCheck to instead trigger a physics reset when the turn is large enough.")
	EndEvent
EndState

State ToggleRealTime
	Event OnSelectST()
		toggleTag("useRealTime", "ToggleRealTime")
	EndEvent
	
	Event OnHighlightST()
		SetInfoText("Check to use your real time rather than the inner game time (better when using slow time)")
	EndEvent
EndState

State ToggleAutoAdjustMaxSkeletons
	Event OnSelectST()
		toggleTag("autoAdjustMaxSkeletons", "ToggleAutoAdjustMaxSkeletons")
		ForcePageReset()
	EndEvent
	
	Event OnHighlightST()
		SetInfoText("Check to auto adjust the max number of SMP NPCs, else it's 10")
	EndEvent
EndState

State Toggle1stPersonViewPhysics
	Event OnSelectST()
		toggleTag("disable1stPersonViewPhysics", "Toggle1stPersonViewPhysics")
	EndEvent
	
	Event OnHighlightST()
		SetInfoText("Check to avoid calculating your character physics when in 1st person view")
	EndEvent
EndState

State ToggleCuda
	Event OnSelectST()
		toggleTag("enableCuda", "ToggleCuda")
	EndEvent
	
	Event OnHighlightST()
		SetInfoText("Enable the CUDA code (will be used only if you installed a CUDA version)")
	EndEvent
EndState

State ToggleGroupMLCP
	Event OnSelectST()
		toggleTag("groupEnableMLCP", "ToggleGroupMLCP")
	EndEvent
	
	Event OnHighlightST()
		SetInfoText("Check to enable a better simulation (more CPU intensive)")
	EndEvent
EndState

State ToggleWind
	Event OnSelectST()
		toggleTag("enabled", "ToggleWind")
		ForcePageReset()
	EndEvent
	
	Event OnHighlightST()
		SetInfoText("Check to enable FSMP-native wind")
	EndEvent
EndState

State ToggleSMP
	Event OnSelectST()
		bSMPOn = !bSMPOn
		SetToggleOptionValueST(bSMPOn, false, "ToggleSMP")
		if bSMPOn
			ConsoleUtil.ExecuteCommand("smp on")
		else
			ConsoleUtil.ExecuteCommand("smp off")
		endif
		Debug.Messagebox(ConsoleUtil.ReadMessage())
	EndEvent
	
	Event OnHighlightST()
		SetInfoText("Uncheck to disable SMP (Skinned Mesh Physics)")
	EndEvent
EndState

State SMP
	Event OnSelectST()
		ConsoleUtil.ExecuteCommand("smp")
		Debug.Messagebox("Done: check the info in the console")
    EndEvent
    
	Event OnHighlightST()
		SetInfoText("Click to have basic information")
	EndEvent
EndState

State SMPReset
	Event OnSelectST()
		ConsoleUtil.ExecuteCommand("smp reset")
		Debug.Messagebox("Done: smp reset")
    EndEvent
    
	Event OnHighlightST()
		SetInfoText("Resets the physics calculation")
	EndEvent
EndState

State SMPDumptree
	Event OnSelectST()
		ConsoleUtil.ExecuteCommand("smp dumptree")
		Debug.Messagebox("Done: smp dumptree. Check your hdtSMP64.log")
    EndEvent
    
	Event OnHighlightST()
		SetInfoText("Dumps the whole data tree of a NPC in the logs. You need a log level of 3 or more.\nYou need to open the console and target a NPC, then either click here or do 'smp dumptree' in the console.\nThe NPC tree will be dumped in your log file,\ngenerally C:/Users/your_user_name/Documents/My Games/Skyrim Special Edition/SKSE/hdtSMP64.log.")
	EndEvent
EndState

State SMPDetail
	Event OnSelectST()
		ConsoleUtil.ExecuteCommand("smp detail")
		Debug.Messagebox("Done: check the detail in the console")
    EndEvent
    
	Event OnHighlightST()
		SetInfoText("Click to have detailed information")
	EndEvent
EndState

State SMPList
	Event OnSelectST()
		ConsoleUtil.ExecuteCommand("smp list")
		Debug.Messagebox("Done: check the list in the console")
    EndEvent
    
	Event OnHighlightST()
		SetInfoText("Click to have a list of informations")
	EndEvent
EndState

State SMPQueryOverridde
	Event OnSelectST()
		ConsoleUtil.ExecuteCommand("smp QueryOverridde")
		Debug.Messagebox("Done: smp QueryOverridde")
    EndEvent
    
	Event OnHighlightST()
		SetInfoText("Click to QueryOverridde")
	EndEvent
EndState