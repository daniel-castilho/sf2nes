# Estratégia para personagens e referências públicas de Street Fighter II

## Decisão de planejamento

A implementação de Ken é o primeiro molde recomendado: o ROM NES já contém cerca de 4,3 KB de frames do Ken, embora não tenha os estados dele ligados. A proposta é reaproveitar o motor e os dados comuns do Ryu, organizar os estados/tabelas do Ken, conectar a ficha e validar sprites, golpes e colisões. A IA do Ryu pode servir como ponto de partida.

Depois de Ken, não há base suficiente no conteúdo atualmente identificado para declarar um único personagem restante como objetivamente mais fácil: para eles, o ROM contém essencialmente retratos, e os frames, estados e colisões de luta precisam ser produzidos/integrados. Escolher o seguinte deve depender dos recursos de arte disponíveis e da mecânica que se queira testar. Guile pode ser um bom teste para golpes de carga; Sagat, para reutilização do padrão de projéteis. São escolhas para testar capacidades, não uma afirmação de que sejam os mais fáceis em termos totais.

Abordagem incremental sugerida, ainda não iniciada:
1. Usar Ken como caso-piloto e registrar quais partes do Ryu são genéricas e quais são específicas.
2. Extrair uma representação reutilizável para estados, quadros, colisões, golpes e referências a metasprites, mantendo o motor comum separado dos dados de cada lutador.
3. Implementar um lutador por vez, começando pelo conjunto mínimo para jogar e testar; acrescentar movimentos específicos depois.
4. Manter testes de regressão para que mudanças de conteúdo não alterem o comportamento já validado do Ryu.

## Por que consultar código-fonte de outros projetos de SFII

A finalidade da busca original era encontrar trabalhos públicos do mesmo jogo que servissem de referência para implementar personagens no projeto NES — não procurar especificamente código para ports de N64 ou Neo Geo CD.

Esses projetos podem ajudar a entender e comparar regras de jogo, movimentos, estados, colisões, diferenças entre versões e organização de um lutador. São referência sobre o mesmo jogo/série; não são uma base diretamente portável: CPS1/CPS2 usam outros processadores, formatos de dados, hardware e escalas de recursos. O projeto NES é um demo próprio, dirigido por tabelas e executado em 6502/MMC5. A integração deve seguir a arquitetura já descoberta nesse projeto e ser validada no emulador NES.

### Repositórios encontrados

- [Xalcker/SF2Recomp](https://github.com/Xalcker/SF2Recomp): ferramentas e runtime públicos para recompilação estática da versão arcade CPS1 *The World Warrior* (World 910522). O código 68000 convertido é gerado localmente a partir da ROM e não é publicado no repositório. Útil como fonte de metodologia, organização de análise e referência de comportamento; não como código de personagens 6502 a transplantar. As alegações de equivalência e cobertura são as dos mantenedores.
- [bentorkington/sf2ww](https://github.com/bentorkington/sf2ww): reescrita/clone C99 + OpenGL de *World Warrior*, declarada como trabalho original, incompleto e dependente dos arquivos de ROM para gráficos. É um candidato mais próximo para consultar lógica de jogo implementada em alto nível; seus trechos devem ser tratados como referência separada, não copiados automaticamente para o projeto NES.
- [focusright/sf2](https://github.com/focusright/sf2): outra recompilação CPS1/68000 para C; candidato adicional, com status e completude a conferir antes de confiar em detalhes.
- [omegakatana92/Street-Fighter-2-The-World-Warrior-Recomp](https://github.com/omegakatana92/Street-Fighter-2-The-World-Warrior-Recomp): planejamento/auditoria, sem port jogável conforme a descrição consultada; pode ser útil para documentação, mas não é uma implementação pronta de personagens.
- Projetos de *Super Street Fighter II* e *Hyper Street Fighter II* em CPS2 são jogos/versões aparentados, não o mesmo build. Usá-los só como referência comparativa, deixando explícitas as diferenças de versão.

## Uso de princípios de sala limpa

A ideia é viável como método de desenvolvimento independente: observar o comportamento relevante de SFII e os dados do nosso próprio ROM; escrever uma especificação funcional em linguagem própria (por exemplo, sequência de golpes, transições de estado e caixas de colisão); implementar essa especificação em 6502 e nos formatos de dados do projeto NES; e validar o resultado com testes reproduzíveis. Registrar a origem de cada requisito ajuda a distinguir observações do projeto NES, comportamento comparado em outras versões e decisões de implementação.

Para manter uma separação rigorosa, as especificações usadas para implementar devem descrever comportamentos e requisitos, sem copiar código, tabelas traduzidas, comentários ou dados derivados dos repositórios consultados. A consulta a código de terceiros pode influenciar a compreensão do problema; portanto, se for desejada uma alegação formal de processo de sala limpa, uma separação real entre quem pesquisa/escreve especificações e quem implementa é mais forte do que simplesmente chamar de “clean room” um fluxo feito pela mesma pessoa. Esta nota registra uma orientação de engenharia, não uma conclusão jurídica.

Nenhuma implementação de personagem, alteração de ROM ou cópia de código de terceiros foi feita ao criar esta nota.
