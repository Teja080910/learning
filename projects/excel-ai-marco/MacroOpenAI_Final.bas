REM ============================================================
        REM MACRO: Descripcion automatica de prendas con OpenAI Vision
        REM VERSION: 1.2 - Con keywords y generacion de imagenes DALL-E
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
                    
                    REM Eliminar colores de la descripcion
                    If Left(sDescripcion, 5) <> "Error" Then
                        sDescripcion = EliminarColores(sDescripcion)
                    End If
                    
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

        REM Llama a la API de OpenAI Vision
        Function LlamarOpenAI(sURL)
            Dim sTempDir
            Dim sBatchFile
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
            
            REM Archivos temporales
            sTempDir = Environ("TEMP")
            sBatchFile = sTempDir & "\openai_call.bat"
            sResponseFile = sTempDir & "\openai_response.txt"
            sJsonFile = sTempDir & "\openai_request.json"
            
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
                
                REM Crear comando curl con codificacion UTF-8
                sComando = "@echo off" & Chr(13) & Chr(10)
                sComando = sComando & "chcp 65001 > nul" & Chr(13) & Chr(10)
                sComando = sComando & "curl -s -X POST " & Q & "https://api.openai.com/v1/chat/completions" & Q & " "
                sComando = sComando & "-H " & Q & "Content-Type: application/json; charset=utf-8" & Q & " "
                sComando = sComando & "-H " & Q & "Authorization: Bearer " & sApiKey & Q & " "
                sComando = sComando & "-d @" & Q & sJsonFile & Q & " "
                sComando = sComando & "> " & Q & sResponseFile & Q & " 2>&1" & Chr(13) & Chr(10)
                
                REM Escribir y ejecutar batch
                nFile = FreeFile()
                Open sBatchFile For Output As #nFile
                Print #nFile, sComando
                Close #nFile
                
                Shell(sBatchFile, 0, True)
                Wait(8000)
                
                REM Leer respuesta
                sRespuesta = ""
                nFile = FreeFile()
                Open sResponseFile For Input As #nFile
                While Not EOF(nFile)
                    Dim sLinea
                    Line Input #nFile, sLinea
                    sRespuesta = sRespuesta & sLinea & Chr(10)
                Wend
                Close #nFile
                
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
            Kill sBatchFile
            Kill sResponseFile
            Kill sJsonFile
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

        REM Extrae la referencia de articulo de la URL
        REM Ejemplo: F_15115847_M_2406915_Detail.jpg -> F_15115847
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

        REM Corrige caracteres especiales del espanol
        Function CorregirCaracteresEspanol(sTexto)
            Dim sResultado
            sResultado = sTexto
            
            REM Corregir UTF-8 mojibake (caracteres corruptos)
            sResultado = Replace(sResultado, "Ã¡", Chr(225))
            sResultado = Replace(sResultado, "Ã©", Chr(233))
            sResultado = Replace(sResultado, "Ã­", Chr(237))
            sResultado = Replace(sResultado, "Ã³", Chr(243))
            sResultado = Replace(sResultado, "Ãº", Chr(250))
            sResultado = Replace(sResultado, "Ã±", Chr(241))
            sResultado = Replace(sResultado, "Ã¼", Chr(252))
            sResultado = Replace(sResultado, "Ã", Chr(193))
            sResultado = Replace(sResultado, "Ã‰", Chr(201))
            sResultado = Replace(sResultado, "Ã", Chr(205))
            sResultado = Replace(sResultado, "Ã", Chr(211))
            sResultado = Replace(sResultado, "Ãš", Chr(218))
            sResultado = Replace(sResultado, "Ã'", Chr(209))
            sResultado = Replace(sResultado, "Âº", Chr(186))
            sResultado = Replace(sResultado, "Â¿", Chr(191))
            sResultado = Replace(sResultado, "Â¡", Chr(161))
            
            REM Corregir secuencias Unicode escapadas
            sResultado = Replace(sResultado, "\u00e1", Chr(225))
            sResultado = Replace(sResultado, "\u00e9", Chr(233))
            sResultado = Replace(sResultado, "\u00ed", Chr(237))
            sResultado = Replace(sResultado, "\u00f3", Chr(243))
            sResultado = Replace(sResultado, "\u00fa", Chr(250))
            sResultado = Replace(sResultado, "\u00f1", Chr(241))
            sResultado = Replace(sResultado, "\u00fc", Chr(252))
            sResultado = Replace(sResultado, "\u00c1", Chr(193))
            sResultado = Replace(sResultado, "\u00c9", Chr(201))
            sResultado = Replace(sResultado, "\u00cd", Chr(205))
            sResultado = Replace(sResultado, "\u00d3", Chr(211))
            sResultado = Replace(sResultado, "\u00da", Chr(218))
            sResultado = Replace(sResultado, "\u00d1", Chr(209))
            sResultado = Replace(sResultado, "\u00dc", Chr(220))
            sResultado = Replace(sResultado, "\u00bf", Chr(191))
            sResultado = Replace(sResultado, "\u00a1", Chr(161))
            
            CorregirCaracteresEspanol = sResultado
        End Function

        REM Prueba la API con una imagen de ejemplo
        Sub ProbarUnaImagen()
            Dim sURL
            Dim sDesc
            
            sURL = "https://shop.bondilife.es/Fotos/Only/PV26/F_15115847_M_669_Front.jpg"
            MsgBox "Testing API connection..." & Chr(10) & "Please wait..."
            sDesc = LlamarOpenAI(sURL)
            
            MsgBox "URL: " & Chr(10) & sURL & Chr(10) & Chr(10) & "Descripcion: " & Chr(10) & sDesc & Chr(10) & Chr(10) & "If you see an error message above, your API key is invalid or curl is not working"
        End Sub

        REM Prueba la generacion de keywords
        Sub ProbarKeywords()
            Dim sDesc
            Dim sKeywords
            
            sDesc = "Pantalones beige con cintura elastica y cordon, ideales para comodidad y estilo."
            sKeywords = GenerarKeywords(sDesc)
            
            MsgBox "Descripcion: " & Chr(10) & sDesc & Chr(10) & Chr(10) & "Keywords: " & Chr(10) & sKeywords
        End Sub

        REM Continua desde filas con error o sin procesar
        Sub ContinuarDesdeError()
            Dim oDoc
            Dim oSheet
            Dim nFila
            Dim sImageURL
            Dim sDescripcion
            Dim sEstado
            Dim bContinuar
            Dim nProcesadas
            Dim nErrores
            
            oDoc = ThisComponent
            oSheet = oDoc.Sheets(0)
            
            nFila = 2
            bContinuar = True
            nProcesadas = 0
            nErrores = 0
            
            While bContinuar
                sImageURL = oSheet.getCellByPosition(0, nFila - 1).getString()
                
                If Len(Trim(sImageURL)) = 0 Then
                    bContinuar = False
                Else
                    sDescripcion = oSheet.getCellByPosition(1, nFila - 1).getString()
                    sEstado = oSheet.getCellByPosition(2, nFila - 1).getString()
                    
                    REM Solo procesar filas vacias o con error
                    If Len(Trim(sDescripcion)) = 0 Or sEstado = "ERROR" Then
                        oSheet.getCellByPosition(2, nFila - 1).setString("Procesando...")
                        
                        sDescripcion = LlamarOpenAI(sImageURL)
                        
                        If Left(sDescripcion, 5) = "Error" Then
                            nErrores = nErrores + 1
                            oSheet.getCellByPosition(2, nFila - 1).setString("ERROR")
                        Else
                            nProcesadas = nProcesadas + 1
                            oSheet.getCellByPosition(2, nFila - 1).setString("OK")
                            
                            REM Generar keywords de la descripcion
                            Dim sKeywords
                            sKeywords = GenerarKeywords(sDescripcion)
                            oSheet.getCellByPosition(3, nFila - 1).setString(sKeywords)
                        End If
                        
                        oSheet.getCellByPosition(1, nFila - 1).setString(sDescripcion)
                        Wait(3000)
                    End If
                    
                    nFila = nFila + 1
                End If
            Wend
            
            MsgBox "Continuacion completada." & Chr(10) & "Procesadas: " & nProcesadas & Chr(10) & "Errores: " & nErrores
        End Sub

        REM Genera keywords a partir de una descripcion usando OpenAI
        Function GenerarKeywords(sDescripcion)
            Dim sTempDir
            Dim sBatchFile
            Dim sResponseFile
            Dim sComando
            Dim sRespuesta
            Dim nFile
            Dim Q
            Dim sApiKey
            Dim sResultado
            
            Q = Chr(34)
            
            REM Usar la misma API key
            sApiKey = "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"
            
            REM Archivos temporales
            sTempDir = Environ("TEMP")
            sBatchFile = sTempDir & "\openai_keywords.bat"
            sResponseFile = sTempDir & "\openai_keywords_response.txt"
            
            REM Limpiar descripcion para JSON (remover caracteres problematicos)
            Dim sDescLimpia
            sDescLimpia = Replace(sDescripcion, Chr(34), "'")
            sDescLimpia = Replace(sDescLimpia, Chr(13), " ")
            sDescLimpia = Replace(sDescLimpia, Chr(10), " ")
            sDescLimpia = Replace(sDescLimpia, Chr(9), " ")
            REM Remover acentos para evitar problemas de encoding
            sDescLimpia = Replace(sDescLimpia, "á", "a")
            sDescLimpia = Replace(sDescLimpia, "é", "e")
            sDescLimpia = Replace(sDescLimpia, "í", "i")
            sDescLimpia = Replace(sDescLimpia, "ó", "o")
            sDescLimpia = Replace(sDescLimpia, "ú", "u")
            sDescLimpia = Replace(sDescLimpia, "ñ", "n")
            sDescLimpia = Replace(sDescLimpia, "Á", "A")
            sDescLimpia = Replace(sDescLimpia, "É", "E")
            sDescLimpia = Replace(sDescLimpia, "Í", "I")
            sDescLimpia = Replace(sDescLimpia, "Ó", "O")
            sDescLimpia = Replace(sDescLimpia, "Ú", "U")
            sDescLimpia = Replace(sDescLimpia, "Ñ", "N")
            
            REM Construir JSON inline
            Dim sJsonData
            sJsonData = "{\" & Q & "model\" & Q & ": \" & Q & "gpt-4o-mini\" & Q & ", "
            sJsonData = sJsonData & "\" & Q & "messages\" & Q & ": [{\" & Q & "role\" & Q & ": \" & Q & "user\" & Q & ", "
            sJsonData = sJsonData & "\" & Q & "content\" & Q & ": \" & Q & "Extract 5-8 relevant keywords from this product description in Spanish. Return only the keywords separated by commas, no explanations: " & sDescLimpia & "\" & Q & "}], "
            sJsonData = sJsonData & "\" & Q & "max_tokens\" & Q & ": 50}"
            
            On Error Resume Next
            
            REM Crear comando curl con JSON inline
            sComando = "@echo off" & Chr(13) & Chr(10)
            sComando = sComando & "chcp 65001 > nul" & Chr(13) & Chr(10)
            sComando = sComando & "curl -s -X POST " & Q & "https://api.openai.com/v1/chat/completions" & Q & " "
            sComando = sComando & "-H " & Q & "Content-Type: application/json" & Q & " "
            sComando = sComando & "-H " & Q & "Authorization: Bearer " & sApiKey & Q & " "
            sComando = sComando & "-d " & Q & sJsonData & Q & " "
            sComando = sComando & "> " & Q & sResponseFile & Q & " 2>&1" & Chr(13) & Chr(10)
            
            REM Escribir y ejecutar batch
            nFile = FreeFile()
            Open sBatchFile For Output As #nFile
            Print #nFile, sComando
            Close #nFile
            
            Shell(sBatchFile, 0, True)
            Wait(8000)
            
            REM Leer respuesta
            sRespuesta = ""
            nFile = FreeFile()
            Open sResponseFile For Input As #nFile
            While Not EOF(nFile)
                Dim sLinea
                Line Input #nFile, sLinea
                sRespuesta = sRespuesta & sLinea & Chr(10)
            Wend
            Close #nFile
            
            On Error GoTo 0
            
            REM Extraer resultado
            sResultado = ExtraerDescripcionOpenAI(sRespuesta)
            
            REM Si hay error, intentar guardar la respuesta completa para debug
            If Left(sResultado, 5) = "Error" Or Len(Trim(sResultado)) = 0 Then
                REM Guardar respuesta para debug
                Dim sDebugFile
                sDebugFile = sTempDir & "\openai_keywords_debug.txt"
                nFile = FreeFile()
                Open sDebugFile For Output As #nFile
                Print #nFile, "DESCRIPCION:"
                Print #nFile, sDescripcion
                Print #nFile, ""
                Print #nFile, "DESCRIPCION LIMPIA:"
                Print #nFile, sDescLimpia
                Print #nFile, ""
                Print #nFile, "JSON ENVIADO:"
                Print #nFile, sJsonData
                Print #nFile, ""
                Print #nFile, "RESPUESTA API:"
                Print #nFile, sRespuesta
                Print #nFile, ""
                Print #nFile, "RESULTADO EXTRAIDO:"
                Print #nFile, sResultado
                Close #nFile
            End If
            
            REM Limpiar archivos temporales
            On Error Resume Next
            Kill sBatchFile
            Kill sResponseFile
            On Error GoTo 0
            
            If Left(sResultado, 5) = "Error" Or Len(Trim(sResultado)) = 0 Then
                GenerarKeywords = "[Error: ver " & sTempDir & "\openai_keywords_debug.txt]"
            Else
                GenerarKeywords = CorregirCaracteresEspanol(sResultado)
            End If
        End Function

    REM Procesa solo las descripciones existentes para generar keywords
    Sub GenerarKeywordsParaDescripciones()
        Dim oDoc
        Dim oSheet
        Dim nFila
        Dim sDescripcion
        Dim sKeywords
        Dim bContinuar
        Dim nProcesadas
        Dim nTotal
        
        oDoc = ThisComponent
        oSheet = oDoc.Sheets(0)
        
        nFila = 2
        bContinuar = True
        nProcesadas = 0
        nTotal = 0

        While Len(Trim(oSheet.getCellByPosition(1, nTotal + 1).getString())) > 0
            nTotal = nTotal + 1
        Wend
        
        If nTotal = 0 Then
            MsgBox "No se encontraron descripciones en la columna B."
            Exit Sub
        End If
        
        MsgBox "Se generaran keywords para " & nTotal & " descripciones." & Chr(10) & "Presione OK para comenzar."
        
        While bContinuar
            sDescripcion = oSheet.getCellByPosition(1, nFila - 1).getString()
            
            If Len(Trim(sDescripcion)) = 0 Then
                bContinuar = False
            Else
                REM Solo procesar si no hay keywords o si hay error en descripcion
                If Left(sDescripcion, 5) <> "Error" Then
                    oSheet.getCellByPosition(3, nFila - 1).setString("Generando...")
                    sKeywords = GenerarKeywords(sDescripcion)
                    oSheet.getCellByPosition(3, nFila - 1).setString(sKeywords)
                    nProcesadas = nProcesadas + 1
                    Wait(2000)
                End If
                
                nFila = nFila + 1
            End If
        Wend
        
        MsgBox "Keywords generadas: " & nProcesadas
    End Sub

        REM Genera imagenes del producto en diferentes contextos usando DALL-E
        Function GenerarImagenesProducto(sImageURL, sDescripcion, nFila)
            Dim aImagenes(5) As String
            Dim aContextos(2) As String
            Dim aVistas(1) As String
            Dim i, j, idx
            Dim sPrompt
            Dim sImagenURL
            Dim sArchivoLocal
            Dim sNombreBase
            Dim sArticuloRef
            Dim sCarpetaDestino
            Dim sComando
            Dim Q
            
            Q = Chr(34)
            
            REM Definir carpeta de destino
            sCarpetaDestino = "C:\macro_images"
            
            REM Crear carpeta si no existe
            sComando = "if not exist " & Q & sCarpetaDestino & Q & " mkdir " & Q & sCarpetaDestino & Q
            Shell("cmd /c " & sComando, 0, True)
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
            
            REM Nombre base para archivos
            sNombreBase = sArticuloRef & "_"
            
            REM Generar 6 imagenes (3 contextos x 2 vistas)
            idx = 1
            For i = 0 To 2
                For j = 0 To 1
                    sPrompt = "Professional e-commerce product photography: " & sDescripcion & " displayed on a fashion model in a tasteful, professional manner, " & aVistas(j) & ", " & aContextos(i) & ", natural daylight, high quality, clean and professional style, suitable for online retail catalog"
                    sImagenURL = GenerarImagenDALLE(sPrompt)
                    
                    REM Descargar imagen a carpeta local
                    If Left(sImagenURL, 5) <> "Error" And Len(Trim(sImagenURL)) > 0 Then
                        sArchivoLocal = DescargarImagenLocal(sImagenURL, sCarpetaDestino, sNombreBase & idx)
                        aImagenes(idx - 1) = sArchivoLocal
                    Else
                        aImagenes(idx - 1) = "[Error]"
                    End If
                    
                    idx = idx + 1
                    Wait(2000)
                Next j
            Next i
            
            REM Retornar array de rutas locales separadas por pipe
            REM También retornar la primera URL DALL-E para column F
            If Len(Trim(aImagenes(0))) > 0 And Left(aImagenes(0), 7) <> "[Error]" Then
                GenerarImagenesProducto = aImagenes(0) & "|" & aImagenes(1) & "|" & aImagenes(2) & "|" & aImagenes(3) & "|" & aImagenes(4) & "|" & aImagenes(5)
            Else
                GenerarImagenesProducto = "[Error]"
            End If
        End Function

        REM Llama a DALL-E para generar una imagen
        Function GenerarImagenDALLE(sPrompt)
            Dim sTempDir
            Dim sBatchFile
            Dim sResponseFile
            Dim sComando
            Dim sRespuesta
            Dim nFile
            Dim Q
            Dim sApiKey
            Dim sJsonData
            Dim sResultado
            Dim sPromptLimpio
            
            Q = Chr(34)
            
            REM Usar la misma API key
            sApiKey = "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"
            
            REM Archivos temporales
            sTempDir = Environ("TEMP")
            sBatchFile = sTempDir & "\openai_dalle.bat"
            sResponseFile = sTempDir & "\openai_dalle_response.txt"
            
            REM Limpiar prompt (remover acentos y caracteres especiales)
            sPromptLimpio = Replace(sPrompt, Chr(34), "'")
            sPromptLimpio = Replace(sPromptLimpio, Chr(13), " ")
            sPromptLimpio = Replace(sPromptLimpio, Chr(10), " ")
            sPromptLimpio = Replace(sPromptLimpio, "á", "a")
            sPromptLimpio = Replace(sPromptLimpio, "é", "e")
            sPromptLimpio = Replace(sPromptLimpio, "í", "i")
            sPromptLimpio = Replace(sPromptLimpio, "ó", "o")
            sPromptLimpio = Replace(sPromptLimpio, "ú", "u")
            sPromptLimpio = Replace(sPromptLimpio, "ñ", "n")
            
            REM Construir JSON para DALL-E
            sJsonData = "{\" & Q & "model\" & Q & ": \" & Q & "dall-e-3\" & Q & ", "
            sJsonData = sJsonData & "\" & Q & "prompt\" & Q & ": \" & Q & sPromptLimpio & "\" & Q & ", "
            sJsonData = sJsonData & "\" & Q & "n\" & Q & ": 1, "
            sJsonData = sJsonData & "\" & Q & "size\" & Q & ": \" & Q & "1024x1024\" & Q & "}"
            
            On Error Resume Next
            
            REM Crear comando curl
            sComando = "@echo off" & Chr(13) & Chr(10)
            sComando = sComando & "chcp 65001 > nul" & Chr(13) & Chr(10)
            sComando = sComando & "curl -s -X POST " & Q & "https://api.openai.com/v1/images/generations" & Q & " "
            sComando = sComando & "-H " & Q & "Content-Type: application/json" & Q & " "
            sComando = sComando & "-H " & Q & "Authorization: Bearer " & sApiKey & Q & " "
            sComando = sComando & "-d " & Q & sJsonData & Q & " "
            sComando = sComando & "> " & Q & sResponseFile & Q & " 2>&1" & Chr(13) & Chr(10)
            
            REM Escribir y ejecutar batch
            nFile = FreeFile()
            Open sBatchFile For Output As #nFile
            Print #nFile, sComando
            Close #nFile
            
            Shell(sBatchFile, 0, True)
            Wait(30000)
            
            REM Leer respuesta
            sRespuesta = ""
            nFile = FreeFile()
            Open sResponseFile For Input As #nFile
            While Not EOF(nFile)
                Dim sLinea
                Line Input #nFile, sLinea
                sRespuesta = sRespuesta & sLinea & Chr(10)
            Wend
            Close #nFile
            
            On Error GoTo 0
            
            REM Extraer URL de la imagen generada
            sResultado = ExtraerURLImagen(sRespuesta)
            
            REM Limpiar archivos temporales
            On Error Resume Next
            Kill sBatchFile
            Kill sResponseFile
            On Error GoTo 0
            
            If Left(sResultado, 5) = "Error" Or Len(Trim(sResultado)) = 0 Then
                GenerarImagenDALLE = "[Error]"
            Else
                GenerarImagenDALLE = sResultado
            End If
        End Function

        REM Extrae la URL de imagen del JSON de respuesta de DALL-E
        Function ExtraerURLImagen(sJSON)
            Dim nPos
            Dim nStart
            Dim nEnd
            Dim sURL
            
            REM Verificar si hay error
            If InStr(sJSON, "error") > 0 Then
                ExtraerURLImagen = "Error API"
                Exit Function
            End If
            
            REM Buscar campo url dentro de data
            nPos = InStr(sJSON, "url")
            If nPos = 0 Then
                ExtraerURLImagen = "Sin URL"
                Exit Function
            End If
            
            REM Extraer URL
            nStart = InStr(nPos, sJSON, ":") + 1
            nStart = InStr(nStart, sJSON, Chr(34)) + 1
            nEnd = InStr(nStart, sJSON, Chr(34))
            
            If nEnd > nStart Then
                sURL = Mid(sJSON, nStart, nEnd - nStart)
                ExtraerURLImagen = sURL
            Else
                ExtraerURLImagen = "Error extraccion"
            End If
        End Function

        REM Descarga una imagen desde URL y la guarda localmente
        Function DescargarImagen(sURL, sNombreArchivo)
            Dim sTempDir
            Dim sBatchFile
            Dim sArchivoDestino
            Dim sComando
            Dim nFile
            Dim Q
            
            Q = Chr(34)
            
            REM Crear carpeta temporal si no existe
            sTempDir = Environ("TEMP") & "\ImagenesTemp"
            sComando = "if not exist " & Q & sTempDir & Q & " mkdir " & Q & sTempDir & Q
            Shell("cmd /c " & sComando, 0, True)
            Wait(500)
            
            REM Archivo destino
            sArchivoDestino = sTempDir & "\" & sNombreArchivo & ".png"
            
            REM Crear batch para descargar
            sBatchFile = Environ("TEMP") & "\download_image.bat"
            
            sComando = "@echo off" & Chr(13) & Chr(10)
            sComando = sComando & "curl -s -o " & Q & sArchivoDestino & Q & " " & Q & sURL & Q & Chr(13) & Chr(10)
            
            nFile = FreeFile()
            Open sBatchFile For Output As #nFile
            Print #nFile, sComando
            Close #nFile
            
            Shell(sBatchFile, 0, True)
            Wait(3000)
            
            REM Limpiar batch
            On Error Resume Next
            Kill sBatchFile
            On Error GoTo 0
            
            REM Retornar ruta local
            DescargarImagen = sArchivoDestino
        End Function

        REM Sube una imagen a ImgBB y retorna la URL permanente
        Function SubirImagenImgBB(sArchivoLocal)
            Dim sTempDir
            Dim sBatchFile
            Dim sResponseFile
            Dim sComando
            Dim sRespuesta
            Dim nFile
            Dim Q
            Dim sApiKey
            Dim sResultado
            
            Q = Chr(34)
            
            REM API Key de ImgBB (publica, sin expiracion)
            REM Puedes obtener tu propia key gratis en: https://api.imgbb.com/
            sApiKey = "4614f584226d3704421a2b5120baecad"
            
            REM Archivos temporales
            sTempDir = Environ("TEMP")
            sBatchFile = sTempDir & "\upload_imgbb.bat"
            sResponseFile = sTempDir & "\upload_imgbb_response.txt"
            
            On Error Resume Next
            
            REM Crear comando curl para subir imagen
            sComando = "@echo off" & Chr(13) & Chr(10)
            sComando = sComando & "chcp 65001 > nul" & Chr(13) & Chr(10)
            sComando = sComando & "curl -s -X POST " & Q & "https://api.imgbb.com/1/upload" & Q & " "
            sComando = sComando & "-F " & Q & "key=" & sApiKey & Q & " "
            sComando = sComando & "-F " & Q & "image=@" & sArchivoLocal & Q & " "
            sComando = sComando & "> " & Q & sResponseFile & Q & " 2>&1" & Chr(13) & Chr(10)
            
            REM Escribir y ejecutar batch
            nFile = FreeFile()
            Open sBatchFile For Output As #nFile
            Print #nFile, sComando
            Close #nFile
            
            Shell(sBatchFile, 0, True)
            Wait(5000)
            
            REM Leer respuesta
            sRespuesta = ""
            nFile = FreeFile()
            Open sResponseFile For Input As #nFile
            While Not EOF(nFile)
                Dim sLinea
                Line Input #nFile, sLinea
                sRespuesta = sRespuesta & sLinea & Chr(10)
            Wend
            Close #nFile
            
            On Error GoTo 0
            
            REM Extraer URL de la respuesta
            sResultado = ExtraerURLImgBB(sRespuesta)
            
            REM Limpiar archivos temporales
            On Error Resume Next
            Kill sBatchFile
            Kill sResponseFile
            Kill sArchivoLocal
            On Error GoTo 0
            
            SubirImagenImgBB = sResultado
        End Function

        REM Extrae la URL permanente de la respuesta de ImgBB
        Function ExtraerURLImgBB(sJSON)
            Dim nPos
            Dim nStart
            Dim nEnd
            Dim sURL
            Dim sTempFile
            Dim nFile
            
            REM Guardar respuesta para debug
            sTempFile = Environ("TEMP") & "\imgbb_response_debug.txt"
            nFile = FreeFile()
            Open sTempFile For Output As #nFile
            Print #nFile, sJSON
            Close #nFile
            
            REM Verificar si hay error
            If InStr(sJSON, "error") > 0 Then
                ExtraerURLImgBB = "[Error upload]"
                Exit Function
            End If
            
            REM Buscar "display_url" que es la URL directa de la imagen
            nPos = InStr(sJSON, "display_url")
            If nPos = 0 Then
                REM Si no hay display_url, buscar "url" dentro de "data"
                nPos = InStr(sJSON, "data")
                If nPos > 0 Then
                    nPos = InStr(nPos, sJSON, "url")
                End If
                
                If nPos = 0 Then
                    ExtraerURLImgBB = "[Sin URL - ver " & sTempFile & "]"
                    Exit Function
                End If
            End If
            
            REM Extraer URL
            nStart = InStr(nPos, sJSON, ":") + 1
            nStart = InStr(nStart, sJSON, Chr(34)) + 1
            nEnd = InStr(nStart, sJSON, Chr(34))
            
            If nEnd > nStart Then
                sURL = Mid(sJSON, nStart, nEnd - nStart)
                REM Limpiar caracteres escapados
                sURL = Replace(sURL, "\/", "/")
                sURL = Replace(sURL, "\\", "")
                ExtraerURLImgBB = sURL
            Else
                ExtraerURLImgBB = "[Error extraccion - ver " & sTempFile & "]"
            End If
        End Function

        REM Procesa imagenes y genera variaciones con DALL-E
        Sub GenerarVariacionesImagenes()
            Dim oDoc
            Dim oSheet
            Dim nFila
            Dim sImageURL
            Dim sDescripcion
            Dim sImagenesGeneradas
            Dim bContinuar
            Dim nProcesadas
            Dim nErrores
            Dim nTotal
            
            oDoc = ThisComponent
            oSheet = oDoc.Sheets(0)
            
            nFila = 2
            bContinuar = True
            nProcesadas = 0
            nErrores = 0
            
            REM Contar total de filas con descripciones
            nTotal = 0
            While Len(Trim(oSheet.getCellByPosition(1, nTotal + 1).getString())) > 0
                nTotal = nTotal + 1
            Wend
            
            If nTotal = 0 Then
                MsgBox "No se encontraron descripciones. Ejecute primero ProcesarImagenesPrendas."
                Exit Sub
            End If
            
            MsgBox "Se generaran 6 imagenes para cada una de las " & nTotal & " prendas." & Chr(10) & "Esto puede tomar varios minutos." & Chr(10) & "Presione OK para comenzar."
            
            While bContinuar
                sImageURL = oSheet.getCellByPosition(0, nFila - 1).getString()
                sDescripcion = oSheet.getCellByPosition(1, nFila - 1).getString()
                
                If Len(Trim(sDescripcion)) = 0 Then
                    bContinuar = False
                Else
                    REM Solo procesar si hay descripcion valida
                    If Left(sDescripcion, 5) <> "Error" Then
                        oSheet.getCellByPosition(4, nFila - 1).setString("Generando imagenes...")
                        
                        sImagenesGeneradas = GenerarImagenesProducto(sImageURL, sDescripcion, nFila)
                        
                        REM Separar las 6 URLs y colocarlas en columnas E-J
                        Dim aURLs
                        aURLs = Split(sImagenesGeneradas, "|")
                        
                        oSheet.getCellByPosition(4, nFila - 1).setString(aURLs(0))
                        oSheet.getCellByPosition(5, nFila - 1).setString(aURLs(1))
                        oSheet.getCellByPosition(6, nFila - 1).setString(aURLs(2))
                        oSheet.getCellByPosition(7, nFila - 1).setString(aURLs(3))
                        oSheet.getCellByPosition(8, nFila - 1).setString(aURLs(4))
                        oSheet.getCellByPosition(9, nFila - 1).setString(aURLs(5))
                        
                        nProcesadas = nProcesadas + 1
                    End If
                    
                    nFila = nFila + 1
                End If
            Wend
            
            MsgBox "Generacion completada." & Chr(10) & "Procesadas: " & nProcesadas & Chr(10) & Chr(10) & "Imagenes guardadas en: D:\macro_images" & Chr(10) & "Las rutas locales estan en las columnas E-J"
        End Sub


