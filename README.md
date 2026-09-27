# Tappy Plane

A small endless flyer made with [Doriax Engine](https://github.com/doriaxengine/doriax).

Keep the plane in the air, fly through the gaps between the rocks and beat your best score.

[Play in the browser](https://doriaxengine.github.io/tappyplane/) or open the folder in Doriax Editor
and press **Play**.

## Controls

| Input | Action |
| --- | --- |
| Space / Up, click or tap | Flap |

Hitting a rock, the ground or the top of the screen ends the run. Flap again to retry.

## Project

- `Main Scene`: background, ground, rocks, plane and sounds. The `Game` entity has the
  `GameController.lua` script, with the tuning values and the entities it uses set in its properties.
- `HUD Scene`: score and messages, a child scene of `Main Scene`.
- `scripts/GameController.lua`: the game logic.

The best score is saved with `UserSettings`.

## Credits

Art, font and sounds are CC0 assets by [Kenney](https://kenney.nl): Tappy Plane, Digital Audio,
Music Jingles and Kenney Fonts. Their licenses are in `assets/licenses/`.

`assets/sprites/plane-sheet.png` has the three `planeBlue` frames from Tappy Plane side by side.
