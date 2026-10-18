'use client';

import React, { useState } from 'react';
import { Users, Plus, Trash2, Play, X } from 'lucide-react';
import { PIECE_STYLES } from '@/game/players/playerStyles';
import { useGameStore } from '@/game/store/useGameStore';
import { PieceStyleId, PlayerSetupInput } from '@/game/types';

export function PlayerSetupModal() {
  const setupModalOpen = useGameStore((s) => s.setupModalOpen);
  const players = useGameStore((s) => s.players);
  const soundEnabled = useGameStore((s) => s.soundEnabled);
  const reducedMotion = useGameStore((s) => s.reducedMotion);
  const setSoundEnabled = useGameStore((s) => s.setSoundEnabled);
  const setReducedMotion = useGameStore((s) => s.setReducedMotion);
  const setSetupModalOpen = useGameStore((s) => s.setSetupModalOpen);
  const startNewGame = useGameStore((s) => s.startNewGame);

  const [draftPlayers, setDraftPlayers] = useState<PlayerSetupInput[]>(() =>
    players.map((p) => ({ name: p.name, pieceStyle: p.pieceStyle }))
  );

  if (!setupModalOpen) return null;

  const handleAddPlayer = () => {
    if (draftPlayers.length >= 4) return;
    const nextStyle = PIECE_STYLES[draftPlayers.length % PIECE_STYLES.length].id;
    setDraftPlayers([
      ...draftPlayers,
      { name: `Pemain ${draftPlayers.length + 1}`, pieceStyle: nextStyle },
    ]);
  };

  const handleRemovePlayer = (idx: number) => {
    if (draftPlayers.length <= 2) return;
    setDraftPlayers(draftPlayers.filter((_, i) => i !== idx));
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    startNewGame(draftPlayers, true);
  };

  return (
    <div
      role="dialog"
      aria-modal="true"
      aria-labelledby="setup-dialog-title"
      data-testid="player-setup-modal"
      className="fixed inset-0 z-50 flex items-center justify-center bg-garden-deepMauve/40 p-4 backdrop-blur-xs"
    >
      <form
        onSubmit={handleSubmit}
        className="w-full max-w-md rounded-3xl border-2 border-garden-gold bg-garden-ivory p-6 text-garden-mauve shadow-card"
      >
        <div className="mb-4 flex items-center justify-between">
          <div className="flex items-center gap-2">
            <Users className="h-5 w-5 text-garden-rose" />
            <h2
              id="setup-dialog-title"
              className="font-serif text-xl font-bold text-garden-deepMauve"
            >
              Pengaturan Pemain & Taman
            </h2>
          </div>
          <button
            type="button"
            aria-label="Tutup pengaturan"
            onClick={() => setSetupModalOpen(false)}
            className="rounded-full p-1.5 text-garden-mauve hover:bg-garden-blush"
          >
            <X className="h-4 w-4" />
          </button>
        </div>

        <div className="space-y-3">
          {draftPlayers.map((p, idx) => (
            <div
              key={idx}
              className="flex flex-col gap-2 rounded-2xl border border-garden-gold/50 bg-garden-cream p-3 sm:flex-row sm:items-center"
            >
              <div className="flex-1">
                <label className="block text-[11px] font-medium text-garden-mauve/75">
                  Nama Pemain {idx + 1}
                </label>
                <input
                  type="text"
                  value={p.name}
                  maxLength={24}
                  onChange={(e) => {
                    const next = [...draftPlayers];
                    next[idx] = { ...next[idx], name: e.target.value };
                    setDraftPlayers(next);
                  }}
                  className="mt-0.5 w-full rounded-xl border border-garden-blush bg-white px-3 py-1.5 text-sm font-medium text-garden-deepMauve focus:border-garden-rose focus:outline-none"
                />
              </div>

              <div className="sm:w-44">
                <label className="block text-[11px] font-medium text-garden-mauve/75">
                  Bidak 3D
                </label>
                <select
                  value={p.pieceStyle}
                  onChange={(e) => {
                    const next = [...draftPlayers];
                    next[idx] = {
                      ...next[idx],
                      pieceStyle: e.target.value as PieceStyleId,
                    };
                    setDraftPlayers(next);
                  }}
                  className="mt-0.5 w-full rounded-xl border border-garden-blush bg-white px-2.5 py-1.5 text-xs font-medium text-garden-deepMauve focus:border-garden-rose focus:outline-none"
                >
                  {PIECE_STYLES.map((style) => (
                    <option key={style.id} value={style.id}>
                      {style.label}
                    </option>
                  ))}
                </select>
              </div>

              {draftPlayers.length > 2 && (
                <button
                  type="button"
                  onClick={() => handleRemovePlayer(idx)}
                  aria-label={`Hapus Pemain ${idx + 1}`}
                  className="self-end rounded-xl p-2 text-garden-rose hover:bg-garden-blush sm:self-center"
                >
                  <Trash2 className="h-4 w-4" />
                </button>
              )}
            </div>
          ))}
        </div>

        {draftPlayers.length < 4 && (
          <button
            type="button"
            onClick={handleAddPlayer}
            className="mt-3 flex w-full items-center justify-center gap-1.5 rounded-2xl border border-dashed border-garden-gold py-2 text-xs font-semibold text-garden-mauve hover:bg-garden-blush/50"
          >
            <Plus className="h-3.5 w-3.5" />
            Tambah Pemain Lokal (Maks. 4)
          </button>
        )}

        <div className="mt-4 space-y-2 border-t border-garden-gold/30 pt-3 text-xs">
          <label className="flex cursor-pointer items-center justify-between">
            <span>Efek Suara Romantis</span>
            <input
              type="checkbox"
              checked={soundEnabled}
              onChange={(e) => setSoundEnabled(e.target.checked)}
              className="h-4 w-4 accent-garden-rose"
            />
          </label>
          <label className="flex cursor-pointer items-center justify-between">
            <span>Kurangi Animasi Gerakan (Reduced Motion)</span>
            <input
              type="checkbox"
              checked={reducedMotion}
              onChange={(e) => setReducedMotion(e.target.checked)}
              className="h-4 w-4 accent-garden-rose"
            />
          </label>
        </div>

        <div className="mt-5 flex gap-2">
          <button
            type="submit"
            data-testid="confirm-start-match-btn"
            className="flex flex-1 items-center justify-center gap-2 rounded-2xl bg-garden-rose px-4 py-2.5 text-sm font-semibold text-white shadow-sm transition hover:bg-garden-deepMauve"
          >
            <Play className="h-4 w-4" />
            Mulai Permainan Baru
          </button>
        </div>
      </form>
    </div>
  );
}
