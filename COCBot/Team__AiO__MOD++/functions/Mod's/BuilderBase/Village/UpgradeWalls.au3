; #FUNCTION# ====================================================================================================================
; Name ..........: BuilderBaseUpgradeWalls
; Description ...:
; Author ........: SpartanUBPT
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as Multibot and ClashGameBot. Copyright 2015-2020
;                  MultiBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
;Builder Base Walls

Func TestRunWallsUpgradeBB()
	SetDebugLog("** TestRunWallsUpgradeBB START**", $COLOR_DEBUG)
	Local $status = $g_bRunState
	Local $wasWallsBB = $g_bChkBBUpgradeWalls
	$g_bRunState = True
	$g_bChkBBUpgradeWalls = True
	WallsUpgradeBB()
	$g_bRunState = $status
	$g_bChkBBUpgradeWalls = $wasWallsBB
	SetDebugLog("** TestRunWallsUpgradeBB END**", $COLOR_DEBUG)
EndFunc   ;==>TestRunWallsUpgradeBB

Func WallsUpgradeBB()
	If Not $g_bRunState Then Return
	If Not $g_bChkBBUpgradeWalls Then Return
	FuncEnter(WallsUpgradeBB)
	Local $bBuilderBase = True
	ZoomOut()
	If isOnBuilderBase(True, True) Then
		SetLog("Start Upgrade BB Wall.", $COLOR_INFO)
		Local $hWallBBTimer = __TimerInit()
		If Not getBuilderCount(False, $bBuilderBase) Then Return
		If $g_aiCurrentLootBB[$eLootGoldBB] = 0 Then BuilderBaseReport()
		If _Sleep($DELAYRESPOND) Then Return
		Local $hStarttime = _Timer_Init()
		Local $iBBWallLevel = $g_iCmbBBWallLevel + 1
		Local $iBBNextLevelCost = $g_aWallBBInfoPerLevel[$iBBWallLevel + 1][1]
		Local $bNextlevel = False
		SetDebugLog("Wall(s) to search lvl " & $iBBWallLevel)
		SetDebugLog("Level " & $iBBWallLevel + 1 & " value: " & $iBBNextLevelCost & " G: " & $g_aiCurrentLootBB[$eLootGoldBB] & " E: " & $g_aiCurrentLootBB[$eLootElixirBB])
		If $g_iFreeBuilderCountBB > 0 And $g_bChkBBWallRing Then
			For $i = 0 To 10
				If $g_bDebugSetlog Then SetDebugLog("Using Walls Rings loop " & $i)
				If DetectedWalls($iBBWallLevel) Then
					If $g_bDebugSetlog Then SetDebugLog("Array Wall Rings button --> " & _ArrayToString($aWallRing, " ", -1, -1, "|"))
					If UpgradeCurrentWall("WallR") Then
						SetLog("Walls Ring found, let's Click it!", $COLOR_INFO)
						If _Sleep($DELAYAUTOUPGRADEBUILDING1) Then Return
					EndIf
				Else
					If Not $bNextlevel Then
						SwitchToNextWallBBLevel()
						$bNextlevel = True
					EndIf
				EndIf
			Next
			ClickAway()
			BuilderBaseReport()
			SetDebugLog("Level " & $iBBWallLevel + 1 & " value: " & $iBBNextLevelCost & " G: " & $g_aiCurrentLootBB[$eLootGoldBB] & " E: " & $g_aiCurrentLootBB[$eLootElixirBB])
		EndIf
		If $g_iFreeBuilderCountBB > 0 And Number($g_aiCurrentLootBB[$eLootGoldBB]) > $iBBNextLevelCost And $g_bChkBBUpgWallsGold Then
			For $i = 0 To 10
				If $g_bDebugSetlog Then SetDebugLog("Using Gold loop " & $i)
				If Number($g_aiCurrentLootBB[$eLootGoldBB]) <= $iBBNextLevelCost Then ExitLoop
				If DetectedWalls($iBBWallLevel) Then
					If UpgradeCurrentWall("Gold") Then
						SetDebugLog("Wall level " & $iBBWallLevel & " Upgraded with Gold!")
					Else
						ExitLoop
					EndIf
				Else
					If Not $bNextlevel Then
						SwitchToNextWallBBLevel()
						$bNextlevel = True
					EndIf
				EndIf
				ClickAway()
				BuilderBaseReport()
				SetDebugLog("Level " & $iBBWallLevel + 1 & " value: " & $iBBNextLevelCost & " G: " & $g_aiCurrentLootBB[$eLootGoldBB] & " E: " & $g_aiCurrentLootBB[$eLootElixirBB])
			Next
		EndIf
		If $g_iFreeBuilderCountBB > 0 And Number($g_aiCurrentLootBB[$eLootElixirBB]) > $iBBNextLevelCost And $g_bChkBBUpgWallsElixir Then
			For $i = 0 To 10
				If $g_bDebugSetlog Then SetDebugLog("Using Elixir loop " & $i)
				If Number($g_aiCurrentLootBB[$eLootElixirBB]) <= $iBBNextLevelCost Then ExitLoop
				If DetectedWalls($iBBWallLevel) Then
					If UpgradeCurrentWall("Elixir") Then
						SetDebugLog("Wall level " & $iBBWallLevel & " Upgraded with Elixir!")
					Else
						ExitLoop
					EndIf
				Else
					If Not $bNextlevel Then
						SwitchToNextWallBBLevel()
						$bNextlevel = True
					EndIf
				EndIf
				ClickAway()
				BuilderBaseReport()
				SetDebugLog("Level " & $iBBWallLevel + 1 & " value: " & $iBBNextLevelCost & " G: " & $g_aiCurrentLootBB[$eLootGoldBB] & " E: " & $g_aiCurrentLootBB[$eLootElixirBB])
			Next
		EndIf
		ClickAway()
	EndIf
	FuncReturn()
