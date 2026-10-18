'use client';

import React, { useMemo } from 'react';
import * as THREE from 'three';
import { BOARD_CONFIG } from '@/game/board/boardConfig';
import { LadderDefinition, SnakeDefinition } from '@/game/types';

interface ObstaclesProps {
  activeTransitionId: string | null;
}

function SnakeMesh({
  snake,
  isHighlighted,
}: {
  snake: SnakeDefinition;
  isHighlighted: boolean;
}) {
  const headPos = BOARD_CONFIG.squares[snake.head].worldPosition;
  const tailPos = BOARD_CONFIG.squares[snake.tail].worldPosition;

  const { curve, headPosition, headLookAt } = useMemo(() => {
    const start = new THREE.Vector3(headPos.x, headPos.y + 0.14, headPos.z);
    const end = new THREE.Vector3(tailPos.x, tailPos.y + 0.12, tailPos.z);
    const dir = new THREE.Vector3().subVectors(end, start);
    const perp = new THREE.Vector3(-dir.z, 0, dir.x).normalize();

    const p1 = start
      .clone()
      .lerp(end, 0.25)
      .addScaledVector(perp, 0.55)
      .add(new THREE.Vector3(0, 0.18, 0));
    const p2 = start
      .clone()
      .lerp(end, 0.55)
      .addScaledVector(perp, -0.55)
      .add(new THREE.Vector3(0, 0.14, 0));
    const p3 = start
      .clone()
      .lerp(end, 0.8)
      .addScaledVector(perp, 0.35)
      .add(new THREE.Vector3(0, 0.1, 0));

    const spline = new THREE.CatmullRomCurve3([start, p1, p2, p3, end]);
    return {
      curve: spline,
      headPosition: start,
      headLookAt: p1,
    };
  }, [headPos, tailPos]);

  const colorMap: Record<SnakeDefinition['style'], string> = {
    jade_sculpt: '#8FA889',
    sage_stone: '#A9B9A0',
    rose_bronze: '#C99A72',
    ivory_serpent: '#E9D5DA',
  };

  const bodyColor = colorMap[snake.style];

  return (
    <group name={snake.id}>
      <mesh castShadow>
        <tubeGeometry args={[curve, 48, 0.085, 12, false]} />
        <meshStandardMaterial
          color={bodyColor}
          roughness={0.28}
          metalness={0.25}
          emissive={isHighlighted ? '#C98296' : '#000000'}
          emissiveIntensity={isHighlighted ? 0.5 : 0}
        />
      </mesh>

      <group
        position={[headPosition.x, headPosition.y + 0.06, headPosition.z]}
        rotation={[
          0,
          Math.atan2(headLookAt.x - headPosition.x, headLookAt.z - headPosition.z),
          0,
        ]}
      >
        <mesh castShadow scale={[1.1, 0.85, 1.4]}>
          <sphereGeometry args={[0.13, 16, 16]} />
          <meshStandardMaterial
            color={bodyColor}
            roughness={0.22}
            metalness={0.35}
          />
        </mesh>
        <mesh position={[0, 0.11, 0.03]}>
          <octahedronGeometry args={[0.045, 0]} />
          <meshStandardMaterial color="#C99A72" metalness={0.8} roughness={0.2} />
        </mesh>
      </group>
    </group>
  );
}

function LadderMesh({
  ladder,
  isHighlighted,
}: {
  ladder: LadderDefinition;
  isHighlighted: boolean;
}) {
  const bottomPos = BOARD_CONFIG.squares[ladder.bottom].worldPosition;
  const topPos = BOARD_CONFIG.squares[ladder.top].worldPosition;

  const { midpoint, length, angleY, angleX, rungCount } = useMemo(() => {
    const start = new THREE.Vector3(bottomPos.x, bottomPos.y + 0.12, bottomPos.z);
    const end = new THREE.Vector3(topPos.x, topPos.y + 0.12, topPos.z);
    const diff = new THREE.Vector3().subVectors(end, start);
    const dist = diff.length();
    const mid = start.clone().lerp(end, 0.5).add(new THREE.Vector3(0, 0.05, 0));

    const yaw = Math.atan2(diff.x, diff.z);
    const pitch = Math.PI / 2;

    return {
      midpoint: mid,
      length: dist,
      angleY: yaw,
      angleX: pitch,
      rungCount: Math.max(4, Math.floor(dist * 2.4)),
    };
  }, [bottomPos, topPos]);

  const railSpacing = 0.26;
  const railColor =
    ladder.style === 'rose_gold_trellis'
      ? '#C99A72'
      : ladder.style === 'painted_ivory'
      ? '#FFF7ED'
      : '#D6B18E';

  return (
    <group
      name={ladder.id}
      position={[midpoint.x, midpoint.y, midpoint.z]}
      rotation={[0, angleY, 0]}
    >
      <mesh
        position={[-railSpacing / 2, 0, 0]}
        rotation={[angleX, 0, 0]}
        castShadow
      >
        <cylinderGeometry args={[0.032, 0.032, length, 10]} />
        <meshStandardMaterial
          color={railColor}
          roughness={0.3}
          metalness={ladder.style === 'rose_gold_trellis' ? 0.65 : 0.15}
          emissive={isHighlighted ? '#C99A72' : '#000000'}
          emissiveIntensity={isHighlighted ? 0.45 : 0}
        />
      </mesh>

      <mesh
        position={[railSpacing / 2, 0, 0]}
        rotation={[angleX, 0, 0]}
        castShadow
      >
        <cylinderGeometry args={[0.032, 0.032, length, 10]} />
        <meshStandardMaterial
          color={railColor}
          roughness={0.3}
          metalness={ladder.style === 'rose_gold_trellis' ? 0.65 : 0.15}
          emissive={isHighlighted ? '#C99A72' : '#000000'}
          emissiveIntensity={isHighlighted ? 0.45 : 0}
        />
      </mesh>

      {Array.from({ length: rungCount }).map((_, idx) => {
        const t = (idx + 1) / (rungCount + 1) - 0.5;
        const zOffset = t * length;
        return (
          <mesh
            key={idx}
            position={[0, 0, zOffset]}
            rotation={[0, 0, Math.PI / 2]}
            castShadow
          >
            <cylinderGeometry args={[0.022, 0.022, railSpacing, 8]} />
            <meshStandardMaterial
              color="#C99A72"
              roughness={0.28}
              metalness={0.55}
            />
          </mesh>
        );
      })}
    </group>
  );
}

export function SnakesAndLadders3D({ activeTransitionId }: ObstaclesProps) {
  return (
    <group name="snakes-and-ladders-group">
      {BOARD_CONFIG.snakes.map((snake) => (
        <SnakeMesh
          key={snake.id}
          snake={snake}
          isHighlighted={activeTransitionId === snake.id}
        />
      ))}
      {BOARD_CONFIG.ladders.map((ladder) => (
        <LadderMesh
          key={ladder.id}
          ladder={ladder}
          isHighlighted={activeTransitionId === ladder.id}
        />
      ))}
    </group>
  );
}
