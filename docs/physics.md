# Física e handling

Modelo **simcade**: base Godot-Easy-Vehicle-Physics (GEVP), brush tire model, suspensão calculada por massa/peso, transferência de carga, ABS, TC, countersteer. Referência de sensação: Forza Motorsport (Turn 10).

## Chassis

- Massa por classe (GT4 ~1300kg, GT3 ~1250kg, LMP ~900kg).
- Distribuição de peso (F/R) afeta tração e frenagem.
- Centro de gravidade: altura afeta rolagem e transferência de carga.

## Pneu (brush tire model, GEVP)

- Força lateral e longitudinal combinadas (círculo de aderência).
- Slip angle e slip ratio: o modelo usa a diferença entre velocidade da roda e do carro.
- Sem modelo de calor/desgaste (decisão: foco em handling base). Se um dia entrar, é aditivo no `Wheel`.
- Coeficientes de atrito por superfície: `Road` 3.0, `Dirt` 2.4, `Grass` 2.0.
- Rigidez do pneu por superfície: `Road` 10, `Dirt` 0.5, `Grass` 0.5.

## Aerodinâmica

- Arrasto: `0.5 * air_density * speed² * frontal_area * coefficient_of_drag`.
- Downforce: `apply_central_force(-up * speed² * k)` no `Car` (k=2.2). Não está no GEVP — é aditivo.
- Drafting: não modelado (fora de escopo).

## Transmissão (GEVP)

- Caixa automática (6 marchas) com embreagem simulada.
- Curva de torque por RPM; redline.
- Embreagem: desengata abaixo de `idle_rpm+100`, reengata acima de `clutch_out_rpm`. Histerese evita oscilação.
- Controle de tração: corta torque do clutch quando o slip da roda excede `traction_control_max_slip`.

## Assistências (configuráveis por carro/modo)

- ABS, controle de tração, controle de estabilidade, countersteer, steering slip assist.
- Presets em `car_config.gd`:
  - `ranked`: ABS + TC + estabilidade ligados, countersteer 0.7.
  - `casual`: tudo ligado, countersteer 0.9.
  - `time_trial`: sem assists, countersteer 0.0.
- Em ranqueada: ABS + TC básicos (a confirmar).

## Drift

- Indução: frenagem de mão + esterço + lift de acelerador.
- Manutenção: contra-esterço + acelerador parcial.
- Recuperação: suave; countersteer assist ajuda (0.7 no ranked, 0.0 no time trial).

## Parâmetros de tuning (setup)

- Asa (downforce), suspensão (mola/amortecedor/camber), diferencial, freio (balanço), pressão de pneu, marchas (relação final).
- Sem troca de peças em ranqueada.

## Calibração

- Alvo: carro previsível a 80% do limite; derrapagem recuperável.
- Testes com pilotos de referência (lap time target por classe/circuito).

## Estrutura técnica

- `addons/gevp/scripts/vehicle.gd` — `class_name Vehicle extends RigidBody3D`. Loop principal, câmbio, motor, clutch, TC, ABS, stability, countersteer.
- `addons/gevp/scripts/wheel.gd` — `class_name Wheel extends RayCast3D`. Suspensão (spring/damper calculados), brush tire model, superfícies.
- `addons/gevp/scripts/vehicle_controllergd.gd` — `class_name VehicleController extends Node3D`. Input → `Vehicle`.
- `car.gd` — `extends Vehicle`. Aplica `CarConfig`, downforce, câmera, input.
- `car_config.gd` — `class_name CarConfig extends Resource`. Presets e `apply_to(v: Vehicle)`.
- Superfícies detectadas por grupos de nós: `Road`, `Dirt`, `Grass`.
