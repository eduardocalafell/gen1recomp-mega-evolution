# Generate the Lua MEGAS-with-quests table + QUESTS.md from one source of truth.
import re, os

TABLE = open(r'C:\Users\EDUARD~1\AppData\Local\Temp\claude\megas_table.lua.txt', encoding='utf-8').read()

# parse the fetched base data (stats/types/sprite/dex) per form
base = {}
rx = re.compile(
    r'id = "(?P<id>[A-Z0-9_]+)", name = "(?P<name>[A-Z]+)", from = "(?P<from>[A-Z0-9_]+)", '
    r'dex = (?P<dex>\d+), sprite = "(?P<sprite>[a-z0-9_]+)",\s*\n\s*types = \{ (?P<types>[^}]+) \},\s*\n'
    r'\s*baseStats = \{ hp = (?P<hp>\d+), attack = (?P<atk>\d+), defense = (?P<df>\d+), '
    r'speed = (?P<spd>\d+), special = (?P<spc>\d+) \}', re.M)
for m in rx.finditer(TABLE):
    base[m.group('id')] = m.groupdict()

# quest data (one source of truth) keyed by mega form id.
# fields: stone id, stone display name, base species to own+level, level,
# koLine (species that count toward KOs), koCount, optional wins / dex, blurb.
Q = {
 "MEGA_VENUSAUR":   ("VENUSAURITE","VENUSAURITE","VENUSAUR",50,["BULBASAUR","IVYSAUR","VENUSAUR"],60,None,None,"Raise a Venusaur to Lv50 and score 60 KOs with the Bulbasaur line."),
 "MEGA_CHARIZARD_X":("CHARIZARDITE_X","CHARIZARDITE X","CHARIZARD",60,["CHARMANDER","CHARMELEON","CHARIZARD"],100,None,None,"Raise a Charizard to Lv60 and score 100 KOs with the Charmander line."),
 "MEGA_CHARIZARD_Y":("CHARIZARDITE_Y","CHARIZARDITE Y","CHARIZARD",60,None,None,80,None,"Raise a Charizard to Lv60 and win 80 battles."),
 "MEGA_BLASTOISE":  ("BLASTOISINITE","BLASTOISINITE","BLASTOISE",50,["SQUIRTLE","WARTORTLE","BLASTOISE"],60,None,None,"Raise a Blastoise to Lv50 and score 60 KOs with the Squirtle line."),
 "MEGA_BEEDRILL":   ("BEEDRILLITE","BEEDRILLITE","BEEDRILL",30,["WEEDLE","KAKUNA","BEEDRILL"],30,None,None,"Raise a Beedrill to Lv30 and score 30 KOs with the Weedle line."),
 "MEGA_PIDGEOT":    ("PIDGEOTITE","PIDGEOTITE","PIDGEOT",35,["PIDGEY","PIDGEOTTO","PIDGEOT"],40,None,None,"Raise a Pidgeot to Lv35 and score 40 KOs with the Pidgey line."),
 "MEGA_ALAKAZAM":   ("ALAKAZITE","ALAKAZITE","ALAKAZAM",50,["ABRA","KADABRA","ALAKAZAM"],40,None,60,"Raise an Alakazam to Lv50, score 40 KOs with the Abra line, and own 60 dex entries."),
 "MEGA_SLOWBRO":    ("SLOWBRONITE","SLOWBRONITE","SLOWBRO",50,["SLOWPOKE","SLOWBRO"],40,None,None,"Raise a Slowbro to Lv50 and score 40 KOs with the Slowpoke line."),
 "MEGA_GENGAR":     ("GENGARITE","GENGARITE","GENGAR",50,["GASTLY","HAUNTER","GENGAR"],66,None,None,"Raise a Gengar to Lv50 and score 66 KOs with the Gastly line."),
 "MEGA_KANGASKHAN": ("KANGASKHANITE","KANGASKHANITE","KANGASKHAN",35,["KANGASKHAN"],40,None,None,"Raise a Kangaskhan to Lv35 and score 40 KOs with it."),
 "MEGA_PINSIR":     ("PINSIRITE","PINSIRITE","PINSIR",45,["PINSIR"],50,None,None,"Raise a Pinsir to Lv45 and score 50 KOs with it."),
 "MEGA_GYARADOS":   ("GYARADOSITE","GYARADOSITE","GYARADOS",50,["MAGIKARP","GYARADOS"],50,None,None,"Raise a Gyarados to Lv50 and score 50 KOs with the Magikarp line."),
 "MEGA_AERODACTYL": ("AERODACTYLITE","AERODACTYLITE","AERODACTYL",50,["AERODACTYL"],50,None,None,"Raise an Aerodactyl to Lv50 and score 50 KOs with it."),
 "MEGA_MEWTWO_X":   ("MEWTWONITE_X","MEWTWONITE X","MEWTWO",70,["MEWTWO"],150,None,None,"Raise Mewtwo to Lv70 and score 150 KOs with it."),
 "MEGA_MEWTWO_Y":   ("MEWTWONITE_Y","MEWTWONITE Y","MEWTWO",70,None,None,100,120,"Raise Mewtwo to Lv70, win 100 battles, and own 120 dex entries."),
 "MEGA_AMPHAROS":   ("AMPHAROSITE","AMPHAROSITE","AMPHAROS",50,["MAREEP","FLAAFFY","AMPHAROS"],50,None,None,"Raise an Ampharos to Lv50 and score 50 KOs with the Mareep line."),
 "MEGA_STEELIX":    ("STEELIXITE","STEELIXITE","STEELIX",55,["ONIX","STEELIX"],55,None,None,"Raise a Steelix to Lv55 and score 55 KOs with the Onix line."),
 "MEGA_SCIZOR":     ("SCIZORITE","SCIZORITE","SCIZOR",55,["SCYTHER","SCIZOR"],60,None,None,"Raise a Scizor to Lv55 and score 60 KOs with the Scyther line."),
 "MEGA_HERACROSS":  ("HERACRONITE","HERACRONITE","HERACROSS",55,["HERACROSS"],66,None,None,"Raise a Heracross to Lv55 and score 66 KOs with it."),
 "MEGA_HOUNDOOM":   ("HOUNDOOMINITE","HOUNDOOMINITE","HOUNDOOM",55,["HOUNDOUR","HOUNDOOM"],66,None,None,"Raise a Houndoom to Lv55 and score 66 KOs with the Houndour line."),
 "MEGA_TYRANITAR":  ("TYRANITARITE","TYRANITARITE","TYRANITAR",60,["LARVITAR","PUPITAR","TYRANITAR"],100,None,None,"Raise a Tyranitar to Lv60 and score 100 KOs with the Larvitar line."),
}

