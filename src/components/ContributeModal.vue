<script setup>
import { ref, watch, nextTick, onUnmounted, useTemplateRef } from 'vue'
import QRCode from 'qrcode'

const props = defineProps({
  open: { type: Boolean, default: false },
})

const emit = defineEmits(['close'])

const ZCASH_ADDRESS = 'u1aqs7vmn545y6qm2jata7t2pve5pvtqa2dpydsg3decqklplv9meesu8stf3lcad6s822slengfxq7fjv079a7c90snsm99f8y4mwjkmqhw30gtj74ffamx0e4qrvvxqvf44sj6ms43umre8mxqp9q7q0kkc72a4ax5r67vfj2gcegjsc'
const MONERO_ADDRESS = '8BM7h4VQjtNdq4tSXh1sAEiehYSdSPfRohNXQJ9ohb8cEUwwkszpLyHHGRTsTcqQvVcJBd44Jd2zXXt84EhB7FKR8Y4rsqw'

const ZCASH_QR_ID = 'zcash_qr'
const MONERO_QR_ID = 'monero_qr'

const qrCanvasZcash = useTemplateRef('qrCanvasZcash')
const qrCanvasMonero = useTemplateRef('qrCanvasMonero')
const dialogRef = useTemplateRef('dialogRef')
const copiedZcash = ref(false)
const copiedMonero = ref(false)
const qrReadyZcash = ref(false)
const qrReadyMonero = ref(false)
const qrErrorZcash = ref(null)
const qrErrorMonero = ref(null)

const activeTab = ref('zcash')

let copyResetTimerZcash = null
let copyResetTimerMonero = null
let previousActive = null

async function renderQrZcash() {
  if (!qrCanvasZcash.value) return
  try {
    await QRCode.toCanvas(qrCanvasZcash.value, ZCASH_ADDRESS, {
      errorCorrectionLevel: 'L',
      margin: 1,
      width: 220,
      color: {
        dark: '#0a0f15',
        light: '#ffffff',
      },
    })
    qrReadyZcash.value = true
    qrErrorZcash.value = null
  } catch (err) {
    qrErrorZcash.value = err?.message || 'Failed to render QR code'
    qrReadyZcash.value = false
  }
}

async function renderQrMonero() {
  if (!qrCanvasMonero.value) return
  try {
    await QRCode.toCanvas(qrCanvasMonero.value, MONERO_ADDRESS, {
      errorCorrectionLevel: 'L',
      margin: 1,
      width: 220,
      color: {
        dark: '#0a0f15',
        light: '#ffffff',
      },
    })
    qrReadyMonero.value = true
    qrErrorMonero.value = null
  } catch (err) {
    qrErrorMonero.value = err?.message || 'Failed to render QR code'
    qrReadyMonero.value = false
  }
}

async function renderQrs() {
  await Promise.all([renderQrZcash(), renderQrMonero()])
}

async function copyAddressZcash() {
  try {
    await navigator.clipboard.writeText(ZCASH_ADDRESS)
    copiedZcash.value = true
    if (copyResetTimerZcash) clearTimeout(copyResetTimerZcash)
    copyResetTimerZcash = setTimeout(() => {
      copiedZcash.value = false
    }, 1500)
  } catch {
    const tmp = document.createElement('textarea')
    tmp.value = ZCASH_ADDRESS
    tmp.setAttribute('readonly', '')
    tmp.style.position = 'fixed'
    tmp.style.opacity = '0'
    document.body.appendChild(tmp)
    tmp.select()
    try {
      document.execCommand('copy')
      copiedZcash.value = true
      if (copyResetTimerZcash) clearTimeout(copyResetTimerZcash)
      copyResetTimerZcash = setTimeout(() => {
        copiedZcash.value = false
      }, 1500)
    } catch {
      // ignore
    }
    document.body.removeChild(tmp)
  }
}

async function copyAddressMonero() {
  try {
    await navigator.clipboard.writeText(MONERO_ADDRESS)
    copiedMonero.value = true
    if (copyResetTimerMonero) clearTimeout(copyResetTimerMonero)
    copyResetTimerMonero = setTimeout(() => {
      copiedMonero.value = false
    }, 1500)
  } catch {
    const tmp = document.createElement('textarea')
    tmp.value = MONERO_ADDRESS
    tmp.setAttribute('readonly', '')
    tmp.style.position = 'fixed'
    tmp.style.opacity = '0'
    document.body.appendChild(tmp)
    tmp.select()
    try {
      document.execCommand('copy')
      copiedMonero.value = true
      if (copyResetTimerMonero) clearTimeout(copyResetTimerMonero)
      copyResetTimerMonero = setTimeout(() => {
        copiedMonero.value = false
      }, 1500)
    } catch {
      // ignore
    }
    document.body.removeChild(tmp)
  }
}