EndFunc   ;==>WallsUpgradeBB

Func DetectedWalls($iBBWallLevel = 1)
	Local $hStarttime = _Timer_Init()
	ClickAway()
	Local $aWallsBBNXY = findMultipleQuick($g_sBundleWallsBB, Default, "FV", True, "", False, 25, $g_bDebugImageSave, $iBBWallLevel, $iBBWallLevel, Default)
	If $g_bDebugSetlog Then SetDebugLog("Image Detection for Walls in Builder Base : " & Round(_Timer_Diff($hStarttime), 2) & "'ms")
	If IsArray($aWallsBBNXY) And UBound($aWallsBBNXY) > 0 Then
		SetDebugLog("Total Walls Found: " & UBound($aWallsBBNXY) & " --> " & _ArrayToString($aWallsBBNXY, " ", -1, -1, "|"))
		For $i = 0 To UBound($aWallsBBNXY) - 1
			If $g_bDebugSetlog Then SetDebugLog($aWallsBBNXY[$i][0] & " found at (" & $aWallsBBNXY[$i][1] & "," & $aWallsBBNXY[$i][2] & ")", $COLOR_SUCCESS)
			If IsMainPageBuilderBase() Then Click($aWallsBBNXY[$i][1], $aWallsBBNXY[$i][2], 1, 0, "#902")
			If _Sleep($DELAYCOLLECT3) Then Return
			Local $aResult = BuildingInfo(245, 490 + $g_iBottomOffsetY) ; Get building name and level with OCR
			If $aResult[0] = 2 Then
				If StringInStr($aResult[1], "Wall") = True And Number($aResult[2]) = $iBBWallLevel Then
					SetLog("Position : " & $aWallsBBNXY[$i][1] & ", " & $aWallsBBNXY[$i][2] & " is a Wall Level: " & $iBBWallLevel & ".")
					Return True
				EndIf
			EndIf
			ClickAway()
		Next
	EndIf
	Return False
EndFunc   ;==>DetectedWalls

