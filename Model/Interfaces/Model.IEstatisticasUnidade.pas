unit Model.IEstatisticasUnidade;

interface

type
  TNomeUnidade = (nuSede, nuUEQ, nuVarjota, nuSeisBocas);

  TEstatisticaUnidade = record
    NomeUnidade    : string;
    TotalEnviadas  : Integer;
    TotalCanceladas: Integer;
    DiretorioBase  : string;
  end;

  TArrayEstatisticas = array[TNomeUnidade] of TEstatisticaUnidade;

  IEstatisticasUnidade = interface
    ['{E5F6A7B8-C9D0-1234-EF01-345678901234}']
    procedure Calcular(const AAno, AMes: Word);
    procedure PreencherEstatisticas(out AEstatisticas: TArrayEstatisticas);
  end;

implementation

end.
