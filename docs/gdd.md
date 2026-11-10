# Game Design Document — OnRacing

## 1. Visão geral

Corrida competitiva com física arcade-sim (referência: NFS Most Wanted / Underground 2) em circuitos reais, com carros de competição (GT3, GT4, touring, LMP). Foco em skill e consistência, não em assistências.

## 2. Pilares

- **Controle previsível:** o carro responde de forma consistente; derrapagem é intencional e recuperável.
- **Competição justa:** sem catch-up, sem IA que freia para o jogador.
- **Fidelidade de traçado:** circuitos reais com elevação e curvas nomeadas.
- **Progressão por performance:** classe e rating (Elo-like) por resultado.

## 3. Loop de jogo

1. Escolher classe e carro.
2. Escolher circuito e modo.
3. Qualificação (volta rápida) → grid.
4. Corrida.
5. Resultado → pontos de rating + créditos → desbloqueios.

## 4. Core mechanics

- **Aceleração/frenagem:** curva de torque por marcha; ABS opcional.
- **Direção:** assistência variável; contra-esterço manual.
- **Drift:** induzido por frenagem de mão + esterço; mantém velocidade lateral; score de drift em modos específicos.
- **Nitro:** recarga por ações (ultrapassagem, drift, volta limpa); uso estratégico.
- **Drafting:** vácuo reduz arrasto; incentiva ultrapassagem em retas.
- **Dano:** visual + leve impacto em handling; sem destruição total.

## 5. Câmera

- 3ª pessoa (padrão), cockpit, capô, teto. FOV ajustável.

## 6. IA

- Usada apenas em modos de treino/prática e time trial com fantasmas.
- Sem rubber-banding; ritmo por classe de carro.

## 7. Multiplayer

- Lobbies ranqueados e casuais; até 16 jogadores.
- Netcode: rollback/prediction para inputs; reconciliação de posição.

## 8. Progressão

- Carros desbloqueados por classe e rating mínimo.
- Upgrades limitados (setup, não peças) para manter equilíbrio em ranqueado.

## 9. Audio/visual

- PBR, ciclo dia/noite, clima (seco/molhado/intermediário).
- Som: motor por cilindros, turbo, pneu, ambiente.

## 10. Plataformas alvo

PC (primeiro), depois consoles. Controle recomendado.

## 11. Fora de escopo (v1)

- Open world, tuning de rua, polícia/perseguição.
