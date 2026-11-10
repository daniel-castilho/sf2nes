-- cdl.lua — Code/Data Logger + referencias cruzadas para o Mesen 2 (modo --testrunner, sem janela).
-- Gera, para o ROM carregado (MMC5, PRG modo 3 = 4 bancos de 8K):
--   <OUT>/cdl.bin      1 byte por byte de PRG-ROM: bit0=executado, bit1=inicio de instrucao, bit2=lido como dado,
--                      bit3=lido na janela $C000-$DFFF (amostras DPCM), bit4=alvo de salto indireto/RTS-trick
--   <OUT>/edges.txt    saltos indiretos observados: tipo origem destino
--   <OUT>/readers.txt  pares (instrucao leitora -> offset de dado lido)
--   <OUT>/ram.txt      mapa de uso da RAM ($0000-$07FF): leituras, escritas e quem acessa
--   <OUT>/chr.txt      valores escritos nos registradores de CHR/PRG do MMC5
--   <OUT>/shots/*.png  screenshots periodicos
--   <OUT>/first.txt    por instrucao: offset, primeiro frame, ultimo frame, contagem, mascara de modos de tela ($B0)
--   <OUT>/timeline.txt mudancas de algumas variaveis de estado: frame endereco valor
--   <OUT>/apu.txt      hash acumulado das escritas na APU ($4000-$4017) a cada 60 quadros
-- Parametros vem de variaveis de ambiente (SF2_OUT, SF2_PLAN, SF2_FRAMES, SF2_SEED, SF2_SHOT_EVERY).
local OUT    = os.getenv("SF2_OUT") or "/tmp/sf2trace"
local PLAN   = os.getenv("SF2_PLAN") or "p1random"
local FRAMES = tonumber(os.getenv("SF2_FRAMES") or "7200")
local SEED   = tonumber(os.getenv("SF2_SEED") or "1")
local SHOT   = tonumber(os.getenv("SF2_SHOT_EVERY") or "300")
local HOLDS  = os.getenv("SF2_HOLD") or ""      -- "addr:valor:de:ate,..." (addr/valor em hex, frames em decimal): reescreve todo frame
local POKES  = os.getenv("SF2_POKES") or ""     -- "frame:addr:valor,frame:addr:valor" (hex) p/ forcar estados
os.execute('mkdir -p "' .. OUT .. '/shots"')

local LEN = {}  -- tamanho da instrucao por opcode (oficiais; ilegais = 1)
do
  local l1 = {0x00,0x08,0x0A,0x18,0x28,0x2A,0x38,0x40,0x48,0x4A,0x58,0x60,0x68,0x6A,0x78,0x88,0x8A,0x98,0x9A,0xA8,0xAA,0xB8,0xBA,0xC8,0xCA,0xD8,0xE8,0xEA,0xF8}
  local l3 = {0x0D,0x0E,0x19,0x1D,0x1E,0x20,0x2C,0x2D,0x2E,0x39,0x3D,0x3E,0x4C,0x4D,0x4E,0x59,0x5D,0x5E,0x6C,0x6D,0x6E,0x79,0x7D,0x7E,0x8C,0x8D,0x8E,0x99,0x9D,0xAC,0xAD,0xAE,0xB9,0xBC,0xBD,0xBE,0xCC,0xCD,0xCE,0xD9,0xDD,0xDE,0xEC,0xED,0xEE,0xF9,0xFD,0xFE}
  for i = 0, 255 do LEN[i] = 2 end
  for _, o in ipairs(l1) do LEN[o] = 1 end
  for _, o in ipairs(l3) do LEN[o] = 3 end
end

-- estado do mapeador (PRG modo 3): slot 0..3 = $8000,$A000,$C000,$E000
local prg = {[0]=0x3F, [1]=0x3F, [2]=0x3F, [3]=0x3F}
local prgIsRom = {[0]=true, [1]=true, [2]=true, [3]=true}
local flags = {}            -- offset PRG -> bits
local edges = {}            -- "tipo from to" -> n
local readers = {}          -- reader*2^20+data -> true
local nreaders = 0
local ramR, ramW, ramWho = {}, {}, {}
local regvals = {}          -- reg -> {valor -> n}
local curOp, curOpOff, curOpByte, remain, nextAddr = -1, -1, -1, 0, -1
local frame = 0
local firstF, lastF, countF = {}, {}, {}   -- por inicio de instrucao: primeiro/ultimo frame em que executou e contagem
local modeNow, modeMask = 0, {}            -- modo de tela atual (RAM $B0) e, por instrucao, mascara dos modos em que executou
local prevOpByte, prevOpOff = -1, -1
local RAMBASE = 0x1000000   -- offsets "virtuais" p/ codigo em RAM

local function off(addr)
  if addr >= 0x8000 then
    local s = (addr - 0x8000) >> 13
    return prg[s] * 0x2000 + (addr & 0x1FFF)
  end
  return RAMBASE + addr
end

emu.addMemoryCallback(function(addr, value)
  if remain > 0 and addr == nextAddr then
    remain = remain - 1; nextAddr = addr + 1
    if addr >= 0x8000 then local o = off(addr); flags[o] = (flags[o] or 0) | 1 end
    return
  end
  -- nova instrucao
  local o = off(addr)
  if prevOpByte == 0x60 or prevOpByte == 0x6C or prevOpByte == 0x40 then
    local k = string.format("%s %07X %07X", (prevOpByte == 0x60 and "RTS") or (prevOpByte == 0x6C and "JMPI") or "RTI", prevOpOff, o)
    edges[k] = (edges[k] or 0) + 1
  end
  if (prevOpByte == 0x20 or prevOpByte == 0x4C) and addr >= 0x8000 and curOp >= 0x8000 and (addr >> 13) ~= (curOp >> 13) then
    local k = string.format("%s %07X %07X", (prevOpByte == 0x20 and "XJSR") or "XJMP", prevOpOff, o)
    edges[k] = (edges[k] or 0) + 1
  end
  if addr >= 0x8000 then
    flags[o] = (flags[o] or 0) | 3
    if not firstF[o] then firstF[o] = frame; countF[o] = 0; modeMask[o] = 0 end
    lastF[o] = frame; countF[o] = countF[o] + 1
    modeMask[o] = modeMask[o] | (1 << modeNow)
  end
  prevOpByte = value; prevOpOff = o
  curOp = addr; curOpOff = o; curOpByte = value
  remain = LEN[value] - 1; nextAddr = addr + 1
end, emu.callbackType.exec, 0x0000, 0xFFFF)

emu.addMemoryCallback(function(addr, value)
  local s = (addr - 0x8000) >> 13
  if not prgIsRom[s] then return end
  local o = prg[s] * 0x2000 + (addr & 0x1FFF)
  if s == 2 then
    flags[o] = (flags[o] or 0) | 8
    -- so registra leitor se a instrucao atual usa enderecamento que alcanca ROM (heuristica: guarda mesmo assim, marcado)
  else
    flags[o] = (flags[o] or 0) | 4
  end
  local k = curOpOff * 0x100000 + o
  if not readers[k] then readers[k] = (s == 2) and 2 or 1; nreaders = nreaders + 1 end
end, emu.callbackType.read, 0x8000, 0xFFFF)

emu.addMemoryCallback(function(addr, value)
  ramR[addr] = (ramR[addr] or 0) + 1
  local w = ramWho[addr]; if not w then w = {}; ramWho[addr] = w end
  local k = "r" .. curOpOff
  if not w[k] then w[k] = true end
end, emu.callbackType.read, 0x0000, 0x07FF)

emu.addMemoryCallback(function(addr, value)
  if addr == 0xB0 then modeNow = value & 7 end
  ramW[addr] = (ramW[addr] or 0) + 1
  local w = ramWho[addr]; if not w then w = {}; ramWho[addr] = w end
  local k = "w" .. curOpOff
  if not w[k] then w[k] = true end
end, emu.callbackType.write, 0x0000, 0x07FF)

emu.addMemoryCallback(function(addr, value)
  local t = regvals[addr]; if not t then t = {}; regvals[addr] = t end
  t[value] = (t[value] or 0) + 1
  if addr >= 0x5114 and addr <= 0x5117 then
    local s = addr - 0x5114
    prg[s] = value & 0x3F
    prgIsRom[s] = (s == 3) or (value & 0x80) ~= 0
  end
end, emu.callbackType.write, 0x5100, 0x5206)

-- amostras DPCM: registra (banco em $C000, endereco, tamanho, taxa) a cada disparo do canal DMC
local dmcreg = {[0x4010]=0, [0x4011]=0, [0x4012]=0, [0x4013]=0}
local dmcplays = {}
emu.addMemoryCallback(function(addr, value)
  if addr == 0x4015 then
    if (value & 0x10) ~= 0 then
      local k = string.format("%02X %04X %04X %02X %07X", prg[2], 0xC000 + dmcreg[0x4012] * 64, dmcreg[0x4013] * 16 + 1, dmcreg[0x4010], curOpOff)
      dmcplays[k] = (dmcplays[k] or 0) + 1
    end
  else
    dmcreg[addr] = value
  end
end, emu.callbackType.write, 0x4010, 0x4015)

-- resumo do som: um hash de todas as escritas na APU, fechado a cada 60 quadros (para comparar dois ROMs "de ouvido")
local apuH, apuLog = 0, {}
emu.addMemoryCallback(function(addr, value)
  apuH = (apuH * 31 + addr * 257 + value) % 4294967296
end, emu.callbackType.write, 0x4000, 0x4017)

------------------------------------------------------------------ entrada
local rng = SEED * 2654435761 % 4294967296
local function rnd(n) rng = (rng * 1103515245 + 12345) % 2147483648; return (rng >> 8) % n end
local RAMDUMP = os.getenv("SF2_RAMDUMP") == "1"
local ramf = RAMDUMP and io.open(OUT .. "/ram_frames.bin", "wb") or nil
local inpf = RAMDUMP and io.open(OUT .. "/input_frames.txt", "w") or nil
local cur = {{}, {}}        -- botoes atuais p1/p2
local queue = {{}, {}}      -- fila de passos {botoes, duracao}
local function push(p, b, d) table.insert(queue[p], {b, d}) end

local function gen(p)       -- gera a proxima "acao" aleatoria para o jogador p
  local r = rnd(100)
  local fwd, back = "right", "left"
  if rnd(2) == 0 then fwd, back = "left", "right" end
  local btn = (rnd(2) == 0) and "a" or "b"
  if r < 12 then          -- hadouken: baixo, baixo+frente, frente + botao
    push(p, {down=true}, 2 + rnd(3)); push(p, {down=true, [fwd]=true}, 2 + rnd(3)); push(p, {[fwd]=true, [btn]=true}, 2 + rnd(4)); push(p, {}, 1 + rnd(10))
  elseif r < 22 then      -- shoryuken: frente, baixo, baixo+frente + botao
    push(p, {[fwd]=true}, 2 + rnd(3)); push(p, {down=true}, 2 + rnd(3)); push(p, {down=true, [fwd]=true, [btn]=true}, 2 + rnd(4)); push(p, {}, 1 + rnd(10))
  elseif r < 32 then      -- tatsumaki: baixo, baixo+tras, tras + botao
    push(p, {down=true}, 2 + rnd(3)); push(p, {down=true, [back]=true}, 2 + rnd(3)); push(p, {[back]=true, [btn]=true}, 2 + rnd(4)); push(p, {}, 1 + rnd(10))
  elseif r < 44 then push(p, {[fwd]=true}, 5 + rnd(40))                         -- anda
  elseif r < 50 then push(p, {[back]=true}, 5 + rnd(40))                        -- recua / defende
  elseif r < 56 then push(p, {down=true}, 5 + rnd(30))                          -- agacha
  elseif r < 60 then push(p, {down=true, [back]=true}, 5 + rnd(30))             -- defesa baixa
  elseif r < 66 then push(p, {up=true}, 2 + rnd(4)); push(p, {}, rnd(12)); push(p, {[btn]=true}, 2 + rnd(3))            -- pulo + golpe
  elseif r < 72 then push(p, {up=true, [fwd]=true}, 2 + rnd(4)); push(p, {}, rnd(14)); push(p, {[btn]=true}, 2 + rnd(3))
  elseif r < 76 then push(p, {up=true, [back]=true}, 2 + rnd(4)); push(p, {}, rnd(14)); push(p, {[btn]=true}, 2 + rnd(3))
  elseif r < 84 then push(p, {[btn]=true}, 1 + rnd(4)); push(p, {}, 1 + rnd(6))                                        -- golpe em pe
  elseif r < 90 then push(p, {down=true, [btn]=true}, 2 + rnd(4)); push(p, {}, 1 + rnd(6))                             -- golpe agachado
  elseif r < 93 then push(p, {[fwd]=true, [btn]=true}, 2 + rnd(6)); push(p, {}, 1 + rnd(6))                            -- arremesso / frente+golpe
  elseif r < 95 then push(p, {a=true, b=true}, 1 + rnd(4)); push(p, {}, 1 + rnd(6))
  elseif r < 96 then push(p, {select=true}, 1 + rnd(3)); push(p, {}, 1 + rnd(6))
  else push(p, {}, 5 + rnd(40)) end
end

-- planos: funcao(frame) que decide o que cada jogador faz
local plans = {}
local function menu_start(p, f, every) return (f % every) < 3 end
plans.idle = function(f)        -- so entra na luta e fica parado (CPU vence)
  local b = {}
  if f > 1250 and (f % 240) < 3 then b.start = true end
  if f > 1250 and (f % 240) >= 120 and (f % 240) < 123 then b.a = true end
  if f > 2200 and f < 2100 + 3600 then b = {} end
  return b, nil
end
plans.p1random = function(f)    -- P1 aleatorio contra a CPU
  if f < 1250 then return {}, nil end
  if f < 2150 then
    local b = {}
    if (f % 150) < 3 then b.start = true elseif (f % 150) >= 75 and (f % 150) < 78 then b.a = true end
    return b, nil
  end
  if #queue[1] == 0 then gen(1) end
  local step = queue[1][1]; step[2] = step[2] - 1
  local b = {}; for k, v in pairs(step[1]) do b[k] = v end
  if step[2] <= 0 then table.remove(queue[1], 1) end
  if (f % 1500) < 2 then b.start = true end          -- pausa/confirma telas de vez em quando
  if (f % 1500) >= 30 and (f % 1500) < 32 then b.start = true end
  return b, nil
end
plans.p2join = function(f)      -- P2 aperta START e os dois jogam aleatoriamente
  if f < 1250 then return {}, nil end
  if f < 2150 then
    local b = {}
    if (f % 150) < 3 then b.start = true elseif (f % 150) >= 75 and (f % 150) < 78 then b.a = true end
    return b, nil
  end
  local res = {}
  for p = 1, 2 do
    if #queue[p] == 0 then gen(p) end
    local step = queue[p][1]; step[2] = step[2] - 1
    local b = {}; for k, v in pairs(step[1]) do b[k] = v end
    if step[2] <= 0 then table.remove(queue[p], 1) end
    res[p] = b
  end
  if f >= 2400 and f < 2404 then res[2] = {start=true} end
  if f >= 2700 and (f % 600) < 3 then res[2].start = true; res[2].a = (f % 1200) < 3 end
  if (f % 1500) >= 700 and (f % 1500) < 702 then res[1].start = true end
  if (f % 1500) >= 730 and (f % 1500) < 732 then res[1].start = true end
  return res[1], res[2]
end
plans.attract = function(f) return {}, nil end   -- nao toca em nada (telas de abertura)

local plan = plans[PLAN] or plans.p1random
local pokes = {}
for fr, ad, va in string.gmatch(POKES, "(%d+):(%x+):(%x+)") do
  local t = pokes[tonumber(fr)]; if not t then t = {}; pokes[tonumber(fr)] = t end
  table.insert(t, {tonumber(ad, 16), tonumber(va, 16)})
end

local holds = {}
for ad, va, f1, f2 in string.gmatch(HOLDS, "(%x+):(%x+):(%d+):(%d+)") do
  table.insert(holds, {tonumber(ad, 16), tonumber(va, 16), tonumber(f1), tonumber(f2)})
end
-- linha do tempo: registra toda mudanca em algumas variaveis de estado (modo de tela, round, vitorias, relogio)
local WATCH = {0xB0, 0xB8, 0x10, 0x11, 0xB2, 0x12, 0x13, 0x00, 0x01}
local watchLast = {}
local timeline = {}

emu.addEventCallback(function()
  local b1, b2 = plan(frame)
  if b1 then emu.setInput(b1, 0) end
  if b2 then emu.setInput(b2, 1) end
end, emu.eventType.inputPolled)

------------------------------------------------------------------ saida
local function dump()
  local f = io.open(OUT .. "/cdl.bin", "wb")
  local chunk = {}
  for o = 0, 0x7FFFF do
    chunk[#chunk + 1] = string.char(flags[o] or 0)
    if #chunk == 8192 then f:write(table.concat(chunk)); chunk = {} end
  end
  f:write(table.concat(chunk)); f:close()
  f = io.open(OUT .. "/edges.txt", "w")
  for k, n in pairs(edges) do f:write(k, " ", n, "\n") end
  f:close()
  f = io.open(OUT .. "/readers.txt", "w")
  for k, v in pairs(readers) do f:write(string.format("%07X %05X %d\n", k // 0x100000, k % 0x100000, v)) end
  f:close()
  f = io.open(OUT .. "/ram.txt", "w")
  for a = 0, 0x7FF do
    if ramR[a] or ramW[a] then
      local who = {}
      for k, _ in pairs(ramWho[a] or {}) do who[#who + 1] = string.format("%s%07X", k:sub(1, 1), tonumber(k:sub(2))) end
      table.sort(who)
      f:write(string.format("%04X r=%d w=%d %s\n", a, ramR[a] or 0, ramW[a] or 0, table.concat(who, ",")))
    end
  end
  f:close()
  f = io.open(OUT .. "/dmc.txt", "w")
  for k, n in pairs(dmcplays) do f:write(k, " ", n, "\n") end
  f:close()
  f = io.open(OUT .. "/first.txt", "w")
  for o, fr in pairs(firstF) do f:write(string.format("%07X %d %d %d %02X\n", o, fr, lastF[o], countF[o], modeMask[o])) end
  f:close()
  f = io.open(OUT .. "/apu.txt", "w")
  for _, l in ipairs(apuLog) do f:write(l, "\n") end
  f:close()
  f = io.open(OUT .. "/timeline.txt", "w")
  for _, l in ipairs(timeline) do f:write(l, "\n") end
  f:close()
  f = io.open(OUT .. "/chr.txt", "w")
  for reg = 0x5100, 0x5206 do
    local t = regvals[reg]
    if t then
      local vs = {}
      for v, n in pairs(t) do vs[#vs + 1] = string.format("%02X:%d", v, n) end
      table.sort(vs)
      f:write(string.format("%04X %s\n", reg, table.concat(vs, " ")))
    end
  end
  f:close()
end

emu.addEventCallback(function()
  frame = frame + 1
  local pk = pokes[frame]
  if pk then for _, p in ipairs(pk) do emu.write(p[1], p[2], emu.memType.nesMemory) end end
  for _, h in ipairs(holds) do
    if frame >= h[3] and frame <= h[4] then emu.write(h[1], h[2], emu.memType.nesMemory) end
  end
  if frame % 60 == 0 then apuLog[#apuLog + 1] = string.format("%d %08X", frame, apuH) end
  for _, a in ipairs(WATCH) do
    local v = emu.read(a, emu.memType.nesInternalRam)
    if v ~= watchLast[a] then
      timeline[#timeline + 1] = string.format("%d %02X %02X", frame, a, v); watchLast[a] = v
    end
  end
  if ramf then
    local t = {}
    for a = 0, 0x7FF do t[#t + 1] = string.char(emu.read(a, emu.memType.nesInternalRam)) end
    ramf:write(table.concat(t))
  end
  if SHOT > 0 and frame % SHOT == 0 then
    local f = io.open(string.format("%s/shots/f%06d.png", OUT, frame), "wb")
    f:write(emu.takeScreenshot()); f:close()
  end
  if frame >= FRAMES then
    if ramf then ramf:close() end
    dump()
    emu.stop(0)
  end
end, emu.eventType.endFrame)
