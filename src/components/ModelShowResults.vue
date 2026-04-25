<script setup>
import { ref, computed, onMounted, onUnmounted, onErrorCaptured } from 'vue'



// ── Types ──────────────────────────────────────────────────────────────
/**
 * @typedef {Object} ResultMeta
 * @property {string} id
 * @property {string} slug
 * @property {string} timestamp          – ISO 8601
 * @property {string} prompt
 * @property {string} prompt_preview
 * @property {string[]} models_queried
 * @property {number} models_queried_count
 * @property {string} winner_model
 * @property {number} winner_score
 * @property {number} total_duration_ms
 * @property {string} json_url
 * @property {string} md_url
 */

// ── State ──────────────────────────────────────────────────────────────
const INDEX_URL = '/modelshow-results/index.json'

const results          = ref([])
const loading          = ref(true)        // initial load
const error            = ref(null)

// Error handling
onErrorCaptured((err, instance, info) => {
  console.error('ModelShowResults Vue error:', err, info);
  error.value = `Component error: ${err.message}`;
  return false; // Prevent error from propagating
})

const newIds           = ref(new Set())   // IDs that appeared since first load

const expandedId       = ref(null)        // currently open row
const expandedFull     = ref(null)        // full JSON for expanded row
const expandLoading    = ref(false)

const sortBy           = ref('timestamp')
const sortOrder        = ref('desc')      // 'asc' | 'desc'
const filterText       = ref('')

// Pagination state
const currentPage      = ref(1)
const itemsPerPage     = ref(5)           // Default: 5 items per page
const itemsPerPageOptions = [5, 10, 20, 0] // 0 means "all"

let knownIds           = new Set()

// ── Computed ───────────────────────────────────────────────────────────
const filteredResults = computed(() => {
  const q = filterText.value.trim().toLowerCase()
  if (!q) return results.value
  return results.value.filter(r => {
    // Search in prompt
    if (r.prompt.toLowerCase().includes(q)) return true
    // Search in winner model
    if (r.winner_model.toLowerCase().includes(q)) return true
    // Search in judge model
    if (r.judge_model && r.judge_model.toLowerCase().includes(q)) return true
    // Search in models queried
    if (r.models_queried.some(m => m.toLowerCase().includes(q))) return true
    // Search in keywords/tags
    if (r.tags && r.tags.some(tag => tag.toLowerCase().includes(q))) return true
    return false
  })
})

const sortedResults = computed(() => {
  const arr = [...filteredResults.value]
  const dir = sortOrder.value === 'asc' ? 1 : -1
  arr.sort((a, b) => {
    switch (sortBy.value) {
      case 'timestamp':
        return dir * (new Date(a.timestamp) - new Date(b.timestamp))
      case 'winner_score':
        return dir * (a.winner_score - b.winner_score)
      case 'judge_model':
        return dir * (a.judge_model || '').localeCompare(b.judge_model || '')
      default:
        return 0
    }
  })
  return arr
})

// Pagination computed properties
const totalPages = computed(() => {
  if (itemsPerPage.value === 0) return 1 // Show all items on one page
  return Math.ceil(sortedResults.value.length / itemsPerPage.value)
})

const paginatedResults = computed(() => {
  if (itemsPerPage.value === 0) return sortedResults.value // Show all
  
  const start = (currentPage.value - 1) * itemsPerPage.value
  const end = start + itemsPerPage.value
  return sortedResults.value.slice(start, end)
})

const pageNumbers = computed(() => {
  const pages = []
  const maxVisible = 5 // Maximum number of page buttons to show
  
  if (totalPages.value <= maxVisible) {
    // Show all pages
    for (let i = 1; i <= totalPages.value; i++) {
      pages.push(i)
    }
  } else {
    // Show first page, last page, and pages around current page
    pages.push(1)
    
    let start = Math.max(2, currentPage.value - 1)
    let end = Math.min(totalPages.value - 1, currentPage.value + 1)
    
    // Adjust if we're near the beginning
    if (currentPage.value <= 3) {
      end = Math.min(totalPages.value - 1, 4)
    }
    
    // Adjust if we're near the end
    if (currentPage.value >= totalPages.value - 2) {
      start = Math.max(2, totalPages.value - 3)
    }
    
    // Add ellipsis if needed
    if (start > 2) {
      pages.push('...')
    }
    
    // Add middle pages
    for (let i = start; i <= end; i++) {
      pages.push(i)
    }
    
    // Add ellipsis if needed
    if (end < totalPages.value - 1) {
      pages.push('...')
    }
    
    // Add last page
    if (totalPages.value > 1) {
      pages.push(totalPages.value)
    }
  }
  
  return pages
})

const hasResults = computed(() => results.value.length > 0)
const hasFilter  = computed(() => filterText.value.trim().length > 0)

