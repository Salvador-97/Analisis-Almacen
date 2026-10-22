let
    Origen = GoogleSheets.Contents("https://docs.google.com/spreadsheets/d/1DzL_3cPeIvWSiLv1B7R9iVsKRGa8Mdvg9BrlVrHj66c/export?format=xlsx"),
    #"Navegación" = Origen{[name = "General 总汇表", ItemKind = "Table"]}[Data],
    #"Encabezados promovidos" = Table.PromoteHeaders(
        #"Navegación",
        [PromoteAllScalars=true]
    ),

    rellenarOBC = Table.FillDown(
        minusculasSurtidor,
        {"FOLIO SURTIDO"}
    ),
    
    filtrarFilas = Table.SelectRows(
        #"Encabezados promovidos",
        each
            [FECHA] <> null and
            [FOLIO SURTIDO] <> null and
            [FOLIO SURTIDO] <> "" and
            [SURTIDOR] <> null and
            [SURTIDOR] <> ""
    ),
    
    #"Tipo cambiado" = Table.TransformColumnTypes(
        filtrarFilas,
        {
            {"FECHA", type date},
            {"FOLIO SURTIDO", type text},
            {"CLIENTE", type text},
            {"HORA ASIGNADA", type time},
            {"CHECK #(lf)LIST", type logical},
            {"HORA FIN#(lf)VALIDACION", type time},
            {"Recipient/收件人", type text},
            {"DESTINO", type text},
            {"FECHACITA", type date},
            {" ", Int64.Type},
            {"CAJASSURTIDAS", Int64.Type},
            {"%AVANCE", Int64.Type}, 
            {"MNE", Int64.Type},
            {"PRO", type text},
            {"SURTIDOR", type text},
            {"VALIDADOR", type text},
            {"OBSERVACIONES", type any},
            {"RESPUESTA INVENTARIOS", type any},
            {"COMENTARIOS", type any}
        },
        "es-MX"
    ),
    /*Cambio de nombre a columnas*/
    cambioNombre = Table.RenameColumns(
        #"Tipo cambiado",
        {
            {"FECHA", "Fecha"},
            {"FOLIO SURTIDO", "Folio"},
            {"CLIENTE", "Cliente"},
            {"HORA ASIGNADA", "Hora Asignada"},
            {"CHECK #(lf)LIST", "Check List"},
            {"HORA FIN#(lf)VALIDACION", "Hora Fin"},
            {"Recipient/收件人", "Receptor"},
            {"DESTINO", "Destino"},
            {"FECHACITA", "Fecha Cita"},
            {" ", "Total Cajas"},
            {"CAJASSURTIDAS", "Cajas Surtidas"},
            {"%AVANCE", "% Avance"},
            {"MNE", "MNE"},
            {"PRO", "Producción"},
            {"SURTIDOR", "Surtidor"},
            {"VALIDADOR", "Validador"},
            {"OBSERVACIONES", "Observaciones"},
            {"RESPUESTA INVENTARIOS", "R-Inventarios"},
            {"COMENTARIOS", "Comentarios"}
        }
    ),
    /*Seleccion de columnas*/
    columnas = Table.SelectColumns(
        cambioNombre,
        {
            "Fecha",
            "Folio",
            //"Hora Asignada",
            "Check List",
            //"Hora Fin",
            "Destino",
            "Fecha Cita",
            "Total Cajas",
            "Cajas Surtidas",
            "% Avance",
            "MNE",
            "Surtidor",
            "Validador",
            "Observaciones",
            "R-Inventarios",
            "Comentarios"
        }
    ),
    /*Quitar espacion*/
    limpiarEspacios = Table.TransformColumns(
        columnas,
        {
            {"Surtidor", Text.Trim},
            {"Validador", Text.Trim}
        }
    ),
    sinObservaciones = Table.ReplaceValue(
        limpiarEspacios,
        null,
        "Sin observaciones",
        Replacer.ReplaceValue,
        {"Observaciones"}
    ),
    sinRespuesta = Table.ReplaceValue(
        sinObservaciones,
        null,
        "N/A",
        Replacer.ReplaceValue,
        {"R-Inventarios"}
    ),
    sinComentarios = Table.ReplaceValue(
        sinRespuesta,
        null,
        "Sin comentarios",
        Replacer.ReplaceValue,
        {"Comentarios"}
    ),
    nombreDia = Table.AddColumn(
        sinComentarios,
        "Dia Semana",
        each Date.DayOfWeekName([Fecha], "es-MX")
    ),
    mayusculasDia = Table.TransformColumns(
        nombreDia,
        {
            {"Dia Semana", each Text.Proper(_)}
        }
    ),
    minusculasSurtidor = Table.TransformColumns(
        mayusculasDia,
        {
            {"Surtidor", each Text.Proper(_)}
        }
    ),
    /*
    rellenarFechaInicio = Table.FillDown(
        rellenarOBC,
        {"Hora Asignada"}
    ),
    */
    
    crearLlave = Table.AddColumn(
        minusculasSurtidor,
        "Llave",
        each
            Text.Combine(
                {[Folio], [Surtidor]},
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