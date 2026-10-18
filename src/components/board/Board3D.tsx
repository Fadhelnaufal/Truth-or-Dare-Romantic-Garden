'use client';

import React, { useMemo } from 'react';
import { Text, RoundedBox } from '@react-three/drei';
import { BOARD_CONFIG } from '@/game/board/boardConfig';
import { SquareMetadata } from '@/game/types';

interface Board3DProps {
  highlightedSquare: number | null;
}

function getTileColors(meta: SquareMetadata, isEvenChecker: boolean) {
  switch (meta.type) {
    case 'start':
      return {
        surface: '#F4D7DE',
        border: '#C99A72',
        text: '#654754',
        badge: 'MULAI',
      };
    case 'finish':
      return {
        surface: '#C99A72',
        border: '#FFF7ED',
        text: '#FFFDF8',
        badge: 'MAHKOTA 100',
      };
    case 'truth':
      return {
        surface: '#F6E2E8',
        border: '#C98296',
        text: '#654754',
        badge: '♥ TRUTH',
      };
    case 'dare':
      return {
        surface: '#EFE7F8',
        border: '#C99A72',
        text: '#654754',
        badge: '✦ DARE',
      };
    case 'snake_head':
      return {
        surface: '#E4ECE0',
        border: '#7C9473',
        text: '#47303A',
        badge: 'ULAR',
      };
    case 'ladder_bottom':
      return {
        surface: '#FBF0D9',
        border: '#C99A72',
        text: '#654754',
        badge: 'TANGGA',
      };
    default:
      return {
        surface: isEvenChecker ? '#FFF7ED' : '#F9E8EC',
        border: '#E5CED4',
        text: '#654754',
        badge: null,
      };
  }
}

export function Board3D({ highlightedSquare }: Board3DProps) {
  const squaresList = useMemo(
    () => Object.values(BOARD_CONFIG.squares),
    []
  );

  const totalBoardWidth =
    BOARD_CONFIG.cols * (BOARD_CONFIG.tileSize + BOARD_CONFIG.tileGap) + 0.65;

  return (
    <group name="romantic-board-root">
      <RoundedBox
        args={[totalBoardWidth, 0.34, totalBoardWidth]}
        radius={0.14}
        smoothness={4}
        position={[0, 0.02, 0]}
        receiveShadow
        castShadow
      >
        <meshStandardMaterial
          color="#FFF7ED"
          roughness={0.35}
          metalness={0.08}
        />
      </RoundedBox>

      <RoundedBox
        args={[totalBoardWidth + 0.18, 0.24, totalBoardWidth + 0.18]}
        radius={0.16}
        smoothness={4}
        position={[0, -0.02, 0]}
        receiveShadow
      >
        <meshStandardMaterial
          color="#C99A72"
          roughness={0.28}
          metalness={0.62}
        />
      </RoundedBox>

      {squaresList.map((meta) => {
        const isEvenChecker = (meta.row + meta.col) % 2 === 0;
        const palette = getTileColors(meta, isEvenChecker);
        const isHighlighted = highlightedSquare === meta.square;

        return (
          <group
            key={meta.square}
            position={[
              meta.worldPosition.x,
              meta.worldPosition.y,
              meta.worldPosition.z,
            ]}
          >
            <RoundedBox
              args={[BOARD_CONFIG.tileSize, 0.14, BOARD_CONFIG.tileSize]}
              radius={0.04}
              smoothness={3}
              receiveShadow
              castShadow
            >
              <meshStandardMaterial
                color={isHighlighted ? '#FFE3EC' : palette.surface}
                roughness={0.32}
                metalness={meta.type === 'finish' ? 0.45 : 0.06}
                emissive={isHighlighted ? '#C98296' : '#000000'}
                emissiveIntensity={isHighlighted ? 0.35 : 0}
              />
            </RoundedBox>

            {meta.type !== 'normal' && (
              <mesh position={[0, 0.072, 0]} rotation={[-Math.PI / 2, 0, 0]}>
                <ringGeometry
                  args={[
                    BOARD_CONFIG.tileSize * 0.38,
                    BOARD_CONFIG.tileSize * 0.44,
                    24,
                  ]}
                />
                <meshStandardMaterial
                  color={palette.border}
                  roughness={0.3}
                  metalness={0.5}
                />
              </mesh>
            )}

            <Text
              position={[
                -BOARD_CONFIG.tileSize * 0.28,
                0.082,
                -BOARD_CONFIG.tileSize * 0.26,
              ]}
              rotation={[-Math.PI / 2, 0, 0]}
              fontSize={0.2}
              color={palette.text}
              anchorX="left"
              anchorY="top"
            >
              {String(meta.square)}
            </Text>

            {palette.badge && (
              <Text
                position={[0, 0.082, BOARD_CONFIG.tileSize * 0.18]}
                rotation={[-Math.PI / 2, 0, 0]}
                fontSize={0.115}
                color={palette.text}
                anchorX="center"
                anchorY="middle"
              >
                {palette.badge}
              </Text>
            )}
          </group>
        );
      })}
    </group>
  );
}