// ── Helpers ────────────────────────────────────────────────────────────
function shortModel(model) {
  // "google/gemini-2.5-pro" → "gemini-2.5-pro"
  // "openrouter/openai/gpt-5" → "gpt-5"
  if (!model) {
    // Don't log warnings in production - it's expected for some results
    // console.warn('shortModel called with falsy value:', model);
    return '—'
  }
  // Handle both string and object/array cases
  if (typeof model !== 'string') {
    return '—'
  }
  return model.split('/').pop()
}

function fmtDate(isoStr) {
  // Display date only — no time component shown in the main table
  return new Intl.DateTimeFormat('en-US', {
    month: 'short', day: 'numeric', year: 'numeric'
  }).format(new Date(isoStr))
}

function fmtDateFull(isoStr) {
  // For expanded detail view: date + time (UTC, no raw ISO string)
  return new Intl.DateTimeFormat('en-US', {
    month: 'short', day: 'numeric', year: 'numeric',
    hour: '2-digit', minute: '2-digit', timeZone: 'UTC', timeZoneName: 'short'
  }).format(new Date(isoStr))
}

function fmtDuration(ms) {
  if (ms < 1000) return `${ms}ms`
  return `${(ms / 1000).toFixed(1)}s`
}

function slugify(text) {
  if (typeof text !== 'string' || !text) return '';
  return text
    .toString()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .toLowerCase()
    .trim()
    .replace(/[^a-z0-9\s-]/g, '')
    .replace(/\s+/g, '-')
    .replace(/-+/g, '-');
}

function generatePromptLink(result) {
  if (!result || !result.id) return '#';
  return `/modelshow-results/#${result.id}`;
}

async function copyLinkToClipboard(link) {
  try {
    const fullUrl = window.location.origin + link;
    await navigator.clipboard.writeText(fullUrl);
    alert('Link copied to clipboard!');
  } catch (err) {
    console.error('Failed to copy: ', err);
    alert('Failed to copy link.');
  }
}

function getMedal(rank) {
  return ['🥇', '🥈', '🥉'][rank - 1] ?? `#${rank}`
}

function sortIcon(col) {
  if (sortBy.value !== col) return '↕'
  return sortOrder.value === 'desc' ? '↓' : '↑'
}

function toggleSort(col) {
  if (sortBy.value === col) {
    sortOrder.value = sortOrder.value === 'desc' ? 'asc' : 'desc'
  } else {
    sortBy.value = col
    sortOrder.value = 'desc'
  }
}

// ── Data fetching ──────────────────────────────────────────────────────
async function fetchIndex() {
  loading.value = true
  error.value = null

  try {
    const res = await fetch(`${INDEX_URL}?_t=${Date.now()}`)
    if (!res.ok) throw new Error(`HTTP ${res.status}`)
    const data = await res.json()

    const incoming = (data.results ?? [])
    // Detect new items (entries not seen on first load)
    if (knownIds.size > 0) {
      const fresh = incoming.filter(r => !knownIds.has(r.id))
      fresh.forEach(r => newIds.value.add(r.id))
    }
    incoming.forEach(r => knownIds.add(r.id))

    results.value = incoming
  } catch (e) {
    error.value = `Could not load results: ${e.message}`
    // Exponential backoff
    return
  } finally {
    loading.value = false
  }
}

async function fetchFullResult(id, jsonUrl) {
  if (expandedId.value === id) {
    // Collapse
    expandedId.value = null
    expandedFull.value = null
    return
  }
  expandedId.value = id
  expandedFull.value = null
  expandLoading.value = true
  newIds.value.delete(id) // mark as seen

  try {
    const res = await fetch(`${jsonUrl}?_t=${Date.now()}`)
    if (!res.ok) throw new Error(`HTTP ${res.status}`)
    expandedFull.value = await res.json()
  } catch (e) {
    expandedFull.value = { _error: `Failed to load: ${e.message}` }
  } finally {
    expandLoading.value = false
  }
}

function clearFilter() {
  filterText.value = ''
}

// Pagination functions
function goToPage(page) {
  if (page >= 1 && page <= totalPages.value && page !== currentPage.value) {
    currentPage.value = page
  }
}

function nextPage() {
  if (currentPage.value < totalPages.value) {
    currentPage.value++
  }
}

function prevPage() {
  if (currentPage.value > 1) {
    currentPage.value--
  }
}

function changeItemsPerPage(value) {
  itemsPerPage.value = value
  currentPage.value = 1 // Reset to first page when changing items per page
}

