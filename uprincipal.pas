unit uprincipal;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, DB, BufDataset, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, Buttons, StdCtrls, DBGrids, DBCtrls, ZConnection, ZDataset, SynEdit,
  SynHighlighterPas;

type

  { TFrmPrincipal }

  TFrmPrincipal = class(TForm)
    BtnGerarClasse: TBitBtn;
    BtnSair: TBitBtn;
    BtnGerarMetodos: TBitBtn;
    bufTemp: TBufDataset;
    chkChavePrimaria: TDBCheckBox;
    chkCampoGrid: TDBCheckBox;
    dtsBuf: TDataSource;
    dtsBancos: TDataSource;
    dtsTabelas: TDataSource;
    dtsCampos: TDataSource;
    EdtTraducao: TDBEdit;
    DblkpBancoDeDados: TDBLookupComboBox;
    DblkpTabela: TDBLookupComboBox;
    LblRotulo: TLabel;
    NvgControle: TDBNavigator;
    GrdCampos: TDBGrid;
    EdtNomeDaClasse: TEdit;
    EdtTipoClasse: TEdit;
    LblSelecioneBanco: TLabel;
    LblNomeClasse: TLabel;
    LblNomeClasse1: TLabel;
    LblNomeClasse2: TLabel;
    LblSelecioneBanco1: TLabel;
    LblTipoDaClasse: TLabel;
    Panel1: TPanel;
    PnlGrid: TPanel;
    PnlControles: TPanel;
    PnlEsquerdo: TPanel;
    PnlCentro: TPanel;
    PnlBotoes: TPanel;
    SynCodigo: TSynEdit;
    SynPascal: TSynPasSyn;
    conDataBase: TZConnection;
    qryBancos: TZQuery;
    qryTabelas: TZQuery;
    qryCampos: TZQuery;
    procedure BtnGerarClasseClick(Sender: TObject);
    procedure BtnSairClick(Sender: TObject);
    procedure DblkpBancoDeDadosExit(Sender: TObject);
    procedure DblkpTabelaExit(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
  private
    procedure WhereAndParamsPK;
    procedure addTransaction;
    function RetornaTipoCampo:String;
    function RetornaTipoCampoWithAs:String;

  public

  end;

var
  FrmPrincipal: TFrmPrincipal;

implementation

{$R *.lfm}

{ TFrmPrincipal }

procedure TFrmPrincipal.BtnSairClick(Sender: TObject);
begin
   close;
end;

procedure TFrmPrincipal.BtnGerarClasseClick(Sender: TObject);
begin
  if bufTemp.State in [dsEdit,dsInsert] then
     bufTemp.Post;

  if bufTemp.IsEmpty then
      begin
         MessageDlg('Não existe campos deifiido para classe !',mtWarning,[mbOK],0);
         EdtNomeDaClasse.SetFocus;
         exit;
      end;

  if EdtNomeDaClasse.Text=EmptyStr then
     begin
         MessageDlg('Nome da classe OBRIGATORIO !',mtWarning,[mbok],0);
         EdtNomeDaClasse.SetFocus;
         exit;
     end;

  if EdtTipoClasse.Text=EmptyStr then
     begin
         MessageDlg('Tipo da classe OBRIGATORIO !',mtWarning,[mbok],0);
         EdtTipoClasse.SetFocus;
         exit;
     end;
  SynCodigo.Clear;

  with SynCodigo.Lines do begin
     add(' unit c'+EdtNomeDaClasse.Text +';');
     add('');
     add('{$mode objfpc}{$H+} ');
     add('');
     add('interface ');
     add('');
     add('uses Classes, ');
     add('     Controls, ');
     add('     ExtCtrls,');
     add('     Dialogs, ');
     add('     cBase, ');
     add('     ZAbstractConnection, ');
     add('     ZConnection, ');
     add('     ZAbstractRODataset, ');
     add('     ZAbstractDataset, ');
     add('     ZDataset, ');
     add('     SysUtils, ');
     add('     uUtils; ');
     add('');
     add('type ');
     add('  T'+EdtTipoClasse.Text+ '= class(TBase)');
     add('  private');
     bufTemp.First;
     while not bufTemp.EOF do begin
        Add('   F_'+bufTemp.FieldByName('NomeCampo').AsString+':'+RetornaTipoCampo+';');
        bufTemp.Next;
     end;

    add(' Public ');
    add('   constructor Create(aConexao:TZConnection);');
    add('   destructor Destroy; override;');
    add('   function Inserir:Boolean;');
    add('   function Atualizar:Boolean;');
    add('   function Apagar:Boolean;');
    add('   function Selecionar(id:string):Boolean;');
    add('');
    add(' published');
    bufTemp.First;
    while not bufTemp.EOF do begin
      add('   property '+bufTemp.FieldByName('NomeCampo').AsString+':'+RetornaTipoCampo+
                       ' read  F_'+bufTemp.FieldByName('NomeCampo').AsString+
                       ' write F_'+bufTemp.FieldByName('NomeCampo').AsString+';');
      bufTemp.Next;
    end;
    add('');
    add('end;');
    add('');
    add(' implementation ');
    add('');
    add('{T'+EdtTipoClasse.text+'}');
    add('');

    add(' {$region ''Constructor and Destructor''} ');
    add(' constructor T'+copy(EdtTipoClasse.Text,1,50)+'.Create(aConexao:TZConnection);');
    add(' begin');
    add('   ConexaoDB:=aConexao;');
    add(' end;');
    add('');
    add(' destructor T'+copy(EdtTipoClasse.Text,1,50)+'.Destroy; ');
    add(' begin');
    add('   inherited;');
    add(' end;');
    add(' {$endRegion}');
    add('');

    add('{$region ''CRUD''}');
    add('function T'+copy(EdtTipoClasse.Text,1,50)+'.Apagar:Bollean;');
    add('Var Qry:TZquery;');
    add('Begin');
    add('  if MessageNoYes(''Apagar Registro ?'',mtconfirmation)=mrNo then begin  )');
    add( '    Result:=false;');
    add( '    abort;');
    add('  end;');
    add('  try ');
    add('     Result:=True;  ');
    add('     Qry:=TZquery.Create(nil);');
    add('     Qry.Connection:=ConexaoDB;');
    add('     Qry.SQL.Clear;');
    add('     Qry.SQL.Add(''delete from '+DblkpTabela.text +' '' + ');
    WhereAndParamsPK;
    addTransaction;
    add('  finally');
    add('     if assigned(Qry) then ');
    add('        FreeAndNil(Qry); ');
    add('     end;');
    add('end;');
    add('');
    //atualizar
    add('function T'+copy(EdtTipoClasse.Text,1,50)+'.Atualizar:Bollean;');
    add('Var Qry:TZquery;');
    add('Begin');
    add('  try ');
    add('     Result:=True;  ');
    add('     Qry:=TZquery.Create(nil);');
    add('     Qry.Connection:=ConexaoDB;');
    add('     Qry.SQL.Clear;');
    add('     Qry.SQL.Add(''update from '+DblkpTabela.text +''' + ');


    add('{$endRegion}');
    add('end.');
  end;



end;

procedure TFrmPrincipal.DblkpBancoDeDadosExit(Sender: TObject);
var tmn:integer;
begin
  if (TDBLookupComboBox(Sender).KeyValue = Null) or (TDBLookupComboBox(Sender).KeyValue='') then
     begin
       ShowMessage('Banco não informado ! ');
       exit;
     end;

   try
     qryTabelas.close;
     qryTabelas.sql.Clear;
     qrytabelas.sql.Add('select table_name '+
                          ' from information_schema.tables '+
                          ' where table_schema=' + quotedstr( TDBLookupComboBox(sender).KeyValue));
     qryTabelas.Open;
     DblkpTabela.KeyValue:=nil;

   except
     qryTabelas.close;
   end;
end;

procedure TFrmPrincipal.DblkpTabelaExit(Sender: TObject);
var regs:integer;
begin
  regs:=0;
  if (TDBLookupComboBox(Sender).KeyValue = Null) or (TDBLookupComboBox(Sender).KeyValue='') then
     begin
       ShowMessage('Tabela não informada ! ');
       exit;
     end;

  try
    qryCampos.Close;
    qryCampos.SQL.Clear;
    qryCampos.sql.add('select * from information_schema.columns where TABLE_SCHEMA = '+ QuotedStr(DblkpBancoDeDados.KeyValue) + ' and  TABLE_NAME = ' +QuotedStr(TDBLookupComboBox(sender).KeyValue));
    qryCampos.Open;
    qryCampos.First;

    //limpar o dataset temporario
    bufTemp.First;
    //ShowMessage(inttostr(bufTemp.RecordCount));
    //regs:=bufTemp.RecordCount;
    if bufTemp.RecordCount>0 then
        begin
          while not bufTemp.EOF do
            begin
               bufTemp.Delete;
               bufTemp.Next;
            end;
        end;

    //alimentar o dataset tenporario
      while not qryCampos.eof do
       begin
          bufTemp.Append;
          bufTemp.FieldByName('NOMECAMPO').AsString      :=qryCampos.FieldByName('COLUMN_NAME').AsString;
          bufTemp.FieldByName('TIPOCAMPO').AsString      :=qryCampos.FieldByName('DATA_TYPE').AsString;
          bufTemp.FieldByName('TAMANHO').AsInteger       :=qryCampos.FieldByName('CHARACTER_MAXIMUM_LENGTH').AsInteger;
          bufTemp.FieldByName('CHAVEPRIMARIA').AsBoolean :=FALSE;
          bufTemp.FieldByName('CAMPONOGRID').AsBoolean   :=FALSE;
          bufTemp.FieldByName('TRADUCAOCAMPO').AsString  :=qryCampos.FieldByName('COLUMN_NAME').AsString;
          bufTemp.Post;
          qryCampos.Next;
       end;



  except


  end;



end;

procedure TFrmPrincipal.FormClose(Sender: TObject; var CloseAction: TCloseAction
  );
begin
  qryBancos.Close;

  conDataBase.Connected:=False;


end;

procedure TFrmPrincipal.FormShow(Sender: TObject);
begin
  bufTemp.FieldDefs.add('NOMECAMPO',ftString,50);
  bufTemp.FieldDefs.Add('TRADUCAOCAMPO',ftString,50);
  bufTemp.FieldDefs.ADD('TIPOCAMPO',ftString,50);
  bufTemp.FieldDefs.ADD('TAMANHO',ftInteger,0);
  bufTemp.FieldDefs.ADD('CHAVEPRIMARIA',ftBoolean);
  bufTemp.FieldDefs.Add('CAMPONOGRID',ftBoolean);

  bufTemp.CreateDataset;

  conDataBase.Connected:=true;

  qryBancos.SQL.Clear;

  qryBancos.SQL.Add('show databases');

  qryBancos.Open;

  //* BancoDeDados */
  DblkpBancoDeDados.ListSource:=dtsBancos;
  DblkpBancoDeDados.ListField :='DataBase';
  DblkpBancoDeDados.KeyField  :='DataBase';
  //DblkpBancoDeDados.KeyValue:=qryBancos.FieldByName('DataBase').AsString;

  //* Tabelas */
  DblkpTabela.ListSource:=dtsTabelas;
  DblkpTabela.ListField :='table_name';
  DblkpTabela.KeyField  :='table_name';
  DblkpTabela.KeyValue:=nil;

  chkChavePrimaria.DataSource:=dtsBuf;
  chkChavePrimaria.DataField:='CHAVEPRIMARIA';

  chkCampoGrid.DataSource:=dtsBuf;
  chkCampoGrid.DataField:='CAMPONOGRID';

  EdtTraducao.DataSource:=dtsBuf;
  EdtTraducao.DataField:='TRADUCAOCAMPO';

  GrdCampos.DataSource:=dtsBuf;
  NvgControle.DataSource:=dtsBuf;
end;

function TFrmPrincipal.RetornaTipoCampo: String;
begin
  if LowerCase(bufTemp.FieldByName('TipoCampo').AsString)='int' then
     result:='Integer'
  else if LowerCase(bufTemp.FieldByName('TipoCampo').AsString)='bigint' then
     result:='Int64'
  else if (LowerCase(bufTemp.FieldByName('TipoCampo').AsString)='varchar') or
          (LowerCase(bufTemp.FieldByName('TipoCampo').AsString)='longtext') or
          (LowerCase(bufTemp.FieldByName('TipoCampo').AsString)='char') or
          (LowerCase(bufTemp.FieldByName('TipoCampo').AsString)='text') then
     result:='String'
  else if (LowerCase(bufTemp.FieldByName('TipoCampo').AsString)='date') then
     result:='TDate'
  else if (LowerCase(bufTemp.FieldByName('TipoCampo').AsString)='timestamp') or
          (LowerCase(bufTemp.FieldByName('TipoCampo').AsString)='datetime') then
     result:='TDateTime'
  else if (LowerCase(bufTemp.FieldByName('TipoCampo').AsString)='double') or
          (LowerCase(bufTemp.FieldByName('TipoCampo').AsString)='decimal') then
     result:='Double'
  else if (LowerCase(bufTemp.FieldByName('TipoCampo').AsString)='tinyinty') or
          (LowerCase(bufTemp.FieldByName('TipoCampo').AsString)='bit') then
     result:='Boolean'
  else
     result:='IMplementar'

end;

function TFrmPrincipal.RetornaTipoCampoWithAs: String;
  begin
    if LowerCase(bufTemp.FieldByName('TipoCampo').AsString)='int' then
       result:='AsInteger'
    else if LowerCase(bufTemp.FieldByName('TipoCampo').AsString)='bigint' then
       result:='AsInteger'
    else if (LowerCase(bufTemp.FieldByName('TipoCampo').AsString)='varchar') or
            (LowerCase(bufTemp.FieldByName('TipoCampo').AsString)='longtext') or
            (LowerCase(bufTemp.FieldByName('TipoCampo').AsString)='char') or
            (LowerCase(bufTemp.FieldByName('TipoCampo').AsString)='text') then
       result:='AsString'
    else if (LowerCase(bufTemp.FieldByName('TipoCampo').AsString)='date') then
       result:='AsDateTime'
    else if (LowerCase(bufTemp.FieldByName('TipoCampo').AsString)='timestamp') or
            (LowerCase(bufTemp.FieldByName('TipoCampo').AsString)='datetime') then
       result:='AsDateTime'
    else if (LowerCase(bufTemp.FieldByName('TipoCampo').AsString)='double') or
            (LowerCase(bufTemp.FieldByName('TipoCampo').AsString)='decimal') then
       result:='AsFloat'
    else if (LowerCase(bufTemp.FieldByName('TipoCampo').AsString)='tinyinty') or
            (LowerCase(bufTemp.FieldByName('TipoCampo').AsString)='bit') then
       result:='AsBoolean'
    else
       result:='Implementar'

end;

procedure TFrmPrincipal.WhereAndParamsPK;
var i :Integer;
begin
  with SynCodigo.Lines do
  begin
     i:=0;
     bufTemp.First;
     while not bufTemp.EOF do Begin
         if (bufTemp.FieldByName('CHAVEPRIMARIA').AsBoolean)  then begin
            if i=0 then
               add('     ''    where '+bufTemp.FieldByName('NOMECAMPO').AsString+':='+bufTemp.FieldByName('NOMECAMPO').AsString +''');' )
            else
               add('     ''    and   '+bufTemp.FieldByName('NOMECAMPO').AsString+':='+bufTemp.FieldByName('NOMECAMPO').AsString +''');' );
            inc(i);
         end;
         bufTemp.Next;
     end;

     bufTemp.First;
     while not bufTemp.EOF do Begin
        if (bufTemp.FieldByName('CHAVEPRIMARIA').AsBoolean)  then begin
           add('    Qry.ParamByName('+QuotedStr(bufTemp.FieldByName('NOMECAMPO').AsString)+').'+RetornaTipoCampoWithAs+' :=Self.F_'+bufTemp.FieldByName('NOMECAMPO').AsString+';');

        end;
        bufTemp.Next;
     end;

  end;
end;

procedure TFrmPrincipal.addTransaction;
begin
  with SynCodigo.Lines do begin
     add('   try');
     add('     ConexaoDB.StartTransaction;');
     add('     Qry.ExecSql;');
     add('     ConexaoDB.Commit');
     add('   execept');
     add('     ConexaoDB.Rollback;');
     add('     Result:=false;');
     add('   end;')

  end;

end;


end.

