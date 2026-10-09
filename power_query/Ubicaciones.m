let
    Origen = Excel.Workbook(
        Web.Contents(
            "https://docs.google.com/spreadsheets/d/1LKjvM5nIACSSTkxdHLF5DhFc37uIsj6dM_tcBOsZ4eg/export?format=xlsx"), 
            null, 
            true
        ),

    BaseDatosWMS_Sheet = Origen{[Item="BaseDatosWMS",Kind="Sheet"]}[Data],

    #"Encabezados promovidos" = Table.PromoteHeaders(
        BaseDatosWMS_Sheet, 
        [PromoteAllScalars=true]
    ),
    #"Tipo cambiado" = Table.TransformColumnTypes(
        #"Encabezados promovidos",{
            {"Box type No./箱类型号", type text}, 
            {"Customize Barcode/自定义箱条码", type text}, 
            {"Warehouse/仓库", type text}, 
            {"Customer/客户", type text}, 
            {"Size/尺寸", type text}, 
            {"Weight/重量", type text}, 
            {"cellNo", type text}, 
            {"Area/库区", type text}, 
            {"Total Stock/总库存", Int64.Type}, 
            {"Available stock/可用库存", Int64.Type}, 
            {"Locked Inventory/锁定库存", Int64.Type}, 
            {"sku", type text}, 
            {"Product name/产品名称", type text}, 
            {"Product alias/产品别名", type any}, 
            {"Qty per Package/每箱数量", Int64.Type}
            }
        ),
    cambioNombresColumnas = Table.RenameColumns(
        #"Tipo cambiado",
        {
            {"cellNo", "UbicacionID"},
            {"Total Stock/总库存", "Total"},
            {"Available stock/可用库存", "Disponible"},
            {"Locked Inventory/锁定库存", "Bloqueado"}
        }
    ),
    seleccionarColumnas = Table.SelectColumns(
        cambioNombresColumnas,
        {
            "UbicacionID",
            "Total",
            "Disponible",
            "Bloqueado"
        }
    ),
    ordenarUbicaciones = Table.Sort(
        seleccionarColumnas,
        {"UbicacionID", Order.Ascending}
    )
in
    ordenarUbicaciones