// ── Lifecycle ──────────────────────────────────────────────────────────
onMounted(() => {
  fetchIndex().then(() => {
    if (window.location.hash) {
      const hash = window.location.hash.substring(1);
      const parts = hash.split('-');
      
      // Since format is YYYY-MM-DD-ID-SLUG, we need to extract ID correctly.
      // E.g. 2026-03-31-show-me-the-entire-gettysburg-2026-03-31-0043-show-me-the-entire-gettysburg-address-by-abraham-
      // It's safer to extract it based on finding a matching ID from results array using substring match on hash
      const targetResult = results.value.find(r => hash.includes(r.id));

      if (targetResult) {
        itemsPerPage.value = 0;
        
        // Use a small delay to ensure DOM is ready
        setTimeout(() => {
          fetchFullResult(targetResult.id, targetResult.json_url).then(() => {
            setTimeout(() => {
              const element = document.getElementById(`modelshow-result-${targetResult.id}`);
              if (element) {
                element.scrollIntoView({ behavior: 'smooth', block: 'center' });
                // Optional highlight effect
                element.style.transition = 'background-color 2s';
                element.style.backgroundColor = 'rgba(232, 116, 97, 0.2)';
                setTimeout(() => {
                   element.style.backgroundColor = '';
                }, 2000);
              }
            }, 100);
          });
        }, 100);
      }
    }
  });
})

// ── Watchers ──────────────────────────────────────────────────────────
import { watch } from 'vue'
// Reset to first page when filter changes or sorted results change
watch([filterText, sortedResults], () => {
  currentPage.value = 1
})
</script>

