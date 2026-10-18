'use client';

import { gardenAudio } from '@/utils/gardenAudio';

class RomanticSoundEngine {
  playDiceRoll(enabled: boolean) {
    if (!enabled) return;
    gardenAudio.playDiceRoll();
  }

  playStepHop(enabled: boolean, stepIndex = 0) {
    if (!enabled) return;
    gardenAudio.playHop(stepIndex);
  }

  playChallengeReveal(enabled: boolean, type: 'truth' | 'dare' | 'custom' = 'truth') {
    if (!enabled) return;
    gardenAudio.playSpecialCard(type);
  }

  playLadderClimb(enabled: boolean) {
    if (!enabled) return;
    gardenAudio.playLadderClimb();
  }

  playSnakeSlide(enabled: boolean) {
    if (!enabled) return;
    gardenAudio.playSnakeSlide();
  }

  playVictoryFanfare(enabled: boolean) {
    if (!enabled) return;
    gardenAudio.playVictory();
  }
}

export const soundEngine = new RomanticSoundEngine();
