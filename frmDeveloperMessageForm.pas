unit frmDeveloperMessageForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,
  JvExStdCtrls, JvRichEdit, FileContainer, JvHtControls;

type
  TdmChoice = (dmcPatreon, dmcKoFi, dmcPayPal);

  TfrmDeveloperMessage = class(TForm)

    reMain: TJvRichEdit;
    fcMessage: TFileContainer;
    fcMessageThanks: TFileContainer;

    pnlElminster: TPanel;
    imgElminster: TImage;
    fcImage: TFileContainer;

    tmrEnableButton: TTimer;
    pnlBottom: TPanel;
    btnOops: TButton;
    cbDontShowAgain: TCheckBox;
    btnCancel: TButton;
    btnOK: TButton;
    btnKoFi: TButton;
    btnPayPal: TButton;

    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);

    procedure btnOopsClick(Sender: TObject);

    procedure tmrEnableButtonTimer(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnKoFiClick(Sender: TObject);
    procedure btnPayPalClick(Sender: TObject);
  private
    procedure FixZoom;
  public
    Choice : TdmChoice;
  end;

implementation

{$R *.dfm}

uses
  wbInterface,
  frmViewMain,
  Vcl.Styles.Utils.SystemMenu;

procedure TfrmDeveloperMessage.FixZoom;
var
  i, CharCount : Integer;
  pt        : TPoint;
begin
  if RichEditVersion >= 3 then begin
    reMain.Zoom := reMain.Zoom - 1;
    reMain.SelLength := 0;
    reMain.SelStart := 100000;
    i := reMain.SelStart;
    reMain.SelText := #13#13;
    reMain.SelStart := 100000;
    CharCount := reMain.SelStart;
    pt := reMain.GetCharPos(CharCount);
    while pt.Y < reMain.Height do begin
      reMain.Zoom := reMain.Zoom + 1;
      pt := reMain.GetCharPos(CharCount);
    end;
    while pt.Y > reMain.Height do begin
      reMain.Zoom := reMain.Zoom - 1;
      pt := reMain.GetCharPos(CharCount);
    end;
    while pt.Y < reMain.Height do begin
      reMain.Zoom := reMain.Zoom + 1;
      pt := reMain.GetCharPos(CharCount);
    end;
    while pt.Y > reMain.Height do begin
      reMain.Zoom := reMain.Zoom - 1;
      pt := reMain.GetCharPos(CharCount);
    end;
    pt := reMain.GetCharPos(80);
    pnlElminster.Top := reMain.Top + 10;
    pnlElminster.Height := pt.y - 20;
    pnlElminster.Width := pnlElminster.Height;
    pnlElminster.Left := (reMain.Left + reMain.Width) - (pnlElminster.Width + 10);

    reMain.SelStart := i;
    reMain.SelLength := 1000;
    reMain.SelText := '';
    reMain.SelStart := 0;
  end else
    pnlElminster.Visible := False;
end;

procedure TfrmDeveloperMessage.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if not (btnCancel.Enabled or (ModalResult = mrOk)) then
    Action := caNone;
end;

procedure TfrmDeveloperMessage.FormCreate(Sender: TObject);
var
  Stream: TStream;
begin
  wbApplyFontAndScale(Self);

  Stream := fcImage.CreateReadStream;
  try
    imgElminster.Picture.LoadFromStream(Stream);
  finally
    Stream.Free;
  end;

  if wbPatron then begin
    btnOops.Visible := True;
    cbDontShowAgain.Caption := '&Don''t show again until changed';
    Stream := fcMessageThanks.CreateReadStream
  end else begin
    btnOops.Visible := False;
    cbDontShowAgain.Caption := '&Don''t show again for a while';
    Stream := fcMessage.CreateReadStream;
  end;
  try
    reMain.Lines.LoadFromStream(Stream);
  finally
    Stream.Free;
  end;

  if wbThemesSupported then
    with TVclStylesSystemMenu.Create(Self) do begin
      ShowNativeStyle := True;
      MenuCaption := 'Theme';
    end;
end;

procedure TfrmDeveloperMessage.FormShow(Sender: TObject);
begin
  tmrEnableButton.Enabled := True;
  FixZoom;
end;

procedure TfrmDeveloperMessage.btnOKClick(Sender: TObject);
begin
  Choice := dmcPatreon;
end;

procedure TfrmDeveloperMessage.btnOopsClick(Sender: TObject);
var
  Stream: TStream;
begin
  wbPatron := False;
  LockWindowUpdate(Handle);
  try
    btnOops.Visible := False;
    btnOK.Visible := True;
    btnKoFi.Visible := True;
    btnPayPal.Visible := True;
    btnOK.Enabled := True;
    btnKoFi.Enabled := True;
    btnPayPal.Enabled := True;
    btnOK.Default := True;
    btnCancel.Default := False;
    cbDontShowAgain.Caption := '&Don''t show again for a while';

    cbDontShowAgain.Left := 0;
    btnCancel.Left := cbDontShowAgain.Left + cbDontShowAgain.Width + 5;
    btnOK.Left := btnCancel.Left + btnCancel.Width + 5;
    btnKoFi.Left := btnOK.Left + btnOK.Width + 5;
    btnPayPal.Left := btnKoFi.Left + btnKoFi.Width + 5;

    Stream := fcMessage.CreateReadStream;
    try
      reMain.Lines.LoadFromStream(Stream);
    finally
      Stream.Free;
    end;
    FixZoom;
  finally
    LockWindowUpdate(0);
  end;
end;

procedure TfrmDeveloperMessage.btnKoFiClick(Sender: TObject);
begin
  Choice := dmcKoFi;
end;

procedure TfrmDeveloperMessage.btnPayPalClick(Sender: TObject);
begin
  Choice := dmcPayPal;
end;

procedure TfrmDeveloperMessage.tmrEnableButtonTimer(Sender: TObject);
begin
  tmrEnableButton.Enabled := False;
  btnCancel.Enabled := True;
end;

end.
