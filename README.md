# Tappy Plane

An endless flyer built with the [Doriax Engine](https://github.com/doriaxengine/doriax). Tap, click, or press space to keep the plane in the air, thread the rock gaps, and beat your best score.

[Play in the browser](https://doriaxengine.github.io/tappyplane/) or open the project in Doriax Editor and press **Play**. Desktop builds are published as GitHub Actions artifacts on every push.

## How to play

- **Space**, **Up**, **click**, or **tap** to flap
- Pass through the gaps to score
- Hitting a rock, the ground, or the ceiling ends the run
- Flap again after game over to restart

## How it is built

Every game object is a real entity, so it shows up in the Structure panel and can be selected and edited:

| Entity | Scene | What it is |
| --- | --- | --- |
| `Game` | Main Scene | Empty entity holding `scripts/GameController.lua` |
| `Background`, `Ground` | Main Scene | Two scrolling tiles each, recycled as they leave the screen |
| `Rocks` | Main Scene | Four rock pairs, resized and repositioned per gap |
| `Plane` | Main Scene | Sprite sheet with three frames, driven by `Plane Animation` |
| `Flap Sound`, `Score Sound`, `Hit Sound`, `Game Over Sound` | Main Scene | Sound sources for flap, score, hit, and game over |
| `Score`, `Get Ready`, `Game Over`, `Tap Hint`, `Best Score`, `Hint` | HUD Scene | UI overlay, a start-active child of Main Scene |

The plane's propeller uses a `SpriteAnimation` action targeting the plane sprite, so the frames come from `framesRect` on a single texture instead of swapping textures each frame.

`GameController.lua` talks to world sprites, the HUD, and sound sources through entity-reference properties on the **Game** entity (the same pattern IcePee uses for `Score Scene`). Flap strength, gravity, scroll speed, gap size, and pipe spacing are also exposed there.

## Assets

All third-party files in this project are **CC0** (public domain) from [Kenney](https://kenney.nl). Attribution is not required; it is included here for credit.

Copies of each pack's license are in `assets/licenses/`.

| Files in this project | Pack | License | Source |
| --- | --- | --- | --- |
| `assets/sprites/*`, `assets/ui/*` | Tappy Plane | [CC0 1.0](https://creativecommons.org/publicdomain/zero/1.0/) | https://kenney.nl/assets/tappy-plane |
| `assets/audio/flap.ogg` (`phaseJump1.ogg`) | Digital Audio | [CC0 1.0](https://creativecommons.org/publicdomain/zero/1.0/) | https://kenney.nl/assets/digital-audio |
| `assets/audio/score.ogg` (`twoTone1.ogg`) | Digital Audio | [CC0 1.0](https://creativecommons.org/publicdomain/zero/1.0/) | https://kenney.nl/assets/digital-audio |
| `assets/audio/hit.ogg` (`zap1.ogg`) | Digital Audio | [CC0 1.0](https://creativecommons.org/publicdomain/zero/1.0/) | https://kenney.nl/assets/digital-audio |
| `assets/audio/game-over.ogg` (`jingles_HIT07.ogg`) | Music Jingles | [CC0 1.0](https://creativecommons.org/publicdomain/zero/1.0/) | https://kenney.nl/assets/music-jingles |
| `assets/fonts/KenneyFutureNarrow.ttf` | Kenney Fonts | [CC0 1.0](https://creativecommons.org/publicdomain/zero/1.0/) | https://kenney.nl/assets/kenney-fonts |

`assets/sprites/plane-sheet.png` is the only modified file: it stacks Tappy Plane's `planeBlue1/2/3.png` (88×73 each) side by side into one 264×73 sheet so the three frames can be driven by a single `SpriteAnimation`.

Tappy Plane is also mirrored on OpenGameArt: https://opengameart.org/content/tappy-plane
