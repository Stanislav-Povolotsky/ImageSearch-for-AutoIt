; Copy ImageSearch files to this folder before running example
; Taken from https://macroforge.wordpress.com/2019/06/08/using-image-search-in-autoit/
#include <Constants.au3>
#include <GUIConstantsEx.au3>
#include <ImageSearch.au3>

Func findImage($imageFile)
	;search entire screen area for image, return img coords if found, false if not
	Local $searchAreaX1 = 0
	Local $searchAreaY1 = 0
	Local $searchAreaX2 = @DesktopWidth
	Local $searchAreaY2 = @DesktopHeight
	Local $transparentColor = 0xEA00F6 ;bright magenta colro	
	Local $imgX = 0
	Local $imgY = 0
		
	Local $result = _ImageSearchArea($imageFile, 1, $searchAreaX1, $searchAreaY1, $searchAreaX2, $searchAreaY2, $imgX, $imgY, 0, $transparentColor)	
	
	If $result = 1 Then
		Local $imgCoords[2] = [$imgX, $imgY]
		Return $imgCoords
	Else
		Return false	
	EndIf					
EndFunc 

GUICreate("ImageSearch demo", 200, 100)
GUICtrlCreateLabel("ImageSearch demo" & @CRLF & @CRLF & "- F9 test" , 10, 10, 100)
GUISetState()

HotkeySet ("{F9}", test)		


Func test()

	;waitForImage("stats.bmp") ;search until image s found
	;waitForImage("stats_transp.bmp", 5) ;search 5 seconds for the image
	Local $result = findImage("stats_transp.png")	
	
	If $result = false Then
		MsgBox(0, 'Error', "Image was not found on screen.")
	Else
		MouseMove($result[0], $result[1], 10)
		;MouseClick($MOUSE_CLICK_RIGHT)	
	EndIf
	
EndFunc


Func exitScript()
	Exit
EndFunc


Func idle()
	While 1 
		Switch GUIGetMsg() 	
			Case $GUI_EVENT_CLOSE
				exit				
		EndSwitch	
		sleep(40)			
	WEnd
EndFunc	

idle()


Func waitForImage($imageFile, $waitSecs = 0)		
	Local $timeout = $waitSecs * 1000
	Local $startTime = TimerInit()
		
	;loop until image is found, or until wait time is exceeded
	While true 

		If findImage($imageFile) <> false Then
			Return true
		EndIf
		
		If $timeout > 0 And TimerDiff($startTime) >= $timeout Then
			ExitLoop
		EndIf
		sleep(50)	
	WEnd
	
	Return False
EndFunc



