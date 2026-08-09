# Mega Evolution

In-battle **Mega Evolution** for the Kanto/Johto roster — done the honest way.

A Mega Evolution here is a **temporary battle transformation**, not a permanent
evolution: your Pokémon transforms during the fight and reverts when the battle
ends, exactly like the real games. It works by reusing the engine's own
`TRANSFORM` move machinery — the battler's volatile `curStats`, `curTypes`, and
`sprite` are swapped for the mega form's, while the party Pokémon itself is never
touched, so the change is free to undo.

## How to use

In battle, on the action menu (FIGHT / PKMN / ITEM / RUN), press **SELECT**
(**Tab**, or either Shift) while your active Pokémon can Mega Evolve. A `TAB:MEGA`
prompt shows when it's available. The transformation plays a short animation, and
your Pokémon fights the rest of the battle in its mega form.

## What's covered

All **21 Gen 1/2 mega forms**, with their real base stats and typings:

- **Kanto:** Venusaur, Charizard **X** & **Y**, Blastoise, Beedrill, Pidgeot,
  Alakazam, Slowbro, Gengar, Kangaskhan, Pinsir, Gyarados, Aerodactyl,
  Mewtwo **X** & **Y**.
- **Johto:** Ampharos, Steelix, Scizor, Heracross, Houndoom, Tyranitar.

Charizard and Mewtwo have two forms each — pick **X** or **Y** in the mod's
options.

## Gates (all in the mod's options)

- **MEGA MIN LVL** — minimum level to Mega Evolve (OFF / 30 / 40 / 50).
- **MEGA COOLDOWN** — battles that must pass between Mega Evolutions
  (OFF / every 3 / 5 / 10).
- Only **once per battle**, always.
- **CHARIZARD MEGA / MEWTWO MEGA** — choose the X or Y form.

The prompt tells you why a mega is unavailable (`NEED LV40`, `CD 2`, `USED`).

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
