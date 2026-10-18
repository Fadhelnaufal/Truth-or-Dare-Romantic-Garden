#!/usr/bin/env bash
set -euo pipefail

echo "🐱🎀 Mengintegrasikan 6 karakter dari cats.glb & toys_kuromi_melody_and_hello_kitty.glb ke dalam game..."

mkdir -p public/models

cat << 'EOF' > src/game/types/index.ts
export type GamePhase =
  | 'setup'
  | 'ready'
  | 'rolling'
  | 'moving'
  | 'resolving_event'
  | 'awaiting_challenge'
  | 'transitioning'
  | 'turn_complete'
  | 'victory';

export type AnimationPhase =
  | 'idle'
  | 'rolling'
  | 'moving'
  | 'reacting'
  | 'transitioning'
  | 'celebrating'
  | 'victory';

export type TileType =
  | 'normal'
  | 'start'
  | 'finish'
  | 'truth'
  | 'dare'
  | 'snake_head'
  | 'snake_tail'
  | 'ladder_bottom'
  | 'ladder_top';

export type ChallengeType = 'truth' | 'dare';

export type TruthCategory =
  | 'Awal Jatuh Cinta'
  | 'Perasaan yang Jarang Diucapkan'
  | 'Bikin Salting dan Baper'
  | 'Kejujuran dan Kedekatan'
  | 'Masa Depan Bersama';

export type DareCategory =
  | 'Manis dan Romantis'
  | 'Bikin Hati Meleleh'
  | 'Kenangan Berdua'
  | 'Kedekatan yang Lebih Dalam'
  | 'Momen untuk Diingat';

export interface ChallengeCard {
  id: string;
  type: ChallengeType;
  category: TruthCategory | DareCategory;
  prompt: string;
  intimacyNote?: string;
  isCustom?: boolean;
}

export interface CustomCardInput {
  type: ChallengeType;
  category: TruthCategory | DareCategory;
  prompt: string;
}

export type SnakeStyle = 'jade_sculpt' | 'sage_stone' | 'rose_bronze' | 'ivory_serpent';
export type LadderStyle = 'warm_oak' | 'painted_ivory' | 'rose_gold_trellis';

export interface SnakeDefinition {
  id: string;
  name: string;
  head: number;
  tail: number;
  style: SnakeStyle;
}

export interface LadderDefinition {
  id: string;
  name: string;
  bottom: number;
  top: number;
  style: LadderStyle;
}

export interface Vector3Tuple {
  x: number;
  y: number;
  z: number;
}

export interface SquareMetadata {
  square: number;
  row: number;
  col: number;
  worldPosition: Vector3Tuple;
  type: TileType;
  snakeId?: string;
  ladderId?: string;
}

export interface BoardConfiguration {
  rows: number;
  cols: number;
  totalSquares: number;
  tileSize: number;
  tileGap: number;
  boardElevation: number;
  startSquare: number;
  finishSquare: number;
  truthSquares: number[];
  dareSquares: number[];
  snakes: SnakeDefinition[];
  ladders: LadderDefinition[];
  squares: Record<number, SquareMetadata>;
}

export type PieceStyleId =
  | 'kuromi_toy'
  | 'melody_toy'
  | 'hello_kitty_toy'
  | 'cat_classic'
  | 'cat_panda'
  | 'cat_shark'
  | 'ivory_rose_gold'
  | 'blush_quartz'
  | 'sage_celadon'
  | 'lavender_pearl';

export interface GLBNodeConfig {
  url: string;
  nodeName: string;
  targetHeight: number;
  rotationY?: number;
}

export interface PieceStyleDefinition {
  id: PieceStyleId;
  label: string;
  primaryColor: string;
  accentColor: string;
  silhouette: 'crown_spire' | 'rose_chalice' | 'bloom_obelisk' | 'heart_column';
  glbConfig?: GLBNodeConfig;
}

export interface PlayerState {
  id: string;
  name: string;
  pieceStyle: PieceStyleId;
  color: string;
  accentColor: string;
  square: number;
  completedChallenges: number;
  skippedChallenges: number;
}

export interface PlayerSetupInput {
  name: string;
  pieceStyle: PieceStyleId;
}

export interface ActiveTransition {
  kind: 'snake' | 'ladder';
  id: string;
  name: string;
  fromSquare: number;
  toSquare: number;
}

