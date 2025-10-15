const WIDTH = 29;
const HEIGHT = 19;
const MAX_ENEMIES = 7;
const MAX_CRYSTALS = 6;
const MAX_HEARTS = 3;

const TILE = {
  WALL: "#",
  FLOOR: ".",
  EXIT: ">",
  CRYSTAL: "*",
  HEART: "+",
};

const DIRS = [
  { x: 0, y: -1, name: "up" },
  { x: 1, y: 0, name: "right" },
  { x: 0, y: 1, name: "down" },
  { x: -1, y: 0, name: "left" },
];

const ENEMY_TYPES = [
  { name: "Goblin", glyph: "g", hp: 2, damage: 1 },
  { name: "Bat", glyph: "b", hp: 1, damage: 1 },
  { name: "Slime", glyph: "s", hp: 3, damage: 1 },
];

const state = {
  tiles: [],
  items: new Map(),
  enemies: [],
  player: {
    x: 0,
    y: 0,
    hp: 8,
    maxHp: 8,
    crystals: 0,
    score: 0,
  },
  exit: { x: 0, y: 0 },
  visible: new Set(),
  seen: new Set(),
  status: "loading",
  message: "",
};

const mapEl = document.getElementById("map");
const messageEl = document.getElementById("message");
const statsEl = document.getElementById("stats");
const controlButtons = document.querySelectorAll(".control[data-dir]");
const newGameButton = document.getElementById("new-game");

function idx(x, y) {
  return y * WIDTH + x;
}

function key(x, y) {
  return `${x},${y}`;
}

function clamp(value, min, max) {
  return Math.max(min, Math.min(max, value));
}

function randomOf(array) {
  return array[Math.floor(Math.random() * array.length)];
}

