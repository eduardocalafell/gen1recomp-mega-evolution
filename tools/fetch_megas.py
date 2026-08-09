import json, os, urllib.request, io
from PIL import Image

ASSETS = r'C:\games\mods\mega_evolution\assets'
os.makedirs(ASSETS, exist_ok=True)

# form: (mega_id, base_name, from_species, pokeapi_name, showdown_name, dex, sprite_stem)
# dex scheme: 5000 + base national dex; Y variants use 6000 + base dex (unique,
# outside the pinned 1..251 Pokedex bound).
FORMS = [
    ("MEGA_VENUSAUR",     "VENUSAUR",   "VENUSAUR",   "venusaur-mega",    "venusaur-mega",   5003, "mega_venusaur"),
    ("MEGA_CHARIZARD_X",  "CHARIZARD",  "CHARIZARD",  "charizard-mega-x", "charizard-megax", 5006, "mega_charizard_x"),
    ("MEGA_CHARIZARD_Y",  "CHARIZARD",  "CHARIZARD",  "charizard-mega-y", "charizard-megay", 6006, "mega_charizard_y"),
    ("MEGA_BLASTOISE",    "BLASTOISE",  "BLASTOISE",  "blastoise-mega",   "blastoise-mega",  5009, "mega_blastoise"),
    ("MEGA_BEEDRILL",     "BEEDRILL",   "BEEDRILL",   "beedrill-mega",    "beedrill-mega",   5015, "mega_beedrill"),
    ("MEGA_PIDGEOT",      "PIDGEOT",    "PIDGEOT",    "pidgeot-mega",     "pidgeot-mega",    5018, "mega_pidgeot"),
    ("MEGA_ALAKAZAM",     "ALAKAZAM",   "ALAKAZAM",   "alakazam-mega",    "alakazam-mega",   5065, "mega_alakazam"),
    ("MEGA_SLOWBRO",      "SLOWBRO",    "SLOWBRO",    "slowbro-mega",     "slowbro-mega",    5080, "mega_slowbro"),
    ("MEGA_GENGAR",       "GENGAR",     "GENGAR",     "gengar-mega",      "gengar-mega",     5094, "mega_gengar"),
    ("MEGA_KANGASKHAN",   "KANGASKHAN", "KANGASKHAN", "kangaskhan-mega",  "kangaskhan-mega", 5115, "mega_kangaskhan"),
    ("MEGA_PINSIR",       "PINSIR",     "PINSIR",     "pinsir-mega",      "pinsir-mega",     5127, "mega_pinsir"),
    ("MEGA_GYARADOS",     "GYARADOS",   "GYARADOS",   "gyarados-mega",    "gyarados-mega",   5130, "mega_gyarados"),
    ("MEGA_AERODACTYL",   "AERODACTYL", "AERODACTYL", "aerodactyl-mega",  "aerodactyl-mega", 5142, "mega_aerodactyl"),
    ("MEGA_MEWTWO_X",     "MEWTWO",     "MEWTWO",     "mewtwo-mega-x",    "mewtwo-megax",    5150, "mega_mewtwo_x"),
    ("MEGA_MEWTWO_Y",     "MEWTWO",     "MEWTWO",     "mewtwo-mega-y",    "mewtwo-megay",    6150, "mega_mewtwo_y"),
    ("MEGA_AMPHAROS",     "AMPHAROS",   "AMPHAROS",   "ampharos-mega",    "ampharos-mega",   5181, "mega_ampharos"),
    ("MEGA_STEELIX",      "STEELIX",    "STEELIX",    "steelix-mega",     "steelix-mega",    5208, "mega_steelix"),
    ("MEGA_SCIZOR",       "SCIZOR",     "SCIZOR",     "scizor-mega",      "scizor-mega",     5212, "mega_scizor"),
    ("MEGA_HERACROSS",    "HERACROSS",  "HERACROSS",  "heracross-mega",   "heracross-mega",  5214, "mega_heracross"),
    ("MEGA_HOUNDOOM",     "HOUNDOOM",   "HOUNDOOM",   "houndoom-mega",    "houndoom-mega",   5229, "mega_houndoom"),
    ("MEGA_TYRANITAR",    "TYRANITAR",  "TYRANITAR",  "tyranitar-mega",   "tyranitar-mega",  5248, "mega_tyranitar"),
]

