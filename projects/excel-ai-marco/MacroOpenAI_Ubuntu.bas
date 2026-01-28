REM ============================================================
REM MACRO: Descripcion automatica de prendas con OpenAI Vision
REM VERSION: 2.0 - LibreOffice Calc Ubuntu/Linux Edition
REM ============================================================

REM Funcion auxiliar para pausas
Sub Wait(nMilisegundos)
    Dim nStart
    nStart = Timer()
    While (Timer() - nStart) * 1000 < nMilisegundos
        DoEvents
    Wend
End Sub

REM Procesa todas las URLs de la columna A y genera descripciones en columna B
Sub ProcesarImagenesPrendas()
    Dim oDoc
    Dim oSheet
    Dim nFila
    Dim sImageURL
    Dim sDescripcion
    Dim sKeywords
    Dim bContinuar
    Dim nProcesadas
    Dim nErrores
    Dim nTotal
    Dim nInicio
    
    oDoc = ThisComponent
    oSheet = oDoc.Sheets(0)
    
    nFila = 2
    bContinuar = True
    nProcesadas = 0
    nErrores = 0
    nInicio = Timer
    
    REM Contar total de filas con URLs
    nTotal = 0
    While Len(Trim(oSheet.getCellByPosition(0, nTotal + 1).getString())) > 0
        nTotal = nTotal + 1
    Wend
    
    If nTotal = 0 Then
        MsgBox "No se encontraron URLs en la columna A."
        Exit Sub
    End If
    
    MsgBox "Se procesaran " & nTotal & " imagenes." & Chr(10) & "Presione OK para comenzar."
    
    REM Bucle principal de procesamiento
    While bContinuar
        sImageURL = oSheet.getCellByPosition(0, nFila - 1).getString()
        
        If Len(Trim(sImageURL)) = 0 Then
            bContinuar = False
        Else
            oSheet.getCellByPosition(2, nFila - 1).setString("Procesando...")
            
            sDescripcion = LlamarOpenAI(sImageURL)
            
            REM DEBUG: Log description before color removal
            On Error Resume Next
            Dim nDebugMain
            nDebugMain = FreeFile()
            Open "/tmp/main_debug.log" For Append As #nDebugMain
            Print #nDebugMain, "Row " & nFila & " - After LlamarOpenAI:"
            Print #nDebugMain, "  sDescripcion length: " & Len(sDescripcion)
            Print #nDebugMain, "  sDescripcion value: " & Left(sDescripcion, 200)
            Close #nDebugMain
            Err.Clear
            On Error GoTo 0
            
            REM Eliminar colores de la descripcion
            If Left(sDescripcion, 5) <> "Error" Then
                sDescripcion = EliminarColores(sDescripcion)
            End If
            
            REM DEBUG: Log description after color removal
            On Error Resume Next
            nDebugMain = FreeFile()
            Open "/tmp/main_debug.log" For Append As #nDebugMain
            Print #nDebugMain, "  After EliminarColores:"
            Print #nDebugMain, "    sDescripcion length: " & Len(sDescripcion)
            Print #nDebugMain, "    sDescripcion value: " & Left(sDescripcion, 200)
            Close #nDebugMain
            Err.Clear
            On Error GoTo 0
            
            REM Escribir descripcion sin colores
            oSheet.getCellByPosition(1, nFila - 1).setString(sDescripcion)
            
            REM Registrar resultado y generar keywords
            If Left(sDescripcion, 5) = "Error" Then
                nErrores = nErrores + 1
                oSheet.getCellByPosition(2, nFila - 1).setString("ERROR")
                oSheet.getCellByPosition(3, nFila - 1).setString("")
            Else
                nProcesadas = nProcesadas + 1
                oSheet.getCellByPosition(2, nFila - 1).setString("OK")
                
                REM Generar keywords de la descripcion
                oSheet.getCellByPosition(3, nFila - 1).setString("Generando keywords...")
                Wait(1000)
                sKeywords = GenerarKeywords(sDescripcion)
                If Len(Trim(sKeywords)) = 0 Then
                    sKeywords = "[Vacio]"
                End If
                oSheet.getCellByPosition(3, nFila - 1).setString(sKeywords)
                
                REM Generar imagenes del producto
                oSheet.getCellByPosition(4, nFila - 1).setString("Generando imagenes...")
                Wait(2000)
                On Error Resume Next
                Dim sImagenes
                Dim nErrorBeforeDalle
                nErrorBeforeDalle = Err.Number
                Err.Clear
                sImagenes = GenerarImagenesProducto(sImageURL, sDescripcion, nFila)
                Dim nErrorAfterDalle
                nErrorAfterDalle = Err.Number
                
                REM DEBUG: Log image generation result
                nDebugMain = FreeFile()
                Open "/tmp/main_debug.log" For Append As #nDebugMain
                Print #nDebugMain, "Row " & nFila & " - After GenerarImagenesProducto:"
                Print #nDebugMain, "  sImagenes value: " & sImagenes
                Print #nDebugMain, "  sImagenes length: " & Len(sImagenes)
                Print #nDebugMain, "  Err.Number before: " & nErrorBeforeDalle
                Print #nDebugMain, "  Err.Number after: " & nErrorAfterDalle
                Close #nDebugMain
                Err.Clear
                
                If nErrorAfterDalle <> 0 Then
                    oSheet.getCellByPosition(4, nFila - 1).setString("Error en imagenes")
                    oSheet.getCellByPosition(5, nFila - 1).setString("")
                Else
                    REM Si sImagenes es una URL (contiene http), guardarla en columna F
                    If InStr(sImagenes, "http") > 0 Then
                        oSheet.getCellByPosition(4, nFila - 1).setString("Image generated")
                        oSheet.getCellByPosition(5, nFila - 1).setString(sImagenes)
                    Else
                        oSheet.getCellByPosition(4, nFila - 1).setString(sImagenes)
                        oSheet.getCellByPosition(5, nFila - 1).setString("")
                    End If
                End If
                Err.Clear
                On Error GoTo 0
            End If
            nFila = nFila + 1
            
            REM Pausas para respetar limites de API
            Wait(3000)
            If (nProcesadas + nErrores) Mod 10 = 0 Then
                Wait(2000)
            End If
        End If
    Wend
    
    Dim nTiempo
    nTiempo = Int((Timer - nInicio) / 60)
    
    MsgBox "COMPLETADO" & Chr(10) & "Procesadas: " & nProcesadas & Chr(10) & "Errores: " & nErrores & Chr(10) & "Tiempo: " & nTiempo & " min"
