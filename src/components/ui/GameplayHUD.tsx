'use client';

import React, { useState } from 'react';
import {
  Volume2,
  VolumeX,
  RotateCcw,
  Compass,
  Users,
  Dices,
  History,
  ChevronUp,
  ChevronDown,
  BookOpen,
} from 'lucide-react';
import { useGameStore } from '@/game/store/useGameStore';
import { KawaiiMusicPlayer } from './KawaiiMusicPlayer';

export function GameplayHUD() {
  const phase = useGameStore((s) => s.phase);
  const players = useGameStore((s) => s.players);
  const activePlayerIndex = useGameStore((s) => s.activePlayerIndex);
  const lastDiceValue = useGameStore((s) => s.lastDiceValue);
  const statusMessage = useGameStore((s) => s.statusMessage);
  const moveHistory = useGameStore((s) => s.moveHistory);
  const soundEnabled = useGameStore((s) => s.soundEnabled);
  const customCards = useGameStore((s) => s.customCards);

  const setSoundEnabled = useGameStore((s) => s.setSoundEnabled);
  const triggerCameraReset = useGameStore((s) => s.triggerCameraReset);
  const setSetupModalOpen = useGameStore((s) => s.setSetupModalOpen);
  const setCustomCardModalOpen = useGameStore((s) => s.setCustomCardModalOpen);
  const startNewGame = useGameStore((s) => s.startNewGame);
  const rollDice = useGameStore((s) => s.rollDice);

  const [historyOpen, setHistoryOpen] = useState(false);

  const activePlayer = players[activePlayerIndex] ?? players[0];
  const canRoll = phase === 'ready';

  return (
    <div className="pointer-events-none fixed inset-0 z-30 flex flex-col justify-between p-3 sm:p-5">
      <header className="pointer-events-auto flex items-center justify-between rounded-2xl border border-garden-gold/60 bg-garden-ivory/95 px-4 py-2.5 text-garden-mauve shadow-romantic backdrop-blur-xs">
        <div className="flex items-center gap-3">
          <span className="flex h-8 w-8 items-center justify-center rounded-full border border-garden-gold bg-garden-blush font-serif text-sm font-bold text-garden-deepMauve">
            ❀
          </span>
          <div>
            <h1 className="font-serif text-sm font-bold tracking-wide text-garden-deepMauve sm:text-base">
              Truth or Dare: Romantic Garden
            </h1>
            <p className="hidden text-[11px] text-garden-mauve/75 sm:block">
              Ular Tangga 3D Romantis • 100 Kotak Petualangan Pasangan
            </p>
          </div>
        </div>

        <div className="flex items-center gap-1.5 sm:gap-2">
          <button
            type="button"
            onClick={() => setCustomCardModalOpen(true)}
            aria-label="Kelola kartu kustom pasangan"
            data-testid="open-custom-cards-btn"
            className="flex items-center gap-1.5 rounded-xl border border-garden-gold/50 bg-garden-cream px-2.5 py-1.5 text-xs font-medium text-garden-mauve transition hover:bg-garden-blush focus:outline-none focus:ring-2 focus:ring-garden-rose"
          >
            <BookOpen className="h-4 w-4 text-garden-rose" />
            <span className="hidden md:inline">Kartu Kustom</span>
            {customCards.length > 0 && (
              <span
                data-testid="custom-cards-count-badge"
                className="rounded-full bg-garden-rose px-1.5 py-0.2 text-[10px] font-bold text-white"
              >
                {customCards.length}
              </span>
            )}
          </button>

          <KawaiiMusicPlayer />

          <button
            type="button"
            onClick={triggerCameraReset}
            aria-label="Reset sudut kamera"
            data-testid="camera-reset-btn"
            className="flex items-center gap-1 rounded-xl border border-garden-gold/50 bg-garden-cream px-2.5 py-1.5 text-xs font-medium text-garden-mauve transition hover:bg-garden-blush focus:outline-none focus:ring-2 focus:ring-garden-rose"
          >
            <Compass className="h-4 w-4 text-garden-gold" />
            <span className="hidden lg:inline">Reset Kamera</span>
          </button>

          <button
            type="button"
            onClick={() => setSetupModalOpen(true)}
            aria-label="Pengaturan pemain"
            data-testid="open-setup-btn"
            className="flex items-center gap-1 rounded-xl border border-garden-gold/50 bg-garden-cream px-2.5 py-1.5 text-xs font-medium text-garden-mauve transition hover:bg-garden-blush focus:outline-none focus:ring-2 focus:ring-garden-rose"
          >
            <Users className="h-4 w-4 text-garden-rose" />
            <span className="hidden md:inline">Pemain</span>
          </button>

          <button
            type="button"
            onClick={() => startNewGame(undefined, false)}
            aria-label="Mulai ulang permainan"
            data-testid="restart-match-btn"
            className="flex items-center gap-1 rounded-xl border border-garden-gold/60 bg-garden-blush px-2.5 py-1.5 text-xs font-semibold text-garden-deepMauve transition hover:bg-garden-rose hover:text-white focus:outline-none focus:ring-2 focus:ring-garden-rose"
          >
            <RotateCcw className="h-4 w-4" />
            <span className="hidden sm:inline">Mulai Baru</span>
          </button>
        </div>
      </header>

      <div className="flex flex-col gap-2 sm:flex-row sm:items-end sm:justify-between">
        <div className="pointer-events-auto flex flex-col gap-2 rounded-2xl border border-garden-gold/60 bg-garden-ivory/95 p-3.5 text-garden-mauve shadow-romantic backdrop-blur-xs sm:max-w-md">
          <div className="flex flex-wrap gap-2">
            {players.map((p, idx) => {
              const isActive = idx === activePlayerIndex;
              return (
                <div
                  key={p.id}
                  data-testid={`player-card-${idx}`}
                  className={`flex items-center gap-2 rounded-xl border px-3 py-1.5 text-xs transition ${
                    isActive
                      ? 'border-garden-rose bg-garden-blush font-semibold text-garden-deepMauve shadow-xs'
                      : 'border-garden-gold/30 bg-garden-cream text-garden-mauve/80'
                  }`}
                >
                  <span
                    className="h-3 w-3 rounded-full border border-garden-deepMauve/40"
                    style={{ backgroundColor: p.accentColor }}
                  />
                  <span>{p.name}</span>
                  <span
                    data-testid={`player-square-${idx}`}
                    className="rounded-md bg-white/80 px-1.5 py-0.5 text-[11px] font-bold text-garden-deepMauve"
                  >
                    #{p.square}
                  </span>
                </div>
              );
            })}
          </div>

          <div
            role="status"
            aria-live="polite"
            data-testid="status-banner"
            className="text-xs leading-snug text-garden-deepMauve"
          >
            {statusMessage}
          </div>

          <div>
            <button
              type="button"
              onClick={() => setHistoryOpen(!historyOpen)}
              className="flex items-center gap-1 text-[11px] font-semibold text-garden-rose hover:underline"
            >
              <History className="h-3.5 w-3.5" />
              Riwayat Langkah ({moveHistory.length})
              {historyOpen ? (
                <ChevronDown className="h-3.5 w-3.5" />
              ) : (
                <ChevronUp className="h-3.5 w-3.5" />
              )}
            </button>

            {historyOpen && (
              <ul
                data-testid="move-history-list"
                className="mt-1.5 max-h-28 space-y-1 overflow-y-auto rounded-xl border border-garden-gold/30 bg-garden-cream p-2 text-[11px]"
              >
                {moveHistory.length === 0 ? (
                  <li className="text-garden-mauve/60">
                    Belum ada langkah tercatat.
                  </li>
                ) : (
                  moveHistory.slice(0, 8).map((item) => (
                    <li key={item.id} className="border-b border-garden-blush/50 pb-1 last:border-none">
                      <strong>{item.playerName}</strong> dadu [{item.diceValue}]: #{item.fromSquare} → #{item.finalSquare}
                      {item.transition && ` (${item.transition.name})`}
                      {item.challenge &&
                        ` [${item.challenge.type.toUpperCase()} - ${
                          item.challenge.outcome === 'completed'
                            ? 'Selesai'
                            : 'Dilewati'
                        }]`}
                    </li>
                  ))
                )}
              </ul>
            )}
          </div>
        </div>

        <div className="pointer-events-auto flex items-center justify-between gap-3 rounded-2xl border border-garden-gold/60 bg-garden-ivory/95 p-3.5 shadow-romantic backdrop-blur-xs sm:justify-end">
          <div className="text-left sm:text-right">
            <div className="text-[11px] font-medium text-garden-mauve/75">
              Giliran Aktif
            </div>
            <div
              data-testid="active-player-indicator"
              className="font-serif text-sm font-bold text-garden-deepMauve"
            >
              {activePlayer.name} (Kotak #{activePlayer.square})
            </div>
            <div
              data-testid="dice-result-readout"
              className="text-xs font-semibold text-garden-rose"
            >
              Hasil Dadu: {lastDiceValue !== null ? lastDiceValue : '—'}
            </div>
          </div>

          <button
            type="button"
            disabled={!canRoll}
            onClick={() => rollDice()}
            data-testid="roll-dice-btn"
            className="flex items-center gap-2 rounded-2xl bg-garden-rose px-5 py-3.5 text-sm font-semibold text-white shadow-romantic transition hover:bg-garden-deepMauve disabled:cursor-not-allowed disabled:opacity-50 focus:outline-none focus:ring-2 focus:ring-garden-rose"
          >
            <Dices className="h-5 w-5" />
            <span>{canRoll ? 'Lempar Dadu' : 'Memproses...'}</span>
          </button>
        </div>
      </div>
    </div>
  );
}
