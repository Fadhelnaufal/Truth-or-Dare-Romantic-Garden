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
  isCustom?: boolean;
}

export interface CustomCardInput {
  type: ChallengeType;
  category: TruthCategory | DareCategory;
  prompt: string;
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
  | 'kuromi_toy'
  | 'melody_toy'
  | 'pom_purin'
  | 'keroppi'
  | 'pochacco'
  | 'hello_kitty_toy'
  | 'cat_classic'
  | 'cat_panda'
  | 'cat_shark'
  | 'ivory_rose_gold'
  | 'blush_quartz'
  | 'sage_celadon'
  | 'lavender_pearl';

export interface GLBNodeConfig {
  url: string;
  nodeName?: string;
  targetHeight: number;
  rotationY?: number;
  rotationX?: number;
  rotationZ?: number;
}

export interface PieceStyleDefinition {
  id: PieceStyleId;
  label: string;
  primaryColor: string;
  accentColor: string;
  silhouette: 'crown_spire' | 'rose_chalice' | 'bloom_obelisk' | 'heart_column';
  glbConfig?: GLBNodeConfig;
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
  customCards: ChallengeCard[];
}

export type RandomSource = () => number;
