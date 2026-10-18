import { PieceStyleDefinition, PieceStyleId, PlayerSetupInput, PlayerState } from '../types';

export const PIECE_STYLES: PieceStyleDefinition[] = [
  // 5 Karakter Sanrio Spesial dari Models Mandiri (Kuromi, My Melody, Pompompurin, Keroppi, Pochacco)
  {
    id: 'kuromi_toy',
    label: '🎀 Kuromi (3D GLB)',
    primaryColor: '#47303A',
    accentColor: '#C98296',
    silhouette: 'crown_spire',
    glbConfig: {
      url: '/models/kuromi.glb',
      targetHeight: 0.72,
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
      url: '/models/my_melody.glb',
      targetHeight: 0.72,
      rotationY: 0,
    },
  },
  {
    id: 'pom_purin',
    label: '🍮 Pompompurin (3D GLB)',
    primaryColor: '#FFE29A',
    accentColor: '#C99A72',
    silhouette: 'bloom_obelisk',
    glbConfig: {
      url: '/models/pom.glb',
      targetHeight: 0.68,
      rotationY: 0,
    },
  },
  {
    id: 'keroppi',
    label: '🐸 Keroppi (3D GLB)',
    primaryColor: '#A9C9A0',
    accentColor: '#7C9473',
    silhouette: 'heart_column',
    glbConfig: {
      url: '/models/keroppi.glb',
      targetHeight: 0.68,
      rotationY: 0,
    },
  },
  {
    id: 'pochacco',
    label: '🐾 Pochacco (3D GLB)',
    primaryColor: '#FFFDF8',
    accentColor: '#4A3E56',
    silhouette: 'crown_spire',
    glbConfig: {
      url: '/models/pochacco.glb',
      targetHeight: 0.70,
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
