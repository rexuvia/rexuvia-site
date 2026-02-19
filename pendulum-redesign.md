# Pendulum Waves → "PENDULUM GATE" Redesign Plan

## Critique of Current Version

The current app is a **screensaver**, not a game. Problems:
- **No objective** — pendulums swing, you watch
- **No challenge** — clicking does nothing meaningful
- **No scoring** — no feedback on performance
- **No progression** — nothing changes over time
- **No reason to return** — seen once, seen forever
- The controls (angle, count, speed, color mode) are sandbox knobs with no purpose

The physics and neon aesthetic are solid. The pendulum wave pattern is inherently mesmerizing. We need to weaponize that hypnotic quality into gameplay.

---

## Game Concept: "PENDULUM GATE"

**Genre:** Timing/precision launch game  
**Core loop:** Pendulums swing back and forth creating moving obstacles. Player must tap to launch a particle upward through the gaps between swinging bobs at the right moment. Score points for each pendulum layer successfully passed.

Think of it as **Flappy Bird meets pendulum physics** — except instead of continuous flight, each round is a single carefully-timed shot through a gauntlet of swinging pendulums.

---

## Core Mechanics

### The Setup
- Pendulums are arranged in **horizontal rows** (not the current vertical column layout)
- Each row has 2-5 pendulums swinging at different frequencies
- Rows are stacked vertically, creating layers the particle must pass through
- The player's **launch pad** is at the bottom of the screen

### The Action
1. Player sees the pendulums swinging in their wave pattern
2. Player **taps** to launch a glowing particle **upward**
3. The particle travels upward at a fixed speed through the pendulum rows
4. If the particle hits a pendulum bob → **game over** (or life lost)
5. If it passes through all rows → **score!**

### Why Pendulum Physics Matter
- The pendulums swing in a wave pattern — gaps open and close in complex, shifting rhythms
- Players must **read the wave** and predict when a clear vertical channel will align
- Different pendulum frequencies mean the pattern never exactly repeats — each shot is a new timing puzzle
- As levels progress, frequencies get closer together, making wave patterns harder to read

---

## Scoring System

| Event | Points |
|---|---|
| Pass through one pendulum row | +100 × row number (higher rows = more points) |
| Clear all rows (full pass) | +500 bonus |
| "Threading the needle" (pass within 10px of a bob) | +50 bonus per near-miss |
| Perfect level (all 3 shots clear) | ×2 multiplier on level score |
| Consecutive clears (combo) | +100 × combo count |

**Score display:** Top-right, neon green, Orbitron font. High score persisted in localStorage.

---

## Level Progression

### Level Structure
Each level gives the player **3 lives** (3 particles to launch). Must clear at least 1 to advance.

| Level | Rows | Pendulums/Row | Frequency Spread | Particle Speed | Special |
|---|---|---|---|---|---|
| 1 | 2 | 2 | Wide (easy gaps) | Slow | Tutorial hints |
| 2 | 2 | 3 | Wide | Slow | — |
| 3 | 3 | 3 | Medium | Slow | — |
| 4 | 3 | 3 | Medium | Medium | — |
| 5 | 3 | 4 | Medium | Medium | — |
| 6 | 4 | 3 | Narrow | Medium | Bobs pulse (size changes) |
| 7 | 4 | 4 | Narrow | Medium | — |
| 8 | 4 | 4 | Narrow | Fast | — |
| 9 | 5 | 4 | Very narrow | Fast | Some bobs are invisible (ghost) |
| 10 | 5 | 5 | Very narrow | Fast | Boss: wave pattern reverses mid-flight |

After level 10: **Endless mode** — rows keep adding, speed increases every 3 clears.

### Frequency Spread Explained
- **Wide:** Pendulums in a row have very different frequencies → large, predictable gaps
- **Medium:** Closer frequencies → gaps open/close faster, wave pattern is more complex
- **Narrow:** Nearly synchronized → gaps are brief and travel across the row
- **Very narrow:** Almost in sync → requires reading the subtle wave ripple

---

## UI Layout

```
┌─────────────────────────────────┐
│ ← Back          SCORE: 12,400  │  ← Header bar
│              HI: 28,000        │
│                                 │
│   ○   ○   ○                    │  ← Lives (particle icons)
│                                 │
│  ──●──────●──────●──           │  ← Row 4 (pendulums swinging)
│                                 │
│  ────●──────●────●──           │  ← Row 3
│                                 │
│  ──●────●──────●────           │  ← Row 2
│                                 │
│  ────●────●──────●──           │  ← Row 1
│                                 │
│              ↑                  │
│           [LAUNCH]              │  ← Launch zone (tap anywhere below row 1)
│                                 │
│    Level 3     Combo: x4       │  ← Status bar
└─────────────────────────────────┘
```

