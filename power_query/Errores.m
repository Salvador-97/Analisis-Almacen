let
    Origen = Excel.Workbook(
        Web.Contents("https://docs.google.com/spreadsheets/d/1wEPcXXEF7x9I-Q9TV7Fku5qA1Cu4yMCWRyDqe_DADdA/export?format=xlsx"), 
        null, 
        true),
    #"JULIO-AGOSTO_Sheet" = Origen{
            [Item="JULIO-AGOSTO",Kind="Sheet"]
        }
        [Data],
    #"Encabezados promovidos" = Table.PromoteHeaders(#"JULIO-AGOSTO_Sheet", [PromoteAllScalars=true]),
    #"Tipo cambiado" = Table.TransformColumnTypes(
        #"Encabezados promovidos",
        {
            {"FECHA", type date}, 
            {"OBC", type text}, 
            {"CÓDIGO", type text}, 
            {"SURTIDOR", type text}, 
            {"RESPONSABLE DE COLOCAR EL ERROR ", type text}, 
            {"OBSERVACIÓN ", type text}, 
            {"SE LE ENTREGA A  ", type text}
        }
    ),
    renombrarColumnas = Table.RenameColumns(
        #"Tipo cambiado",
        {
            {"FECHA", "Fecha"},
            {"OBC", "OBC"},
            {"CÓDIGO", "Código"},
            {"SURTIDOR", "Surtidor"},
            {"RESPONSABLE DE COLOCAR EL ERROR ", "Detectado Por"},
            {"OBSERVACIÓN ", "Error"},
            {"SE LE ENTREGA A  ", "Responsable Inventarios"}
        }
    ),
    columnas = Table.SelectColumns(
        renombrarColumnas,
        {
            "Fecha",
            "OBC",
            "Código",
            "Surtidor",
            "Detectado Por",
            "Error",
            "Responsable Inventarios"
        }
    ),
    filas = Table.SelectRows(
        columnas,
        each [OBC] <> null
    ),
    limpiarEspacios = Table.TransformColumns(
        filas,
        {
            {"OBC", Text.Trim},
            {"Código", Text.Trim},
            {"Surtidor", Text.Trim},
            {"Detectado Por", Text.Trim},
            {"Error", Text.Trim},
            {"Responsable Inventarios", Text.Trim}
        }
    ),
    minusculas = Table.TransformColumns(
        limpiarEspacios,
        {
            {"Surtidor", each Text.Proper(_)},
            {"Detectado Por", each Text.Proper(_)},
            {"Error", each Text.Proper(_)},
            {"Responsable Inventarios", each Text.Proper(_)}
        }
    ),
    crearLlave = Table.AddColumn(
        minusculas,
        "Llave",
        each
            Text.Combine(
                {[OBC], [Surtidor]},
                "|"
            )
    ),
    fechaLlave = Table.AddColumn(
        crearLlave,
        "Fecha Surtido",
        each DateTime.Date([Fecha])
    )
in
    fechaLlave