REM Test simple para generar keywords
Sub TestGenerarKeywordsSimple()
    Dim oDoc
    Dim oSheet
    Dim sDescripcion
    Dim sKeywords
    Dim oCell
    
    oDoc = ThisComponent
    oSheet = oDoc.Sheets(0)
    
    REM Leer descripcion de B2
    sDescripcion = oSheet.getCellByPosition(1, 1).getString()
    
    MsgBox "Descripcion leida:" & Chr(10) & sDescripcion
    
    REM Generar keywords
    sKeywords = GenerarKeywords(sDescripcion)
    
    MsgBox "Keywords generadas:" & Chr(10) & sKeywords
    
    REM Escribir en D2 - Metodo 1
    oCell = oSheet.getCellByPosition(3, 1)
    oCell.setString(sKeywords)
    
    REM Forzar actualizacion
    oDoc.getCurrentController().getFrame().getContainerWindow().setVisible(True)
    
    MsgBox "Keywords escritas en D2: " & oSheet.getCellByPosition(3, 1).getString()
End Sub


REM Test alternativo para escribir keywords
Sub TestEscribirKeywordsAlternativo()
    Dim oDoc
    Dim oSheet
    Dim sDescripcion
    Dim sKeywords
    Dim oCell
    
    oDoc = ThisComponent
    oSheet = oDoc.Sheets(0)
    
    REM Leer descripcion de B2
    sDescripcion = oSheet.getCellByPosition(1, 1).getString()
    
    REM Generar keywords
    sKeywords = GenerarKeywords(sDescripcion)
    
    MsgBox "Keywords: " & sKeywords
    
    REM Metodo alternativo: usar setValue en lugar de setString
    oCell = oSheet.getCellByPosition(3, 1)
    oCell.String = sKeywords
    
    MsgBox "Verificar D2: " & oSheet.getCellByPosition(3, 1).String
