'use client';

import React, { useEffect, useState } from 'react';
import { Canvas } from '@react-three/fiber';
import { BOARD_CONFIG } from '@/game/board/boardConfig';
import { useGameStore } from '@/game/store/useGameStore';
import { Board3D } from '../board/Board3D';
import { Dice3D } from '../dice/Dice3D';
import { RomanticGardenEnvironment } from '../environment/RomanticGardenEnvironment';
import { SnakesAndLadders3D } from '../obstacles/SnakesAndLadders3D';
import { PlayerPieces3D } from '../pieces/PlayerPieces3D';
import { GardenCameraController } from './GardenCameraController';

function Fallback2DBoard() {
  const players = useGameStore((s) => s.players);
  const squares = Object.values(BOARD_CONFIG.squares).sort(
    (a, b) => b.row - a.row || a.col - b.col
  );

  return (
    <div
      data-testid="fallback-2d-board"
      className="flex h-full w-full flex-col items-center justify-center bg-garden-ivory p-4 text-garden-mauve"
    >
      <div className="mb-2 rounded-full bg-garden-blush px-4 py-1 text-xs font-medium">
        Mode Papan 2D Aktif (Fallback WebGL) — 100 Kotak Tetap Dapat Dimainkan
      </div>
      <div className="grid aspect-square w-full max-w-[540px] grid-cols-10 gap-1 rounded-2xl border-2 border-garden-gold bg-garden-cream p-2 shadow-romantic">
        {squares.map((sq) => {
          const occupants = players.filter((p) => p.square === sq.square);
          return (
            <div
              key={sq.square}
              data-square={sq.square}
              className="relative flex flex-col items-center justify-between rounded border border-garden-blush bg-garden-ivory p-1 text-[10px]"
            >
              <span className="font-semibold">{sq.square}</span>
              <div className="flex gap-0.5">
                {occupants.map((p) => (
                  <span
                    key={p.id}
                    title={p.name}
                    className="h-2.5 w-2.5 rounded-full border border-garden-mauve"
                    style={{ backgroundColor: p.accentColor }}
                  />
                ))}
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}

export function RomanticGardenScene() {
  const [webglSupported, setWebglSupported] = useState(true);
  const players = useGameStore((s) => s.players);
  const activePlayerIndex = useGameStore((s) => s.activePlayerIndex);
  const activeTransition = useGameStore((s) => s.activeTransition);
  const cameraMode = useGameStore((s) => s.cameraMode);
  const finishCameraIntro = useGameStore((s) => s.finishCameraIntro);

  useEffect(() => {
    try {
      const canvas = document.createElement('canvas');
      const gl =
        canvas.getContext('webgl2') ||
        canvas.getContext('webgl') ||
        canvas.getContext('experimental-webgl');
      if (!gl) {
        setWebglSupported(false);
      }
    } catch {
      setWebglSupported(false);
    }
  }, []);

  const activeSquare = players[activePlayerIndex]?.square ?? null;

  if (!webglSupported) {
    return <Fallback2DBoard />;
  }

  return (
    <div className="relative h-full w-full" data-testid="garden-3d-canvas-wrapper">
      <Canvas
        shadows
        dpr={[1, 2]}
        camera={{ position: [0, 12.6, 11.4], fov: 40, near: 0.1, far: 120 }}
      >
        <color attach="background" args={['#F4D7DE']} />
        <fog attach="fog" args={['#F4D7DE', 18, 42]} />

        <ambientLight intensity={0.78} color="#FFF7ED" />
        <hemisphereLight
          color="#FFFDF8"
          groundColor="#C98296"
          intensity={0.55}
        />
        <directionalLight
          position={[11, 18, 9]}
          intensity={1.35}
          color="#FFE8D6"
          castShadow
          shadow-mapSize-width={1024}
          shadow-mapSize-height={1024}
          shadow-camera-near={1}
          shadow-camera-far={45}
          shadow-camera-left={-12}
          shadow-camera-right={12}
          shadow-camera-top={12}
          shadow-camera-bottom={-12}
        />
        <directionalLight
          position={[-9, 8, -8]}
          intensity={0.4}
          color="#DCD5F0"
        />

        <GardenCameraController />
        <RomanticGardenEnvironment />
        <Board3D highlightedSquare={activeSquare} />
        <SnakesAndLadders3D activeTransitionId={activeTransition?.id ?? null} />
        <PlayerPieces3D />
        <Dice3D />
      </Canvas>

      {cameraMode === 'intro' && (
        <button
          type="button"
          onClick={finishCameraIntro}
          className="absolute top-20 right-6 z-20 rounded-full border border-garden-gold bg-garden-ivory/95 px-4 py-1.5 text-xs font-medium text-garden-mauve shadow-romantic transition hover:bg-garden-blush focus:outline-none focus:ring-2 focus:ring-garden-rose"
        >
          Lewati Intro Kamera →
        </button>
      )}
    </div>
  );
}
