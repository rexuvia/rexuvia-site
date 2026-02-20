<script setup>
import { ref } from 'vue'

const reactionClass = ref('')
const cooldown = ref(false)
const showBubble = ref(false)

const reactions = [
  'react-bounce',
  'react-wiggle',
  'react-rainbow',
  'react-squish',
  'react-peek',
]

function handleClick() {
  if (cooldown.value) return
  cooldown.value = true

  // Pick a random character reaction
  const pick = reactions[Math.floor(Math.random() * reactions.length)]
  reactionClass.value = pick

  // Show speech bubble
  showBubble.value = true

  setTimeout(() => {
    reactionClass.value = ''
    showBubble.value = false
    cooldown.value = false
  }, 2500)
}
</script>

<template>
  <div class="logo-banner">
    <!-- Lobster + speech bubble wrapper -->
    <div class="mascot-wrapper">
      <!-- Speech bubble -->
      <div v-if="showBubble" class="speech-bubble">
        Sorry but I'm closed source for now
      </div>

      <!-- Lobster SVG (click target) -->
      <svg class="lobster-svg" :class="reactionClass" @click="handleClick" role="button" tabindex="0" aria-label="Rexuvia mascot — click for a surprise" viewBox="0 0 260 220" xmlns="http://www.w3.org/2000/svg">
      <defs>
        <!-- Body gradient -->
        <radialGradient id="bodyGrad" cx="50%" cy="40%" r="55%">
          <stop offset="0%" stop-color="#ff9a8b" />
          <stop offset="70%" stop-color="#e87461" />
          <stop offset="100%" stop-color="#c4523e" />
        </radialGradient>
        <!-- Claw gradient -->
        <radialGradient id="clawGrad" cx="40%" cy="35%" r="60%">
          <stop offset="0%" stop-color="#f28b7a" />
          <stop offset="100%" stop-color="#c4523e" />
        </radialGradient>
        <!-- Eye white gradient -->
        <radialGradient id="eyeWhite" cx="45%" cy="40%" r="50%">
          <stop offset="0%" stop-color="#ffffff" />
          <stop offset="100%" stop-color="#e8e8ee" />
        </radialGradient>
        <!-- Cheek blush -->
        <radialGradient id="blush" cx="50%" cy="50%" r="50%">
          <stop offset="0%" stop-color="rgba(255,140,140,0.45)" />
          <stop offset="100%" stop-color="rgba(255,140,140,0)" />
        </radialGradient>
      </defs>

      <!-- ===== Antennae (behind body) ===== -->
      <g class="antenna-group">
        <g class="antenna antenna-left" transform-origin="108 60">
          <path d="M108 68 Q95 30 78 12" stroke="#d45a47" stroke-width="3.5" fill="none" stroke-linecap="round" />
          <circle cx="78" cy="12" r="5" fill="#e87461" />
          <circle cx="78" cy="12" r="3" fill="#ff9a8b" />
        </g>
        <g class="antenna antenna-right" transform-origin="152 60">
          <path d="M152 68 Q165 30 182 12" stroke="#d45a47" stroke-width="3.5" fill="none" stroke-linecap="round" />
          <circle cx="182" cy="12" r="5" fill="#e87461" />
          <circle cx="182" cy="12" r="3" fill="#ff9a8b" />
        </g>
      </g>

      <!-- ===== Legs (behind body) ===== -->
      <g class="legs" opacity="0.9">
        <!-- Left legs (4 pairs, jointed) -->
        <path d="M108 150 L88 166 L78 178" stroke="#d45a47" stroke-width="3" fill="none" stroke-linecap="round" stroke-linejoin="round" />
        <path d="M105 140 L82 152 L70 164" stroke="#d45a47" stroke-width="3" fill="none" stroke-linecap="round" stroke-linejoin="round" />
        <path d="M102 130 L78 138 L64 150" stroke="#d45a47" stroke-width="3" fill="none" stroke-linecap="round" stroke-linejoin="round" />
        <path d="M100 120 L76 124 L62 134" stroke="#d45a47" stroke-width="2.8" fill="none" stroke-linecap="round" stroke-linejoin="round" />
        <!-- Right legs (4 pairs, jointed) -->
        <path d="M152 150 L172 166 L182 178" stroke="#d45a47" stroke-width="3" fill="none" stroke-linecap="round" stroke-linejoin="round" />
        <path d="M155 140 L178 152 L190 164" stroke="#d45a47" stroke-width="3" fill="none" stroke-linecap="round" stroke-linejoin="round" />
        <path d="M158 130 L182 138 L196 150" stroke="#d45a47" stroke-width="3" fill="none" stroke-linecap="round" stroke-linejoin="round" />
        <path d="M160 120 L184 124 L198 134" stroke="#d45a47" stroke-width="2.8" fill="none" stroke-linecap="round" stroke-linejoin="round" />
        <!-- Tiny foot nubs -->
        <circle cx="78" cy="178" r="2.5" fill="#c4523e" />
        <circle cx="70" cy="164" r="2.5" fill="#c4523e" />
        <circle cx="64" cy="150" r="2.5" fill="#c4523e" />
        <circle cx="62" cy="134" r="2.5" fill="#c4523e" />
        <circle cx="182" cy="178" r="2.5" fill="#c4523e" />
        <circle cx="190" cy="164" r="2.5" fill="#c4523e" />
        <circle cx="196" cy="150" r="2.5" fill="#c4523e" />
        <circle cx="198" cy="134" r="2.5" fill="#c4523e" />
      </g>

      <!-- ===== Claw Arms ===== -->
      <!-- Left arm + claw -->
      <g class="claw claw-left">
        <path d="M100 100 Q72 88 52 72" stroke="#d45a47" stroke-width="6" fill="none" stroke-linecap="round" />
        <!-- Claw pincer -->
        <g transform="translate(52,72)">
          <ellipse class="claw-top" cx="-8" cy="-10" rx="18" ry="12" fill="url(#clawGrad)" stroke="#c4523e" stroke-width="1.5" transform="rotate(-25)" />
          <ellipse class="claw-bottom" cx="-6" cy="4" rx="16" ry="10" fill="url(#clawGrad)" stroke="#c4523e" stroke-width="1.5" transform="rotate(10)" />
          <ellipse cx="-2" cy="-2" rx="5" ry="4" fill="#ff9a8b" opacity="0.5" />
        </g>
      </g>
      <!-- Right arm + claw -->
      <g class="claw claw-right">
        <path d="M160 100 Q188 88 208 72" stroke="#d45a47" stroke-width="6" fill="none" stroke-linecap="round" />
        <g transform="translate(208,72)">
          <ellipse class="claw-top" cx="8" cy="-10" rx="18" ry="12" fill="url(#clawGrad)" stroke="#c4523e" stroke-width="1.5" transform="rotate(25)" />
          <ellipse class="claw-bottom" cx="6" cy="4" rx="16" ry="10" fill="url(#clawGrad)" stroke="#c4523e" stroke-width="1.5" transform="rotate(-10)" />
          <ellipse cx="2" cy="-2" rx="5" ry="4" fill="#ff9a8b" opacity="0.5" />
        </g>
      </g>

      <!-- ===== Main Body ===== -->
      <ellipse cx="130" cy="115" rx="52" ry="56" fill="url(#bodyGrad)" stroke="#c4523e" stroke-width="2" />
      <!-- Body highlight -->
      <ellipse cx="122" cy="98" rx="28" ry="22" fill="rgba(255,255,255,0.1)" />
      <!-- Belly spot -->
      <ellipse cx="130" cy="135" rx="26" ry="18" fill="rgba(255,200,180,0.15)" />

      <!-- ===== Face ===== -->
      <!-- Left eye -->
      <g class="eye eye-left">
        <ellipse cx="114" cy="98" rx="16" ry="17" fill="url(#eyeWhite)" stroke="#ccc" stroke-width="0.8" />
        <!-- Iris -->
        <circle cx="116" cy="100" r="9" fill="#2a2a4a" />
        <!-- Pupil -->
        <circle cx="117" cy="99" r="5" fill="#111128" />
        <!-- Eye shine -->
        <circle class="eye-shine" cx="119" cy="95" r="3.5" fill="white" opacity="0.9" />
        <circle cx="113" cy="102" r="1.5" fill="white" opacity="0.4" />
        <!-- Eyelashes (fanning from outer-top edge of left eye) -->
        <g class="lashes" stroke="#3a3a3a" stroke-width="1.8" stroke-linecap="round" fill="none">
          <path d="M99 91 L93 84" />
          <path d="M100 87 L95 79" />
          <path d="M103 84 L99 75" />
          <path d="M107 83 L105 74" />
        </g>
        <!-- Eyelid (for blink) -->
        <ellipse class="eyelid" cx="114" cy="98" rx="16.5" ry="0" fill="#e87461" />
      </g>

      <!-- Right eye -->
      <g class="eye eye-right">
        <ellipse cx="146" cy="98" rx="16" ry="17" fill="url(#eyeWhite)" stroke="#ccc" stroke-width="0.8" />
        <circle cx="148" cy="100" r="9" fill="#2a2a4a" />
        <circle cx="149" cy="99" r="5" fill="#111128" />
        <circle class="eye-shine" cx="151" cy="95" r="3.5" fill="white" opacity="0.9" />
        <circle cx="145" cy="102" r="1.5" fill="white" opacity="0.4" />
        <!-- Eyelashes (fanning from outer-top edge of right eye) -->
        <g class="lashes" stroke="#3a3a3a" stroke-width="1.8" stroke-linecap="round" fill="none">
          <path d="M153 83 L155 74" />
          <path d="M157 84 L161 75" />
          <path d="M160 87 L165 79" />
          <path d="M161 91 L167 84" />
        </g>
        <ellipse class="eyelid" cx="146" cy="98" rx="16.5" ry="0" fill="#e87461" />
      </g>

      <!-- Cheek blush -->
      <circle cx="98" cy="114" r="10" fill="url(#blush)" />
      <circle cx="162" cy="114" r="10" fill="url(#blush)" />

      <!-- Mouth — cute smile -->
      <path d="M120 122 Q130 132 140 122" stroke="#8b3a2e" stroke-width="2.2" fill="none" stroke-linecap="round" />
      <!-- Tiny fang on the left -->
      <path d="M122 122 L121 126" stroke="#fff" stroke-width="1.4" stroke-linecap="round" opacity="0.6" />
    </svg>
    </div>

    <!-- Title text -->
    <svg class="title-svg" viewBox="0 0 320 60" xmlns="http://www.w3.org/2000/svg">
      <defs>
        <linearGradient id="metalGrad" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stop-color="#e0f0ff" />
          <stop offset="35%" stop-color="#b0d4f1" />
          <stop offset="50%" stop-color="#ffffff" />
          <stop offset="65%" stop-color="#8bbce0" />
          <stop offset="100%" stop-color="#5a8aad" />
        </linearGradient>
        <linearGradient id="metalStroke" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stop-color="#7ab8dd" />
          <stop offset="100%" stop-color="#3a6a8a" />
        </linearGradient>
      </defs>
      <text
        x="150" y="45"
        text-anchor="middle"
        font-family="'Orbitron', sans-serif"
        font-weight="900"
        font-size="55"
        fill="url(#metalGrad)"
        stroke="url(#metalStroke)"
        stroke-width="1.2"
        letter-spacing="6"
      >Rexuvia</text>
    </svg>
  </div>
