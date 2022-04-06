reportextension 50102 "ABC Sales Quote" extends "Standard Sales - Quote"
{
    WordLayout = '.\src\StandardSalesQuote.docx';
    dataset
    {
        modify(Header)
        {
            trigger OnAfterAfterGetRecord()
            begin
                Beyondbarcodesde.CreateBarcodeOnDocument(Header."No.", TempItem);
            end;
        }
        add(Header)
        {
            column(BarcodePicture; TempItem."Picture") { }
        }
    }

    var
        Beyondbarcodesde: Codeunit "ABC beyond-barcodes-de";
        TempItem: Record Item temporary;
}