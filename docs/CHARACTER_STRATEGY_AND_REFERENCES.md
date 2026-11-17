# Character strategy and public references for Street Fighter II

## Planning decision

Ken's implementation is the first recommended mold: the NES ROM already contains about 4.3 KB of Ken frames, although it does not have his states connected. The proposal is to reuse the engine and common Ryu data, organize Ken's states/tables, connect the fiche and validate sprites, moves and collisions. Ryu's AI can serve as a starting point.

After Ken, there is not enough base in the currently identified content to declare any single remaining character as objectively easier: for them, the ROM essentially contains portraits, and fight frames, states and collisions need to be produced/integrated. Choosing the next one should depend on available art resources and the mechanic to be tested. Guile could be a good test for charge moves; Sagat, for projectile pattern reuse. These are choices to test capabilities, not a statement that they are the easiest overall.

Suggested incremental approach, not yet started:

1. Use Ken as pilot case and register which Ryu parts are generic and which are specific.
2. Extract a reusable representation for states, frames, collisions, moves and metasprite references, keeping the common engine separate from each fighter's data.
3. Implement one fighter at a time, starting with the minimum set to play and test; add specific moves later.
4. Keep regression tests so content changes do not alter already validated Ryu behavior.

## Why consult source code from other SFII projects

The purpose of the original search was to find public works of the same game that could serve as reference for implementing characters in the NES project — not specifically looking for N64 or Neo Geo CD ports.

These projects can help understand and compare game rules, moves, states, collisions, differences between versions and organization of a fighter. They are reference on the same game/series; they are not a directly portable base: CPS1/CPS2 use other processors, data formats, hardware and resource scales. The NES project is its own demo, table-driven and running on 6502/MMC5. Integration must follow the architecture already discovered in this project and be validated in the NES emulator.

### Repositories found

- [Xalcker/SF2Recomp](https://github.com/Xalcker/SF2Recomp): public tools and runtime for static recompilation of arcade CPS1 *The World Warrior* (World 910522). Converted 68000 code is generated locally from the ROM and is not published in the repository. Useful as methodology source, analysis organization and behavior reference; not as 6502 character code to transplant. Equivalence and coverage claims are those of the maintainers.
- [bentorkington/sf2ww](https://github.com/bentorkington/sf2ww): C99 + OpenGL rewrite/clone of *World Warrior*, declared as original work, incomplete and dependent on ROM files for graphics. It is a closer candidate for consulting high-level game logic; its snippets should be treated as separate reference, not automatically copied to the NES project.
- [focusright/sf2](https://github.com/focusright/sf2): another CPS1/68000 to C recompilation; additional candidate, with status and completeness to verify before trusting details.
- [omegakatana92/Street-Fighter-2-The-World-Warrior-Recomp](https://github.com/omegakatana92/Street-Fighter-2-The-World-Warrior-Recomp): planning/audit, no playable port per consulted description; may be useful for documentation, but is not a ready character implementation.
- *Super Street Fighter II* and *Hyper Street Fighter II* CPS2 projects are related games/versions, not the same build. Use them only as comparative reference, leaving version differences explicit.

## Clean room principles

The idea is viable as an independent development method: observe relevant SFII behavior and our own ROM data; write a functional specification in our own language (e.g., move sequence, state transitions and collision boxes); implement that specification in 6502 and in NES project data formats; and validate the result with reproducible tests. Recording the origin of each requirement helps distinguish observations from the NES project, compared behavior in other versions and implementation decisions.

To maintain rigorous separation, specifications used for implementation should describe behaviors and requirements, without copying code, translated tables, comments or derived data from consulted repositories. Consulting third-party code can influence understanding of the problem; therefore, if a formal clean room process claim is desired, a real separation between who researches/writes specifications and who implements is stronger than simply calling a same-person flow "clean room". This note records an engineering guideline, not a legal conclusion.

No character implementation, ROM change or third-party code copy was made when creating this note.