End Sub


REM Descarga una imagen y la guarda en carpeta especifica
Function DescargarImagenLocal(sURL, sCarpetaDestino, sNombreArchivo)
    Dim sBatchFile
    Dim sArchivoDestino
    Dim sComando
    Dim nFile
    Dim Q
    Dim sLogFile
    
    Q = Chr(34)
    
    REM Crear carpeta si no existe
    sComando = "if not exist " & Q & sCarpetaDestino & Q & " mkdir " & Q & sCarpetaDestino & Q
    Shell("cmd /c " & sComando, 0, True)
    Wait(1000)
    
    REM Archivo destino
    sArchivoDestino = sCarpetaDestino & "\" & sNombreArchivo & ".png"
    sLogFile = sCarpetaDestino & "\" & sNombreArchivo & "_log.txt"
    
    REM Crear batch para descargar con log
    sBatchFile = Environ("TEMP") & "\download_image_local.bat"
    
    sComando = "@echo off" & Chr(13) & Chr(10)
    sComando = sComando & "echo Descargando desde: " & sURL & " > " & Q & sLogFile & Q & Chr(13) & Chr(10)
    sComando = sComando & "echo Guardando en: " & sArchivoDestino & " >> " & Q & sLogFile & Q & Chr(13) & Chr(10)
    sComando = sComando & "curl -v -o " & Q & sArchivoDestino & Q & " " & Q & sURL & Q & " >> " & Q & sLogFile & Q & " 2>&1" & Chr(13) & Chr(10)
    sComando = sComando & "echo Codigo de salida: %ERRORLEVEL% >> " & Q & sLogFile & Q & Chr(13) & Chr(10)
    
    nFile = FreeFile()
    Open sBatchFile For Output As #nFile
    Print #nFile, sComando
    Close #nFile
    
    REM Ejecutar y esperar mas tiempo
    Shell(sBatchFile, 0, True)
    Wait(10000)
    
    REM Limpiar batch
    On Error Resume Next
    Kill sBatchFile
    On Error GoTo 0
    
    REM Retornar ruta local
    DescargarImagenLocal = sArchivoDestino
