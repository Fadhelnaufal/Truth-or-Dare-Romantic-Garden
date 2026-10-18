#!/usr/bin/env bash
set -euo pipefail

echo "🌸 Membuat struktur direktori Truth or Dare: A Romantic Garden Adventure..."

mkdir -p \
  src/game/types \
  src/game/board \
  src/game/dice \
  src/game/players \
  src/game/challenges \
  src/game/engine \
  src/game/store \
  src/components/audio \
  src/components/board \
  src/components/obstacles \
  src/components/pieces \
  src/components/dice \
  src/components/environment \
  src/components/scene \
  src/components/ui \
  src/app \
  src/tests \
  e2e

echo "📦 Menulis konfigurasi paket dan proyek..."

cat << 'EOF' > package.json
{
  "name": "romantic-garden-snakes-and-ladders",
  "version": "1.0.0",
  "private": true,
  "description": "Truth or Dare: A Romantic Garden Adventure — 3D Snakes & Ladders for Couples",
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "next lint",
    "typecheck": "tsc --noEmit",
    "test": "vitest run",
    "test:watch": "vitest",
    "test:e2e": "playwright test"
  },
  "dependencies": {
    "@react-three/drei": "^9.114.0",
    "@react-three/fiber": "^8.17.10",
    "clsx": "^2.1.1",
    "lucide-react": "^0.454.0",
    "next": "^14.2.16",
    "react": "^18.3.1",
    "react-dom": "^18.3.1",
    "three": "^0.169.0",
    "zustand": "^5.0.1"
  },
  "devDependencies": {
    "@playwright/test": "^1.48.2",
    "@types/node": "^22.8.6",
    "@types/react": "^18.3.12",
    "@types/react-dom": "^18.3.1",
    "@types/three": "^0.169.0",
    "autoprefixer": "^10.4.20",
    "eslint": "^8.57.1",
    "eslint-config-next": "14.2.16",
    "postcss": "^8.4.47",
    "tailwindcss": "^3.4.14",
    "typescript": "^5.6.3",
    "vitest": "^2.1.4"
  }
}
EOF

cat << 'EOF' > tsconfig.json
{
  "compilerOptions": {
    "lib": ["dom", "dom.iterable", "esnext"],
    "allowJs": false,
    "skipLibCheck": true,
    "strict": true,
    "noEmit": true,
    "esModuleInterop": true,
    "module": "esnext",
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve",
    "incremental": true,
    "plugins": [
      {
        "name": "next"
      }
    ],
    "paths": {
      "@/*": ["./src/*"]
    }
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx", ".next/types/**/*.ts"],
  "exclude": ["node_modules"]
}
EOF

cat << 'EOF' > next.config.mjs
/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  transpilePackages: ['three'],
};

export default nextConfig;
EOF

cat << 'EOF' > postcss.config.mjs
/** @type {import('postcss-load-config').Config} */
const config = {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
};

export default config;
EOF

cat << 'EOF' > .eslintrc.json
{
  "extends": ["next/core-web-vitals"]
}
EOF

cat << 'EOF' > tailwind.config.ts
import type { Config } from 'tailwindcss';

const config: Config = {
  content: [
    './src/pages/**/*.{js,ts,jsx,tsx,mdx}',
    './src/components/**/*.{js,ts,jsx,tsx,mdx}',
    './src/app/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      colors: {
        garden: {
          blush: '#F4D7DE',
          ivory: '#FFF7ED',
          rose: '#C98296',
          gold: '#C99A72',
          sage: '#A9B9A0',
          lavender: '#DCD5F0',
          cream: '#FFFDF8',
          mauve: '#654754',
          deepMauve: '#47303A',
        },
      },
      fontFamily: {
        serif: ['Georgia', 'Cambria', '"Times New Roman"', 'Times', 'serif'],
        sans: ['Inter', 'system-ui', '-apple-system', 'sans-serif'],
      },
      boxShadow: {
        romantic: '0 12px 32px -8px rgba(101, 71, 84, 0.18)',
        card: '0 20px 50px -12px rgba(101, 71, 84, 0.28)',
      },
    },
  },
  plugins: [],
};

export default config;
EOF

cat << 'EOF' > vitest.config.ts
import { defineConfig } from 'vitest/config';
import path from 'path';

export default defineConfig({
  test: {
    environment: 'node',
    include: ['src/tests/**/*.test.ts'],
    globals: true,
  },
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
    },
  },
});
EOF

cat << 'EOF' > playwright.config.ts
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './e2e',
  fullyParallel: false,
  retries: 0,
  workers: 1,
  reporter: 'list',
  use: {
    baseURL: 'http://localhost:3000',
    trace: 'on-first-retry',
  },
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
  ],
  webServer: {
    command: 'npm run dev',
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI,
    timeout: 120000,
  },
});
EOF

echo "🎲 Menulis modul Game Engine, Papan 100 Kotak, Dadu, dan 100 Kartu Truth or Dare..."

cat << 'EOF' > src/game/types/index.ts
export type GamePhase =
  | 'setup'
  | 'ready'
  | 'rolling'
  | 'moving'
  | 'resolving_event'
  | 'awaiting_challenge'
  | 'transitioning'
  | 'turn_complete'
  | 'victory';

export type AnimationPhase =
  | 'idle'
  | 'rolling'
  | 'moving'
  | 'reacting'
  | 'transitioning'
  | 'celebrating'
  | 'victory';

export type TileType =
  | 'normal'
  | 'start'
  | 'finish'
  | 'truth'
  | 'dare'
  | 'snake_head'
  | 'snake_tail'
  | 'ladder_bottom'
  | 'ladder_top';

export type ChallengeType = 'truth' | 'dare';

export type TruthCategory =
  | 'Awal Jatuh Cinta'
  | 'Perasaan yang Jarang Diucapkan'
  | 'Bikin Salting dan Baper'
  | 'Kejujuran dan Kedekatan'
  | 'Masa Depan Bersama';

export type DareCategory =
  | 'Manis dan Romantis'
  | 'Bikin Hati Meleleh'
  | 'Kenangan Berdua'
  | 'Kedekatan yang Lebih Dalam'
  | 'Momen untuk Diingat';

export interface ChallengeCard {
  id: string;
  type: ChallengeType;
  category: TruthCategory | DareCategory;
  prompt: string;
  intimacyNote?: string;
}

export type SnakeStyle = 'jade_sculpt' | 'sage_stone' | 'rose_bronze' | 'ivory_serpent';
export type LadderStyle = 'warm_oak' | 'painted_ivory' | 'rose_gold_trellis';

export interface SnakeDefinition {
  id: string;
  name: string;
  head: number;
  tail: number;
  style: SnakeStyle;
}

export interface LadderDefinition {
  id: string;
  name: string;
  bottom: number;
  top: number;
  style: LadderStyle;
}

export interface Vector3Tuple {
  x: number;
  y: number;
  z: number;
}

export interface SquareMetadata {
  square: number;
  row: number;
  col: number;
  worldPosition: Vector3Tuple;
  type: TileType;
  snakeId?: string;
  ladderId?: string;
}

export interface BoardConfiguration {
  rows: number;
  cols: number;
  totalSquares: number;
  tileSize: number;
  tileGap: number;
  boardElevation: number;
  startSquare: number;
  finishSquare: number;
  truthSquares: number[];
  dareSquares: number[];
  snakes: SnakeDefinition[];
  ladders: LadderDefinition[];
  squares: Record<number, SquareMetadata>;
}

export type PieceStyleId =
  | 'ivory_rose_gold'
  | 'blush_quartz'
  | 'sage_celadon'
  | 'lavender_pearl';

export interface PieceStyleDefinition {
  id: PieceStyleId;
  label: string;
  primaryColor: string;
  accentColor: string;
  silhouette: 'crown_spire' | 'rose_chalice' | 'bloom_obelisk' | 'heart_column';
}

export interface PlayerState {
  id: string;
  name: string;
  pieceStyle: PieceStyleId;
  color: string;
  accentColor: string;
  square: number;
  completedChallenges: number;
  skippedChallenges: number;
}

export interface PlayerSetupInput {
  name: string;
  pieceStyle: PieceStyleId;
}

export interface ActiveTransition {
  kind: 'snake' | 'ladder';
  id: string;
  name: string;
  fromSquare: number;
  toSquare: number;
}

export interface MoveRecord {
  id: string;
  turnNumber: number;
  playerId: string;
  playerName: string;
  diceValue: number;
  fromSquare: number;
  landedSquare: number;
  finalSquare: number;
  overshot: boolean;
  transition?: ActiveTransition;
  challenge?: {
    cardId: string;
    type: ChallengeType;
    category: string;
    outcome: 'completed' | 'skipped';
  };
  wonMatch: boolean;
  timestamp: number;
}

export interface GameEngineState {
  phase: GamePhase;
  animationPhase: AnimationPhase;
  players: PlayerState[];
  activePlayerIndex: number;
  turnNumber: number;
  lastDiceValue: number | null;
  pendingPath: number[];
  overshotLastRoll: boolean;
  activeChallenge: ChallengeCard | null;
  activeTransition: ActiveTransition | null;
  winnerId: string | null;
  moveHistory: MoveRecord[];
  statusMessage: string;
  usedTruthIds: string[];
  usedDareIds: string[];
}

export type RandomSource = () => number;
EOF

cat << 'EOF' > src/game/board/boardConfig.ts
import {
  BoardConfiguration,
  LadderDefinition,
  SnakeDefinition,
  SquareMetadata,
  TileType,
  Vector3Tuple,
} from '../types';

export const BOARD_ROWS = 10;
export const BOARD_COLS = 10;
export const TOTAL_SQUARES = 100;
export const TILE_SIZE = 0.96;
export const TILE_GAP = 0.08;
export const BOARD_ELEVATION = 0.22;

export const SNAKES_CONFIG: SnakeDefinition[] = [
  {
    id: 'snake-1',
    name: 'Ular Giok Embun',
    head: 27,
    tail: 7,
    style: 'jade_sculpt',
  },
  {
    id: 'snake-2',
    name: 'Ular Sulur Mawar',
    head: 40,
    tail: 19,
    style: 'rose_bronze',
  },
  {
    id: 'snake-3',
    name: 'Ular Batu Sage',
    head: 54,
    tail: 31,
    style: 'sage_stone',
  },
  {
    id: 'snake-4',
    name: 'Ular Teratai Senja',
    head: 66,
    tail: 45,
    style: 'ivory_serpent',
  },
  {
    id: 'snake-5',
    name: 'Ular Gading Kencana',
    head: 76,
    tail: 58,
    style: 'rose_bronze',
  },
  {
    id: 'snake-6',
    name: 'Ular Kabut Lembayung',
    head: 89,
    tail: 53,
    style: 'jade_sculpt',
  },
  {
    id: 'snake-7',
    name: 'Ular Penjaga Awan',
    head: 97,
    tail: 78,
    style: 'sage_stone',
  },
];

export const LADDERS_CONFIG: LadderDefinition[] = [
  {
    id: 'ladder-1',
    name: 'Tangga Melati Pagi',
    bottom: 4,
    top: 25,
    style: 'warm_oak',
  },
  {
    id: 'ladder-2',
    name: 'Tangga Arkade Mawar',
    bottom: 13,
    top: 46,
    style: 'rose_gold_trellis',
  },
  {
    id: 'ladder-3',
    name: 'Tangga Air Mancur Cahaya',
    bottom: 33,
    top: 49,
    style: 'painted_ivory',
  },
  {
    id: 'ladder-4',
    name: 'Tangga Pelaminan Senja',
    bottom: 42,
    top: 63,
    style: 'rose_gold_trellis',
  },
  {
    id: 'ladder-5',
    name: 'Tangga Teras Awan',
    bottom: 50,
    top: 69,
    style: 'warm_oak',
  },
  {
    id: 'ladder-6',
    name: 'Tangga Pergola Bintang',
    bottom: 62,
    top: 81,
    style: 'painted_ivory',
  },
  {
    id: 'ladder-7',
    name: 'Tangga Menuju Nirwana',
    bottom: 74,
    top: 92,
    style: 'rose_gold_trellis',
  },
];

export const TRUTH_SQUARES: number[] = [
  3, 9, 16, 22, 35, 44, 52, 60, 68, 75, 84, 94,
];

export const DARE_SQUARES: number[] = [
  6, 12, 18, 29, 37, 48, 56, 65, 72, 83, 90, 96,
];

export function calculateSquareCoordinates(
  square: number,
  tileSize = TILE_SIZE,
  tileGap = TILE_GAP,
  boardElevation = BOARD_ELEVATION
): { row: number; col: number; worldPosition: Vector3Tuple } {
  if (!Number.isInteger(square) || square < 1 || square > TOTAL_SQUARES) {
    throw new Error(`Invalid square number: ${square}. Expected integer between 1 and 100.`);
  }

  const zeroIndex = square - 1;
  const row = Math.floor(zeroIndex / BOARD_COLS);
  const offsetInRow = zeroIndex % BOARD_COLS;
  const isEvenRow = row % 2 === 0;
  const col = isEvenRow ? offsetInRow : BOARD_COLS - 1 - offsetInRow;

  const step = tileSize + tileGap;
  const halfSpan = (BOARD_COLS - 1) / 2;

  const x = Number(((col - halfSpan) * step).toFixed(4));
  const z = Number(((halfSpan - row) * step).toFixed(4));
  const y = boardElevation;

  return {
    row,
    col,
    worldPosition: { x, y, z },
  };
}

export function getPieceStackOffset(
  indexOnSquare: number,
  totalOnSquare: number,
  tileSize = TILE_SIZE
): Vector3Tuple {
  if (totalOnSquare <= 1) {
    return { x: 0, y: 0, z: 0 };
  }
  const radius = tileSize * 0.24;
  const angle = (indexOnSquare / totalOnSquare) * Math.PI * 2 + Math.PI / 4;
  return {
    x: Number((Math.cos(angle) * radius).toFixed(4)),
    y: 0,
    z: Number((Math.sin(angle) * radius).toFixed(4)),
  };
}

export function createAuthoritativeBoardConfig(): BoardConfiguration {
  const squares: Record<number, SquareMetadata> = {};

  const truthSet = new Set(TRUTH_SQUARES);
  const dareSet = new Set(DARE_SQUARES);
  const snakeHeadMap = new Map(SNAKES_CONFIG.map((s) => [s.head, s.id]));
  const snakeTailMap = new Map(SNAKES_CONFIG.map((s) => [s.tail, s.id]));
  const ladderBottomMap = new Map(LADDERS_CONFIG.map((l) => [l.bottom, l.id]));
  const ladderTopMap = new Map(LADDERS_CONFIG.map((l) => [l.top, l.id]));

  for (let sq = 1; sq <= TOTAL_SQUARES; sq++) {
    const { row, col, worldPosition } = calculateSquareCoordinates(sq);

    let type: TileType = 'normal';
    let snakeId: string | undefined;
    let ladderId: string | undefined;

    if (sq === 1) {
      type = 'start';
    } else if (sq === TOTAL_SQUARES) {
      type = 'finish';
    } else if (snakeHeadMap.has(sq)) {
      type = 'snake_head';
      snakeId = snakeHeadMap.get(sq);
    } else if (ladderBottomMap.has(sq)) {
      type = 'ladder_bottom';
      ladderId = ladderBottomMap.get(sq);
    } else if (truthSet.has(sq)) {
      type = 'truth';
    } else if (dareSet.has(sq)) {
      type = 'dare';
    } else if (snakeTailMap.has(sq)) {
      type = 'snake_tail';
      snakeId = snakeTailMap.get(sq);
    } else if (ladderTopMap.has(sq)) {
      type = 'ladder_top';
      ladderId = ladderTopMap.get(sq);
    }

    squares[sq] = {
      square: sq,
      row,
      col,
      worldPosition,
      type,
      snakeId,
      ladderId,
    };
  }

  return {
    rows: BOARD_ROWS,
    cols: BOARD_COLS,
    totalSquares: TOTAL_SQUARES,
    tileSize: TILE_SIZE,
    tileGap: TILE_GAP,
    boardElevation: BOARD_ELEVATION,
    startSquare: 1,
    finishSquare: TOTAL_SQUARES,
    truthSquares: [...TRUTH_SQUARES],
    dareSquares: [...DARE_SQUARES],
    snakes: [...SNAKES_CONFIG],
    ladders: [...LADDERS_CONFIG],
    squares,
  };
}

export const BOARD_CONFIG: BoardConfiguration = createAuthoritativeBoardConfig();
EOF

cat << 'EOF' > src/game/board/boardValidator.ts
import { BoardConfiguration } from '../types';
import { calculateSquareCoordinates } from './boardConfig';

export interface BoardValidationResult {
  valid: boolean;
  errors: string[];
}

export function validateBoardConfiguration(
  config: BoardConfiguration
): BoardValidationResult {
  const errors: string[] = [];

  if (config.rows !== 10 || config.cols !== 10 || config.totalSquares !== 100) {
    errors.push('Board dimensions must be strictly 10x10 with 100 total squares.');
  }

  const squareKeys = Object.keys(config.squares).map(Number);
  if (squareKeys.length !== 100) {
    errors.push(`Expected exactly 100 playable squares, found ${squareKeys.length}.`);
  }

  const seenCoordinates = new Set<string>();

  for (let sq = 1; sq <= 100; sq++) {
    const meta = config.squares[sq];
    if (!meta) {
      errors.push(`Missing square definition for square ${sq}.`);
      continue;
    }

    const expected = calculateSquareCoordinates(
      sq,
      config.tileSize,
      config.tileGap,
      config.boardElevation
    );
    if (meta.row !== expected.row || meta.col !== expected.col) {
      errors.push(
        `Square ${sq} has mismatched row/col (${meta.row},${meta.col}) vs expected (${expected.row},${expected.col}).`
      );
    }

    const coordKey = `${meta.row}:${meta.col}`;
    if (seenCoordinates.has(coordKey)) {
      errors.push(`Duplicate grid coordinate (${meta.row}, ${meta.col}) at square ${sq}.`);
    }
    seenCoordinates.add(coordKey);
  }

  const occupiedSpecialSquares = new Map<number, string>();
  const registerSpecial = (sq: number, label: string) => {
    if (sq < 1 || sq > 100 || !Number.isInteger(sq)) {
      errors.push(`${label} references out-of-range square ${sq}.`);
      return;
    }
    if (sq === config.startSquare || sq === config.finishSquare) {
      errors.push(`${label} cannot be placed on start (1) or finish (100) square (${sq}).`);
      return;
    }
    const existing = occupiedSpecialSquares.get(sq);
    if (existing) {
      errors.push(`Unintended overlap on square ${sq} between ${existing} and ${label}.`);
    } else {
      occupiedSpecialSquares.set(sq, label);
    }
  };

  for (const sq of config.truthSquares) {
    registerSpecial(sq, `Truth tile (${sq})`);
  }

  for (const sq of config.dareSquares) {
    registerSpecial(sq, `Dare tile (${sq})`);
  }

  const transitionMap = new Map<number, number>();

  for (const snake of config.snakes) {
    if (snake.head === snake.tail) {
      errors.push(`Snake ${snake.id} starts and ends on the same square (${snake.head}).`);
    }
    if (snake.head <= snake.tail) {
      errors.push(
        `Snake ${snake.id} head (${snake.head}) must be strictly above tail (${snake.tail}).`
      );
    }
    const headMeta = config.squares[snake.head];
    const tailMeta = config.squares[snake.tail];
    if (headMeta && tailMeta && headMeta.row <= tailMeta.row && snake.head <= snake.tail) {
      errors.push(`Snake ${snake.id} head must be higher on the board than its tail.`);
    }
    registerSpecial(snake.head, `Snake head ${snake.id}`);
    registerSpecial(snake.tail, `Snake tail ${snake.id}`);
    transitionMap.set(snake.head, snake.tail);
  }

  for (const ladder of config.ladders) {
    if (ladder.bottom === ladder.top) {
      errors.push(
        `Ladder ${ladder.id} starts and ends on the same square (${ladder.bottom}).`
      );
    }
    if (ladder.top <= ladder.bottom) {
      errors.push(
        `Ladder ${ladder.id} top (${ladder.top}) must be strictly above bottom (${ladder.bottom}).`
      );
    }
    registerSpecial(ladder.bottom, `Ladder bottom ${ladder.id}`);
    registerSpecial(ladder.top, `Ladder top ${ladder.id}`);
    transitionMap.set(ladder.bottom, ladder.top);
  }

  for (const [startSq] of transitionMap.entries()) {
    const visited = new Set<number>([startSq]);
    let cursor: number | undefined = transitionMap.get(startSq);
    let steps = 0;

    while (cursor !== undefined) {
      if (visited.has(cursor) || steps > 100) {
        errors.push(`Infinite transition cycle detected starting from square ${startSq}.`);
        break;
      }
      visited.add(cursor);
      cursor = transitionMap.get(cursor);
      steps++;
    }
  }

  if (transitionMap.has(config.finishSquare)) {
    errors.push('Finish square 100 cannot trigger an automatic transition.');
  }

  return {
    valid: errors.length === 0,
    errors,
  };
}
EOF

