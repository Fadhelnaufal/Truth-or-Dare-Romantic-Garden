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
      soundEngine.playChallengeReveal(
        soundEnabled,
        activeChallenge.isCustom ? 'custom' : activeChallenge.type
      );
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
        <div className="mb-3 flex flex-wrap items-center justify-between gap-2">
          <div className="flex items-center gap-1.5">
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

            {activeChallenge.isCustom && (
              <span
                data-testid="custom-card-badge"
                className="rounded-full border border-garden-gold bg-garden-cream px-2.5 py-0.5 text-[10px] font-semibold text-garden-deepMauve"
              >
                ✨ Kartu Kustom
              </span>
            )}
          </div>

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
