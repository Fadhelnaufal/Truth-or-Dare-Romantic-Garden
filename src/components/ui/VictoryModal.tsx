'use client';

import React from 'react';
import { Crown, RotateCcw, Users } from 'lucide-react';
import { useGameStore } from '@/game/store/useGameStore';

export function VictoryModal() {
  const phase = useGameStore((s) => s.phase);
  const winnerId = useGameStore((s) => s.winnerId);
  const players = useGameStore((s) => s.players);
  const turnNumber = useGameStore((s) => s.turnNumber);
  const startNewGame = useGameStore((s) => s.startNewGame);
  const setSetupModalOpen = useGameStore((s) => s.setSetupModalOpen);

  if (phase !== 'victory' || !winnerId) return null;

  const winner = players.find((p) => p.id === winnerId) ?? players[0];

  return (
    <div
      role="dialog"
      aria-modal="true"
      aria-labelledby="victory-modal-title"
      data-testid="victory-modal"
      className="fixed inset-0 z-50 flex items-center justify-center bg-garden-deepMauve/35 p-4 backdrop-blur-xs"
    >
      <div className="w-full max-w-md rounded-3xl border-2 border-garden-gold bg-garden-ivory p-7 text-center text-garden-mauve shadow-card">
        <div className="mx-auto mb-3 flex h-14 w-14 items-center justify-center rounded-full border border-garden-gold bg-garden-blush text-garden-gold">
          <Crown className="h-7 w-7" />
        </div>

        <p className="text-xs font-semibold uppercase tracking-widest text-garden-rose">
          Kotak 100 Tercapai
        </p>
        <h2
          id="victory-modal-title"
          className="mt-1 font-serif text-2xl font-bold text-garden-deepMauve"
        >
          {winner.name} Memenangkan Petualangan!
        </h2>

        <p className="mt-2 text-sm text-garden-mauve/85">
          Setelah {turnNumber} giliran penuh tawa, kejujuran, dan momen manis di Taman Romantis, kalian telah menyelesaikan perjalanan ini bersama.
        </p>

        <div className="my-5 grid grid-cols-2 gap-2 rounded-2xl border border-garden-gold/40 bg-garden-cream p-3 text-left text-xs">
          {players.map((p) => (
            <div key={p.id} className="space-y-0.5">
              <div className="font-semibold text-garden-deepMauve">{p.name}</div>
              <div>Kotak Akhir: #{p.square}</div>
              <div>
                Tantangan Selesai: {p.completedChallenges} (Lewati:{' '}
                {p.skippedChallenges})
              </div>
            </div>
          ))}
        </div>

        <div className="flex flex-col gap-2.5 sm:flex-row">
          <button
            type="button"
            data-testid="victory-replay-btn"
            onClick={() => startNewGame(undefined, false)}
            className="flex flex-1 items-center justify-center gap-2 rounded-2xl bg-garden-rose px-4 py-3 text-sm font-semibold text-white shadow-sm transition hover:bg-garden-deepMauve"
          >
            <RotateCcw className="h-4 w-4" />
            Main Lagi
          </button>
          <button
            type="button"
            onClick={() => setSetupModalOpen(true)}
            className="flex items-center justify-center gap-2 rounded-2xl border border-garden-gold bg-garden-cream px-4 py-3 text-sm font-medium text-garden-mauve transition hover:bg-garden-blush"
          >
            <Users className="h-4 w-4" />
            Atur Pemain
          </button>
        </div>
      </div>
    </div>
  );
}
