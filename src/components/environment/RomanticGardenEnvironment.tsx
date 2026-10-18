'use client';

import React, { Component, Suspense, useMemo, useRef } from 'react';
import { useFrame } from '@react-three/fiber';
import { useGLTF } from '@react-three/drei';
import * as THREE from 'three';
import { useGameStore } from '@/game/store/useGameStore';

class ModelErrorBoundary extends Component<
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

function RomanticGardenGLBModel() {
  const { scene } = useGLTF('/models/romantic-garden.glb');

  const clonedScene = useMemo(() => {
    const clone = scene.clone(true);
    clone.traverse((child) => {
      if ((child as THREE.Mesh).isMesh) {
        child.castShadow = true;
        child.receiveShadow = true;
      }
    });
    return clone;
  }, [scene]);

  return (
    <primitive
      object={clonedScene}
      position={[0, 0, 0]}
      rotation={[0, 0, 0]}
      scale={1}
    />
  );
}

// Safe component to load a specific node from decoration GLB files
function GLBDecorationNode({
  url,
  nodeName,
  position,
  scale = 1,
  rotation = [0, 0, 0],
}: {
  url: string;
  nodeName: string;
  position: [number, number, number];
  scale?: number;
  rotation?: [number, number, number];
}) {
  const { scene } = useGLTF(url);

  const clonedNode = useMemo(() => {
    const target = scene.getObjectByName(nodeName) ?? scene;
    const clone = target.clone(true);

    clone.traverse((child) => {
      if ((child as THREE.Mesh).isMesh) {
        child.castShadow = true;
        child.receiveShadow = true;
      }
    });
    return clone;
  }, [scene, nodeName]);

  return (
    <group position={position} rotation={rotation} scale={scale}>
      <primitive object={clonedNode} />
    </group>
  );
}

function FloatingPetalsInstanced() {
  const reducedMotion = useGameStore((s) => s.reducedMotion);
  const phase = useGameStore((s) => s.phase);
  const meshRef = useRef<THREE.InstancedMesh | null>(null);
  const count = 90;

  const particles = useMemo(() => {
    return Array.from({ length: count }).map((_, i) => ({
      x: Math.sin(i * 17.3) * 11.5,
      y: (i % 10) * 0.75 + 0.6,
      z: Math.cos(i * 23.1) * 11.5,
      speed: 0.25 + (i % 5) * 0.08,
      phaseOffset: i * 0.7,
    }));
  }, [count]);

  const dummy = useMemo(() => new THREE.Object3D(), []);

  useFrame((state) => {
    if (!meshRef.current) return;
    const t = state.clock.elapsedTime;
    const speedMultiplier = phase === 'victory' ? 2.2 : 1.0;

    particles.forEach((p, idx) => {
      const yOffset = reducedMotion
        ? p.y
        : ((p.y - t * p.speed * speedMultiplier) % 7.5 + 7.5) % 7.5 + 0.3;
      const swayX = reducedMotion
        ? p.x
        : p.x + Math.sin(t * 0.8 + p.phaseOffset) * 0.45;
      const swayZ = reducedMotion
        ? p.z
        : p.z + Math.cos(t * 0.7 + p.phaseOffset) * 0.45;

      dummy.position.set(swayX, yOffset, swayZ);
      dummy.rotation.set(
        t * 0.6 + p.phaseOffset,
        t * 0.4 + p.phaseOffset,
        p.phaseOffset
      );
      dummy.scale.set(0.14, 0.04, 0.2);
      dummy.updateMatrix();
      meshRef.current!.setMatrixAt(idx, dummy.matrix);
    });
    meshRef.current.instanceMatrix.needsUpdate = true;
  });

  return (
    <instancedMesh ref={meshRef} args={[undefined, undefined, count]}>
      <sphereGeometry args={[1, 8, 8]} />
      <meshStandardMaterial
        color="#F4D7DE"
        roughness={0.4}
        emissive="#C98296"
        emissiveIntensity={0.18}
      />
    </instancedMesh>
  );
}

export function RomanticGardenEnvironment() {
  return (
    <group name="dreamy-romantic-garden-environment">
      {/* 1. Main Romantic Garden 3D GLB Scenery */}
      <ModelErrorBoundary fallback={null}>
        <Suspense fallback={null}>
          <RomanticGardenGLBModel />
        </Suspense>
      </ModelErrorBoundary>

      {/* 2. Sanrio Toy Character (Hello Kitty) relaxing on the garden lawn */}
      <ModelErrorBoundary fallback={null}>
        <Suspense fallback={null}>
          <group position={[-5.8, 0.05, -3.2]} rotation={[0, Math.PI / 4, 0]}>
            <GLBDecorationNode
              url="/models/toys_kuromi_melody_and_hello_kitty.glb"
              nodeName="Plane.001_2"
              position={[-2, 0.00, 1]}
              rotation={[0, 0.7, 0]}
              scale={0.42}
            />
          </group>
        </Suspense>
      </ModelErrorBoundary>

      {/* 3. Cat Characters (Panda, Cat, Shark) relaxing by the right garden pathway */}
      <ModelErrorBoundary fallback={null}>
        <Suspense fallback={null}>
          <group position={[6.2, 0.05, 3.5]} rotation={[0, -Math.PI / 3, 0]}>
            <GLBDecorationNode
              url="/models/cats.glb"
              nodeName="panda_0"
              position={[0, 0, 0]}
              scale={0.38}
              rotation={[Math.PI / 2, 0, 0]}
            />
            <GLBDecorationNode
              url="/models/cats.glb"
              nodeName="cat_1"
              position={[0.7, 0, -0.3]}
              scale={0.35}
              rotation={[Math.PI / 2, 0, 0]}
            />
            <GLBDecorationNode
              url="/models/cats.glb"
              nodeName="shark_2"
              position={[-0.6, 0, 0.4]}
              scale={0.35}
              rotation={[Math.PI / 2, 0, 0]}
            />
          </group>
        </Suspense>
      </ModelErrorBoundary>

      {/* 4. Atmospheric Floating Cherry Blossom Petals */}
      <FloatingPetalsInstanced />
    </group>
  );
}

useGLTF.preload('/models/romantic-garden.glb');
useGLTF.preload('/models/toys_kuromi_melody_and_hello_kitty.glb');
useGLTF.preload('/models/cats.glb');