function onBackdropClick(event) {
  if (event.target === event.currentTarget) emit('close')
}

function onKeydown(event) {
  if (event.key === 'Escape') emit('close')
}

watch(
  () => props.open,
  async (isOpen) => {
    if (isOpen) {
      previousActive = document.activeElement
      document.body.style.overflow = 'hidden'
      await nextTick()
      await renderQrs()
      dialogRef.value?.focus()
    } else {
      document.body.style.overflow = ''
      copiedZcash.value = false
      copiedMonero.value = false
      qrReadyZcash.value = false
      qrReadyMonero.value = false
      if (previousActive && typeof previousActive.focus === 'function') {
        previousActive.focus()
      }
      previousActive = null
    }
  },
)

onUnmounted(() => {
  document.body.style.overflow = ''
  if (copyResetTimerZcash) clearTimeout(copyResetTimerZcash)
  if (copyResetTimerMonero) clearTimeout(copyResetTimerMonero)
})
</script>

<template>
  <Transition name="modal">
    <div
      v-if="open"
      class="modal-backdrop"
      role="presentation"
      @click="onBackdropClick"
      @keydown="onKeydown"
    >
      <div
        ref="dialogRef"
        class="modal-panel"
        role="dialog"
        aria-modal="true"
        aria-labelledby="contribute-title"
        tabindex="-1"
      >
        <button
          type="button"
          class="modal-close"
          aria-label="Close"
          @click="emit('close')"
        >
          ×
        </button>

        <h2 id="contribute-title" class="modal-title">Help cover compute costs</h2>

        <p class="modal-body">
          The experiments shared on this site cost real money in API tokens.
          If anything here has sparked an idea or made you smile, you can chip
          in via Zcash or Monero. Every contribution goes directly toward more
          experiments.
        </p>

        <div class="tabs">
          <button 
            type="button" 
            class="tab-btn" 
            :class="{ active: activeTab === 'zcash' }" 
            @click="activeTab = 'zcash'"
          >
            Zcash
          </button>
          <button 
            type="button" 
            class="tab-btn" 
            :class="{ active: activeTab === 'monero' }" 
            @click="activeTab = 'monero'"
          >
            Monero
          </button>
        </div>

        <div v-show="activeTab === 'zcash'" class="tab-content">
          <div class="qr-wrap">
            <canvas
              ref="qrCanvasZcash"
              class="qr-canvas"
              :class="{ 'qr-ready': qrReadyZcash }"
              aria-label="QR code for Zcash shielded address"
            ></canvas>
            <p v-if="qrErrorZcash" class="qr-error">{{ qrErrorZcash }}</p>
          </div>

          <div class="address-section">
            <p class="address-label">Shielded Zcash address</p>
            <code class="address-text">{{ ZCASH_ADDRESS }}</code>
            <button
              type="button"
              class="copy-btn"
              :class="{ copied: copiedZcash }"
              @click="copyAddressZcash"
            >
              {{ copiedZcash ? 'Copied!' : 'Copy address' }}
            </button>
          </div>
        </div>

        <div v-show="activeTab === 'monero'" class="tab-content">
          <div class="qr-wrap">
            <canvas
              ref="qrCanvasMonero"
              class="qr-canvas"
              :class="{ 'qr-ready': qrReadyMonero }"
              aria-label="QR code for Monero address"
            ></canvas>
            <p v-if="qrErrorMonero" class="qr-error">{{ qrErrorMonero }}</p>
          </div>

          <div class="address-section">
            <p class="address-label">Monero address</p>
            <code class="address-text">{{ MONERO_ADDRESS }}</code>
            <button
              type="button"
              class="copy-btn"
              :class="{ copied: copiedMonero }"
              @click="copyAddressMonero"
            >
              {{ copiedMonero ? 'Copied!' : 'Copy address' }}
            </button>
          </div>
        </div>

      </div>
    </div>
  </Transition>
</template>

<style scoped>
.modal-backdrop {
  position: fixed;
  inset: 0;
  z-index: 1000;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 20px;
  background: rgba(0, 0, 0, 0.7);
  backdrop-filter: blur(6px);
  -webkit-backdrop-filter: blur(6px);
}

.modal-panel {
  position: relative;
  width: 100%;
  max-width: 480px;
  max-height: calc(100vh - 40px);
  overflow-y: auto;
  padding: 28px 26px 24px;
  background: #0a0f15;
  border: 1px solid rgba(0, 240, 255, 0.25);
  border-radius: 16px;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.6),
    0 0 40px rgba(0, 240, 255, 0.08);
  color: #e0e0e0;
  outline: none;
}

.modal-panel:focus-visible {
  outline: 2px solid rgba(0, 240, 255, 0.5);
  outline-offset: 4px;
}