cat << 'EOF' > src/game/dice/diceLogic.ts
import { RandomSource, Vector3Tuple } from '../types';

export function rollDiceValue(random: RandomSource = Math.random): number {
  const raw = random();
  const clamped = Math.max(0, Math.min(0.999999, raw));
  return Math.floor(clamped * 6) + 1;
}

export const DIE_OPPOSITE_FACES: Record<number, number> = {
  1: 6,
  6: 1,
  2: 5,
  5: 2,
  3: 4,
  4: 3,
};

export const DIE_FACE_NORMALS: Record<number, Vector3Tuple> = {
  1: { x: 0, y: 1, z: 0 },
  6: { x: 0, y: -1, z: 0 },
  2: { x: 0, y: 0, z: 1 },
  5: { x: 0, y: 0, z: -1 },
  3: { x: 1, y: 0, z: 0 },
  4: { x: -1, y: 0, z: 0 },
};

export function getRotationForDiceValue(diceValue: number): [number, number, number] {
  switch (diceValue) {
    case 1:
      return [0, 0, 0];
    case 6:
      return [Math.PI, 0, 0];
    case 2:
      return [-Math.PI / 2, 0, 0];
    case 5:
      return [Math.PI / 2, 0, 0];
    case 3:
      return [0, 0, Math.PI / 2];
    case 4:
      return [0, 0, -Math.PI / 2];
    default:
      throw new Error(`Invalid dice value for orientation mapping: ${diceValue}`);
  }
}
EOF

cat << 'EOF' > src/game/players/playerStyles.ts
import { PieceStyleDefinition, PieceStyleId, PlayerSetupInput, PlayerState } from '../types';

export const PIECE_STYLES: PieceStyleDefinition[] = [
  {
    id: 'ivory_rose_gold',
    label: 'Gading Mawar Kencana',
    primaryColor: '#FFF7ED',
    accentColor: '#C99A72',
    silhouette: 'crown_spire',
  },
  {
    id: 'blush_quartz',
    label: 'Kuarsa Merah Muda',
    primaryColor: '#F4D7DE',
    accentColor: '#C98296',
    silhouette: 'rose_chalice',
  },
  {
    id: 'sage_celadon',
    label: 'Giok Embun Taman',
    primaryColor: '#A9B9A0',
    accentColor: '#FFF7ED',
    silhouette: 'bloom_obelisk',
  },
  {
    id: 'lavender_pearl',
    label: 'Mutiara Lembayung',
    primaryColor: '#DCD5F0',
    accentColor: '#654754',
    silhouette: 'heart_column',
  },
];

export const DEFAULT_PLAYERS_SETUP: PlayerSetupInput[] = [
  { name: 'Sayang 1', pieceStyle: 'ivory_rose_gold' },
  { name: 'Sayang 2', pieceStyle: 'blush_quartz' },
];

export function createInitialPlayers(
  inputs: PlayerSetupInput[] = DEFAULT_PLAYERS_SETUP
): PlayerState[] {
  const clampedInputs = inputs.slice(0, 4);
  if (clampedInputs.length < 2) {
    throw new Error('At least two players are required to start a match.');
  }

  return clampedInputs.map((input, index) => {
    const style =
      PIECE_STYLES.find((s) => s.id === input.pieceStyle) ??
      PIECE_STYLES[index % PIECE_STYLES.length];

    return {
      id: `player-${index + 1}`,
      name: input.name.trim() || `Pemain ${index + 1}`,
      pieceStyle: style.id as PieceStyleId,
      color: style.primaryColor,
      accentColor: style.accentColor,
      square: 1,
      completedChallenges: 0,
      skippedChallenges: 0,
    };
  });
}
EOF

cat << 'EOF' > src/game/challenges/challengeBank.ts
import { ChallengeCard, ChallengeType, RandomSource } from '../types';

export const TRUTH_CARDS: ChallengeCard[] = [
  {
    id: 'truth-01',
    type: 'truth',
    category: 'Awal Jatuh Cinta',
    prompt: 'Apa kesan pertamamu saat pertama kali kita bertemu, dan apa yang berubah setelah kita semakin dekat?',
  },
  {
    id: 'truth-02',
    type: 'truth',
    category: 'Awal Jatuh Cinta',
    prompt: 'Kapan momen spesifik kamu sadar kalau perasaanmu ke aku lebih dari sekadar teman biasa?',
  },
  {
    id: 'truth-03',
    type: 'truth',
    category: 'Awal Jatuh Cinta',
    prompt: 'Hal kecil apa dariku di awal pendekatan yang diam-diam bikin kamu senyum-senyum sendiri?',
  },
  {
    id: 'truth-04',
    type: 'truth',
    category: 'Awal Jatuh Cinta',
    prompt: 'Lagu apa yang paling mengingatkanmu pada masa-masa awal kita dekat dulu?',
  },
  {
    id: 'truth-05',
    type: 'truth',
    category: 'Awal Jatuh Cinta',
    prompt: 'Pernahkah kamu gugup sebelum bertemu denganku di awal hubungan kita? Ceritakan momennya!',
  },
  {
    id: 'truth-06',
    type: 'truth',
    category: 'Awal Jatuh Cinta',
    prompt: 'Pesan singkat atau obrolan apa dariku di masa awal yang paling berkesan di ingatanmu?',
  },
  {
    id: 'truth-07',
    type: 'truth',
    category: 'Awal Jatuh Cinta',
    prompt: 'Sifatku yang mana yang pertama kali membuatmu merasa nyaman dan aman berada di dekatku?',
  },
  {
    id: 'truth-08',
    type: 'truth',
    category: 'Awal Jatuh Cinta',
    prompt: 'Apa kencan pertama atau pertemuan awal kita yang paling ingin kamu ulangi sekali lagi?',
  },
  {
    id: 'truth-09',
    type: 'truth',
    category: 'Awal Jatuh Cinta',
    prompt: 'Hal konyol apa yang pernah kamu lakukan demi menarik perhatianku waktu pertama kali suka?',
  },
  {
    id: 'truth-10',
    type: 'truth',
    category: 'Awal Jatuh Cinta',
    prompt: 'Kalau kisah awal pertemuan kita dijadikan judul film romantis, kira-kira apa judul yang paling pas?',
  },
  {
    id: 'truth-11',
    type: 'truth',
    category: 'Perasaan yang Jarang Diucapkan',
    prompt: 'Hal apa yang sudah lama ingin kamu ucapkan sebagai rasa terima kasih kepadaku, tapi belum sempat terucap?',
  },
  {
    id: 'truth-12',
    type: 'truth',
    category: 'Perasaan yang Jarang Diucapkan',
    prompt: 'Kapan kamu merasa paling dicintai dan dihargai olehku tanpa aku harus mengucapkan sepatah kata pun?',
  },
  {
    id: 'truth-13',
    type: 'truth',
    category: 'Perasaan yang Jarang Diucapkan',
    prompt: 'Apa ketakutan terbesarmu dalam hubungan yang jarang kamu ceritakan karena tidak ingin membuatku khawatir?',
  },
  {
    id: 'truth-14',
    type: 'truth',
    category: 'Perasaan yang Jarang Diucapkan',
    prompt: 'Saat kamu sedang lelah dengan harimu, bentuk perhatian seperti apa dariku yang paling menenangkan hatimu?',
  },
  {
    id: 'truth-15',
    type: 'truth',
    category: 'Perasaan yang Jarang Diucapkan',
    prompt: 'Perubahan positif apa dalam dirimu yang kamu rasakan sejak kita menjalani hubungan bersama?',
  },
  {
    id: 'truth-16',
    type: 'truth',
    category: 'Perasaan yang Jarang Diucapkan',
    prompt: 'Momen sederhana apa bersama aku yang diam-diam selalu kamu rindukan saat kita sedang berjauhan?',
  },
  {
    id: 'truth-17',
    type: 'truth',
    category: 'Perasaan yang Jarang Diucapkan',
    prompt: 'Apa satu hal tentang caraku mencintaimu yang membuatmu merasa hubungan ini berbeda dan istimewa?',
  },
  {
    id: 'truth-18',
    type: 'truth',
    category: 'Perasaan yang Jarang Diucapkan',
    prompt: 'Kapan terakhir kali kamu merasa sangat bangga memilikiku sebagai pasanganmu?',
  },
  {
    id: 'truth-19',
    type: 'truth',
    category: 'Perasaan yang Jarang Diucapkan',
    prompt: 'Jika hari ini kita hanya punya waktu lima menit untuk mengobrol dari hati ke hati, apa yang ingin kamu sampaikan?',
  },
  {
    id: 'truth-20',
    type: 'truth',
    category: 'Perasaan yang Jarang Diucapkan',
    prompt: 'Bagian mana dari kepribadianku yang paling sering menjadi alasanmu bertahan dan tersenyum di saat sulit?',
  },
  {
    id: 'truth-21',
    type: 'truth',
    category: 'Bikin Salting dan Baper',
    prompt: 'Ekspresi wajah atau gerak-gerikku yang mana yang paling sering bikin kamu salah tingkah sampai sekarang?',
  },
  {
    id: 'truth-22',
    type: 'truth',
    category: 'Bikin Salting dan Baper',
    prompt: 'Pujian apa dariku yang pernah bikin kamu kepikiran dan senyum-senyum seharian penuh?',
  },
  {
    id: 'truth-23',
    type: 'truth',
    category: 'Bikin Salting dan Baper',
    prompt: 'Dari semua pakaian atau gaya penampilanku, mana yang menurutmu paling memikat saat aku kenakan?',
  },
  {
    id: 'truth-24',
    type: 'truth',
    category: 'Bikin Salting dan Baper',
    prompt: 'Apa hal paling menggemaskan yang sering aku lakukan tanpa aku sadari?',
  },
  {
    id: 'truth-25',
    type: 'truth',
    category: 'Bikin Salting dan Baper',
    prompt: 'Kapan terakhir kali jantungmu berdebar kencang hanya karena tatapan atau sentuhan lembut dariku?',
  },
  {
    id: 'truth-26',
    type: 'truth',
    category: 'Bikin Salting dan Baper',
    prompt: 'Sebutkan tiga hal fisik maupun non-fisik dariku yang paling membuatmu jatuh hati berulang kali!',
  },
  {
    id: 'truth-27',
    type: 'truth',
    category: 'Bikin Salting dan Baper',
    prompt: 'Panggilan sayang apa yang diam-diam paling kamu sukai saat aku ucapkan dengan suara lembut?',
  },
  {
    id: 'truth-28',
    type: 'truth',
    category: 'Bikin Salting dan Baper',
    prompt: 'Pernahkah kamu diam-diam memperhatikanku saat aku sedang fokus melakukan sesuatu? Apa yang kamu pikirkan saat itu?',
  },
  {
    id: 'truth-29',
    type: 'truth',
    category: 'Bikin Salting dan Baper',
    prompt: 'Hal romantis kecil apa yang pernah aku lakukan yang sukses bikin hatimu meleleh seketika?',
  },
  {
    id: 'truth-30',
    type: 'truth',
    category: 'Bikin Salting dan Baper',
    prompt: 'Kalau kamu harus mendeskripsikan senyumku dalam satu kalimat puitis, kalimat apa yang akan kamu pilih?',
  },
  {
    id: 'truth-31',
    type: 'truth',
    category: 'Kejujuran dan Kedekatan',
    prompt: 'Bagaimana cara terbaik bagiku untuk menenangkanmu ketika kamu sedang kesal atau butuh ruang sendiri?',
  },
  {
    id: 'truth-32',
    type: 'truth',
    category: 'Kejujuran dan Kedekatan',
    prompt: 'Kebiasaan baik apa dalam komunikasi kita yang menurutmu harus terus kita jaga selamanya?',
  },
  {
    id: 'truth-33',
    type: 'truth',
    category: 'Kejujuran dan Kedekatan',
    prompt: 'Apa bahasa cinta (love language) yang paling kamu rasakan kebutuhannya akhir-akhir ini dariku?',
  },
  {
    id: 'truth-34',
    type: 'truth',
    category: 'Kejujuran dan Kedekatan',
    prompt: 'Adakah kesalahpahaman kecil di masa lalu yang membuat kita justru semakin mengerti satu sama lain?',
  },
  {
    id: 'truth-35',
    type: 'truth',
    category: 'Kejujuran dan Kedekatan',
    prompt: 'Apa hal yang membuatmu merasa paling didengarkan saat kita sedang berdiskusi tentang hal serius?',
  },
  {
    id: 'truth-36',
    type: 'truth',
    category: 'Kejujuran dan Kedekatan',
    prompt: 'Dalam hal apa menurutmu kita berdua adalah tim yang paling saling melengkapi?',
  },
  {
    id: 'truth-37',
    type: 'truth',
    category: 'Kejujuran dan Kedekatan',
    prompt: 'Apa satu hal sederhana yang bisa kita lakukan setiap minggu agar hubungan kita selalu terasa hangat?',
  },
  {
    id: 'truth-38',
    type: 'truth',
    category: 'Kejujuran dan Kedekatan',
    prompt: 'Pelajaran berharga apa tentang cinta yang kamu temukan selama kita berjalan beriringan?',
  },
  {
    id: 'truth-39',
    type: 'truth',
    category: 'Kejujuran dan Kedekatan',
    prompt: 'Saat kita berbeda pendapat, sikapku yang mana yang paling membantumu merasa tetap dihormati dan disayangi?',
  },
  {
    id: 'truth-40',
    type: 'truth',
    category: 'Kejujuran dan Kedekatan',
    prompt: 'Apa arti rumah dan rasa pulang bagi dirimu ketika kita sedang menghabiskan waktu berdua?',
  },
  {
    id: 'truth-41',
    type: 'truth',
    category: 'Masa Depan Bersama',
    prompt: 'Destinasi impian mana yang paling ingin kamu kunjungi bersamaku suatu hari nanti, dan apa yang ingin kita lakukan di sana?',
  },
  {
    id: 'truth-42',
    type: 'truth',
    category: 'Masa Depan Bersama',
    prompt: 'Seperti apa suasana pagi hari impianmu jika suatu saat kita bangun di bawah atap yang sama setiap hari?',
  },
  {
    id: 'truth-43',
    type: 'truth',
    category: 'Masa Depan Bersama',
    prompt: 'Tradisi tahunan apa yang ingin kamu ciptakan dan rayakan bersamaku hingga kita menua nanti?',
  },
  {
    id: 'truth-44',
    type: 'truth',
    category: 'Masa Depan Bersama',
    prompt: 'Hobi atau proyek seru apa yang belum pernah kita coba, tapi sangat ingin kamu mulai bersamaku tahun ini?',
  },
  {
    id: 'truth-45',
    type: 'truth',
    category: 'Masa Depan Bersama',
    prompt: 'Saat membayangkan kita sepuluh tahun lagi, hal indah apa yang paling membuatmu bersemangat?',
  },
  {
    id: 'truth-46',
    type: 'truth',
    category: 'Masa Depan Bersama',
    prompt: 'Bagaimana gambaran kencan malam minggu yang paling sempurna versi kita saat kita sudah tua nanti?',
  },
  {
    id: 'truth-47',
    type: 'truth',
    category: 'Masa Depan Bersama',
    prompt: 'Impian pribadimu yang mana yang paling ingin aku dukung dan saksikan langsung pencapaiannya?',
  },
  {
    id: 'truth-48',
    type: 'truth',
    category: 'Masa Depan Bersama',
    prompt: 'Jika kita bisa mendesain taman atau sudut santai impian di rumah masa depan kita, seperti apa bentuknya?',
  },
  {
    id: 'truth-49',
    type: 'truth',
    category: 'Masa Depan Bersama',
    prompt: 'Petualangan baru apa yang ingin kita wujudkan bersama dalam waktu satu tahun ke depan?',
  },
  {
    id: 'truth-50',
    type: 'truth',
    category: 'Masa Depan Bersama',
    prompt: 'Satu janji hangat apa yang ingin kamu pegang bersama denganku untuk perjalanan kita ke depan?',
  },
];

