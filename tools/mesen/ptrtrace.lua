-- ptrtrace.lua — descobre PONTEIROS por rastreamento de origem ("taint") no Mesen 2 (modo --testrunner).
--
-- Para cada valor em A/X/Y e em cada byte da RAM guarda de qual byte do ROM ele veio (operando imediato ou dado lido).
-- Quando o jogo le o ROM atraves de um ponteiro (zp),y — ou retorna com RTS para um endereco empilhado a mao —
-- sabemos que os dois bytes de origem formam um ponteiro, e para onde ele aponta. Isso permite trocar numeros crus
-- (lda #$8C / ldx #$F9 ; .byte $CE,$85 ...) por expressoes simbolicas (#<Rotulo / #>Rotulo ; .word Rotulo),
-- que e' o que torna o fonte REALOCAVEL (da para inserir/remover codigo sem quebrar o jogo).
--
-- Saida: <OUT>/ptr.txt   linhas "P|R|Y  origem_lo  origem_hi  contagem  end_min  end_max  bancos"
--        (P = via (zp),y ; R = destino de RTS ; Y = byte baixo vindo do registrador Y, com o ponteiro apontando p/ a pagina)
-- Parametros (variaveis de ambiente): os mesmos do cdl.lua (SF2_OUT, SF2_PLAN, SF2_FRAMES, SF2_SEED, SF2_HOLD, SF2_POKES).
local OUT    = os.getenv("SF2_OUT") or "/tmp/sf2trace/ptr"
local PLAN   = os.getenv("SF2_PLAN") or "p1random"
local FRAMES = tonumber(os.getenv("SF2_FRAMES") or "7200")
local SEED   = tonumber(os.getenv("SF2_SEED") or "1")
local SHOT   = tonumber(os.getenv("SF2_SHOT_EVERY") or "0")
local HOLDS  = os.getenv("SF2_HOLD") or ""
local POKES  = os.getenv("SF2_POKES") or ""
os.execute('mkdir -p "' .. OUT .. '/shots"')
local frame = 0

local LEN, CLS = {}, {}
do
  local l1 = {0x00,0x08,0x0A,0x18,0x28,0x2A,0x38,0x40,0x48,0x4A,0x58,0x60,0x68,0x6A,0x78,0x88,0x8A,0x98,0x9A,0xA8,0xAA,0xB8,0xBA,0xC8,0xCA,0xD8,0xE8,0xEA,0xF8}
  local l3 = {0x0D,0x0E,0x19,0x1D,0x1E,0x20,0x2C,0x2D,0x2E,0x39,0x3D,0x3E,0x4C,0x4D,0x4E,0x59,0x5D,0x5E,0x6C,0x6D,0x6E,0x79,0x7D,0x7E,0x8C,0x8D,0x8E,0x99,0x9D,0xAC,0xAD,0xAE,0xB9,0xBC,0xBD,0xBE,0xCC,0xCD,0xCE,0xD9,0xDD,0xDE,0xEC,0xED,0xEE,0xF9,0xFD,0xFE}
  for i = 0, 255 do LEN[i] = 2; CLS[i] = 0 end
  for _, o in ipairs(l1) do LEN[o] = 1 end
  for _, o in ipairs(l3) do LEN[o] = 3 end
  local function set(c, t) for _, o in ipairs(t) do CLS[o] = c end end
  set(1, {0xA9}); set(2, {0xA2}); set(3, {0xA0})                              -- LDA/LDX/LDY #imm
  set(4, {0xA5,0xB5,0xAD,0xBD,0xB9}); set(5, {0xA6,0xB6,0xAE,0xBE}); set(6, {0xA4,0xB4,0xAC,0xBC})  -- carga da memoria
  set(7, {0xB1})                                                              -- LDA (zp),y
  set(8, {0x71,0xF1,0xD1})                                                    -- ADC/SBC/CMP (zp),y
  set(29, {0x31,0x11,0x51})                                                   -- AND/ORA/EOR (zp),y
  set(10, {0x85,0x95,0x8D,0x9D,0x99,0x81,0x91}); set(11, {0x86,0x96,0x8E}); set(12, {0x84,0x94,0x8C})  -- STA/STX/STY
  set(13, {0xAA}); set(14, {0xA8}); set(15, {0x8A}); set(16, {0x98})         -- TAX TAY TXA TYA
  set(17, {0x48}); set(18, {0x68}); set(27, {0x08,0x00})                      -- PHA PLA PHP/BRK
  set(28, {0x69}); set(19, {0x65,0x75,0x6D,0x7D,0x79})                        -- ADC #imm ; ADC mem
  set(20, {0x29,0x25,0x35,0x2D,0x3D,0x39,0x21, 0x09,0x05,0x15,0x0D,0x1D,0x19,0x01, 0x49,0x45,0x55,0x4D,0x5D,0x59,0x41,
           0x0A,0x4A,0x2A,0x6A, 0xA1})                                        -- operacoes que destroem a origem de A
  set(21, {0xE8,0xCA,0xBA,0xCB}); set(22, {0xC8,0x88})                        -- INX/DEX/TSX/AXS ; INY/DEY
  set(23, {0x20}); set(24, {0x60}); set(26, {0x6C})                           -- JSR RTS JMP()
  set(25, {0x06,0x16,0x0E,0x1E,0x46,0x56,0x4E,0x5E,0x26,0x36,0x2E,0x3E,0x66,0x76,0x6E,0x7E,0xE6,0xF6,0xEE,0xFE,0xC6,0xD6,0xCE,0xDE})
end

local prg = {[0]=0x3F, [1]=0x3F, [2]=0x3F, [3]=0x3F}
local function off(addr) return prg[(addr - 0x8000) >> 13] * 0x2000 + (addr & 0x1FFF) end
emu.addMemoryCallback(function(addr, value) prg[addr - 0x5114] = value & 0x3F end, emu.callbackType.write, 0x5114, 0x5117)

local Ao, Xo, Yo = 0, 0, 0          -- origem (offset no PRG + 1; 0 = desconhecida) do valor em cada registrador
local memO = {}                     -- idem para cada byte da RAM
local cls, opAddr, nextPC, nread, nwrite = 0, -1, -1, 0, 0
local pLo, pHi, rLo, rHi = 0, 0, 0, 0
local Az = false                    -- A foi carregado com #$00 (ex.: lda #0 / adc PonteiroHi): a origem util e' a do operando
local pend = 0                      -- endereco da ultima leitura de ROM via ponteiro nesta instrucao (0 = nenhuma)
local evP, evR, evY = {}, {}, {}
local pendY = 0
local function record(tbl, lo, hi, addr)
  local t = tbl[lo]; if not t then t = {}; tbl[lo] = t end
  local e = t[hi]; if not e then e = {0, addr, addr, {}}; t[hi] = e end
  e[1] = e[1] + 1
  if addr < e[2] then e[2] = addr end
  if addr > e[3] then e[3] = addr end
  local b = prg[(addr - 0x8000) >> 13]; e[4][b] = true
end

emu.addMemoryCallback(function(addr, value)
  if cls == 24 and rLo ~= 0 and rHi ~= 0 and rLo ~= rHi and addr >= 0x8000 then record(evR, rLo, rHi, addr) end
  if pend ~= 0 then
    record(evP, pLo, pHi, pend)
    -- idioma "ponteiro = pagina (byte baixo 0) + Y": o byte baixo de verdade esta em Y
    if pendY ~= 0 and pendY ~= pHi then record(evY, pendY, pHi, pend) end
    pend = 0
  end    -- so a ULTIMA leitura conta (descarta a leitura "fantasma" de cruzamento de pagina)
  cls = CLS[value]; opAddr = addr; nextPC = addr + LEN[value]; nread = 0; nwrite = 0
  if cls == 0 then return end
  if cls == 4 or cls == 7 or cls == 15 or cls == 16 or cls == 18 or cls == 20 or cls == 29 then Az = false end
  if cls == 1 then
    Ao = (addr >= 0x8000 and addr < 0xFFFF) and off(addr + 1) + 1 or 0
    Az = (emu.read(addr + 1, emu.memType.nesMemory) == 0)
  elseif cls == 2 then Xo = (addr >= 0x8000 and addr < 0xFFFF) and off(addr + 1) + 1 or 0
  elseif cls == 3 then Yo = (addr >= 0x8000 and addr < 0xFFFF) and off(addr + 1) + 1 or 0
  elseif cls == 13 then Xo = Ao elseif cls == 14 then Yo = Ao
  elseif cls == 15 then Ao = Xo elseif cls == 16 then Ao = Yo
  elseif cls == 20 or cls == 29 then Ao = 0
  elseif cls == 21 then Xo = 0 elseif cls == 22 then Yo = 0
  elseif cls == 28 then
    if (Ao == 0 or Az) and addr >= 0x8000 and addr < 0xFFFF then Ao = off(addr + 1) + 1 end
    Az = false
  elseif cls == 24 then rLo = 0; rHi = 0
  elseif cls == 7 or cls == 8 then pLo = 0; pHi = 0
  end
  if cls == 29 then pLo = 0; pHi = 0 end
end, emu.callbackType.exec, 0x0000, 0xFFFF)

emu.addMemoryCallback(function(addr, value)          -- leituras da RAM
  if addr == opAddr + 1 or addr == opAddr + 2 then return end      -- operandos de codigo rodando na RAM (trampolim)
  if cls == 4 then Ao = memO[addr] or 0
  elseif cls == 5 then Xo = memO[addr] or 0
  elseif cls == 6 then Yo = memO[addr] or 0
  elseif cls == 7 or cls == 8 or cls == 29 then
    nread = nread + 1
    if nread == 1 then pLo = memO[addr] or 0
    elseif nread == 2 then pHi = memO[addr] or 0
    elseif cls == 7 then Ao = memO[addr] or 0 end
  elseif cls == 18 then Ao = memO[addr] or 0
  elseif cls == 19 then if Ao == 0 or Az then Ao = memO[addr] or 0; Az = false end
  elseif cls == 24 then rLo = rHi; rHi = memO[addr] or 0
  end
end, emu.callbackType.read, 0x0000, 0x07FF)

emu.addMemoryCallback(function(addr, value)          -- leituras do ROM
  if addr == opAddr + 1 then
    if cls == 1 then Az = (value == 0) end
    return
  end
  -- addr == opAddr: releitura "fantasma" do opcode quando o DMA do canal DMC rouba um ciclo
  if addr == opAddr or addr == opAddr + 2 or addr == nextPC or addr >= 0xFFFA then return end
  -- o canal DMC busca amostras na janela $C000 no meio de qualquer instrucao: nao sao leituras do programa
  if addr >= 0xC000 and addr < 0xE000 and prg[2] ~= 0x36 then return end
  if cls == 4 then Ao = off(addr) + 1
  elseif cls == 5 then Xo = off(addr) + 1
  elseif cls == 6 then Yo = off(addr) + 1
  elseif cls == 7 then
    if pLo ~= 0 and pHi ~= 0 and pLo ~= pHi then pend = addr; pendY = Yo end
    Ao = off(addr) + 1
  elseif cls == 8 or cls == 29 then
    if pLo ~= 0 and pHi ~= 0 and pLo ~= pHi then pend = addr; pendY = Yo end
  elseif cls == 19 then if Ao == 0 or Az then Ao = off(addr) + 1; Az = false end
  end
end, emu.callbackType.read, 0x8000, 0xFFFF)

emu.addMemoryCallback(function(addr, value)          -- escritas na RAM
  nwrite = nwrite + 1
  if nwrite == 1 then
    if cls == 10 or cls == 17 then memO[addr] = Ao
    elseif cls == 11 then memO[addr] = Xo
    elseif cls == 12 then memO[addr] = Yo
    elseif cls ~= 25 then memO[addr] = 0 end
  elseif cls ~= 25 or nwrite > 2 then memO[addr] = 0 end
end, emu.callbackType.write, 0x0000, 0x07FF)

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


local function dump()
  local f = io.open(OUT .. "/ptr.txt", "w")
  for kind, tbl in pairs({P = evP, R = evR, Y = evY}) do
    for lo, t in pairs(tbl) do
      for hi, e in pairs(t) do
        local bs = {}
        for b, _ in pairs(e[4]) do bs[#bs + 1] = string.format("%02X", b) end
        table.sort(bs)
        f:write(string.format("%s %07X %07X %d %04X %04X %s\n", kind, lo - 1, hi - 1, e[1], e[2], e[3], table.concat(bs, ",")))
      end
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
  if SHOT > 0 and frame % SHOT == 0 then
    local f = io.open(string.format("%s/shots/f%06d.png", OUT, frame), "wb")
    f:write(emu.takeScreenshot()); f:close()
  end
  if frame >= FRAMES then dump(); emu.stop(0) end
end, emu.eventType.endFrame)