Func UpgradeCurrentWall($sResource = "Gold")

	If IsMainPageBuilderBase() Then
		Return HammerSearch($sResource)
	EndIf

	Return False
EndFunc   ;==>UpgradeCurrentWall

Func SwitchToNextWallBBLevel()
	If $g_iCmbBBWallLevel >= 0 And $g_iCmbBBWallLevel < 7 Then
		EnableGuiControls()
		_GUICtrlComboBox_SetCurSel($g_hCmbBBWallLevel, $g_iCmbBBWallLevel + 1)
		cmbBBWall()
		saveConfig()
		DisableGuiControls()
		Return True
	EndIf
	Return False
EndFunc   ;==>SwitchToNextWallBBLevel

Func HammerSearch($sResource = "Gold")
	Local $aHammer[2] = [0, 0]
	Local $sMode = ""
	Local $iDist = 0
	Local $aButtonPixel
	Local $bReturn = False
	
	Local $aButtons = findMultipleQuick(@ScriptDir & "\COCBot\Team__AiO__MOD++\Images\Upgrade\Hammer", Default, "179, 579, 675, 694", True, "", False, 0)
	If $aButtons <> -1 Then
		For $i = 0 To UBound($aButtons) -1
			
			Switch $aButtons[$i][0]
				Case "BuildH", "WallR"
					$sMode = "Hammer"
				Case "Hammer", "HammerD"
					$sMode = "Resource"
					Switch $sResource
						Case "Gold"
							$aButtonPixel = _MultiPixelSearch($aButtons[$i][1], 579, $aButtons[$i][1] + 67, 613, 2, 2, Hex(0xFFFFFF, 6), StringSplit2D("0xFFFFFF-0-1|0xFFF955-8-0"), 35)
						Case "Elixir" 
							$aButtonPixel = _MultiPixelSearch($aButtons[$i][1], 579, $aButtons[$i][1] + 67, 613, 2, 2, Hex(0xFFFFFF, 6), StringSplit2D("0xFFFFFF-0-1|0xFF60FF-8-0"), 35)
						Case "Dark"
							$aButtonPixel = _MultiPixelSearch($aButtons[$i][1], 579, $aButtons[$i][1] + 67, 613, 2, 2, Hex(0xFFFFFF, 6), StringSplit2D("0xFFFFFF-0-1|0x3A2C3E-8-0"), 35)
						Case Else
							$sMode = ""
					EndSwitch
			EndSwitch
			
			If $sMode <> "" Then 
				$aHammer[0] = $aButtons[$i][1]
				$aHammer[1] = $aButtons[$i][2]
				ExitLoop
			EndIf
			
		Next
		
		If $sMode <> "" Then
			ClickP($aHammer)
			If _Sleep(2000) Then Return
			
			Switch $sMode
				Case "Resource"
					$aButtonPixel = _MultiPixelSearch(45, 356, 802, 621, 15, 15, Hex(0xDFF885, 6), StringSplit2D("0x77C422-0-30|0xE0F884-15-0"), 35)
				Case "Hammer"
					$aButtonPixel = _MultiPixelSearch(45, 356, 802, 621, 15, 15, Hex(0xDADEFF, 6), StringSplit2D("0x7C8AFF-0-30|0xDADEFF-15-0"), 35)
			EndSwitch
			
			If $aButtonPixel <> 0 Then
				ClickP($aButtonPixel)
				If _Sleep(2000) Then Return
				
				If _Wait4Pixel($aIsGemWindow1[0], $aIsGemWindow1[1], $aIsGemWindow1[2], $aIsGemWindow1[3], 2000, "IsGemWindow1") Then
					If isGemOpen(True) = False Then
						$bReturn = True
					Else
						SetLog("Gem window opened, this should not happen.", $COLOR_INFO)
					EndIf
				Else
					$bReturn = True
				EndIf
			EndIf
		EndIf
	EndIf
	
	ClickAway()
	Return $bReturn
EndFunc