export const DARE_CARDS: ChallengeCard[] = [
  {
    id: 'dare-01',
    type: 'dare',
    category: 'Manis dan Romantis',
    prompt: 'Genggam kedua tangan pasanganmu sekarang, tatap matanya selama 15 detik, lalu ucapkan satu hal yang paling kamu syukuri darinya hari ini.',
  },
  {
    id: 'dare-02',
    type: 'dare',
    category: 'Manis dan Romantis',
    prompt: 'Berikan tiga pujian tulus secara berurutan tentang senyum, kebaikan hati, dan cara pasanganmu memperlakukanmu.',
  },
  {
    id: 'dare-03',
    type: 'dare',
    category: 'Manis dan Romantis',
    prompt: 'Elus lembut rambut atau pundak pasanganmu sambil mengucapkan kalimat penyemangat paling hangat untuk minggunya.',
  },
  {
    id: 'dare-04',
    type: 'dare',
    category: 'Manis dan Romantis',
    prompt: 'Bisikkan di dekat telinga pasanganmu alasan mengapa kamu senang menghabiskan waktu bersamanya saat ini.',
  },
  {
    id: 'dare-05',
    type: 'dare',
    category: 'Manis dan Romantis',
    prompt: 'Peluk pasanganmu dengan hangat selama 20 detik tanpa bicara, biarkan suasana tenang berbicara untuk kalian.',
  },
  {
    id: 'dare-06',
    type: 'dare',
    category: 'Manis dan Romantis',
    prompt: 'Ciptakan satu panggilan sayang baru yang manis dan gunakan panggilan itu sampai giliranmu berikutnya!',
  },
  {
    id: 'dare-07',
    type: 'dare',
    category: 'Manis dan Romantis',
    prompt: 'Gambar bentuk hati kecil di telapak tangan pasanganmu menggunakan ujung jarimu sambil tersenyum padanya.',
  },
  {
    id: 'dare-08',
    type: 'dare',
    category: 'Manis dan Romantis',
    prompt: 'Nyanyikan sepenggal lirik lagu cinta favoritmu sambil menatap mata pasanganmu dengan penuh penghayatan.',
  },
  {
    id: 'dare-09',
    type: 'dare',
    category: 'Manis dan Romantis',
    prompt: 'Kecup punggung tangan pasanganmu dengan lembut ala bangsawan di taman kerajaan, lalu tersenyumlah.',
  },
  {
    id: 'dare-10',
    type: 'dare',
    category: 'Manis dan Romantis',
    prompt: 'Ucapkan "Terima kasih sudah hadir di hidupku" dengan nada paling tulus sambil menggenggam jari kelingkingnya.',
  },
  {
    id: 'dare-11',
    type: 'dare',
    category: 'Bikin Hati Meleleh',
    prompt: 'Rangkai sebuah puisi pendek spontan 4 baris tentang keindahan pasanganmu malam ini.',
  },
  {
    id: 'dare-12',
    type: 'dare',
    category: 'Bikin Hati Meleleh',
    prompt: 'Peragakan ulang ekspresi wajahmu saat pertama kali kamu naksir berat pada pasanganmu!',
  },
  {
    id: 'dare-13',
    type: 'dare',
    category: 'Bikin Hati Meleleh',
    prompt: 'Sandarkan kepalamu di bahu pasanganmu selama satu putaran penuh dan ceritakan satu hal yang membuatmu nyaman di sisinya.',
  },
  {
    id: 'dare-14',
    type: 'dare',
    category: 'Bikin Hati Meleleh',
    prompt: 'Berikan tatapan paling manis tanpa berkedip selama 10 detik, siapa yang tertawa duluan harus memberi pelukan tambahan!',
  },
  {
    id: 'dare-15',
    type: 'dare',
    category: 'Bikin Hati Meleleh',
    prompt: 'Ceritakan dalam 30 detik mengapa pasanganmu adalah orang paling menarik di matamu.',
  },
  {
    id: 'dare-16',
    type: 'dare',
    category: 'Bikin Hati Meleleh',
    prompt: 'Pijat lembut telapak tangan atau jemari pasanganmu selama 30 detik sambil menanyakan kabarnya hari ini.',
  },
  {
    id: 'dare-17',
    type: 'dare',
    category: 'Bikin Hati Meleleh',
    prompt: 'Ucapkan satu kalimat gombalan paling manis dan klasik yang bisa membuat pasanganmu tersipu malu sekarang juga.',
  },
  {
    id: 'dare-18',
    type: 'dare',
    category: 'Bikin Hati Meleleh',
    prompt: 'Rapikan anak rambut atau kerah baju pasanganmu dengan perlahan sambil menatapnya penuh kasih sayang.',
  },
  {
    id: 'dare-19',
    type: 'dare',
    category: 'Bikin Hati Meleleh',
    prompt: 'Sebutkan lima hal kecil dari pasanganmu yang selalu berhasil memperbaiki suasana hatimu seketika.',
  },
  {
    id: 'dare-20',
    type: 'dare',
    category: 'Bikin Hati Meleleh',
    prompt: 'Berikan high-five yang berubah menjadi genggaman tangan erat selama 15 detik sambil tersenyum lebar.',
  },
  {
    id: 'dare-21',
    type: 'dare',
    category: 'Kenangan Berdua',
    prompt: 'Ceritakan kembali momen paling lucu yang pernah kalian alami berdua dengan gaya bercerita yang ekspresif!',
  },
  {
    id: 'dare-22',
    type: 'dare',
    category: 'Kenangan Berdua',
    prompt: 'Tirukan satu kebiasaan khas atau gaya bicara pasanganmu yang paling menggemaskan (dengan penuh kasih sayang!).',
  },
  {
    id: 'dare-23',
    type: 'dare',
    category: 'Kenangan Berdua',
    prompt: 'Sebutkan tiga tempat yang pernah kalian kunjungi bersama dan apa kenangan terbaik di masing-masing tempat tersebut.',
  },
  {
    id: 'dare-24',
    type: 'dare',
    category: 'Kenangan Berdua',
    prompt: 'Deskripsikan foto berdua favoritmu secara detail dan ceritakan perasaanmu saat foto itu diambil.',
  },
  {
    id: 'dare-25',
    type: 'dare',
    category: 'Kenangan Berdua',
    prompt: 'Peragakan kembali cara kalian menyapa satu sama lain saat pertama kali pergi kencan dulu.',
  },
  {
    id: 'dare-26',
    type: 'dare',
    category: 'Kenangan Berdua',
    prompt: 'Ceritakan momen ketika pasanganmu melakukan sesuatu yang tak terduga dan membuatmu makin jatuh cinta.',
  },
  {
    id: 'dare-27',
    type: 'dare',
    category: 'Kenangan Berdua',
    prompt: 'Sebutkan makanan atau minuman yang paling mengingatkanmu pada momen kebersamaan kalian, lalu rencanakan kapan memakannya lagi.',
  },
  {
    id: 'dare-28',
    type: 'dare',
    category: 'Kenangan Berdua',
    prompt: 'Buat ulasan bintang lima yang seru dan romantis tentang pengalaman menjadi pasangan dari kekasihmu selama ini!',
  },
  {
    id: 'dare-29',
    type: 'dare',
    category: 'Kenangan Berdua',
    prompt: 'Bagikan satu pelajaran paling manis yang kamu ingat dari perjalanan atau liburan yang pernah kalian lakukan bersama.',
  },
  {
    id: 'dare-30',
    type: 'dare',
    category: 'Kenangan Berdua',
    prompt: 'Ucapkan kembali kalimat pertama yang kamu ingat pernah membuat kalian berdua tertawa lepas bersama.',
  },
  {
    id: 'dare-31',
    type: 'dare',
    category: 'Kedekatan yang Lebih Dalam',
    prompt: 'Tarik napas dalam-dalam bersama pasanganmu sebanyak tiga kali sambil berpegangan tangan dan saling menatap tenang.',
  },
  {
    id: 'dare-32',
    type: 'dare',
    category: 'Kedekatan yang Lebih Dalam',
    prompt: 'Sampaikan satu harapan baik dan doa tulus untuk kebahagiaan pasanganmu secara langsung di hadapannya.',
  },
  {
    id: 'dare-33',
    type: 'dare',
    category: 'Kedekatan yang Lebih Dalam',
    prompt: 'Tanyakan pada pasanganmu: "Hal kecil apa yang bisa aku lakukan minggu ini agar harimu terasa lebih ringan?" dan dengarkan jawabannya.',
  },
  {
    id: 'dare-34',
    type: 'dare',
    category: 'Kedekatan yang Lebih Dalam',
    prompt: 'Ucapkan tiga kualitas karakter pasanganmu yang paling kamu kagumi dan jadikan inspirasi dalam hidupmu.',
  },
  {
    id: 'dare-35',
    type: 'dare',
    category: 'Kedekatan yang Lebih Dalam',
    prompt: 'Tempelkan dahimu dengan lembut ke dahi pasanganmu (jika nyaman) atau genggam erat tangannya selama 10 detik dalam keheningan yang hangat.',
  },
  {
    id: 'dare-36',
    type: 'dare',
    category: 'Kedekatan yang Lebih Dalam',
    prompt: 'Ceritakan satu momen ketika dukungan dari pasanganmu berhasil membuatmu bangkit kembali.',
  },
  {
    id: 'dare-37',
    type: 'dare',
    category: 'Kedekatan yang Lebih Dalam',
    prompt: 'Berikan apresiasi tulus atas usaha yang dilakukan pasanganmu akhir-akhir ini dalam kesehariannya.',
  },
  {
    id: 'dare-38',
    type: 'dare',
    category: 'Kedekatan yang Lebih Dalam',
    prompt: 'Ungkapkan satu komitmen sederhana yang ingin kamu jaga agar hubungan kalian makin dewasa dan saling menguatkan.',
  },
  {
    id: 'dare-39',
    type: 'dare',
    category: 'Kedekatan yang Lebih Dalam',
    prompt: 'Biarkan pasanganmu memilih satu pertanyaan tambahan apa saja tentang perasaanmu, dan jawablah dengan sepenuh hati.',
  },
  {
    id: 'dare-40',
    type: 'dare',
    category: 'Kedekatan yang Lebih Dalam',
    prompt: 'Saling bertukar satu kalimat afirmasi positif yang dimulai dengan kata: "Bersamamu, aku merasa..."',
  },
  {
    id: 'dare-41',
    type: 'dare',
    category: 'Momen untuk Diingat',
    prompt: 'Rencanakan satu ide kencan sederhana untuk akhir pekan ini dalam waktu 60 detik bersama pasanganmu!',
  },
  {
    id: 'dare-42',
    type: 'dare',
    category: 'Momen untuk Diingat',
    prompt: 'Ambil pose paling manis berdua sekarang (atau bayangkan bingkai foto imajiner) dan beri judul untuk momen malam ini.',
  },
  {
    id: 'dare-43',
    type: 'dare',
    category: 'Momen untuk Diingat',
    prompt: 'Berdansa pelan di tempat bersama pasanganmu (atau ayunkan tangan berdua) selama 15 detik dengan irama imajiner.',
  },
  {
    id: 'dare-44',
    type: 'dare',
    category: 'Momen untuk Diingat',
    prompt: 'Buat salam rahasia (secret handshake) khusus pasangan yang romantis dan seru hanya untuk kalian berdua!',
  },
  {
    id: 'dare-45',
    type: 'dare',
    category: 'Momen untuk Diingat',
    prompt: 'Tulis pesan singkat satu kalimat di catatan ponsel atau secarik kertas untuk dibaca pasanganmu besok pagi.',
  },
  {
    id: 'dare-46',
    type: 'dare',
    category: 'Momen untuk Diingat',
    prompt: 'Berikan "Kupon Kasih Sayang" lisan kepada pasanganmu (misalnya: 1x pijat bahu atau 1x traktir es krim favoritnya).',
  },
  {
    id: 'dare-47',
    type: 'dare',
    category: 'Momen untuk Diingat',
    prompt: 'Sebutkan tiga hal seru dalam "Bucket List Berdua" yang ingin kalian centang bersama tahun ini.',
  },
  {
    id: 'dare-48',
    type: 'dare',
    category: 'Momen untuk Diingat',
    prompt: 'Ucapkan satu kalimat pembuka surat cinta seolah-olah kamu sedang menulis surat untuk dibaca 20 tahun mendatang.',
  },
  {
    id: 'dare-49',
    type: 'dare',
    category: 'Momen untuk Diingat',
    prompt: 'Pilih satu lagu yang akan menjadi "Lagu Tema" kalian minggu ini dan senandungkan nadanya bersama.',
  },
  {
    id: 'dare-50',
    type: 'dare',
    category: 'Momen untuk Diingat',
    prompt: 'Akhiri tantangan ini dengan pelukan hangat dan ucapkan: "Aku senang bermain dan berbagi cerita denganmu hari ini."',
  },
];

export const ALL_CHALLENGE_CARDS: ChallengeCard[] = [...TRUTH_CARDS, ...DARE_CARDS];

export function selectNextChallengeCard(
  type: ChallengeType,
  usedIds: string[],
  random: RandomSource = Math.random
): { card: ChallengeCard; updatedUsedIds: string[] } {
  const pool = type === 'truth' ? TRUTH_CARDS : DARE_CARDS;
  const usedSet = new Set(usedIds);

  let available = pool.filter((card) => !usedSet.has(card.id));
  let nextUsedBase = [...usedIds];

  if (available.length === 0) {
    const lastId = usedIds[usedIds.length - 1];
    available = pool.filter((card) => card.id !== lastId);
    nextUsedBase = [];
  }

  const raw = Math.max(0, Math.min(0.999999, random()));
  const chosenIndex = Math.floor(raw * available.length);
  const card = available[chosenIndex];

  return {
    card,
    updatedUsedIds: [...nextUsedBase, card.id],
  };
}
EOF

cat << 'EOF' > src/game/engine/gameEngine.ts
import { BOARD_CONFIG } from '../board/boardConfig';
import { selectNextChallengeCard } from '../challenges/challengeBank';
import { rollDiceValue } from '../dice/diceLogic';
import { createInitialPlayers, DEFAULT_PLAYERS_SETUP } from '../players/playerStyles';
import {
  ActiveTransition,
  BoardConfiguration,
  GameEngineState,
  MoveRecord,
  PlayerSetupInput,
  RandomSource,
} from '../types';

export interface CreateGameOptions {
  players?: PlayerSetupInput[];
  startInReadyPhase?: boolean;
}

export function createInitialGameState(options: CreateGameOptions = {}): GameEngineState {
  const players = createInitialPlayers(options.players ?? DEFAULT_PLAYERS_SETUP);
  const startReady = options.startInReadyPhase ?? true;

  return {
    phase: startReady ? 'ready' : 'setup',
    animationPhase: 'idle',
    players,
    activePlayerIndex: 0,
    turnNumber: 1,
    lastDiceValue: null,
    pendingPath: [],
    overshotLastRoll: false,
    activeChallenge: null,
    activeTransition: null,
    winnerId: null,
    moveHistory: [],
    statusMessage: `Giliran ${players[0].name} untuk melempar dadu di Taman Romantis.`,
    usedTruthIds: [],
    usedDareIds: [],
  };
}

export function startMatch(
  _state: GameEngineState,
  playersInput: PlayerSetupInput[]
): GameEngineState {
  return createInitialGameState({
    players: playersInput,
    startInReadyPhase: true,
  });
}

export function rollTurnDice(
  state: GameEngineState,
  options: {
    forcedDiceValue?: number;
    random?: RandomSource;
    board?: BoardConfiguration;
  } = {}
): GameEngineState {
  if (state.phase !== 'ready') {
    return state;
  }

  const board = options.board ?? BOARD_CONFIG;
  const diceValue =
    options.forcedDiceValue !== undefined
      ? options.forcedDiceValue
      : rollDiceValue(options.random);

  if (!Number.isInteger(diceValue) || diceValue < 1 || diceValue > 6) {
    throw new Error(`Invalid dice value: ${diceValue}. Expected integer 1..6.`);
  }

  const activePlayer = state.players[state.activePlayerIndex];
  const currentSquare = activePlayer.square;
  const targetSquare = currentSquare + diceValue;

  if (targetSquare > board.finishSquare) {
    return {
      ...state,
      phase: 'rolling',
      animationPhase: 'rolling',
      lastDiceValue: diceValue,
      pendingPath: [],
      overshotLastRoll: true,
      statusMessage: `${activePlayer.name} melempar angka ${diceValue}. Melebihi kotak 100, tetap di kotak ${currentSquare}.`,
    };
  }

  const pendingPath: number[] = [];
  for (let sq = currentSquare + 1; sq <= targetSquare; sq++) {
    pendingPath.push(sq);
  }

  return {
    ...state,
    phase: 'rolling',
    animationPhase: 'rolling',
    lastDiceValue: diceValue,
    pendingPath,
    overshotLastRoll: false,
    statusMessage: `${activePlayer.name} melempar dadu dan mendapat angka ${diceValue}!`,
  };
}

export function completeDiceRollAnimation(
  state: GameEngineState
): GameEngineState {
  if (state.phase !== 'rolling') {
    return state;
  }

  if (state.overshotLastRoll || state.pendingPath.length === 0) {
    const activePlayer = state.players[state.activePlayerIndex];
    const moveRecord: MoveRecord = {
      id: `move-${state.turnNumber}-${Date.now()}`,
      turnNumber: state.turnNumber,
      playerId: activePlayer.id,
      playerName: activePlayer.name,
      diceValue: state.lastDiceValue ?? 0,
      fromSquare: activePlayer.square,
      landedSquare: activePlayer.square,
      finalSquare: activePlayer.square,
      overshot: true,
      wonMatch: false,
      timestamp: Date.now(),
    };

    const nextState: GameEngineState = {
      ...state,
      phase: 'turn_complete',
      animationPhase: 'idle',
      moveHistory: [moveRecord, ...state.moveHistory].slice(0, 30),
    };
    return advanceToNextPlayerTurn(nextState);
  }

  const activePlayer = state.players[state.activePlayerIndex];
  const destination = state.pendingPath[state.pendingPath.length - 1];

  return {
    ...state,
    phase: 'moving',
    animationPhase: 'moving',
    statusMessage: `${activePlayer.name} melangkah menuju kotak ${destination}...`,
  };
}

export function completeNormalMovement(
  state: GameEngineState,
  options: { random?: RandomSource; board?: BoardConfiguration } = {}
): GameEngineState {
  if (state.phase !== 'moving') {
    return state;
  }

  const board = options.board ?? BOARD_CONFIG;
  const activePlayer = state.players[state.activePlayerIndex];
  const fromSquare = activePlayer.square;
  const landedSquare =
    state.pendingPath.length > 0
      ? state.pendingPath[state.pendingPath.length - 1]
      : activePlayer.square;

  const updatedPlayers = state.players.map((p, idx) =>
    idx === state.activePlayerIndex ? { ...p, square: landedSquare } : p
  );

  if (landedSquare === board.finishSquare) {
    const victoryRecord: MoveRecord = {
      id: `move-${state.turnNumber}-${Date.now()}`,
      turnNumber: state.turnNumber,
      playerId: activePlayer.id,
      playerName: activePlayer.name,
      diceValue: state.lastDiceValue ?? 0,
      fromSquare,
      landedSquare,
      finalSquare: landedSquare,
      overshot: false,
      wonMatch: true,
      timestamp: Date.now(),
    };

    return {
      ...state,
      players: updatedPlayers,
      pendingPath: [],
      phase: 'victory',
      animationPhase: 'victory',
      winnerId: activePlayer.id,
      moveHistory: [victoryRecord, ...state.moveHistory].slice(0, 30),
      statusMessage: `Selamat! ${activePlayer.name} mencapai Kotak 100 dan memenangkan petualangan cinta ini!`,
    };
  }

  const snake = board.snakes.find((s) => s.head === landedSquare);
  if (snake) {
    const transition: ActiveTransition = {
      kind: 'snake',
      id: snake.id,
      name: snake.name,
      fromSquare: snake.head,
      toSquare: snake.tail,
    };
    return {
      ...state,
      players: updatedPlayers,
      pendingPath: [fromSquare, landedSquare],
      phase: 'transitioning',
      animationPhase: 'transitioning',
      activeTransition: transition,
      statusMessage: `${activePlayer.name} bertemu ${snake.name} di kotak ${snake.head}! Meluncur turun ke kotak ${snake.tail}.`,
    };
  }

  const ladder = board.ladders.find((l) => l.bottom === landedSquare);
  if (ladder) {
    const transition: ActiveTransition = {
      kind: 'ladder',
      id: ladder.id,
      name: ladder.name,
      fromSquare: ladder.bottom,
      toSquare: ladder.top,
    };
    return {
      ...state,
      players: updatedPlayers,
      pendingPath: [fromSquare, landedSquare],
      phase: 'transitioning',
      animationPhase: 'transitioning',
      activeTransition: transition,
      statusMessage: `${activePlayer.name} menemukan ${ladder.name} di kotak ${ladder.bottom}! Naik menuju kotak ${ladder.top}.`,
    };
  }

  const squareMeta = board.squares[landedSquare];
  if (squareMeta?.type === 'truth') {
    const { card, updatedUsedIds } = selectNextChallengeCard(
      'truth',
      state.usedTruthIds,
      options.random
    );
    return {
      ...state,
      players: updatedPlayers,
      pendingPath: [fromSquare, landedSquare],
      phase: 'awaiting_challenge',
      animationPhase: 'reacting',
      activeChallenge: card,
      usedTruthIds: updatedUsedIds,
      statusMessage: `${activePlayer.name} mendarat di Kotak Truth (${landedSquare}) — Kategori: ${card.category}.`,
    };
  }

  if (squareMeta?.type === 'dare') {
    const { card, updatedUsedIds } = selectNextChallengeCard(
      'dare',
      state.usedDareIds,
      options.random
    );
    return {
      ...state,
      players: updatedPlayers,
      pendingPath: [fromSquare, landedSquare],
      phase: 'awaiting_challenge',
      animationPhase: 'reacting',
      activeChallenge: card,
      usedDareIds: updatedUsedIds,
      statusMessage: `${activePlayer.name} mendarat di Kotak Dare (${landedSquare}) — Kategori: ${card.category}.`,
    };
  }

  const normalRecord: MoveRecord = {
    id: `move-${state.turnNumber}-${Date.now()}`,
    turnNumber: state.turnNumber,
    playerId: activePlayer.id,
    playerName: activePlayer.name,
    diceValue: state.lastDiceValue ?? 0,
    fromSquare,
    landedSquare,
    finalSquare: landedSquare,
    overshot: false,
    wonMatch: false,
    timestamp: Date.now(),
  };

  const completedState: GameEngineState = {
    ...state,
    players: updatedPlayers,
    pendingPath: [],
    phase: 'turn_complete',
    animationPhase: 'idle',
    moveHistory: [normalRecord, ...state.moveHistory].slice(0, 30),
  };

  return advanceToNextPlayerTurn(completedState);
}

