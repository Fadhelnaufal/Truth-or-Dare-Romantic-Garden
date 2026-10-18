'use client';

import React, { useEffect } from 'react';
import { RomanticGardenScene } from '@/components/scene/RomanticGardenScene';
import { ChallengeCardModal } from '@/components/ui/ChallengeCardModal';
import { CustomCardEditorModal } from '@/components/ui/CustomCardEditorModal';
import { GameplayHUD } from '@/components/ui/GameplayHUD';
import { PlayerSetupModal } from '@/components/ui/PlayerSetupModal';
import { VictoryModal } from '@/components/ui/VictoryModal';
import { useGameStore } from '@/game/store/useGameStore';

export default function HomePage() {
  const setReducedMotion = useGameStore((s) => s.setReducedMotion);
  const hydrateCustomCards = useGameStore((s) => s.hydrateCustomCards);

  useEffect(() => {
    hydrateCustomCards();

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
  }, [setReducedMotion, hydrateCustomCards]);

  return (
    <main className="relative h-screen w-screen overflow-hidden bg-garden-blush">
      <RomanticGardenScene />
      <GameplayHUD />
      <ChallengeCardModal />
      <CustomCardEditorModal />
      <PlayerSetupModal />
      <VictoryModal />
    </main>
  );
}
