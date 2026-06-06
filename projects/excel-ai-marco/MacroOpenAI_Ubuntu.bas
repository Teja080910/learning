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

REM Test macro - creates a file to verify macro is running
Sub TestMacroExecution()
    Dim nFile
    nFile = FreeFile()
    Open "/tmp/macro_test.txt" For Output As #nFile
    Print #nFile, "Macro execution test at " & Now()
    Close #nFile
    MsgBox "Test file created at /tmp/macro_test.txt"
End Sub

REM Escapa caracteres especiales para JSON
Function EscapeJSON(sText)
    Dim sResult
    sResult = sText
    sResult = Replace(sResult, "\", "\\")
    sResult = Replace(sResult, Chr(34), "\\" & Chr(34))
    sResult = Replace(sResult, Chr(10), "\n")
    sResult = Replace(sResult, Chr(13), "\n")
    sResult = Replace(sResult, Chr(9), "\t")
    EscapeJSON = sResult
End Function

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
                    REM Separar las 6 rutas locales y colocarlas en columnas E-J
                    Dim aURLs
                    aURLs = Split(sImagenes, "|")
                    
                    If UBound(aURLs) >= 5 Then
                        oSheet.getCellByPosition(4, nFila - 1).setString(aURLs(0))
                        oSheet.getCellByPosition(5, nFila - 1).setString(aURLs(1))
                        oSheet.getCellByPosition(6, nFila - 1).setString(aURLs(2))
                        oSheet.getCellByPosition(7, nFila - 1).setString(aURLs(3))
                        oSheet.getCellByPosition(8, nFila - 1).setString(aURLs(4))
                        oSheet.getCellByPosition(9, nFila - 1).setString(aURLs(5))
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
    
    REM Construir JSON para la API - FIXED JSON STRUCTURE
    Dim sEscapedURL
    sEscapedURL = EscapeJSON(sURL)
    sJsonBody = "{" & Q & "model" & Q & ":" & Q & "gpt-4o-mini" & Q & ","
    sJsonBody = sJsonBody & Q & "messages" & Q & ":[{"
    sJsonBody = sJsonBody & Q & "role" & Q & ":" & Q & "user" & Q & ","
    sJsonBody = sJsonBody & Q & "content" & Q & ":["
    sJsonBody = sJsonBody & "{"
    sJsonBody = sJsonBody & Q & "type" & Q & ":" & Q & "text" & Q & ","
    sJsonBody = sJsonBody & Q & "text" & Q & ":" & Q & "Describe this clothing item in Spanish for a product catalog. Include: type of garment, color, material if visible, style (casual/formal), and any notable details like patterns or design elements. Keep it between 20-40 words." & Q
    sJsonBody = sJsonBody & "},"
    sJsonBody = sJsonBody & "{"
    sJsonBody = sJsonBody & Q & "type" & Q & ":" & Q & "image_url" & Q & ","
    sJsonBody = sJsonBody & Q & "image_url" & Q & ":{"
    sJsonBody = sJsonBody & Q & "url" & Q & ":" & Q & sEscapedURL & Q
    sJsonBody = sJsonBody & "}"
    sJsonBody = sJsonBody & "}"
    sJsonBody = sJsonBody & "]"
    sJsonBody = sJsonBody & "}],"
    sJsonBody = sJsonBody & Q & "max_tokens" & Q & ":150}"
    
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
    
    REM Escapar caracteres especiales para JSON
    Dim sDescripcionEscapada
    sDescripcionEscapada = EscapeJSON(sDescripcion)
    
    sJsonBody = "{" & Q & "model" & Q & ":" & Q & "gpt-4o-mini" & Q & ","
    sJsonBody = sJsonBody & Q & "messages" & Q & ":[{"
    sJsonBody = sJsonBody & Q & "role" & Q & ":" & Q & "user" & Q & ","
    sJsonBody = sJsonBody & Q & "content" & Q & ":" & Q & "Extract 5-7 key keywords from this product description in Spanish: " & sDescripcionEscapada & ". Return only comma-separated keywords." & Q
    sJsonBody = sJsonBody & "}],"
    sJsonBody = sJsonBody & Q & "max_tokens" & Q & ":50}"
    
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
    Dim aImagenes()
    Dim aContextos()
    Dim aVistas()
    Dim i As Integer
    Dim j As Integer
    Dim idx As Integer
    Dim sPrompt As String
    Dim sImagenURL As String
    Dim sArchivoLocal As String
    Dim sNombreBase As String
    Dim sArticuloRef As String
    Dim sCarpetaDestino As String
    Dim sComando As String
    Dim Q As String
    Dim nDebugFile As Integer
    
    REM Initialize arrays first with proper ReDim
    ReDim aImagenes(5)
    ReDim aContextos(2)
    ReDim aVistas(1)
    
    REM DEBUG: Log array initialization success
    nDebugFile = FreeFile()
    Open "/tmp/dalle_generation_debug.log" For Append As #nDebugFile
    Print #nDebugFile, "=== ARRAYS INITIALIZED SUCCESSFULLY ==="
    Close #nDebugFile
    
    Q = Chr(34)
    
    REM DEBUG: Log entry
    nDebugFile = FreeFile()
    Open "/tmp/dalle_generation_debug.log" For Append As #nDebugFile
    Print #nDebugFile, "=== FUNCTION ENTRY: GenerarImagenesProducto for row " & nFila & " at " & Now() & " ==="
    Print #nDebugFile, "Inputs - ImageURL: " & sImageURL
    Print #nDebugFile, "Inputs - Descripcion length: " & Len(sDescripcion)
    Close #nDebugFile
    
    REM DEBUG: Before mkdir
    nDebugFile = FreeFile()
    Open "/tmp/dalle_generation_debug.log" For Append As #nDebugFile
    Print #nDebugFile, "=== BEFORE MKDIR COMMAND ==="
    Close #nDebugFile
    
    REM Definir carpeta de destino
    sCarpetaDestino = "/home/teja/Desktop/learning/macro_images"
    
    REM Crear carpeta si no existe (Linux compatible)
    sComando = "mkdir -p /home/teja/Desktop/learning/macro_images"
    Shell(sComando, 0, True)
    
    REM DEBUG: After mkdir
    nDebugFile = FreeFile()
    Open "/tmp/dalle_generation_debug.log" For Append As #nDebugFile
    Print #nDebugFile, "=== AFTER MKDIR COMMAND ==="
    Close #nDebugFile
    
    Wait(500)
    
    REM Definir contextos y vistas
    aContextos(0) = "urban city street background"
    aContextos(1) = "beach seaside background"
    aContextos(2) = "mountain rural countryside background"
    
    aVistas(0) = "front view"
    aVistas(1) = "side profile view"
    
    REM Extraer referencia de articulo de la URL
    sArticuloRef = ExtraerArticuloRef(sImageURL)
    If Len(Trim(sArticuloRef)) = 0 Then
        sArticuloRef = "articulo_" & nFila
    End If
    
    REM Nombre base para archivos - usando nomenclatura F_XXXXX_1_1.jpg
    sNombreBase = sArticuloRef & "_"
    
    REM DEBUG: Log after all initialization
    nDebugFile = FreeFile()
    Open "/tmp/dalle_generation_debug.log" For Append As #nDebugFile
    Print #nDebugFile, "=== ABOUT TO ENTER FOR LOOP ==="
    Print #nDebugFile, "Article ref: " & sArticuloRef
    Print #nDebugFile, "Base name: " & sNombreBase
    Close #nDebugFile
    
    REM Generar 6 imagenes (3 contextos x 2 vistas)
    idx = 1
    For i = 0 To 0  REM TEMPORARY: Generate only 1 image for debugging
        REM DEBUG: Log inside outer loop
        nDebugFile = FreeFile()
        Open "/tmp/dalle_generation_debug.log" For Append As #nDebugFile
        Print #nDebugFile, "INSIDE OUTER LOOP: i=" & i
        Close #nDebugFile
        
        For j = 0 To 0
            REM DEBUG: Log inside inner loop
            nDebugFile = FreeFile()
            Open "/tmp/dalle_generation_debug.log" For Append As #nDebugFile
            Print #nDebugFile, "INSIDE INNER LOOP: i=" & i & ", j=" & j
            Close #nDebugFile
            
            sPrompt = "Professional casual fashion product photography: on a model, front view, urban city street background, natural daylight, high quality, professional style, suitable for online retail"
            
            REM DEBUG: Log before DALL-E call
            nDebugFile = FreeFile()
            Open "/tmp/dalle_generation_debug.log" For Append As #nDebugFile
            Print #nDebugFile, "About to call GenerarImagenDALLE with prompt length: " & Len(sPrompt)
            Close #nDebugFile
            
            sImagenURL = GenerarImagenDALLE(sPrompt)
            
            REM DEBUG: Log DALL-E result
            nDebugFile = FreeFile()
            Open "/tmp/dalle_generation_debug.log" For Append As #nDebugFile
            Print #nDebugFile, "DALL-E returned URL length: " & Len(sImagenURL)
            Print #nDebugFile, "DALL-E returned (first 200 chars): " & Left(sImagenURL, 200)
            Close #nDebugFile
            
            REM Descargar imagen a carpeta local
            If Left(sImagenURL, 5) <> "Error" And Len(Trim(sImagenURL)) > 0 Then
                sArchivoLocal = DescargarImagenLocal(sImagenURL, sCarpetaDestino, sNombreBase & "1_1")
                aImagenes(0) = sArchivoLocal
                
                REM DEBUG: Log download result
                nDebugFile = FreeFile()
                Open "/tmp/dalle_generation_debug.log" For Append As #nDebugFile
                Print #nDebugFile, "Image downloaded to: " & sArchivoLocal
                Close #nDebugFile
            Else
                aImagenes(0) = "[Error]"
                
                REM DEBUG: Log error
                nDebugFile = FreeFile()
                Open "/tmp/dalle_generation_debug.log" For Append As #nDebugFile
                Print #nDebugFile, "ERROR: Invalid URL returned - " & sImagenURL
                Close #nDebugFile
            End If
            
            idx = idx + 1
        Next j
    Next i
    
    REM DEBUG: Log array contents before return
    nDebugFile = FreeFile()
    Open "/tmp/dalle_generation_debug.log" For Append As #nDebugFile
    Print #nDebugFile, "Array[0] = " & aImagenes(0)
    Print #nDebugFile, "Array[0] length = " & Len(aImagenes(0))
    Print #nDebugFile, "About to return from GenerarImagenesProducto"
    Close #nDebugFile
    
    REM Retornar ruta local (simplified for testing - just return first image)
    If Len(Trim(aImagenes(0))) > 0 And Left(aImagenes(0), 7) <> "[Error]" Then
        GenerarImagenesProducto = aImagenes(0)
    Else
        GenerarImagenesProducto = "[Error]"
    End If
End Function

REM Descarga una imagen desde URL y la guarda localmente
Function DescargarImagenLocal(sURL, sCarpetaDestino, sNombreArchivo)
    Dim sShellScript
    Dim sArchivoDestino
    Dim sComando
    Dim nFile
    Dim Q
    Dim sErrorLog
    Dim nDebugFile
    Dim nTimestamp
    
    Q = Chr(34)
    
    REM Crear carpeta si no existe (Linux compatible)
    sComando = "mkdir -p /home/teja/Desktop/learning/macro_images 2>&1"
    Shell(sComando, 0, True)
    Wait(500)
    
    REM Archivo destino - usar ruta Linux
    sArchivoDestino = "/home/teja/Desktop/learning/macro_images/" & sNombreArchivo & ".jpg"
    sErrorLog = "/tmp/download_image.log"
    
    REM Crear script bash para descargar con mejor manejo de errores
    nTimestamp = Timer()
    sShellScript = "/tmp/download_img_" & Int(nTimestamp) & ".sh"
    
    sComando = "#!/bin/bash" & Chr(13) & Chr(10)
    sComando = sComando & "curl -L --max-time 30 -o " & Q & sArchivoDestino & Q & " " & Q & sURL & Q & " 2>&1 | tee " & Q & sErrorLog & Q & Chr(13) & Chr(10)
    sComando = sComando & "if [ -f " & Q & sArchivoDestino & Q & " ]; then" & Chr(13) & Chr(10)
    sComando = sComando & "  echo " & Q & "SUCCESS" & Q & " >> " & Q & sErrorLog & Q & Chr(13) & Chr(10)
    sComando = sComando & "else" & Chr(13) & Chr(10)
    sComando = sComando & "  echo " & Q & "FAILED" & Q & " >> " & Q & sErrorLog & Q & Chr(13) & Chr(10)
    sComando = sComando & "fi" & Chr(13) & Chr(10)
    
    nFile = FreeFile()
    Open sShellScript For Output As #nFile
    Print #nFile, sComando
    Close #nFile
    
    REM Hacer ejecutable y ejecutar
    Shell("chmod +x " & Q & sShellScript & Q, 0, True)
    Wait(500)
    Shell(sShellScript, 0, True)
    Wait(8000)
    
    REM Registrar resultado en debug log
    On Error Resume Next
    nDebugFile = FreeFile()
    Open "/tmp/image_download_debug.log" For Append As #nDebugFile
    Print #nDebugFile, "Download attempt:"
    Print #nDebugFile, "  URL: " & sURL
    Print #nDebugFile, "  File: " & sArchivoDestino
    Print #nDebugFile, "  Script: " & sShellScript
    Print #nDebugFile, "  Error log contents:"
    
    REM Leer log de errores
    Dim nErrorFile
    nErrorFile = FreeFile()
    If Dir(sErrorLog) <> "" Then
        Open sErrorLog For Input As #nErrorFile
        While Not EOF(nErrorFile)
            Dim sErrorLine
            Line Input #nErrorFile, sErrorLine
            Print #nDebugFile, "    " & sErrorLine
        Wend
        Close #nErrorFile
    End If
    
    Print #nDebugFile, ""
    Close #nDebugFile
    On Error GoTo 0
    
    REM Limpiar scripts temporales
    On Error Resume Next
    Shell("rm -f " & Q & sShellScript & Q, 0, True)
    Shell("rm -f " & Q & sErrorLog & Q, 0, True)
    On Error GoTo 0
    
    REM Retornar ruta local
    DescargarImagenLocal = sArchivoDestino
End Function

REM Llama a DALL-E para generar una imagen
Function GenerarImagenDALLE(sPrompt)
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
    Dim nDebugFile
    Dim sLinea
    Dim nUrlStart, nUrlEnd, nErrorPos, nErrorStart, nErrorEnd
    Dim sSearchStr
    
    Q = Chr(34)
    
    REM Write entry point log
    On Error Resume Next
    nDebugFile = FreeFile()
    Open "/tmp/dalle_generation_debug.log" For Append As #nDebugFile
    Print #nDebugFile, "DALLE_FUNCTION_ENTRY: " & Now()
    Close #nDebugFile
    Err.Clear
    On Error GoTo 0
    
    sApiKey = "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"
    
    sTempDir = "/tmp"
    sJsonFile = sTempDir & "/dalle_request.json"
    sResponseFile = sTempDir & "/dalle_response.txt"
    sShellScript = sTempDir & "/dalle_call.sh"
    sLogFile = sTempDir & "/dalle_debug.log"
    
    REM Limpiar prompt (remover caracteres problematicos)
    Dim sPromptLimpio
    sPromptLimpio = EscapeJSON(sPrompt)
    sPromptLimpio = Replace(sPromptLimpio, "á", "a")
    sPromptLimpio = Replace(sPromptLimpio, "é", "e")
    sPromptLimpio = Replace(sPromptLimpio, "í", "i")
    sPromptLimpio = Replace(sPromptLimpio, "ó", "o")
    sPromptLimpio = Replace(sPromptLimpio, "ú", "u")
    sPromptLimpio = Replace(sPromptLimpio, "ñ", "n")
    
    REM Crear JSON simple y limpio
    sJsonBody = "{" & Q & "model" & Q & ":" & Q & "dall-e-3" & Q & ","
    sJsonBody = sJsonBody & Q & "prompt" & Q & ":" & Q & sPromptLimpio & Q & ","
    sJsonBody = sJsonBody & Q & "n" & Q & ":1,"
    sJsonBody = sJsonBody & Q & "size" & Q & ":" & Q & "1024x1024" & Q & ","
    sJsonBody = sJsonBody & Q & "quality" & Q & ":" & Q & "standard" & Q & "}"
    
    On Error Resume Next
    
    REM Escribir JSON
    nFile = FreeFile()
    Open sJsonFile For Output As #nFile
    Print #nFile, sJsonBody
    Close #nFile
    
    REM Crear script bash con curl
    sComando = "#!/bin/bash" & Chr(13) & Chr(10)
    sComando = sComando & "curl -s -X POST https://api.openai.com/v1/images/generations \" & Chr(13) & Chr(10)
    sComando = sComando & "  -H " & Q & "Content-Type: application/json" & Q & " \" & Chr(13) & Chr(10)
    sComando = sComando & "  -H " & Q & "Authorization: Bearer " & sApiKey & Q & " \" & Chr(13) & Chr(10)
    sComando = sComando & "  -d @" & Q & sJsonFile & Q & " 2>&1 > " & Q & sResponseFile & Q & Chr(13) & Chr(10)
    sComando = sComando & "echo 'CURL_EXIT_CODE:'$?" & Chr(13) & Chr(10)
    
    nFile = FreeFile()
    Open sShellScript For Output As #nFile
    Print #nFile, sComando
    Close #nFile
    
    REM Hacer ejecutable y ejecutar
    Shell("chmod +x " & Q & sShellScript & Q, 0, True)
    Wait(500)
    
    REM Log before curl
    On Error Resume Next
    nDebugFile = FreeFile()
    Open "/tmp/dalle_generation_debug.log" For Append As #nDebugFile
    Print #nDebugFile, "About to execute shell script: " & sShellScript
    Close #nDebugFile
    Err.Clear
    On Error GoTo 0
    
    Shell(sShellScript, 0, True)
    Wait(20000)
    
    REM Log after curl
    On Error Resume Next
    nDebugFile = FreeFile()
    Open "/tmp/dalle_generation_debug.log" For Append As #nDebugFile
    Print #nDebugFile, "Shell script execution completed"
    Close #nDebugFile
    Err.Clear
    On Error GoTo 0
    
    REM Leer respuesta
    sRespuesta = ""
    On Error Resume Next
    nFile = FreeFile()
    Open sResponseFile For Input As #nFile
    If Err.Number = 0 Then
        While Not EOF(nFile)
            Line Input #nFile, sLinea
            sRespuesta = sRespuesta & sLinea & Chr(10)
        Wend
        Close #nFile
    Else
        sRespuesta = ""
        Err.Clear
    End If
    On Error GoTo 0
    
    REM Extraer URL de imagen del JSON response
    sResultado = "Error generating image"
    
    REM DEBUG: Log DALL-E response
    On Error Resume Next
    Dim nDalleDebugFile
    nDalleDebugFile = FreeFile()
    Open "/tmp/dalle_full_response.log" For Append As #nDalleDebugFile
    Print #nDalleDebugFile, "=== DALL-E Response Debug ==="
    Print #nDalleDebugFile, "Response length: " & Len(sRespuesta)
    Print #nDalleDebugFile, "Full response: " & sRespuesta
    Print #nDalleDebugFile, ""
    Close #nDalleDebugFile
    Err.Clear
    On Error GoTo 0
    
    On Error Resume Next
    
    If Len(Trim(sRespuesta)) > 0 Then
        REM Verificar si hay error en la respuesta
        If InStr(sRespuesta, "error") > 0 Then
            nErrorPos = InStr(sRespuesta, "message")
            If nErrorPos > 0 Then
                nErrorStart = InStr(nErrorPos, sRespuesta, Chr(34)) + 1
                nErrorEnd = InStr(nErrorStart, sRespuesta, Chr(34))
                If nErrorEnd > nErrorStart Then
                    sResultado = "Error: " & Mid(sRespuesta, nErrorStart, nErrorEnd - nErrorStart)
                End If
            End If
        Else
            REM Buscar URL en la respuesta
            REM Construir el patron "url": " usando Chr(34)
            sSearchStr = Chr(34) & "url" & Chr(34) & ": " & Chr(34)
            nUrlStart = InStr(sRespuesta, sSearchStr)
            
            If nUrlStart > 0 Then
                REM Ajustar para apuntar al inicio de la URL
                nUrlStart = nUrlStart + Len(sSearchStr)
                REM Encontrar el siguiente quote que cierra la URL
                nUrlEnd = InStr(nUrlStart, sRespuesta, Chr(34))
                
                If nUrlEnd > nUrlStart Then
                    sGeneratedImageUrl = Mid(sRespuesta, nUrlStart, nUrlEnd - nUrlStart)
                    
                    If Len(Trim(sGeneratedImageUrl)) > 20 Then
                        sResultado = sGeneratedImageUrl
                    End If
                End If
            End If
        End If
    End If
    
    On Error GoTo 0
    
    REM Limpiar archivos temporales
    On Error Resume Next
    Shell("rm -f " & Q & sJsonFile & Q, 0, True)
    REM Keep response file for debugging: Shell("rm -f " & Q & sResponseFile & Q, 0, True)
    Shell("rm -f " & Q & sShellScript & Q, 0, True)
    Err.Clear
    On Error GoTo 0
    
    GenerarImagenDALLE = sResultado
End Function

REM Extrae la referencia de articulo de la URL
Function ExtraerArticuloRef(sURL)
    Dim nPos
    Dim sNombre
    Dim sRef
    
    REM Obtener nombre del archivo de la URL
    nPos = InStrRev(sURL, "/")
    If nPos > 0 Then
        sNombre = Mid(sURL, nPos + 1)
    Else
        sNombre = sURL
    End If
    
    REM Extraer la referencia (primera parte antes del primer guion bajo despues de F_)
    nPos = InStr(sNombre, "_")
    If nPos > 0 Then
        sRef = Left(sNombre, nPos - 1)
        nPos = InStr(nPos + 1, sNombre, "_")
        If nPos > 0 Then
            sRef = sRef & "_" & Mid(sNombre, nPos + 1, InStr(nPos + 1, sNombre, "_") - nPos - 1)
            ExtraerArticuloRef = sRef
        Else
            ExtraerArticuloRef = sRef
        End If
    Else
        ExtraerArticuloRef = ""
    End If
End Function