export interface MoveRecord {
  id: string;
  turnNumber: number;
  playerId: string;
  playerName: string;
  diceValue: number;
  fromSquare: number;
  landedSquare: number;
  finalSquare: number;
  overshot: boolean;
  transition?: ActiveTransition;
  challenge?: {
    cardId: string;
    type: ChallengeType;
    category: string;
    outcome: 'completed' | 'skipped';
  };
  wonMatch: boolean;
  timestamp: number;
}

export interface GameEngineState {
  phase: GamePhase;
  animationPhase: AnimationPhase;
  players: PlayerState[];
  activePlayerIndex: number;
  turnNumber: number;
  lastDiceValue: number | null;
  pendingPath: number[];
  overshotLastRoll: boolean;
  activeChallenge: ChallengeCard | null;
  activeTransition: ActiveTransition | null;
  winnerId: string | null;
  moveHistory: MoveRecord[];
  statusMessage: string;
  usedTruthIds: string[];
  usedDareIds: string[];
  customCards: ChallengeCard[];
}

export type RandomSource = () => number;
EOF

cat << 'EOF' > src/game/players/playerStyles.ts
import { PieceStyleDefinition, PieceStyleId, PlayerSetupInput, PlayerState } from '../types';

export const PIECE_STYLES: PieceStyleDefinition[] = [
  // 3 Karakter dari toys_kuromi_melody_and_hello_kitty.glb (Kuromi, My Melody, Hello Kitty)
  {
    id: 'kuromi_toy',
    label: '🎀 Kuromi (3D GLB)',
    primaryColor: '#47303A',
    accentColor: '#C98296',
    silhouette: 'crown_spire',
    glbConfig: {
      url: '/models/toys_kuromi_melody_and_hello_kitty.glb',
      nodeName: 'Plane_0',
      targetHeight: 0.68,
      rotationY: 0,
    },
  },
  {
    id: 'melody_toy',
    label: '🌸 My Melody (3D GLB)',
    primaryColor: '#F4D7DE',
    accentColor: '#CC445B',
    silhouette: 'rose_chalice',
    glbConfig: {
      url: '/models/toys_kuromi_melody_and_hello_kitty.glb',
      nodeName: 'Plane.002_1',
      targetHeight: 0.68,
      rotationY: 0,
    },
  },
  {
    id: 'hello_kitty_toy',
    label: '🐱 Hello Kitty (3D GLB)',
    primaryColor: '#FFFDF8',
    accentColor: '#CC1226',
    silhouette: 'heart_column',
    glbConfig: {
      url: '/models/toys_kuromi_melody_and_hello_kitty.glb',
      nodeName: 'Plane.001_2',
      targetHeight: 0.66,
      rotationY: 0,
    },
  },

  // 3 Karakter dari cats.glb (Kucing Klasik, Kucing Panda, Kucing Hiu)
  {
    id: 'cat_classic',
    label: '🐾 Kucing Manis (3D GLB)',
    primaryColor: '#FFF7ED',
    accentColor: '#C99A72',
    silhouette: 'bloom_obelisk',
    glbConfig: {
      url: '/models/cats.glb',
      nodeName: 'cat_1',
      targetHeight: 0.58,
      rotationY: 0,
    },
  },
  {
    id: 'cat_panda',
    label: '🐼 Kucing Panda (3D GLB)',
    primaryColor: '#FFFDF8',
    accentColor: '#654754',
    silhouette: 'crown_spire',
    glbConfig: {
      url: '/models/cats.glb',
      nodeName: 'panda_0',
      targetHeight: 0.58,
      rotationY: 0,
    },
  },
  {
    id: 'cat_shark',
    label: '🦈 Kucing Hiu (3D GLB)',
    primaryColor: '#DCD5F0',
    accentColor: '#C98296',
    silhouette: 'rose_chalice',
    glbConfig: {
      url: '/models/cats.glb',
      nodeName: 'shark_2',
      targetHeight: 0.6,
      rotationY: 0,
    },
  },

  // 4 Bidak Marmer Prosedural Klasik
  {
    id: 'ivory_rose_gold',
    label: '♔ Gading Mawar Kencana',
    primaryColor: '#FFF7ED',
    accentColor: '#C99A72',
    silhouette: 'crown_spire',
  },
  {
    id: 'blush_quartz',
    label: '♕ Kuarsa Merah Muda',
    primaryColor: '#F4D7DE',
    accentColor: '#C98296',
    silhouette: 'rose_chalice',
  },
  {
    id: 'sage_celadon',
    label: '♗ Giok Embun Taman',
    primaryColor: '#A9B9A0',
    accentColor: '#FFF7ED',
    silhouette: 'bloom_obelisk',
  },
  {
    id: 'lavender_pearl',
    label: '♘ Mutiara Lembayung',
    primaryColor: '#DCD5F0',
    accentColor: '#654754',
    silhouette: 'heart_column',
  },
];

