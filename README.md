# Mega Evolution

In-battle **Mega Evolution** for the Kanto/Johto roster — done the honest way.

A Mega Evolution here is a **temporary battle transformation**, not a permanent
evolution: your Pokémon transforms during the fight and reverts when the battle
ends, exactly like the real games. It works by reusing the engine's own
`TRANSFORM` move machinery — the battler's volatile `curStats`, `curTypes`, and
`sprite` are swapped for the mega form's, while the party Pokémon itself is never
touched, so the change is free to undo.

## How to unlock and use

Mega Evolution is earned, not free. **Megare**, a Mega-Evolution researcher, stands
in **Professor Oak's Lab** in Pallet Town and sets a **trial for each Pokémon**
(see **[QUESTS.md](QUESTS.md)** for all 21). Every trial tracks automatically in
the background — raise the Pokémon to a level, rack up KOs with its line, etc.

When a trial is complete, **talk to Megare** and he hands you that Pokémon's
**Mega Stone** (a key item). While you hold the stone, in battle press **SELECT**
(**Tab**, or either Shift) on the action menu — a `TAB:MEGA` prompt shows when your
active Pokémon can transform. The transformation plays a full animation, and your
Pokémon fights the rest of the battle in its mega form (reverting afterward). Once
per battle.

Charizard and Mewtwo have **X** and **Y** stones — earn either or both, and pick
the form in the mod's options.

## What's covered

All **21 Gen 1/2 mega forms**, with their real base stats and typings:

- **Kanto:** Venusaur, Charizard **X** & **Y**, Blastoise, Beedrill, Pidgeot,
  Alakazam, Slowbro, Gengar, Kangaskhan, Pinsir, Gyarados, Aerodactyl,
  Mewtwo **X** & **Y**.
- **Johto:** Ampharos, Steelix, Scizor, Heracross, Houndoom, Tyranitar.

Charizard and Mewtwo have two forms each — pick **X** or **Y** in the mod's
options.

## Gating

- You can only Mega Evolve a Pokémon whose **Mega Stone** you hold — earned from
  **Megare's trials** (see [QUESTS.md](QUESTS.md)).
- Only **once per battle**.
- **CHARIZARD MEGA / MEWTWO MEGA** (mod options) — choose the X or Y form when you
  own both stones.

## Requires

**gen2_dex.** It pins the Pokédex bound (so the hidden mega forms stay out of the
dex) and registers the **Dark** and **Steel** types that Mega Gyarados, Houndoom,
Tyranitar, Scizor, and Steelix need.

## Sprites

Mega sprites are Pokémon Showdown's Gen 5–style pixel art (no official pixel
sprites for megas exist — Gen 6 onward is 3D). Fan-made art, the same licensing
grey area as any sprite-based fan mod for this game; the artwork remains ©
Nintendo / Game Freak / Creatures.

## Notes

- The mega's boosted stats and changed typing are the payoff — they're live for
  the turn as soon as you transform, and affect damage, type matchups, and STAB.
- Tuned for the DS voxel battle view; the mega pics render a touch larger than a
  normal Pokémon on purpose.

## License

MIT (this repo's code). Sprite artwork is Nintendo/Game Freak/Creatures IP.