function randomInt(min, max) {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

function inBounds(x, y) {
  return x >= 0 && x < WIDTH && y >= 0 && y < HEIGHT;
}

function isWalkable(x, y) {
  const tile = state.tiles[idx(x, y)];
  return tile !== TILE.WALL;
}

function carveDungeon() {
  const tiles = new Array(WIDTH * HEIGHT).fill(TILE.WALL);
  let x = Math.floor(WIDTH / 2);
  let y = Math.floor(HEIGHT / 2);
  const maxSteps = WIDTH * HEIGHT * 5;

  for (let step = 0; step < maxSteps; step++) {
    tiles[idx(x, y)] = TILE.FLOOR;
    const dir = randomOf(DIRS);
    x = clamp(x + dir.x, 1, WIDTH - 2);
    y = clamp(y + dir.y, 1, HEIGHT - 2);
  }

  return tiles;
}

function findFloorTiles(tiles) {
  const floors = [];
  for (let y = 0; y < HEIGHT; y++) {
    for (let x = 0; x < WIDTH; x++) {
      if (tiles[idx(x, y)] === TILE.FLOOR) {
        floors.push({ x, y });
      }
    }
  }
  return floors;
}

function bfsDistances(tiles, start) {
  const distances = new Map();
  const queue = [start];
  distances.set(key(start.x, start.y), 0);

  while (queue.length) {
    const current = queue.shift();
    const currentKey = key(current.x, current.y);
    const dist = distances.get(currentKey);

    for (const dir of DIRS) {
      const nx = current.x + dir.x;
      const ny = current.y + dir.y;
      if (!inBounds(nx, ny) || tiles[idx(nx, ny)] === TILE.WALL) continue;
      const nextKey = key(nx, ny);
      if (!distances.has(nextKey)) {
        distances.set(nextKey, dist + 1);
        queue.push({ x: nx, y: ny });
      }
    }
  }

  return distances;
}

function placeExit(tiles, start) {
  const distances = bfsDistances(tiles, start);
  let farthest = start;
  let maxDist = 0;

  for (const [posKey, distance] of distances.entries()) {
    if (distance > maxDist) {
      const [x, y] = posKey.split(",").map(Number);
      farthest = { x, y };
      maxDist = distance;
    }
  }

  return farthest;
}

function placeItems(tiles, excludeKeys) {
  const floors = findFloorTiles(tiles).filter(({ x, y }) => !excludeKeys.has(key(x, y)));
  const items = new Map();
  const crystals = randomInt(MAX_CRYSTALS - 2, MAX_CRYSTALS);
  const hearts = randomInt(Math.max(1, MAX_HEARTS - 2), MAX_HEARTS);

  for (let i = 0; i < crystals && floors.length; i++) {
    const index = Math.floor(Math.random() * floors.length);
    const spot = floors.splice(index, 1)[0];
    items.set(key(spot.x, spot.y), { type: "crystal", glyph: TILE.CRYSTAL, value: 1 });
  }

  for (let i = 0; i < hearts && floors.length; i++) {
    const index = Math.floor(Math.random() * floors.length);
    const spot = floors.splice(index, 1)[0];
    items.set(key(spot.x, spot.y), { type: "heart", glyph: TILE.HEART, value: 2 });
  }

  return items;
}

function placeEnemies(tiles, excludeKeys) {
  const floors = findFloorTiles(tiles).filter(({ x, y }) => !excludeKeys.has(key(x, y)));
  const enemies = [];
  const count = randomInt(MAX_ENEMIES - 2, MAX_ENEMIES);

  for (let i = 0; i < count && floors.length; i++) {
    const spotIndex = Math.floor(Math.random() * floors.length);
    const spot = floors.splice(spotIndex, 1)[0];
    const template = randomOf(ENEMY_TYPES);
    enemies.push({
      id: `${template.name}-${i}-${Date.now()}`,
      name: template.name,
      glyph: template.glyph,
      hp: template.hp,
      damage: template.damage,
      x: spot.x,
      y: spot.y,
    });
  }

  return enemies;
}

function newGame() {
  state.tiles = carveDungeon();
  const floors = findFloorTiles(state.tiles);
  const start = floors[Math.floor(Math.random() * floors.length)] ?? {
    x: Math.floor(WIDTH / 2),
    y: Math.floor(HEIGHT / 2),
  };

  state.player = {
    x: start.x,
    y: start.y,
    hp: 8,
    maxHp: 8,
    crystals: 0,
    score: 0,
  };

  state.exit = placeExit(state.tiles, start);
  state.tiles[idx(state.exit.x, state.exit.y)] = TILE.EXIT;

  const occupied = new Set([key(start.x, start.y), key(state.exit.x, state.exit.y)]);
  state.items = placeItems(state.tiles, occupied);
  for (const posKey of state.items.keys()) {
    occupied.add(posKey);
  }

  state.enemies = placeEnemies(state.tiles, occupied);
  state.visible = new Set();
  state.seen = new Set();
  state.status = "playing";
  state.message = "Explore the dungeon!";
  computeVisibility();
  render();
}

function computeVisibility() {
  state.visible.clear();
  const radius = 7;
  for (let y = state.player.y - radius; y <= state.player.y + radius; y++) {
    for (let x = state.player.x - radius; x <= state.player.x + radius; x++) {
      if (!inBounds(x, y)) continue;
      if (Math.hypot(x - state.player.x, y - state.player.y) > radius) continue;
      if (hasLineOfSight(state.player.x, state.player.y, x, y)) {
        const positionKey = key(x, y);
        state.visible.add(positionKey);
        state.seen.add(positionKey);
      }
    }
  }
}

function hasLineOfSight(x0, y0, x1, y1) {
  let dx = Math.abs(x1 - x0);
  let sx = x0 < x1 ? 1 : -1;
  let dy = -Math.abs(y1 - y0);
  let sy = y0 < y1 ? 1 : -1;
  let err = dx + dy;

  while (true) {
    if (!inBounds(x0, y0)) return false;
    if (state.tiles[idx(x0, y0)] === TILE.WALL && !(x0 === x1 && y0 === y1)) return false;
    if (x0 === x1 && y0 === y1) return true;
    const e2 = 2 * err;
    if (e2 >= dy) {
      err += dy;
      x0 += sx;
    }
    if (e2 <= dx) {
      err += dx;
      y0 += sy;
    }
  }
}

function enemyAt(x, y) {
  return state.enemies.find((enemy) => enemy.x === x && enemy.y === y);
}

function removeEnemy(enemy) {
  state.enemies = state.enemies.filter((e) => e !== enemy);
}

function itemAt(x, y) {
  return state.items.get(key(x, y));
}

function removeItem(x, y) {
  state.items.delete(key(x, y));
}

function movePlayer(dx, dy) {
  if (state.status !== "playing") return;

  const nx = state.player.x + dx;
  const ny = state.player.y + dy;
  if (!inBounds(nx, ny)) return;

  const tile = state.tiles[idx(nx, ny)];
  if (tile === TILE.WALL) {
    state.message = "A wall blocks your path.";
    render();
    return;
  }

  const foe = enemyAt(nx, ny);
  if (foe) {
    attackEnemy(foe);
    return;
  }

  state.player.x = nx;
  state.player.y = ny;
  state.player.score += 1;

  const item = itemAt(nx, ny);
  if (item) {
    if (item.type === "crystal") {
      state.player.crystals += item.value;
      state.player.score += 10;
      state.message = "You pocket a shimmering crystal!";
    } else if (item.type === "heart") {
      const healed = Math.min(state.player.maxHp - state.player.hp, item.value);
      state.player.hp += healed;
      state.message = healed
        ? "You feel reinvigorated."
        : "You are already at full health.";
    }
    removeItem(nx, ny);
  } else {
    state.message = "";
  }

  if (nx === state.exit.x && ny === state.exit.y) {
    state.status = "won";
    state.message = `You escape with ${state.player.crystals} crystals!`;
  }

  computeVisibility();
  if (state.status === "playing") {
    enemyTurn();
  }
  render();
}

function waitTurn() {
  if (state.status !== "playing") return;
  state.message = "You catch your breath.";
  enemyTurn();
  render();
}

function attackEnemy(enemy) {
  enemy.hp -= 2;
  state.message = `You strike the ${enemy.name.toLowerCase()}!`;
  state.player.score += 5;
  if (enemy.hp <= 0) {
    state.message = `The ${enemy.name.toLowerCase()} falls!`;
    removeEnemy(enemy);
  }
  enemyTurn();
  render();
}

function enemyTurn() {
  for (const enemy of [...state.enemies]) {
    if (Math.abs(enemy.x - state.player.x) + Math.abs(enemy.y - state.player.y) === 1) {
      state.player.hp -= enemy.damage;
      state.message = `The ${enemy.name.toLowerCase()} hits you!`;
      if (state.player.hp <= 0) {
        state.status = "lost";
        state.message = "You were defeated in the dark.";
      }
      continue;
    }

    const { x: stepX, y: stepY } = chaseStep(enemy);
    const nx = enemy.x + stepX;
    const ny = enemy.y + stepY;

    if (!inBounds(nx, ny)) continue;
    if (!isWalkable(nx, ny)) continue;
    if (enemyAt(nx, ny)) continue;
    if (nx === state.player.x && ny === state.player.y) continue;

    enemy.x = nx;
    enemy.y = ny;
  }
  computeVisibility();
}

function chaseStep(enemy) {
  const dx = state.player.x - enemy.x;
  const dy = state.player.y - enemy.y;
  let stepX = 0;
  let stepY = 0;

  if (Math.abs(dx) > Math.abs(dy)) {
    stepX = Math.sign(dx);
  } else if (dy !== 0) {
    stepY = Math.sign(dy);
  }

  const primary = { x: stepX, y: stepY };
  const options = [primary, { x: 0, y: Math.sign(dy) }, { x: Math.sign(dx), y: 0 }, { x: 0, y: 0 }];

  for (const option of options) {
    const nx = enemy.x + option.x;
    const ny = enemy.y + option.y;
    if (!inBounds(nx, ny)) continue;
    if (!isWalkable(nx, ny)) continue;
    if (enemyAt(nx, ny)) continue;
    if (nx === state.player.x && ny === state.player.y) continue;
    return option;
  }

  return { x: 0, y: 0 };
}

function render() {
  const rows = [];
  for (let y = 0; y < HEIGHT; y++) {
    const chars = [];
    for (let x = 0; x < WIDTH; x++) {
      const positionKey = key(x, y);
      const isVisible = state.visible.has(positionKey);
      const isSeen = state.seen.has(positionKey);

      if (!isVisible && !isSeen) {
        chars.push(`<span class="tile tile-fog">·</span>`);
        continue;
      }

      let glyph = state.tiles[idx(x, y)];
      let tileClass = "tile-floor";

      if (glyph === TILE.WALL) tileClass = "tile-wall";
      if (glyph === TILE.EXIT) tileClass = "tile-exit";
      if (glyph === TILE.FLOOR) tileClass = "tile-floor";

      const item = itemAt(x, y);
      const enemy = enemyAt(x, y);
      let content = glyph;
      let extraClass = "";

      if (state.exit.x === x && state.exit.y === y) {
        glyph = TILE.EXIT;
        tileClass = "tile-exit";
        content = glyph;
      }

      if (item) {
        content = item.glyph;
        tileClass = item.type === "crystal" ? "tile-crystal" : "tile-heart";
      }

      if (enemy) {
        content = enemy.glyph;
        tileClass = "tile-enemy";
      }

      if (state.player.x === x && state.player.y === y) {
        content = "@";
        tileClass = "tile-player";
      }

      const hidden = !isVisible ? " tile-fog" : "";
      chars.push(`<span class="tile ${tileClass}${hidden}">${content}</span>`);
    }
    rows.push(chars.join(""));
  }

  mapEl.innerHTML = rows.join("\n");
  updateHud();
}

function updateHud() {
  statsEl.innerHTML = `HP: ${state.player.hp}/${state.player.maxHp} · Crystals: ${state.player.crystals} · Score: ${state.player.score}`;
  messageEl.textContent = state.message;

  if (state.status === "won") {
    messageEl.textContent += " Tap New Dungeon to delve again.";
  } else if (state.status === "lost") {
    messageEl.textContent += " Tap New Dungeon to retry.";
  }
}

function handleDirection(direction) {
  switch (direction) {
    case "up":
      movePlayer(0, -1);
      break;
    case "down":
      movePlayer(0, 1);
      break;
    case "left":
      movePlayer(-1, 0);
      break;
    case "right":
      movePlayer(1, 0);
      break;
    case "wait":
      waitTurn();
      break;
    default:
      break;
  }
}

function bindControls() {
  controlButtons.forEach((button) => {
    button.addEventListener("click", (event) => {
      const direction = event.currentTarget.dataset.dir;
      handleDirection(direction);
    });
  });

  newGameButton.addEventListener("click", () => {
    newGame();
  });

  window.addEventListener("keydown", (event) => {
    const keyMap = {
      ArrowUp: "up",
      ArrowDown: "down",
      ArrowLeft: "left",
      ArrowRight: "right",
      w: "up",
      s: "down",
      a: "left",
      d: "right",
      ".": "wait",
      Space: "wait",
    };
    const dir = keyMap[event.key];
    if (dir) {
      event.preventDefault();
      handleDirection(dir);
    }
  });

  mapEl.addEventListener("click", (event) => {
    const rect = mapEl.getBoundingClientRect();
    const relativeX = event.clientX - rect.left;
    const relativeY = event.clientY - rect.top;
    const tileWidth = rect.width / WIDTH;
    const tileHeight = rect.height / HEIGHT;
    const targetX = Math.floor(relativeX / tileWidth);
    const targetY = Math.floor(relativeY / tileHeight);

    const dx = targetX - state.player.x;
    const dy = targetY - state.player.y;

    if (Math.abs(dx) > Math.abs(dy)) {
      handleDirection(dx > 0 ? "right" : "left");
    } else if (Math.abs(dy) > 0) {
      handleDirection(dy > 0 ? "down" : "up");
    }
  });
}

bindControls();
newGame();