- **Pendulums:** Rendered as before — neon-colored bobs on strings, hanging from horizontal pivot bars
- **Particle:** Bright white/cyan glowing orb with comet trail going upward
- **Launch zone:** Bottom 20% of screen. Tap anywhere in this zone to fire.
- **Background:** Dark (#0a0a0f) with subtle grid lines for depth

---

## Control Scheme

| Input | Action |
|---|---|
| Tap (bottom zone) | Launch particle upward from center |
| Tap (during flight) | No effect (committed once launched) |
| Swipe left/right before launch | Aim launch angle (±15° from vertical) — **unlocked at level 4** |
| Tap after death/score | Next shot or next level |

**Mobile-first:** Single tap is the only required input. Aiming is optional and only adds a strategic layer later.

---

## Visual & Audio Feedback

### Visuals
- **Launch:** Burst of particles at launch pad, screen shake micro-pulse
- **Near miss:** Bob briefly flashes white, sparks fly, "+50" floats up
- **Hit (death):** Particle explodes into fragments matching bob color, bobs all flash red, brief screen flash
- **Clear row:** Row's pivot bar lights up green, stays lit
- **Full clear:** All pendulums freeze momentarily, rainbow pulse radiates from top, "+500" with glow
- **Combo:** Combo counter pulses bigger with each increment, trail behind particle gets longer/brighter
- **Level complete:** Pendulums spell out "CLEAR" by aligning (cosmetic animation)
- **Game over:** Pendulums slow to stop, score tallies up digit by digit

### Audio (Web Audio API — generated, no assets needed)
- **Launch:** Rising synth whoosh
- **Bob passing:** Quick ascending chime (pitch increases with row number)
- **Near miss:** Metallic "ting!" 
- **Hit:** Low thud + shatter sound
- **Full clear:** Major chord arpeggio
- **Combo increase:** Pitch of chimes rises with combo
- **Background:** Subtle ambient drone that intensifies with level (optional, toggle-able)

---

## Game States & Flow

```
TITLE SCREEN → TAP TO START → LEVEL INTRO (shows level #, row preview)
    → PLAYING (pendulums swing, player times shots)
    → [HIT] → lose life → PLAYING (if lives remain)
    → [CLEAR] → score tally → PLAYING (next shot or next level)
    → [ALL LIVES LOST] → GAME OVER (final score, high score check)
    → TAP → TITLE SCREEN
```

### Title Screen
- "PENDULUM GATE" in Orbitron, neon cyan
- Pendulums swinging in background (decorative, using original sim)
- "TAP TO START" pulsing
- High score displayed
- Small "SANDBOX" button → opens original free-play mode (preserves the current toy)

---

## Technical Implementation Notes

### Pendulum Layout Change
- Current: Pendulums hang side-by-side in a single row
- New: Multiple horizontal rows, each with its own set of pendulums
- Each row has a pivot bar at a fixed Y position
- Pendulums within a row are spaced evenly along the bar
- String length is VISUAL only (cosmetic) — actual swing determined by frequency parameter

### Collision Detection
- Simple circle-circle: particle (radius ~6px) vs bob (radius ~8px)
- Check every frame during particle flight
- Hit radius can be slightly smaller than visual radius (forgiving hitbox, ~80%)

### Pendulum Data Structure
```javascript
level = {
  rows: [
    { y: 0.2, pendulums: [{ freq: 1.2, phase: 0 }, { freq: 1.5, phase: 0.3 }, ...] },
    { y: 0.4, pendulums: [...] },
    ...
  ],
  particleSpeed: 300, // px/sec upward
  stringLength: 80,   // visual only
  bobRadius: 8
}
```

### State Management
- `gameState`: 'title' | 'intro' | 'playing' | 'flying' | 'dead' | 'cleared' | 'gameover'
- `currentLevel`, `lives`, `score`, `combo`, `highScore`
- Particle: `{ x, y, vx, vy, alive }`

### Persistence
- `localStorage.setItem('pendulumgate_highscore', score)`
- Optionally store highest level reached

### Performance
- Keep trail rendering efficient (limit trail points to 30)
- Max ~25 pendulums on screen at once (5 rows × 5) — well within canvas perf budget
- Use `requestAnimationFrame` as current implementation does

---

## Replayability Hooks

1. **High score chasing** — always visible, localStorage persisted
2. **Combo system** — risk/reward of shooting fast vs waiting for safe gaps
3. **Near-miss bonus** — incentivizes daring play
4. **Endless mode** after level 10 — how far can you go?
5. **Level patterns are deterministic but phase-shifted** — pendulums start at random phases each attempt, so memorization doesn't work perfectly
6. **Sandbox mode** — players who just want to play with pendulums can still do that (preserves original appeal)

---

## Summary

Transform a passive pendulum wave visualization into **PENDULUM GATE**: a timing-based precision game where players launch particles through layers of swinging pendulums. The hypnotic wave patterns become the obstacle course. Simple tap controls, escalating difficulty across 10 levels + endless mode, combo scoring for replayability, and all wrapped in the existing neon Rexuvia aesthetic.

**Estimated implementation:** Single HTML file, ~400-600 lines. No external assets. Canvas + Web Audio API. Mobile-first.
