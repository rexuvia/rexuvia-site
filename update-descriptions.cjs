const fs = require('fs');

const path = 'public/game_list.json';
const data = JSON.parse(fs.readFileSync(path, 'utf8'));

const descriptions = {
  'glitch-loom': 'Weave pixel-sorted and datamoshed strands into glitch art tapestries with custom patterns and animation exports.',
  'memory-palace-builder': '3D interactive spatial memory system using WASD navigation. Place custom objects and practice your recall.',
  'prime-spiral': 'Explore the mysterious patterns of prime numbers through an interactive spiral visualization.',
  'flock-mind': 'Emergent boids flocking simulation with attract/repel interactions and spatial grid optimization.',
  'branching-narrative-web': 'Navigate complex interactive stories through an interconnected web of branching narrative paths.',
  'sideways-tetris': 'A mind-bending twist on the classic puzzle game where pieces fall horizontally instead of vertically.',
  'wave-collapse-weaver': 'Procedural generation tool using the Wave Function Collapse algorithm to create infinite, repeating patterns.',
  '2026-02-23-neural-knot-untangler': '3D graph puzzle game. Untangle complex neural knots to clear crossings across varying difficulty levels.',
  '2026-02-22-cell-symphony': 'Interactive cellular automaton that generates dynamic musical soundscapes as life evolves on the grid.',
  'lava-flow': 'Mesmerizing fluid dynamics and particle simulation exploring the hypnotic movement of digital lava.',
  'mirror-maze': 'Navigate a tricky labyrinth of reflecting surfaces. Use logic and spatial reasoning to find the exit.',
  '2026-02-18-signal-scope': 'Real-time audio analyzer featuring 8 notation formats, pitch history, and visual waveform feedback.',
  '2026-02-17-sort-cinema': 'Educational visualization of 15 different sorting algorithms in action, complete with interactive explanations.',
  '2026-02-16-neon-synth-pad': 'Expressive, neon-infused synthesizer pad for creating rich electronic soundscapes in your browser.',
  '2026-02-16-pendulum-waves': 'Hypnotic physics simulation demonstrating the mathematical beauty of uncoupled pendulum waves.'
};

let updated = 0;
data.forEach(game => {
  if (!game.description) {
    let key = game.id;
    if (!key && game.url) {
      key = game.url.split('/').pop().replace('.html', '');
    }
    
    if (key && descriptions[key]) {
      game.description = descriptions[key];
      updated++;
    } else {
      console.log(`No description found for: ${game.title} (key: ${key})`);
    }
  }
});

fs.writeFileSync(path, JSON.stringify(data, null, 2));
console.log(`Updated ${updated} descriptions.`);
