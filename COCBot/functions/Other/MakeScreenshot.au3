; #FUNCTION# ====================================================================================================================
; Name ..........: MakeScreenshot
; Description ...: This file creates a snapshot of the user base
; Syntax ........: MakeScreenshot($TargetDir[, $type = "jpg"])
; Parameters ....: $TargetDir           - required - location to save file
;                  $type                - [optional] string - type of image to save ("jpg", "png", "bmp"). Default is "jpg".
; Return values .: None
; Author ........: Sardo (2015-06)
; Modified ......: Hervidero, ProMac (2015-10), MonkeyHunter (2016-2)
; Remarks .......: This file is part of MyBot Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func MakeScreenshot($TargetDir, $type = Default)
	
	If $type = Default Then
		If $g_bScreenshotPNGFormat Then
			$type = "png"
		Else
			$type = "jpg"
		EndIf
	EndIf
	
	If WinGetAndroidHandle() <> 0 Then

		Local $SuspendMode
		Local $iLeft = 0, $iTop = 0, $iRight = $g_iAndroidClientWidth, $iBottom = $g_iAndroidClientHeight ; set size of ENTIRE screen to save
		Local $iW = Number($iRight) - Number($iLeft)
		Local $iH = Number($iBottom) - Number($iTop)
		Local $hHBitmapScreenshot = _CaptureRegion($iLeft, $iTop, $iRight, $iBottom, True)
		Local $hBitmapScreenshot = _GDIPlus_BitmapCreateFromHBITMAP($hHBitmapScreenshot)
		Local $hGraphic = _GDIPlus_ImageGetGraphicsContext($hBitmapScreenshot) ; Get graphics content from bitmap image
;		Local $hBrush = _GDIPlus_BrushCreateSolid(0xFF000029) ;create a brush AARRGGBB (using 0x000029 = Dark Blue)
		Local $hBrush = _GDIPlus_BrushCreateSolid(0xFFFFFFFF) ;create a brush AARRGGBB (using 0x000029 = Dark Blue)


	    If $g_bScreenshotHideName Then
			If $g_aiClanCastlePos[0] = -1 Or $g_aiClanCastlePos[1] = -1 Then
				SetLog("Screenshot warning: Locate the Clan Castle to hide the clanname!", $COLOR_ERROR)
			EndIf
			_GDIPlus_GraphicsFillRect($hGraphic, 0, 0, 250, 63, $hBrush) ;draw filled rectangle on the image to hide the user IGN
			If $g_aiClanCastlePos[0] <> -1 Then
				Local $xCC = $g_aiClanCastlePos[0]
				Local $yCC = $g_aiClanCastlePos[1]
				ConvertToVillagePos($xCC, $yCC)
				_GDIPlus_GraphicsFillRect($hGraphic, $xCC - 31, $yCC - 3, 66, 20, $hBrush) ;draw filled rectangle on the image to hide the user CC if position is known
			EndIf

			GetVillageSize()

			_GDIPlus_GraphicsDrawString($hGraphic, "S: " & $g_aVillageSize[4] & ", " & $g_aVillageSize[5], 5, 10, "Arial", 12)
			_GDIPlus_GraphicsDrawString($hGraphic, "T: " & $g_aVillageSize[7] & ", " & $g_aVillageSize[8], 5, 30, "Arial", 12)						
		EndIf
		
		Local $Date = @YEAR & "-" & @MON & "-" & @MDAY
		Local $Time = @HOUR & "." & @MIN & "." & @SEC
		Local $filename = $Date & "_" & $Time & "." & $type  ; most systems support type = png, jpg, bmp, gif, tif
		_GDIPlus_ImageSaveToFile($hBitmapScreenshot, $TargetDir & $filename)
		If FileExists($TargetDir & $filename) = 1 Then
			If $g_sProfileTempPath = $TargetDir Then
				SetLog("Screenshot saved: .\Profiles\" & $g_sProfileCurrentName & "\Temp\" & $filename)
			Else
				SetLog("Screenshot saved: " & $TargetDir & $filename)
			EndIf
		Else
			SetLog("Screenshot file not created: " & $TargetDir & $filename, $COLOR_ERROR)
		EndIf
		$g_bMakeScreenshotNow = False
		;reduce mem
		_GDIPlus_BrushDispose($hBrush)
		_GDIPlus_GraphicsDispose($hGraphic)
		_GDIPlus_BitmapDispose($hBitmapScreenshot)
		_WinAPI_DeleteObject($hHBitmapScreenshot)

	Else
		SetLog("Not in game", $COLOR_ERROR)
	EndIf

EndFunc   ;==>MakeScreenshot