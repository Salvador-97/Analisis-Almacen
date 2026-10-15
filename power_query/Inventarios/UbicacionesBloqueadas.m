let
  Origen = GoogleSheets.Contents(
    "https://docs.google.com/spreadsheets/d/1LKjvM5nIACSSTkxdHLF5DhFc37uIsj6dM_tcBOsZ4eg/export?format=xlsx"),
  
  Bloqueadas_Table = Origen{[name = "Bloqueadas", ItemKind = "Table"]}[Data],
  
  Encabezados = Table.PromoteHeaders(Bloqueadas_Table, [PromoteAllScalars = true]),
  
  seleccionarFilas = Table.SelectRows(
        Encabezados,
        each [UbicacionID] <> null and
            [UbicacionID] <> ""
    )
in
  seleccionarFilas