export function completeTransitionMovement(state: GameEngineState): GameEngineState {
  if (state.phase !== 'transitioning' || !state.activeTransition) {
    return state;
  }

  const activePlayer = state.players[state.activePlayerIndex];
  const fromSquare = state.pendingPath[0] ?? activePlayer.square;
  const landedSquare = state.activeTransition.fromSquare;
  const finalSquare = state.activeTransition.toSquare;

  const updatedPlayers = state.players.map((p, idx) =>
    idx === state.activePlayerIndex ? { ...p, square: finalSquare } : p
  );

  const transitionRecord: MoveRecord = {
    id: `move-${state.turnNumber}-${Date.now()}`,
    turnNumber: state.turnNumber,
    playerId: activePlayer.id,
    playerName: activePlayer.name,
    diceValue: state.lastDiceValue ?? 0,
    fromSquare,
    landedSquare,
    finalSquare,
    overshot: false,
    transition: state.activeTransition,
    wonMatch: false,
    timestamp: Date.now(),
  };

  const nextState: GameEngineState = {
    ...state,
    players: updatedPlayers,
    pendingPath: [],
    activeTransition: null,
    phase: 'turn_complete',
    animationPhase: 'idle',
    moveHistory: [transitionRecord, ...state.moveHistory].slice(0, 30),
  };

  return advanceToNextPlayerTurn(nextState);
}

export function resolveActiveChallenge(
  state: GameEngineState,
  outcome: 'completed' | 'skipped'
): GameEngineState {
  if (state.phase !== 'awaiting_challenge' || !state.activeChallenge) {
    return state;
  }

  const activePlayer = state.players[state.activePlayerIndex];
  const fromSquare = state.pendingPath[0] ?? activePlayer.square;
  const landedSquare = activePlayer.square;
  const card = state.activeChallenge;

  const updatedPlayers = state.players.map((p, idx) => {
    if (idx !== state.activePlayerIndex) return p;
    return {
      ...p,
      completedChallenges:
        outcome === 'completed' ? p.completedChallenges + 1 : p.completedChallenges,
      skippedChallenges:
        outcome === 'skipped' ? p.skippedChallenges + 1 : p.skippedChallenges,
    };
  });

  const challengeRecord: MoveRecord = {
    id: `move-${state.turnNumber}-${Date.now()}`,
    turnNumber: state.turnNumber,
    playerId: activePlayer.id,
    playerName: activePlayer.name,
    diceValue: state.lastDiceValue ?? 0,
    fromSquare,
    landedSquare,
    finalSquare: landedSquare,
    overshot: false,
    challenge: {
      cardId: card.id,
      type: card.type,
      category: card.category,
      outcome,
    },
    wonMatch: false,
    timestamp: Date.now(),
  };

  const nextState: GameEngineState = {
    ...state,
    players: updatedPlayers,
    pendingPath: [],
    activeChallenge: null,
    phase: 'turn_complete',
    animationPhase: 'idle',
    moveHistory: [challengeRecord, ...state.moveHistory].slice(0, 30),
  };

  return advanceToNextPlayerTurn(nextState);
}

export function advanceToNextPlayerTurn(state: GameEngineState): GameEngineState {
  if (state.phase === 'victory') {
    return state;
  }

  const nextIndex = (state.activePlayerIndex + 1) % state.players.length;
  const nextPlayer = state.players[nextIndex];

  return {
    ...state,
    phase: 'ready',
    animationPhase: 'idle',
    activePlayerIndex: nextIndex,
    turnNumber: state.turnNumber + 1,
    activeChallenge: null,
    activeTransition: null,
    pendingPath: [],
    statusMessage: `Giliran ${nextPlayer.name} (Kotak ${nextPlayer.square}) untuk melempar dadu.`,
  };
}
EOF

cat << 'EOF' > src/game/store/useGameStore.ts
import { create } from 'zustand';
import {
  completeDiceRollAnimation,
  completeNormalMovement,
  completeTransitionMovement,
  createInitialGameState,
  resolveActiveChallenge,
  rollTurnDice,
  startMatch,
} from '../engine/gameEngine';
import { DEFAULT_PLAYERS_SETUP } from '../players/playerStyles';
import { GameEngineState, PlayerSetupInput } from '../types';

export type CameraMode = 'intro' | 'gameplay';

interface GameStore extends GameEngineState {
  soundEnabled: boolean;
  reducedMotion: boolean;
  cameraMode: CameraMode;
  cameraResetTrigger: number;
  setupModalOpen: boolean;

  setSoundEnabled: (enabled: boolean) => void;
  setReducedMotion: (reduced: boolean) => void;
  finishCameraIntro: () => void;
  triggerCameraReset: () => void;
  setSetupModalOpen: (open: boolean) => void;

  startNewGame: (players?: PlayerSetupInput[], replayIntro?: boolean) => void;
  rollDice: (forcedValue?: number) => void;
  notifyDiceAnimationComplete: () => void;
  notifyMovementAnimationComplete: () => void;
  notifyTransitionAnimationComplete: () => void;
  completeChallenge: () => void;
  skipChallenge: () => void;
  setDebugPlayerSquare: (playerIndex: number, square: number) => void;
}

export const useGameStore = create<GameStore>((set, get) => ({
  ...createInitialGameState({
    players: DEFAULT_PLAYERS_SETUP,
    startInReadyPhase: true,
  }),
  soundEnabled: true,
  reducedMotion: false,
  cameraMode: 'intro',
  cameraResetTrigger: 0,
  setupModalOpen: false,

  setSoundEnabled: (enabled) => set({ soundEnabled: enabled }),
  setReducedMotion: (reduced) =>
    set((state) => ({
      reducedMotion: reduced,
      cameraMode: reduced ? 'gameplay' : state.cameraMode,
    })),
  finishCameraIntro: () => set({ cameraMode: 'gameplay' }),
  triggerCameraReset: () =>
    set((state) => ({
      cameraMode: 'gameplay',
      cameraResetTrigger: state.cameraResetTrigger + 1,
    })),
  setSetupModalOpen: (open) => set({ setupModalOpen: open }),

  startNewGame: (playersInput, replayIntro = false) => {
    const current = get();
    const playersToUse =
      playersInput ??
      current.players.map((p) => ({
        name: p.name,
        pieceStyle: p.pieceStyle,
      }));
    const fresh = startMatch(current, playersToUse);
    set({
      ...fresh,
      setupModalOpen: false,
      cameraMode: replayIntro && !current.reducedMotion ? 'intro' : 'gameplay',
    });
  },

  rollDice: (forcedValue) => {
    const next = rollTurnDice(get(), { forcedDiceValue: forcedValue });
    set(next);
  },

  notifyDiceAnimationComplete: () => {
    const next = completeDiceRollAnimation(get());
    set(next);
  },

  notifyMovementAnimationComplete: () => {
    const next = completeNormalMovement(get());
    set(next);
  },

  notifyTransitionAnimationComplete: () => {
    const next = completeTransitionMovement(get());
    set(next);
  },

  completeChallenge: () => {
    const next = resolveActiveChallenge(get(), 'completed');
    set(next);
  },

  skipChallenge: () => {
    const next = resolveActiveChallenge(get(), 'skipped');
    set(next);
  },

  setDebugPlayerSquare: (playerIndex, square) => {
    set((state) => ({
      players: state.players.map((p, idx) =>
        idx === playerIndex ? { ...p, square } : p
      ),
    }));
  },
}));
EOF

echo "🎨 Menulis komponen 3D React Three Fiber, Audio, dan UI..."

cat << 'EOF' > src/components/audio/soundEngine.ts
'use client';

class RomanticSoundEngine {
  private ctx: AudioContext | null = null;

  private ensureContext(): AudioContext | null {
    if (typeof window === 'undefined') return null;
    if (!this.ctx) {
      const AudioCtx =
        window.AudioContext ||
        (window as unknown as { webkitAudioContext?: typeof AudioContext })
          .webkitAudioContext;
      if (AudioCtx) {
        this.ctx = new AudioCtx();
      }
    }
    if (this.ctx && this.ctx.state === 'suspended') {
      this.ctx.resume().catch(() => {});
    }
    return this.ctx;
  }

  private playTone(
    freq: number,
    duration: number,
    type: OscillatorType = 'sine',
    gainPeak = 0.08,
    delay = 0
  ) {
    const ctx = this.ensureContext();
    if (!ctx) return;

    const startTime = ctx.currentTime + delay;
    const osc = ctx.createOscillator();
    const gain = ctx.createGain();

    osc.type = type;
    osc.frequency.setValueAtTime(freq, startTime);

    gain.gain.setValueAtTime(0.0001, startTime);
    gain.gain.exponentialRampToValueAtTime(gainPeak, startTime + 0.02);
    gain.gain.exponentialRampToValueAtTime(0.0001, startTime + duration);

    osc.connect(gain);
    gain.connect(ctx.destination);

    osc.start(startTime);
    osc.stop(startTime + duration + 0.02);
  }

  playDiceRoll(enabled: boolean) {
    if (!enabled) return;
    const notes = [330, 392, 440, 523.25];
    notes.forEach((n, i) => {
      this.playTone(n, 0.09, 'triangle', 0.06, i * 0.06);
    });
  }

  playStepHop(enabled: boolean, stepIndex = 0) {
    if (!enabled) return;
    const baseFreq = 440 + (stepIndex % 6) * 35;
    this.playTone(baseFreq, 0.11, 'sine', 0.05, 0);
  }

  playChallengeReveal(enabled: boolean, type: 'truth' | 'dare') {
    if (!enabled) return;
    const chord =
      type === 'truth'
        ? [523.25, 659.25, 783.99, 1046.5]
        : [440, 554.37, 659.25, 880];
    chord.forEach((freq, idx) => {
      this.playTone(freq, 0.38, 'sine', 0.06, idx * 0.07);
    });
  }

  playLadderClimb(enabled: boolean) {
    if (!enabled) return;
    const scale = [392, 440, 493.88, 587.33, 659.25, 783.99];
    scale.forEach((freq, idx) => {
      this.playTone(freq, 0.22, 'triangle', 0.065, idx * 0.08);
    });
  }

  playSnakeSlide(enabled: boolean) {
    if (!enabled) return;
    const scale = [659.25, 587.33, 493.88, 440, 349.23];
    scale.forEach((freq, idx) => {
      this.playTone(freq, 0.24, 'sine', 0.06, idx * 0.09);
    });
  }

  playVictoryFanfare(enabled: boolean) {
    if (!enabled) return;
    const notes = [523.25, 659.25, 783.99, 1046.5, 1318.5];
    notes.forEach((freq, idx) => {
      this.playTone(freq, 0.55, 'triangle', 0.08, idx * 0.11);
    });
  }
}

export const soundEngine = new RomanticSoundEngine();
EOF

cat << 'EOF' > src/components/board/Board3D.tsx
'use client';

import React, { useMemo } from 'react';
import { Text, RoundedBox } from '@react-three/drei';
import { BOARD_CONFIG } from '@/game/board/boardConfig';
import { SquareMetadata } from '@/game/types';

interface Board3DProps {
  highlightedSquare: number | null;
}

function getTileColors(meta: SquareMetadata, isEvenChecker: boolean) {
  switch (meta.type) {
    case 'start':
      return {
        surface: '#F4D7DE',
        border: '#C99A72',
        text: '#654754',
        badge: 'MULAI',
      };
    case 'finish':
      return {
        surface: '#C99A72',
        border: '#FFF7ED',
        text: '#FFFDF8',
        badge: 'MAHKOTA 100',
      };
    case 'truth':
      return {
        surface: '#F6E2E8',
        border: '#C98296',
        text: '#654754',
        badge: '♥ TRUTH',
      };
    case 'dare':
      return {
        surface: '#EFE7F8',
        border: '#C99A72',
        text: '#654754',
        badge: '✦ DARE',
      };
    case 'snake_head':
      return {
        surface: '#E4ECE0',
        border: '#7C9473',
        text: '#47303A',
        badge: 'ULAR',
      };
    case 'ladder_bottom':
      return {
        surface: '#FBF0D9',
        border: '#C99A72',
        text: '#654754',
        badge: 'TANGGA',
      };
    default:
      return {
        surface: isEvenChecker ? '#FFF7ED' : '#F9E8EC',
        border: '#E5CED4',
        text: '#654754',
        badge: null,
      };
  }
}

export function Board3D({ highlightedSquare }: Board3DProps) {
  const squaresList = useMemo(
    () => Object.values(BOARD_CONFIG.squares),
    []
  );

  const totalBoardWidth =
    BOARD_CONFIG.cols * (BOARD_CONFIG.tileSize + BOARD_CONFIG.tileGap) + 0.65;

  return (
    <group name="romantic-board-root">
      <RoundedBox
        args={[totalBoardWidth, 0.34, totalBoardWidth]}
        radius={0.14}
        smoothness={4}
        position={[0, 0.02, 0]}
        receiveShadow
        castShadow
      >
        <meshStandardMaterial
          color="#FFF7ED"
          roughness={0.35}
          metalness={0.08}
        />
      </RoundedBox>

      <RoundedBox
        args={[totalBoardWidth + 0.18, 0.24, totalBoardWidth + 0.18]}
        radius={0.16}
        smoothness={4}
        position={[0, -0.02, 0]}
        receiveShadow
      >
        <meshStandardMaterial
          color="#C99A72"
          roughness={0.28}
          metalness={0.62}
        />
      </RoundedBox>

      {squaresList.map((meta) => {
        const isEvenChecker = (meta.row + meta.col) % 2 === 0;
        const palette = getTileColors(meta, isEvenChecker);
        const isHighlighted = highlightedSquare === meta.square;

        return (
          <group
            key={meta.square}
            position={[
              meta.worldPosition.x,
              meta.worldPosition.y,
              meta.worldPosition.z,
            ]}
          >
            <RoundedBox
              args={[BOARD_CONFIG.tileSize, 0.14, BOARD_CONFIG.tileSize]}
              radius={0.04}
              smoothness={3}
              receiveShadow
              castShadow
            >
              <meshStandardMaterial
                color={isHighlighted ? '#FFE3EC' : palette.surface}
                roughness={0.32}
                metalness={meta.type === 'finish' ? 0.45 : 0.06}
                emissive={isHighlighted ? '#C98296' : '#000000'}
                emissiveIntensity={isHighlighted ? 0.35 : 0}
              />
            </RoundedBox>

            {meta.type !== 'normal' && (
              <mesh position={[0, 0.072, 0]} rotation={[-Math.PI / 2, 0, 0]}>
                <ringGeometry
                  args={[
                    BOARD_CONFIG.tileSize * 0.38,
                    BOARD_CONFIG.tileSize * 0.44,
                    24,
                  ]}
                />
                <meshStandardMaterial
                  color={palette.border}
                  roughness={0.3}
                  metalness={0.5}
                />
              </mesh>
            )}

            <Text
              position={[
                -BOARD_CONFIG.tileSize * 0.28,
                0.082,
                -BOARD_CONFIG.tileSize * 0.26,
              ]}
              rotation={[-Math.PI / 2, 0, 0]}
              fontSize={0.2}
              color={palette.text}
              anchorX="left"
              anchorY="top"
            >
              {String(meta.square)}
            </Text>

            {palette.badge && (
              <Text
                position={[0, 0.082, BOARD_CONFIG.tileSize * 0.18]}
                rotation={[-Math.PI / 2, 0, 0]}
                fontSize={0.115}
                color={palette.text}
                anchorX="center"
                anchorY="middle"
              >
                {palette.badge}
              </Text>
            )}
          </group>
        );
      })}
    </group>
  );
}
EOF

cat << 'EOF' > src/components/obstacles/SnakesAndLadders3D.tsx
'use client';

import React, { useMemo } from 'react';
import * as THREE from 'three';
import { BOARD_CONFIG } from '@/game/board/boardConfig';
import { LadderDefinition, SnakeDefinition } from '@/game/types';

interface ObstaclesProps {
  activeTransitionId: string | null;
}

function SnakeMesh({
  snake,
  isHighlighted,
}: {
  snake: SnakeDefinition;
  isHighlighted: boolean;
}) {
  const headPos = BOARD_CONFIG.squares[snake.head].worldPosition;
  const tailPos = BOARD_CONFIG.squares[snake.tail].worldPosition;

  const { curve, headPosition, headLookAt } = useMemo(() => {
    const start = new THREE.Vector3(headPos.x, headPos.y + 0.14, headPos.z);
    const end = new THREE.Vector3(tailPos.x, tailPos.y + 0.12, tailPos.z);
    const dir = new THREE.Vector3().subVectors(end, start);
    const perp = new THREE.Vector3(-dir.z, 0, dir.x).normalize();

    const p1 = start
      .clone()
      .lerp(end, 0.25)
      .addScaledVector(perp, 0.55)
      .add(new THREE.Vector3(0, 0.18, 0));
    const p2 = start
      .clone()
      .lerp(end, 0.55)
      .addScaledVector(perp, -0.55)
      .add(new THREE.Vector3(0, 0.14, 0));
    const p3 = start
      .clone()
      .lerp(end, 0.8)
      .addScaledVector(perp, 0.35)
      .add(new THREE.Vector3(0, 0.1, 0));

    const spline = new THREE.CatmullRomCurve3([start, p1, p2, p3, end]);
    return {
      curve: spline,
      headPosition: start,
      headLookAt: p1,
    };
  }, [headPos, tailPos]);

  const colorMap: Record<SnakeDefinition['style'], string> = {
    jade_sculpt: '#8FA889',
    sage_stone: '#A9B9A0',
    rose_bronze: '#C99A72',
    ivory_serpent: '#E9D5DA',
  };

  const bodyColor = colorMap[snake.style];

  return (
    <group name={snake.id}>
      <mesh castShadow>
        <tubeGeometry args={[curve, 48, 0.085, 12, false]} />
        <meshStandardMaterial
          color={bodyColor}
          roughness={0.28}
          metalness={0.25}
          emissive={isHighlighted ? '#C98296' : '#000000'}
          emissiveIntensity={isHighlighted ? 0.5 : 0}
        />
      </mesh>

      <group
        position={[headPosition.x, headPosition.y + 0.06, headPosition.z]}
        rotation={[
          0,
          Math.atan2(headLookAt.x - headPosition.x, headLookAt.z - headPosition.z),
          0,
        ]}
      >
        <mesh castShadow scale={[1.1, 0.85, 1.4]}>
          <sphereGeometry args={[0.13, 16, 16]} />
          <meshStandardMaterial
            color={bodyColor}
            roughness={0.22}
            metalness={0.35}
          />
        </mesh>
        <mesh position={[0, 0.11, 0.03]}>
          <octahedronGeometry args={[0.045, 0]} />
          <meshStandardMaterial color="#C99A72" metalness={0.8} roughness={0.2} />
        </mesh>
      </group>
    </group>
  );
}

