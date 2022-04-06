pageextension 50102 "ABC Item List" extends "Item List"
{
    layout
    {
        addafter("No.")
        {
            field(Picture; Rec.Picture)
            {
                ApplicationArea = All;
                Visible = true;
            }
        }
    }
}