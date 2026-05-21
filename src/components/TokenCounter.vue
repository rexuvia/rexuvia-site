<script setup>
import { ref, onMounted, onUnmounted } from 'vue'

const emit = defineEmits(['contribute'])

const BASELINE_MS = Date.UTC(2026, 4, 10, 0, 0, 0)
const BASELINE_TOKENS = 120_500_000
const TOKENS_PER_DAY = 900_000
const MS_PER_DAY = 86_400_000

const formatter = new Intl.NumberFormat('en-US')

const displayTokens = ref(computeTokens(Date.now()))

function computeTokens(nowMs) {
  const elapsed = nowMs - BASELINE_MS
  if (elapsed <= 0) return BASELINE_TOKENS
  return Math.floor(BASELINE_TOKENS + (elapsed * TOKENS_PER_DAY) / MS_PER_DAY)
}

let rafId = null
let lastValue = displayTokens.value

function tick() {
  const next = computeTokens(Date.now())
  if (next !== lastValue) {
    lastValue = next
    displayTokens.value = next
  }
  rafId = requestAnimationFrame(tick)
}

onMounted(() => {
  rafId = requestAnimationFrame(tick)
})

onUnmounted(() => {
  if (rafId !== null) cancelAnimationFrame(rafId)
})
</script>

<template>
  <section class="token-counter-section">
    <div class="token-card">
      <div class="token-info">
        <p class="token-label">Estimated LLM API tokens used</p>
        <p
          class="token-number"
          :aria-label="`Approximately ${formatter.format(displayTokens)} LLM API tokens used so far`"
          aria-live="off"
        >
          {{ formatter.format(displayTokens) }}
        </p>
      </div>
      <button
        type="button"
        class="contribute-btn"
        @click="emit('contribute')"
      >
        <span class="contribute-icon" aria-hidden="true">◈</span>
        Help cover compute costs
      </button>
    </div>
  </section>
</template>

<style scoped>
.token-counter-section {
  padding: 4px 0 8px;
}

@media (min-width: 600px) {
  .token-counter-section {
    padding: 8px 0 12px;
  }
}

.token-card {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16px;
  padding: 12px 16px;
  border: 1px solid rgba(255, 255, 255, 0.05);
  border-radius: 8px;
  background: rgba(255, 255, 255, 0.02);
  transition: border-color 0.3s ease, background 0.3s ease;
}

.token-card:hover {
  border-color: rgba(0, 240, 255, 0.15);
  background: rgba(255, 255, 255, 0.03);
}

.token-info {
  display: flex;
  flex-direction: column;
  gap: 4px;
  min-width: 0;
}

.token-label {
  font-size: 0.72rem;
  font-weight: 500;
  letter-spacing: 0.04em;
  text-transform: uppercase;
  color: #888;
  margin: 0;
}

.token-number {
  font-family: 'Orbitron', sans-serif;
  font-weight: 700;
  font-size: clamp(1.2rem, 3vw, 1.5rem);
  color: rgba(0, 240, 255, 0.8);
  text-shadow: 0 0 12px rgba(0, 240, 255, 0.15);
  margin: 0;
  letter-spacing: 0.04em;
  font-variant-numeric: tabular-nums;
  line-height: 1.05;
}

.contribute-btn {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  padding: 10px 18px;
  background: rgba(0, 240, 255, 0.12);
  color: #00f0ff;
  border: 1px solid rgba(0, 240, 255, 0.35);
  border-radius: 8px;
  font-family: 'Inter', sans-serif;
  font-weight: 500;
  font-size: 0.85rem;
  cursor: pointer;
  transition: background 0.25s ease, border-color 0.25s ease, transform 0.15s ease, box-shadow 0.25s ease;
  white-space: nowrap;
  flex-shrink: 0;
}

.contribute-btn:hover {
  background: rgba(0, 240, 255, 0.2);
  border-color: rgba(0, 240, 255, 0.6);
  box-shadow: 0 0 24px rgba(0, 240, 255, 0.2);
  transform: translateY(-1px);
}

.contribute-btn:active {
  transform: translateY(0);
}

.contribute-btn:focus-visible {
  outline: 2px solid rgba(0, 240, 255, 0.7);
  outline-offset: 2px;
}

.contribute-icon {
  font-size: 1rem;
  line-height: 1;
}

@media (max-width: 600px) {
  .token-card {
    flex-direction: column;
    align-items: stretch;
    gap: 12px;
    padding: 14px 16px;
  }

  .token-info {
    align-items: flex-start;
  }

  .contribute-btn {
    justify-content: center;
    width: 100%;
    padding: 11px 16px;
  }
}
</style>