End Function


REM Test simple para generar una imagen con DALL-E
Sub ProbarGenerarImagen()
    Dim sDescripcion
    Dim sPrompt
    Dim sImagenURL
    Dim sArchivoLocal
    Dim sCarpeta
    
    sCarpeta = "D:\macro_images"
    sDescripcion = "Pantalones beige casuales"
    sPrompt = "Professional e-commerce product photography: " & sDescripcion & " displayed on a fashion model, front view, urban city street background, natural daylight, high quality"
    
    MsgBox "Generando imagen con DALL-E..." & Chr(10) & "Prompt: " & sPrompt
    
    sImagenURL = GenerarImagenDALLE(sPrompt)
    
    MsgBox "URL generada: " & Chr(10) & sImagenURL
    
    If Left(sImagenURL, 5) <> "Error" And Len(Trim(sImagenURL)) > 0 Then
        MsgBox "Descargando imagen a: " & sCarpeta
        sArchivoLocal = DescargarImagenLocal(sImagenURL, sCarpeta, "test_imagen")
        MsgBox "Imagen guardada en: " & Chr(10) & sArchivoLocal & Chr(10) & Chr(10) & "Carpeta: " & sCarpeta
    Else
        MsgBox "Error generando imagen: " & sImagenURL
    End If
End Sub