ORDER = ["MEGA_VENUSAUR","MEGA_CHARIZARD_X","MEGA_CHARIZARD_Y","MEGA_BLASTOISE","MEGA_BEEDRILL",
 "MEGA_PIDGEOT","MEGA_ALAKAZAM","MEGA_SLOWBRO","MEGA_GENGAR","MEGA_KANGASKHAN","MEGA_PINSIR",
 "MEGA_GYARADOS","MEGA_AERODACTYL","MEGA_MEWTWO_X","MEGA_MEWTWO_Y","MEGA_AMPHAROS","MEGA_STEELIX",
 "MEGA_SCIZOR","MEGA_HERACROSS","MEGA_HOUNDOOM","MEGA_TYRANITAR"]

def luastr_list(xs):
    return "{ " + ", ".join('"%s"' % x for x in xs) + " }"

lua = []
for fid in ORDER:
    b = base[fid]; q = Q[fid]
    stone, sname, sp, lvl, koline, kocount, wins, dex, blurb = q
    quest = 'level = %d' % lvl
    if koline: quest += ', koLine = %s, koCount = %d' % (luastr_list(koline), kocount)
    if wins: quest += ', wins = %d' % wins
    if dex: quest += ', dex = %d' % dex
    lua.append(
      '    { id = "%s", name = "%s", from = "%s", dex = %s, sprite = "%s",\n'
      '      types = { %s },\n'
      '      baseStats = { hp = %s, attack = %s, defense = %s, speed = %s, special = %s },\n'
      '      frontSize = 7, stone = "%s", stoneName = "%s",\n'
      '      quest = { %s,\n'
      '        blurb = "%s" } },'
      % (b['id'], b['name'], b['from'], b['dex'], b['sprite'], b['types'],
         b['hp'], b['atk'], b['df'], b['spd'], b['spc'], stone, sname, quest, blurb))

open(r'C:\Users\EDUARD~1\AppData\Local\Temp\claude\megas_full.lua.txt','w',encoding='utf-8').write("\n".join(lua))

# QUESTS.md
md = ["# Mega Evolution — Quests\n",
 "Talk to **Megare** in Professor Oak's Lab (Pallet Town). Every quest tracks",
 "automatically in the background; when one is complete, talk to Megare to",
 "receive that Pokemon's **Mega Stone**. Hold the stone and you can Mega Evolve",
 "that Pokemon in battle by pressing **SELECT** (Tab).\n",
 "KO counts are **per species line** (any Pokemon in the listed line contributes).",
 "\"Win\" counts are total battles won; \"dex\" is Pokemon registered as owned.\n",
 "| Pokemon | Mega Stone | Requirements |",
 "|---|---|---|"]
for fid in ORDER:
    b = base[fid]; q = Q[fid]
    stone, sname, sp, lvl, koline, kocount, wins, dex, blurb = q
    reqs = ["own **%s** at **Lv %d**" % (sp, lvl)]
    if koline: reqs.append("**%d KOs** with %s" % (kocount, "/".join(koline).title()))
    if wins: reqs.append("**%d battles won**" % wins)
    if dex: reqs.append("**%d dex** owned" % dex)
    formlbl = b['name'] + (" X" if fid.endswith("_X") else " Y" if fid.endswith("_Y") else "")
    md.append("| %s | %s | %s |" % (formlbl, sname, "; ".join(reqs)))
md.append("\n_All 21 Gen 1/2 mega forms. Charizard and Mewtwo have X and Y stones — "
          "earn either (or both) and pick the form in the mod's options._")
open(r'C:\games\mods\mega_evolution\QUESTS.md','w',encoding='utf-8').write("\n".join(md)+"\n")

print("wrote megas_full.lua.txt (%d forms) and QUESTS.md" % len(lua))
print("stones:", ", ".join(Q[f][0] for f in ORDER))
