; Copy ImageSearch files to this folder before running example
; Modified version of "ImgSearch demo" example from https://macroforge.wordpress.com/2019/06/08/using-image-search-in-autoit/
#include <Constants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <ImageSearch.au3>

Func findImage($imageFile, $multi_results = false)
  ;search entire screen area for image, return img coords if found, false if not
  Local $searchAreaX1 = 0
  Local $searchAreaY1 = 0
  Local $searchAreaX2 = @DesktopWidth
  Local $searchAreaY2 = @DesktopHeight
  Local $transparentColor = 0xEA00F6 ; bright magenta color
  Local $imgX = 0
  Local $imgY = 0
    
  Local $result
  if(not $multi_results) Then
    $result = _ImageSearchArea($imageFile, 1, $searchAreaX1, $searchAreaY1, $searchAreaX2, $searchAreaY2, $imgX, $imgY, 0, $transparentColor)
    If $result Then
      Local $imgCoords[2] = [$imgX, $imgY]
      Return $imgCoords
    EndIf          
  else
    Local $results
    $result = _ImageSearchAreaMultiResults($results, $imageFile, 1, $searchAreaX1, $searchAreaY1, $searchAreaX2, $searchAreaY2, 0, $transparentColor)
    if($result) Then 
      return $results
    EndIf
  Endif
  return false
EndFunc 

GUICreate("ImageSearch demo", 410, 570)
Local $idButton_img1 = GUICtrlCreateButton("Find 'smile.png' {F9}", 10, 10, 130, 25)
Local $idButton_img2 = GUICtrlCreateButton("Find 'stats_transp.png'", 140, 10, 130, 25)
Local $idButton_img3 = GUICtrlCreateButton("Find all 'stones.png'", 270, 10, 130, 25)
$idLog = GUICtrlCreateEdit("", 10, 460, 390, 100,  $ES_AUTOVSCROLL+$ES_MULTILINE+$ES_READONLY)
GUICtrlCreateLabel("Test image:", 10, 40, 100)

Local $idPic = GUICtrlCreatePic("res\test_inventory.bmp", 10, 60, 318, 390)
GUISetState()

HotkeySet ("{F9}", test_f9)    


Func test_find_image($image_name, $multi_search = false)
  Local $result = findImage($image_name, $multi_search)
  Local $text = "Image '" & $image_name & "' "
  if($result == false) Then
    $text = $text & " was not found"
  else
    if(not $multi_search) Then
      $text = $text & " was found at (" & $result[0] & "; " & $result[1] & ")"
      MouseMove($result[0], $result[1], 10)
    Else
      Local $i
      $text = $text & " was found " & UBound($result) & " time(s) at"
      for $i = 0 To UBound($result) - 1
        $text = $text & " (" & $result[$i][0] & "; " & $result[$i][1] & ")"
      Next
      MouseMove($result[0][0], $result[0][1], 10)
    EndIf
  EndIf
  GUICtrlSetData($idLog, $text & @CRLF, 1)  
EndFunc

Func test_f9()
  test_find_image("images-to-find\smile.png")
EndFunc

Func exitScript()
  Exit
EndFunc


Func idle()
  While 1 
    Switch GUIGetMsg()   
      Case $GUI_EVENT_CLOSE
        exit
      Case $idButton_img1
        test_find_image("images-to-find\smile.png")
      Case $idButton_img2
        test_find_image("images-to-find\stats_transp.png")
      Case $idButton_img3
        test_find_image("images-to-find\stones.png", true)
    EndSwitch  
    sleep(40)      
  WEnd
EndFunc  

idle()