<template>
  <section class="section modelshow-section">
    <!-- Section header -->
    <h2 class="section-title">Model Comparisons</h2>
    
    <!-- Section explanation -->
    <div class="skill-explanation">
      <p>Results from experiments I run regularly to evaluate how different AI models handle various prompts—from factual questions to creative challenges. Each comparison uses <a href="https://clawhub.com/skills/modelshow" target="_blank" rel="noopener" class="modelshow-link"><strong>ModelShow</strong></a>, an OpenClaw skill that conducts double-blind tests where model names are hidden and a judge ranks responses purely on merit.</p>
    </div>

    <!-- Error banner -->
    <div v-if="error" class="ms-error-banner" role="alert">
      ⚠️ {{ error }}
      <button class="ms-retry-btn" @click="manualRefresh">Retry</button>
    </div>

    <!-- Controls bar -->
    <div v-if="!loading" class="ms-controls">
      <div class="ms-search-wrap">
        <input
          v-model="filterText"
          class="ms-search"
          type="search"
          placeholder="Filter by prompt, model, keyword…"
          aria-label="Filter results"
        />
        <button v-if="hasFilter" class="ms-clear-btn" @click="clearFilter" aria-label="Clear filter">✕</button>
      </div>

      
    </div>

    <!-- Loading skeleton -->
    <div v-if="loading" class="ms-loading">
      <div class="ms-skeleton" v-for="n in 3" :key="n"></div>
    </div>

    <!-- Results table -->
    <div v-else-if="hasResults" class="ms-table-wrap">
      <table class="ms-table" role="table">
        <thead>
          <tr>
            <th class="ms-th ms-th-sortable" @click="toggleSort('timestamp')" scope="col">
              Date {{ sortIcon('timestamp') }}
            </th>
            <th class="ms-th" scope="col">Prompt</th>
            <th class="ms-th ms-th-sortable" @click="toggleSort('judge_model')" scope="col">
              Judge {{ sortIcon('judge_model') }}
            </th>
            <th class="ms-th" scope="col">Winner</th>
            
            <th class="ms-th ms-th-actions" scope="col">Details</th>
          </tr>
        </thead>
        <tbody>
          <template v-for="r in paginatedResults" :key="r.id">
            <!-- Main row -->
            <tr
              class="ms-row"
              :id="`modelshow-result-${r.id}`"
              :class="{
                'ms-row-new': newIds.has(r.id),
                'ms-row-expanded': expandedId === r.id
              }"
            >
              <td class="ms-td ms-td-date">
                <span class="ms-new-badge" v-if="newIds.has(r.id)">NEW</span>
                {{ fmtDate(r.timestamp) }}
              </td>
              <td class="ms-td ms-td-prompt">
                <span class="ms-prompt-text">{{ r.prompt_preview }}</span>
                <div v-if="r.tags && r.tags.length > 0" class="ms-keywords">
                  <span v-for="tag in r.tags" :key="tag" class="ms-keyword-tag">{{ tag }}</span>
                </div>
              </td>
              <td class="ms-td ms-td-judge">
                <span class="ms-judge-name">{{ shortModel(r.judge_model || r.meta?.judge_model) }}</span>
              </td>
              <td class="ms-td ms-td-winner">
                🏆 <span class="ms-winner-name">{{ shortModel(r.winner_model) }}</span>
              </td>
              
              <td class="ms-td ms-td-actions">
                <button
                  class="ms-copy-link-btn"
                  @click.stop="copyLinkToClipboard(generatePromptLink(r))"
                  aria-label="Copy link to this prompt"
                  title="Copy link to this prompt"
                >
                  🔗
                </button>
                <button
                  class="ms-expand-btn"
                  @click="fetchFullResult(r.id, r.json_url)"
                  :aria-expanded="expandedId === r.id"
                  :aria-label="expandedId === r.id ? 'Collapse details' : 'Expand details'"
                >
                  {{ expandedId === r.id ? '▲' : '▼' }}
                </button>
              </td>
            </tr>

            <!-- Expanded detail row -->
            <tr v-if="expandedId === r.id" class="ms-detail-row">
              <td colspan="5" class="ms-detail-cell">

                <!-- Loading spinner for detail -->
                <div v-if="expandLoading" class="ms-detail-loading">Loading…</div>

                <!-- Error in detail -->
                <div v-else-if="expandedFull && expandedFull._error" class="ms-detail-error">
                  {{ expandedFull._error }}
                </div>

                <!-- Full detail view -->
                <div v-else-if="expandedFull" class="ms-detail">

                  <!-- Prompt -->
                  <div class="ms-detail-prompt">
                    <span class="ms-detail-label">Prompt</span>
                    <p class="ms-detail-prompt-text">{{ expandedFull.meta.prompt }}</p>
                  </div>

                  <!-- Meta row -->
                  <div class="ms-detail-meta-row">
                    <span class="ms-chip">📅 {{ fmtDateFull(expandedFull.meta.timestamp) }}</span>
                    <span class="ms-chip">⚖️ Judge: {{ shortModel(expandedFull.meta.judge_model) }}</span>
                    <span class="ms-chip">👁 Mode: {{ expandedFull.meta.judging_mode === 'blind' ? 'double-blind' : expandedFull.meta.judging_mode }}</span>
                    <span v-if="expandedFull.metadata && expandedFull.metadata.total_duration_ms > 0" class="ms-chip">⏱ {{ fmtDuration(expandedFull.metadata.total_duration_ms) }}</span>
                    <span v-if="expandedFull.metadata && expandedFull.metadata.failed_models > 0" class="ms-chip ms-chip-warn">
                      ⚠️ {{ expandedFull.metadata.failed_models }} failed
                    </span>
                  </div>

                  <!-- Rankings -->
                  <div class="ms-rankings">
                    <div
                      v-for="entry in expandedFull.results"
                      :key="entry.rank"
                      class="ms-rank-card"
                      :class="`ms-rank-${entry.rank}`"
                    >
                      <div class="ms-rank-header">
                        <span class="ms-medal">{{ getMedal(entry.rank) }}</span>
                        <strong class="ms-rank-model">{{ shortModel(entry.model) }}</strong>
                        <span class="ms-rank-score">{{ entry.score.toFixed(1) }}/10</span>
                      </div>
                      <p class="ms-assessment">{{ entry.assessment }}</p>
                      <details class="ms-response-details">
                        <summary class="ms-response-summary">View response</summary>
                        <div class="ms-response-body">{{ entry.response }}</div>
                      </details>
                    </div>
                  </div>

                  <!-- Judge analysis -->
                  <div class="ms-judge-analysis">
                    <span class="ms-detail-label">Judge's Overall Assessment</span>
                    <p>{{ expandedFull.judge_analysis || expandedFull.judge_analysis_full }}</p>
                    <details v-if="expandedFull.judge_analysis_full && expandedFull.judge_analysis !== expandedFull.judge_analysis_full" class="ms-response-details" style="margin-top: 10px;">
                      <summary class="ms-response-summary">Full judge report (per-model rankings + analysis)</summary>
                      <div class="ms-response-body">{{ expandedFull.judge_analysis_full }}</div>
                    </details>
                  </div>

                  <!-- Raw links -->
                  <div class="ms-detail-links">
                    <a :href="r.json_url" target="_blank" rel="noopener" class="ms-raw-link">
                      Raw JSON ↗
                    </a>
                    <a v-if="r.md_url" :href="r.md_url" target="_blank" rel="noopener" class="ms-raw-link">
                      Report ↗
                    </a>
                  </div>
                </div>
              </td>
            </tr>
          </template>
        </tbody>
      </table>

      <!-- Filtered-empty state -->
      <div v-if="sortedResults.length === 0 && hasFilter" class="ms-empty">
        No results match "{{ filterText }}"
        <button class="ms-clear-btn-inline" @click="clearFilter">Clear filter</button>
      </div>

      <!-- Footer -->
      <div class="ms-table-footer">
        <div class="ms-pagination-info">
          <span v-if="itemsPerPage > 0">
            Showing {{ ((currentPage - 1) * itemsPerPage) + 1 }}-{{ Math.min(currentPage * itemsPerPage, sortedResults.length) }} of {{ sortedResults.length }} result{{ sortedResults.length !== 1 ? 's' : '' }}
          </span>
          <span v-else>
            Showing all {{ sortedResults.length }} result{{ sortedResults.length !== 1 ? 's' : '' }}
          </span>
        </div>
        
        <!-- Items per page selector -->
        <div class="ms-items-per-page">
          <label for="items-per-page-select" class="ms-items-per-page-label">Show:</label>
          <select 
            id="items-per-page-select"
            v-model="itemsPerPage" 
            @change="changeItemsPerPage(parseInt($event.target.value))"
            class="ms-items-per-page-select"
          >
            <option v-for="option in itemsPerPageOptions" :key="option" :value="option">
              {{ option === 0 ? 'All' : option }}
            </option>
          </select>
        </div>
      </div>

      <!-- Pagination controls -->
      <div v-if="totalPages > 1" class="ms-pagination-controls">
        <button 
          class="ms-pagination-btn ms-pagination-prev" 
          @click="prevPage"
          :disabled="currentPage === 1"
          aria-label="Previous page"
        >
          ← Previous
        </button>
        
        <div class="ms-pagination-pages">
          <button
            v-for="page in pageNumbers"
            :key="page"
            class="ms-pagination-page"
            :class="{
              'ms-pagination-page-current': page === currentPage,
              'ms-pagination-page-ellipsis': page === '...'
            }"
            @click="page !== '...' && goToPage(page)"
            :disabled="page === '...' || page === currentPage"
            :aria-label="page === '...' ? 'More pages' : `Go to page ${page}`"
            :aria-current="page === currentPage ? 'page' : null"
          >
            {{ page }}
          </button>
        </div>
        
        <button 
          class="ms-pagination-btn ms-pagination-next" 
          @click="nextPage"
          :disabled="currentPage === totalPages"
          aria-label="Next page"
        >
          Next →
        </button>
      </div>
    </div>

    <!-- Truly empty state (no data at all) -->
    <div v-else class="ms-empty ms-empty-full">
      <span class="ms-empty-icon">🔬</span>
      <p>No ModelShow results yet.</p>
      <p class="ms-empty-hint">Run <code>/mdls &lt;prompt&gt;</code> in chat to start a comparison.</p>
    </div>
  </section>
