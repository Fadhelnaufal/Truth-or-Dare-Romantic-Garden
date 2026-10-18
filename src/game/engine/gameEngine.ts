import { BOARD_CONFIG } from '../board/boardConfig';
import { selectNextChallengeCard } from '../challenges/challengeBank';
import { rollDiceValue } from '../dice/diceLogic';
import { createInitialPlayers, DEFAULT_PLAYERS_SETUP } from '../players/playerStyles';
import {
  ActiveTransition,
  BoardConfiguration,
  ChallengeCard,
  GameEngineState,
  MoveRecord,
  PlayerSetupInput,
  RandomSource,
} from '../types';

export interface CreateGameOptions {
  players?: PlayerSetupInput[];
  startInReadyPhase?: boolean;
  customCards?: ChallengeCard[];
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
    customCards: options.customCards ? [...options.customCards] : [],
  };
}

export function startMatch(
  state: GameEngineState,
  playersInput: PlayerSetupInput[]
): GameEngineState {
  return createInitialGameState({
    players: playersInput,
    startInReadyPhase: true,
    customCards: state.customCards,
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
      options.random,
      state.customCards
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
      options.random,
      state.customCards
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
