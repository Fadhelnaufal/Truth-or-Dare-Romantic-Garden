'use client';

import React, { useEffect, useRef } from 'react';
import { useFrame } from '@react-three/fiber';
import { useGLTF } from '@react-three/drei';
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

useGLTF.preload('/models/kuromi.glb');
useGLTF.preload('/models/my_melody.glb');
useGLTF.preload('/models/pom.glb');
useGLTF.preload('/models/keroppi.glb');
useGLTF.preload('/models/pochacco.glb');
useGLTF.preload('/models/toys_kuromi_melody_and_hello_kitty.glb');
useGLTF.preload('/models/cats.glb');
