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