export const DEFAULT_PLAYERS_SETUP: PlayerSetupInput[] = [
  { name: 'Sayang 1', pieceStyle: 'kuromi_toy' },
  { name: 'Sayang 2', pieceStyle: 'melody_toy' },
];

export function createInitialPlayers(
  inputs: PlayerSetupInput[] = DEFAULT_PLAYERS_SETUP
): PlayerState[] {
  const clampedInputs = inputs.slice(0, 4);
  if (clampedInputs.length < 2) {
    throw new Error('At least two players are required to start a match.');
  }

  return clampedInputs.map((input, index) => {
    const style =
      PIECE_STYLES.find((s) => s.id === input.pieceStyle) ??
      PIECE_STYLES[index % PIECE_STYLES.length];

    return {
      id: `player-${index + 1}`,
      name: input.name.trim() || `Pemain ${index + 1}`,
      pieceStyle: style.id as PieceStyleId,
      color: style.primaryColor,
      accentColor: style.accentColor,
      square: 1,
      completedChallenges: 0,
      skippedChallenges: 0,
    };
  });
}
EOF

cat << 'EOF' > src/components/pieces/GLBCharacterPiece.tsx
'use client';

import React, { Component, Suspense, useMemo } from 'react';
import { useGLTF } from '@react-three/drei';
import * as THREE from 'three';
import { GLBNodeConfig } from '@/game/types';

interface GLBCharacterPieceProps {
  config: GLBNodeConfig;
  fallback: React.ReactNode;
}

class GLBPieceErrorBoundary extends Component<
  { fallback: React.ReactNode; children: React.ReactNode },
  { hasError: boolean }
> {
  constructor(props: { fallback: React.ReactNode; children: React.ReactNode }) {
    super(props);
    this.state = { hasError: false };
  }

  static getDerivedStateFromError() {
    return { hasError: true };
  }

  render() {
    if (this.state.hasError) {
      return this.props.fallback;
    }
    return this.props.children;
  }
}

function ExtractedGLBNode({ config }: { config: GLBNodeConfig }) {
  const { scene } = useGLTF(config.url);

  const normalizedClone = useMemo(() => {
    const targetNode = scene.getObjectByName(config.nodeName) ?? scene;

    // Bungkus dalam grup baru dan kloning seluruh hierarki mesh & materialnya
    const wrapper = new THREE.Group();
    const clonedSubtree = targetNode.clone(true);

    // Pertahankan orientasi Z-up -> Y-up dari GLTF_SceneRootNode Sketchfab
    // namun hapus translasi offset X/Y/Z bawaan supaya bisa di-center otomatis
    clonedSubtree.position.set(0, 0, 0);

    // Karena model Sketchfab memiliki rotasi induk pada Sketchfab_model & GLTF_SceneRootNode,
    // kita terapkan koreksi orientasi agar karakter berdiri tegak di sumbu +Y
    const rootHolder = new THREE.Group();
    if (config.url.includes('cats.glb')) {
      // Pada cats.glb, sumbu Z lokal adalah tinggi karakter (-1.03 s.d. 0)
      rootHolder.rotation.set(Math.PI / 2, 0, 0);
    } else if (config.url.includes('toys_kuromi_melody_and_hello_kitty.glb') && config.nodeName === 'Plane_0') {
      // Pada toys_kuromi_melody_and_hello_kitty.glb, Plane_0 (Kuromi) memiliki matriks rotasi khusus dibanding Plane.001_2 & Plane.002_1
      rootHolder.rotation.set(0, Math.PI / 2, 0);
    }

    rootHolder.add(clonedSubtree);
    wrapper.add(rootHolder);

    // Aktifkan bayangan pada setiap sub-mesh
    wrapper.traverse((child) => {
      if ((child as THREE.Mesh).isMesh) {
        child.castShadow = true;
        child.receiveShadow = true;
      }
    });

    // Hitung bounding box aktual untuk menormalisasi skala dan menapakkan alas ke Y = 0
    wrapper.updateMatrixWorld(true);
    const box = new THREE.Box3().setFromObject(wrapper);
    const size = new THREE.Vector3();
    const center = new THREE.Vector3();
    box.getSize(size);
    box.getCenter(center);

    const maxDimension = Math.max(size.x, size.y, size.z, 0.001);
    const scaleFactor = config.targetHeight / maxDimension;

    wrapper.scale.setScalar(scaleFactor);
    wrapper.updateMatrixWorld(true);

    // Hitung ulang box setelah diskalakan agar tepat di tengah (X=0, Z=0) dan menapak di Y=0.06
    const scaledBox = new THREE.Box3().setFromObject(wrapper);
    const scaledCenter = new THREE.Vector3();
    scaledBox.getCenter(scaledCenter);

    wrapper.position.set(
      -scaledCenter.x,
      -scaledBox.min.y + 0.06,
      -scaledCenter.z
    );

    if (config.rotationY) {
      wrapper.rotation.y = config.rotationY;
    }

    return wrapper;
  }, [scene, config]);

  return <primitive object={normalizedClone} />;
}

