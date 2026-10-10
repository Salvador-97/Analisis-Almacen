let
  Origen = Excel.Workbook(
        Web.Contents(
            "https://docs.google.com/spreadsheets/d/1LKjvM5nIACSSTkxdHLF5DhFc37uIsj6dM_tcBOsZ4eg/export?format=xlsx"), 
            null, 
            true
        ),
  #"Navegación 1" = Origen{[name = "Ubicaciones", ItemKind = "Table"]}[Data],

  Encabezados = Table.PromoteHeaders(
    #"Navegación 1",
    [PromoteAllScalars=true]
  )
in
    Encabezados