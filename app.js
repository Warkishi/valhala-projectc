const SAVE_KEY = 'valhala-projectc-save-v1';
const START_GOLD = 1000;
const SINGLE_COST = 100;
const TEN_COST = 900;
const RARITIES = 10;
const CLASSES = ['Guerrier', 'Mage', 'Archer', 'Paladin', 'Assassin', 'Druide'];

const state = {
  gold: START_GOLD,
  heroes: [],
  history: [],
};

const elements = {
  gold: document.getElementById('goldValue'),
  probability: document.getElementById('probabilityText'),
  summonOne: document.getElementById('summonOneBtn'),
  summonTen: document.getElementById('summonTenBtn'),
  results: document.getElementById('resultsLabel'),
  inventory: document.getElementById('inventoryGrid'),
  toast: document.getElementById('toast'),
};

function loadState() {
  const raw = localStorage.getItem(SAVE_KEY);
  if (!raw) return;

  try {
    const parsed = JSON.parse(raw);
    state.gold = Number(parsed.gold ?? START_GOLD);
    state.heroes = Array.isArray(parsed.heroes) ? parsed.heroes : [];
    state.history = Array.isArray(parsed.history) ? parsed.history : [];
  } catch (error) {
    console.warn('Impossible de lire la sauvegarde locale.', error);
  }
}

function saveState() {
  localStorage.setItem(SAVE_KEY, JSON.stringify({
    gold: state.gold,
    heroes: state.heroes,
    history: state.history,
  }));
}

function probabilityText() {
  const weights = [];
  let total = 0;

  for (let rarity = 1; rarity <= RARITIES; rarity += 1) {
    const weight = Math.pow(2, RARITIES - rarity);
    weights.push(weight);
    total += weight;
  }

  const parts = weights.map((weight, index) => {
    const rarity = index + 1;
    const chance = (weight / total) * 100;
    return `${rarity}★ ${chance.toFixed(2)}%`;
  });

  return `Probabilités exponentielles\n  •  ${parts.join('  •  ')}`;
}

function rollRarity() {
  const weights = [];
  let total = 0;

  for (let rarity = 1; rarity <= RARITIES; rarity += 1) {
    const weight = Math.pow(2, RARITIES - rarity);
    weights.push(weight);
    total += weight;
  }

  let pick = Math.random() * total;
  for (let rarity = 1; rarity <= RARITIES; rarity += 1) {
    pick -= weights[rarity - 1];
    if (pick <= 0) {
      return rarity;
    }
  }

  return 1;
}

function randomFrom(array) {
  return array[Math.floor(Math.random() * array.length)];
}

function createHero() {
  const rarity = rollRarity();
  const heroIndex = Math.floor(Math.random() * 99999999) + 1000;
  const firstNames = ['Ael', 'Lyra', 'Kael', 'Mira', 'Orin', 'Nyx', 'Eira', 'Thane', 'Sora', 'Vey'];
  const heroName = `${randomFrom(firstNames)}-${heroIndex % 997}`;
  const className = randomFrom(CLASSES);

  return {
    id: heroIndex,
    name: heroName,
    class: className,
    rarity,
    power: Math.floor(Math.random() * 41) + 40 + rarity * 35,
    seed: Math.floor(Math.random() * 10000),
  };
}

function rarityColor(rarity) {
  const hue = (rarity - 1) / 14 + 0.7;
  return `hsl(${Math.round(hue * 360)}, 80%, 70%)`;
}

function renderInventory() {
  if (!state.heroes.length) {
    elements.inventory.innerHTML = '<div class="empty-state">Aucun héros. Lancez votre première invocation !</div>';
    return;
  }

  elements.inventory.innerHTML = state.heroes
    .map((hero) => {
      const accent = rarityColor(hero.rarity);
      const glow = `radial-gradient(circle, ${accent} 0%, rgba(255,255,255,0) 68%)`;
      return `
        <article class="hero-card">
          <div class="portrait" aria-label="Portrait de ${hero.name}">
            <div class="portrait-glow" style="background:${glow};"></div>
            <div class="portrait-core" style="border-color:${accent}; background: linear-gradient(180deg, rgba(255,255,255,0.08), rgba(28,36,66,0.9));"></div>
          </div>
          <p class="hero-name" style="color:${accent};">${hero.name}</p>
          <p class="hero-meta">${hero.class} • ${hero.rarity}★</p>
          <p class="hero-power">Puissance ${hero.power}</p>
        </article>
      `;
    })
    .join('');
}

function showToast(message) {
  elements.toast.textContent = message;
  elements.toast.classList.add('visible');
  clearTimeout(showToast.timeoutId);
  showToast.timeoutId = setTimeout(() => {
    elements.toast.classList.remove('visible');
  }, 2500);
}

function updateResources() {
  elements.gold.textContent = state.gold;
  elements.summonOne.disabled = state.gold < SINGLE_COST;
  elements.summonTen.disabled = state.gold < TEN_COST;
}

function summon(amount) {
  const cost = amount === 1 ? SINGLE_COST : TEN_COST;
  if (state.gold < cost) {
    showToast('Pas assez de fragments ✦');
    return;
  }

  state.gold -= cost;

  const newNames = [];
  for (let i = 0; i < amount; i += 1) {
    const hero = createHero();
    state.heroes.unshift(hero);
    state.history.unshift(hero);
    newNames.push(`${hero.name} ${hero.rarity}★`);
  }

  saveState();
  updateResources();
  renderInventory();
  elements.results.textContent = 'Dernière invocation : ' + newNames.join(', ');
  showToast("Les portes de Valhala s'ouvrent...");
}

function setupEvents() {
  elements.summonOne.addEventListener('click', () => summon(1));
  elements.summonTen.addEventListener('click', () => summon(10));
}

function init() {
  loadState();
  elements.probability.textContent = probabilityText();
  setupEvents();
  updateResources();
  renderInventory();
  elements.results.textContent = 'Bienvenue dans les chroniques de Valhala';
}

init();