export function GLBCharacterPiece({ config, fallback }: GLBCharacterPieceProps) {
  return (
    <GLBPieceErrorBoundary fallback={fallback}>
      <Suspense fallback={fallback}>
        <ExtractedGLBNode config={config} />
      </Suspense>
    </GLBPieceErrorBoundary>
  );
}
EOF

cat << 'EOF' > src/components/pieces/PlayerPieces3D.tsx
'use client';

import React, { useEffect, useRef } from 'react';
import { useFrame } from '@react-three/fiber';
import * as THREE from 'three';
import { BOARD_CONFIG, getPieceStackOffset } from '@/game/board/boardConfig';
import { PIECE_STYLES } from '@/game/players/playerStyles';
import { useGameStore } from '@/game/store/useGameStore';
import { PlayerState } from '@/game/types';
import { soundEngine } from '../audio/soundEngine';
import { GLBCharacterPiece } from './GLBCharacterPiece';

function ProceduralMarblePiece({
  player,
  index,
}: {
  player: PlayerState;
  index: number;
}) {
  return (
    <group>
      <mesh position={[0, 0.06, 0]} castShadow receiveShadow>
        <cylinderGeometry args={[0.2, 0.24, 0.12, 24]} />
        <meshStandardMaterial
          color={player.color}
          roughness={0.22}
          metalness={0.15}
        />
      </mesh>

      <mesh position={[0, 0.14, 0]} castShadow>
        <cylinderGeometry args={[0.17, 0.19, 0.05, 24]} />
        <meshStandardMaterial
          color={player.accentColor}
          roughness={0.25}
          metalness={0.75}
        />
      </mesh>

      <mesh position={[0, 0.34, 0]} castShadow>
        <cylinderGeometry args={[0.11, 0.16, 0.36, 24]} />
        <meshStandardMaterial
          color={player.color}
          roughness={0.2}
          metalness={0.12}
        />
      </mesh>

      {index % 2 === 0 ? (
        <mesh position={[0, 0.58, 0]} castShadow>
          <sphereGeometry args={[0.13, 24, 24]} />
          <meshStandardMaterial
            color={player.accentColor}
            roughness={0.2}
            metalness={0.68}
          />
        </mesh>
      ) : (
        <mesh
          position={[0, 0.59, 0]}
          rotation={[0, Math.PI / 4, 0]}
          castShadow
        >
          <octahedronGeometry args={[0.14, 0]} />
          <meshStandardMaterial
            color={player.accentColor}
            roughness={0.18}
            metalness={0.72}
          />
        </mesh>
      )}
    </group>
  );
}

