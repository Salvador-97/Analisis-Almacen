let
    Origen = GoogleSheets.Contents("https://docs.google.com/spreadsheets/d/1Jy2OWyOz6T2UtU6wmdeoj74oilzqPQpxioq3Uzoj5yw/export?format=xlsx"),
  #"Navegación 1" = Origen{[name = "JULIO-SEPTIEMBRE", ItemKind = "Table"]}[Data],

    #"Encabezados promovidos" = Table.PromoteHeaders(#"Navegación 1", [PromoteAllScalars=true]),
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

    nulosOBC = Table.ReplaceValue(
        columnas,
        "",
        null,
        Replacer.ReplaceValue,
        {"OBC"}
    ),
    rellenarOBC = Table.FillDown(
        nulosOBC,
        {"OBC"}
    ),
    rellenarFecha = Table.FillDown(
        rellenarOBC,
        {"Fecha"}
    ),
    filas = Table.SelectRows(
        rellenarFecha,
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
    )
    /*
    fechaLlave = Table.AddColumn(
        crearLlave,
        "Fecha Surtido",
        each DateTime.Date([Fecha]),
        type date
    )
    */
in
    crearLlave