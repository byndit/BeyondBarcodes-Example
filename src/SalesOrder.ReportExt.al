reportextension 50101 "ABC Sales Order" extends "Standard Sales - Order Conf."
{
    WordLayout = '.\src\StandardSalesOrderConf.docx';
    dataset
    {
        modify(Header)
        {
            trigger OnAfterAfterGetRecord()
            var
                InStr: InStream;
                Beyondbarcodesde: Codeunit "ABC beyond-barcodes-de";
            begin
                Beyondbarcodesde.CreateBarcodeOnDocument(Header."No.", InStr);
                TempItem.Picture.ImportStream(InStr, Header."No.", 'image/png');
            end;
        }
        add(Header)
        {
            column(BarcodePicture; TempItem."Picture") { }
        }
    }

    var
        TempItem: Record Item temporary;
}