</template>

<style scoped>
/* ── Section wrapper ────────────────────────────────── */
.modelshow-section {
  padding: 0;
}

/* ── Error banner ───────────────────────────────────── */
.ms-error-banner {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 16px;
  padding: 12px 16px;
  background: rgba(255, 80, 80, 0.08);
  border: 1px solid rgba(255, 80, 80, 0.25);
  border-radius: 8px;
  color: #ff8080;
  font-size: 0.9rem;
}

.ms-retry-btn {
  margin-left: auto;
  padding: 4px 12px;
  background: transparent;
  border: 1px solid rgba(255, 80, 80, 0.4);
  color: #ff8080;
  border-radius: 4px;
  cursor: pointer;
  font-size: 0.85rem;
  transition: background 0.2s;
}
.ms-retry-btn:hover { background: rgba(255, 80, 80, 0.15); }

/* ── Controls bar ───────────────────────────────────── */
.ms-controls {
  display: flex;
  align-items: center;
  gap: 10px;
  flex-wrap: wrap;
  margin-bottom: 16px;
}

.ms-search-wrap {
  position: relative;
  flex: 1;
  min-width: 160px;
}

.ms-search {
  width: 100%;
  padding: 8px 32px 8px 12px;
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 6px;
  color: #e0e0e0;
  font-size: 0.9rem;
  outline: none;
  transition: border-color 0.2s;
}
.ms-search:focus { border-color: rgba(232, 116, 97, 0.5); }
.ms-search::placeholder { color: #555; }

.ms-clear-btn {
  position: absolute;
  right: 8px;
  top: 50%;
  transform: translateY(-50%);
  background: none;
  border: none;
  color: #666;
  cursor: pointer;
  font-size: 0.8rem;
  padding: 2px;
  line-height: 1;
  transition: color 0.2s;
}
.ms-clear-btn:hover { color: #e0e0e0; }

/* ── Loading skeleton ───────────────────────────────── */
.ms-loading {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.ms-skeleton {
  height: 48px;
  background: linear-gradient(90deg,
    rgba(255,255,255,0.03) 0%,
    rgba(255,255,255,0.07) 50%,
    rgba(255,255,255,0.03) 100%
  );
  background-size: 200% 100%;
  border-radius: 6px;
  animation: shimmer 1.5s infinite;
}

@keyframes shimmer {
  0%   { background-position: -200% 0; }
  100% { background-position:  200% 0; }
}

/* ── Table ──────────────────────────────────────────── */
.ms-table-wrap {
  overflow-x: auto;
  -webkit-overflow-scrolling: touch;
  border-radius: 10px;
  border: 1px solid rgba(255, 255, 255, 0.07);
}

.ms-table {
  width: 100%;
  border-collapse: collapse;
  font-size: 0.88rem;
  min-width: 520px;
}

/* ── Table header ───────────────────────────────────── */
.ms-th {
  padding: 12px 14px;
  text-align: left;
  color: #888;
  font-weight: 600;
  font-size: 0.78rem;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  border-bottom: 1px solid rgba(255, 255, 255, 0.08);
  white-space: nowrap;
  background: rgba(255, 255, 255, 0.02);
}

.ms-th-sortable {
  cursor: pointer;
  user-select: none;
  transition: color 0.2s;
}
.ms-th-sortable:hover { color: #e87461; }

.ms-th-num { text-align: right; }
.ms-th-actions { width: 60px; text-align: center; }

/* ── Table rows ─────────────────────────────────────── */
.ms-row {
  transition: background 0.15s;
}
.ms-row:hover { background: rgba(255, 255, 255, 0.03); }

.ms-row-new {
  animation: flash-new 1.5s ease-out;
}
@keyframes flash-new {
  0%   { background: rgba(232, 116, 97, 0.15); }
  100% { background: transparent; }
}

.ms-row-expanded > .ms-td {
  border-bottom: none;
}

/* ── Table cells ────────────────────────────────────── */
.ms-td {
  padding: 12px 14px;
  border-bottom: 1px solid rgba(255, 255, 255, 0.04);
  vertical-align: top;
  color: #ccc;
}

.ms-td-date {
  white-space: nowrap;
  font-size: 0.8rem;
  color: #777;
}

.ms-td-prompt {
  max-width: 400px;
}

.ms-prompt-text {
  display: -webkit-box;
  -webkit-line-clamp: 3;
  -webkit-box-orient: vertical;
  overflow: hidden;
  line-height: 1.4;
}

.ms-td-num { text-align: right; }

.ms-td-winner { white-space: nowrap; }
.ms-winner-name { color: #e0e0e0; }

.ms-td-score {
  color: #e87461;
  font-weight: 600;
  font-variant-numeric: tabular-nums;
}

.ms-td-actions { text-align: center; }

/* ── New badge ──────────────────────────────────────── */
.ms-new-badge {
  display: inline-block;
  margin-right: 6px;
  padding: 1px 5px;
  background: rgba(232, 116, 97, 0.25);
  border: 1px solid rgba(232, 116, 97, 0.5);
  border-radius: 3px;
  color: #e87461;
  font-size: 0.65rem;
  font-weight: 700;
  letter-spacing: 0.06em;
  vertical-align: middle;
}

/* ── Expand button ──────────────────────────────────── */
.ms-copy-link-btn {
  padding: 6px 10px;
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(255, 255, 255, 0.1);
  color: #888;
  border-radius: 5px;
  cursor: pointer;
  font-size: 0.75rem;
  transition: background 0.2s, color 0.2s;
  touch-action: manipulation;
  min-width: 36px;
  min-height: 36px; /* touch-friendly */
  margin-right: 8px; /* Spacing between copy and expand button */
}

.ms-copy-link-btn:hover {
  background: rgba(255, 255, 255, 0.1);
  color: #e0e0e0;
}

.ms-expand-btn {
  padding: 6px 10px;
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(255, 255, 255, 0.1);
  color: #888;
  border-radius: 5px;
  cursor: pointer;
  font-size: 0.75rem;
  transition: background 0.2s, color 0.2s;
  touch-action: manipulation;
  min-width: 36px;
  min-height: 36px;  /* touch-friendly */
}
.ms-expand-btn:hover { background: rgba(255, 255, 255, 0.1); color: #e0e0e0; }

/* ── Detail row ─────────────────────────────────────── */
.ms-detail-row > .ms-detail-cell {
  padding: 0;
  background: rgba(255, 255, 255, 0.015);
  border-bottom: 1px solid rgba(255, 255, 255, 0.07);
}

.ms-detail {
  padding: 20px 20px 24px;
}

.ms-detail-loading,
.ms-detail-error {
  padding: 20px;
  text-align: center;
  color: #666;
  font-style: italic;
}
.ms-detail-error { color: #ff8080; }

/* ── Detail: Prompt ─────────────────────────────────── */
.ms-detail-label {
  display: block;
  font-size: 0.72rem;
  text-transform: uppercase;
  letter-spacing: 0.08em;
  color: #666;
  font-weight: 600;
  margin-bottom: 6px;
}

.ms-detail-prompt {
  margin-bottom: 14px;
  padding: 14px;
  background: rgba(255, 255, 255, 0.02);
  border-left: 2px solid rgba(232, 116, 97, 0.4);
  border-radius: 0 6px 6px 0;
}
.ms-detail-prompt-text {
  color: #bbb;
  line-height: 1.6;
  margin: 0;
}

/* ── Detail: Meta chips ─────────────────────────────── */
.ms-detail-meta-row {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  margin-bottom: 16px;
}

.ms-chip {
  padding: 4px 10px;
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(255, 255, 255, 0.08);
  border-radius: 20px;
  color: #888;
  font-size: 0.78rem;
  white-space: nowrap;
}
.ms-chip-warn {
  background: rgba(255, 180, 50, 0.08);
  border-color: rgba(255, 180, 50, 0.25);
  color: #ffb432;
}

/* ── Rankings ───────────────────────────────────────── */
.ms-rankings {
  display: flex;
  flex-direction: column;
  gap: 12px;
  margin-bottom: 16px;
}

.ms-rank-card {
  padding: 14px 16px;
  border-radius: 8px;
  background: rgba(255, 255, 255, 0.02);
  border: 1px solid rgba(255, 255, 255, 0.06);
}
.ms-rank-1 { border-color: rgba(255, 215, 0, 0.2); background: rgba(255, 215, 0, 0.03); }
.ms-rank-2 { border-color: rgba(192, 192, 192, 0.18); }
.ms-rank-3 { border-color: rgba(205, 127, 50, 0.18); }

.ms-rank-header {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 8px;
}

.ms-medal { font-size: 1.2rem; flex-shrink: 0; }
.ms-rank-model { color: #e0e0e0; font-size: 0.95rem; flex: 1; }
.ms-rank-score { color: #e87461; font-weight: 700; font-size: 0.95rem; white-space: nowrap; }

.ms-assessment {
  color: #888;
  font-size: 0.85rem;
  line-height: 1.5;
  margin: 0 0 10px;
}

.ms-response-details {
  margin-top: 4px;
}

.ms-response-summary {
  cursor: pointer;
  color: #666;
  font-size: 0.8rem;
  user-select: none;
  padding: 2px 0;
  list-style: none;
  transition: color 0.2s;
}
.ms-response-summary:hover { color: #aaa; }
.ms-response-summary::-webkit-details-marker { display: none; }
.ms-response-summary::before { content: '▶ '; font-size: 0.65rem; }
details[open] .ms-response-summary::before { content: '▼ '; }

.ms-response-body {
  margin-top: 10px;
  padding: 12px 14px;
  background: rgba(0, 0, 0, 0.3);
  border-radius: 6px;
  color: #bbb;
  font-size: 0.85rem;
  line-height: 1.6;
  white-space: pre-wrap;
  word-break: break-word;
}

/* ── Judge analysis ─────────────────────────────────── */
.ms-judge-analysis {
  padding: 14px;
  border-left: 2px solid rgba(255, 255, 255, 0.1);
  border-radius: 0 6px 6px 0;
  margin-bottom: 14px;
}
.ms-judge-analysis p {
  color: #999;
  font-size: 0.87rem;
  line-height: 1.6;
  font-style: italic;
  margin: 0;
}

/* ── Detail links ───────────────────────────────────── */
.ms-detail-links {
  display: flex;
  gap: 12px;
}

.ms-raw-link {
  font-size: 0.8rem;
  color: #666;
  text-decoration: none;
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
  transition: color 0.2s, border-color 0.2s;
}
.ms-raw-link:hover { color: #e87461; border-color: rgba(232, 116, 97, 0.4); }

/* ── Table footer ───────────────────────────────────── */
.ms-table-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 10px 14px;
  border-top: 1px solid rgba(255, 255, 255, 0.06);
  color: #555;
  font-size: 0.78rem;
  flex-wrap: wrap;
  gap: 12px;
}

.ms-poll-note { font-style: italic; }

.ms-pagination-info {
  flex: 1;
  min-width: 200px;
}

.ms-items-per-page {
  display: flex;
  align-items: center;
  gap: 6px;
}

.ms-items-per-page-label {
  color: #666;
  font-size: 0.75rem;
}

.ms-items-per-page-select {
  padding: 4px 8px;
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 4px;
  color: #ccc;
  font-size: 0.75rem;
  outline: none;
  cursor: pointer;
  transition: border-color 0.2s;
}

.ms-items-per-page-select:hover {
  border-color: rgba(232, 116, 97, 0.3);
}

.ms-items-per-page-select:focus {
  border-color: rgba(232, 116, 97, 0.5);
}

/* ── Pagination controls ────────────────────────────── */
.ms-pagination-controls {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 12px;
  padding: 16px 14px;
  border-top: 1px solid rgba(255, 255, 255, 0.06);
  flex-wrap: wrap;
}

.ms-pagination-btn {
  padding: 8px 16px;
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 6px;
  color: #888;
  font-size: 0.85rem;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s;
  white-space: nowrap;
}

.ms-pagination-btn:hover:not(:disabled) {
  background: rgba(255, 255, 255, 0.1);
  color: #e0e0e0;
  border-color: rgba(232, 116, 97, 0.3);
}

.ms-pagination-btn:disabled {
  opacity: 0.4;
  cursor: not-allowed;
}

.ms-pagination-pages {
  display: flex;
  gap: 6px;
}

.ms-pagination-page {
  min-width: 36px;
  height: 36px;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 0 8px;
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 6px;
  color: #888;
  font-size: 0.85rem;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s;
}

.ms-pagination-page:hover:not(:disabled):not(.ms-pagination-page-ellipsis) {
  background: rgba(255, 255, 255, 0.1);
  color: #e0e0e0;
  border-color: rgba(232, 116, 97, 0.3);
}

.ms-pagination-page-current {
  background: rgba(232, 116, 97, 0.15);
  color: #e87461;
  border-color: rgba(232, 116, 97, 0.4);
  cursor: default;
}

.ms-pagination-page-ellipsis {
  background: transparent;
  border: none;
  cursor: default;
  min-width: auto;
  padding: 0 4px;
}

.ms-pagination-page:disabled {
  opacity: 0.4;
  cursor: not-allowed;
}

/* ── Empty states ───────────────────────────────────── */
.ms-empty {
  padding: 20px;
  text-align: center;
  color: #555;
  font-size: 0.9rem;
}

.ms-empty-full {
  padding: 48px 20px;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
}
.ms-empty-icon { font-size: 2.5rem; opacity: 0.4; }
.ms-empty-full p { margin: 0; color: #555; }
.ms-empty-hint { color: #444; font-size: 0.85rem; }
.ms-empty-hint code {
  padding: 1px 5px;
  background: rgba(255, 255, 255, 0.06);
  border-radius: 4px;
  font-size: 0.82rem;
  color: #e87461;
}

.ms-clear-btn-inline {
  display: inline-block;
  margin-left: 8px;
  padding: 3px 10px;
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 4px;
  color: #888;
  cursor: pointer;
  font-size: 0.85rem;
  transition: color 0.2s;
}
.ms-clear-btn-inline:hover { color: #e0e0e0; }

/* ── Keywords ───────────────────────────────────────── */
.ms-keywords {
  display: flex;
  flex-wrap: wrap;
  gap: 4px;
  margin-top: 6px;
}

.ms-keyword-tag {
  background: rgba(100, 255, 218, 0.1);
  color: #64ffda;
  padding: 2px 6px;
  border-radius: 10px;
  font-size: 0.7rem;
  font-weight: 500;
}

/* ── Section Explanation Box ─────────────────────────── */
.skill-explanation {
  background: rgba(255, 255, 255, 0.03);
  border-radius: 8px;
  padding: 14px 18px;
  margin-bottom: 20px;
  border-left: 3px solid #00f0ff;
}

.skill-explanation p {
  margin: 0;
  line-height: 1.5;
  color: #999;
  font-size: 0.85rem;
}

/* ── Mobile ─────────────────────────────────────────── */
@media (max-width: 600px) {
  .ms-controls {
    flex-direction: column;
    align-items: stretch;
  }

  .ms-th:nth-child(3),
  .ms-td:nth-child(3) {
    display: none;
  }

  .ms-td-date {
    font-size: 0.72rem;
  }

  .ms-prompt-text {
    -webkit-line-clamp: 2;
  }

  .ms-detail {
    padding: 14px 12px 18px;
  }

  .ms-rankings {
    gap: 10px;
  }

  .ms-rank-card {
    padding: 12px;
  }

  .ms-table-footer {
    flex-direction: column;
    gap: 8px;
    align-items: stretch;
  }

  .ms-pagination-info {
    min-width: auto;
    text-align: center;
  }

  .ms-items-per-page {
    justify-content: center;
  }

  .ms-pagination-controls {
    flex-direction: column;
    gap: 10px;
  }

  .ms-pagination-btn {
    width: 100%;
    justify-content: center;
  }

  .ms-pagination-pages {
    order: -1;
    width: 100%;
    justify-content: center;
    flex-wrap: wrap;
  }

  .skill-explanation {
    padding: 12px 14px;
    margin-bottom: 16px;
  }
  .skill-explanation p {
    font-size: 0.82rem;
  }
}

.modelshow-link {
  color: #00f0ff;
  text-decoration: none;
  border-bottom: 1px dashed rgba(0, 240, 255, 0.4);
  transition: all 0.2s ease;
}

.modelshow-link:hover {
  color: #64ffda;
  border-bottom-color: #64ffda;
}

.modelshow-link strong {
  color: inherit;
}

</style>
