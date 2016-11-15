Enumeration
  #Window
  #Image 
EndEnumeration

Macro ListCaptchas(Directory)
NewList Captchas.s()
If ExamineDirectory(0,Directory,"*.jpg*")  
  While NextDirectoryEntry(0)
    If Len(DirectoryEntryName(0))=19
      AddElement(Captchas())
      Captchas()=DirectoryEntryName(0)
    EndIf 
 Wend
 FinishDirectory(0)
EndIf
FirstElement(Captchas())
EndMacro
Macro Desktop()
 "C:\Users\Ayman\Desktop\"
EndMacro 
Macro Documents()
 "C:\Users\Ayman\Documents\"
EndMacro 
Macro Directory()
 "C:\Users\Ayman\Desktop\Swagbucks Bots\Swagcode CAPTCHAS\"
EndMacro 
Macro FastRGB(Red,Green,Blue)
(((Blue << 8 + Green) << 8 ) + Red)
EndMacro

Procedure ImgDraw(srcImage, dstImage, x, y, ClearColor=-1)
; Draw image with a transparent colour
Protected dw, dh, w, h, *tmp, a, b, c.l
Protected dw0, dh0, sw0, sh0
StartDrawing(ImageOutput(srcImage))
w = OutputWidth(): h = OutputHeight()
; Determine the transparent colour
If ClearColor<0
  ; Use a corner pixel to set the transparent colour
  ; The ordering of corners (-1..-4) is anticlockwise from the top left
  Select ClearColor
  Case -2 ; Bottom left
    ClearColor = Point(0, h-1)
  Case -3 ; Bottom right
    ClearColor = Point(w-1, h-1)
  Case -4 ; Top right
    ClearColor = Point(w-1, 0)
  Default ; Top left
    ClearColor = Point(0, 0)
  EndSelect
EndIf
; If required, clip the image areas
dw = ImageWidth(dstImage): dh = ImageHeight(dstImage)
; Clip destination
If x>=0: dw0 = x: Else: dw0 = 0: EndIf
If y>=0: dh0 = y: Else: dh0 = 0: EndIf
; Clip source
If x>=0: sw0 = 0: Else: sw0 = -x: w + x: EndIf
If y>=0: sh0 = 0: Else: sh0 = -y: h + x: EndIf
If w>dw-dw0: w = dw-dw0: EndIf
If h>dh-dh0: h = dh-dh0: EndIf
If w<=0 Or h<=0: StopDrawing(): ProcedureReturn: EndIf
*tmp = AllocateMemory(w*h*4) ; Temporary memory for source image data
; Loop through the image to collect data
For a = 0 To w-1
  For b = 0 To h-1
    c = Point(a+sw0, b+sh0) ; Get the color
    PokeL(*tmp + (b*w+a)*4, c)    ; Save the color
  Next
Next
StopDrawing()
; Draw the temporary image data on the destination
StartDrawing(ImageOutput(dstImage))
For a = 0 To w-1
  For b = 0 To h-1
   c = PeekL(*tmp + (b*w+a)*4)    ; Read the color
   If c <> ClearColor
      Plot(a+dw0, b+dh0, c)
    EndIf
  Next
Next
StopDrawing()
FreeMemory(*tmp) ; Clean up
EndProcedure

Procedure Max(List List1())
Global LetterIndex 
FirstElement(List1())
Max=List1()
For i=0 To ListSize(List1())-1
  SelectElement(List1(),i)
  If List1()>Max 
    Max=List1()
  EndIf 
Next 

ForEach List1()
  If List1()=Max 
    LetterIndex=ListIndex(List1())
    Break 
  EndIf 
Next 

ProcedureReturn Max 
EndProcedure 