End Sub

REM Llama a la API de OpenAI Vision usando curl en Linux
Function LlamarOpenAI(sURL)
    Dim sTempDir
    Dim sShellScript
    Dim sResponseFile
    Dim sJsonFile
    Dim sComando
    Dim sRespuesta
    Dim nFile
    Dim Q
    Dim sApiKey
    Dim sJsonBody
    Dim nIntentos
    Dim sResultado
    
    Q = Chr(34)
    
    REM CONFIGURACION: Reemplazar con tu API key de OpenAI
    sApiKey = "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"
    
    REM Archivos temporales - Ubuntu/Linux
    sTempDir = "/tmp"
    sShellScript = sTempDir & "/openai_call.sh"
    sResponseFile = sTempDir & "/openai_response.txt"
    sJsonFile = sTempDir & "/openai_request.json"
    
    REM Construir JSON para la API
    sJsonBody = "{" & Q & "model" & Q & ": " & Q & "gpt-4o-mini" & Q & ", "
    sJsonBody = sJsonBody & Q & "messages" & Q & ": [{" & Q & "role" & Q & ": " & Q & "user" & Q & ", "
    sJsonBody = sJsonBody & Q & "content" & Q & ": [{" & Q & "type" & Q & ": " & Q & "text" & Q & ", "
    sJsonBody = sJsonBody & Q & "text" & Q & ": " & Q & "Describe this clothing item in Spanish for a product catalog. Include: type of garment, color, material if visible, style (casual/formal), and any notable details like patterns or design elements. Keep it between 20-40 words." & Q & "}, "
    sJsonBody = sJsonBody & "{" & Q & "type" & Q & ": " & Q & "image_url" & Q & ", "
    sJsonBody = sJsonBody & Q & "image_url" & Q & ": {" & Q & "url" & Q & ": " & Q & sURL & Q & "}}]}], "
    sJsonBody = sJsonBody & Q & "max_tokens" & Q & ": 150}"
    
    REM Reintentar hasta 3 veces
    nIntentos = 0
    sResultado = "Error: Sin respuesta"
    
    While nIntentos < 3
        nIntentos = nIntentos + 1
        
        On Error Resume Next
        
        REM Escribir archivo JSON
        nFile = FreeFile()
        Open sJsonFile For Output As #nFile
        Print #nFile, sJsonBody
        Close #nFile
        
        REM Crear script bash para Linux (en lugar de batch de Windows)
        sComando = "#!/bin/bash" & Chr(13) & Chr(10)
        sComando = sComando & "curl -s -X POST " & Q & "https://api.openai.com/v1/chat/completions" & Q & " "
        sComando = sComando & "-H " & Q & "Content-Type: application/json" & Q & " "
        sComando = sComando & "-H " & Q & "Authorization: Bearer " & sApiKey & Q & " "
        sComando = sComando & "-d @" & Q & sJsonFile & Q & " "
        sComando = sComando & "> " & Q & sResponseFile & Q & " 2>&1" & Chr(13) & Chr(10)
        
        REM Escribir script bash
        nFile = FreeFile()
        Open sShellScript For Output As #nFile
        Print #nFile, sComando
        Close #nFile
        
        REM Hacer el script ejecutable y ejecutarlo (Linux)
        Shell("chmod +x " & Q & sShellScript & Q, 0, True)
        Wait(500)
        Shell(sShellScript, 0, True)
        Wait(8000)
        
        REM Leer respuesta
        sRespuesta = ""
        On Error Resume Next
        nFile = FreeFile()
        Open sResponseFile For Input As #nFile
        If Err.Number = 0 Then
            While Not EOF(nFile)
                Dim sLinea
                Line Input #nFile, sLinea
                sRespuesta = sRespuesta & sLinea & Chr(10)
            Wend
            Close #nFile
        Else
            sRespuesta = ""
            Err.Clear
        End If
        On Error GoTo 0
        
        sResultado = ExtraerDescripcionOpenAI(sRespuesta)
        
        If Left(sResultado, 5) <> "Error" Then
            nIntentos = 3
        Else
            If nIntentos < 3 Then
                Wait(5000)
            End If
        End If
    Wend
    
    REM Limpiar archivos temporales
    On Error Resume Next
    Shell("rm -f " & Q & sShellScript & Q, 0, True)
    Shell("rm -f " & Q & sResponseFile & Q, 0, True)
    Shell("rm -f " & Q & sJsonFile & Q, 0, True)
    On Error GoTo 0
    
    REM DEBUG: Escribir respuesta al log
    On Error Resume Next
    Dim nDebugFile
    nDebugFile = FreeFile()
    Open "/tmp/openai_vision_debug.log" For Append As #nDebugFile
    Print #nDebugFile, "=== Vision API Call ==="
    Print #nDebugFile, "URL: " & sURL
    Print #nDebugFile, "Response length: " & Len(sRespuesta)
    Print #nDebugFile, "First 500 chars: " & Left(sRespuesta, 500)
    Print #nDebugFile, "Result: " & sResultado
    Print #nDebugFile, ""
    Close #nDebugFile
    Err.Clear
    On Error GoTo 0
    
    LlamarOpenAI = sResultado
