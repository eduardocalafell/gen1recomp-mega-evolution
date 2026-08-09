-- Mega Evolution for Gen1Recomp.
--
-- Mega Evolution is a TEMPORARY in-battle transformation (not a permanent
-- evolution): it reuses the engine's TRANSFORM machinery — overwrite a
-- battler's volatile curStats/curTypes/sprite, never the party mon, so it
-- reverts for free at battle's end.
--
-- Unlock model: an NPC, **Megare**, stands in Professor Oak's Lab and sets a
-- trial per Pokemon. Every trial tracks in the background; clear one and Megare
-- hands you that Pokemon's **Mega Stone** (a key item). Hold the stone and you
-- can Mega Evolve that Pokemon in battle with SELECT (Tab). See QUESTS.md.
--
-- Requires gen2_dex (pins the Pokedex bound; provides DARK/STEEL types).

return function(mod)
  local ASSETS = mod.path .. "/assets"
  local Stats = require("src.pokemon.Stats") -- whitelisted require

  ----------------------------------------------------------------------------
  -- 1) Mega forms + their stone (key item) + trial. Stats/types from PokeAPI
  --    (special = round of the Sp.Atk/Sp.Def average). koLine = the species
  --    whose KOs count for that trial. See tools/ + QUESTS.md.
  ----------------------------------------------------------------------------
  local MEGAS = {
    { id = "MEGA_VENUSAUR", name = "VENUSAUR", from = "VENUSAUR", dex = 5003, sprite = "mega_venusaur",
      types = { "GRASS", "POISON" },
      baseStats = { hp = 80, attack = 100, defense = 123, speed = 80, special = 121 },
      frontSize = 7, stone = "VENUSAURITE", stoneName = "VENUSAURITE",
      quest = { level = 50, koLine = { "BULBASAUR", "IVYSAUR", "VENUSAUR" }, koCount = 60,
        blurb = "Raise a Venusaur to Lv50 and score 60 KOs with the Bulbasaur line." } },
    { id = "MEGA_CHARIZARD_X", name = "CHARIZARD", from = "CHARIZARD", dex = 5006, sprite = "mega_charizard_x",
      types = { "FIRE", "DRAGON" },
      baseStats = { hp = 78, attack = 130, defense = 111, speed = 100, special = 108 },
      frontSize = 7, stone = "CHARIZARDITE_X", stoneName = "CHARIZARDITE X",
      quest = { level = 60, koLine = { "CHARMANDER", "CHARMELEON", "CHARIZARD" }, koCount = 100,
        blurb = "Raise a Charizard to Lv60 and score 100 KOs with the Charmander line." } },
    { id = "MEGA_CHARIZARD_Y", name = "CHARIZARD", from = "CHARIZARD", dex = 6006, sprite = "mega_charizard_y",
      types = { "FIRE", "FLYING" },
      baseStats = { hp = 78, attack = 104, defense = 78, speed = 100, special = 137 },
      frontSize = 7, stone = "CHARIZARDITE_Y", stoneName = "CHARIZARDITE Y",
      quest = { level = 60, wins = 80,
        blurb = "Raise a Charizard to Lv60 and win 80 battles." } },
    { id = "MEGA_BLASTOISE", name = "BLASTOISE", from = "BLASTOISE", dex = 5009, sprite = "mega_blastoise",
      types = { "WATER" },
      baseStats = { hp = 79, attack = 103, defense = 120, speed = 78, special = 125 },
      frontSize = 7, stone = "BLASTOISINITE", stoneName = "BLASTOISINITE",
      quest = { level = 50, koLine = { "SQUIRTLE", "WARTORTLE", "BLASTOISE" }, koCount = 60,
        blurb = "Raise a Blastoise to Lv50 and score 60 KOs with the Squirtle line." } },
    { id = "MEGA_BEEDRILL", name = "BEEDRILL", from = "BEEDRILL", dex = 5015, sprite = "mega_beedrill",
      types = { "BUG", "POISON" },
      baseStats = { hp = 65, attack = 150, defense = 40, speed = 145, special = 48 },
      frontSize = 7, stone = "BEEDRILLITE", stoneName = "BEEDRILLITE",
      quest = { level = 30, koLine = { "WEEDLE", "KAKUNA", "BEEDRILL" }, koCount = 30,
        blurb = "Raise a Beedrill to Lv30 and score 30 KOs with the Weedle line." } },
    { id = "MEGA_PIDGEOT", name = "PIDGEOT", from = "PIDGEOT", dex = 5018, sprite = "mega_pidgeot",
      types = { "NORMAL", "FLYING" },
      baseStats = { hp = 83, attack = 80, defense = 80, speed = 121, special = 108 },
      frontSize = 7, stone = "PIDGEOTITE", stoneName = "PIDGEOTITE",
      quest = { level = 35, koLine = { "PIDGEY", "PIDGEOTTO", "PIDGEOT" }, koCount = 40,
        blurb = "Raise a Pidgeot to Lv35 and score 40 KOs with the Pidgey line." } },
    { id = "MEGA_ALAKAZAM", name = "ALAKAZAM", from = "ALAKAZAM", dex = 5065, sprite = "mega_alakazam",
      types = { "PSYCHIC_TYPE" },
      baseStats = { hp = 55, attack = 50, defense = 65, speed = 150, special = 140 },
      frontSize = 7, stone = "ALAKAZITE", stoneName = "ALAKAZITE",
      quest = { level = 50, koLine = { "ABRA", "KADABRA", "ALAKAZAM" }, koCount = 40, dex = 60,
        blurb = "Raise an Alakazam to Lv50, score 40 KOs with the Abra line, and own 60 dex entries." } },
    { id = "MEGA_SLOWBRO", name = "SLOWBRO", from = "SLOWBRO", dex = 5080, sprite = "mega_slowbro",
      types = { "WATER", "PSYCHIC_TYPE" },
      baseStats = { hp = 95, attack = 75, defense = 180, speed = 30, special = 105 },
      frontSize = 7, stone = "SLOWBRONITE", stoneName = "SLOWBRONITE",
      quest = { level = 50, koLine = { "SLOWPOKE", "SLOWBRO" }, koCount = 40,
        blurb = "Raise a Slowbro to Lv50 and score 40 KOs with the Slowpoke line." } },
    { id = "MEGA_GENGAR", name = "GENGAR", from = "GENGAR", dex = 5094, sprite = "mega_gengar",
      types = { "GHOST", "POISON" },
      baseStats = { hp = 60, attack = 65, defense = 80, speed = 130, special = 133 },
      frontSize = 7, stone = "GENGARITE", stoneName = "GENGARITE",
      quest = { level = 50, koLine = { "GASTLY", "HAUNTER", "GENGAR" }, koCount = 66,
        blurb = "Raise a Gengar to Lv50 and score 66 KOs with the Gastly line." } },
    { id = "MEGA_KANGASKHAN", name = "KANGASKHAN", from = "KANGASKHAN", dex = 5115, sprite = "mega_kangaskhan",
      types = { "NORMAL" },
      baseStats = { hp = 105, attack = 125, defense = 100, speed = 100, special = 80 },
      frontSize = 7, stone = "KANGASKHANITE", stoneName = "KANGASKHANITE",
      quest = { level = 35, koLine = { "KANGASKHAN" }, koCount = 40,
        blurb = "Raise a Kangaskhan to Lv35 and score 40 KOs with it." } },
    { id = "MEGA_PINSIR", name = "PINSIR", from = "PINSIR", dex = 5127, sprite = "mega_pinsir",
      types = { "BUG", "FLYING" },
      baseStats = { hp = 65, attack = 155, defense = 120, speed = 105, special = 78 },
      frontSize = 7, stone = "PINSIRITE", stoneName = "PINSIRITE",
      quest = { level = 45, koLine = { "PINSIR" }, koCount = 50,
        blurb = "Raise a Pinsir to Lv45 and score 50 KOs with it." } },
    { id = "MEGA_GYARADOS", name = "GYARADOS", from = "GYARADOS", dex = 5130, sprite = "mega_gyarados",
      types = { "WATER", "DARK" },
      baseStats = { hp = 95, attack = 155, defense = 109, speed = 81, special = 100 },
      frontSize = 7, stone = "GYARADOSITE", stoneName = "GYARADOSITE",
      quest = { level = 50, koLine = { "MAGIKARP", "GYARADOS" }, koCount = 50,
        blurb = "Raise a Gyarados to Lv50 and score 50 KOs with the Magikarp line." } },
    { id = "MEGA_AERODACTYL", name = "AERODACTYL", from = "AERODACTYL", dex = 5142, sprite = "mega_aerodactyl",
      types = { "ROCK", "FLYING" },
      baseStats = { hp = 80, attack = 135, defense = 85, speed = 150, special = 83 },
      frontSize = 7, stone = "AERODACTYLITE", stoneName = "AERODACTYLITE",
      quest = { level = 50, koLine = { "AERODACTYL" }, koCount = 50,
        blurb = "Raise an Aerodactyl to Lv50 and score 50 KOs with it." } },
    { id = "MEGA_MEWTWO_X", name = "MEWTWO", from = "MEWTWO", dex = 5150, sprite = "mega_mewtwo_x",
      types = { "PSYCHIC_TYPE", "FIGHTING" },
      baseStats = { hp = 106, attack = 190, defense = 100, speed = 130, special = 127 },
      frontSize = 7, stone = "MEWTWONITE_X", stoneName = "MEWTWONITE X",
      quest = { level = 70, koLine = { "MEWTWO" }, koCount = 150,
        blurb = "Raise Mewtwo to Lv70 and score 150 KOs with it." } },
    { id = "MEGA_MEWTWO_Y", name = "MEWTWO", from = "MEWTWO", dex = 6150, sprite = "mega_mewtwo_y",
      types = { "PSYCHIC_TYPE" },
      baseStats = { hp = 106, attack = 150, defense = 70, speed = 140, special = 157 },
      frontSize = 7, stone = "MEWTWONITE_Y", stoneName = "MEWTWONITE Y",
      quest = { level = 70, wins = 100, dex = 120,
        blurb = "Raise Mewtwo to Lv70, win 100 battles, and own 120 dex entries." } },
    { id = "MEGA_AMPHAROS", name = "AMPHAROS", from = "AMPHAROS", dex = 5181, sprite = "mega_ampharos",
      types = { "ELECTRIC", "DRAGON" },
      baseStats = { hp = 90, attack = 95, defense = 105, speed = 45, special = 138 },
      frontSize = 7, stone = "AMPHAROSITE", stoneName = "AMPHAROSITE",
      quest = { level = 50, koLine = { "MAREEP", "FLAAFFY", "AMPHAROS" }, koCount = 50,
        blurb = "Raise an Ampharos to Lv50 and score 50 KOs with the Mareep line." } },
    { id = "MEGA_STEELIX", name = "STEELIX", from = "STEELIX", dex = 5208, sprite = "mega_steelix",
      types = { "STEEL", "GROUND" },
      baseStats = { hp = 75, attack = 125, defense = 230, speed = 30, special = 75 },
      frontSize = 7, stone = "STEELIXITE", stoneName = "STEELIXITE",
      quest = { level = 55, koLine = { "ONIX", "STEELIX" }, koCount = 55,
        blurb = "Raise a Steelix to Lv55 and score 55 KOs with the Onix line." } },
    { id = "MEGA_SCIZOR", name = "SCIZOR", from = "SCIZOR", dex = 5212, sprite = "mega_scizor",
      types = { "BUG", "STEEL" },
      baseStats = { hp = 70, attack = 150, defense = 140, speed = 75, special = 83 },
      frontSize = 7, stone = "SCIZORITE", stoneName = "SCIZORITE",
      quest = { level = 55, koLine = { "SCYTHER", "SCIZOR" }, koCount = 60,
        blurb = "Raise a Scizor to Lv55 and score 60 KOs with the Scyther line." } },
    { id = "MEGA_HERACROSS", name = "HERACROSS", from = "HERACROSS", dex = 5214, sprite = "mega_heracross",
      types = { "BUG", "FIGHTING" },
      baseStats = { hp = 80, attack = 185, defense = 115, speed = 75, special = 73 },
      frontSize = 7, stone = "HERACRONITE", stoneName = "HERACRONITE",
      quest = { level = 55, koLine = { "HERACROSS" }, koCount = 66,
        blurb = "Raise a Heracross to Lv55 and score 66 KOs with it." } },
    { id = "MEGA_HOUNDOOM", name = "HOUNDOOM", from = "HOUNDOOM", dex = 5229, sprite = "mega_houndoom",
      types = { "DARK", "FIRE" },
      baseStats = { hp = 75, attack = 90, defense = 90, speed = 115, special = 115 },
      frontSize = 7, stone = "HOUNDOOMINITE", stoneName = "HOUNDOOMINITE",
      quest = { level = 55, koLine = { "HOUNDOUR", "HOUNDOOM" }, koCount = 66,
        blurb = "Raise a Houndoom to Lv55 and score 66 KOs with the Houndour line." } },
    { id = "MEGA_TYRANITAR", name = "TYRANITAR", from = "TYRANITAR", dex = 5248, sprite = "mega_tyranitar",
      types = { "ROCK", "DARK" },
      baseStats = { hp = 100, attack = 164, defense = 150, speed = 71, special = 108 },
      frontSize = 7, stone = "TYRANITARITE", stoneName = "TYRANITARITE",
      quest = { level = 60, koLine = { "LARVITAR", "PUPITAR", "TYRANITAR" }, koCount = 100,
        blurb = "Raise a Tyranitar to Lv60 and score 100 KOs with the Larvitar line." } },
  }

  local BY_FROM = {} -- base species -> list of mega forms (1 or 2)
  local BY_ID = {}   -- mega id -> form
  for _, m in ipairs(MEGAS) do
    BY_FROM[m.from] = BY_FROM[m.from] or {}
    table.insert(BY_FROM[m.from], m)
    BY_ID[m.id] = m
  end

  ----------------------------------------------------------------------------
  -- 2) Register each mega as a hidden species + its Mega Stone key item, and
  --    serve mega sprites from this mod's PNGs (same pipeline as gen2_dex).
  ----------------------------------------------------------------------------
  for _, m in ipairs(MEGAS) do
    mod.content.pokemon:register(m.id, {
      id = m.id, name = m.name, dex = m.dex, types = m.types,
      baseStats = m.baseStats,
      catchRate = 45, baseExp = 240, growthRate = "MEDIUM_SLOW",
      level1Moves = {}, learnset = {}, evolutions = {},
      spriteFront = "assets/" .. m.sprite .. "_front.png",
      spriteBack  = "assets/" .. m.sprite .. "_back.png",
      frontSize = m.frontSize, trueColor = true,
    })
    mod.content.items:register(m.stone, {
      id = m.stone, name = m.stoneName, price = 0, tossable = false,
    })
  end

  mod.hooks:wrap("pokemon.sprite", function(next, originalPath, ctx)
    local m = ctx and BY_ID[ctx.species]
    if m then
      ctx.trueColor = true
      local side = ctx.side == "back" and "back" or "front"
      return ASSETS .. "/" .. m.sprite .. "_" .. side .. ".png"
    end
    return next(originalPath, ctx)
  end, 950)

  ----------------------------------------------------------------------------
  -- 3) X/Y picker option, one per species that has two mega forms.
  ----------------------------------------------------------------------------
  local schema, seen = {}, {}
  for _, m in ipairs(MEGAS) do
    local list = BY_FROM[m.from]
    if #list > 1 and not seen[m.from] then
      seen[m.from] = true
      local choices = {}
      for i, mm in ipairs(list) do
        choices[i] = { "MEGA " .. (mm.id:match("_(%u)$") or tostring(i)), tostring(i) }
      end
      schema[#schema + 1] = { key = "var_" .. m.from, label = m.from .. " MEGA",
                              type = "choice", default = "1", choices = choices }
    end
  end
  if #schema > 0 then mod.options:define(schema) end

  local function optionValue(game, key)
    local opts = game and game.save and game.save.options
    local bucket = opts and opts.modOptions and opts.modOptions[mod.id]
    local v = bucket and bucket[key]
    if v == nil then v = mod.options:get(key) end
    return v
  end

  ----------------------------------------------------------------------------
  -- 4) Trial tracking (mod.save): KOs per species (enemy faints attributed to
  --    the active player mon) and total battles won.
  ----------------------------------------------------------------------------
  mod.events:on("battle.fainted", function(ev)
    local battle, fainted = ev and ev.battle, ev and ev.battler
    if not (battle and fainted) or fainted.isPlayer then return end
    local pmon = battle.player and battle.player.mon
    if not pmon or not pmon.species then return end
    local ko = mod.save:get("ko") or {}
    ko[pmon.species] = (ko[pmon.species] or 0) + 1
    mod.save:set("ko", ko)
  end)

  mod.events:on("battle.ended", function(ev)
    if ev and ev.result == "win" then
      mod.save:set("wins", (mod.save:get("wins") or 0) + 1)
    end
  end)

  ----------------------------------------------------------------------------
  -- 5) Trial evaluation helpers.
  ----------------------------------------------------------------------------
  local function eachOwnedMon(save, fn)
    for _, mon in ipairs(save.party or {}) do fn(mon) end
    local boxes = save.boxes or (save.pc and save.pc.boxes)
    if type(boxes) == "table" then
      for _, box in pairs(boxes) do
        local list = (type(box) == "table" and (box.mons or box)) or nil
        if type(list) == "table" then for _, mon in ipairs(list) do fn(mon) end end
      end
    end
  end

  local function maxOwnedLevel(save, species)
    local best = 0
    eachOwnedMon(save, function(mon)
      if mon and mon.species == species and (mon.level or 0) > best then best = mon.level end
    end)
    return best
  end

  local function ownsSpecies(save, species)
    return maxOwnedLevel(save, species) > 0
  end

  local function dexOwnedCount(save)
    local owned = save.pokedex and save.pokedex.owned
    if type(owned) ~= "table" then return 0 end
    local n = 0
    for _, v in pairs(owned) do if v then n = n + 1 end end
    return n
  end

  local function koSum(line)
    local ko = mod.save:get("ko") or {}
    local n = 0
    for _, s in ipairs(line or {}) do n = n + (ko[s] or 0) end
    return n
  end

  local function questDone(game, m)
    local q = m.quest
    if maxOwnedLevel(game.save, m.from) < q.level then return false end
    if q.koCount and koSum(q.koLine) < q.koCount then return false end
    if q.wins and (mod.save:get("wins") or 0) < q.wins then return false end
    if q.dex and dexOwnedCount(game.save) < q.dex then return false end
    return true
  end

  local function progressMsgs(game, m)
    local q = m.quest
    local out = { m.name .. " TRIAL:" }
    local line = "Lv" .. maxOwnedLevel(game.save, m.from) .. "/" .. q.level
    if q.koCount then line = line .. " KO" .. koSum(q.koLine) .. "/" .. q.koCount end
    out[#out + 1] = line
    if q.wins then out[#out + 1] = "WINS " .. (mod.save:get("wins") or 0) .. "/" .. q.wins end
    if q.dex then out[#out + 1] = "DEX " .. dexOwnedCount(game.save) .. "/" .. q.dex end
    return out
  end

  ----------------------------------------------------------------------------
  -- 6) Megare, the Mega researcher in Oak's Lab. Trials track passively; on
  --    talk he hands over every newly-cleared stone, else shows the progress
  --    of the first pending trial for a Pokemon you own.
  ----------------------------------------------------------------------------
  local function sayChain(game, msgs, done)
    local i = 0
    local function step()
      i = i + 1
      if i > #msgs then if done then done() end return end
      game.stack:push(require("src.render.TextBox").new(game, msgs[i], step))
    end
    step()
  end

  local function suffixOf(m)
    local s = m.id:match("_(%u)$")
    return s and (" " .. s) or ""
  end

  -- Browsable quest log: every mega form, marked * (stone earned) or - (trial
  -- still open). Choosing one shows its progress (or a "done" note). B closes.
  local function openQuestLog(game, onDone)
    local items = {}
    for _, m in ipairs(MEGAS) do
      local have = game.save.inventory and game.save.inventory[m.stone]
      items[#items + 1] = { label = (have and "*" or "-") .. " " .. m.name .. suffixOf(m),
                            mega = m }
    end
    local ListMenu = require("src.ui.ListMenu")
    local menu = ListMenu.new(game, "MEGA TRIALS", items, {
      wrap = true, keyRepeat = true,
      onCancel = function() if onDone then onDone() end end,
      onChoose = function(item)
        local m = item.mega
        local msgs = {}
        if game.save.inventory and game.save.inventory[m.stone] then
          msgs[#msgs + 1] = m.name .. suffixOf(m) .. ": CLEARED!"
          msgs[#msgs + 1] = "Hold " .. m.stoneName .. "\nto Mega Evolve."
        else
          for _, l in ipairs(progressMsgs(game, m)) do msgs[#msgs + 1] = l end
        end
        sayChain(game, msgs) -- returns to the list underneath
      end,
    })
    game.stack:push(menu)
  end

  -- Talk: greet (first time) + hand over every newly-cleared stone, then open
  -- the browsable quest log.
  local function megareTalk(game, ow, npc, onDone)
    local save = game.save
    local pre = {}
    if not mod.save:get("metMegare") then
      mod.save:set("metMegare", true)
      pre[#pre + 1] = "I'm MEGARE! I study\nMega Evolution."
      pre[#pre + 1] = "Clear my trials and I'll\ngive you the Mega Stone"
      pre[#pre + 1] = "that awakens each\nPOKeMON's true power!"
    end
    for _, m in ipairs(MEGAS) do
      if not mod.save:get("claim_" .. m.stone) and questDone(game, m) then
        require("src.inventory.Bag").add(save, m.stone, 1, game.data)
        mod.save:set("claim_" .. m.stone, true)
        pre[#pre + 1] = m.name .. suffixOf(m) .. " trial cleared!"
        pre[#pre + 1] = "Take the " .. m.stoneName .. "!"
      end
    end
    sayChain(game, pre, function() openQuestLog(game, onDone) end)
  end

  mod.content.maps:patch("OAKS_LAB", { objects = { __append = { {
    index = 90, name = "MEGARE", movement = "STAY", sprite = "SPRITE_SCIENTIST",
    text = "MEGARE_TALK", x = 8, y = 5, range = "DOWN",
  } } } })
  mod.content.map_scripts:register("OAKS_LAB", { talk = { MEGARE_TALK = megareTalk } })

  ----------------------------------------------------------------------------
  -- 7) The transform (mirrors TRANSFORM_EFFECT). Max HP kept.
  ----------------------------------------------------------------------------
  local function applyMega(battle, b, m)
    local megaDef = battle.data.pokemon[m.id]
    if not megaDef then return false end
    local st = Stats.calc(megaDef, b.mon.level, b.mon.dvs or {})
    st.hp = b.mon.stats.hp
    b.curStats = st
    b.curTypes = { m.types[1], m.types[2] }
    b.sprite = battle:speciesSprite(m.id, b.isPlayer) or b.sprite
    b.megaForm = m.id
    return true
  end

  -- which mega form the player can use for a species right now: it needs the
  -- Mega Stone in the bag. With both X/Y stones, the option picks.
  local function ownedForm(game, species)
    local list = BY_FROM[species]
    if not list then return nil end
    local inv = game.save and game.save.inventory or {}
    local owned = {}
    for _, m in ipairs(list) do if inv[m.stone] then owned[#owned + 1] = m end end
    if #owned == 0 then return nil end
    if #owned == 1 then return owned[1] end
    local idx = tonumber(optionValue(game, "var_" .. species)) or 1
    return owned[math.min(idx, #owned)]
  end

  ----------------------------------------------------------------------------
  -- 8) Trigger + transformation animation, in the battle.overlay draw seam.
  ----------------------------------------------------------------------------
  local Font = mod.ui.Font

  local selectWasDown = false
  local function selectEdge()
    local down = love.keyboard.isDown("tab")
              or love.keyboard.isDown("rshift") or love.keyboard.isDown("lshift")
    local edge = down and not selectWasDown
    selectWasDown = down
    return edge
  end

  local A_CHARGE, A_PEAK, A_FADE = 0.85, 0.12, 0.33
  local A_DUR = A_CHARGE + A_PEAK + A_FADE

  mod.hooks:wrap("battle.overlay", function(next, battle)
    next()
    if not (battle and battle.player and battle.player.mon) then return end
    battle.megaMons = battle.megaMons or {}
    local b = battle.player

    -- (a) transformation animation owns the frame
    local anim = battle.megaAnim
    if anim then
      local t = love.timer.getTime() - anim.t0
      if t >= A_DUR then
        if anim.b then anim.b.sprite = anim.megaSprite end
        battle.megaAnim = nil
      else
        local flash
        if t < A_CHARGE then
          local prog = t / A_CHARGE
          local period = 0.15 - 0.115 * prog
          if anim.b then
            anim.b.sprite = (math.floor(t / period) % 2 == 0)
                            and anim.origSprite or anim.megaSprite
          end
          flash = prog * prog * prog * 0.8
        elseif t < A_CHARGE + A_PEAK then
          if anim.b then anim.b.sprite = anim.megaSprite end
          flash = 1
        else
          if anim.b then anim.b.sprite = anim.megaSprite end
          flash = 1 - (t - A_CHARGE - A_PEAK) / A_FADE
        end
        love.graphics.setColor(1, 1, 1, math.max(0, math.min(1, flash)))
        love.graphics.rectangle("fill", 0, 0, 160, 144)
        love.graphics.setColor(1, 1, 1, 1)
      end
      return
    end

    -- (b) re-apply a mega a switch reset
    local remembered = battle.megaMons[b.mon]
    if remembered and b.megaForm ~= remembered.id then
      applyMega(battle, b, remembered)
    end

    -- (c) can this mon mega right now? (needs its stone)
    local m = ownedForm(battle.game, b.mon.species)
    local canMega = m and not battle.megaMons[b.mon]
                    and not battle.megaUsed and battle.phase == "menu"

    -- (d) trigger
    if selectEdge() and canMega then
      local orig = b.sprite
      if applyMega(battle, b, m) then
        battle.megaMons[b.mon] = m
        battle.megaUsed = true
        battle.megaAnim = { b = b, t0 = love.timer.getTime(),
                            origSprite = orig, megaSprite = b.sprite }
        b.sprite = orig
        pcall(function()
          require("src.core.Sound").playCry(battle.data, b.mon.species)
        end)
      end
    end

    -- (e) prompt
    if canMega then
      love.graphics.setColor(0, 0, 0, 1)
      Font.draw("TAB:MEGA", 0, 0)
      love.graphics.setColor(1, 1, 1, 1)
    end
  end, 900)
end