</template>

<style scoped>
/* ── Banner layout ─────────────────────────────────── */
.logo-banner {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 4px;
}

@media (min-width: 520px) {
  .logo-banner {
    flex-direction: row;
    gap: 12px;
    justify-content: center;
  }
}

.lobster-svg {
  width: 140px;
  height: auto;
  flex-shrink: 0;
  cursor: pointer;
  user-select: none;
  -webkit-tap-highlight-color: transparent;
  outline: none;
  animation: float 3s ease-in-out infinite;
}

.mascot-wrapper {
  position: relative;
  flex-shrink: 0;
  margin-top: 50px; /* Add space for speech bubble on mobile */
}

.title-svg {
  width: 300px; /* Smaller on mobile to prevent cutoff */
  height: auto;
  flex-shrink: 0;
}

@media (min-width: 520px) {
  .lobster-svg {
    width: 180px;
  }
  .title-svg {
    width: 440px;
  }
  .mascot-wrapper {
    margin-top: 0; /* Remove top margin on desktop */
  }
}

/* ── Speech Bubble ─────────────────────────────────── */
.speech-bubble {
  position: absolute;
  bottom: 100%;
  left: 50%;
  transform: translateX(-50%);
  margin-bottom: 6px;
  background: rgba(255, 255, 255, 0.95);
  color: #1a1a2e;
  font-family: 'Inter', system-ui, sans-serif;
  font-size: 0.75rem;
  font-weight: 500;
  line-height: 1.4;
  padding: 8px 14px;
  border-radius: 12px;
  white-space: nowrap;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.3);
  animation: bubble-pop 0.3s ease-out;
  pointer-events: none;
  z-index: 10;
}

