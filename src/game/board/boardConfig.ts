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
