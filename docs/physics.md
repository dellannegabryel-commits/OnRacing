# Física e handling

Modelo **arcade-sim**: não é simulação pura (rFactor/iRacing), mas tem massa, inércia, carga aerodinâmica e pneu simplificado. Referência de sensação: NFS MW/U2.

## Chassis

- Massa por classe (GT4 ~1300kg, GT3 ~1250kg, LMP ~900kg).
- Distribuição de peso (F/R) afeta tração e frenagem.
- Centro de gravidade: altura afeta rolagem e transferência de carga.

## Pneu (modelo simplificado)

- Força lateral vs slip angle: curva com pico e queda (não linear).
- Força longitudinal vs slip ratio.
- Combinado: círculo de aderência (fricção combinada).
- Temperatura: faixa de operação; fora dela, grip reduzido.
- Desgaste: leve, afeta corridas longas.

## Aerodinâmica

- Downforce por velocidade (asas GT3).
- Arrasto; drafting reduz arrasto do carro de trás.

## Transmissão

- Caixa sequencial (paddle); embreagem automática.
- Curva de torque por RPM; redline.

## Assistências (configuráveis)

- ABS, controle de tração, controle de estabilidade, assistência de direção.
- Em ranqueado: apenas ABS + TC básicos permitidos (a definir).

## Drift

- Indução: frenagem de mão + esterço + lift de acelerador.
- Manutenção: contra-esterço + acelerador parcial.
- Recuperação: suave; sem snap violento.

## Parâmetros de tuning (setup)

- Asa (downforce), suspensão (mola/amortecedor/camber), diferencial, freio (balanço), pressão de pneu, marchas (relação final).
- Sem troca de peças em ranqueado.

## Calibração

- Alvo: carro previsível a 80% do limite; derrapagem recuperável.
- Testes com pilotos de referência (lap time target por classe/circuito).
