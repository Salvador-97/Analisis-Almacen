let
  Origen = GoogleSheets.Contents(
    "https://docs.google.com/spreadsheets/d/1LKjvM5nIACSSTkxdHLF5DhFc37uIsj6dM_tcBOsZ4eg/export?format=xlsx"),
  
  #"Navegación 1" = Origen{[name = "Ubicaciones", ItemKind = "Table"]}[Data],
  
  Encabezados = Table.PromoteHeaders(
    #"Navegación 1",
    [PromoteAllScalars=true]
  ),
  seleccionarFilas = Table.SelectRows(
        Encabezados,
        each [UbicacionID] <> null and
            [UbicacionID] <> ""
    )
in
  seleccionarFilas