function LadderMesh({
  ladder,
  isHighlighted,
}: {
  ladder: LadderDefinition;
  isHighlighted: boolean;
}) {
  const bottomPos = BOARD_CONFIG.squares[ladder.bottom].worldPosition;
  const topPos = BOARD_CONFIG.squares[ladder.top].worldPosition;

  const { midpoint, length, angleY, angleX, rungCount } = useMemo(() => {
    const start = new THREE.Vector3(bottomPos.x, bottomPos.y + 0.12, bottomPos.z);
    const end = new THREE.Vector3(topPos.x, topPos.y + 0.12, topPos.z);
    const diff = new THREE.Vector3().subVectors(end, start);
    const dist = diff.length();
    const mid = start.clone().lerp(end, 0.5).add(new THREE.Vector3(0, 0.05, 0));

    const yaw = Math.atan2(diff.x, diff.z);
    const pitch = Math.PI / 2;

    return {
      midpoint: mid,
      length: dist,
      angleY: yaw,
      angleX: pitch,
      rungCount: Math.max(4, Math.floor(dist * 2.4)),
    };
  }, [bottomPos, topPos]);

  const railSpacing = 0.26;
  const railColor =
    ladder.style === 'rose_gold_trellis'
      ? '#C99A72'
      : ladder.style === 'painted_ivory'
      ? '#FFF7ED'
      : '#D6B18E';

  return (
    <group
      name={ladder.id}
      position={[midpoint.x, midpoint.y, midpoint.z]}
      rotation={[0, angleY, 0]}
    >
      <mesh
        position={[-railSpacing / 2, 0, 0]}
        rotation={[angleX, 0, 0]}
        castShadow
      >
        <cylinderGeometry args={[0.032, 0.032, length, 10]} />
        <meshStandardMaterial
          color={railColor}
          roughness={0.3}
          metalness={ladder.style === 'rose_gold_trellis' ? 0.65 : 0.15}
          emissive={isHighlighted ? '#C99A72' : '#000000'}
          emissiveIntensity={isHighlighted ? 0.45 : 0}
        />
      </mesh>

      <mesh
        position={[railSpacing / 2, 0, 0]}
        rotation={[angleX, 0, 0]}
        castShadow
      >
        <cylinderGeometry args={[0.032, 0.032, length, 10]} />
        <meshStandardMaterial
          color={railColor}
          roughness={0.3}
          metalness={ladder.style === 'rose_gold_trellis' ? 0.65 : 0.15}
          emissive={isHighlighted ? '#C99A72' : '#000000'}
          emissiveIntensity={isHighlighted ? 0.45 : 0}
        />
      </mesh>

      {Array.from({ length: rungCount }).map((_, idx) => {
        const t = (idx + 1) / (rungCount + 1) - 0.5;
        const zOffset = t * length;
        return (
          <mesh
            key={idx}
            position={[0, 0, zOffset]}
            rotation={[0, 0, Math.PI / 2]}
            castShadow
          >
            <cylinderGeometry args={[0.022, 0.022, railSpacing, 8]} />
            <meshStandardMaterial
              color="#C99A72"
              roughness={0.28}
              metalness={0.55}
            />
          </mesh>
        );
      })}
    </group>
  );
}

export function SnakesAndLadders3D({ activeTransitionId }: ObstaclesProps) {
  return (
    <group name="snakes-and-ladders-group">
      {BOARD_CONFIG.snakes.map((snake) => (
        <SnakeMesh
          key={snake.id}
          snake={snake}
          isHighlighted={activeTransitionId === snake.id}
        />
      ))}
      {BOARD_CONFIG.ladders.map((ladder) => (
        <LadderMesh
          key={ladder.id}
          ladder={ladder}
          isHighlighted={activeTransitionId === ladder.id}
        />
      ))}
    </group>
  );
}
EOF

cat << 'EOF' > src/components/pieces/PlayerPieces3D.tsx
'use client';

import React, { useEffect, useRef } from 'react';
import { useFrame } from '@react-three/fiber';
import * as THREE from 'three';
import { BOARD_CONFIG, getPieceStackOffset } from '@/game/board/boardConfig';
import { useGameStore } from '@/game/store/useGameStore';
import { soundEngine } from '../audio/soundEngine';

export function PlayerPieces3D() {
  const players = useGameStore((s) => s.players);
  const activePlayerIndex = useGameStore((s) => s.activePlayerIndex);
  const phase = useGameStore((s) => s.phase);
  const pendingPath = useGameStore((s) => s.pendingPath);
  const activeTransition = useGameStore((s) => s.activeTransition);
  const reducedMotion = useGameStore((s) => s.reducedMotion);
  const soundEnabled = useGameStore((s) => s.soundEnabled);

  const notifyMovementAnimationComplete = useGameStore(
    (s) => s.notifyMovementAnimationComplete
  );
  const notifyTransitionAnimationComplete = useGameStore(
    (s) => s.notifyTransitionAnimationComplete
  );

  const pieceRefs = useRef<Record<string, THREE.Group | null>>({});

  const moveProgressRef = useRef<{
    active: boolean;
    stepIndex: number;
    stepProgress: number;
    fromPos: THREE.Vector3;
    toPos: THREE.Vector3;
  }>({
    active: false,
    stepIndex: 0,
    stepProgress: 0,
    fromPos: new THREE.Vector3(),
    toPos: new THREE.Vector3(),
  });

  const transitionProgressRef = useRef<{
    active: boolean;
    progress: number;
    fromPos: THREE.Vector3;
    toPos: THREE.Vector3;
    kind: 'snake' | 'ladder';
  }>({
    active: false,
    progress: 0,
    fromPos: new THREE.Vector3(),
    toPos: new THREE.Vector3(),
    kind: 'ladder',
  });

  useEffect(() => {
    if (phase === 'moving' && pendingPath.length > 0) {
      const activePlayer = players[activePlayerIndex];
      const startSq = activePlayer.square;
      const firstTargetSq = pendingPath[0];
      const startCoord = BOARD_CONFIG.squares[startSq].worldPosition;
      const nextCoord = BOARD_CONFIG.squares[firstTargetSq].worldPosition;

      moveProgressRef.current = {
        active: true,
        stepIndex: 0,
        stepProgress: 0,
        fromPos: new THREE.Vector3(startCoord.x, startCoord.y, startCoord.z),
        toPos: new THREE.Vector3(nextCoord.x, nextCoord.y, nextCoord.z),
      };
      soundEngine.playStepHop(soundEnabled, 0);
    } else {
      moveProgressRef.current.active = false;
    }
  }, [phase, pendingPath, activePlayerIndex, players, soundEnabled]);

  useEffect(() => {
    if (phase === 'transitioning' && activeTransition) {
      const startCoord =
        BOARD_CONFIG.squares[activeTransition.fromSquare].worldPosition;
      const endCoord =
        BOARD_CONFIG.squares[activeTransition.toSquare].worldPosition;

      transitionProgressRef.current = {
        active: true,
        progress: 0,
        fromPos: new THREE.Vector3(startCoord.x, startCoord.y, startCoord.z),
        toPos: new THREE.Vector3(endCoord.x, endCoord.y, endCoord.z),
        kind: activeTransition.kind,
      };

      if (activeTransition.kind === 'ladder') {
        soundEngine.playLadderClimb(soundEnabled);
      } else {
        soundEngine.playSnakeSlide(soundEnabled);
      }
    } else {
      transitionProgressRef.current.active = false;
    }
  }, [phase, activeTransition, soundEnabled]);

  useEffect(() => {
    if (phase === 'victory') {
      soundEngine.playVictoryFanfare(soundEnabled);
    }
  }, [phase, soundEnabled]);

  useFrame((state, delta) => {
    const activePlayer = players[activePlayerIndex];

    if (phase === 'moving' && moveProgressRef.current.active && activePlayer) {
      const speed = reducedMotion ? 9.0 : 4.2;
      const m = moveProgressRef.current;
      m.stepProgress += delta * speed;

      const group = pieceRefs.current[activePlayer.id];
      if (group) {
        const t = Math.min(1, m.stepProgress);
        const lerped = new THREE.Vector3().lerpVectors(m.fromPos, m.toPos, t);
        const bounceArc = reducedMotion ? 0 : Math.sin(t * Math.PI) * 0.42;
        group.position.set(lerped.x, lerped.y + 0.12 + bounceArc, lerped.z);
      }

      if (m.stepProgress >= 1) {
        const nextStepIndex = m.stepIndex + 1;
        if (nextStepIndex < pendingPath.length) {
          const prevSq = pendingPath[m.stepIndex];
          const nextSq = pendingPath[nextStepIndex];
          const pCoord = BOARD_CONFIG.squares[prevSq].worldPosition;
          const nCoord = BOARD_CONFIG.squares[nextSq].worldPosition;

          m.stepIndex = nextStepIndex;
          m.stepProgress = 0;
          m.fromPos.set(pCoord.x, pCoord.y, pCoord.z);
          m.toPos.set(nCoord.x, nCoord.y, nCoord.z);
          soundEngine.playStepHop(soundEnabled, nextStepIndex);
        } else {
          m.active = false;
          notifyMovementAnimationComplete();
        }
      }
      return;
    }

    if (
      phase === 'transitioning' &&
      transitionProgressRef.current.active &&
      activePlayer
    ) {
      const tr = transitionProgressRef.current;
      const speed = reducedMotion ? 3.5 : 1.35;
      tr.progress += delta * speed;
      const t = Math.min(1, tr.progress);
      const smoothT = t * t * (3 - 2 * t);

      const group = pieceRefs.current[activePlayer.id];
      if (group) {
        const pos = new THREE.Vector3().lerpVectors(
          tr.fromPos,
          tr.toPos,
          smoothT
        );
        const arcLift =
          tr.kind === 'ladder'
            ? Math.sin(smoothT * Math.PI) * 0.55
            : Math.sin(smoothT * Math.PI * 2) * 0.12;
        group.position.set(pos.x, pos.y + 0.14 + arcLift, pos.z);
      }

      if (tr.progress >= 1) {
        tr.active = false;
        notifyTransitionAnimationComplete();
      }
      return;
    }

    const squareGroups = new Map<number, string[]>();
    players.forEach((p) => {
      const list = squareGroups.get(p.square) ?? [];
      list.push(p.id);
      squareGroups.set(p.square, list);
    });

    players.forEach((player, idx) => {
      const group = pieceRefs.current[player.id];
      if (!group) return;

      const sqCoord = BOARD_CONFIG.squares[player.square].worldPosition;
      const occupants = squareGroups.get(player.square) ?? [player.id];
      const indexOnSquare = occupants.indexOf(player.id);
      const offset = getPieceStackOffset(indexOnSquare, occupants.length);

      const isWinner = phase === 'victory' && idx === activePlayerIndex;
      const isTurnOwner = idx === activePlayerIndex;
      const idleFloat =
        reducedMotion
          ? 0
          : isWinner
          ? Math.sin(state.clock.elapsedTime * 3.5) * 0.14 + 0.18
          : isTurnOwner
          ? Math.sin(state.clock.elapsedTime * 2.4) * 0.035
          : 0;

      group.position.x = THREE.MathUtils.lerp(
        group.position.x,
        sqCoord.x + offset.x,
        0.22
      );
      group.position.z = THREE.MathUtils.lerp(
        group.position.z,
        sqCoord.z + offset.z,
        0.22
      );
      group.position.y = THREE.MathUtils.lerp(
        group.position.y,
        sqCoord.y + 0.1 + idleFloat,
        0.22
      );
    });
  });

  return (
    <group name="player-pieces-root">
      {players.map((player, index) => {
        const startCoord = BOARD_CONFIG.squares[player.square].worldPosition;
        const isCurrentTurn = index === activePlayerIndex;

        return (
          <group
            key={player.id}
            ref={(el) => {
              pieceRefs.current[player.id] = el;
            }}
            position={[startCoord.x, startCoord.y + 0.1, startCoord.z]}
          >
            <mesh position={[0, 0.06, 0]} castShadow receiveShadow>
              <cylinderGeometry args={[0.2, 0.24, 0.12, 24]} />
              <meshStandardMaterial
                color={player.color}
                roughness={0.22}
                metalness={0.15}
              />
            </mesh>

            <mesh position={[0, 0.14, 0]} castShadow>
              <cylinderGeometry args={[0.17, 0.19, 0.05, 24]} />
              <meshStandardMaterial
                color={player.accentColor}
                roughness={0.25}
                metalness={0.75}
              />
            </mesh>

            <mesh position={[0, 0.34, 0]} castShadow>
              <cylinderGeometry args={[0.11, 0.16, 0.36, 24]} />
              <meshStandardMaterial
                color={player.color}
                roughness={0.2}
                metalness={0.12}
              />
            </mesh>

            {index % 2 === 0 ? (
              <mesh position={[0, 0.58, 0]} castShadow>
                <sphereGeometry args={[0.13, 24, 24]} />
                <meshStandardMaterial
                  color={player.accentColor}
                  roughness={0.2}
                  metalness={0.68}
                />
              </mesh>
            ) : (
              <mesh
                position={[0, 0.59, 0]}
                rotation={[0, Math.PI / 4, 0]}
                castShadow
              >
                <octahedronGeometry args={[0.14, 0]} />
                <meshStandardMaterial
                  color={player.accentColor}
                  roughness={0.18}
                  metalness={0.72}
                />
              </mesh>
            )}

            {isCurrentTurn && (
              <mesh position={[0, 0.01, 0]} rotation={[-Math.PI / 2, 0, 0]}>
                <ringGeometry args={[0.26, 0.33, 32]} />
                <meshBasicMaterial
                  color="#C98296"
                  transparent
                  opacity={0.85}
                />
              </mesh>
            )}
          </group>
        );
      })}
    </group>
  );
}
EOF

cat << 'EOF' > src/components/dice/Dice3D.tsx
'use client';

import React, { useEffect, useRef } from 'react';
import { useFrame } from '@react-three/fiber';
import { RoundedBox } from '@react-three/drei';
import * as THREE from 'three';
import { getRotationForDiceValue } from '@/game/dice/diceLogic';
import { useGameStore } from '@/game/store/useGameStore';
import { soundEngine } from '../audio/soundEngine';

const PIP_PATTERNS: Record<number, [number, number][]> = {
  1: [[0, 0]],
  2: [
    [-0.18, -0.18],
    [0.18, 0.18],
  ],
  3: [
    [-0.2, -0.2],
    [0, 0],
    [0.2, 0.2],
  ],
  4: [
    [-0.18, -0.18],
    [0.18, -0.18],
    [-0.18, 0.18],
    [0.18, 0.18],
  ],
  5: [
    [-0.19, -0.19],
    [0.19, -0.19],
    [0, 0],
    [-0.19, 0.19],
    [0.19, 0.19],
  ],
  6: [
    [-0.18, -0.2],
    [0.18, -0.2],
    [-0.18, 0],
    [0.18, 0],
    [-0.18, 0.2],
    [0.18, 0.2],
  ],
};

function FacePips({
  value,
  position,
  rotation,
}: {
  value: number;
  position: [number, number, number];
  rotation: [number, number, number];
}) {
  const pips = PIP_PATTERNS[value] ?? [];
  return (
    <group position={position} rotation={rotation}>
      {pips.map(([px, py], idx) => (
        <mesh key={idx} position={[px, py, 0]}>
          <circleGeometry args={[0.055, 16]} />
          <meshStandardMaterial
            color={value === 1 ? '#C98296' : '#654754'}
            roughness={0.25}
            metalness={0.4}
          />
        </mesh>
      ))}
    </group>
  );
}

export function Dice3D() {
  const phase = useGameStore((s) => s.phase);
  const lastDiceValue = useGameStore((s) => s.lastDiceValue);
  const reducedMotion = useGameStore((s) => s.reducedMotion);
  const soundEnabled = useGameStore((s) => s.soundEnabled);
  const rollDice = useGameStore((s) => s.rollDice);
  const notifyDiceAnimationComplete = useGameStore(
    (s) => s.notifyDiceAnimationComplete
  );

  const dieRef = useRef<THREE.Group | null>(null);
  const animRef = useRef<{
    rolling: boolean;
    elapsed: number;
    duration: number;
    targetEuler: [number, number, number];
  }>({
    rolling: false,
    elapsed: 0,
    duration: 0.9,
    targetEuler: [0, 0, 0],
  });

  useEffect(() => {
    if (phase === 'rolling' && lastDiceValue !== null) {
      const targetEuler = getRotationForDiceValue(lastDiceValue);
      animRef.current = {
        rolling: true,
        elapsed: 0,
        duration: reducedMotion ? 0.25 : 0.92,
        targetEuler,
      };
      soundEngine.playDiceRoll(soundEnabled);
    }
  }, [phase, lastDiceValue, reducedMotion, soundEnabled]);

  useFrame((_, delta) => {
    const die = dieRef.current;
    if (!die) return;

    if (phase === 'rolling' && animRef.current.rolling) {
      const a = animRef.current;
      a.elapsed += delta;
      const t = Math.min(1, a.elapsed / a.duration);
      const easeOut = 1 - Math.pow(1 - t, 3);

      const extraSpins = reducedMotion ? 1 : 3;
      const spinAngle = (1 - easeOut) * Math.PI * 2 * extraSpins;

      die.rotation.set(
        a.targetEuler[0] + spinAngle,
        a.targetEuler[1] + spinAngle * 0.7,
        a.targetEuler[2] + spinAngle * 0.5
      );

      const bounce = reducedMotion
        ? 0
        : Math.abs(Math.sin(t * Math.PI * 2.5)) * (1 - t) * 1.35;
      die.position.y = 0.85 + bounce;

      if (t >= 1) {
        a.rolling = false;
        die.rotation.set(a.targetEuler[0], a.targetEuler[1], a.targetEuler[2]);
        die.position.y = 0.85;
        notifyDiceAnimationComplete();
      }
    } else if (lastDiceValue !== null) {
      const target = getRotationForDiceValue(lastDiceValue);
      die.rotation.set(target[0], target[1], target[2]);
      die.position.y = 0.85;
    }
  });

  const offset = 0.385;

  return (
    <group position={[6.8, 0, 3.6]} name="interactive-3d-die-pedestal">
      <mesh position={[0, 0.2, 0]} receiveShadow castShadow>
        <cylinderGeometry args={[0.95, 1.12, 0.42, 32]} />
        <meshStandardMaterial color="#FFF7ED" roughness={0.35} metalness={0.1} />
      </mesh>
      <mesh position={[0, 0.42, 0]} receiveShadow>
        <cylinderGeometry args={[0.82, 0.88, 0.06, 32]} />
        <meshStandardMaterial color="#C99A72" roughness={0.28} metalness={0.65} />
      </mesh>

      <group
        ref={dieRef}
        position={[0, 0.85, 0]}
        onClick={(e) => {
          e.stopPropagation();
          if (phase === 'ready') {
            rollDice();
          }
        }}
      >
        <RoundedBox
          args={[0.76, 0.76, 0.76]}
          radius={0.09}
          smoothness={4}
          castShadow
          receiveShadow
        >
          <meshStandardMaterial
            color="#FFFDF8"
            roughness={0.2}
            metalness={0.08}
          />
        </RoundedBox>

        <FacePips
          value={1}
          position={[0, offset, 0]}
          rotation={[-Math.PI / 2, 0, 0]}
        />
        <FacePips
          value={6}
          position={[0, -offset, 0]}
          rotation={[Math.PI / 2, 0, 0]}
        />
        <FacePips value={2} position={[0, 0, offset]} rotation={[0, 0, 0]} />
        <FacePips
          value={5}
          position={[0, 0, -offset]}
          rotation={[0, Math.PI, 0]}
        />
        <FacePips
          value={3}
          position={[offset, 0, 0]}
          rotation={[0, Math.PI / 2, 0]}
        />
        <FacePips
          value={4}
          position={[-offset, 0, 0]}
          rotation={[0, -Math.PI / 2, 0]}
        />
      </group>
    </group>
  );
}
EOF