.speech-bubble::after {
  content: '';
  position: absolute;
  top: 100%;
  left: 50%;
  transform: translateX(-50%);
  border: 6px solid transparent;
  border-top-color: rgba(255, 255, 255, 0.95);
}

@keyframes bubble-pop {
  0% {
    opacity: 0;
    transform: translateX(-50%) scale(0.6) translateY(8px);
  }
  60% {
    transform: translateX(-50%) scale(1.05) translateY(-2px);
  }
  100% {
    opacity: 1;
    transform: translateX(-50%) scale(1) translateY(0);
  }
}

/* ── Idle: Float / Bob ─────────────────────────────── */
@keyframes float {
  0%, 100% { transform: translateY(0); }
  50%      { transform: translateY(-6px); }
}

/* ── Idle: Blink ───────────────────────────────────── */
.eyelid {
  animation: blink 4s ease-in-out infinite;
}

@keyframes blink {
  0%, 90%, 100% { ry: 0; }
  94%           { ry: 17.5; }
  97%           { ry: 17.5; }
}

/* ── Idle: Antenna Sway ────────────────────────────── */
.antenna-left {
  animation: sway-left 3.5s ease-in-out infinite;
}
.antenna-right {
  animation: sway-right 3.8s ease-in-out infinite;
}

@keyframes sway-left {
  0%, 100% { transform: rotate(0deg); }
  50%      { transform: rotate(-6deg); }
}
@keyframes sway-right {
  0%, 100% { transform: rotate(0deg); }
  50%      { transform: rotate(6deg); }
}

