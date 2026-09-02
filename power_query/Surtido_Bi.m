let
    Origen = Excel.Workbook(Web.Contents("https://docs.google.com/spreadsheets/d/1BG8o3_2Y2RRZWYP1pz0q0KG71cBrtmCh3TlYhUs6s9w/export?format=xlsx"), null, true),
    #"Hoja 1_Sheet" = Origen{[Item="Hoja 1",Kind="Sheet"]}[Data],
    #"Encabezados promovidos" = Table.PromoteHeaders(
        #"Hoja 1_Sheet",
        [PromoteAllScalars=true]
    ),
    #"Tipo cambiado" = Table.TransformColumnTypes(
        #"Encabezados promovidos",
        {
            {"FECHA", type date},
            {"FOLIO SURTIDO", type text},
            {"CLIENTE", type text},
            {"HORA ASIGNADA", type time},
            {"CHECK #(lf)LIST", type logical},
            {"HORA FIN#(lf) VALIDACION", type time},
            {"Recipient/收件人", type text},
            {"DESTINO", type text},
            {"FECHACITA", type date},
            {"TOTALCAJAS", Int64.Type},
            {"CAJASSURTIDAS", Int64.Type},
            {"%AVANCE", Int64.Type}, 
            {"MNE", Int64.Type},
            {"PRO", type text},
            {"SURTIDOR", type text},
            {"VALIDADOR", type text},
            {"OBSERVACIONES", type any},
            {"RESPUESTA INVENTARIOS", type any},
            {"COMENTARIOS", type any}
        }
    ),
    /*Cambio de nombre a columnas*/
    cambioNombre = Table.RenameColumns(
        #"Tipo cambiado",
        {
            {"FECHA", "Fecha"},
            {"FOLIO SURTIDO", "Folio Surtido"},
            {"CLIENTE", "Cliente"},
            {"HORA ASIGNADA", "Hora Asignada"},
            {"CHECK #(lf)LIST", "Check List"},
            {"HORA FIN#(lf) VALIDACION", "Hora Fin"},
            {"Recipient/收件人", "Receptor"},
            {"DESTINO", "Destino"},
            {"FECHACITA", "Fecha Cita"},
            {"TOTALCAJAS", "Total Cajas"},
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
            "Folio Surtido",
            "Hora Asignada",
            "Check List",
            "Hora Fin",
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
    totalCajasSurtidas = Table.AddColumn(
        sinComentarios,
        "Estado Cajas",
        each
            if [Cajas Surtidas] > [Total Cajas]
            then "Error"
            else "Correcto",
        type text
    ),
    estadoSurtido = Table.AddColumn(
        totalCajasSurtidas,
        "Estado Surtido",
        each
            if [Cajas Surtidas] = [Total Cajas]
            then "Completo"
            else "Pendiente"
    ),
    avanceSurtido = Table.AddColumn(
        estadoSurtido,
        "Categoria Avance",
        each
            if [#"% Avance"] = 0 then "Sin iniciar" else
            if [#"% Avance"] > 0.1 and [#"% Avance"] < 0.49 then "Bajo" else
            if [#"% Avance"] > 0.5 and [#"% Avance"] < 0.79 then "Medio" else
            if [#"% Avance"] > 0.8 and [#"% Avance"] < 0.99 then "Alto"
            else "Completo",
        type text
    ),
    horaMinutos = Table.AddColumn(
        avanceSurtido,
        "Tiempo Proceso (min)",
        each 
            ((Time.Hour([Hora Fin]) * 60) + (Time.Minute([Hora Fin]))) -
            ((Time.Hour([Hora Asignada]) * 60) + (Time.Minute([Hora Asignada])))
    ),
    nombreDia = Table.AddColumn(
        horaMinutos,
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
    limpiarSurtidores = Table.TransformColumns(
        minusculasSurtidor,
        {
            {"Surtidor", each if _ <> null then _ else "Otro"}
        }
    ),
    limpiarOtros = Table.SelectRows(
        limpiarSurtidores,
        each [Surtidor] <> "Otro"
    ),
    datosCompletos = Table.AddColumn(
        limpiarOtros,
        "Datos Completos",
        each 
            if [Folio Surtido] <> null and [Hora Asignada] <> null
                and [Surtidor] <> null and [Validador] <> null
            then "Completo" 
            else "Incompleto",
            type text
    ),
    categoriaCajas = Table.AddColumn(
        datosCompletos,
        "Categoría Cajas",
        each
            if [Total Cajas] = 0 then "Sin cajas" else
            if [Total Cajas] <= 20 then "Pequeño" else
            if [Total Cajas] <= 50 then "Mediano" else
            if [Total Cajas] <= 100 then "Grande" 
            else "Muy Grande",
            type text
    ),
    categoriaTiempo = Table.AddColumn(
        categoriaCajas,
        "Categoría Tiempo",
        each
            if [#"Tiempo Proceso (min)"] <= 30 then "Rápido" else
            if [#"Tiempo Proceso (min)"] <= 60 then "Normal" else
            if [#"Tiempo Proceso (min)"] <= 120 then "Largo" 
            else "Muy Largo",
            type text
    ),
    validarTiempo = Table.AddColumn(
        categoriaTiempo,
        "Validación Tiempo",
        each
            if [Hora Fin] = null or [Hora Asignada] = null then "Sin Registro" else
            if [#"Tiempo Proceso (min)"] < 0 then "Revisar" 
            else "Correcto",
            type text
    ),
    filtrarFecha = Table.SelectRows(
        validarTiempo,
        each [Fecha] <> null
    ),
    filtrarFilas = Table.SelectRows(
        filtrarFecha,
        each
            [Folio Surtido] <> null and
            [Hora Asignada] <> null and
            [Hora Fin] <> null
    )
in
    filtrarFilas