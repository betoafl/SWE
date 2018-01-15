object sSWE1: TsSWE1
  OldCreateOrder = False
  OnCreate = ServiceCreate
  OnDestroy = ServiceDestroy
  DisplayName = 'SWE - Servi'#231'o do Windows - Exemplo did'#225'tico'
  AfterInstall = ServiceAfterInstall
  OnExecute = ServiceExecute
  Left = 65534
  Top = 103
  Height = 150
  Width = 215
  object tmrSWE: TTimer
    Interval = 900000
    OnTimer = tmrSWETimer
    Left = 88
    Top = 48
  end
end