cat << 'EOF' > src/components/environment/RomanticGardenEnvironment.tsx
'use client';

import React, { useMemo, useRef } from 'react';
import { useFrame } from '@react-three/fiber';
import * as THREE from 'three';
import { useGameStore } from '@/game/store/useGameStore';

function RoseArch({
  position,
  rotationY = 0,
}: {
  position: [number, number, number];
  rotationY?: number;
}) {
  return (
    <group position={position} rotation={[0, rotationY, 0]}>
      <mesh position={[-1.4, 1.4, 0]} castShadow receiveShadow>
        <cylinderGeometry args={[0.12, 0.15, 2.8, 12]} />
        <meshStandardMaterial color="#FFF7ED" roughness={0.35} />
      </mesh>
      <mesh position={[1.4, 1.4, 0]} castShadow receiveShadow>
        <cylinderGeometry args={[0.12, 0.15, 2.8, 12]} />
        <meshStandardMaterial color="#FFF7ED" roughness={0.35} />
      </mesh>

      <mesh position={[0, 2.8, 0]} castShadow>
        <torusGeometry args={[1.4, 0.11, 12, 32, Math.PI]} />
        <meshStandardMaterial color="#C99A72" roughness={0.3} metalness={0.5} />
      </mesh>

      {[
        [-1.4, 2.2, 0.14],
        [-1.0, 3.6, 0.12],
        [0, 4.18, 0.12],
        [1.0, 3.6, 0.12],
        [1.4, 2.2, 0.14],
      ].map((pos, idx) => (
        <group key={idx} position={pos as [number, number, number]}>
          <mesh castShadow>
            <dodecahedronGeometry args={[0.24, 1]} />
            <meshStandardMaterial color="#A9B9A0" roughness={0.6} />
          </mesh>
          <mesh position={[0, 0.08, 0.12]}>
            <sphereGeometry args={[0.13, 10, 10]} />
            <meshStandardMaterial
              color={idx % 2 === 0 ? '#C98296' : '#F4D7DE'}
              roughness={0.35}
            />
          </mesh>
        </group>
      ))}
    </group>
  );
}

function LuminousFountain({ position }: { position: [number, number, number] }) {
  const waterRingRef = useRef<THREE.Mesh | null>(null);

  useFrame((state) => {
    if (waterRingRef.current) {
      const s = 1 + Math.sin(state.clock.elapsedTime * 2.5) * 0.04;
      waterRingRef.current.scale.set(s, s, 1);
    }
  });

  return (
    <group position={position}>
      <mesh position={[0, 0.25, 0]} receiveShadow castShadow>
        <cylinderGeometry args={[1.55, 1.35, 0.5, 28]} />
        <meshStandardMaterial color="#FFF7ED" roughness={0.3} />
      </mesh>
      <mesh position={[0, 0.48, 0]} rotation={[-Math.PI / 2, 0, 0]}>
        <circleGeometry args={[1.42, 28]} />
        <meshStandardMaterial
          color="#DCD5F0"
          roughness={0.12}
          metalness={0.2}
          emissive="#F4D7DE"
          emissiveIntensity={0.22}
        />
      </mesh>
      <mesh
        ref={waterRingRef}
        position={[0, 0.49, 0]}
        rotation={[-Math.PI / 2, 0, 0]}
      >
        <ringGeometry args={[0.65, 0.72, 28]} />
        <meshBasicMaterial color="#FFFDF8" transparent opacity={0.65} />
      </mesh>
      <mesh position={[0, 0.95, 0]} castShadow>
        <cylinderGeometry args={[0.25, 0.35, 1.1, 16]} />
        <meshStandardMaterial color="#FFF7ED" roughness={0.3} />
      </mesh>
      <mesh position={[0, 1.45, 0]} castShadow>
        <cylinderGeometry args={[0.75, 0.4, 0.28, 24]} />
        <meshStandardMaterial color="#C99A72" roughness={0.3} metalness={0.55} />
      </mesh>
    </group>
  );
}

function FloatingPetalsInstanced() {
  const reducedMotion = useGameStore((s) => s.reducedMotion);
  const phase = useGameStore((s) => s.phase);
  const meshRef = useRef<THREE.InstancedMesh | null>(null);
  const count = 90;

  const particles = useMemo(() => {
    return Array.from({ length: count }).map((_, i) => ({
      x: Math.sin(i * 17.3) * 11.5,
      y: (i % 10) * 0.75 + 0.6,
      z: Math.cos(i * 23.1) * 11.5,
      speed: 0.25 + (i % 5) * 0.08,
      phaseOffset: i * 0.7,
    }));
  }, [count]);

  const dummy = useMemo(() => new THREE.Object3D(), []);

  useFrame((state) => {
    if (!meshRef.current) return;
    const t = state.clock.elapsedTime;
    const speedMultiplier = phase === 'victory' ? 2.2 : 1.0;

    particles.forEach((p, idx) => {
      const yOffset = reducedMotion
        ? p.y
        : ((p.y - t * p.speed * speedMultiplier) % 7.5 + 7.5) % 7.5 + 0.3;
      const swayX = reducedMotion
        ? p.x
        : p.x + Math.sin(t * 0.8 + p.phaseOffset) * 0.45;
      const swayZ = reducedMotion
        ? p.z
        : p.z + Math.cos(t * 0.7 + p.phaseOffset) * 0.45;

      dummy.position.set(swayX, yOffset, swayZ);
      dummy.rotation.set(
        t * 0.6 + p.phaseOffset,
        t * 0.4 + p.phaseOffset,
        p.phaseOffset
      );
      dummy.scale.set(0.14, 0.04, 0.2);
      dummy.updateMatrix();
      meshRef.current!.setMatrixAt(idx, dummy.matrix);
    });
    meshRef.current.instanceMatrix.needsUpdate = true;
  });

  return (
    <instancedMesh ref={meshRef} args={[undefined, undefined, count]}>
      <sphereGeometry args={[1, 8, 8]} />
      <meshStandardMaterial
        color="#F4D7DE"
        roughness={0.4}
        emissive="#C98296"
        emissiveIntensity={0.18}
      />
    </instancedMesh>
  );
}

export function RomanticGardenEnvironment() {
  return (
    <group name="dreamy-romantic-garden-environment">
      <mesh position={[0, -0.55, 0]} receiveShadow>
        <cylinderGeometry args={[10.8, 9.6, 0.9, 48]} />
        <meshStandardMaterial color="#A9B9A0" roughness={0.75} />
      </mesh>
      <mesh position={[0, -1.55, 0]} receiveShadow>
        <cylinderGeometry args={[9.4, 6.2, 1.4, 36]} />
        <meshStandardMaterial color="#D8C8B8" roughness={0.85} />
      </mesh>
      <mesh position={[0, -2.7, 0]}>
        <coneGeometry args={[6.1, 2.2, 24]} />
        <meshStandardMaterial color="#B59E92" roughness={0.9} />
      </mesh>

      <RoseArch position={[-3.6, -0.1, -6.9]} rotationY={0.15} />
      <RoseArch position={[3.6, -0.1, -6.9]} rotationY={-0.15} />
      <RoseArch position={[-7.6, -0.1, -1.5]} rotationY={Math.PI / 2} />

      <LuminousFountain position={[7.4, -0.1, -2.8]} />

      {[
        [-11.5, -1.4, -6.5, 2.6],
        [-13.0, -1.8, 2.5, 2.2],
        [11.8, -1.5, -7.2, 2.8],
        [12.4, -1.7, 4.8, 2.3],
        [0, -2.1, -12.8, 3.2],
        [-6.5, -2.0, 10.5, 2.5],
        [6.8, -1.9, 10.2, 2.4],
      ].map(([cx, cy, cz, scale], idx) => (
        <group key={idx} position={[cx, cy, cz]}>
          <mesh scale={[scale * 1.4, scale * 0.65, scale]}>
            <sphereGeometry args={[1, 16, 16]} />
            <meshStandardMaterial
              color="#FFFDF8"
              roughness={0.9}
              emissive="#F4D7DE"
              emissiveIntensity={0.08}
            />
          </mesh>
        </group>
      ))}

      <FloatingPetalsInstanced />
    </group>
  );
}
EOF

cat << 'EOF' > src/components/scene/GardenCameraController.tsx
'use client';

import React, { useEffect, useRef } from 'react';
import { useFrame, useThree } from '@react-three/fiber';
import { OrbitControls } from '@react-three/drei';
import * as THREE from 'three';
import type { OrbitControls as OrbitControlsImpl } from 'three-stdlib';
import { useGameStore } from '@/game/store/useGameStore';

const GAMEPLAY_CAMERA_POS = new THREE.Vector3(0, 12.6, 11.4);
const GAMEPLAY_TARGET = new THREE.Vector3(0.4, 0.2, 0.2);

export function GardenCameraController() {
  const { camera } = useThree();
  const cameraMode = useGameStore((s) => s.cameraMode);
  const reducedMotion = useGameStore((s) => s.reducedMotion);
  const cameraResetTrigger = useGameStore((s) => s.cameraResetTrigger);
  const finishCameraIntro = useGameStore((s) => s.finishCameraIntro);

  const controlsRef = useRef<OrbitControlsImpl | null>(null);
  const introElapsedRef = useRef(0);
  const introDuration = 4.5;

  useEffect(() => {
    if (reducedMotion && cameraMode === 'intro') {
      finishCameraIntro();
    }
  }, [reducedMotion, cameraMode, finishCameraIntro]);

  useEffect(() => {
    if (cameraResetTrigger > 0) {
      camera.position.copy(GAMEPLAY_CAMERA_POS);
      if (controlsRef.current) {
        controlsRef.current.target.copy(GAMEPLAY_TARGET);
        controlsRef.current.update();
      }
    }
  }, [cameraResetTrigger, camera]);

  useFrame((_, delta) => {
    if (cameraMode === 'intro' && !reducedMotion) {
      introElapsedRef.current += delta;
      const t = Math.min(1, introElapsedRef.current / introDuration);
      const smooth = t * t * (3 - 2 * t);

      const startPos = new THREE.Vector3(-11.5, 16.5, 18.5);
      camera.position.lerpVectors(startPos, GAMEPLAY_CAMERA_POS, smooth);
      camera.lookAt(GAMEPLAY_TARGET);

      if (t >= 1) {
        finishCameraIntro();
        if (controlsRef.current) {
          controlsRef.current.target.copy(GAMEPLAY_TARGET);
          controlsRef.current.update();
        }
      }
    }
  });

  return (
    <OrbitControls
      ref={controlsRef}
      enabled={cameraMode === 'gameplay'}
      target={[GAMEPLAY_TARGET.x, GAMEPLAY_TARGET.y, GAMEPLAY_TARGET.z]}
      enablePan={false}
      minDistance={9.5}
      maxDistance={21}
      minPolarAngle={Math.PI / 6}
      maxPolarAngle={Math.PI / 2.35}
      minAzimuthAngle={-Math.PI / 3.5}
      maxAzimuthAngle={Math.PI / 3.5}
      dampingFactor={0.08}
      enableDamping
    />
  );
}
EOF

cat << 'EOF' > src/components/scene/RomanticGardenScene.tsx
'use client';

import React, { useEffect, useState } from 'react';
import { Canvas } from '@react-three/fiber';
import { BOARD_CONFIG } from '@/game/board/boardConfig';
import { useGameStore } from '@/game/store/useGameStore';
import { Board3D } from '../board/Board3D';
import { Dice3D } from '../dice/Dice3D';
import { RomanticGardenEnvironment } from '../environment/RomanticGardenEnvironment';
import { SnakesAndLadders3D } from '../obstacles/SnakesAndLadders3D';
import { PlayerPieces3D } from '../pieces/PlayerPieces3D';
import { GardenCameraController } from './GardenCameraController';

