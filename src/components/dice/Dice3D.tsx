'use client';

import React, { useEffect, useRef } from 'react';
import { useFrame } from '@react-three/fiber';
import { RoundedBox } from '@react-three/drei';
import * as THREE from 'three';
import { getRotationForDiceValue } from '@/game/dice/diceLogic';
import { useGameStore } from '@/game/store/useGameStore';
import { soundEngine } from '../audio/soundEngine';

const PIP_PATTERNS: Record<number, [number, number][]> = {
  1: [[0, 0]],
  2: [
    [-0.18, -0.18],
    [0.18, 0.18],
  ],
  3: [
    [-0.2, -0.2],
    [0, 0],
    [0.2, 0.2],
  ],
  4: [
    [-0.18, -0.18],
    [0.18, -0.18],
    [-0.18, 0.18],
    [0.18, 0.18],
  ],
  5: [
    [-0.19, -0.19],
    [0.19, -0.19],
    [0, 0],
    [-0.19, 0.19],
    [0.19, 0.19],
  ],
  6: [
    [-0.18, -0.2],
    [0.18, -0.2],
    [-0.18, 0],
    [0.18, 0],
    [-0.18, 0.2],
    [0.18, 0.2],
  ],
};

function FacePips({
  value,
  position,
  rotation,
}: {
  value: number;
  position: [number, number, number];
  rotation: [number, number, number];
}) {
  const pips = PIP_PATTERNS[value] ?? [];
  return (
    <group position={position} rotation={rotation}>
      {pips.map(([px, py], idx) => (
        <mesh key={idx} position={[px, py, 0]}>
          <circleGeometry args={[0.055, 16]} />
          <meshStandardMaterial
            color={value === 1 ? '#C98296' : '#654754'}
            roughness={0.25}
            metalness={0.4}
          />
        </mesh>
      ))}
    </group>
  );
}

export function Dice3D() {
  const phase = useGameStore((s) => s.phase);
  const lastDiceValue = useGameStore((s) => s.lastDiceValue);
  const reducedMotion = useGameStore((s) => s.reducedMotion);
  const soundEnabled = useGameStore((s) => s.soundEnabled);
  const rollDice = useGameStore((s) => s.rollDice);
  const notifyDiceAnimationComplete = useGameStore(
    (s) => s.notifyDiceAnimationComplete
  );

  const dieRef = useRef<THREE.Group | null>(null);
  const animRef = useRef<{
    rolling: boolean;
    elapsed: number;
    duration: number;
    targetEuler: [number, number, number];
  }>({
    rolling: false,
    elapsed: 0,
    duration: 0.9,
    targetEuler: [0, 0, 0],
  });

  useEffect(() => {
    if (phase === 'rolling' && lastDiceValue !== null) {
      const targetEuler = getRotationForDiceValue(lastDiceValue);
      animRef.current = {
        rolling: true,
        elapsed: 0,
        duration: reducedMotion ? 0.25 : 0.92,
        targetEuler,
      };
      soundEngine.playDiceRoll(soundEnabled);
    }
  }, [phase, lastDiceValue, reducedMotion, soundEnabled]);

  useFrame((_, delta) => {
    const die = dieRef.current;
    if (!die) return;

    if (phase === 'rolling' && animRef.current.rolling) {
      const a = animRef.current;
      a.elapsed += delta;
      const t = Math.min(1, a.elapsed / a.duration);
      const easeOut = 1 - Math.pow(1 - t, 3);

      const extraSpins = reducedMotion ? 1 : 3;
      const spinAngle = (1 - easeOut) * Math.PI * 2 * extraSpins;

      die.rotation.set(
        a.targetEuler[0] + spinAngle,
        a.targetEuler[1] + spinAngle * 0.7,
        a.targetEuler[2] + spinAngle * 0.5
      );

      const bounce = reducedMotion
        ? 0
        : Math.abs(Math.sin(t * Math.PI * 2.5)) * (1 - t) * 1.35;
      die.position.y = 0.85 + bounce;

      if (t >= 1) {
        a.rolling = false;
        die.rotation.set(a.targetEuler[0], a.targetEuler[1], a.targetEuler[2]);
        die.position.y = 0.85;
        notifyDiceAnimationComplete();
      }
    } else if (lastDiceValue !== null) {
      const target = getRotationForDiceValue(lastDiceValue);
      die.rotation.set(target[0], target[1], target[2]);
      die.position.y = 0.85;
    }
  });

  const offset = 0.385;

  return (
    <group position={[6.8, 0, 3.6]} name="interactive-3d-die-pedestal">
      <mesh position={[0, 0.2, 0]} receiveShadow castShadow>
        <cylinderGeometry args={[0.95, 1.12, 0.42, 32]} />
        <meshStandardMaterial color="#FFF7ED" roughness={0.35} metalness={0.1} />
      </mesh>
      <mesh position={[0, 0.42, 0]} receiveShadow>
        <cylinderGeometry args={[0.82, 0.88, 0.06, 32]} />
        <meshStandardMaterial color="#C99A72" roughness={0.28} metalness={0.65} />
      </mesh>

      <group
        ref={dieRef}
        position={[0, 0.85, 0]}
        onClick={(e) => {
          e.stopPropagation();
          if (phase === 'ready') {
            rollDice();
          }
        }}
      >
        <RoundedBox
          args={[0.76, 0.76, 0.76]}
          radius={0.09}
          smoothness={4}
          castShadow
          receiveShadow
        >
          <meshStandardMaterial
            color="#FFFDF8"
            roughness={0.2}
            metalness={0.08}
          />
        </RoundedBox>

        <FacePips
          value={1}
          position={[0, offset, 0]}
          rotation={[-Math.PI / 2, 0, 0]}
        />
        <FacePips
          value={6}
          position={[0, -offset, 0]}
          rotation={[Math.PI / 2, 0, 0]}
        />
        <FacePips value={2} position={[0, 0, offset]} rotation={[0, 0, 0]} />
        <FacePips
          value={5}
          position={[0, 0, -offset]}
          rotation={[0, Math.PI, 0]}
        />
        <FacePips
          value={3}
          position={[offset, 0, 0]}
          rotation={[0, Math.PI / 2, 0]}
        />
        <FacePips
          value={4}
          position={[-offset, 0, 0]}
          rotation={[0, -Math.PI / 2, 0]}
        />
      </group>
    </group>
  );
}
