'use client';

import React, { Component, Suspense, useMemo } from 'react';
import { useGLTF } from '@react-three/drei';
import * as THREE from 'three';
import { SkeletonUtils } from 'three-stdlib';
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
    const targetNode = config.nodeName
      ? (scene.getObjectByName(config.nodeName) ?? scene)
      : scene;

    // Bungkus dalam grup baru dan kloning seluruh hierarki mesh & materialnya menggunakan SkeletonUtils
    const wrapper = new THREE.Group();
    const clonedSubtree = SkeletonUtils.clone(targetNode);

    // Pertahankan orientasi namun hapus translasi offset X/Y/Z bawaan supaya bisa di-center otomatis
    clonedSubtree.position.set(0, 0, 0);

    const rootHolder = new THREE.Group();
    if (config.url.includes('cats.glb')) {
      rootHolder.rotation.set(Math.PI / 2, 0, 0);
    } else if (
      config.url.includes('toys_kuromi_melody_and_hello_kitty.glb') &&
      config.nodeName === 'Plane_0'
    ) {
      rootHolder.rotation.set(0, Math.PI / 2, 0);
    }

    if (config.rotationX) rootHolder.rotation.x += config.rotationX;
    if (config.rotationZ) rootHolder.rotation.z += config.rotationZ;

    // Khusus Keroppi: hapus kotak air dan bendera diorama agar katak tampil ramping dan pas di kotak bidak
    if (config.url.includes('keroppi.glb')) {
      const toRemove: THREE.Object3D[] = [];
      clonedSubtree.traverse((child) => {
        if (
          child.name === 'Cube_Water_0' ||
          child.name.startsWith('Flag') ||
          child.name === 'Cube'
        ) {
          toRemove.push(child);
        }
      });
      toRemove.forEach((child) => child.parent?.remove(child));
    }

    rootHolder.add(clonedSubtree);
    wrapper.add(rootHolder);

    // Aktifkan bayangan pada setiap sub-mesh yang ada
    wrapper.traverse((child) => {
      if ((child as THREE.Mesh).isMesh) {
        child.castShadow = true;
        child.receiveShadow = true;
      }
    });

    // Hitung bounding box aktual untuk normalisasi skala dan penapakan alas
    wrapper.updateMatrixWorld(true);
    const box = new THREE.Box3().setFromObject(wrapper);
    const size = new THREE.Vector3();
    const center = new THREE.Vector3();
    box.getSize(size);
    box.getCenter(center);

    const maxDimension = Math.max(size.x, size.y, size.z, 0.001);
    const scaleFactor = config.targetHeight / maxDimension;

    wrapper.scale.setScalar(scaleFactor);

    // Posisikan wrapper secara analitis: poros X=0, Z=0 tepat di tengah, dan alas kaki di Y=0.06
    wrapper.position.set(
      -center.x * scaleFactor,
      -box.min.y * scaleFactor + 0.06,
      -center.z * scaleFactor
    );

    // Bungkus wrapper di dalam pivotGroup agar rotasi Y memutar karakter tepat pada poros tengahnya
    const pivotGroup = new THREE.Group();
    pivotGroup.add(wrapper);

    if (config.rotationY) {
      pivotGroup.rotation.y = config.rotationY;
    }

    return pivotGroup;
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