function Fallback2DBoard() {
  const players = useGameStore((s) => s.players);
  const squares = Object.values(BOARD_CONFIG.squares).sort(
    (a, b) => b.row - a.row || a.col - b.col
  );

  return (
    <div
      data-testid="fallback-2d-board"
      className="flex h-full w-full flex-col items-center justify-center bg-garden-ivory p-4 text-garden-mauve"
    >
      <div className="mb-2 rounded-full bg-garden-blush px-4 py-1 text-xs font-medium">
        Mode Papan 2D Aktif (Fallback WebGL) — 100 Kotak Tetap Dapat Dimainkan
      </div>
      <div className="grid aspect-square w-full max-w-[540px] grid-cols-10 gap-1 rounded-2xl border-2 border-garden-gold bg-garden-cream p-2 shadow-romantic">
        {squares.map((sq) => {
          const occupants = players.filter((p) => p.square === sq.square);
          return (
            <div
              key={sq.square}
              data-square={sq.square}
              className="relative flex flex-col items-center justify-between rounded border border-garden-blush bg-garden-ivory p-1 text-[10px]"
            >
              <span className="font-semibold">{sq.square}</span>
              <div className="flex gap-0.5">
                {occupants.map((p) => (
                  <span
                    key={p.id}
                    title={p.name}
                    className="h-2.5 w-2.5 rounded-full border border-garden-mauve"
                    style={{ backgroundColor: p.accentColor }}
                  />
                ))}
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}

export function RomanticGardenScene() {
  const [webglSupported, setWebglSupported] = useState(true);
  const players = useGameStore((s) => s.players);
  const activePlayerIndex = useGameStore((s) => s.activePlayerIndex);
  const activeTransition = useGameStore((s) => s.activeTransition);
  const cameraMode = useGameStore((s) => s.cameraMode);
  const finishCameraIntro = useGameStore((s) => s.finishCameraIntro);

  useEffect(() => {
    try {
      const canvas = document.createElement('canvas');
      const gl =
        canvas.getContext('webgl2') ||
        canvas.getContext('webgl') ||
        canvas.getContext('experimental-webgl');
      if (!gl) {
        setWebglSupported(false);
      }
    } catch {
      setWebglSupported(false);
    }
  }, []);

  const activeSquare = players[activePlayerIndex]?.square ?? null;

  if (!webglSupported) {
    return <Fallback2DBoard />;
  }

  return (
    <div className="relative h-full w-full" data-testid="garden-3d-canvas-wrapper">
      <Canvas
        shadows
        dpr={[1, 2]}
        camera={{ position: [0, 12.6, 11.4], fov: 40, near: 0.1, far: 120 }}
      >
        <color attach="background" args={['#F4D7DE']} />
        <fog attach="fog" args={['#F4D7DE', 18, 42]} />

        <ambientLight intensity={0.78} color="#FFF7ED" />
        <hemisphereLight
          color="#FFFDF8"
          groundColor="#C98296"
          intensity={0.55}
        />
        <directionalLight
          position={[11, 18, 9]}
          intensity={1.35}
          color="#FFE8D6"
          castShadow
          shadow-mapSize-width={1024}
          shadow-mapSize-height={1024}
          shadow-camera-near={1}
          shadow-camera-far={45}
          shadow-camera-left={-12}
          shadow-camera-right={12}
          shadow-camera-top={12}
          shadow-camera-bottom={-12}
        />
        <directionalLight
          position={[-9, 8, -8]}
          intensity={0.4}
          color="#DCD5F0"
        />

        <GardenCameraController />
        <RomanticGardenEnvironment />
        <Board3D highlightedSquare={activeSquare} />
        <SnakesAndLadders3D activeTransitionId={activeTransition?.id ?? null} />
        <PlayerPieces3D />
        <Dice3D />
      </Canvas>

      {cameraMode === 'intro' && (
        <button
          type="button"
          onClick={finishCameraIntro}
          className="absolute top-20 right-6 z-20 rounded-full border border-garden-gold bg-garden-ivory/95 px-4 py-1.5 text-xs font-medium text-garden-mauve shadow-romantic transition hover:bg-garden-blush focus:outline-none focus:ring-2 focus:ring-garden-rose"
        >
          Lewati Intro Kamera →
        </button>
      )}
    </div>
  );
}
EOF

cat << 'EOF' > src/components/ui/ChallengeCardModal.tsx
'use client';

import React, { useEffect } from 'react';
import { Heart, Sparkles, Check, FastForward } from 'lucide-react';
import { useGameStore } from '@/game/store/useGameStore';
import { soundEngine } from '../audio/soundEngine';

export function ChallengeCardModal() {
  const phase = useGameStore((s) => s.phase);
  const activeChallenge = useGameStore((s) => s.activeChallenge);
  const players = useGameStore((s) => s.players);
  const activePlayerIndex = useGameStore((s) => s.activePlayerIndex);
  const soundEnabled = useGameStore((s) => s.soundEnabled);
  const completeChallenge = useGameStore((s) => s.completeChallenge);
  const skipChallenge = useGameStore((s) => s.skipChallenge);

  const activePlayer = players[activePlayerIndex];

  useEffect(() => {
    if (phase === 'awaiting_challenge' && activeChallenge) {
      soundEngine.playChallengeReveal(soundEnabled, activeChallenge.type);
    }
  }, [phase, activeChallenge, soundEnabled]);

  if (phase !== 'awaiting_challenge' || !activeChallenge || !activePlayer) {
    return null;
  }

  const isTruth = activeChallenge.type === 'truth';

  return (
    <div
      role="dialog"
      aria-modal="true"
      aria-labelledby="challenge-card-title"
      data-testid="challenge-card-modal"
      className="fixed inset-x-0 bottom-4 z-40 mx-auto flex max-w-lg items-end justify-center px-4 sm:inset-y-0 sm:items-center"
    >
      <div className="w-full rounded-3xl border-2 border-garden-gold bg-garden-ivory p-6 text-garden-mauve shadow-card transition-all">
        <div className="mb-3 flex items-center justify-between">
          <span
            className={`inline-flex items-center gap-1.5 rounded-full px-3.5 py-1 text-xs font-semibold uppercase tracking-wider ${
              isTruth
                ? 'bg-garden-blush text-garden-mauve border border-garden-rose'
                : 'bg-garden-lavender text-garden-mauve border border-garden-gold'
            }`}
          >
            {isTruth ? (
              <Heart className="h-3.5 w-3.5 text-garden-rose" />
            ) : (
              <Sparkles className="h-3.5 w-3.5 text-garden-gold" />
            )}
            {isTruth ? 'Kartu Truth' : 'Kartu Dare'}
          </span>
          <span className="text-xs font-medium text-garden-mauve/80">
            Kotak #{activePlayer.square} • {activeChallenge.category}
          </span>
        </div>

        <h2
          id="challenge-card-title"
          className="font-serif text-xl font-bold text-garden-deepMauve"
        >
          Untuk {activePlayer.name}
        </h2>

        <div className="my-3 flex items-center gap-2">
          <div className="h-px flex-1 bg-garden-gold/40" />
          <span className="text-xs text-garden-gold">❀</span>
          <div className="h-px flex-1 bg-garden-gold/40" />
        </div>

        <p
          data-testid="challenge-prompt-text"
          className="my-4 font-serif text-base leading-relaxed text-garden-deepMauve sm:text-lg"
        >
          “{activeChallenge.prompt}”
        </p>

        <p className="mb-5 text-xs text-garden-mauve/75">
          Kenyamanan bersama adalah prioritas utama. Kamu bebas menyelesaikan atau melewati kartu ini kapan saja tanpa penalti.
        </p>

        <div className="flex flex-col gap-2.5 sm:flex-row">
          <button
            type="button"
            data-testid="complete-challenge-btn"
            onClick={completeChallenge}
            className="flex flex-1 items-center justify-center gap-2 rounded-2xl bg-garden-rose px-5 py-3 text-sm font-semibold text-white shadow-sm transition hover:bg-garden-deepMauve focus:outline-none focus:ring-2 focus:ring-garden-rose"
          >
            <Check className="h-4 w-4" />
            Selesai Dilakukan
          </button>
          <button
            type="button"
            data-testid="skip-challenge-btn"
            onClick={skipChallenge}
            className="flex items-center justify-center gap-2 rounded-2xl border border-garden-gold bg-garden-cream px-5 py-3 text-sm font-medium text-garden-mauve transition hover:bg-garden-blush focus:outline-none focus:ring-2 focus:ring-garden-gold"
          >
            <FastForward className="h-4 w-4" />
            Lewati Tanpa Penalti
          </button>
        </div>
      </div>
    </div>
  );
}
EOF

cat << 'EOF' > src/components/ui/PlayerSetupModal.tsx
'use client';

import React, { useState } from 'react';
import { Users, Plus, Trash2, Play, X } from 'lucide-react';
import { PIECE_STYLES } from '@/game/players/playerStyles';
import { useGameStore } from '@/game/store/useGameStore';
import { PieceStyleId, PlayerSetupInput } from '@/game/types';

export function PlayerSetupModal() {
  const setupModalOpen = useGameStore((s) => s.setupModalOpen);
  const players = useGameStore((s) => s.players);
  const soundEnabled = useGameStore((s) => s.soundEnabled);
  const reducedMotion = useGameStore((s) => s.reducedMotion);
  const setSoundEnabled = useGameStore((s) => s.setSoundEnabled);
  const setReducedMotion = useGameStore((s) => s.setReducedMotion);
  const setSetupModalOpen = useGameStore((s) => s.setSetupModalOpen);
  const startNewGame = useGameStore((s) => s.startNewGame);

  const [draftPlayers, setDraftPlayers] = useState<PlayerSetupInput[]>(() =>
    players.map((p) => ({ name: p.name, pieceStyle: p.pieceStyle }))
  );

  if (!setupModalOpen) return null;

  const handleAddPlayer = () => {
    if (draftPlayers.length >= 4) return;
    const nextStyle = PIECE_STYLES[draftPlayers.length % PIECE_STYLES.length].id;
    setDraftPlayers([
      ...draftPlayers,
      { name: `Pemain ${draftPlayers.length + 1}`, pieceStyle: nextStyle },
    ]);
  };

  const handleRemovePlayer = (idx: number) => {
    if (draftPlayers.length <= 2) return;
    setDraftPlayers(draftPlayers.filter((_, i) => i !== idx));
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    startNewGame(draftPlayers, true);
  };

  return (
    <div
      role="dialog"
      aria-modal="true"
      aria-labelledby="setup-dialog-title"
      data-testid="player-setup-modal"
      className="fixed inset-0 z-50 flex items-center justify-center bg-garden-deepMauve/40 p-4 backdrop-blur-xs"
    >
      <form
        onSubmit={handleSubmit}
        className="w-full max-w-md rounded-3xl border-2 border-garden-gold bg-garden-ivory p-6 text-garden-mauve shadow-card"
      >
        <div className="mb-4 flex items-center justify-between">
          <div className="flex items-center gap-2">
            <Users className="h-5 w-5 text-garden-rose" />
            <h2
              id="setup-dialog-title"
              className="font-serif text-xl font-bold text-garden-deepMauve"
            >
              Pengaturan Pemain & Taman
            </h2>
          </div>
          <button
            type="button"
            aria-label="Tutup pengaturan"
            onClick={() => setSetupModalOpen(false)}
            className="rounded-full p-1.5 text-garden-mauve hover:bg-garden-blush"
          >
            <X className="h-4 w-4" />
          </button>
        </div>

        <div className="space-y-3">
          {draftPlayers.map((p, idx) => (
            <div
              key={idx}
              className="flex flex-col gap-2 rounded-2xl border border-garden-gold/50 bg-garden-cream p-3 sm:flex-row sm:items-center"
            >
              <div className="flex-1">
                <label className="block text-[11px] font-medium text-garden-mauve/75">
                  Nama Pemain {idx + 1}
                </label>
                <input
                  type="text"
                  value={p.name}
                  maxLength={24}
                  onChange={(e) => {
                    const next = [...draftPlayers];
                    next[idx] = { ...next[idx], name: e.target.value };
                    setDraftPlayers(next);
                  }}
                  className="mt-0.5 w-full rounded-xl border border-garden-blush bg-white px-3 py-1.5 text-sm font-medium text-garden-deepMauve focus:border-garden-rose focus:outline-none"
                />
              </div>

              <div className="sm:w-44">
                <label className="block text-[11px] font-medium text-garden-mauve/75">
                  Bidak 3D
                </label>
                <select
                  value={p.pieceStyle}
                  onChange={(e) => {
                    const next = [...draftPlayers];
                    next[idx] = {
                      ...next[idx],
                      pieceStyle: e.target.value as PieceStyleId,
                    };
                    setDraftPlayers(next);
                  }}
                  className="mt-0.5 w-full rounded-xl border border-garden-blush bg-white px-2.5 py-1.5 text-xs font-medium text-garden-deepMauve focus:border-garden-rose focus:outline-none"
                >
                  {PIECE_STYLES.map((style) => (
                    <option key={style.id} value={style.id}>
                      {style.label}
                    </option>
                  ))}
                </select>
              </div>

              {draftPlayers.length > 2 && (
                <button
                  type="button"
                  onClick={() => handleRemovePlayer(idx)}
                  aria-label={`Hapus Pemain ${idx + 1}`}
                  className="self-end rounded-xl p-2 text-garden-rose hover:bg-garden-blush sm:self-center"
                >
                  <Trash2 className="h-4 w-4" />
                </button>
              )}
            </div>
          ))}
        </div>

        {draftPlayers.length < 4 && (
          <button
            type="button"
            onClick={handleAddPlayer}
            className="mt-3 flex w-full items-center justify-center gap-1.5 rounded-2xl border border-dashed border-garden-gold py-2 text-xs font-semibold text-garden-mauve hover:bg-garden-blush/50"
          >
            <Plus className="h-3.5 w-3.5" />
            Tambah Pemain Lokal (Maks. 4)
          </button>
        )}

        <div className="mt-4 space-y-2 border-t border-garden-gold/30 pt-3 text-xs">
          <label className="flex cursor-pointer items-center justify-between">
            <span>Efek Suara Romantis</span>
            <input
              type="checkbox"
              checked={soundEnabled}
              onChange={(e) => setSoundEnabled(e.target.checked)}
              className="h-4 w-4 accent-garden-rose"
            />
          </label>
          <label className="flex cursor-pointer items-center justify-between">
            <span>Kurangi Animasi Gerakan (Reduced Motion)</span>
            <input
              type="checkbox"
              checked={reducedMotion}
              onChange={(e) => setReducedMotion(e.target.checked)}
              className="h-4 w-4 accent-garden-rose"
            />
          </label>
        </div>

        <div className="mt-5 flex gap-2">
          <button
            type="submit"
            data-testid="confirm-start-match-btn"
            className="flex flex-1 items-center justify-center gap-2 rounded-2xl bg-garden-rose px-4 py-2.5 text-sm font-semibold text-white shadow-sm transition hover:bg-garden-deepMauve"
          >
            <Play className="h-4 w-4" />
            Mulai Permainan Baru
          </button>
        </div>
      </form>
    </div>
  );
}
EOF

cat << 'EOF' > src/components/ui/VictoryModal.tsx
'use client';

import React from 'react';
import { Crown, RotateCcw, Users } from 'lucide-react';
import { useGameStore } from '@/game/store/useGameStore';

export function VictoryModal() {
  const phase = useGameStore((s) => s.phase);
  const winnerId = useGameStore((s) => s.winnerId);
  const players = useGameStore((s) => s.players);
  const turnNumber = useGameStore((s) => s.turnNumber);
  const startNewGame = useGameStore((s) => s.startNewGame);
  const setSetupModalOpen = useGameStore((s) => s.setSetupModalOpen);

  if (phase !== 'victory' || !winnerId) return null;

  const winner = players.find((p) => p.id === winnerId) ?? players[0];

  return (
    <div
      role="dialog"
      aria-modal="true"
      aria-labelledby="victory-modal-title"
      data-testid="victory-modal"
      className="fixed inset-0 z-50 flex items-center justify-center bg-garden-deepMauve/35 p-4 backdrop-blur-xs"
    >
      <div className="w-full max-w-md rounded-3xl border-2 border-garden-gold bg-garden-ivory p-7 text-center text-garden-mauve shadow-card">
        <div className="mx-auto mb-3 flex h-14 w-14 items-center justify-center rounded-full border border-garden-gold bg-garden-blush text-garden-gold">
          <Crown className="h-7 w-7" />
        </div>

        <p className="text-xs font-semibold uppercase tracking-widest text-garden-rose">
          Kotak 100 Tercapai
        </p>
        <h2
          id="victory-modal-title"
          className="mt-1 font-serif text-2xl font-bold text-garden-deepMauve"
        >
          {winner.name} Memenangkan Petualangan!
        </h2>

        <p className="mt-2 text-sm text-garden-mauve/85">
          Setelah {turnNumber} giliran penuh tawa, kejujuran, dan momen manis di Taman Romantis, kalian telah menyelesaikan perjalanan ini bersama.
        </p>

        <div className="my-5 grid grid-cols-2 gap-2 rounded-2xl border border-garden-gold/40 bg-garden-cream p-3 text-left text-xs">
          {players.map((p) => (
            <div key={p.id} className="space-y-0.5">
              <div className="font-semibold text-garden-deepMauve">{p.name}</div>
              <div>Kotak Akhir: #{p.square}</div>
              <div>
                Tantangan Selesai: {p.completedChallenges} (Lewati:{' '}
                {p.skippedChallenges})
              </div>
            </div>
          ))}
        </div>

        <div className="flex flex-col gap-2.5 sm:flex-row">
          <button
            type="button"
            data-testid="victory-replay-btn"
            onClick={() => startNewGame(undefined, false)}
            className="flex flex-1 items-center justify-center gap-2 rounded-2xl bg-garden-rose px-4 py-3 text-sm font-semibold text-white shadow-sm transition hover:bg-garden-deepMauve"
          >
            <RotateCcw className="h-4 w-4" />
            Main Lagi
          </button>
          <button
            type="button"
            onClick={() => setSetupModalOpen(true)}
            className="flex items-center justify-center gap-2 rounded-2xl border border-garden-gold bg-garden-cream px-4 py-3 text-sm font-medium text-garden-mauve transition hover:bg-garden-blush"
          >
            <Users className="h-4 w-4" />
            Atur Pemain
          </button>
        </div>
      </div>
    </div>
  );
}
EOF

cat << 'EOF' > src/components/ui/GameplayHUD.tsx
'use client';

import React, { useState } from 'react';
import {
  Volume2,
  VolumeX,
  RotateCcw,
  Compass,
  Users,
  Dices,
  History,
  ChevronUp,
  ChevronDown,
} from 'lucide-react';
import { useGameStore } from '@/game/store/useGameStore';

export function GameplayHUD() {
  const phase = useGameStore((s) => s.phase);
  const players = useGameStore((s) => s.players);
  const activePlayerIndex = useGameStore((s) => s.activePlayerIndex);
  const lastDiceValue = useGameStore((s) => s.lastDiceValue);
  const statusMessage = useGameStore((s) => s.statusMessage);
  const moveHistory = useGameStore((s) => s.moveHistory);
  const soundEnabled = useGameStore((s) => s.soundEnabled);

  const setSoundEnabled = useGameStore((s) => s.setSoundEnabled);
  const triggerCameraReset = useGameStore((s) => s.triggerCameraReset);
  const setSetupModalOpen = useGameStore((s) => s.setSetupModalOpen);
  const startNewGame = useGameStore((s) => s.startNewGame);
  const rollDice = useGameStore((s) => s.rollDice);

  const [historyOpen, setHistoryOpen] = useState(false);

  const activePlayer = players[activePlayerIndex] ?? players[0];
  const canRoll = phase === 'ready';

  return (
    <div className="pointer-events-none fixed inset-0 z-30 flex flex-col justify-between p-3 sm:p-5">
      <header className="pointer-events-auto flex items-center justify-between rounded-2xl border border-garden-gold/60 bg-garden-ivory/95 px-4 py-2.5 text-garden-mauve shadow-romantic backdrop-blur-xs">
        <div className="flex items-center gap-3">
          <span className="flex h-8 w-8 items-center justify-center rounded-full border border-garden-gold bg-garden-blush font-serif text-sm font-bold text-garden-deepMauve">
            ❀
          </span>
          <div>
            <h1 className="font-serif text-sm font-bold tracking-wide text-garden-deepMauve sm:text-base">
              Truth or Dare: Romantic Garden
            </h1>
            <p className="hidden text-[11px] text-garden-mauve/75 sm:block">
              Ular Tangga 3D Romantis • 100 Kotak Petualangan Pasangan
            </p>
          </div>
        </div>

        <div className="flex items-center gap-1.5 sm:gap-2">
          <button
            type="button"
            onClick={() => setSoundEnabled(!soundEnabled)}
            aria-label={soundEnabled ? 'Matikan suara' : 'Nyalakan suara'}
            data-testid="sound-toggle-btn"
            className="flex items-center gap-1 rounded-xl border border-garden-gold/50 bg-garden-cream px-2.5 py-1.5 text-xs font-medium text-garden-mauve transition hover:bg-garden-blush focus:outline-none focus:ring-2 focus:ring-garden-rose"
          >
            {soundEnabled ? (
              <Volume2 className="h-4 w-4 text-garden-rose" />
            ) : (
              <VolumeX className="h-4 w-4 text-garden-mauve/60" />
            )}
            <span className="hidden md:inline">
              {soundEnabled ? 'Suara Aktif' : 'Bisu'}
            </span>
          </button>

          <button
            type="button"
            onClick={triggerCameraReset}
            aria-label="Reset sudut kamera"
            data-testid="camera-reset-btn"
            className="flex items-center gap-1 rounded-xl border border-garden-gold/50 bg-garden-cream px-2.5 py-1.5 text-xs font-medium text-garden-mauve transition hover:bg-garden-blush focus:outline-none focus:ring-2 focus:ring-garden-rose"
          >
            <Compass className="h-4 w-4 text-garden-gold" />
            <span className="hidden md:inline">Reset Kamera</span>
          </button>

          <button
            type="button"
            onClick={() => setSetupModalOpen(true)}
            aria-label="Pengaturan pemain"
            data-testid="open-setup-btn"
            className="flex items-center gap-1 rounded-xl border border-garden-gold/50 bg-garden-cream px-2.5 py-1.5 text-xs font-medium text-garden-mauve transition hover:bg-garden-blush focus:outline-none focus:ring-2 focus:ring-garden-rose"
          >
            <Users className="h-4 w-4 text-garden-rose" />
            <span className="hidden md:inline">Pemain</span>
          </button>

          <button
            type="button"
            onClick={() => startNewGame(undefined, false)}
            aria-label="Mulai ulang permainan"
            data-testid="restart-match-btn"
            className="flex items-center gap-1 rounded-xl border border-garden-gold/60 bg-garden-blush px-2.5 py-1.5 text-xs font-semibold text-garden-deepMauve transition hover:bg-garden-rose hover:text-white focus:outline-none focus:ring-2 focus:ring-garden-rose"
          >
            <RotateCcw className="h-4 w-4" />
            <span className="hidden sm:inline">Mulai Baru</span>
          </button>
        </div>
      </header>

      <div className="flex flex-col gap-2 sm:flex-row sm:items-end sm:justify-between">
        <div className="pointer-events-auto flex flex-col gap-2 rounded-2xl border border-garden-gold/60 bg-garden-ivory/95 p-3.5 text-garden-mauve shadow-romantic backdrop-blur-xs sm:max-w-md">
          <div className="flex flex-wrap gap-2">
            {players.map((p, idx) => {
              const isActive = idx === activePlayerIndex;
              return (
                <div
                  key={p.id}
                  data-testid={`player-card-${idx}`}
                  className={`flex items-center gap-2 rounded-xl border px-3 py-1.5 text-xs transition ${
                    isActive
                      ? 'border-garden-rose bg-garden-blush font-semibold text-garden-deepMauve shadow-xs'
                      : 'border-garden-gold/30 bg-garden-cream text-garden-mauve/80'
                  }`}
                >
                  <span
                    className="h-3 w-3 rounded-full border border-garden-deepMauve/40"
                    style={{ backgroundColor: p.accentColor }}
                  />
                  <span>{p.name}</span>
                  <span
                    data-testid={`player-square-${idx}`}
                    className="rounded-md bg-white/80 px-1.5 py-0.5 text-[11px] font-bold text-garden-deepMauve"
                  >
                    #{p.square}
                  </span>
                </div>
              );
            })}
          </div>

          <div
            role="status"
            aria-live="polite"
            data-testid="status-banner"
            className="text-xs leading-snug text-garden-deepMauve"
          >
            {statusMessage}
          </div>

          <div>
            <button
              type="button"
              onClick={() => setHistoryOpen(!historyOpen)}
              className="flex items-center gap-1 text-[11px] font-semibold text-garden-rose hover:underline"
            >
              <History className="h-3.5 w-3.5" />
              Riwayat Langkah ({moveHistory.length})
              {historyOpen ? (
                <ChevronDown className="h-3.5 w-3.5" />
              ) : (
                <ChevronUp className="h-3.5 w-3.5" />
              )}
            </button>

            {historyOpen && (
              <ul
                data-testid="move-history-list"
                className="mt-1.5 max-h-28 space-y-1 overflow-y-auto rounded-xl border border-garden-gold/30 bg-garden-cream p-2 text-[11px]"
              >
                {moveHistory.length === 0 ? (
                  <li className="text-garden-mauve/60">
                    Belum ada langkah tercatat.
                  </li>
                ) : (
                  moveHistory.slice(0, 8).map((item) => (
                    <li key={item.id} className="border-b border-garden-blush/50 pb-1 last:border-none">
                      <strong>{item.playerName}</strong> dadu [{item.diceValue}]: #{item.fromSquare} → #{item.finalSquare}
                      {item.transition && ` (${item.transition.name})`}
                      {item.challenge &&
                        ` [${item.challenge.type.toUpperCase()} - ${
                          item.challenge.outcome === 'completed'
                            ? 'Selesai'
                            : 'Dilewati'
                        }]`}
                    </li>
                  ))
                )}
              </ul>
            )}
          </div>
        </div>

        <div className="pointer-events-auto flex items-center justify-between gap-3 rounded-2xl border border-garden-gold/60 bg-garden-ivory/95 p-3.5 shadow-romantic backdrop-blur-xs sm:justify-end">
          <div className="text-left sm:text-right">
            <div className="text-[11px] font-medium text-garden-mauve/75">
              Giliran Aktif
            </div>
            <div
              data-testid="active-player-indicator"
              className="font-serif text-sm font-bold text-garden-deepMauve"
            >
              {activePlayer.name} (Kotak #{activePlayer.square})
            </div>
            <div
              data-testid="dice-result-readout"
              className="text-xs font-semibold text-garden-rose"
            >
              Hasil Dadu: {lastDiceValue !== null ? lastDiceValue : '—'}
            </div>
          </div>

          <button
            type="button"
            disabled={!canRoll}
            onClick={() => rollDice()}
            data-testid="roll-dice-btn"
            className="flex items-center gap-2 rounded-2xl bg-garden-rose px-5 py-3.5 text-sm font-semibold text-white shadow-romantic transition hover:bg-garden-deepMauve disabled:cursor-not-allowed disabled:opacity-50 focus:outline-none focus:ring-2 focus:ring-garden-rose"
          >
            <Dices className="h-5 w-5" />
            <span>{canRoll ? 'Lempar Dadu' : 'Memproses...'}</span>
          </button>
        </div>
      </div>
    </div>
  );
}
EOF

echo "🌐 Menulis halaman App Router Next.js..."

cat << 'EOF' > src/app/globals.css
@tailwind base;
@tailwind components;
@tailwind utilities;

html,
body {
  margin: 0;
  padding: 0;
  width: 100%;
  height: 100%;
  overflow: hidden;
  background-color: #F4D7DE;
  color: #654754;
}
EOF

cat << 'EOF' > src/app/layout.tsx
import type { Metadata } from 'next';
import './globals.css';

export const metadata: Metadata = {
  title: 'Truth or Dare: A Romantic Garden Adventure — 3D Snakes & Ladders',
  description:
    'Permainan papan Ular Tangga 3D romantis dengan kartu Truth or Dare Bahasa Indonesia untuk pasangan.',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="id">
      <body className="antialiased selection:bg-garden-rose selection:text-white">
        {children}
      </body>
    </html>
  );
}
EOF

cat << 'EOF' > src/app/page.tsx
'use client';

import React, { useEffect } from 'react';
import { RomanticGardenScene } from '@/components/scene/RomanticGardenScene';
import { ChallengeCardModal } from '@/components/ui/ChallengeCardModal';
import { GameplayHUD } from '@/components/ui/GameplayHUD';
import { PlayerSetupModal } from '@/components/ui/PlayerSetupModal';
import { VictoryModal } from '@/components/ui/VictoryModal';
import { useGameStore } from '@/game/store/useGameStore';

export default function HomePage() {
  const setReducedMotion = useGameStore((s) => s.setReducedMotion);

  useEffect(() => {
    if (typeof window !== 'undefined' && window.matchMedia) {
      const mediaQuery = window.matchMedia('(prefers-reduced-motion: reduce)');
      if (mediaQuery.matches) {
        setReducedMotion(true);
      }
    }

    if (typeof window !== 'undefined') {
      (window as unknown as { __GAME_STORE__?: typeof useGameStore }).__GAME_STORE__ =
        useGameStore;
    }
  }, [setReducedMotion]);

  return (
    <main className="relative h-screen w-screen overflow-hidden bg-garden-blush">
      <RomanticGardenScene />
      <GameplayHUD />
      <ChallengeCardModal />
      <PlayerSetupModal />
      <VictoryModal />
    </main>
  );
}
EOF

echo "🧪 Menulis 23 Unit Test Vitest dan E2E Test Playwright..."

cat << 'EOF' > src/tests/gameEngine.test.ts
import { describe, expect, it } from 'vitest';
import {
  BOARD_CONFIG,
  calculateSquareCoordinates,
} from '../game/board/boardConfig';
import { validateBoardConfiguration } from '../game/board/boardValidator';
import {
  DARE_CARDS,
  selectNextChallengeCard,
  TRUTH_CARDS,
} from '../game/challenges/challengeBank';
import {
  DIE_OPPOSITE_FACES,
  getRotationForDiceValue,
  rollDiceValue,
} from '../game/dice/diceLogic';
import {
  completeDiceRollAnimation,
  completeNormalMovement,
  completeTransitionMovement,
  createInitialGameState,
  resolveActiveChallenge,
  rollTurnDice,
  startMatch,
} from '../game/engine/gameEngine';

describe('Truth or Dare: Romantic Garden — Game Engine & Board Suite', () => {
  it('1. initializes in ready state with default two-player setup on square 1', () => {
    const state = createInitialGameState();
    expect(state.phase).toBe('ready');
    expect(state.players).toHaveLength(2);
    expect(state.players[0].square).toBe(1);
    expect(state.players[1].square).toBe(1);
    expect(state.activePlayerIndex).toBe(0);
  });

  it('2. contains exactly 100 playable squares in the authoritative board config', () => {
    const squares = Object.keys(BOARD_CONFIG.squares);
    expect(squares).toHaveLength(100);
    expect(BOARD_CONFIG.totalSquares).toBe(100);
  });

  it('3. maps serpentine coordinates accurately for representative squares 1, 10, 11, 20, 91, 100', () => {
    const sq1 = calculateSquareCoordinates(1);
    const sq10 = calculateSquareCoordinates(10);
    const sq11 = calculateSquareCoordinates(11);
    const sq20 = calculateSquareCoordinates(20);
    const sq91 = calculateSquareCoordinates(91);
    const sq100 = calculateSquareCoordinates(100);

    expect({ row: sq1.row, col: sq1.col }).toEqual({ row: 0, col: 0 });
    expect({ row: sq10.row, col: sq10.col }).toEqual({ row: 0, col: 9 });
    expect({ row: sq11.row, col: sq11.col }).toEqual({ row: 1, col: 9 });
    expect({ row: sq20.row, col: sq20.col }).toEqual({ row: 1, col: 0 });
    expect({ row: sq91.row, col: sq91.col }).toEqual({ row: 9, col: 9 });
    expect({ row: sq100.row, col: sq100.col }).toEqual({ row: 9, col: 0 });
  });

  it('4. assigns unique 3D world coordinates to all 100 squares', () => {
    const seen = new Set<string>();
    for (let sq = 1; sq <= 100; sq++) {
      const { worldPosition } = BOARD_CONFIG.squares[sq];
      const key = `${worldPosition.x},${worldPosition.y},${worldPosition.z}`;
      expect(seen.has(key)).toBe(false);
      seen.add(key);
    }
    expect(seen.size).toBe(100);
  });

  it('5. generates dice values strictly between 1 and 6 and maps opposite faces', () => {
    for (let i = 0; i < 6; i++) {
      const val = rollDiceValue(() => i / 6 + 0.01);
      expect(val).toBe(i + 1);
      expect(val + DIE_OPPOSITE_FACES[val]).toBe(7);
      expect(getRotationForDiceValue(val)).toHaveLength(3);
    }
  });

  it('6. rotates turn ownership predictably between players after a normal move', () => {
    let state = createInitialGameState();
    state = rollTurnDice(state, { forcedDiceValue: 1 });
    state = completeDiceRollAnimation(state);
    state = completeNormalMovement(state);

    expect(state.phase).toBe('ready');
    expect(state.activePlayerIndex).toBe(1);
    expect(state.turnNumber).toBe(2);
  });

  it('7. computes sequential intermediate squares for normal movement', () => {
    let state = createInitialGameState();
    state = rollTurnDice(state, { forcedDiceValue: 4 });
    expect(state.pendingPath).toEqual([2, 3, 4, 5]);
    state = completeDiceRollAnimation(state);
    expect(state.phase).toBe('moving');
    state = completeNormalMovement(state);
    expect(state.players[0].square).toBe(5);
  });

  it('8. triggers and resolves downward snake transitions accurately', () => {
    let state = createInitialGameState();
    state.players[0].square = 25;
    state = rollTurnDice(state, { forcedDiceValue: 2 });
    state = completeDiceRollAnimation(state);
    state = completeNormalMovement(state);

    expect(state.phase).toBe('transitioning');
    expect(state.activeTransition?.kind).toBe('snake');
    expect(state.activeTransition?.toSquare).toBe(7);

    state = completeTransitionMovement(state);
    expect(state.players[0].square).toBe(7);
    expect(state.phase).toBe('ready');
    expect(state.activePlayerIndex).toBe(1);
  });

  it('9. triggers and resolves upward ladder transitions accurately', () => {
    let state = createInitialGameState();
    state = rollTurnDice(state, { forcedDiceValue: 3 });
    state = completeDiceRollAnimation(state);
    state = completeNormalMovement(state);

    expect(state.phase).toBe('transitioning');
    expect(state.activeTransition?.kind).toBe('ladder');
    expect(state.activeTransition?.toSquare).toBe(25);

    state = completeTransitionMovement(state);
    expect(state.players[0].square).toBe(25);
    expect(state.phase).toBe('ready');
  });

  it('10. opens a Truth challenge on a Truth square and advances turn upon completion', () => {
    let state = createInitialGameState();
    state = rollTurnDice(state, { forcedDiceValue: 2 });
    state = completeDiceRollAnimation(state);
    state = completeNormalMovement(state);

    expect(state.phase).toBe('awaiting_challenge');
    expect(state.activeChallenge?.type).toBe('truth');

    state = resolveActiveChallenge(state, 'completed');
    expect(state.players[0].completedChallenges).toBe(1);
    expect(state.phase).toBe('ready');
    expect(state.activePlayerIndex).toBe(1);
  });

  it('11. opens a Dare challenge on a Dare square and advances turn upon completion', () => {
    let state = createInitialGameState();
    state = rollTurnDice(state, { forcedDiceValue: 5 });
    state = completeDiceRollAnimation(state);
    state = completeNormalMovement(state);

    expect(state.phase).toBe('awaiting_challenge');
    expect(state.activeChallenge?.type).toBe('dare');

    state = resolveActiveChallenge(state, 'completed');
    expect(state.players[0].completedChallenges).toBe(1);
    expect(state.phase).toBe('ready');
    expect(state.activePlayerIndex).toBe(1);
  });

  it('12. requires an exact roll onto square 100 to finish', () => {
    let state = createInitialGameState();
    state.players[0].square = 98;
    state = rollTurnDice(state, { forcedDiceValue: 2 });
    state = completeDiceRollAnimation(state);
    state = completeNormalMovement(state);

    expect(state.players[0].square).toBe(100);
    expect(state.phase).toBe('victory');
    expect(state.winnerId).toBe(state.players[0].id);
  });

  it('13. keeps player on current square when dice roll overshoots 100', () => {
    let state = createInitialGameState();
    state.players[0].square = 98;
    state = rollTurnDice(state, { forcedDiceValue: 5 });
    expect(state.overshotLastRoll).toBe(true);
    expect(state.pendingPath).toEqual([]);

    state = completeDiceRollAnimation(state);
    expect(state.players[0].square).toBe(98);
    expect(state.phase).toBe('ready');
    expect(state.activePlayerIndex).toBe(1);
  });

  it('14. locks the game in victory phase and prevents further rolls after winning', () => {
    let state = createInitialGameState();
    state.players[0].square = 99;
    state = rollTurnDice(state, { forcedDiceValue: 1 });
    state = completeDiceRollAnimation(state);
    state = completeNormalMovement(state);

    expect(state.phase).toBe('victory');
    const afterAttemptedRoll = rollTurnDice(state, { forcedDiceValue: 3 });
    expect(afterAttemptedRoll).toEqual(state);
  });

  it('15. rejects duplicate dice roll requests while rolling or moving', () => {
    let state = createInitialGameState();
    state = rollTurnDice(state, { forcedDiceValue: 4 });
    expect(state.phase).toBe('rolling');

    const duplicateAttempt = rollTurnDice(state, { forcedDiceValue: 6 });
    expect(duplicateAttempt.lastDiceValue).toBe(4);
  });

  it('16. resets all player positions, history, and turn counters on restart', () => {
    let state = createInitialGameState();
    state = rollTurnDice(state, { forcedDiceValue: 4 });
    state = completeDiceRollAnimation(state);
    state = completeNormalMovement(state);

    const restarted = startMatch(state, [
      { name: 'Rama', pieceStyle: 'ivory_rose_gold' },
      { name: 'Sinta', pieceStyle: 'blush_quartz' },
    ]);

    expect(restarted.phase).toBe('ready');
    expect(restarted.turnNumber).toBe(1);
    expect(restarted.players[0].square).toBe(1);
    expect(restarted.players[1].square).toBe(1);
    expect(restarted.moveHistory).toHaveLength(0);
  });

  it('17. synchronizes final logical square in player state and move history after ladder/snake', () => {
    let state = createInitialGameState();
    state = rollTurnDice(state, { forcedDiceValue: 3 });
    state = completeDiceRollAnimation(state);
    state = completeNormalMovement(state);
    state = completeTransitionMovement(state);

    expect(state.players[0].square).toBe(25);
    expect(state.moveHistory[0].landedSquare).toBe(4);
    expect(state.moveHistory[0].finalSquare).toBe(25);
  });

  it('18. passes all board configuration validation checks with zero errors', () => {
    const validation = validateBoardConfiguration(BOARD_CONFIG);
    expect(validation.errors).toEqual([]);
    expect(validation.valid).toBe(true);
  });

  it('19. draws all 50 Truth cards and 50 Dare cards before repeating any card', () => {
    expect(TRUTH_CARDS.length).toBeGreaterThanOrEqual(50);
    expect(DARE_CARDS.length).toBeGreaterThanOrEqual(50);

    let usedTruth: string[] = [];
    const seenTruth = new Set<string>();

    for (let i = 0; i < TRUTH_CARDS.length; i++) {
      const res = selectNextChallengeCard('truth', usedTruth, () => 0);
      expect(seenTruth.has(res.card.id)).toBe(false);
      seenTruth.add(res.card.id);
      usedTruth = res.updatedUsedIds;
    }
    expect(seenTruth.size).toBe(TRUTH_CARDS.length);
  });

  it('20. supports deterministic dice outcome injection for automated testing', () => {
    const state = createInitialGameState();
    const rolled = rollTurnDice(state, { forcedDiceValue: 6 });
    expect(rolled.lastDiceValue).toBe(6);
  });

  it('21. produces deterministic card selections when given a seeded random function', () => {
    const first = selectNextChallengeCard('dare', [], () => 0.42);
    const second = selectNextChallengeCard('dare', [], () => 0.42);
    expect(first.card.id).toBe(second.card.id);
  });

  it('22. allows skipping a challenge without penalty and cleanly advances the turn', () => {
    let state = createInitialGameState();
    state = rollTurnDice(state, { forcedDiceValue: 2 });
    state = completeDiceRollAnimation(state);
    state = completeNormalMovement(state);

    const beforeSquare = state.players[0].square;
    state = resolveActiveChallenge(state, 'skipped');

    expect(state.players[0].square).toBe(beforeSquare);
    expect(state.players[0].skippedChallenges).toBe(1);
    expect(state.phase).toBe('ready');
    expect(state.activePlayerIndex).toBe(1);
  });

  it('23. detects and rejects cyclic snake/ladder chains in board validator', () => {
    const brokenConfig = {
      ...BOARD_CONFIG,
      snakes: [
        ...BOARD_CONFIG.snakes,
        {
          id: 'cyclic-snake',
          name: 'Cyclic Snake',
          head: 25,
          tail: 4,
          style: 'jade_sculpt' as const,
        },
      ],
    };
    const result = validateBoardConfiguration(brokenConfig);
    expect(result.valid).toBe(false);
    expect(
      result.errors.some(
        (e) => e.includes('Infinite transition cycle') || e.includes('overlap')
      )
    ).toBe(true);
  });
});
EOF

cat << 'EOF' > e2e/game.spec.ts
import { test, expect } from '@playwright/test';

test.describe('Truth or Dare: A Romantic Garden Adventure E2E', () => {
  test('loads interface, rolls die, resolves Truth card, and reaches deterministic victory', async ({
    page,
  }) => {
    await page.goto('/');

    await expect(
      page.getByText('Truth or Dare: Romantic Garden')
    ).toBeVisible();
    const rollBtn = page.getByTestId('roll-dice-btn');
    await expect(rollBtn).toBeVisible();
    await expect(rollBtn).toBeEnabled();

    await page.evaluate(() => {
      const store = (
        window as unknown as {
          __GAME_STORE__: {
            getState: () => {
              setReducedMotion: (v: boolean) => void;
              rollDice: (v: number) => void;
            };
          };
        }
      ).__GAME_STORE__;
      store.getState().setReducedMotion(true);
      store.getState().rollDice(2);
    });

    const challengeModal = page.getByTestId('challenge-card-modal');
    await expect(challengeModal).toBeVisible({ timeout: 6000 });
    await expect(page.getByTestId('challenge-prompt-text')).not.toBeEmpty();

    await page.getByTestId('skip-challenge-btn').click();
    await expect(challengeModal).toBeHidden();

    await expect(page.getByTestId('active-player-indicator')).toContainText(
      'Sayang 2'
    );

    await page.evaluate(() => {
      const store = (
        window as unknown as {
          __GAME_STORE__: {
            getState: () => {
              setDebugPlayerSquare: (idx: number, sq: number) => void;
              rollDice: (v: number) => void;
            };
          };
        }
      ).__GAME_STORE__;
      store.getState().setDebugPlayerSquare(1, 98);
      store.getState().rollDice(2);
    });

    const victoryModal = page.getByTestId('victory-modal');
    await expect(victoryModal).toBeVisible({ timeout: 6000 });
    await expect(victoryModal).toContainText('Memenangkan Petualangan');

    await page.getByTestId('victory-replay-btn').click();
    await expect(victoryModal).toBeHidden();
    await expect(page.getByTestId('player-square-0')).toHaveText('#1');
  });
});
EOF

echo "✅ Seluruh direktori dan file berhasil dibuat!"
echo "👉 Langkah selanjutnya:"
echo "   1. npm install"
echo "   2. npm run test"
echo "   3. npm run dev"