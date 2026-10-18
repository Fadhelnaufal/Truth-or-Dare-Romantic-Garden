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

  for (const startSq of Array.from(transitionMap.keys())) {
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