REM Verificar si el archivo existe
Sub VerificarArchivo()
    Dim sArchivo
    Dim oFSO
    
    sArchivo = "D:\macro_images\test_imagen.png"
    
    Set oFSO = CreateObject("Scripting.FileSystemObject")
    
    If oFSO.FileExists(sArchivo) Then
        MsgBox "El archivo EXISTE: " & Chr(10) & sArchivo & Chr(10) & Chr(10) & "Tamano: " & oFSO.GetFile(sArchivo).Size & " bytes"
    Else
        MsgBox "El archivo NO EXISTE: " & Chr(10) & sArchivo & Chr(10) & Chr(10) & "Verificar que curl funciona correctamente"
    End If
End Sub



REM Elimina menciones de colores de una descripcion
Function EliminarColores(sTexto)
    Dim sResultado
    Dim aColores
    Dim i
    
    sResultado = sTexto
    
    REM Lista de colores en español (con variaciones)
    aColores = Array( _
        "negro", "negra", "negros", "negras", _
        "blanco", "blanca", "blancos", "blancas", _
        "rojo", "roja", "rojos", "rojas", _
        "azul", "azules", _
        "verde", "verdes", _
        "amarillo", "amarilla", "amarillos", "amarillas", _
        "naranja", "naranjas", _
        "rosa", "rosas", _
        "morado", "morada", "morados", "moradas", _
        "violeta", "violetas", _
        "gris", "grises", _
        "marron", "marrón", "marrones", _
        "beige", "beis", _
        "crema", _
        "dorado", "dorada", "dorados", "doradas", _
        "plateado", "plateada", "plateados", "plateadas", _
        "turquesa", _
        "fucsia", _
        "lila", _
        "coral", _
        "salmon", "salmón", _
        "caqui", _
        "oliva", _
        "granate", _
        "burdeos", "burdeo", _
        "celeste", _
        "indigo", "índigo", _
        "magenta", _
        "ocre", _
        "purpura", "púrpura", _
        "escarlata", _
        "carmesi", "carmesí", _
        "esmeralda", _
        "jade", _
        "lavanda", _
        "mostaza", _
        "terracota", _
        "vino", _
        "chocolate", _
        "camel", _
        "arena", _
        "hueso", _
        "marfil", _
        "perla", _
        "oscuro", "oscura", "oscuros", "oscuras", _
        "claro", "clara", "claros", "claras", _
        "color", "colores", _
        "tono", "tonos", _
        "tonalidad", "tonalidades" _
    )
    
    REM Eliminar cada color (case insensitive)
    For i = LBound(aColores) To UBound(aColores)
        REM Eliminar color como palabra completa
        sResultado = Replace(sResultado, " " & aColores(i) & " ", " ", 1, -1, 1)
        sResultado = Replace(sResultado, " " & aColores(i) & ",", ",", 1, -1, 1)
        sResultado = Replace(sResultado, " " & aColores(i) & ".", ".", 1, -1, 1)
        
        REM Eliminar al inicio de frase
        If LCase(Left(sResultado, Len(aColores(i)) + 1)) = LCase(aColores(i) & " ") Then
            sResultado = Mid(sResultado, Len(aColores(i)) + 2)
        End If
    Next i
    
    REM Limpiar espacios multiples
    While InStr(sResultado, "  ") > 0
        sResultado = Replace(sResultado, "  ", " ")
    Wend
    
    REM Limpiar espacios antes de puntuacion
    sResultado = Replace(sResultado, " ,", ",")
    sResultado = Replace(sResultado, " .", ".")
    
    REM Trim espacios al inicio y final
    sResultado = Trim(sResultado)
    
    EliminarColores = sResultado