.modal-close {
  position: absolute;
  top: 10px;
  right: 12px;
  width: 32px;
  height: 32px;
  border: none;
  background: transparent;
  color: #888;
  font-size: 1.6rem;
  line-height: 1;
  cursor: pointer;
  border-radius: 8px;
  transition: color 0.2s ease, background 0.2s ease;
}

.modal-close:hover {
  color: #fff;
  background: rgba(255, 255, 255, 0.05);
}

.modal-close:focus-visible {
  outline: 2px solid rgba(0, 240, 255, 0.6);
  outline-offset: 2px;
}

.modal-title {
  font-family: 'Orbitron', sans-serif;
  font-weight: 700;
  font-size: 1.3rem;
  color: #fff;
  margin: 0 32px 12px 0;
  letter-spacing: 0.04em;
}

.modal-body {
  font-size: 0.9rem;
  line-height: 1.6;
  color: #b0b0b0;
  margin: 0 0 16px;
}

.tabs {
  display: flex;
  gap: 8px;
  margin-bottom: 20px;
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
  padding-bottom: 8px;
}

.tab-btn {
  background: transparent;
  border: none;
  color: #888;
  font-family: 'Inter', sans-serif;
  font-size: 0.9rem;
  font-weight: 500;
  padding: 8px 12px;
  cursor: pointer;
  border-radius: 6px;
  transition: all 0.2s ease;
}

.tab-btn:hover {
  color: #fff;
  background: rgba(255, 255, 255, 0.05);
}

.tab-btn.active {
  color: #00f0ff;
  background: rgba(0, 240, 255, 0.1);
}

.qr-wrap {
  display: flex;
  flex-direction: column;
  align-items: center;
  margin-bottom: 20px;
}

.qr-canvas {
  display: block;
  width: 220px;
  height: 220px;
  padding: 12px;
  background: #fff;
  border-radius: 12px;
  opacity: 0;
  transition: opacity 0.25s ease;
}

.qr-canvas.qr-ready {
  opacity: 1;
}

.qr-error {
  margin: 8px 0 0;
  font-size: 0.8rem;
  color: #e87461;
}

.address-section {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.address-label {
  font-size: 0.7rem;
  font-weight: 600;
  letter-spacing: 0.06em;
  text-transform: uppercase;
  color: #777;
  margin: 0;
}

.address-text {
  display: block;
  padding: 12px 14px;
  font-family: 'Menlo', 'Consolas', 'Courier New', monospace;
  font-size: 0.72rem;
  line-height: 1.5;
  color: #d8e6ee;
  background: rgba(255, 255, 255, 0.04);
  border: 1px solid rgba(255, 255, 255, 0.08);
  border-radius: 8px;
  word-break: break-all;
  overflow-wrap: anywhere;
  user-select: all;
}

.copy-btn {
  align-self: flex-start;
  padding: 8px 14px;
  background: rgba(0, 240, 255, 0.12);
  color: #00f0ff;
  border: 1px solid rgba(0, 240, 255, 0.35);
  border-radius: 8px;
  font-family: 'Inter', sans-serif;
  font-weight: 500;
  font-size: 0.82rem;
  cursor: pointer;
  transition: background 0.2s ease, color 0.2s ease, border-color 0.2s ease;
}

.copy-btn:hover {
  background: rgba(0, 240, 255, 0.2);
  border-color: rgba(0, 240, 255, 0.6);
}

.copy-btn:focus-visible {
  outline: 2px solid rgba(0, 240, 255, 0.6);
  outline-offset: 2px;
}

.copy-btn.copied {
  background: rgba(80, 250, 123, 0.15);
  border-color: rgba(80, 250, 123, 0.5);
  color: #50fa7b;
}

/* Entrance / exit animations */
.modal-enter-active,
.modal-leave-active {
  transition: opacity 0.2s ease;
}

.modal-enter-active .modal-panel,
.modal-leave-active .modal-panel {
  transition: transform 0.26s cubic-bezier(0.2, 0.8, 0.2, 1),
    opacity 0.26s ease;
}

.modal-enter-from,
.modal-leave-to {
  opacity: 0;
}

.modal-enter-from .modal-panel,
.modal-leave-to .modal-panel {
  transform: translateY(8px) scale(0.92);
  opacity: 0;
}

@media (max-width: 600px) {
  .modal-backdrop {
    padding: 12px;
  }

  .modal-panel {
    padding: 24px 20px 20px;
    border-radius: 14px;
  }

  .modal-title {
    font-size: 1.15rem;
  }

  .qr-canvas {
    width: 200px;
    height: 200px;
  }

  .address-text {
    font-size: 0.68rem;
  }
}

@media (prefers-reduced-motion: reduce) {
  .modal-enter-active,
  .modal-leave-active,
  .modal-enter-active .modal-panel,
  .modal-leave-active .modal-panel {
    transition-duration: 0ms;
  }

  .qr-canvas {
    transition-duration: 0ms;
  }
}
</style>
