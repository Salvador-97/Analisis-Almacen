let
    Origen = Csv.Document(Web.Contents("https://docs.google.com/spreadsheets/d/1zH5PI1eu4RkuxnreboQ8oNsMACjSrFhITrEvlBNghzo/gviz/tq?tqx=out:csv&sheet=CONSOL 总汇表"),
        [Delimiter = ",", 
        Columns = 22, 
        Encoding = 65001, 
        QuoteStyle = QuoteStyle.Csv]),

    #"Encabezados promovidos" = Table.PromoteHeaders(
        Origen, 
        [PromoteAllScalars=true]
    ),
    #"Tipo cambiado" = Table.TransformColumnTypes(
        #"Encabezados promovidos",
        {
            {"Pasillo", type text}, 
            {"FECHA#(lf)SCAN#(lf)日期", type date}, 
            {"HORA#(lf)SCAN#(lf)小时", type text}, 
            {"CODIGO#(lf)EXTRACION#(lf)代码", type text}, 
            {"CODIGO#(lf)EXTRACION#(lf)代码_1", type text}, 
            {"CANT", Int64.Type}, 
            {"CANTDISP.WMS", type text}, 
            {"CANTBLOQ", type text}, 
            {"CLIENTE#(lf)顾客", type text}, 
            {"UBICACION#(lf)ORIGEN#(lf)地方", type text}, 
            {"UBICACION#(lf)DESTINO", type text}, 
            {"VALIDACION WMS", type text}, 
            {"ACTIVIDAD #(lf)活动", type text}, 
            {"STATUS#(lf)WMS", type text}, 
            {"RESPONSABLE", type text}, 
            {"", type text}, 
            {"_2", type text}, 
            {"TOTALSTOCK#(lf)总库存", Int64.Type}, 
            {"CAJAS#(lf)COMPACTADAS#(lf)压缩盒", Int64.Type}, 
            {"AVANCE%#(lf)进步", Percentage.Type}, 
            {"BARRADE#(lf)PROGRESO#(lf)进度条", type text}, 
            {"CAJAS#(lf)BLOQUEADAS#(lf)封锁", Int64.Type}
        }
    ),
    nuevoNombreColumnas = Table.RenameColumns(
        #"Tipo cambiado",
        {
            {"FECHA#(lf)SCAN#(lf)日期", "Fecha"},
            {"HORA#(lf)SCAN#(lf)小时", "Hora"},
            {"CODIGO#(lf)EXTRACION#(lf)代码_1", "Código"},
            {"CANT", "Cantidad"},
            {"CANTDISP.WMS", "Disponibles"},
            {"CANTBLOQ", "Bloqueada"},
            {"UBICACION#(lf)ORIGEN#(lf)地方", "Ub. Origen"},
            {"UBICACION#(lf)DESTINO", "Ub. Destino"},
            {"ACTIVIDAD #(lf)活动", "Actividad"},
            {"RESPONSABLE", "Responsable"}
        }
    ),
    tranformarHora = Table.TransformColumns(
        nuevoNombreColumnas,
        {
            {"Hora", type time},
            "en-US"
        }
    ),
    seleccionarColumnas = Table.SelectColumns(
        nuevoNombreColumnas,
        {
            "Fecha",
            "Hora",
            "Código",
            "Cantidad",
            "Bloqueada",
            "Ub. Origen",
            "Ub. Destino",
            "Actividad",
            "Responsable"
        }
    )
in
    seleccionarColumnas