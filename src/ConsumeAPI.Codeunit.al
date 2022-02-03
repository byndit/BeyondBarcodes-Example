codeunit 50101 "ABC beyond-barcodes-de"
{
    var
        BaseUrlTxt: Label 'https://beyondbarcodestest.azurewebsites.net/v1/qr/%1', locked = true;
        FreeTokenTxt: Label '8Ktq723Kkz6zbWQLtuClrDVQgMMRg0SaH0xPSh3n', Locked = true;
        MimeTypeTok: Label 'image/png', Locked = true;
        RequestFailedTxt: Label 'Request failed %1.', Locked = true;

    procedure CreateQRcodeOnItem(var Item: Record Item)
    var
        Instr: InStream;
    begin
        if Item."Vendor Item No." = '' then
            exit;
        if TryToCreateBarcode(Item."Vendor Item No.", Instr) then begin
            Clear(Item.Picture);
            Item.Picture.ImportStream(InStr, Item.Description, MimeTypeTok);
            if Item.Picture.Count = 0 then
                exit;
            Item.Modify(true);
        end;
    end;

    local procedure TryToCreateBarcode(BarcodeValue: Text; var Instr: InStream): Boolean
    var
        TempErrorMessage: Record "Error Message" temporary;
        Client: HttpClient;
        Content: HttpContent;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
    begin
        RequestMessage.Method('GET');
        RequestMessage.SetRequestUri(strsubstno(BaseUrlTxt, BarcodeValue));
        Client.DefaultRequestHeaders().Add('token', FreeTokenTxt);
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