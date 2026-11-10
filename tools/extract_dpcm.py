#!/usr/bin/env python3
"""Extrai as vozes (amostras DPCM) do ROM para WAV.

O diretorio de amostras fica no banco $37:
  $E000 + i        banco de PRG (8K) que contem a amostra i  (mapeado em $C000-$DFFF via $5116)
  $E020 + 3*i      descritor no formato do FamiTone2: endereco/64, (tamanho-1)/16, taxa ($4010)
A tabela $E0F9 (16 bytes por personagem) diz que amostras cada voz do lutador usa: pares (primeira, continuacao).

uso: extract_dpcm.py [rom] [dir_saida]
"""
import sys, os, wave, struct
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

# O que cada amostra e', deduzido do CODIGO que a dispara (ver docs/ARQUITETURA.md, secao Som):
USO = {
    0: 'locutor: "ROUND"  (RoundIntroStep)',
    1: 'locutor: numero do round 1', 2: 'locutor: numero do round 2', 3: 'locutor: numero do round 3',
    5: 'locutor: "FIGHT"',
    6: 'locutor: "YOU"  (fim do round)', 7: 'locutor: "WIN"  (vencedor humano)',
    8: 'locutor: "LOSE" (vencedor CPU)', 9: 'locutor: "PERFECT" (venceu com energia cheia)',
    # paises: CountryVoiceTbl ($37:E0EF) diz qual voz cada personagem usa na selecao; o nome do pais e' deducao
    10: 'pais de RYU e EHONDA   (deve ser "JAPAN")', 11: 'pais de BLANKA         (deve ser "BRAZIL")',
    12: 'pais de KEN, GUILE e BALROG (deve ser "U.S.A.")', 13: 'pais de CHUN LI        (deve ser "CHINA")',
    14: 'pais de ZANGIEF        (deve ser "U.S.S.R.")', 15: 'pais de SAGAT e M.BISON (deve ser "THAILAND")',
    16: 'tela de titulo: START', 17: 'selecao: mover cursor', 18: 'selecao: confirmar',
    24: 'Ryu: voz 0 (FighterVoiceTbl)', 27: 'Ryu: vozes 1 e 2',
    28: 'Ryu: vozes 3 e 4, 1a parte', 29: 'Ryu: vozes 3 e 4, 2a parte',
    30: 'Ryu: vozes 5 e 6, 1a parte', 31: 'Ryu: vozes 5 e 6, 2a parte',
}

RATES = [4181.71, 4709.93, 5264.04, 5593.04, 6257.95, 7046.35, 7919.35, 8363.42,
         9419.86, 11186.1, 12604.0, 13982.6, 16884.6, 21306.8, 24858.0, 33143.9]
N = 32

def decode(data):
    level = 32; out = bytearray()
    for byte in data:
        for bit in range(8):
            if (byte >> bit) & 1:
                if level <= 125: level += 2
            else:
                if level >= 2: level -= 2
            out.append(level * 2)
    return bytes(out)

def directory(rom):
    prg = rom[16:16 + 0x80000]
    b37 = prg[0x37 * 0x2000:0x38 * 0x2000]
    res = []
    for i in range(N):
        bank = b37[i]; start, ln, rate = b37[0x20 + 3 * i:0x23 + 3 * i]
        addr = 0xC000 + start * 64; size = ln * 16 + 1
        res.append(dict(i=i, bank=bank, addr=addr, size=size, rate=rate, empty=(ln == 0)))
    return prg, res

def main():
    here = os.path.dirname(os.path.abspath(__file__))
    romp = sys.argv[1] if len(sys.argv) > 1 else os.path.join(here, '..', 'rom', 'sf2ne_demo.nes')
    outd = sys.argv[2] if len(sys.argv) > 2 else os.path.join(here, '..', 'extracted', 'dpcm')
    os.makedirs(outd, exist_ok=True)
    prg, d = directory(open(romp, 'rb').read())
    played = {}
    tp = os.path.join(here, '..', 'trace', 'dmc.txt')
    if os.path.exists(tp):
        for l in open(tp):
            p = l.split()
            if len(p) >= 5 and not l.startswith('#'): played[(int(p[0], 16), int(p[1], 16))] = int(p[4])
    lines = ['# i  banco  endereco  bytes  taxa  duracao(s)  tocada_no_trace  arquivo                    uso (deduzido do codigo)']
    for e in d:
        if e['empty']:
            lines.append('%2d  --     (entrada vazia)' % e['i']); continue
        off = e['bank'] * 0x2000 + (e['addr'] - 0xC000)
        data = prg[off:off + e['size']]
        hz = RATES[e['rate'] & 15]
        name = 'voz_%02d_banco%02X_%04X.wav' % (e['i'], e['bank'], e['addr'])
        w = wave.open(os.path.join(outd, name), 'wb')
        w.setnchannels(1); w.setsampwidth(1); w.setframerate(int(round(hz))); w.writeframes(decode(data)); w.close()
        lines.append('%2d  $%02X    $%04X     %5d  $%02X   %.2f        %-5s  %-26s %s' % (
            e['i'], e['bank'], e['addr'], e['size'], e['rate'], e['size'] * 8 / hz,
            ('sim' if (e['bank'], e['addr']) in played else 'nao'), name, USO.get(e['i'], '?')))
    open(os.path.join(outd, 'INDICE.txt'), 'w').write('\n'.join(lines) + '\n')
    print('\n'.join(lines))

if __name__ == '__main__':
    main()
