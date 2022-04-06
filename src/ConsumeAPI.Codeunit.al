codeunit 50101 "ABC beyond-barcodes-de"
{
    var
        BYDBarcodeSetup: record "BYD Barcode Setup";
        FreeBaseQRUrlTxt: Label 'https://beyondbarcodestest.azurewebsites.net/v1/qr/%1', locked = true;
        BaseQRUrlTxt: Label 'https://api.beyondbarcodes.de/v1/qr/%1', locked = true;
        BaseBarcodeUrlTxt: Label 'https://api.beyondbarcodes.de/v1/barcode/code39/%1', locked = true;
        FreeTokenTxt: Label '8Ktq723Kkz6zbWQLtuClrDVQgMMRg0SaH0xPSh3n', Locked = true;
        MimeTypeTok: Label 'image/png', Locked = true;
        RequestFailedTxt: Label 'Request failed %1.', Locked = true;

    procedure CreateQRcodeOnItem(var Item: Record Item)
    var
        Instr: InStream;
    begin
        if Item."Vendor Item No." = '' then
            exit;
        if TryToCreateBarcode(Item."Vendor Item No.", Instr, FreeBaseQRUrlTxt, FreeTokenTxt) then begin
            Clear(Item.Picture);
            Item.Picture.ImportStream(InStr, Item.Description, MimeTypeTok);
            if Item.Picture.Count = 0 then
                exit;
            Item.Modify(true);
        end;
    end;

    procedure CreateBarcodeOnDocument(BarcodeValue: Text; var InStr: InStream): Boolean
    begin
        if barcodevalue = '' then
            exit(false);

        if not BYDBarcodeSetup.Get() then
            exit(false);
        exit(TryToCreateBarcode(BarcodeValue, Instr, BaseQRUrlTxt, BYDBarcodeSetup."Capacity Token"));
    end;

    procedure CreateBarcodeOnDocument(BarcodeValue: Text; var TempItem: Record Item temporary): Boolean
    var
        InStr: InStream;
    begin
        if BarcodeValue = '' then
            exit(false);

        if not BYDBarcodeSetup.Get() then
            exit(false);
        if TryToCreateBarcode(BarcodeValue, Instr, BaseBarcodeUrlTxt + '?showText=false', BYDBarcodeSetup."Capacity Token") then begin
            Clear(TempItem);
            TempItem."No." := CopyStr(BarcodeValue, 1, MaxStrLen(TempItem."No."));
            TempItem.Picture.ImportStream(InStr, TempItem.Description, MimeTypeTok);
            TempItem.Insert();
            exit(TempItem.Picture.Count <> 0);
        end;
        exit(false);
    end;

    procedure TryToCreateBarcode(BarcodeValue: Text; var Instr: InStream; baseurl: Text; token: Text): Boolean
    var
        TempErrorMessage: Record "Error Message" temporary;
        Client: HttpClient;
        Content: HttpContent;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
    begin
        RequestMessage.Method('GET');
        RequestMessage.SetRequestUri(strsubstno(baseurl, BarcodeValue));
        Client.DefaultRequestHeaders().Add('token', token);
        Client.DefaultRequestHeaders().Add('Accept', MimeTypeTok);

        if Client.Send(RequestMessage, ResponseMessage) then
            if ResponseMessage.IsSuccessStatusCode() then begin
                Content := ResponseMessage.Content;
                Content.ReadAs(InStr);
                if IsInStreamEmpty(InStr) then
                    exit(false);
                exit(true);
            end else begin
                TempErrorMessage.LogSimpleMessage(TempErrorMessage."Message Type"::Error, StrSubstNo(RequestFailedTxt, ResponseMessage.ReasonPhrase));
                if TempErrorMessage.HasErrors(false) then
                    TempErrorMessage.ShowErrorMessages(true);
            end;
        exit(false);
    end;

    local procedure IsInStreamEmpty(var InStr: InStream): Boolean
    var
        txt: Text;
    begin
        InStr.ReadText(txt);
        exit(txt = '');
    end;

}