End Function

REM Extrae la descripcion del JSON de respuesta
Function ExtraerDescripcionOpenAI(sJSON)
    Dim nPos
    Dim nStart
    Dim nEnd
    Dim sTexto
    
    REM Verificar si hay error
    If InStr(sJSON, "error") > 0 Then
        nPos = InStr(sJSON, "message")
        If nPos > 0 Then
            nStart = InStr(nPos, sJSON, ":") + 1
            nStart = InStr(nStart, sJSON, Chr(34)) + 1
            nEnd = InStr(nStart, sJSON, Chr(34))
            If nEnd > nStart Then
                ExtraerDescripcionOpenAI = "Error: " & Mid(sJSON, nStart, nEnd - nStart)
                Exit Function
            End If
        End If
        ExtraerDescripcionOpenAI = "Error API"
        Exit Function
    End If
    
    REM Buscar campo content
    nPos = InStr(sJSON, "content")
    If nPos = 0 Then
        ExtraerDescripcionOpenAI = "Sin descripcion"
        Exit Function
    End If
    
    REM Extraer texto
    nStart = InStr(nPos, sJSON, ":") + 1
    nStart = InStr(nStart, sJSON, Chr(34)) + 1
    nEnd = InStr(nStart, sJSON, Chr(34))
    
    If nEnd > nStart Then
        sTexto = Mid(sJSON, nStart, nEnd - nStart)
        sTexto = Replace(sTexto, "\n", " ")
        sTexto = Replace(sTexto, "\\", "")
        sTexto = CorregirCaracteresEspanol(sTexto)
        ExtraerDescripcionOpenAI = sTexto
    Else
        ExtraerDescripcionOpenAI = "Error extraccion"
    End If