TYPE_MAP = {
    "normal": "NORMAL", "fire": "FIRE", "water": "WATER", "grass": "GRASS",
    "electric": "ELECTRIC", "ice": "ICE", "fighting": "FIGHTING",
    "poison": "POISON", "ground": "GROUND", "flying": "FLYING",
    "psychic": "PSYCHIC_TYPE", "bug": "BUG", "rock": "ROCK", "ghost": "GHOST",
    "dragon": "DRAGON", "dark": "DARK", "steel": "STEEL", "fairy": "FAIRY",
}

UA = {"User-Agent": "Mozilla/5.0 (mega-mod-build)"}


def get(url, binary=False):
    req = urllib.request.Request(url, headers=UA)
    with urllib.request.urlopen(req, timeout=30) as r:
        return r.read() if binary else r.read().decode("utf-8")


def process_sprite(raw, out_path, box=72):
    im = Image.open(io.BytesIO(raw)).convert("RGBA")
    bb = im.getbbox()
    if bb:
        im = im.crop(bb)
    im.thumbnail((box, box), Image.LANCZOS)
    im.save(out_path)
    return im.size


rows = []
report = []
for (mid, base, frm, api, shod, dex, stem) in FORMS:
    try:
        data = json.loads(get("https://pokeapi.co/api/v2/pokemon/%s" % api))
        stats = {s["stat"]["name"]: s["base_stat"] for s in data["stats"]}
        types = [TYPE_MAP[t["type"]["name"]] for t in
                 sorted(data["types"], key=lambda t: t["slot"])]
        spa, spd = stats["special-attack"], stats["special-defense"]
        special = int((spa + spd) / 2 + 0.5)
        bs = dict(hp=stats["hp"], attack=stats["attack"], defense=stats["defense"],
                  speed=stats["speed"], special=special)
        # sprites
        fsz = bsz = None
        try:
            fr = get("https://play.pokemonshowdown.com/sprites/gen5/%s.png" % shod, binary=True)
            fsz = process_sprite(fr, os.path.join(ASSETS, stem + "_front.png"))
        except Exception as e:
            report.append("  ! %s FRONT sprite failed: %s" % (mid, e))
        try:
            bk = get("https://play.pokemonshowdown.com/sprites/gen5-back/%s.png" % shod, binary=True)
            bsz = process_sprite(bk, os.path.join(ASSETS, stem + "_back.png"))
        except Exception as e:
            report.append("  ! %s BACK sprite failed: %s" % (mid, e))
        tlua = ", ".join('"%s"' % t for t in types)
        rows.append(
            '    { id = "%s", name = "%s", from = "%s", dex = %d, sprite = "%s",\n'
            '      types = { %s },\n'
            '      baseStats = { hp = %d, attack = %d, defense = %d, speed = %d, special = %d },\n'
            '      frontSize = 7 },'
            % (mid, base, frm, dex, stem, tlua,
               bs["hp"], bs["attack"], bs["defense"], bs["speed"], bs["special"]))
        report.append("  OK %-18s types=%s stats=%s front=%s back=%s"
                      % (mid, "/".join(types), bs, fsz, bsz))
    except Exception as e:
        report.append("  !! %s FAILED entirely: %s" % (mid, e))

open(os.path.join(os.path.dirname(__file__), "megas_table.lua.txt"), "w", encoding="utf-8").write(
    "\n".join(rows))
print("\n".join(report))
print("\n%d/%d forms built. Lua table -> megas_table.lua.txt" % (len(rows), len(FORMS)))
