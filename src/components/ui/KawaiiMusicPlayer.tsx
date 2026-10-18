'use client';

import React, { useEffect, useRef, useState } from 'react';
import {
  Music,
  Play,
  Pause,
  Volume2,
  VolumeX,
  Download,
  Sparkles,
  Heart,
  Dices,
  Crown,
  ChevronDown,
  ChevronUp,
} from 'lucide-react';
import { useGameStore } from '@/game/store/useGameStore';
import { gardenAudio } from '@/utils/gardenAudio';

export function KawaiiMusicPlayer() {
  const soundEnabled = useGameStore((s) => s.soundEnabled);
  const setSoundEnabled = useGameStore((s) => s.setSoundEnabled);

  const [bgmPlaying, setBgmPlaying] = useState(false);
  const [panelOpen, setPanelOpen] = useState(false);
  const [downloading, setDownloading] = useState(false);
  const playerRef = useRef<HTMLDivElement>(null);

  // Sinkronkan state lokal dengan status gardenAudio
  useEffect(() => {
    const syncState = () => {
      setBgmPlaying(gardenAudio.isBGMPlaying());
    };
    syncState();
    const unsubscribe = gardenAudio.subscribe(syncState);
    return () => unsubscribe();
  }, []);

  // Sinkronkan master mute dengan soundEnabled dari game store
  useEffect(() => {
    gardenAudio.setMuted(!soundEnabled);
  }, [soundEnabled]);

  // Auto-start BGM saat interaksi pengguna pertama kali (klik/touch di halaman)
  useEffect(() => {
    const handleFirstInteraction = () => {
      if (!gardenAudio.isBGMPlaying() && soundEnabled) {
        gardenAudio.startBGM();
      }
      window.removeEventListener('pointerdown', handleFirstInteraction);
      window.removeEventListener('keydown', handleFirstInteraction);
    };

    window.addEventListener('pointerdown', handleFirstInteraction, { once: true });
    window.addEventListener('keydown', handleFirstInteraction, { once: true });

    return () => {
      window.removeEventListener('pointerdown', handleFirstInteraction);
      window.removeEventListener('keydown', handleFirstInteraction);
    };
  }, [soundEnabled]);

  // Tutup panel popover jika pengguna mengklik di luar area player
  useEffect(() => {
    const handleClickOutside = (e: MouseEvent) => {
      if (playerRef.current && !playerRef.current.contains(e.target as Node)) {
        setPanelOpen(false);
      }
    };
    if (panelOpen) {
      document.addEventListener('mousedown', handleClickOutside);
    }
    return () => {
      document.removeEventListener('mousedown', handleClickOutside);
    };
  }, [panelOpen]);

  const handleToggleBGM = (e: React.MouseEvent) => {
    e.stopPropagation();
    gardenAudio.playClick();
    if (bgmPlaying) {
      gardenAudio.stopBGM();
    } else {
      if (!soundEnabled) {
        setSoundEnabled(true);
      }
      gardenAudio.startBGM();
    }
  };

  const handleToggleMute = (e: React.MouseEvent) => {
    e.stopPropagation();
    gardenAudio.playClick();
    const nextState = !soundEnabled;
    setSoundEnabled(nextState);
    gardenAudio.setMuted(!nextState);
  };

  const handleDownloadWav = async () => {
    try {
      setDownloading(true);
      gardenAudio.playClick();
      await gardenAudio.downloadGardenBGM(4);
    } finally {
      setDownloading(false);
    }
  };

  return (
    <div ref={playerRef} className="relative inline-block text-left" data-testid="kawaii-music-player">
      {/* Pill Utama Kawaii Music Player */}
      <div className="flex items-center gap-1 rounded-xl border border-garden-gold/60 bg-garden-cream/95 p-0.5 shadow-xs transition hover:bg-garden-blush">
        {/* Tombol Play/Pause BGM */}
        <button
          type="button"
          onClick={handleToggleBGM}
          title={bgmPlaying ? 'Jeda Musik Latar' : 'Putar Musik Latar'}
          aria-label={bgmPlaying ? 'Jeda Musik Latar' : 'Putar Musik Latar'}
          data-testid="bgm-play-pause-btn"
          className="flex items-center gap-1.5 rounded-lg px-2 py-1 text-xs font-semibold text-garden-deepMauve transition hover:bg-garden-ivory focus:outline-none focus:ring-1 focus:ring-garden-rose"
        >
          {bgmPlaying ? (
            <span className="flex items-center gap-1">
              <span className="flex h-3 items-end gap-0.5">
                <span className="h-2 w-0.5 animate-bounce rounded-full bg-garden-rose" />
                <span className="h-3 w-0.5 animate-bounce rounded-full bg-garden-gold [animation-delay:120ms]" />
                <span className="h-2.5 w-0.5 animate-bounce rounded-full bg-garden-deepMauve [animation-delay:240ms]" />
              </span>
              <Pause className="h-3.5 w-3.5 text-garden-rose" />
            </span>
          ) : (
            <span className="flex items-center gap-1">
              <Music className="h-3.5 w-3.5 text-garden-mauve/70" />
              <Play className="h-3 w-3 text-garden-mauve/70" />
            </span>
          )}
          <span className="hidden sm:inline">
            {bgmPlaying ? 'BGM Nyala' : 'BGM'}
          </span>
        </button>

        {/* Pemisah Halus */}
        <span className="h-4 w-px bg-garden-gold/40" />

        {/* Tombol Toggle Mute Master Audio */}
        <button
          type="button"
          onClick={handleToggleMute}
          title={soundEnabled ? 'Bisukan Semua Suara' : 'Bunyikan Semua Suara'}
          aria-label={soundEnabled ? 'Bisukan Semua Suara' : 'Bunyikan Semua Suara'}
          data-testid="sound-mute-toggle-btn"
          className="flex items-center rounded-lg p-1 text-garden-mauve transition hover:bg-garden-ivory hover:text-garden-rose focus:outline-none focus:ring-1 focus:ring-garden-rose"
        >
          {soundEnabled ? (
            <Volume2 className="h-3.5 w-3.5 text-garden-rose" />
          ) : (
            <VolumeX className="h-3.5 w-3.5 text-garden-mauve/60" />
          )}
        </button>

        {/* Tombol Buka Panel Detail Musik */}
        <button
          type="button"
          onClick={() => setPanelOpen(!panelOpen)}
          title="Buka Menu Kotak Musik"
          aria-label="Buka Menu Kotak Musik"
          aria-expanded={panelOpen}
          data-testid="music-menu-dropdown-btn"
          className="flex items-center rounded-lg px-1 py-1 text-garden-mauve/70 transition hover:bg-garden-ivory hover:text-garden-deepMauve focus:outline-none focus:ring-1 focus:ring-garden-rose"
        >
          {panelOpen ? (
            <ChevronUp className="h-3 w-3" />
          ) : (
            <ChevronDown className="h-3 w-3" />
          )}
        </button>
      </div>

      {/* Popover Menu Kawaii Music Player */}
      {panelOpen && (
        <div
          data-testid="kawaii-music-popover"
          className="absolute right-0 top-full z-50 mt-2 w-72 rounded-2xl border-2 border-garden-gold bg-garden-ivory p-4 text-garden-mauve shadow-card backdrop-blur-md animate-in fade-in zoom-in-95 duration-150"
        >
          {/* Header Popover */}
          <div className="flex items-center justify-between border-b border-garden-gold/40 pb-2.5">
            <div className="flex items-center gap-2">
              <span className="flex h-7 w-7 items-center justify-center rounded-full bg-garden-blush text-sm">
                🌸
              </span>
              <div>
                <h4 className="font-serif text-xs font-bold text-garden-deepMauve">
                  Kotak Musik Taman Romantis
                </h4>
                <p className="text-[10px] text-garden-mauve/75">
                  F Major Pentatonic • 108 BPM
                </p>
              </div>
            </div>
          </div>

          {/* Pengaturan BGM & Volume */}
          <div className="my-3 space-y-2">
            <div className="flex items-center justify-between rounded-xl bg-garden-cream/80 px-3 py-2 text-xs">
              <span className="font-medium text-garden-deepMauve">Musik Latar (BGM)</span>
              <button
                type="button"
                onClick={handleToggleBGM}
                className={`rounded-lg px-2.5 py-1 text-[11px] font-semibold transition ${
                  bgmPlaying
                    ? 'bg-garden-rose text-white shadow-xs'
                    : 'border border-garden-gold/60 bg-garden-ivory text-garden-mauve hover:bg-garden-blush'
                }`}
              >
                {bgmPlaying ? 'Jeda' : 'Putar'}
              </button>
            </div>

            <div className="flex items-center justify-between rounded-xl bg-garden-cream/80 px-3 py-2 text-xs">
              <span className="font-medium text-garden-deepMauve">Master Suara (SFX)</span>
              <button
                type="button"
                onClick={handleToggleMute}
                className={`rounded-lg px-2.5 py-1 text-[11px] font-semibold transition ${
                  soundEnabled
                    ? 'bg-garden-gold text-garden-deepMauve shadow-xs'
                    : 'border border-garden-gold/60 bg-garden-ivory text-garden-mauve hover:bg-garden-blush'
                }`}
              >
                {soundEnabled ? 'Aktif' : 'Bisu'}
              </button>
            </div>
          </div>

          {/* Panel Uji Coba SFX */}
          <div className="mb-3 rounded-xl border border-garden-gold/30 bg-garden-cream/50 p-2.5">
            <p className="mb-1.5 text-[10px] font-semibold uppercase tracking-wider text-garden-rose">
              Uji Coba Efek Suara Kawaii
            </p>
            <div className="grid grid-cols-3 gap-1.5 text-[10px]">
              <button
                type="button"
                onClick={() => gardenAudio.playDiceRoll()}
                className="flex items-center justify-center gap-1 rounded-md border border-garden-gold/40 bg-garden-ivory py-1 font-medium text-garden-mauve hover:bg-garden-blush"
              >
                <Dices className="h-2.5 w-2.5 text-garden-rose" /> Dadu
              </button>
              <button
                type="button"
                onClick={() => gardenAudio.playSpecialCard('truth')}
                className="flex items-center justify-center gap-1 rounded-md border border-garden-gold/40 bg-garden-ivory py-1 font-medium text-garden-mauve hover:bg-garden-blush"
              >
                <Heart className="h-2.5 w-2.5 text-garden-rose" /> Truth
              </button>
              <button
                type="button"
                onClick={() => gardenAudio.playSpecialCard('dare')}
                className="flex items-center justify-center gap-1 rounded-md border border-garden-gold/40 bg-garden-ivory py-1 font-medium text-garden-mauve hover:bg-garden-blush"
              >
                <Sparkles className="h-2.5 w-2.5 text-garden-gold" /> Dare
              </button>
              <button
                type="button"
                onClick={() => gardenAudio.playLadderClimb()}
                className="flex items-center justify-center gap-1 rounded-md border border-garden-gold/40 bg-garden-ivory py-1 font-medium text-garden-mauve hover:bg-garden-blush"
              >
                Tangga
              </button>
              <button
                type="button"
                onClick={() => gardenAudio.playSnakeSlide()}
                className="flex items-center justify-center gap-1 rounded-md border border-garden-gold/40 bg-garden-ivory py-1 font-medium text-garden-mauve hover:bg-garden-blush"
              >
                Ular
              </button>
              <button
                type="button"
                onClick={() => gardenAudio.playVictory()}
                className="flex items-center justify-center gap-1 rounded-md border border-garden-gold/40 bg-garden-ivory py-1 font-medium text-garden-mauve hover:bg-garden-blush"
              >
                <Crown className="h-2.5 w-2.5 text-garden-gold" /> Menang
              </button>
            </div>
          </div>

          {/* Tombol Unduh File BGM WAV Asli */}
          <button
            type="button"
            onClick={handleDownloadWav}
            disabled={downloading}
            className="flex w-full items-center justify-center gap-1.5 rounded-xl border border-garden-gold/60 bg-gradient-to-r from-garden-blush to-garden-cream py-2 text-xs font-semibold text-garden-deepMauve shadow-xs transition hover:brightness-95 disabled:opacity-50"
          >
            <Download className="h-3.5 w-3.5 text-garden-rose" />
            {downloading ? 'Merender Audio WAV...' : 'Unduh BGM (WAV Asli)'}
          </button>
        </div>
      )}
    </div>
  );
}
