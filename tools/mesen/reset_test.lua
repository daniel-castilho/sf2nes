-- reset_test.lua — reproduz o "trava no soft reset": aperta RESET no frame SF2_RESET_AT e observa se o jogo reinicia.
-- Saida em SF2_OUT: reset.txt (banco em $E000 na hora do reset, PC/estado depois) e antes.png / depois.png
local OUT = os.getenv("SF2_OUT") or "/tmp/sf2trace/reset"
local AT  = tonumber(os.getenv("SF2_RESET_AT") or "2500")
local WAIT = tonumber(os.getenv("SF2_RESET_WAIT") or "700")
os.execute('mkdir -p "' .. OUT .. '"')
local frame, e000 = 0, 0x3F
local log = io.open(OUT .. "/reset.txt", "w")
emu.addMemoryCallback(function(addr, value) e000 = value & 0x3F end, emu.callbackType.write, 0x5117, 0x5117)
emu.addEventCallback(function()
  local b = {}
  if frame > 1250 and frame < 2150 then
    if (frame % 150) < 3 then b.start = true elseif (frame % 150) >= 75 and (frame % 150) < 78 then b.a = true end
  end
  emu.setInput(b, 0)
end, emu.eventType.inputPolled)
local function shot(name)
  local f = io.open(OUT .. "/" .. name, "wb"); f:write(emu.takeScreenshot()); f:close()
end
local b1 = {}
emu.addEventCallback(function()
  frame = frame + 1
  if frame == AT then
    shot("antes.png")
    log:write(string.format("reset no frame %d; banco em $E000 = $%02X; modo($B0) = %d\n", frame, e000, emu.read(0xB0, emu.memType.nesInternalRam)))
    emu.reset()
  end
  if frame > AT and frame <= AT + WAIT and (frame - AT) % 100 == 0 then
    local st = emu.getState()
    b1[#b1 + 1] = emu.read(0xB1, emu.memType.nesInternalRam)
    log:write(string.format("  +%d frames: PC=$%04X  $B0=%d  $B1=%d  banco $E000=$%02X\n", frame - AT, st["cpu.pc"] or -1,
      emu.read(0xB0, emu.memType.nesInternalRam), emu.read(0xB1, emu.memType.nesInternalRam), e000))
  end
  if frame == AT + WAIT then
    shot("depois.png")
    local moving = false
    for i = 2, #b1 do if b1[i] ~= b1[1] then moving = true end end
    log:write(moving and "RESULTADO: o jogo continua rodando apos o reset\n" or "RESULTADO: TRAVOU (contador de frames $B1 parado)\n")
    log:close()
    emu.stop(0)
  end
end, emu.eventType.endFrame)
