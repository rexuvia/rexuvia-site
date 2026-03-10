const fs = require('fs');

let content = fs.readFileSync('src/App.vue', 'utf8');

// Replace the onMounted body completely
content = content.replace(/onMounted\(async \(\) => \{[\s\S]*?\}\)/, `onMounted(async () => {
  // Load game list
  try {
    const res = await fetch('/game_list.json')
    if (res.ok) {
      const list = await res.json();
      games.value = list.sort((a, b) => {
        try {
          const dtA = a.last_updated || a.date || '1970-01-01';
          const dtB = b.last_updated || b.date || '1970-01-01';
          return new Date(dtB).getTime() - new Date(dtA).getTime();
        } catch (e) {
          return 0;
        }
      });
    }
  } catch (e) {
    console.warn('Could not load game list:', e)
  }
})`);

fs.writeFileSync('src/App.vue', content);
