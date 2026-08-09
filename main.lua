-- Mega Evolution for Gen1Recomp.
--
-- Mega Evolution is NOT a permanent evolution — it's a temporary, in-battle
-- transformation that reverts when the battle ends. It reuses the machinery
-- the engine's TRANSFORM move already uses (src/battle/MoveEffects.lua
-- TRANSFORM_EFFECT): overwrite a battler's VOLATILE fields — `sprite`,
-- `curStats`, `curTypes` — which the renderer and src/battle/Damage.lua read
-- live and which makeBattler rebuilds each battle. The party mon
-- (`battler.mon`) is never touched, so the revert is automatic and free.
--
-- Each mega is a HIDDEN species (dex 5000+/6000+, outside gen2_dex's pinned
-- 1..251 Pokedex bound) that exists only for its stats, types, and sprite.
--
-- Requires gen2_dex (pins the Pokedex bound; provides DARK/STEEL for the
-- Gyarados/Houndoom/Tyranitar/Scizor/Steelix lines).

return function(mod)
  local ASSETS = mod.path .. "/assets"
  local Stats = require("src.pokemon.Stats") -- whitelisted require
  local Font = mod.ui.Font

  ----------------------------------------------------------------------------
  -- 1) Mega forms (stats/types pulled from PokeAPI; `special` = round of the
  --    Sp.Atk/Sp.Def average, the gen2_dex convention). Species with two
  --    forms (Charizard, Mewtwo) list both; a per-species option picks which.
  ----------------------------------------------------------------------------
  local MEGAS = {
    { id = "MEGA_VENUSAUR", name = "VENUSAUR", from = "VENUSAUR", dex = 5003, sprite = "mega_venusaur",
      types = { "GRASS", "POISON" },
      baseStats = { hp = 80, attack = 100, defense = 123, speed = 80, special = 121 },
      frontSize = 7 },
    { id = "MEGA_CHARIZARD_X", name = "CHARIZARD", from = "CHARIZARD", dex = 5006, sprite = "mega_charizard_x",
      types = { "FIRE", "DRAGON" },
      baseStats = { hp = 78, attack = 130, defense = 111, speed = 100, special = 108 },
      frontSize = 7 },
    { id = "MEGA_CHARIZARD_Y", name = "CHARIZARD", from = "CHARIZARD", dex = 6006, sprite = "mega_charizard_y",
      types = { "FIRE", "FLYING" },
      baseStats = { hp = 78, attack = 104, defense = 78, speed = 100, special = 137 },
      frontSize = 7 },
    { id = "MEGA_BLASTOISE", name = "BLASTOISE", from = "BLASTOISE", dex = 5009, sprite = "mega_blastoise",
      types = { "WATER" },
      baseStats = { hp = 79, attack = 103, defense = 120, speed = 78, special = 125 },
      frontSize = 7 },
    { id = "MEGA_BEEDRILL", name = "BEEDRILL", from = "BEEDRILL", dex = 5015, sprite = "mega_beedrill",
      types = { "BUG", "POISON" },
      baseStats = { hp = 65, attack = 150, defense = 40, speed = 145, special = 48 },
      frontSize = 7 },
    { id = "MEGA_PIDGEOT", name = "PIDGEOT", from = "PIDGEOT", dex = 5018, sprite = "mega_pidgeot",
      types = { "NORMAL", "FLYING" },
      baseStats = { hp = 83, attack = 80, defense = 80, speed = 121, special = 108 },
      frontSize = 7 },
    { id = "MEGA_ALAKAZAM", name = "ALAKAZAM", from = "ALAKAZAM", dex = 5065, sprite = "mega_alakazam",
      types = { "PSYCHIC_TYPE" },
      baseStats = { hp = 55, attack = 50, defense = 65, speed = 150, special = 140 },
      frontSize = 7 },
    { id = "MEGA_SLOWBRO", name = "SLOWBRO", from = "SLOWBRO", dex = 5080, sprite = "mega_slowbro",
      types = { "WATER", "PSYCHIC_TYPE" },
      baseStats = { hp = 95, attack = 75, defense = 180, speed = 30, special = 105 },
      frontSize = 7 },
    { id = "MEGA_GENGAR", name = "GENGAR", from = "GENGAR", dex = 5094, sprite = "mega_gengar",
      types = { "GHOST", "POISON" },
      baseStats = { hp = 60, attack = 65, defense = 80, speed = 130, special = 133 },
      frontSize = 7 },
    { id = "MEGA_KANGASKHAN", name = "KANGASKHAN", from = "KANGASKHAN", dex = 5115, sprite = "mega_kangaskhan",
      types = { "NORMAL" },
      baseStats = { hp = 105, attack = 125, defense = 100, speed = 100, special = 80 },
      frontSize = 7 },
    { id = "MEGA_PINSIR", name = "PINSIR", from = "PINSIR", dex = 5127, sprite = "mega_pinsir",
      types = { "BUG", "FLYING" },
      baseStats = { hp = 65, attack = 155, defense = 120, speed = 105, special = 78 },
      frontSize = 7 },
    { id = "MEGA_GYARADOS", name = "GYARADOS", from = "GYARADOS", dex = 5130, sprite = "mega_gyarados",
      types = { "WATER", "DARK" },
      baseStats = { hp = 95, attack = 155, defense = 109, speed = 81, special = 100 },
      frontSize = 7 },
    { id = "MEGA_AERODACTYL", name = "AERODACTYL", from = "AERODACTYL", dex = 5142, sprite = "mega_aerodactyl",
      types = { "ROCK", "FLYING" },
      baseStats = { hp = 80, attack = 135, defense = 85, speed = 150, special = 83 },
      frontSize = 7 },
    { id = "MEGA_MEWTWO_X", name = "MEWTWO", from = "MEWTWO", dex = 5150, sprite = "mega_mewtwo_x",
      types = { "PSYCHIC_TYPE", "FIGHTING" },
      baseStats = { hp = 106, attack = 190, defense = 100, speed = 130, special = 127 },
      frontSize = 7 },
    { id = "MEGA_MEWTWO_Y", name = "MEWTWO", from = "MEWTWO", dex = 6150, sprite = "mega_mewtwo_y",
      types = { "PSYCHIC_TYPE" },
      baseStats = { hp = 106, attack = 150, defense = 70, speed = 140, special = 157 },
      frontSize = 7 },
    { id = "MEGA_AMPHAROS", name = "AMPHAROS", from = "AMPHAROS", dex = 5181, sprite = "mega_ampharos",
      types = { "ELECTRIC", "DRAGON" },
      baseStats = { hp = 90, attack = 95, defense = 105, speed = 45, special = 138 },
      frontSize = 7 },
    { id = "MEGA_STEELIX", name = "STEELIX", from = "STEELIX", dex = 5208, sprite = "mega_steelix",
      types = { "STEEL", "GROUND" },
      baseStats = { hp = 75, attack = 125, defense = 230, speed = 30, special = 75 },
      frontSize = 7 },
    { id = "MEGA_SCIZOR", name = "SCIZOR", from = "SCIZOR", dex = 5212, sprite = "mega_scizor",
      types = { "BUG", "STEEL" },
      baseStats = { hp = 70, attack = 150, defense = 140, speed = 75, special = 83 },
      frontSize = 7 },
    { id = "MEGA_HERACROSS", name = "HERACROSS", from = "HERACROSS", dex = 5214, sprite = "mega_heracross",
      types = { "BUG", "FIGHTING" },
      baseStats = { hp = 80, attack = 185, defense = 115, speed = 75, special = 73 },
      frontSize = 7 },
    { id = "MEGA_HOUNDOOM", name = "HOUNDOOM", from = "HOUNDOOM", dex = 5229, sprite = "mega_houndoom",
      types = { "DARK", "FIRE" },
      baseStats = { hp = 75, attack = 90, defense = 90, speed = 115, special = 115 },
      frontSize = 7 },
    { id = "MEGA_TYRANITAR", name = "TYRANITAR", from = "TYRANITAR", dex = 5248, sprite = "mega_tyranitar",
      types = { "ROCK", "DARK" },
      baseStats = { hp = 100, attack = 164, defense = 150, speed = 71, special = 108 },
      frontSize = 7 },
  }

  local BY_FROM = {} -- base species id -> list of mega records (1 or 2)
  local BY_ID = {}   -- mega species id  -> mega record
  for _, m in ipairs(MEGAS) do
    BY_FROM[m.from] = BY_FROM[m.from] or {}
    table.insert(BY_FROM[m.from], m)
    BY_ID[m.id] = m
  end

  ----------------------------------------------------------------------------
  -- 2) Register each mega as a hidden species + serve its sprite from this
  --    mod's PNGs (same pipeline as gen2_dex).
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
  -- 3) Options: minimum level, battle cooldown, and one X/Y picker per
  --    species that has two mega forms.
  ----------------------------------------------------------------------------
  local schema = {
    { key = "minlevel", label = "MEGA MIN LVL", type = "choice", default = "40",
      choices = { { "OFF", "0" }, { "LV30", "30" }, { "LV40", "40" }, { "LV50", "50" } } },
    { key = "cooldown", label = "MEGA COOLDOWN", type = "choice", default = "off",
      choices = { { "OFF", "off" }, { "EVERY 3", "3" },
                  { "EVERY 5", "5" }, { "EVERY 10", "10" } } },
  }
  local variantSeen = {}
  for _, m in ipairs(MEGAS) do
    local list = BY_FROM[m.from]
    if #list > 1 and not variantSeen[m.from] then
      variantSeen[m.from] = true
      local choices = {}
      for i, mm in ipairs(list) do
        choices[i] = { "MEGA " .. (mm.id:match("_(%u)$") or tostring(i)), tostring(i) }
      end
      schema[#schema + 1] = { key = "var_" .. m.from, label = m.from .. " MEGA",
                              type = "choice", default = "1", choices = choices }
    end
  end
  mod.options:define(schema)

  local function optionValue(game, key)
    local opts = game and game.save and game.save.options
    local bucket = opts and opts.modOptions and opts.modOptions[mod.id]
    local v = bucket and bucket[key]
    if v == nil then v = mod.options:get(key) end
    return v
  end

  -- which mega a species uses right now (honours the X/Y option)
  local function chosenMega(game, species)
    local list = BY_FROM[species]
    if not list then return nil end
    if #list == 1 then return list[1] end
    local idx = tonumber(optionValue(game, "var_" .. species)) or 1
    return list[idx] or list[1]
  end

  ----------------------------------------------------------------------------
  -- 4) Battle counter for the cooldown (mod.save persists across battles).
  ----------------------------------------------------------------------------
  mod.events:on("battle.started", function()
    mod.save:set("battleCount", (mod.save:get("battleCount") or 0) + 1)
  end)

  ----------------------------------------------------------------------------
  -- 5) The transform (mirrors TRANSFORM_EFFECT). Max HP kept.
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

  ----------------------------------------------------------------------------
  -- 6) Trigger, gates, and the transformation animation, in battle.overlay.
  ----------------------------------------------------------------------------
  -- Rising-edge tracker for the SELECT keys (Tab / Shift), read from
  -- love.keyboard so the trigger is frame-reliable in this draw seam.
  local selectWasDown = false
  local function selectEdge()
    local down = love.keyboard.isDown("tab")
              or love.keyboard.isDown("rshift") or love.keyboard.isDown("lshift")
    local edge = down and not selectWasDown
    selectWasDown = down
    return edge
  end

  -- Animation timing (wall-clock, so --speed / animation-off don't distort it).
  local A_CHARGE, A_PEAK, A_FADE = 0.85, 0.12, 0.33
  local A_DUR = A_CHARGE + A_PEAK + A_FADE

  mod.hooks:wrap("battle.overlay", function(next, battle)
    next()
    if not (battle and battle.player and battle.player.mon) then return end
    battle.megaMons = battle.megaMons or {}
    local b = battle.player

    -- (a) an in-progress transformation owns the frame: flicker the pic
    -- between the two forms, ramp a white flash over it, then reveal.
    local anim = battle.megaAnim
    if anim then
      local t = love.timer.getTime() - anim.t0
      if t >= A_DUR then
        if anim.b then anim.b.sprite = anim.megaSprite end
        battle.megaAnim = nil
      else
        local flash
        if t < A_CHARGE then
          -- accelerating flicker between base and mega silhouettes
          local prog = t / A_CHARGE
          local period = 0.15 - 0.115 * prog
          if anim.b then
            anim.b.sprite = (math.floor(t / period) % 2 == 0)
                            and anim.origSprite or anim.megaSprite
          end
          flash = prog * prog * prog * 0.8
        elseif t < A_CHARGE + A_PEAK then
          if anim.b then anim.b.sprite = anim.megaSprite end
          flash = 1               -- full white; the swap happens under it
        else
          if anim.b then anim.b.sprite = anim.megaSprite end
          flash = 1 - (t - A_CHARGE - A_PEAK) / A_FADE -- fade to reveal
        end
        love.graphics.setColor(1, 1, 1, math.max(0, math.min(1, flash)))
        love.graphics.rectangle("fill", 0, 0, 160, 144)
        love.graphics.setColor(1, 1, 1, 1)
      end
      return
    end

    -- (b) a switch rebuilt the battler -> re-apply the mega it had
    local remembered = battle.megaMons[b.mon]
    if remembered and b.megaForm ~= remembered.id then
      applyMega(battle, b, remembered)
    end

    -- (c) eligibility + gate reasons (for the prompt)
    local m = chosenMega(battle.game, b.mon.species)
    local reason
    if m and not battle.megaMons[b.mon] then
      if battle.megaUsed then
        reason = "USED"
      elseif battle.phase == "menu" then
        local minLvl = tonumber(optionValue(battle.game, "minlevel")) or 0
        local cd = optionValue(battle.game, "cooldown")
        local cdN = (cd ~= "off") and (tonumber(cd) or 0) or 0
        if b.mon.level < minLvl then
          reason = "NEED LV" .. minLvl
        elseif cdN > 0 then
          local since = (mod.save:get("battleCount") or 0)
                        - (mod.save:get("lastMegaBattle") or -9999)
          if since < cdN then reason = "CD " .. (cdN - since) end
        end
      end
    end
    local canMega = m and not battle.megaMons[b.mon]
                    and not battle.megaUsed and battle.phase == "menu"
                    and reason == nil

    -- (d) trigger: start the transformation. Stats/types apply now (so the
    -- mega is live for the turn even if the player rushes a move); the
    -- animation plays over the swap.
    if selectEdge() and canMega then
      local orig = b.sprite
      if applyMega(battle, b, m) then
        battle.megaMons[b.mon] = m
        battle.megaUsed = true
        mod.save:set("lastMegaBattle", mod.save:get("battleCount") or 0)
        battle.megaAnim = { b = b, t0 = love.timer.getTime(),
                            origSprite = orig, megaSprite = b.sprite }
        b.sprite = orig -- show the base for this first frame; anim takes over
        pcall(function()
          require("src.core.Sound").playCry(battle.data, b.mon.species)
        end)
      end
    end

    -- (e) prompt: small, only for a mega-capable active mon
    if m and not b.megaForm then
      love.graphics.setColor(0, 0, 0, 1)
      if canMega then Font.draw("TAB:MEGA", 0, 0)
      elseif reason then Font.draw(reason, 0, 0) end
      love.graphics.setColor(1, 1, 1, 1)
    end
  end, 900)
end
