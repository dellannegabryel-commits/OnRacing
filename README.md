# OnRacing

Jogo de corrida arcade-sim focado em competição: física inspirada em *Need for Speed: Most Wanted* e *Underground 2*, circuitos baseados em traçados reais, estética de carros de competição (GT3, touring, GT4, LMP).

> Status: fase de documentação / pré-produção.

## Visão

- **Sensação de direção:** peso, inércia e derrapagem controlável — drift como ferramenta, não como truque.
- **Competição acima de tudo:** multiplayer ranqueado, sem catch-up artificial. Single player apenas time trial.
- **Fidelidade de traçado:** circuitos modelados a partir de layouts reais (Nürburgring, Spa, Suzuka, Monza, Interlagos, Laguna Seca, Bathurst...).
- **Estética GT:** carros de competição reais/licenciáveis ou inspirados, sem tuning de rua extremo.

## Pilares de design

1. **Física "feel first"** — modelo arcade-sim (não simulação pura), com parâmetros calibrados para derrapagem previsível.
2. **Sem rubber-banding** — IA com ritmo próprio; dificuldade por classe de carro/traçado.
3. **Progressão por classe** — GT4 → GT3 → GTE/LMP, desbloqueio por performance.
4. **Circuitos reais** — traçados com elevação, curvas nomeadas, zonas de DRS/ultrapassagem.

## Documentação

- [Game Design Document](docs/gdd.md)
- [Física e handling](docs/physics.md)
- [Circuitos](docs/tracks.md)
- [Carros e classes](docs/cars.md)
- [Modos de jogo](docs/modes.md)

## Stack (a definir)

Engine a escolher: Unreal Engine 5 (Chaos Vehicle) ou Unity (Vehicle Physics Pro). Render: PBR, ciclo dia/noite, clima dinâmico (molhado/seco).

## Contribuindo

Projeto em estágio inicial. Issues e PRs bem-vindos quando a base de código existir.
