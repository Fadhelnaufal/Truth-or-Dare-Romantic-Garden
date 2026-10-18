'use client';

import React, { useEffect, useRef } from 'react';
import { useFrame, useThree } from '@react-three/fiber';
import { OrbitControls } from '@react-three/drei';
import * as THREE from 'three';
import type { OrbitControls as OrbitControlsImpl } from 'three-stdlib';
import { useGameStore } from '@/game/store/useGameStore';

const GAMEPLAY_CAMERA_POS = new THREE.Vector3(0, 12.6, 11.4);
const GAMEPLAY_TARGET = new THREE.Vector3(0.4, 0.2, 0.2);

export function GardenCameraController() {
  const { camera } = useThree();
  const cameraMode = useGameStore((s) => s.cameraMode);
  const reducedMotion = useGameStore((s) => s.reducedMotion);
  const cameraResetTrigger = useGameStore((s) => s.cameraResetTrigger);
  const finishCameraIntro = useGameStore((s) => s.finishCameraIntro);

  const controlsRef = useRef<OrbitControlsImpl | null>(null);
  const introElapsedRef = useRef(0);
  const introDuration = 4.5;

  useEffect(() => {
    if (reducedMotion && cameraMode === 'intro') {
      finishCameraIntro();
    }
  }, [reducedMotion, cameraMode, finishCameraIntro]);

  useEffect(() => {
    if (cameraResetTrigger > 0) {
      camera.position.copy(GAMEPLAY_CAMERA_POS);
      if (controlsRef.current) {
        controlsRef.current.target.copy(GAMEPLAY_TARGET);
        controlsRef.current.update();
      }
    }
  }, [cameraResetTrigger, camera]);

  useFrame((_, delta) => {
    if (cameraMode === 'intro' && !reducedMotion) {
      introElapsedRef.current += delta;
      const t = Math.min(1, introElapsedRef.current / introDuration);
      const smooth = t * t * (3 - 2 * t);

      const startPos = new THREE.Vector3(-11.5, 16.5, 18.5);
      camera.position.lerpVectors(startPos, GAMEPLAY_CAMERA_POS, smooth);
      camera.lookAt(GAMEPLAY_TARGET);

      if (t >= 1) {
        finishCameraIntro();
        if (controlsRef.current) {
          controlsRef.current.target.copy(GAMEPLAY_TARGET);
          controlsRef.current.update();
        }
      }
    }
  });

  return (
    <OrbitControls
      ref={controlsRef}
      enabled={cameraMode === 'gameplay'}
      target={[GAMEPLAY_TARGET.x, GAMEPLAY_TARGET.y, GAMEPLAY_TARGET.z]}
      enablePan={false}
      minDistance={9.5}
      maxDistance={21}
      minPolarAngle={Math.PI / 6}
      maxPolarAngle={Math.PI / 2.35}
      minAzimuthAngle={-Math.PI / 3.5}
      maxAzimuthAngle={Math.PI / 3.5}
      dampingFactor={0.08}
      enableDamping
    />
  );
}
