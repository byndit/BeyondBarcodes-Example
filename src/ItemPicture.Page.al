pageextension 50101 "ABC Item Picture" extends "Item Picture"
{
    actions
    {
        addafter(DeletePicture)
        {
            action(CreateQRCode)
            {
                ApplicationArea = All;
                Caption = 'Create';
                ToolTip = 'By using this action, a new qrcode will be created.';
                Image = BarCode;

                trigger OnAction()
                var
                    BarcodeAPI: Codeunit "ABC beyond-barcodes-de";
                begin
                    BarcodeAPI.CreateQRcodeOnItem(Rec);
                end;
            }
        }
    }
}