End Function


REM Elimina colores de todas las descripciones en columna B
Sub EliminarColoresDeDescripciones()
    Dim oDoc
    Dim oSheet
    Dim nFila
    Dim sDescripcion
    Dim sDescripcionSinColor
    Dim bContinuar
    Dim nProcesadas
    
    oDoc = ThisComponent
    oSheet = oDoc.Sheets(0)
    
    nFila = 2
    bContinuar = True
    nProcesadas = 0
    
    REM Contar descripciones
    Dim nTotal
    nTotal = 0
    While Len(Trim(oSheet.getCellByPosition(1, nTotal + 1).getString())) > 0
        nTotal = nTotal + 1
    Wend
    
    If nTotal = 0 Then
        MsgBox "No se encontraron descripciones en la columna B."
        Exit Sub
    End If
    
    MsgBox "Se eliminaran colores de " & nTotal & " descripciones." & Chr(10) & "Presione OK para comenzar."
    
    While bContinuar
        sDescripcion = oSheet.getCellByPosition(1, nFila - 1).getString()
        
        If Len(Trim(sDescripcion)) = 0 Then
            bContinuar = False
        Else
            REM Solo procesar si no hay error
            If Left(sDescripcion, 5) <> "Error" Then
                sDescripcionSinColor = EliminarColores(sDescripcion)
                oSheet.getCellByPosition(1, nFila - 1).setString(sDescripcionSinColor)
                nProcesadas = nProcesadas + 1
            End If
            
            nFila = nFila + 1
        End If
    Wend
    
    MsgBox "Colores eliminados de " & nProcesadas & " descripciones."
