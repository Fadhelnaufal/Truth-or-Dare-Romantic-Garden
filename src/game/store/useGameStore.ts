import { create } from 'zustand';
import {
  loadCustomCardsFromStorage,
  saveCustomCardsToStorage,
} from '../challenges/challengeBank';
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
import {
  ChallengeCard,
  CustomCardInput,
  GameEngineState,
  PlayerSetupInput,
} from '../types';

export type CameraMode = 'intro' | 'gameplay';

interface GameStore extends GameEngineState {
  soundEnabled: boolean;
  reducedMotion: boolean;
  cameraMode: CameraMode;
  cameraResetTrigger: number;
  setupModalOpen: boolean;
  customCardModalOpen: boolean;

  setSoundEnabled: (enabled: boolean) => void;
  setReducedMotion: (reduced: boolean) => void;
  finishCameraIntro: () => void;
  triggerCameraReset: () => void;
  setSetupModalOpen: (open: boolean) => void;
  setCustomCardModalOpen: (open: boolean) => void;

  hydrateCustomCards: () => void;
  addCustomCard: (input: CustomCardInput) => ChallengeCard | null;
  deleteCustomCard: (id: string) => void;
  clearAllCustomCards: () => void;

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
  customCardModalOpen: false,

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
  setCustomCardModalOpen: (open) => set({ customCardModalOpen: open }),

  hydrateCustomCards: () => {
    const stored = loadCustomCardsFromStorage();
    set({ customCards: stored });
  },

  addCustomCard: (input) => {
    const trimmedPrompt = input.prompt.trim();
    if (!trimmedPrompt) return null;

    const newCard: ChallengeCard = {
      id: `custom-${input.type}-${Date.now()}-${Math.random().toString(36).slice(2, 6)}`,
      type: input.type,
      category: input.category,
      prompt: trimmedPrompt,
      isCustom: true,
    };

    const updated = [newCard, ...get().customCards];
    saveCustomCardsToStorage(updated);
    set({ customCards: updated });
    return newCard;
  },

  deleteCustomCard: (id) => {
    const updated = get().customCards.filter((c) => c.id !== id);
    saveCustomCardsToStorage(updated);
    set({ customCards: updated });
  },

  clearAllCustomCards: () => {
    saveCustomCardsToStorage([]);
    set({ customCards: [] });
  },

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
