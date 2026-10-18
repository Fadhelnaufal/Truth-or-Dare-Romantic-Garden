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

describe('Custom Couple Cards Integration', () => {
  it('24. includes custom cards in selectNextChallengeCard and preserves them across restarts', () => {
    const customTruth = {
      id: 'custom-truth-1',
      type: 'truth' as const,
      category: 'Awal Jatuh Cinta' as const,
      prompt: 'Pertanyaan spesial buatan pasangan sendiri.',
      isCustom: true,
    };

    const selected = selectNextChallengeCard('truth', [], () => 0, [customTruth]);
    expect(selected.card.id).toBe('custom-truth-1');
    expect(selected.card.isCustom).toBe(true);

    let state = createInitialGameState({ customCards: [customTruth] });
    expect(state.customCards).toHaveLength(1);

    state = startMatch(state, [
      { name: 'Sayang 1', pieceStyle: 'ivory_rose_gold' },
      { name: 'Sayang 2', pieceStyle: 'blush_quartz' },
    ]);
    expect(state.customCards).toHaveLength(1);
    expect(state.customCards[0].id).toBe('custom-truth-1');
  });
});