/* ── Idle: Eye Shine Pulse ─────────────────────────── */
.eye-shine {
  animation: shine-pulse 2.5s ease-in-out infinite;
}

@keyframes shine-pulse {
  0%, 100% { opacity: 0.9; }
  50%      { opacity: 0.55; }
}

/* ── Reaction: Bounce ──────────────────────────────── */
.lobster-svg.react-bounce {
  animation: react-bounce 0.7s ease-out;
}
@keyframes react-bounce {
  0%   { transform: translateY(0); }
  20%  { transform: translateY(-30px); }
  40%  { transform: translateY(0); }
  55%  { transform: translateY(-14px); }
  70%  { transform: translateY(0); }
  82%  { transform: translateY(-5px); }
  100% { transform: translateY(0); }
}

/* ── Reaction: Wiggle ──────────────────────────────── */
.lobster-svg.react-wiggle {
  animation: react-wiggle 0.6s ease-in-out;
}
@keyframes react-wiggle {
  0%, 100% { transform: rotate(0deg); }
  15%      { transform: rotate(-12deg); }
  30%      { transform: rotate(10deg); }
  45%      { transform: rotate(-8deg); }
  60%      { transform: rotate(6deg); }
  75%      { transform: rotate(-3deg); }
  90%      { transform: rotate(1deg); }
}

/* ── Reaction: Rainbow ─────────────────────────────── */
.lobster-svg.react-rainbow {
  animation: react-rainbow 1s linear;
}
@keyframes react-rainbow {
  0%   { filter: hue-rotate(0deg); }
  100% { filter: hue-rotate(360deg); }
}

/* ── Reaction: Squish ──────────────────────────────── */
.lobster-svg.react-squish {
  animation: react-squish 0.7s ease-in-out;
}
@keyframes react-squish {
  0%, 100% { transform: scale(1, 1); }
  25%      { transform: scale(1.2, 0.8); }
  50%      { transform: scale(0.85, 1.15); }
  75%      { transform: scale(1.05, 0.95); }
}

/* ── Reaction: Peek (eyes go wide) ─────────────────── */
.lobster-svg.react-peek .eye {
  animation: react-peek-eye 0.8s ease-in-out;
}
.lobster-svg.react-peek .claw-left {
  animation: react-peek-claw-l 0.8s ease-in-out;
}
.lobster-svg.react-peek .claw-right {
  animation: react-peek-claw-r 0.8s ease-in-out;
}
@keyframes react-peek-eye {
  0%, 100% { transform: scale(1); }
  30%      { transform: scale(1.3); }
  70%      { transform: scale(1.3); }
}
@keyframes react-peek-claw-l {
  0%, 100% { transform: rotate(0deg); }
  25%      { transform: rotate(15deg); }
  75%      { transform: rotate(15deg); }
}
@keyframes react-peek-claw-r {
  0%, 100% { transform: rotate(0deg); }
  25%      { transform: rotate(-15deg); }
  75%      { transform: rotate(-15deg); }
}
</style>