End Sub


REM Prueba la eliminacion de colores
Sub ProbarEliminarColores()
    Dim sOriginal
    Dim sSinColor
    
    sOriginal = "Pantalones beige con cintura elastica y cordon, ideales para comodidad y estilo."
    sSinColor = EliminarColores(sOriginal)
    
    MsgBox "Original:" & Chr(10) & sOriginal & Chr(10) & Chr(10) & "Sin colores:" & Chr(10) & sSinColor
    
    sOriginal = "Camiseta roja de manga corta con cuello redondo, perfecta para verano."
    sSinColor = EliminarColores(sOriginal)
    
    MsgBox "Original:" & Chr(10) & sOriginal & Chr(10) & Chr(10) & "Sin colores:" & Chr(10) & sSinColor
End Sub


REM Genera descripciones SIN mencionar colores
Function LlamarOpenAISinColor(sURL)
    Dim sTempDir
    Dim sBatchFile
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
    
    REM Archivos temporales
    sTempDir = Environ("TEMP")
    sBatchFile = sTempDir & "\openai_call_nocolor.bat"
    sResponseFile = sTempDir & "\openai_response_nocolor.txt"
    sJsonFile = sTempDir & "\openai_request_nocolor.json"
    
    REM Construir JSON para la API - SIN MENCIONAR COLORES
    sJsonBody = "{" & Q & "model" & Q & ": " & Q & "gpt-4o-mini" & Q & ", "
    sJsonBody = sJsonBody & Q & "messages" & Q & ": [{" & Q & "role" & Q & ": " & Q & "user" & Q & ", "
    sJsonBody = sJsonBody & Q & "content" & Q & ": [{" & Q & "type" & Q & ": " & Q & "text" & Q & ", "
    sJsonBody = sJsonBody & Q & "text" & Q & ": " & Q & "Describe this clothing item in Spanish for a product catalog. Include: type of garment, material if visible, style (casual/formal), and any notable details like patterns or design elements. DO NOT mention any colors. Keep it between 20-40 words." & Q & "}, "
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
        
        REM Crear comando curl con codificacion UTF-8
        sComando = "@echo off" & Chr(13) & Chr(10)
        sComando = sComando & "chcp 65001 > nul" & Chr(13) & Chr(10)
        sComando = sComando & "curl -s -X POST " & Q & "https://api.openai.com/v1/chat/completions" & Q & " "
        sComando = sComando & "-H " & Q & "Content-Type: application/json; charset=utf-8" & Q & " "
        sComando = sComando & "-H " & Q & "Authorization: Bearer " & sApiKey & Q & " "
        sComando = sComando & "-d @" & Q & sJsonFile & Q & " "
        sComando = sComando & "> " & Q & sResponseFile & Q & " 2>&1" & Chr(13) & Chr(10)
        
        REM Escribir y ejecutar batch
        nFile = FreeFile()
        Open sBatchFile For Output As #nFile
        Print #nFile, sComando
        Close #nFile
        
        Shell(sBatchFile, 0, True)
        Wait(8000)
        
        REM Leer respuesta
        sRespuesta = ""
        nFile = FreeFile()
        Open sResponseFile For Input As #nFile
        While Not EOF(nFile)
            Dim sLinea
            Line Input #nFile, sLinea
            sRespuesta = sRespuesta & sLinea & Chr(10)
        Wend
        Close #nFile
        
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
    Kill sBatchFile
    Kill sResponseFile
    Kill sJsonFile
    On Error GoTo 0
    
    LlamarOpenAISinColor = sResultado