export function PlayerPieces3D() {
  const players = useGameStore((s) => s.players);
  const activePlayerIndex = useGameStore((s) => s.activePlayerIndex);
  const phase = useGameStore((s) => s.phase);
  const pendingPath = useGameStore((s) => s.pendingPath);
  const activeTransition = useGameStore((s) => s.activeTransition);
  const reducedMotion = useGameStore((s) => s.reducedMotion);
  const soundEnabled = useGameStore((s) => s.soundEnabled);

  const notifyMovementAnimationComplete = useGameStore(
    (s) => s.notifyMovementAnimationComplete
  );
  const notifyTransitionAnimationComplete = useGameStore(
    (s) => s.notifyTransitionAnimationComplete
  );

  const pieceRefs = useRef<Record<string, THREE.Group | null>>({});

  const moveProgressRef = useRef<{
    active: boolean;
    stepIndex: number;
    stepProgress: number;
    fromPos: THREE.Vector3;
    toPos: THREE.Vector3;
  }>({
    active: false,
    stepIndex: 0,
    stepProgress: 0,
    fromPos: new THREE.Vector3(),
    toPos: new THREE.Vector3(),
  });

  const transitionProgressRef = useRef<{
    active: boolean;
    progress: number;
    fromPos: THREE.Vector3;
    toPos: THREE.Vector3;
    kind: 'snake' | 'ladder';
  }>({
    active: false,
    progress: 0,
    fromPos: new THREE.Vector3(),
    toPos: new THREE.Vector3(),
    kind: 'ladder',
  });

  useEffect(() => {
    if (phase === 'moving' && pendingPath.length > 0) {
      const activePlayer = players[activePlayerIndex];
      const startSq = activePlayer.square;
      const firstTargetSq = pendingPath[0];
      const startCoord = BOARD_CONFIG.squares[startSq].worldPosition;
      const nextCoord = BOARD_CONFIG.squares[firstTargetSq].worldPosition;

      moveProgressRef.current = {
        active: true,
        stepIndex: 0,
        stepProgress: 0,
        fromPos: new THREE.Vector3(startCoord.x, startCoord.y, startCoord.z),
        toPos: new THREE.Vector3(nextCoord.x, nextCoord.y, nextCoord.z),
      };
      soundEngine.playStepHop(soundEnabled, 0);
    } else {
      moveProgressRef.current.active = false;
    }
  }, [phase, pendingPath, activePlayerIndex, players, soundEnabled]);

  useEffect(() => {
    if (phase === 'transitioning' && activeTransition) {
      const startCoord =
        BOARD_CONFIG.squares[activeTransition.fromSquare].worldPosition;
      const endCoord =
        BOARD_CONFIG.squares[activeTransition.toSquare].worldPosition;

      transitionProgressRef.current = {
        active: true,
        progress: 0,
        fromPos: new THREE.Vector3(startCoord.x, startCoord.y, startCoord.z),
        toPos: new THREE.Vector3(endCoord.x, endCoord.y, endCoord.z),
        kind: activeTransition.kind,
      };

      if (activeTransition.kind === 'ladder') {
        soundEngine.playLadderClimb(soundEnabled);
      } else {
        soundEngine.playSnakeSlide(soundEnabled);
      }
    } else {
      transitionProgressRef.current.active = false;
    }
  }, [phase, activeTransition, soundEnabled]);

  useEffect(() => {
    if (phase === 'victory') {
      soundEngine.playVictoryFanfare(soundEnabled);
    }
  }, [phase, soundEnabled]);

  useFrame((state, delta) => {
    const activePlayer = players[activePlayerIndex];

    if (phase === 'moving' && moveProgressRef.current.active && activePlayer) {
      const speed = reducedMotion ? 9.0 : 4.2;
      const m = moveProgressRef.current;
      m.stepProgress += delta * speed;

      const group = pieceRefs.current[activePlayer.id];
      if (group) {
        const t = Math.min(1, m.stepProgress);
        const lerped = new THREE.Vector3().lerpVectors(m.fromPos, m.toPos, t);
        const bounceArc = reducedMotion ? 0 : Math.sin(t * Math.PI) * 0.42;
        group.position.set(lerped.x, lerped.y + 0.12 + bounceArc, lerped.z);
      }

      if (m.stepProgress >= 1) {
        const nextStepIndex = m.stepIndex + 1;
        if (nextStepIndex < pendingPath.length) {
          const prevSq = pendingPath[m.stepIndex];
          const nextSq = pendingPath[nextStepIndex];
          const pCoord = BOARD_CONFIG.squares[prevSq].worldPosition;
          const nCoord = BOARD_CONFIG.squares[nextSq].worldPosition;

          m.stepIndex = nextStepIndex;
          m.stepProgress = 0;
          m.fromPos.set(pCoord.x, pCoord.y, pCoord.z);
          m.toPos.set(nCoord.x, nCoord.y, nCoord.z);
          soundEngine.playStepHop(soundEnabled, nextStepIndex);
        } else {
          m.active = false;
          notifyMovementAnimationComplete();
        }
      }
      return;
    }

    if (
      phase === 'transitioning' &&
      transitionProgressRef.current.active &&
      activePlayer
    ) {
      const tr = transitionProgressRef.current;
      const speed = reducedMotion ? 3.5 : 1.35;
      tr.progress += delta * speed;
      const t = Math.min(1, tr.progress);
      const smoothT = t * t * (3 - 2 * t);

      const group = pieceRefs.current[activePlayer.id];
      if (group) {
        const pos = new THREE.Vector3().lerpVectors(
          tr.fromPos,
          tr.toPos,
          smoothT
        );
        const arcLift =
          tr.kind === 'ladder'
            ? Math.sin(smoothT * Math.PI) * 0.55
            : Math.sin(smoothT * Math.PI * 2) * 0.12;
        group.position.set(pos.x, pos.y + 0.14 + arcLift, pos.z);
      }

      if (tr.progress >= 1) {
        tr.active = false;
        notifyTransitionAnimationComplete();
      }
      return;
    }

    const squareGroups = new Map<number, string[]>();
    players.forEach((p) => {
      const list = squareGroups.get(p.square) ?? [];
      list.push(p.id);
      squareGroups.set(p.square, list);
    });

    players.forEach((player, idx) => {
      const group = pieceRefs.current[player.id];
      if (!group) return;

      const sqCoord = BOARD_CONFIG.squares[player.square].worldPosition;
      const occupants = squareGroups.get(player.square) ?? [player.id];
      const indexOnSquare = occupants.indexOf(player.id);
      const offset = getPieceStackOffset(indexOnSquare, occupants.length);

      const isWinner = phase === 'victory' && idx === activePlayerIndex;
      const isTurnOwner = idx === activePlayerIndex;
      const idleFloat =
        reducedMotion
          ? 0
          : isWinner
          ? Math.sin(state.clock.elapsedTime * 3.5) * 0.14 + 0.18
          : isTurnOwner
          ? Math.sin(state.clock.elapsedTime * 2.4) * 0.035
          : 0;

      group.position.x = THREE.MathUtils.lerp(
        group.position.x,
        sqCoord.x + offset.x,
        0.22
      );
      group.position.z = THREE.MathUtils.lerp(
        group.position.z,
        sqCoord.z + offset.z,
        0.22
      );
      group.position.y = THREE.MathUtils.lerp(
        group.position.y,
        sqCoord.y + 0.1 + idleFloat,
        0.22
      );
    });
  });

  return (
    <group name="player-pieces-root">
      {players.map((player, index) => {
        const startCoord = BOARD_CONFIG.squares[player.square].worldPosition;
        const isCurrentTurn = index === activePlayerIndex;
        const styleDef = PIECE_STYLES.find((s) => s.id === player.pieceStyle);

        return (
          <group
            key={player.id}
            ref={(el) => {
              pieceRefs.current[player.id] = el;
            }}
            position={[startCoord.x, startCoord.y + 0.1, startCoord.z]}
          >
            {/* Alas Koin Emas Mawar tipis agar karakter GLB tampak menyatu dengan papan */}
            <mesh position={[0, 0.03, 0]} castShadow receiveShadow>
              <cylinderGeometry args={[0.24, 0.27, 0.06, 24]} />
              <meshStandardMaterial
                color={player.accentColor}
                roughness={0.28}
                metalness={0.55}
              />
            </mesh>

            {styleDef?.glbConfig ? (
              <GLBCharacterPiece
                config={styleDef.glbConfig}
                fallback={<ProceduralMarblePiece player={player} index={index} />}
              />
            ) : (
              <ProceduralMarblePiece player={player} index={index} />
            )}

            {isCurrentTurn && (
              <mesh position={[0, 0.01, 0]} rotation={[-Math.PI / 2, 0, 0]}>
                <ringGeometry args={[0.28, 0.35, 32]} />
                <meshBasicMaterial
                  color="#C98296"
                  transparent
                  opacity={0.85}
                />
              </mesh>
            )}
          </group>
        );
      })}
    </group>
  );
}
EOF

echo "✅ Integrasi selesai! Pastikan kedua file .glb sudah kamu letakkan di:"
echo "   - public/models/cats.glb"
echo "   - public/models/toys_kuromi_melody_and_hello_kitty.glb"