Procedure MoveImage(Image)               
  StartDrawing(ImageOutput(Image))
  For y=0 To ImageHeight(Image)-1
    For x=0 To ImageWidth(Image)-1
      Color=Point(x,y)
      If Color=#Black
        Break 2
      EndIf 
    Next 
  Next    
  StopDrawing() 
  MovedImage=GrabImage(Image,#PB_Any,0,y,ImageWidth(Image),ImageHeight(Image)-y)
  ProcedureReturn MovedImage
EndProcedure 

Procedure CountPixels(Image)            
  StartDrawing(ImageOutput(Image))
  For x=0 To ImageWidth(Image)-1
    For y=0 To ImageHeight(Image)-1   
      Color=Point(x,y)    
      If Color=#Black 
        Pixels+1
      EndIf  
    Next 
  Next 
  StopDrawing()
  ;ClearStructure(*Parameters,OCR)
  ;FreeMemory(*Parameters)
  ProcedureReturn Pixels 
EndProcedure 

Procedure BlackWhite(Image,Hardness) 
NewImage=CreateImage(#PB_Any,ImageWidth(Image),ImageHeight(Image))
For i=0 To ImageWidth(Image)-1
  For j=0 To ImageHeight(Image)-1
    StartDrawing(ImageOutput(Image))
    Color=Point(i,j)     
    StopDrawing()
    StartDrawing(ImageOutput(NewImage)) 
    If Color<FastRGB(Hardness,Hardness,Hardness)
      Plot(i,j,#Black)
    Else
      Plot(i,j,#White)
    EndIf
    StopDrawing()
  Next 
Next
;ClearStructure(*Parameters,OCR)
;FreeMemory(*Parameters)
ProcedureReturn NewImage
EndProcedure 

Procedure IsLine(Image)         
  Global Points$
  StartDrawing(ImageOutput(Image)) 
  For i=0 To ImageWidth(Image)-1
    For j=0 To ImageHeight(Image)-1
      Color=Point(i,j)
      If Green=1 And Red=1
        Points$+Str(i-1)+","
        Green=0
        Red=0
      EndIf 
      If Color=#Black     
        Red=1
        Break 
      EndIf 
    Next 
    If j=37
      Green=1
    EndIf 
  Next 
  StopDrawing()
EndProcedure

Procedure SplitImage(Image)
  Shared Letter1,Letter2,Letter3 
  Global Dim Points(5)
  If CountString(Points$,",")<7
    For i=1 To CountString(Points$,",")
      Points(i-1)=Val(StringField(Points$,i,","))
    Next
  Else
    Debug Points$ 
    Points$=""
    ProcedureReturn 0
  EndIf 
  
  Points$="" 
  
  For b=0 To 4
    If b=1 Or b=3
      Continue
    Else
      If Sign(Points(b+1)-Points(b))=-1
        For i=0 To ArraySize(Points())
          Debug "Points("+Str(i)+") "+Str(Points(i))
        Next 
        FreeArray(Points())
        ProcedureReturn 0 
      EndIf 
    EndIf 
  Next 

  FirstLetter=GrabImage(Image,#PB_Any,Points(0),0,(Points(1)-Points(0)),ImageHeight(Image))
  If FirstLetter
    Letter1=MoveImage(FirstLetter) 
    FreeImage(FirstLetter)
    SecondLetter=GrabImage(Image,#PB_Any,Points(2),0,(Points(3)-Points(2)),ImageHeight(Image))
    If SecondLetter 
      Letter2=MoveImage(SecondLetter)
      FreeImage(SecondLetter)
      ThirdLetter=GrabImage(Image,#PB_Any,Points(4),0,(Points(5)-Points(4)),ImageHeight(Image))
      If ThirdLetter
        Letter3=MoveImage(ThirdLetter)
        FreeImage(ThirdLetter)
        FreeArray(Points())      
        ProcedureReturn 1
      EndIf 
    EndIf
  EndIf 
  FreeArray(Points())
  ProcedureReturn 0 
  
EndProcedure 

Procedure.s SolveCaptcha()
  Shared Letter1,Letter2,Letter3
  NewList Match()
  NewList Letter.s()
  NewList Matches()
  NewList TopMatch()
  NewList Letters()
  
  ;--------FIRST LETTER--------  
  
  ;Memory leak is about 400 with 299 Captchas 
  ;Still some areas that are leaking memory
  
  
  CheckLetter=Letter1 
  
  For Letter=0 To 25    
    LetterCompare=LoadImage(#PB_Any,Documents()+"Alphabet\Class.bmp") 
    LetterToCompare=GrabImage(LetterCompare,#PB_Any,Letter*24,0,24,ImageHeight(LetterCompare))  
    FreeImage(LetterCompare)    
    Pixels=CountPixels(LetterToCompare)
    If ImageWidth(CheckLetter)>5                                        
      PixelsNow=CountPixels(CheckLetter)                                
      ImgDraw(CheckLetter,LetterToCompare,0,0,#White)                   
      PixelsAfter=CountPixels(LetterToCompare)                          
      
      ;       ;Debug StrF((PixelsNow/PixelsAfter)*100,2)+"% Match" 
      ;       ;Debug "Total Pixels "+Str(PixelsAfter)
      ;       ;Debug "Pixels on Letter from captcha "+Str(CountPixels(CheckLetter))
      ;       ;Debug "Pixels on Comparing letter "+Str(Pixels) 
      ;       ;Debug StrF((((Pixels/PixelsAfter)*100)+((PixelsNow/PixelsAfter)*100))/2,2)+" % Estimated Match" ;Still testing      
      
      Match.f=(((Pixels/PixelsAfter)*100)+((PixelsNow/PixelsAfter)*100))/2      
      AddElement(Matches())
      Matches()=Match      
      If Match>=92;%  
        AddElement(Match())      
        Match()=Match            
        AddElement(Letter()) 
        Select Letter 
          Case 0 To 7
            Captcha$+Chr(65+Letter)    
            Letter()=Chr(65+Letter)    
          Case 8 To 24
            Captcha$+Chr(66+Letter)
            Letter()=Chr(66+Letter)    
        EndSelect
      EndIf 
    Else
      Captcha$+"I"
      FoundI=1
      Break 
    EndIf 
    FreeImage(LetterToCompare)
  Next  
  
  ;*If there isn't a high enough match
  If FoundI=0
    If ListSize(Match())=0 
      AddElement(TopMatch())
      TopMatch()=Max(Matches())
      AddElement(Letters())
      Letters()=LetterIndex   
      For Letter=0 To 25
        LetterCompare=LoadImage(#PB_Any,Documents()+"Alphabet\Class.bmp")  
        LetterToCompare=GrabImage(LetterCompare,#PB_Any,Letter*24,0,24,ImageHeight(LetterCompare))
        FreeImage(LetterCompare)  
        Pixels=CountPixels(LetterToCompare)
        For k=1 To 3
          PixelsNow=CountPixels(CheckLetter) 
          ImgDraw(CheckLetter,LetterToCompare,0,0,#White)
          PixelsAfter=CountPixels(LetterToCompare)  
          Match.f=(((Pixels/PixelsAfter)*100)+((PixelsNow/PixelsAfter)*100))/2      
          If Match>92;%
            Select Letter 
              Case 0 To 7  
                Captcha$+Chr(65+Letter)    
              Case 8 To 24
                Captcha$+Chr(66+Letter)    
            EndSelect
            Solved=1
            Break 2
          ElseIf Match>78;%
            AddElement(TopMatch())
            TopMatch()=Match
            AddElement(Letters())
            Letters()=Letter
          EndIf 
        Next   
        FreeImage(LetterToCompare)
      Next   
    ElseIf ListSize(Match())>1      
      ForEach Letter() 
        Captcha$=RemoveString(Captcha$,Letter(),0,0,1)
      Next     
      SelectElement(Match(),1)
      Compare=Match()
      FirstElement(Match())
      If Match()>Compare
        Index=ListIndex(Match())
        ForEach Letter()
          If Index=ListIndex(Letter())
            Captcha$+Letter()
            Solved=1
            Break           
          EndIf 
        Next 
      Else
        NextElement(Match())
        Index=ListIndex(Match())
        ForEach Letter()
          If Index=ListIndex(Letter())
            Captcha$+Letter()
            Solved=1
            Break           
          EndIf 
        Next
      EndIf 
    EndIf    
    If Solved=0     
      FirstElement(Letters())
      ForEach TopMatch()
        Max(TopMatch())
        ForEach Letters()  
          If LetterIndex=ListIndex(Letters())
            Select Letters()
              Case 0 To 7  
                Captcha$+Chr(65+Letters())    
              Case 8 To 24
                Captcha$+Chr(66+Letters())   
            EndSelect 
            Break 2
          EndIf 
        Next 
      Next     
    EndIf    
  EndIf 
  
  ClearList(Letter())
  ClearList(Match())
  ClearList(Matches())
  ClearList(TopMatch())
  ClearList(Letters())
  Solved=0
  Index=0
  Match=0
  FoundI=0
  
  ;--------SECOND LETTER--------
  
  CheckLetter=Letter2
  
  For Letter=0 To 25
    LetterCompare=LoadImage(#PB_Any,Documents()+"Alphabet\Class.bmp")  
    LetterToCompare=GrabImage(LetterCompare,#PB_Any,Letter*24,0,24,ImageHeight(LetterCompare))
    FreeImage(LetterCompare)     
    Pixels=CountPixels(LetterToCompare)
    If ImageWidth(CheckLetter)>5
      PixelsNow=CountPixels(CheckLetter)  
      ImgDraw(CheckLetter,LetterToCompare,0,0,#White)
      PixelsAfter=CountPixels(LetterToCompare)   
      ;       ;Debug StrF((PixelsNow/PixelsAfter)*100,2)+"% Match" 
      ;       ;Debug "Total Pixels "+Str(PixelsAfter)
      ;       ;Debug "Pixels on Letter from captcha "+Str(CountPixels(CheckLetter))
      ;       ;Debug "Pixels on Comparing letter "+Str(Pixels) 
      ;       ;Debug StrF((((Pixels/PixelsAfter)*100)+((PixelsNow/PixelsAfter)*100))/2,2)+" % Estimated Match" ;Still testing
      
      Match.f=(((Pixels/PixelsAfter)*100)+((PixelsNow/PixelsAfter)*100))/2      
      AddElement(Matches())
      Matches()=Match 
      If Match>=92;%  
        AddElement(Match())      
        Match()=Match            
        AddElement(Letter()) 
        Select Letter 
          Case 0 To 7
            Captcha$+Chr(65+Letter)    
            Letter()=Chr(65+Letter)    
          Case 8 To 24
            Captcha$+Chr(66+Letter)
            Letter()=Chr(66+Letter)    
        EndSelect
      EndIf 
    Else
      Captcha$+"I"
      FoundI=1
      Break 
    EndIf 
    FreeImage(LetterToCompare)
  Next  

  ;   ;*If there isn't a high enough match
  If FoundI=0    
    If ListSize(Match())=0    
      AddElement(TopMatch())
      TopMatch()=Max(Matches())
      AddElement(Letters())
      Letters()=LetterIndex       
      For Letter=0 To 25
        LetterCompare=LoadImage(#PB_Any,Documents()+"Alphabet\Class.bmp")  
        LetterToCompare=GrabImage(LetterCompare,#PB_Any,Letter*24,0,24,ImageHeight(LetterCompare))
        FreeImage(LetterCompare)        
        Pixels=CountPixels(LetterToCompare) 
        For k=1 To 3
          PixelsNow=CountPixels(CheckLetter) 
          ImgDraw(CheckLetter,LetterToCompare,0,0,#White)
          PixelsAfter=CountPixels(LetterToCompare)  
          Match.f=(((Pixels/PixelsAfter)*100)+((PixelsNow/PixelsAfter)*100))/2      
          If Match>92;%
            Select Letter 
              Case 0 To 7  
                Captcha$+Chr(65+Letter)    
              Case 8 To 24
                Captcha$+Chr(66+Letter)    
            EndSelect
            Solved=1
            Break 2
          ElseIf Match>78;%
            AddElement(TopMatch())
            TopMatch()=Match
            AddElement(Letters())
            Letters()=Letter
          EndIf 
        Next 
        FreeImage(LetterToCompare)
      Next     
    ElseIf ListSize(Match())>1     
      ForEach Letter() 
        Captcha$=RemoveString(Captcha$,Letter(),0,0,1)
      Next       
      SelectElement(Match(),1)
      Compare=Match()
      FirstElement(Match())
      If Match()>Compare
        Index=ListIndex(Match())
        ForEach Letter()
          If Index=ListIndex(Letter())
            Captcha$+Letter()
            Solved=1
            Break           
          EndIf 
        Next 
      Else
        NextElement(Match())
        Index=ListIndex(Match())
        ForEach Letter()
          If Index=ListIndex(Letter())
            Captcha$+Letter()
            Solved=1
            Break           
          EndIf 
        Next        
      EndIf    
    EndIf 
    If Solved=0     
      FirstElement(Letters())
      ForEach TopMatch() 
        Max(TopMatch())
        ForEach Letters()  
          If LetterIndex=ListIndex(Letters())
            Select Letters()
              Case 0 To 7  
                Captcha$+Chr(65+Letters())    
              Case 8 To 24
                Captcha$+Chr(66+Letters())   
            EndSelect 
            Break 2
          EndIf 
        Next 
      Next
    EndIf 
  EndIf 
  
  ClearList(Letter())
  ClearList(Match())
  ClearList(Matches())
  ClearList(TopMatch())
  ClearList(Letters())
  Solved=0
  Index=0
  Match=0
  FoundI=0
  
  ;--------THIRD LETTER--------
  
  CheckLetter=Letter3
  
  For Letter=0 To 25
    LetterCompare=LoadImage(#PB_Any,Documents()+"Alphabet\Class.bmp")  
    LetterToCompare=GrabImage(LetterCompare,#PB_Any,Letter*24,0,24,ImageHeight(LetterCompare))
    FreeImage(LetterCompare) 
    Pixels=CountPixels(LetterToCompare)
    If ImageWidth(CheckLetter)>5
      PixelsNow=CountPixels(CheckLetter) 
      ImgDraw(CheckLetter,LetterToCompare,0,0,#White)
      PixelsAfter=CountPixels(LetterToCompare)  
      
      ;       ;Debug StrF((PixelsNow/PixelsAfter)*100,2)+"% Match" 
      ;       ;Debug "Total Pixels "+Str(PixelsAfter)
      ;       ;Debug "Pixels on Letter from captcha "+Str(CountPixels(CheckLetter))
      ;       ;Debug "Pixels on Comparing letter "+Str(Pixels) 
      ;       ;Debug StrF((((Pixels/PixelsAfter)*100)+((PixelsNow/PixelsAfter)*100))/2,2)+" % Estimated Match" ;Still testing
      
      Match.f=(((Pixels/PixelsAfter)*100)+((PixelsNow/PixelsAfter)*100))/2      
      AddElement(Matches())
      Matches()=Match              
      If Match>=92;%  
        AddElement(Match())      
        Match()=Match            
        AddElement(Letter()) 
        Select Letter 
          Case 0 To 7
            Captcha$+Chr(65+Letter)    
            Letter()=Chr(65+Letter)    
          Case 8 To 24
            Captcha$+Chr(66+Letter)
            Letter()=Chr(66+Letter)    
        EndSelect
      EndIf 
    Else
      Captcha$+"I"
      FoundI=1
      Break 
    EndIf 
    FreeImage(LetterToCompare)
  Next  
  
  If FoundI=0
    ;*If there isn't a high enough match
    If ListSize(Match())=0
      AddElement(TopMatch())
      TopMatch()=Max(Matches())
      AddElement(Letters())
      Letters()=LetterIndex  
      For Letter=0 To 25
        LetterCompare=LoadImage(#PB_Any,Documents()+"Alphabet\Class.bmp")  
        LetterToCompare=GrabImage(LetterCompare,#PB_Any,Letter*24,0,24,ImageHeight(LetterCompare))
        FreeImage(LetterCompare)
        Pixels=CountPixels(LetterToCompare)
        For k=1 To 3
          PixelsNow=CountPixels(CheckLetter) 
          ImgDraw(CheckLetter,LetterToCompare,0,0,#White)
          PixelsAfter=CountPixels(LetterToCompare)  
          Match.f=(((Pixels/PixelsAfter)*100)+((PixelsNow/PixelsAfter)*100))/2      
          If Match>92;%
            Select Letter 
              Case 0 To 7  
                Captcha$+Chr(65+Letter)    
              Case 8 To 24
                Captcha$+Chr(66+Letter)    
            EndSelect
            Solved=1
            Break 2
          ElseIf Match>78;%
            AddElement(TopMatch())
            TopMatch()=Match
            AddElement(Letters())
            Letters()=Letter
          EndIf 
        Next   
        FreeImage(LetterToCompare)
      Next              
    ElseIf ListSize(Match())>1   
      ForEach Letter() 
        Captcha$=RemoveString(Captcha$,Letter(),0,0,1)
      Next      
      SelectElement(Match(),1)
      Compare=Match()
      FirstElement(Match())
      If Match()>Compare
        Index=ListIndex(Match())
        ForEach Letter()
          If Index=ListIndex(Letter())
            Captcha$+Letter()
            Solved=1
            Break           
          EndIf 
        Next 
      Else
        NextElement(Match())
        Index=ListIndex(Match())
        ForEach Letter()
          If Index=ListIndex(Letter())
            Captcha$+Letter()
            Solved=1
            Break           
          EndIf 
        Next 
      EndIf 
    EndIf 
    If Solved=0     
      FirstElement(Letters())
      ForEach TopMatch()
        Max(TopMatch())
        ForEach Letters()  
          If LetterIndex=ListIndex(Letters())
            Select Letters()
              Case 0 To 7  
                Captcha$+Chr(65+Letters())    
              Case 8 To 24
                Captcha$+Chr(66+Letters())   
            EndSelect 
            Break 2
          EndIf 
        Next 
      Next
    EndIf  
  EndIf 
  
  FreeImage(Letter1)    
  FreeImage(Letter2)
  FreeImage(Letter3)
  FreeList(Letter())
  FreeList(Match())
  FreeList(Matches())
  FreeList(TopMatch())
  FreeList(Letters()) 
 
  ProcedureReturn Captcha$
  
EndProcedure 

UseJPEGImageDecoder()
;ListCaptchas(Directory())

;OpenWindow(0,0,0,300,200,"Swagbucks Captcha Solver",#PB_Window_ScreenCentered)

TotalTime=ElapsedMilliseconds()

NewList Unsolved.s()
AddElement(Unsolved())
Unsolved()="041a12813xiamqt.jpg"
AddElement(Unsolved())
Unsolved()="043101484lhirnu.jpg"
AddElement(Unsolved())
Unsolved()="052454757wiantj.jpg"
AddElement(Unsolved())
Unsolved()="080916082ipbtzs.jpg"
AddElement(Unsolved())
Unsolved()="084413194klreuv.jpg"
AddElement(Unsolved())
Unsolved()="090924939oneoap.jpg"
AddElement(Unsolved())
Unsolved()="090933894oyzzxg.jpg"
AddElement(Unsolved())
Unsolved()="091329156hwnuws.jpg"
AddElement(Unsolved())
Unsolved()="093807198hrzzpz.jpg"
AddElement(Unsolved())
Unsolved()="094208675rnitfr.jpg" 
AddElement(Unsolved())
Unsolved()="100128908llbpvh.jpg"
AddElement(Unsolved())
Unsolved()="100727918ywmxzu.jpg"
AddElement(Unsolved())

;ForEach Captchas()
  
  If LoadImage(#Image,Directory()+"041a12813xiamqt.jpg")                                     
    Time=ElapsedMilliseconds()                                        ;         
    
    CroppedImage=GrabImage(#Image,#PB_Any,44,0,66,ImageHeight(#Image)) 
    Image=BlackWhite(CroppedImage,110)
    IsLine(Image) 
    If SplitImage(Image)
      Captcha$=SolveCaptcha()   
      Solved+1
      Debug Captcha$
;       Debug Captchas()
;       Debug "Solved in "+StrF((ElapsedMilliseconds()-Time)/1000,2)+"s";
;       Debug "Success rate "+StrF((Solved/ListSize(Captchas()))*100,2)+"%" 
;       Debug "Current Captcha ["+Str(CurrentCaptcha)+"/"+Str(ListSize(Captchas())-1)+"]" ;Change -1 after
;       Debug #CRLF$
    Else
      ;Debug Captchas()
      Debug "Captcha cannot be solved"
      Debug #CRLF$
    EndIf 
    CurrentCaptcha+1
  Else
    Debug "Captcha could not be loaded"
    Debug #CRLF$
  EndIf 
  
  FreeImage(#Image)
  FreeImage(CroppedImage)
  FreeImage(Image)
  
;Next 

;Debug "Captcha unsolved "+Str(ListSize(Captchas())-Solved) 
Debug "Time elapsed "+StrF((ElapsedMilliseconds()-TotalTime)/1000,2)+"s"

; Repeat
;   
; Until WaitWindowEvent()=#PB_Event_CloseWindow
