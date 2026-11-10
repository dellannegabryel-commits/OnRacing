# Engine e stack

## Engine: Godot 4 + Jolt

- **Godot 4.x** (latest stable) como engine principal.
- **Jolt Physics** via plugin `godot-jolt` para simulação de rigid bodies/veículos mais estável que o Bullet padrão do Godot.
- VehicleBody3D + VehicleWheel3D customizados em cima do Jolt; parâmetros de suspensão/mola/amortecedor expostos.

## Por que Godot + Jolt

- Open source, licença permissiva, sem royalties.
- Jolt corrige instabilidade de suspensão e túnel de colisão em altas velocidades (problema conhecido do Bullet).
- Export multiplataforma (PC, consoles via port).

## Render

- Forward+/Mobile renderer; PBR, IBL, GI (SDFGI/VoxelGI).
- Ciclo dia/noite, clima (seco/molhado/intermediário), poças dinâmicas.

## Rede

- Godot MultiplayerAPI + ENet (LAN/relay) inicial.
- Rollback/prediction para inputs; interpolação de posição remota.
- Servidor dedicado (headless) para ranqueado.

## Ferramentas

- Blender para assets/pistas; Godot import.
- GDScript para gameplay; GDExtension (C++) para física customizada se necessário.

## Riscos

- VehicleBody3D do Godot é básico; pode exigir implementação custom de veículo em C++/GDExtension.
- Jolt plugin mantido por terceiros; verificar compatibilidade com versão do Godot.