End Function

REM Corrige caracteres especiales del espanol
Function CorregirCaracteresEspanol(sTexto)
    Dim sResultado
    sResultado = sTexto
    sResultado = Replace(sResultado, "\u00e1", "á")
    sResultado = Replace(sResultado, "\u00e9", "é")
    sResultado = Replace(sResultado, "\u00ed", "í")
    sResultado = Replace(sResultado, "\u00f3", "ó")
    sResultado = Replace(sResultado, "\u00fa", "ú")
    sResultado = Replace(sResultado, "\u00f1", "ñ")
    sResultado = Replace(sResultado, "\u00fc", "ü")
    CorregirCaracteresEspanol = sResultado
End Function

REM Elimina menciones de colores
Function EliminarColores(sTexto)
    Dim sResultado
    sResultado = sTexto
    sResultado = Replace(sResultado, "rojo", "")
    sResultado = Replace(sResultado, "azul", "")
    sResultado = Replace(sResultado, "verde", "")
    sResultado = Replace(sResultado, "amarillo", "")
    sResultado = Replace(sResultado, "negro", "")
    sResultado = Replace(sResultado, "blanco", "")
    sResultado = Replace(sResultado, "gris", "")
    sResultado = Replace(sResultado, "rosa", "")
    sResultado = Replace(sResultado, "naranja", "")
    sResultado = Replace(sResultado, "morado", "")
    sResultado = Replace(sResultado, "marrón", "")
    EliminarColores = Trim(sResultado)
End Function

REM Genera keywords de la descripcion usando OpenAI
Function GenerarKeywords(sDescripcion)
    Dim sJsonBody
    Dim sApiKey
    Dim sTempDir
    Dim sJsonFile
    Dim sResponseFile
    Dim sShellScript
    Dim nFile
    Dim Q
    Dim sComando
    Dim sRespuesta
    Dim sResultado
    
    Q = Chr(34)
    
    sApiKey = "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"
    
    sTempDir = "/tmp"
    sJsonFile = sTempDir & "/keywords_request.json"
    sResponseFile = sTempDir & "/keywords_response.txt"
    sShellScript = sTempDir & "/keywords_call.sh"
    
    REM Escapar comillas en la descripcion
    Dim sDescripcionEscapada
    sDescripcionEscapada = Replace(sDescripcion, Chr(34), "\\" & Chr(34))
    
    sJsonBody = "{" & Q & "model" & Q & ": " & Q & "gpt-4o-mini" & Q & ", "
    sJsonBody = sJsonBody & Q & "messages" & Q & ": [{" & Q & "role" & Q & ": " & Q & "user" & Q & ", "
    sJsonBody = sJsonBody & Q & "content" & Q & ": " & Q & "Extract 5-7 key keywords from this product description in Spanish: " & sDescripcionEscapada & ". Return only comma-separated keywords." & Q & "}], "
    sJsonBody = sJsonBody & Q & "max_tokens" & Q & ": 50}"
    
    On Error Resume Next
    
    REM Escribir JSON
    nFile = FreeFile()
    Open sJsonFile For Output As #nFile
    Print #nFile, sJsonBody
    Close #nFile
    
    REM Crear script bash
    sComando = "#!/bin/bash" & Chr(13) & Chr(10)
    sComando = sComando & "curl -s -X POST " & Q & "https://api.openai.com/v1/chat/completions" & Q & " "
    sComando = sComando & "-H " & Q & "Content-Type: application/json" & Q & " "
    sComando = sComando & "-H " & Q & "Authorization: Bearer " & sApiKey & Q & " "
    sComando = sComando & "-d @" & Q & sJsonFile & Q & " "
    sComando = sComando & "> " & Q & sResponseFile & Q & " 2>&1" & Chr(13) & Chr(10)
    
    nFile = FreeFile()
    Open sShellScript For Output As #nFile
    Print #nFile, sComando
    Close #nFile
    
    Shell("chmod +x " & Q & sShellScript & Q, 0, True)
    Wait(500)
    Shell(sShellScript, 0, True)
    Wait(5000)
    
    REM Leer respuesta
    sRespuesta = ""
    On Error Resume Next
    nFile = FreeFile()
    Open sResponseFile For Input As #nFile
    If Err.Number = 0 Then
        While Not EOF(nFile)
            Dim sLinea
            Line Input #nFile, sLinea
            sRespuesta = sRespuesta & sLinea & Chr(10)
        Wend
        Close #nFile
    Else
        sRespuesta = ""
        Err.Clear
    End If
    On Error GoTo 0
    
    sResultado = ExtraerDescripcionOpenAI(sRespuesta)
    
    REM Limpiar
    On Error Resume Next
    Shell("rm -f " & Q & sJsonFile & Q, 0, True)
    Shell("rm -f " & Q & sResponseFile & Q, 0, True)
    Shell("rm -f " & Q & sShellScript & Q, 0, True)
    Err.Clear
    On Error GoTo 0
    
    GenerarKeywords = sResultado