End Function


REM Procesa URLs y genera descripciones SIN colores
Sub ProcesarImagenesSinColor()
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
    
    MsgBox "Se procesaran " & nTotal & " imagenes SIN mencionar colores." & Chr(10) & "Presione OK para comenzar."
    
    REM Bucle principal de procesamiento
    While bContinuar
        sImageURL = oSheet.getCellByPosition(0, nFila - 1).getString()
        
        If Len(Trim(sImageURL)) = 0 Then
            bContinuar = False
        Else
            oSheet.getCellByPosition(2, nFila - 1).setString("Procesando...")
            
            sDescripcion = LlamarOpenAISinColor(sImageURL)
            
            REM Escribir descripcion primero
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

REM Funcion para diagnosticar si curl esta instalado
Sub DiagnosticarCurl()
    Dim sTempDir
    Dim sBatchFile
    Dim sResponseFile
    Dim sComando
    Dim nFile
    Dim sRespuesta
    Dim sLinea
    
    sTempDir = Environ("TEMP")
    sBatchFile = sTempDir & "\test_curl.bat"
    sResponseFile = sTempDir & "\test_curl_response.txt"
    
    REM Crear batch para probar curl
    sComando = "@echo off" & Chr(13) & Chr(10)
    sComando = sComando & "curl --version > " & Chr(34) & sResponseFile & Chr(34) & " 2>&1" & Chr(13) & Chr(10)
    
    nFile = FreeFile()
    Open sBatchFile For Output As #nFile
    Print #nFile, sComando
    Close #nFile
    
    Shell("cmd /c " & sBatchFile, 0, True)
    Wait(2000)
    
    REM Leer respuesta
    sRespuesta = ""
    On Error Resume Next
    nFile = FreeFile()
    Open sResponseFile For Input As #nFile
    While Not EOF(nFile)
        Line Input #nFile, sLinea
        sRespuesta = sRespuesta & sLinea & Chr(10)
    Wend
    Close #nFile
    On Error GoTo 0
    
    If InStr(sRespuesta, "curl") > 0 Then
        MsgBox "✓ CURL INSTALADO" & Chr(10) & Chr(10) & sRespuesta
    Else
        MsgBox "✗ CURL NO ENCONTRADO" & Chr(10) & Chr(10) & "Instalacion:" & Chr(10) & "1. Descargar: https://curl.se/windows/" & Chr(10) & "2. Extraer curl.exe a C:\Windows\System32\" & Chr(10) & "3. Reiniciar Excel/LibreOffice"
    End If
    
    REM Limpiar
    On Error Resume Next
    Kill sBatchFile
    Kill sResponseFile
    On Error GoTo 0
End Sub

REM Test DALL-E API directamente
Sub ProbarDALLEDirecto()
    Dim sPrompt
    Dim sResultado
    
    sPrompt = "A blue casual pants, professional product photography"
    MsgBox "Probando DALL-E..." & Chr(10) & "Prompt: " & sPrompt
    
    sResultado = GenerarImagenDALLE(sPrompt)
    
    If Left(sResultado, 5) = "Error" Then
        MsgBox "ERROR: " & sResultado & Chr(10) & Chr(10) & "Posibles causas:" & Chr(10) & "1. API key invalida/expirada" & Chr(10) & "2. Sin creditos en OpenAI" & Chr(10) & "3. DALL-E no habilitado" & Chr(10) & "4. Rate limit excedido"
    Else
        MsgBox "EXITO! URL generada:" & Chr(10) & sResultado
    End If
End Sub