End Function

REM Genera imagenes del producto usando DALL-E 3
Function GenerarImagenesProducto(sImageURL, sDescripcion, nFila)
    Dim sJsonBody
    Dim sApiKey
    Dim sTempDir
    Dim sJsonFile
    Dim sResponseFile
    Dim sShellScript
    Dim nFile
    Dim Q
    Dim sComando
    Dim sRespuesta
    Dim sResultado
    Dim sGeneratedImageUrl
    Dim sLogFile
    
    Q = Chr(34)
    
    sApiKey = "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"
    
    sTempDir = "/tmp"
    sJsonFile = sTempDir & "/dalle_request_" & nFila & ".json"
    sResponseFile = sTempDir & "/dalle_response_" & nFila & ".txt"
    sShellScript = sTempDir & "/dalle_call_" & nFila & ".sh"
    sLogFile = sTempDir & "/dalle_debug_" & nFila & ".log"
    
    REM Crear JSON simple y limpio (sin caracteres especiales)
    sJsonBody = "{" & Q & "model" & Q & ": " & Q & "dall-e-3" & Q & ", "
    sJsonBody = sJsonBody & Q & "prompt" & Q & ": " & Q & "Professional product photo of clothing item" & Q & ", "
    sJsonBody = sJsonBody & Q & "n" & Q & ": 1, "
    sJsonBody = sJsonBody & Q & "size" & Q & ": " & Q & "1024x1024" & Q & ", "
    sJsonBody = sJsonBody & Q & "quality" & Q & ": " & Q & "standard" & Q & "}"
    
    On Error Resume Next
    
    REM Escribir JSON
    nFile = FreeFile()
    Open sJsonFile For Output As #nFile
    Print #nFile, sJsonBody
    Close #nFile
    
    REM Crear script bash con debug logging
    sComando = "#!/bin/bash" & Chr(13) & Chr(10)
    sComando = sComando & "echo " & Q & "=== Debug Log ===" & Q & " > " & Q & sLogFile & Q & Chr(13) & Chr(10)
    sComando = sComando & "echo " & Q & "JSON File:" & Q & " >> " & Q & sLogFile & Q & Chr(13) & Chr(10)
    sComando = sComando & "cat " & Q & sJsonFile & Q & " >> " & Q & sLogFile & Q & Chr(13) & Chr(10)
    sComando = sComando & "echo " & Q & "Calling API..." & Q & " >> " & Q & sLogFile & Q & Chr(13) & Chr(10)
    sComando = sComando & "curl -s -X POST https://api.openai.com/v1/images/generations \" & Chr(13) & Chr(10)
    sComando = sComando & "  -H " & Q & "Content-Type: application/json" & Q & " \" & Chr(13) & Chr(10)
    sComando = sComando & "  -H " & Q & "Authorization: Bearer " & sApiKey & Q & " \" & Chr(13) & Chr(10)
    sComando = sComando & "  -d @" & Q & sJsonFile & Q & " > " & Q & sResponseFile & Q & " 2>&1" & Chr(13) & Chr(10)
    sComando = sComando & "echo " & Q & "Response:" & Q & " >> " & Q & sLogFile & Q & Chr(13) & Chr(10)
    sComando = sComando & "cat " & Q & sResponseFile & Q & " >> " & Q & sLogFile & Q & Chr(13) & Chr(10)
    
    nFile = FreeFile()
    Open sShellScript For Output As #nFile
    Print #nFile, sComando
    Close #nFile
    
    Shell("chmod +x " & Q & sShellScript & Q, 0, True)
    Wait(500)
    Shell(sShellScript, 0, True)
    Wait(20000)
    
    REM Leer respuesta
    sRespuesta = ""
    On Error Resume Next
    nFile = FreeFile()
    Open sResponseFile For Input As #nFile
    If Err.Number = 0 Then
        While Not EOF(nFile)
            Dim sLinea
            Line Input #nFile, sLinea
            sRespuesta = sRespuesta & sLinea & Chr(10)
        Wend
        Close #nFile
    Else
        sRespuesta = ""
        Err.Clear
    End If
    On Error GoTo 0
    
    REM Debug: escribir respuesta completa al log (con error handling)
    Dim nDebugFile
    On Error Resume Next
    nDebugFile = FreeFile()
    Open sLogFile For Append As #nDebugFile
    Print #nDebugFile, "DEBUG: sRespuesta length = " & Len(sRespuesta)
    Print #nDebugFile, "DEBUG: sRespuesta contains 'url' = " & (InStr(sRespuesta, "url") > 0)
    Print #nDebugFile, "DEBUG: sRespuesta first 500 chars = " & Left(sRespuesta, 500)
    Close #nDebugFile
    Err.Clear
    On Error GoTo 0
    
    REM Extraer URL de imagen - construir patron con Chr(34)
    sResultado = "Error generating image"
    Dim nDebugFile2
    
    On Error Resume Next
    
    If Len(Trim(sRespuesta)) > 0 Then
        Dim nUrlStart, nUrlEnd
        Dim sSearchStr
        REM Construir el patron "url": " usando Chr(34)
        sSearchStr = Chr(34) & "url" & Chr(34) & ": " & Chr(34)
        nUrlStart = InStr(sRespuesta, sSearchStr)
        
        REM Debug detallado
        nDebugFile2 = FreeFile()
        Open sLogFile For Append As #nDebugFile2
        Print #nDebugFile2, "DEBUG: sSearchStr = " & sSearchStr
        Print #nDebugFile2, "DEBUG: nUrlStart = " & nUrlStart
        Close #nDebugFile2
        
        If nUrlStart > 0 Then
            REM Ajustar para apuntar al inicio de la URL (después de "url": ")
            nUrlStart = nUrlStart + Len(sSearchStr)
            REM Encontrar el siguiente quote que cierra la URL
            nUrlEnd = InStr(nUrlStart, sRespuesta, Chr(34))
            
            nDebugFile2 = FreeFile()
            Open sLogFile For Append As #nDebugFile2
            Print #nDebugFile2, "DEBUG: After adjustment nUrlStart = " & nUrlStart
            Print #nDebugFile2, "DEBUG: nUrlEnd = " & nUrlEnd
            Print #nDebugFile2, "DEBUG: Difference = " & (nUrlEnd - nUrlStart)
            Close #nDebugFile2
            
            If nUrlEnd > nUrlStart Then
                sGeneratedImageUrl = Mid(sRespuesta, nUrlStart, nUrlEnd - nUrlStart)
                
                nDebugFile2 = FreeFile()
                Open sLogFile For Append As #nDebugFile2
                Print #nDebugFile2, "DEBUG: URL extracted = " & Left(sGeneratedImageUrl, 100) & "..."
                Print #nDebugFile2, "DEBUG: URL length = " & Len(sGeneratedImageUrl)
                Close #nDebugFile2
                
                If Len(Trim(sGeneratedImageUrl)) > 20 Then
                    sResultado = sGeneratedImageUrl
                    
                    nDebugFile2 = FreeFile()
                    Open sLogFile For Append As #nDebugFile2
                    Print #nDebugFile2, "DEBUG: Result = SUCCESS - Image generated"
                    Close #nDebugFile2
                End If
            Else
                nDebugFile2 = FreeFile()
                Open sLogFile For Append As #nDebugFile2
                Print #nDebugFile2, "DEBUG: Failed - nUrlEnd not > nUrlStart"
                Close #nDebugFile2
            End If
        Else
            nDebugFile2 = FreeFile()
            Open sLogFile For Append As #nDebugFile2
            Print #nDebugFile2, "DEBUG: Pattern not found"
            Close #nDebugFile2
        End If
    End If
    
    On Error GoTo 0
    
    REM Limpiar archivos temporales (mantener log para debug)
    On Error Resume Next
    Shell("rm -f " & Q & sJsonFile & Q, 0, True)
    Shell("rm -f " & Q & sResponseFile & Q, 0, True)
    Shell("rm -f " & Q & sShellScript & Q, 0, True)
    Err.Clear
    On Error GoTo 0
    
    GenerarImagenesProducto = sResultado
End Function
