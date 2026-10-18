#!/usr/bin/env bash
set -euo pipefail

echo "💌 Memasang fitur Editor Kartu Kustom Pasangan (localStorage)..."

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
  | 'ivory_rose_gold'
  | 'blush_quartz'
  | 'sage_celadon'
  | 'lavender_pearl';

export interface PieceStyleDefinition {
  id: PieceStyleId;
  label: string;
  primaryColor: string;
  accentColor: string;
  silhouette: 'crown_spire' | 'rose_chalice' | 'bloom_obelisk' | 'heart_column';
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

cat << 'EOF' > src/game/challenges/challengeBank.ts
import {
  ChallengeCard,
  ChallengeType,
  DareCategory,
  RandomSource,
  TruthCategory,
} from '../types';

export const CUSTOM_CARDS_STORAGE_KEY = 'romantic_garden_custom_cards_v1';

export const TRUTH_CATEGORIES: TruthCategory[] = [
  'Awal Jatuh Cinta',
  'Perasaan yang Jarang Diucapkan',
  'Bikin Salting dan Baper',
  'Kejujuran dan Kedekatan',
  'Masa Depan Bersama',
];

export const DARE_CATEGORIES: DareCategory[] = [
  'Manis dan Romantis',
  'Bikin Hati Meleleh',
  'Kenangan Berdua',
  'Kedekatan yang Lebih Dalam',
  'Momen untuk Diingat',
];

export const TRUTH_CARDS: ChallengeCard[] = [
  {
    id: 'truth-01',
    type: 'truth',
    category: 'Awal Jatuh Cinta',
    prompt: 'Apa kesan pertamamu saat pertama kali kita bertemu, dan apa yang berubah setelah kita semakin dekat?',
  },
  {
    id: 'truth-02',
    type: 'truth',
    category: 'Awal Jatuh Cinta',
    prompt: 'Kapan momen spesifik kamu sadar kalau perasaanmu ke aku lebih dari sekadar teman biasa?',
  },
  {
    id: 'truth-03',
    type: 'truth',
    category: 'Awal Jatuh Cinta',
    prompt: 'Hal kecil apa dariku di awal pendekatan yang diam-diam bikin kamu senyum-senyum sendiri?',
  },
  {
    id: 'truth-04',
    type: 'truth',
    category: 'Awal Jatuh Cinta',
    prompt: 'Lagu apa yang paling mengingatkanmu pada masa-masa awal kita dekat dulu?',
  },
  {
    id: 'truth-05',
    type: 'truth',
    category: 'Awal Jatuh Cinta',
    prompt: 'Pernahkah kamu gugup sebelum bertemu denganku di awal hubungan kita? Ceritakan momennya!',
  },
  {
    id: 'truth-06',
    type: 'truth',
    category: 'Awal Jatuh Cinta',
    prompt: 'Pesan singkat atau obrolan apa dariku di masa awal yang paling berkesan di ingatanmu?',
  },
  {
    id: 'truth-07',
    type: 'truth',
    category: 'Awal Jatuh Cinta',
    prompt: 'Sifatku yang mana yang pertama kali membuatmu merasa nyaman dan aman berada di dekatku?',
  },
  {
    id: 'truth-08',
    type: 'truth',
    category: 'Awal Jatuh Cinta',
    prompt: 'Apa kencan pertama atau pertemuan awal kita yang paling ingin kamu ulangi sekali lagi?',
  },
  {
    id: 'truth-09',
    type: 'truth',
    category: 'Awal Jatuh Cinta',
    prompt: 'Hal konyol apa yang pernah kamu lakukan demi menarik perhatianku waktu pertama kali suka?',
  },
  {
    id: 'truth-10',
    type: 'truth',
    category: 'Awal Jatuh Cinta',
    prompt: 'Kalau kisah awal pertemuan kita dijadikan judul film romantis, kira-kira apa judul yang paling pas?',
  },
  {
    id: 'truth-11',
    type: 'truth',
    category: 'Perasaan yang Jarang Diucapkan',
    prompt: 'Hal apa yang sudah lama ingin kamu ucapkan sebagai rasa terima kasih kepadaku, tapi belum sempat terucap?',
  },
  {
    id: 'truth-12',
    type: 'truth',
    category: 'Perasaan yang Jarang Diucapkan',
    prompt: 'Kapan kamu merasa paling dicintai dan dihargai olehku tanpa aku harus mengucapkan sepatah kata pun?',
  },
  {
    id: 'truth-13',
    type: 'truth',
    category: 'Perasaan yang Jarang Diucapkan',
    prompt: 'Apa ketakutan terbesarmu dalam hubungan yang jarang kamu ceritakan karena tidak ingin membuatku khawatir?',
  },
  {
    id: 'truth-14',
    type: 'truth',
    category: 'Perasaan yang Jarang Diucapkan',
    prompt: 'Saat kamu sedang lelah dengan harimu, bentuk perhatian seperti apa dariku yang paling menenangkan hatimu?',
  },
  {
    id: 'truth-15',
    type: 'truth',
    category: 'Perasaan yang Jarang Diucapkan',
    prompt: 'Perubahan positif apa dalam dirimu yang kamu rasakan sejak kita menjalani hubungan bersama?',
  },
  {
    id: 'truth-16',
    type: 'truth',
    category: 'Perasaan yang Jarang Diucapkan',
    prompt: 'Momen sederhana apa bersama aku yang diam-diam selalu kamu rindukan saat kita sedang berjauhan?',
  },
  {
    id: 'truth-17',
    type: 'truth',
    category: 'Perasaan yang Jarang Diucapkan',
    prompt: 'Apa satu hal tentang caraku mencintaimu yang membuatmu merasa hubungan ini berbeda dan istimewa?',
  },
  {
    id: 'truth-18',
    type: 'truth',
    category: 'Perasaan yang Jarang Diucapkan',
    prompt: 'Kapan terakhir kali kamu merasa sangat bangga memilikiku sebagai pasanganmu?',
  },
  {
    id: 'truth-19',
    type: 'truth',
    category: 'Perasaan yang Jarang Diucapkan',
    prompt: 'Jika hari ini kita hanya punya waktu lima menit untuk mengobrol dari hati ke hati, apa yang ingin kamu sampaikan?',
  },
  {
    id: 'truth-20',
    type: 'truth',
    category: 'Perasaan yang Jarang Diucapkan',
    prompt: 'Bagian mana dari kepribadianku yang paling sering menjadi alasanmu bertahan dan tersenyum di saat sulit?',
  },
  {
    id: 'truth-21',
    type: 'truth',
    category: 'Bikin Salting dan Baper',
    prompt: 'Ekspresi wajah atau gerak-gerikku yang mana yang paling sering bikin kamu salah tingkah sampai sekarang?',
  },
  {
    id: 'truth-22',
    type: 'truth',
    category: 'Bikin Salting dan Baper',
    prompt: 'Pujian apa dariku yang pernah bikin kamu kepikiran dan senyum-senyum seharian penuh?',
  },
  {
    id: 'truth-23',
    type: 'truth',
    category: 'Bikin Salting dan Baper',
    prompt: 'Dari semua pakaian atau gaya penampilanku, mana yang menurutmu paling memikat saat aku kenakan?',
  },
  {
    id: 'truth-24',
    type: 'truth',
    category: 'Bikin Salting dan Baper',
    prompt: 'Apa hal paling menggemaskan yang sering aku lakukan tanpa aku sadari?',
  },
  {
    id: 'truth-25',
    type: 'truth',
    category: 'Bikin Salting dan Baper',
    prompt: 'Kapan terakhir kali jantungmu berdebar kencang hanya karena tatapan atau sentuhan lembut dariku?',
  },
  {
    id: 'truth-26',
    type: 'truth',
    category: 'Bikin Salting dan Baper',
    prompt: 'Sebutkan tiga hal fisik maupun non-fisik dariku yang paling membuatmu jatuh hati berulang kali!',
  },
  {
    id: 'truth-27',
    type: 'truth',
    category: 'Bikin Salting dan Baper',
    prompt: 'Panggilan sayang apa yang diam-diam paling kamu sukai saat aku ucapkan dengan suara lembut?',
  },
  {
    id: 'truth-28',
    type: 'truth',
    category: 'Bikin Salting dan Baper',
    prompt: 'Pernahkah kamu diam-diam memperhatikanku saat aku sedang fokus melakukan sesuatu? Apa yang kamu pikirkan saat itu?',
  },
  {
    id: 'truth-29',
    type: 'truth',
    category: 'Bikin Salting dan Baper',
    prompt: 'Hal romantis kecil apa yang pernah aku lakukan yang sukses bikin hatimu meleleh seketika?',
  },
  {
    id: 'truth-30',
    type: 'truth',
    category: 'Bikin Salting dan Baper',
    prompt: 'Kalau kamu harus mendeskripsikan senyumku dalam satu kalimat puitis, kalimat apa yang akan kamu pilih?',
  },
  {
    id: 'truth-31',
    type: 'truth',
    category: 'Kejujuran dan Kedekatan',
    prompt: 'Bagaimana cara terbaik bagiku untuk menenangkanmu ketika kamu sedang kesal atau butuh ruang sendiri?',
  },
  {
    id: 'truth-32',
    type: 'truth',
    category: 'Kejujuran dan Kedekatan',
    prompt: 'Kebiasaan baik apa dalam komunikasi kita yang menurutmu harus terus kita jaga selamanya?',
  },
  {
    id: 'truth-33',
    type: 'truth',
    category: 'Kejujuran dan Kedekatan',
    prompt: 'Apa bahasa cinta (love language) yang paling kamu rasakan kebutuhannya akhir-akhir ini dariku?',
  },
  {
    id: 'truth-34',
    type: 'truth',
    category: 'Kejujuran dan Kedekatan',
    prompt: 'Adakah kesalahpahaman kecil di masa lalu yang membuat kita justru semakin mengerti satu sama lain?',
  },
  {
    id: 'truth-35',
    type: 'truth',
    category: 'Kejujuran dan Kedekatan',
    prompt: 'Apa hal yang membuatmu merasa paling didengarkan saat kita sedang berdiskusi tentang hal serius?',
  },
  {
    id: 'truth-36',
    type: 'truth',
    category: 'Kejujuran dan Kedekatan',
    prompt: 'Dalam hal apa menurutmu kita berdua adalah tim yang paling saling melengkapi?',
  },
  {
    id: 'truth-37',
    type: 'truth',
    category: 'Kejujuran dan Kedekatan',
    prompt: 'Apa satu hal sederhana yang bisa kita lakukan setiap minggu agar hubungan kita selalu terasa hangat?',
  },
  {
    id: 'truth-38',
    type: 'truth',
    category: 'Kejujuran dan Kedekatan',
    prompt: 'Pelajaran berharga apa tentang cinta yang kamu temukan selama kita berjalan beriringan?',
  },
  {
    id: 'truth-39',
    type: 'truth',
    category: 'Kejujuran dan Kedekatan',
    prompt: 'Saat kita berbeda pendapat, sikapku yang mana yang paling membantumu merasa tetap dihormati dan disayangi?',
  },
  {
    id: 'truth-40',
    type: 'truth',
    category: 'Kejujuran dan Kedekatan',
    prompt: 'Apa arti rumah dan rasa pulang bagi dirimu ketika kita sedang menghabiskan waktu berdua?',
  },
  {
    id: 'truth-41',
    type: 'truth',
    category: 'Masa Depan Bersama',
    prompt: 'Destinasi impian mana yang paling ingin kamu kunjungi bersamaku suatu hari nanti, dan apa yang ingin kita lakukan di sana?',
  },
  {
    id: 'truth-42',
    type: 'truth',
    category: 'Masa Depan Bersama',
    prompt: 'Seperti apa suasana pagi hari impianmu jika suatu saat kita bangun di bawah atap yang sama setiap hari?',
  },
  {
    id: 'truth-43',
    type: 'truth',
    category: 'Masa Depan Bersama',
    prompt: 'Tradisi tahunan apa yang ingin kamu ciptakan dan rayakan bersamaku hingga kita menua nanti?',
  },
  {
    id: 'truth-44',
    type: 'truth',
    category: 'Masa Depan Bersama',
    prompt: 'Hobi atau proyek seru apa yang belum pernah kita coba, tapi sangat ingin kamu mulai bersamaku tahun ini?',
  },
  {
    id: 'truth-45',
    type: 'truth',
    category: 'Masa Depan Bersama',
    prompt: 'Saat membayangkan kita sepuluh tahun lagi, hal indah apa yang paling membuatmu bersemangat?',
  },
  {
    id: 'truth-46',
    type: 'truth',
    category: 'Masa Depan Bersama',
    prompt: 'Bagaimana gambaran kencan malam minggu yang paling sempurna versi kita saat kita sudah tua nanti?',
  },
  {
    id: 'truth-47',
    type: 'truth',
    category: 'Masa Depan Bersama',
    prompt: 'Impian pribadimu yang mana yang paling ingin aku dukung dan saksikan langsung pencapaiannya?',
  },
  {
    id: 'truth-48',
    type: 'truth',
    category: 'Masa Depan Bersama',
    prompt: 'Jika kita bisa mendesain taman atau sudut santai impian di rumah masa depan kita, seperti apa bentuknya?',
  },
  {
    id: 'truth-49',
    type: 'truth',
    category: 'Masa Depan Bersama',
    prompt: 'Petualangan baru apa yang ingin kita wujudkan bersama dalam waktu satu tahun ke depan?',
  },
  {
    id: 'truth-50',
    type: 'truth',
    category: 'Masa Depan Bersama',
    prompt: 'Satu janji hangat apa yang ingin kamu pegang bersama denganku untuk perjalanan kita ke depan?',
  },
];

export const DARE_CARDS: ChallengeCard[] = [
  {
    id: 'dare-01',
    type: 'dare',
    category: 'Manis dan Romantis',
    prompt: 'Genggam kedua tangan pasanganmu sekarang, tatap matanya selama 15 detik, lalu ucapkan satu hal yang paling kamu syukuri darinya hari ini.',
  },
  {
    id: 'dare-02',
    type: 'dare',
    category: 'Manis dan Romantis',
    prompt: 'Berikan tiga pujian tulus secara berurutan tentang senyum, kebaikan hati, dan cara pasanganmu memperlakukanmu.',
  },
  {
    id: 'dare-03',
    type: 'dare',
    category: 'Manis dan Romantis',
    prompt: 'Elus lembut rambut atau pundak pasanganmu sambil mengucapkan kalimat penyemangat paling hangat untuk minggunya.',
  },
  {
    id: 'dare-04',
    type: 'dare',
    category: 'Manis dan Romantis',
    prompt: 'Bisikkan di dekat telinga pasanganmu alasan mengapa kamu senang menghabiskan waktu bersamanya saat ini.',
  },
  {
    id: 'dare-05',
    type: 'dare',
    category: 'Manis dan Romantis',
    prompt: 'Peluk pasanganmu dengan hangat selama 20 detik tanpa bicara, biarkan suasana tenang berbicara untuk kalian.',
  },
  {
    id: 'dare-06',
    type: 'dare',
    category: 'Manis dan Romantis',
    prompt: 'Ciptakan satu panggilan sayang baru yang manis dan gunakan panggilan itu sampai giliranmu berikutnya!',
  },
  {
    id: 'dare-07',
    type: 'dare',
    category: 'Manis dan Romantis',
    prompt: 'Gambar bentuk hati kecil di telapak tangan pasanganmu menggunakan ujung jarimu sambil tersenyum padanya.',
  },
  {
    id: 'dare-08',
    type: 'dare',
    category: 'Manis dan Romantis',
    prompt: 'Nyanyikan sepenggal lirik lagu cinta favoritmu sambil menatap mata pasanganmu dengan penuh penghayatan.',
  },
  {
    id: 'dare-09',
    type: 'dare',
    category: 'Manis dan Romantis',
    prompt: 'Kecup punggung tangan pasanganmu dengan lembut ala bangsawan di taman kerajaan, lalu tersenyumlah.',
  },
  {
    id: 'dare-10',
    type: 'dare',
    category: 'Manis dan Romantis',
    prompt: 'Ucapkan "Terima kasih sudah hadir di hidupku" dengan nada paling tulus sambil menggenggam jari kelingkingnya.',
  },
  {
    id: 'dare-11',
    type: 'dare',
    category: 'Bikin Hati Meleleh',
    prompt: 'Rangkai sebuah puisi pendek spontan 4 baris tentang keindahan pasanganmu malam ini.',
  },
  {
    id: 'dare-12',
    type: 'dare',
    category: 'Bikin Hati Meleleh',
    prompt: 'Peragakan ulang ekspresi wajahmu saat pertama kali kamu naksir berat pada pasanganmu!',
  },
  {
    id: 'dare-13',
    type: 'dare',
    category: 'Bikin Hati Meleleh',
    prompt: 'Sandarkan kepalamu di bahu pasanganmu selama satu putaran penuh dan ceritakan satu hal yang membuatmu nyaman di sisinya.',
  },
  {
    id: 'dare-14',
    type: 'dare',
    category: 'Bikin Hati Meleleh',
    prompt: 'Berikan tatapan paling manis tanpa berkedip selama 10 detik, siapa yang tertawa duluan harus memberi pelukan tambahan!',
  },
  {
    id: 'dare-15',
    type: 'dare',
    category: 'Bikin Hati Meleleh',
    prompt: 'Ceritakan dalam 30 detik mengapa pasanganmu adalah orang paling menarik di matamu.',
  },
  {
    id: 'dare-16',
    type: 'dare',
    category: 'Bikin Hati Meleleh',
    prompt: 'Pijat lembut telapak tangan atau jemari pasanganmu selama 30 detik sambil menanyakan kabarnya hari ini.',
  },
  {
    id: 'dare-17',
    type: 'dare',
    category: 'Bikin Hati Meleleh',
    prompt: 'Ucapkan satu kalimat gombalan paling manis dan klasik yang bisa membuat pasanganmu tersipu malu sekarang juga.',
  },
  {
    id: 'dare-18',
    type: 'dare',
    category: 'Bikin Hati Meleleh',
    prompt: 'Rapikan anak rambut atau kerah baju pasanganmu dengan perlahan sambil menatapnya penuh kasih sayang.',
  },
  {
    id: 'dare-19',
    type: 'dare',
    category: 'Bikin Hati Meleleh',
    prompt: 'Sebutkan lima hal kecil dari pasanganmu yang selalu berhasil memperbaiki suasana hatimu seketika.',
  },
  {
    id: 'dare-20',
    type: 'dare',
    category: 'Bikin Hati Meleleh',
    prompt: 'Berikan high-five yang berubah menjadi genggaman tangan erat selama 15 detik sambil tersenyum lebar.',
  },
  {
    id: 'dare-21',
    type: 'dare',
    category: 'Kenangan Berdua',
    prompt: 'Ceritakan kembali momen paling lucu yang pernah kalian alami berdua dengan gaya bercerita yang ekspresif!',
  },
  {
    id: 'dare-22',
    type: 'dare',
    category: 'Kenangan Berdua',
    prompt: 'Tirukan satu kebiasaan khas atau gaya bicara pasanganmu yang paling menggemaskan (dengan penuh kasih sayang!).',
  },
  {
    id: 'dare-23',
    type: 'dare',
    category: 'Kenangan Berdua',
    prompt: 'Sebutkan tiga tempat yang pernah kalian kunjungi bersama dan apa kenangan terbaik di masing-masing tempat tersebut.',
  },
  {
    id: 'dare-24',
    type: 'dare',
    category: 'Kenangan Berdua',
    prompt: 'Deskripsikan foto berdua favoritmu secara detail dan ceritakan perasaanmu saat foto itu diambil.',
  },
  {
    id: 'dare-25',
    type: 'dare',
    category: 'Kenangan Berdua',
    prompt: 'Peragakan kembali cara kalian menyapa satu sama lain saat pertama kali pergi kencan dulu.',
  },
  {
    id: 'dare-26',
    type: 'dare',
    category: 'Kenangan Berdua',
    prompt: 'Ceritakan momen ketika pasanganmu melakukan sesuatu yang tak terduga dan membuatmu makin jatuh cinta.',
  },
  {
    id: 'dare-27',
    type: 'dare',
    category: 'Kenangan Berdua',
    prompt: 'Sebutkan makanan atau minuman yang paling mengingatkanmu pada momen kebersamaan kalian, lalu rencanakan kapan memakannya lagi.',
  },
  {
    id: 'dare-28',
    type: 'dare',
    category: 'Kenangan Berdua',
    prompt: 'Buat ulasan bintang lima yang seru dan romantis tentang pengalaman menjadi pasangan dari kekasihmu selama ini!',
  },
  {
    id: 'dare-29',
    type: 'dare',
    category: 'Kenangan Berdua',
    prompt: 'Bagikan satu pelajaran paling manis yang kamu ingat dari perjalanan atau liburan yang pernah kalian lakukan bersama.',
  },
  {
    id: 'dare-30',
    type: 'dare',
    category: 'Kenangan Berdua',
    prompt: 'Ucapkan kembali kalimat pertama yang kamu ingat pernah membuat kalian berdua tertawa lepas bersama.',
  },
  {
    id: 'dare-31',
    type: 'dare',
    category: 'Kedekatan yang Lebih Dalam',
    prompt: 'Tarik napas dalam-dalam bersama pasanganmu sebanyak tiga kali sambil berpegangan tangan dan saling menatap tenang.',
  },
  {
    id: 'dare-32',
    type: 'dare',
    category: 'Kedekatan yang Lebih Dalam',
    prompt: 'Sampaikan satu harapan baik dan doa tulus untuk kebahagiaan pasanganmu secara langsung di hadapannya.',
  },
  {
    id: 'dare-33',
    type: 'dare',
    category: 'Kedekatan yang Lebih Dalam',
    prompt: 'Tanyakan pada pasanganmu: "Hal kecil apa yang bisa aku lakukan minggu ini agar harimu terasa lebih ringan?" dan dengarkan jawabannya.',
  },
  {
    id: 'dare-34',
    type: 'dare',
    category: 'Kedekatan yang Lebih Dalam',
    prompt: 'Ucapkan tiga kualitas karakter pasanganmu yang paling kamu kagumi dan jadikan inspirasi dalam hidupmu.',
  },
  {
    id: 'dare-35',
    type: 'dare',
    category: 'Kedekatan yang Lebih Dalam',
    prompt: 'Tempelkan dahimu dengan lembut ke dahi pasanganmu (jika nyaman) atau genggam erat tangannya selama 10 detik dalam keheningan yang hangat.',
  },
  {
    id: 'dare-36',
    type: 'dare',
    category: 'Kedekatan yang Lebih Dalam',
    prompt: 'Ceritakan satu momen ketika dukungan dari pasanganmu berhasil membuatmu bangkit kembali.',
  },
  {
    id: 'dare-37',
    type: 'dare',
    category: 'Kedekatan yang Lebih Dalam',
    prompt: 'Berikan apresiasi tulus atas usaha yang dilakukan pasanganmu akhir-akhir ini dalam kesehariannya.',
  },
  {
    id: 'dare-38',
    type: 'dare',
    category: 'Kedekatan yang Lebih Dalam',
    prompt: 'Ungkapkan satu komitmen sederhana yang ingin kamu jaga agar hubungan kalian makin dewasa dan saling menguatkan.',
  },
  {
    id: 'dare-39',
    type: 'dare',
    category: 'Kedekatan yang Lebih Dalam',
    prompt: 'Biarkan pasanganmu memilih satu pertanyaan tambahan apa saja tentang perasaanmu, dan jawablah dengan sepenuh hati.',
  },
  {
    id: 'dare-40',
    type: 'dare',
    category: 'Kedekatan yang Lebih Dalam',
    prompt: 'Saling bertukar satu kalimat afirmasi positif yang dimulai dengan kata: "Bersamamu, aku merasa..."',
  },
  {
    id: 'dare-41',
    type: 'dare',
    category: 'Momen untuk Diingat',
    prompt: 'Rencanakan satu ide kencan sederhana untuk akhir pekan ini dalam waktu 60 detik bersama pasanganmu!',
  },
  {
    id: 'dare-42',
    type: 'dare',
    category: 'Momen untuk Diingat',
    prompt: 'Ambil pose paling manis berdua sekarang (atau bayangkan bingkai foto imajiner) dan beri judul untuk momen malam ini.',
  },
  {
    id: 'dare-43',
    type: 'dare',
    category: 'Momen untuk Diingat',
    prompt: 'Berdansa pelan di tempat bersama pasanganmu (atau ayunkan tangan berdua) selama 15 detik dengan irama imajiner.',
  },
  {
    id: 'dare-44',
    type: 'dare',
    category: 'Momen untuk Diingat',
    prompt: 'Buat salam rahasia (secret handshake) khusus pasangan yang romantis dan seru hanya untuk kalian berdua!',
  },
  {
    id: 'dare-45',
    type: 'dare',
    category: 'Momen untuk Diingat',
    prompt: 'Tulis pesan singkat satu kalimat di catatan ponsel atau secarik kertas untuk dibaca pasanganmu besok pagi.',
  },
  {
    id: 'dare-46',
    type: 'dare',
    category: 'Momen untuk Diingat',
    prompt: 'Berikan "Kupon Kasih Sayang" lisan kepada pasanganmu (misalnya: 1x pijat bahu atau 1x traktir es krim favoritnya).',
  },
  {
    id: 'dare-47',
    type: 'dare',
    category: 'Momen untuk Diingat',
    prompt: 'Sebutkan tiga hal seru dalam "Bucket List Berdua" yang ingin kalian centang bersama tahun ini.',
  },
  {
    id: 'dare-48',
    type: 'dare',
    category: 'Momen untuk Diingat',
    prompt: 'Ucapkan satu kalimat pembuka surat cinta seolah-olah kamu sedang menulis surat untuk dibaca 20 tahun mendatang.',
  },
  {
    id: 'dare-49',
    type: 'dare',
    category: 'Momen untuk Diingat',
    prompt: 'Pilih satu lagu yang akan menjadi "Lagu Tema" kalian minggu ini dan senandungkan nadanya bersama.',
  },
  {
    id: 'dare-50',
    type: 'dare',
    category: 'Momen untuk Diingat',
    prompt: 'Akhiri tantangan ini dengan pelukan hangat dan ucapkan: "Aku senang bermain dan berbagi cerita denganmu hari ini."',
  },
];

export const ALL_CHALLENGE_CARDS: ChallengeCard[] = [...TRUTH_CARDS, ...DARE_CARDS];

export function loadCustomCardsFromStorage(): ChallengeCard[] {
  if (typeof window === 'undefined') return [];
  try {
    const raw = window.localStorage.getItem(CUSTOM_CARDS_STORAGE_KEY);
    if (!raw) return [];
    const parsed = JSON.parse(raw);
    if (!Array.isArray(parsed)) return [];

    return parsed
      .filter(
        (item): item is ChallengeCard =>
          item &&
          typeof item.id === 'string' &&
          (item.type === 'truth' || item.type === 'dare') &&
          typeof item.category === 'string' &&
          typeof item.prompt === 'string' &&
          item.prompt.trim().length > 0
      )
      .map((item) => ({ ...item, isCustom: true }));
  } catch {
    return [];
  }
}

export function saveCustomCardsToStorage(cards: ChallengeCard[]): void {
  if (typeof window === 'undefined') return;
  try {
    window.localStorage.setItem(CUSTOM_CARDS_STORAGE_KEY, JSON.stringify(cards));
  } catch {
    // Ignore storage errors
  }
}

export function selectNextChallengeCard(
  type: ChallengeType,
  usedIds: string[],
  random: RandomSource = Math.random,
  customCards: ChallengeCard[] = []
): { card: ChallengeCard; updatedUsedIds: string[] } {
  const basePool = type === 'truth' ? TRUTH_CARDS : DARE_CARDS;
  const matchingCustom = customCards.filter((c) => c.type === type);
  const pool = [...matchingCustom, ...basePool];

  const usedSet = new Set(usedIds);
  let available = pool.filter((card) => !usedSet.has(card.id));
  let nextUsedBase = [...usedIds];

  if (available.length === 0) {
    const lastId = usedIds[usedIds.length - 1];
    available =
      pool.length > 1 ? pool.filter((card) => card.id !== lastId) : pool;
    nextUsedBase = [];
  }

  const raw = Math.max(0, Math.min(0.999999, random()));
  const chosenIndex = Math.floor(raw * available.length);
  const card = available[chosenIndex];

  return {
    card,
    updatedUsedIds: [...nextUsedBase, card.id],
  };
}
EOF

cat << 'EOF' > src/game/engine/gameEngine.ts
import { BOARD_CONFIG } from '../board/boardConfig';
import { selectNextChallengeCard } from '../challenges/challengeBank';
import { rollDiceValue } from '../dice/diceLogic';
import { createInitialPlayers, DEFAULT_PLAYERS_SETUP } from '../players/playerStyles';
import {
  ActiveTransition,
  BoardConfiguration,
  ChallengeCard,
  GameEngineState,
  MoveRecord,
  PlayerSetupInput,
  RandomSource,
} from '../types';

export interface CreateGameOptions {
  players?: PlayerSetupInput[];
  startInReadyPhase?: boolean;
  customCards?: ChallengeCard[];
}

export function createInitialGameState(options: CreateGameOptions = {}): GameEngineState {
  const players = createInitialPlayers(options.players ?? DEFAULT_PLAYERS_SETUP);
  const startReady = options.startInReadyPhase ?? true;

  return {
    phase: startReady ? 'ready' : 'setup',
    animationPhase: 'idle',
    players,
    activePlayerIndex: 0,
    turnNumber: 1,
    lastDiceValue: null,
    pendingPath: [],
    overshotLastRoll: false,
    activeChallenge: null,
    activeTransition: null,
    winnerId: null,
    moveHistory: [],
    statusMessage: `Giliran ${players[0].name} untuk melempar dadu di Taman Romantis.`,
    usedTruthIds: [],
    usedDareIds: [],
    customCards: options.customCards ? [...options.customCards] : [],
  };
}

export function startMatch(
  state: GameEngineState,
  playersInput: PlayerSetupInput[]
): GameEngineState {
  return createInitialGameState({
    players: playersInput,
    startInReadyPhase: true,
    customCards: state.customCards,
  });
}

export function rollTurnDice(
  state: GameEngineState,
  options: {
    forcedDiceValue?: number;
    random?: RandomSource;
    board?: BoardConfiguration;
  } = {}
): GameEngineState {
  if (state.phase !== 'ready') {
    return state;
  }

  const board = options.board ?? BOARD_CONFIG;
  const diceValue =
    options.forcedDiceValue !== undefined
      ? options.forcedDiceValue
      : rollDiceValue(options.random);

  if (!Number.isInteger(diceValue) || diceValue < 1 || diceValue > 6) {
    throw new Error(`Invalid dice value: ${diceValue}. Expected integer 1..6.`);
  }

  const activePlayer = state.players[state.activePlayerIndex];
  const currentSquare = activePlayer.square;
  const targetSquare = currentSquare + diceValue;

  if (targetSquare > board.finishSquare) {
    return {
      ...state,
      phase: 'rolling',
      animationPhase: 'rolling',
      lastDiceValue: diceValue,
      pendingPath: [],
      overshotLastRoll: true,
      statusMessage: `${activePlayer.name} melempar angka ${diceValue}. Melebihi kotak 100, tetap di kotak ${currentSquare}.`,
    };
  }

  const pendingPath: number[] = [];
  for (let sq = currentSquare + 1; sq <= targetSquare; sq++) {
    pendingPath.push(sq);
  }

  return {
    ...state,
    phase: 'rolling',
    animationPhase: 'rolling',
    lastDiceValue: diceValue,
    pendingPath,
    overshotLastRoll: false,
    statusMessage: `${activePlayer.name} melempar dadu dan mendapat angka ${diceValue}!`,
  };
}

export function completeDiceRollAnimation(
  state: GameEngineState
): GameEngineState {
  if (state.phase !== 'rolling') {
    return state;
  }

  if (state.overshotLastRoll || state.pendingPath.length === 0) {
    const activePlayer = state.players[state.activePlayerIndex];
    const moveRecord: MoveRecord = {
      id: `move-${state.turnNumber}-${Date.now()}`,
      turnNumber: state.turnNumber,
      playerId: activePlayer.id,
      playerName: activePlayer.name,
      diceValue: state.lastDiceValue ?? 0,
      fromSquare: activePlayer.square,
      landedSquare: activePlayer.square,
      finalSquare: activePlayer.square,
      overshot: true,
      wonMatch: false,
      timestamp: Date.now(),
    };

    const nextState: GameEngineState = {
      ...state,
      phase: 'turn_complete',
      animationPhase: 'idle',
      moveHistory: [moveRecord, ...state.moveHistory].slice(0, 30),
    };
    return advanceToNextPlayerTurn(nextState);
  }

  const activePlayer = state.players[state.activePlayerIndex];
  const destination = state.pendingPath[state.pendingPath.length - 1];

  return {
    ...state,
    phase: 'moving',
    animationPhase: 'moving',
    statusMessage: `${activePlayer.name} melangkah menuju kotak ${destination}...`,
  };
}

export function completeNormalMovement(
  state: GameEngineState,
  options: { random?: RandomSource; board?: BoardConfiguration } = {}
): GameEngineState {
  if (state.phase !== 'moving') {
    return state;
  }

  const board = options.board ?? BOARD_CONFIG;
  const activePlayer = state.players[state.activePlayerIndex];
  const fromSquare = activePlayer.square;
  const landedSquare =
    state.pendingPath.length > 0
      ? state.pendingPath[state.pendingPath.length - 1]
      : activePlayer.square;

  const updatedPlayers = state.players.map((p, idx) =>
    idx === state.activePlayerIndex ? { ...p, square: landedSquare } : p
  );

  if (landedSquare === board.finishSquare) {
    const victoryRecord: MoveRecord = {
      id: `move-${state.turnNumber}-${Date.now()}`,
      turnNumber: state.turnNumber,
      playerId: activePlayer.id,
      playerName: activePlayer.name,
      diceValue: state.lastDiceValue ?? 0,
      fromSquare,
      landedSquare,
      finalSquare: landedSquare,
      overshot: false,
      wonMatch: true,
      timestamp: Date.now(),
    };

    return {
      ...state,
      players: updatedPlayers,
      pendingPath: [],
      phase: 'victory',
      animationPhase: 'victory',
      winnerId: activePlayer.id,
      moveHistory: [victoryRecord, ...state.moveHistory].slice(0, 30),
      statusMessage: `Selamat! ${activePlayer.name} mencapai Kotak 100 dan memenangkan petualangan cinta ini!`,
    };
  }

  const snake = board.snakes.find((s) => s.head === landedSquare);
  if (snake) {
    const transition: ActiveTransition = {
      kind: 'snake',
      id: snake.id,
      name: snake.name,
      fromSquare: snake.head,
      toSquare: snake.tail,
    };
    return {
      ...state,
      players: updatedPlayers,
      pendingPath: [fromSquare, landedSquare],
      phase: 'transitioning',
      animationPhase: 'transitioning',
      activeTransition: transition,
      statusMessage: `${activePlayer.name} bertemu ${snake.name} di kotak ${snake.head}! Meluncur turun ke kotak ${snake.tail}.`,
    };
  }

  const ladder = board.ladders.find((l) => l.bottom === landedSquare);
  if (ladder) {
    const transition: ActiveTransition = {
      kind: 'ladder',
      id: ladder.id,
      name: ladder.name,
      fromSquare: ladder.bottom,
      toSquare: ladder.top,
    };
    return {
      ...state,
      players: updatedPlayers,
      pendingPath: [fromSquare, landedSquare],
      phase: 'transitioning',
      animationPhase: 'transitioning',
      activeTransition: transition,
      statusMessage: `${activePlayer.name} menemukan ${ladder.name} di kotak ${ladder.bottom}! Naik menuju kotak ${ladder.top}.`,
    };
  }

  const squareMeta = board.squares[landedSquare];
  if (squareMeta?.type === 'truth') {
    const { card, updatedUsedIds } = selectNextChallengeCard(
      'truth',
      state.usedTruthIds,
      options.random,
      state.customCards
    );
    return {
      ...state,
      players: updatedPlayers,
      pendingPath: [fromSquare, landedSquare],
      phase: 'awaiting_challenge',
      animationPhase: 'reacting',
      activeChallenge: card,
      usedTruthIds: updatedUsedIds,
      statusMessage: `${activePlayer.name} mendarat di Kotak Truth (${landedSquare}) — Kategori: ${card.category}.`,
    };
  }

  if (squareMeta?.type === 'dare') {
    const { card, updatedUsedIds } = selectNextChallengeCard(
      'dare',
      state.usedDareIds,
      options.random,
      state.customCards
    );
    return {
      ...state,
      players: updatedPlayers,
      pendingPath: [fromSquare, landedSquare],
      phase: 'awaiting_challenge',
      animationPhase: 'reacting',
      activeChallenge: card,
      usedDareIds: updatedUsedIds,
      statusMessage: `${activePlayer.name} mendarat di Kotak Dare (${landedSquare}) — Kategori: ${card.category}.`,
    };
  }

  const normalRecord: MoveRecord = {
    id: `move-${state.turnNumber}-${Date.now()}`,
    turnNumber: state.turnNumber,
    playerId: activePlayer.id,
    playerName: activePlayer.name,
    diceValue: state.lastDiceValue ?? 0,
    fromSquare,
    landedSquare,
    finalSquare: landedSquare,
    overshot: false,
    wonMatch: false,
    timestamp: Date.now(),
  };

  const completedState: GameEngineState = {
    ...state,
    players: updatedPlayers,
    pendingPath: [],
    phase: 'turn_complete',
    animationPhase: 'idle',
    moveHistory: [normalRecord, ...state.moveHistory].slice(0, 30),
  };

  return advanceToNextPlayerTurn(completedState);
}

export function completeTransitionMovement(state: GameEngineState): GameEngineState {
  if (state.phase !== 'transitioning' || !state.activeTransition) {
    return state;
  }

  const activePlayer = state.players[state.activePlayerIndex];
  const fromSquare = state.pendingPath[0] ?? activePlayer.square;
  const landedSquare = state.activeTransition.fromSquare;
  const finalSquare = state.activeTransition.toSquare;

  const updatedPlayers = state.players.map((p, idx) =>
    idx === state.activePlayerIndex ? { ...p, square: finalSquare } : p
  );

  const transitionRecord: MoveRecord = {
    id: `move-${state.turnNumber}-${Date.now()}`,
    turnNumber: state.turnNumber,
    playerId: activePlayer.id,
    playerName: activePlayer.name,
    diceValue: state.lastDiceValue ?? 0,
    fromSquare,
    landedSquare,
    finalSquare,
    overshot: false,
    transition: state.activeTransition,
    wonMatch: false,
    timestamp: Date.now(),
  };

  const nextState: GameEngineState = {
    ...state,
    players: updatedPlayers,
    pendingPath: [],
    activeTransition: null,
    phase: 'turn_complete',
    animationPhase: 'idle',
    moveHistory: [transitionRecord, ...state.moveHistory].slice(0, 30),
  };

  return advanceToNextPlayerTurn(nextState);
}

export function resolveActiveChallenge(
  state: GameEngineState,
  outcome: 'completed' | 'skipped'
): GameEngineState {
  if (state.phase !== 'awaiting_challenge' || !state.activeChallenge) {
    return state;
  }

  const activePlayer = state.players[state.activePlayerIndex];
  const fromSquare = state.pendingPath[0] ?? activePlayer.square;
  const landedSquare = activePlayer.square;
  const card = state.activeChallenge;

  const updatedPlayers = state.players.map((p, idx) => {
    if (idx !== state.activePlayerIndex) return p;
    return {
      ...p,
      completedChallenges:
        outcome === 'completed' ? p.completedChallenges + 1 : p.completedChallenges,
      skippedChallenges:
        outcome === 'skipped' ? p.skippedChallenges + 1 : p.skippedChallenges,
    };
  });

  const challengeRecord: MoveRecord = {
    id: `move-${state.turnNumber}-${Date.now()}`,
    turnNumber: state.turnNumber,
    playerId: activePlayer.id,
    playerName: activePlayer.name,
    diceValue: state.lastDiceValue ?? 0,
    fromSquare,
    landedSquare,
    finalSquare: landedSquare,
    overshot: false,
    challenge: {
      cardId: card.id,
      type: card.type,
      category: card.category,
      outcome,
    },
    wonMatch: false,
    timestamp: Date.now(),
  };

  const nextState: GameEngineState = {
    ...state,
    players: updatedPlayers,
    pendingPath: [],
    activeChallenge: null,
    phase: 'turn_complete',
    animationPhase: 'idle',
    moveHistory: [challengeRecord, ...state.moveHistory].slice(0, 30),
  };

  return advanceToNextPlayerTurn(nextState);
}

export function advanceToNextPlayerTurn(state: GameEngineState): GameEngineState {
  if (state.phase === 'victory') {
    return state;
  }

  const nextIndex = (state.activePlayerIndex + 1) % state.players.length;
  const nextPlayer = state.players[nextIndex];

  return {
    ...state,
    phase: 'ready',
    animationPhase: 'idle',
    activePlayerIndex: nextIndex,
    turnNumber: state.turnNumber + 1,
    activeChallenge: null,
    activeTransition: null,
    pendingPath: [],
    statusMessage: `Giliran ${nextPlayer.name} (Kotak ${nextPlayer.square}) untuk melempar dadu.`,
  };
}
EOF

cat << 'EOF' > src/game/store/useGameStore.ts
import { create } from 'zustand';
import {
  loadCustomCardsFromStorage,
  saveCustomCardsToStorage,
} from '../challenges/challengeBank';
import {
  completeDiceRollAnimation,
  completeNormalMovement,
  completeTransitionMovement,
  createInitialGameState,
  resolveActiveChallenge,
  rollTurnDice,
  startMatch,
} from '../engine/gameEngine';
import { DEFAULT_PLAYERS_SETUP } from '../players/playerStyles';
import {
  ChallengeCard,
  CustomCardInput,
  GameEngineState,
  PlayerSetupInput,
} from '../types';

export type CameraMode = 'intro' | 'gameplay';

interface GameStore extends GameEngineState {
  soundEnabled: boolean;
  reducedMotion: boolean;
  cameraMode: CameraMode;
  cameraResetTrigger: number;
  setupModalOpen: boolean;
  customCardModalOpen: boolean;

  setSoundEnabled: (enabled: boolean) => void;
  setReducedMotion: (reduced: boolean) => void;
  finishCameraIntro: () => void;
  triggerCameraReset: () => void;
  setSetupModalOpen: (open: boolean) => void;
  setCustomCardModalOpen: (open: boolean) => void;

  hydrateCustomCards: () => void;
  addCustomCard: (input: CustomCardInput) => ChallengeCard | null;
  deleteCustomCard: (id: string) => void;
  clearAllCustomCards: () => void;

  startNewGame: (players?: PlayerSetupInput[], replayIntro?: boolean) => void;
  rollDice: (forcedValue?: number) => void;
  notifyDiceAnimationComplete: () => void;
  notifyMovementAnimationComplete: () => void;
  notifyTransitionAnimationComplete: () => void;
  completeChallenge: () => void;
  skipChallenge: () => void;
  setDebugPlayerSquare: (playerIndex: number, square: number) => void;
}

export const useGameStore = create<GameStore>((set, get) => ({
  ...createInitialGameState({
    players: DEFAULT_PLAYERS_SETUP,
    startInReadyPhase: true,
  }),
  soundEnabled: true,
  reducedMotion: false,
  cameraMode: 'intro',
  cameraResetTrigger: 0,
  setupModalOpen: false,
  customCardModalOpen: false,

  setSoundEnabled: (enabled) => set({ soundEnabled: enabled }),
  setReducedMotion: (reduced) =>
    set((state) => ({
      reducedMotion: reduced,
      cameraMode: reduced ? 'gameplay' : state.cameraMode,
    })),
  finishCameraIntro: () => set({ cameraMode: 'gameplay' }),
  triggerCameraReset: () =>
    set((state) => ({
      cameraMode: 'gameplay',
      cameraResetTrigger: state.cameraResetTrigger + 1,
    })),
  setSetupModalOpen: (open) => set({ setupModalOpen: open }),
  setCustomCardModalOpen: (open) => set({ customCardModalOpen: open }),

  hydrateCustomCards: () => {
    const stored = loadCustomCardsFromStorage();
    set({ customCards: stored });
  },

  addCustomCard: (input) => {
    const trimmedPrompt = input.prompt.trim();
    if (!trimmedPrompt) return null;

    const newCard: ChallengeCard = {
      id: `custom-${input.type}-${Date.now()}-${Math.random().toString(36).slice(2, 6)}`,
      type: input.type,
      category: input.category,
      prompt: trimmedPrompt,
      isCustom: true,
    };

    const updated = [newCard, ...get().customCards];
    saveCustomCardsToStorage(updated);
    set({ customCards: updated });
    return newCard;
  },

  deleteCustomCard: (id) => {
    const updated = get().customCards.filter((c) => c.id !== id);
    saveCustomCardsToStorage(updated);
    set({ customCards: updated });
  },

  clearAllCustomCards: () => {
    saveCustomCardsToStorage([]);
    set({ customCards: [] });
  },

  startNewGame: (playersInput, replayIntro = false) => {
    const current = get();
    const playersToUse =
      playersInput ??
      current.players.map((p) => ({
        name: p.name,
        pieceStyle: p.pieceStyle,
      }));
    const fresh = startMatch(current, playersToUse);
    set({
      ...fresh,
      setupModalOpen: false,
      cameraMode: replayIntro && !current.reducedMotion ? 'intro' : 'gameplay',
    });
  },

  rollDice: (forcedValue) => {
    const next = rollTurnDice(get(), { forcedDiceValue: forcedValue });
    set(next);
  },

  notifyDiceAnimationComplete: () => {
    const next = completeDiceRollAnimation(get());
    set(next);
  },

  notifyMovementAnimationComplete: () => {
    const next = completeNormalMovement(get());
    set(next);
  },

  notifyTransitionAnimationComplete: () => {
    const next = completeTransitionMovement(get());
    set(next);
  },

  completeChallenge: () => {
    const next = resolveActiveChallenge(get(), 'completed');
    set(next);
  },

  skipChallenge: () => {
    const next = resolveActiveChallenge(get(), 'skipped');
    set(next);
  },

  setDebugPlayerSquare: (playerIndex, square) => {
    set((state) => ({
      players: state.players.map((p, idx) =>
        idx === playerIndex ? { ...p, square } : p
      ),
    }));
  },
}));
EOF

cat << 'EOF' > src/components/ui/CustomCardEditorModal.tsx
'use client';

import React, { useState } from 'react';
import {
  Heart,
  Sparkles,
  Plus,
  Trash2,
  X,
  BookOpen,
} from 'lucide-react';
import {
  DARE_CATEGORIES,
  TRUTH_CATEGORIES,
} from '@/game/challenges/challengeBank';
import { useGameStore } from '@/game/store/useGameStore';
import { ChallengeType, DareCategory, TruthCategory } from '@/game/types';

export function CustomCardEditorModal() {
  const customCardModalOpen = useGameStore((s) => s.customCardModalOpen);
  const customCards = useGameStore((s) => s.customCards);
  const setCustomCardModalOpen = useGameStore((s) => s.setCustomCardModalOpen);
  const addCustomCard = useGameStore((s) => s.addCustomCard);
  const deleteCustomCard = useGameStore((s) => s.deleteCustomCard);
  const clearAllCustomCards = useGameStore((s) => s.clearAllCustomCards);

  const [type, setType] = useState<ChallengeType>('truth');
  const [category, setCategory] = useState<TruthCategory | DareCategory>(
    TRUTH_CATEGORIES[0]
  );
  const [prompt, setPrompt] = useState('');
  const [filterType, setFilterType] = useState<'all' | ChallengeType>('all');
  const [errorMsg, setErrorMsg] = useState<string | null>(null);

  if (!customCardModalOpen) return null;

  const categoriesForType =
    type === 'truth' ? TRUTH_CATEGORIES : DARE_CATEGORIES;

  const handleTypeChange = (nextType: ChallengeType) => {
    setType(nextType);
    setCategory(
      nextType === 'truth' ? TRUTH_CATEGORIES[0] : DARE_CATEGORIES[0]
    );
    setErrorMsg(null);
  };

  const handleAddCard = (e: React.FormEvent) => {
    e.preventDefault();
    const cleaned = prompt.trim();
    if (cleaned.length < 8) {
      setErrorMsg('Tulis pertanyaan atau tantangan minimal 8 karakter.');
      return;
    }

    addCustomCard({
      type,
      category,
      prompt: cleaned,
    });

    setPrompt('');
    setErrorMsg(null);
  };

  const filteredCards =
    filterType === 'all'
      ? customCards
      : customCards.filter((c) => c.type === filterType);

  const truthCount = customCards.filter((c) => c.type === 'truth').length;
  const dareCount = customCards.filter((c) => c.type === 'dare').length;

  return (
    <div
      role="dialog"
      aria-modal="true"
      aria-labelledby="custom-card-editor-title"
      data-testid="custom-card-editor-modal"
      className="fixed inset-0 z-50 flex items-center justify-center bg-garden-deepMauve/45 p-4 backdrop-blur-xs"
    >
      <div className="flex max-h-[90vh] w-full max-w-xl flex-col overflow-hidden rounded-3xl border-2 border-garden-gold bg-garden-ivory text-garden-mauve shadow-card">
        <div className="flex items-center justify-between border-b border-garden-gold/30 px-6 py-4">
          <div className="flex items-center gap-2.5">
            <span className="flex h-9 w-9 items-center justify-center rounded-full border border-garden-gold bg-garden-blush text-garden-rose">
              <BookOpen className="h-4 w-4" />
            </span>
            <div>
              <h2
                id="custom-card-editor-title"
                className="font-serif text-lg font-bold text-garden-deepMauve sm:text-xl"
              >
                Koleksi Kartu Kustom Pasangan
              </h2>
              <p className="text-xs text-garden-mauve/75">
                Tersimpan otomatis di perangkat ini ({truthCount} Truth •{' '}
                {dareCount} Dare)
              </p>
            </div>
          </div>

          <button
            type="button"
            aria-label="Tutup editor kartu"
            data-testid="close-custom-card-modal-btn"
            onClick={() => setCustomCardModalOpen(false)}
            className="rounded-full p-1.5 text-garden-mauve transition hover:bg-garden-blush"
          >
            <X className="h-5 w-5" />
          </button>
        </div>

        <div className="flex-1 space-y-5 overflow-y-auto p-6">
          <form
            onSubmit={handleAddCard}
            className="space-y-3.5 rounded-2xl border border-garden-gold/50 bg-garden-cream p-4"
          >
            <div className="flex flex-col gap-3 sm:flex-row">
              <div className="flex-1">
                <label className="mb-1 block text-xs font-semibold text-garden-deepMauve">
                  Jenis Kartu
                </label>
                <div className="grid grid-cols-2 gap-2">
                  <button
                    type="button"
                    data-testid="select-custom-type-truth"
                    onClick={() => handleTypeChange('truth')}
                    className={`flex items-center justify-center gap-1.5 rounded-xl border py-2 text-xs font-semibold transition ${
                      type === 'truth'
                        ? 'border-garden-rose bg-garden-blush text-garden-deepMauve shadow-xs'
                        : 'border-garden-gold/30 bg-white text-garden-mauve/75 hover:bg-garden-blush/40'
                    }`}
                  >
                    <Heart className="h-3.5 w-3.5 text-garden-rose" />
                    Truth
                  </button>
                  <button
                    type="button"
                    data-testid="select-custom-type-dare"
                    onClick={() => handleTypeChange('dare')}
                    className={`flex items-center justify-center gap-1.5 rounded-xl border py-2 text-xs font-semibold transition ${
                      type === 'dare'
                        ? 'border-garden-gold bg-garden-lavender text-garden-deepMauve shadow-xs'
                        : 'border-garden-gold/30 bg-white text-garden-mauve/75 hover:bg-garden-lavender/40'
                    }`}
                  >
                    <Sparkles className="h-3.5 w-3.5 text-garden-gold" />
                    Dare
                  </button>
                </div>
              </div>

              <div className="flex-1">
                <label
                  htmlFor="custom-card-category"
                  className="mb-1 block text-xs font-semibold text-garden-deepMauve"
                >
                  Kategori Romantis
                </label>
                <select
                  id="custom-card-category"
                  data-testid="custom-card-category-select"
                  value={category}
                  onChange={(e) =>
                    setCategory(
                      e.target.value as TruthCategory | DareCategory
                    )
                  }
                  className="w-full rounded-xl border border-garden-gold/40 bg-white px-3 py-2 text-xs font-medium text-garden-deepMauve focus:border-garden-rose focus:outline-none"
                >
                  {categoriesForType.map((cat) => (
                    <option key={cat} value={cat}>
                      {cat}
                    </option>
                  ))}
                </select>
              </div>
            </div>

            <div>
              <label
                htmlFor="custom-card-prompt"
                className="mb-1 block text-xs font-semibold text-garden-deepMauve"
              >
                Isi Pertanyaan / Tantangan
              </label>
              <textarea
                id="custom-card-prompt"
                data-testid="custom-card-prompt-input"
                rows={3}
                maxLength={280}
                value={prompt}
                onChange={(e) => {
                  setPrompt(e.target.value);
                  if (errorMsg) setErrorMsg(null);
                }}
                placeholder={
                  type === 'truth'
                    ? 'Contoh: Ceritakan momen ketika kamu merasa paling rindu padaku minggu ini...'
                    : 'Contoh: Nyanyikan lagu favorit kita sambil menggenggam tanganku selama 20 detik...'
                }
                className="w-full resize-none rounded-xl border border-garden-gold/40 bg-white p-3 text-sm text-garden-deepMauve placeholder:text-garden-mauve/45 focus:border-garden-rose focus:outline-none"
              />
              <div className="mt-1 flex items-center justify-between text-[11px] text-garden-mauve/70">
                <span>
                  {errorMsg ? (
                    <strong className="text-garden-rose">{errorMsg}</strong>
                  ) : (
                    'Kartu kustom akan diacak bersama kartu taman bawaan.'
                  )}
                </span>
                <span>{prompt.length}/280</span>
              </div>
            </div>

            <button
              type="submit"
              data-testid="add-custom-card-submit-btn"
              className="flex w-full items-center justify-center gap-2 rounded-xl bg-garden-rose px-4 py-2.5 text-xs font-semibold text-white shadow-sm transition hover:bg-garden-deepMauve focus:outline-none focus:ring-2 focus:ring-garden-rose"
            >
              <Plus className="h-4 w-4" />
              Simpan Kartu Kustom
            </button>
          </form>

          <div>
            <div className="mb-2.5 flex flex-wrap items-center justify-between gap-2">
              <div className="flex items-center gap-1.5">
                {(['all', 'truth', 'dare'] as const).map((tab) => (
                  <button
                    key={tab}
                    type="button"
                    onClick={() => setFilterType(tab)}
                    className={`rounded-lg px-2.5 py-1 text-xs font-semibold transition ${
                      filterType === tab
                        ? 'bg-garden-deepMauve text-white'
                        : 'bg-garden-cream text-garden-mauve hover:bg-garden-blush'
                    }`}
                  >
                    {tab === 'all'
                      ? `Semua (${customCards.length})`
                      : tab === 'truth'
                      ? `Truth (${truthCount})`
                      : `Dare (${dareCount})`}
                  </button>
                ))}
              </div>

              {customCards.length > 0 && (
                <button
                  type="button"
                  data-testid="clear-all-custom-cards-btn"
                  onClick={clearAllCustomCards}
                  className="text-xs font-medium text-garden-rose hover:underline"
                >
                  Hapus Semua
                </button>
              )}
            </div>

            {filteredCards.length === 0 ? (
              <div
                data-testid="empty-custom-cards-state"
                className="rounded-2xl border border-dashed border-garden-gold/50 bg-garden-cream/60 p-6 text-center text-xs text-garden-mauve/75"
              >
                Belum ada kartu kustom pada kategori ini. Tambahkan pertanyaan atau tantangan spesial versi kalian di atas!
              </div>
            ) : (
              <ul data-testid="custom-cards-list" className="space-y-2.5">
                {filteredCards.map((card) => (
                  <li
                    key={card.id}
                    data-testid={`custom-card-item-${card.id}`}
                    className="flex items-start justify-between gap-3 rounded-2xl border border-garden-gold/40 bg-garden-cream p-3.5 shadow-2xs"
                  >
                    <div className="space-y-1">
                      <div className="flex flex-wrap items-center gap-2">
                        <span
                          className={`inline-flex items-center gap-1 rounded-full px-2.5 py-0.5 text-[10px] font-bold uppercase ${
                            card.type === 'truth'
                              ? 'bg-garden-blush text-garden-deepMauve'
                              : 'bg-garden-lavender text-garden-deepMauve'
                          }`}
                        >
                          {card.type === 'truth' ? '♥ Truth' : '✦ Dare'}
                        </span>
                        <span className="text-[11px] font-medium text-garden-mauve/75">
                          {card.category}
                        </span>
                      </div>
                      <p className="font-serif text-sm text-garden-deepMauve">
                        “{card.prompt}”
                      </p>
                    </div>

                    <button
                      type="button"
                      aria-label={`Hapus kartu ${card.prompt}`}
                      data-testid={`delete-custom-card-${card.id}`}
                      onClick={() => deleteCustomCard(card.id)}
                      className="rounded-xl p-1.5 text-garden-mauve/70 transition hover:bg-garden-blush hover:text-garden-rose"
                    >
                      <Trash2 className="h-4 w-4" />
                    </button>
                  </li>
                ))}
              </ul>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
EOF

cat << 'EOF' > src/components/ui/ChallengeCardModal.tsx
'use client';

import React, { useEffect } from 'react';
import { Heart, Sparkles, Check, FastForward } from 'lucide-react';
import { useGameStore } from '@/game/store/useGameStore';
import { soundEngine } from '../audio/soundEngine';

export function ChallengeCardModal() {
  const phase = useGameStore((s) => s.phase);
  const activeChallenge = useGameStore((s) => s.activeChallenge);
  const players = useGameStore((s) => s.players);
  const activePlayerIndex = useGameStore((s) => s.activePlayerIndex);
  const soundEnabled = useGameStore((s) => s.soundEnabled);
  const completeChallenge = useGameStore((s) => s.completeChallenge);
  const skipChallenge = useGameStore((s) => s.skipChallenge);

  const activePlayer = players[activePlayerIndex];

  useEffect(() => {
    if (phase === 'awaiting_challenge' && activeChallenge) {
      soundEngine.playChallengeReveal(soundEnabled, activeChallenge.type);
    }
  }, [phase, activeChallenge, soundEnabled]);

  if (phase !== 'awaiting_challenge' || !activeChallenge || !activePlayer) {
    return null;
  }

  const isTruth = activeChallenge.type === 'truth';

  return (
    <div
      role="dialog"
      aria-modal="true"
      aria-labelledby="challenge-card-title"
      data-testid="challenge-card-modal"
      className="fixed inset-x-0 bottom-4 z-40 mx-auto flex max-w-lg items-end justify-center px-4 sm:inset-y-0 sm:items-center"
    >
      <div className="w-full rounded-3xl border-2 border-garden-gold bg-garden-ivory p-6 text-garden-mauve shadow-card transition-all">
        <div className="mb-3 flex flex-wrap items-center justify-between gap-2">
          <div className="flex items-center gap-1.5">
            <span
              className={`inline-flex items-center gap-1.5 rounded-full px-3.5 py-1 text-xs font-semibold uppercase tracking-wider ${
                isTruth
                  ? 'bg-garden-blush text-garden-mauve border border-garden-rose'
                  : 'bg-garden-lavender text-garden-mauve border border-garden-gold'
              }`}
            >
              {isTruth ? (
                <Heart className="h-3.5 w-3.5 text-garden-rose" />
              ) : (
                <Sparkles className="h-3.5 w-3.5 text-garden-gold" />
              )}
              {isTruth ? 'Kartu Truth' : 'Kartu Dare'}
            </span>

            {activeChallenge.isCustom && (
              <span
                data-testid="custom-card-badge"
                className="rounded-full border border-garden-gold bg-garden-cream px-2.5 py-0.5 text-[10px] font-semibold text-garden-deepMauve"
              >
                ✨ Kartu Kustom
              </span>
            )}
          </div>

          <span className="text-xs font-medium text-garden-mauve/80">
            Kotak #{activePlayer.square} • {activeChallenge.category}
          </span>
        </div>

        <h2
          id="challenge-card-title"
          className="font-serif text-xl font-bold text-garden-deepMauve"
        >
          Untuk {activePlayer.name}
        </h2>

        <div className="my-3 flex items-center gap-2">
          <div className="h-px flex-1 bg-garden-gold/40" />
          <span className="text-xs text-garden-gold">❀</span>
          <div className="h-px flex-1 bg-garden-gold/40" />
        </div>

        <p
          data-testid="challenge-prompt-text"
          className="my-4 font-serif text-base leading-relaxed text-garden-deepMauve sm:text-lg"
        >
          “{activeChallenge.prompt}”
        </p>

        <p className="mb-5 text-xs text-garden-mauve/75">
          Kenyamanan bersama adalah prioritas utama. Kamu bebas menyelesaikan atau melewati kartu ini kapan saja tanpa penalti.
        </p>

        <div className="flex flex-col gap-2.5 sm:flex-row">
          <button
            type="button"
            data-testid="complete-challenge-btn"
            onClick={completeChallenge}
            className="flex flex-1 items-center justify-center gap-2 rounded-2xl bg-garden-rose px-5 py-3 text-sm font-semibold text-white shadow-sm transition hover:bg-garden-deepMauve focus:outline-none focus:ring-2 focus:ring-garden-rose"
          >
            <Check className="h-4 w-4" />
            Selesai Dilakukan
          </button>
          <button
            type="button"
            data-testid="skip-challenge-btn"
            onClick={skipChallenge}
            className="flex items-center justify-center gap-2 rounded-2xl border border-garden-gold bg-garden-cream px-5 py-3 text-sm font-medium text-garden-mauve transition hover:bg-garden-blush focus:outline-none focus:ring-2 focus:ring-garden-gold"
          >
            <FastForward className="h-4 w-4" />
            Lewati Tanpa Penalti
          </button>
        </div>
      </div>
    </div>
  );
}
EOF

cat << 'EOF' > src/components/ui/GameplayHUD.tsx
'use client';

import React, { useState } from 'react';
import {
  Volume2,
  VolumeX,
  RotateCcw,
  Compass,
  Users,
  Dices,
  History,
  ChevronUp,
  ChevronDown,
  BookOpen,
} from 'lucide-react';
import { useGameStore } from '@/game/store/useGameStore';

export function GameplayHUD() {
  const phase = useGameStore((s) => s.phase);
  const players = useGameStore((s) => s.players);
  const activePlayerIndex = useGameStore((s) => s.activePlayerIndex);
  const lastDiceValue = useGameStore((s) => s.lastDiceValue);
  const statusMessage = useGameStore((s) => s.statusMessage);
  const moveHistory = useGameStore((s) => s.moveHistory);
  const soundEnabled = useGameStore((s) => s.soundEnabled);
  const customCards = useGameStore((s) => s.customCards);

  const setSoundEnabled = useGameStore((s) => s.setSoundEnabled);
  const triggerCameraReset = useGameStore((s) => s.triggerCameraReset);
  const setSetupModalOpen = useGameStore((s) => s.setSetupModalOpen);
  const setCustomCardModalOpen = useGameStore((s) => s.setCustomCardModalOpen);
  const startNewGame = useGameStore((s) => s.startNewGame);
  const rollDice = useGameStore((s) => s.rollDice);

  const [historyOpen, setHistoryOpen] = useState(false);

  const activePlayer = players[activePlayerIndex] ?? players[0];
  const canRoll = phase === 'ready';

  return (
    <div className="pointer-events-none fixed inset-0 z-30 flex flex-col justify-between p-3 sm:p-5">
      <header className="pointer-events-auto flex items-center justify-between rounded-2xl border border-garden-gold/60 bg-garden-ivory/95 px-4 py-2.5 text-garden-mauve shadow-romantic backdrop-blur-xs">
        <div className="flex items-center gap-3">
          <span className="flex h-8 w-8 items-center justify-center rounded-full border border-garden-gold bg-garden-blush font-serif text-sm font-bold text-garden-deepMauve">
            ❀
          </span>
          <div>
            <h1 className="font-serif text-sm font-bold tracking-wide text-garden-deepMauve sm:text-base">
              Truth or Dare: Romantic Garden
            </h1>
            <p className="hidden text-[11px] text-garden-mauve/75 sm:block">
              Ular Tangga 3D Romantis • 100 Kotak Petualangan Pasangan
            </p>
          </div>
        </div>

        <div className="flex items-center gap-1.5 sm:gap-2">
          <button
            type="button"
            onClick={() => setCustomCardModalOpen(true)}
            aria-label="Kelola kartu kustom pasangan"
            data-testid="open-custom-cards-btn"
            className="flex items-center gap-1.5 rounded-xl border border-garden-gold/50 bg-garden-cream px-2.5 py-1.5 text-xs font-medium text-garden-mauve transition hover:bg-garden-blush focus:outline-none focus:ring-2 focus:ring-garden-rose"
          >
            <BookOpen className="h-4 w-4 text-garden-rose" />
            <span className="hidden md:inline">Kartu Kustom</span>
            {customCards.length > 0 && (
              <span
                data-testid="custom-cards-count-badge"
                className="rounded-full bg-garden-rose px-1.5 py-0.2 text-[10px] font-bold text-white"
              >
                {customCards.length}
              </span>
            )}
          </button>

          <button
            type="button"
            onClick={() => setSoundEnabled(!soundEnabled)}
            aria-label={soundEnabled ? 'Matikan suara' : 'Nyalakan suara'}
            data-testid="sound-toggle-btn"
            className="flex items-center gap-1 rounded-xl border border-garden-gold/50 bg-garden-cream px-2.5 py-1.5 text-xs font-medium text-garden-mauve transition hover:bg-garden-blush focus:outline-none focus:ring-2 focus:ring-garden-rose"
          >
            {soundEnabled ? (
              <Volume2 className="h-4 w-4 text-garden-rose" />
            ) : (
              <VolumeX className="h-4 w-4 text-garden-mauve/60" />
            )}
            <span className="hidden lg:inline">
              {soundEnabled ? 'Suara Aktif' : 'Bisu'}
            </span>
          </button>

          <button
            type="button"
            onClick={triggerCameraReset}
            aria-label="Reset sudut kamera"
            data-testid="camera-reset-btn"
            className="flex items-center gap-1 rounded-xl border border-garden-gold/50 bg-garden-cream px-2.5 py-1.5 text-xs font-medium text-garden-mauve transition hover:bg-garden-blush focus:outline-none focus:ring-2 focus:ring-garden-rose"
          >
            <Compass className="h-4 w-4 text-garden-gold" />
            <span className="hidden lg:inline">Reset Kamera</span>
          </button>

          <button
            type="button"
            onClick={() => setSetupModalOpen(true)}
            aria-label="Pengaturan pemain"
            data-testid="open-setup-btn"
            className="flex items-center gap-1 rounded-xl border border-garden-gold/50 bg-garden-cream px-2.5 py-1.5 text-xs font-medium text-garden-mauve transition hover:bg-garden-blush focus:outline-none focus:ring-2 focus:ring-garden-rose"
          >
            <Users className="h-4 w-4 text-garden-rose" />
            <span className="hidden md:inline">Pemain</span>
          </button>

          <button
            type="button"
            onClick={() => startNewGame(undefined, false)}
            aria-label="Mulai ulang permainan"
            data-testid="restart-match-btn"
            className="flex items-center gap-1 rounded-xl border border-garden-gold/60 bg-garden-blush px-2.5 py-1.5 text-xs font-semibold text-garden-deepMauve transition hover:bg-garden-rose hover:text-white focus:outline-none focus:ring-2 focus:ring-garden-rose"
          >
            <RotateCcw className="h-4 w-4" />
            <span className="hidden sm:inline">Mulai Baru</span>
          </button>
        </div>
      </header>

      <div className="flex flex-col gap-2 sm:flex-row sm:items-end sm:justify-between">
        <div className="pointer-events-auto flex flex-col gap-2 rounded-2xl border border-garden-gold/60 bg-garden-ivory/95 p-3.5 text-garden-mauve shadow-romantic backdrop-blur-xs sm:max-w-md">
          <div className="flex flex-wrap gap-2">
            {players.map((p, idx) => {
              const isActive = idx === activePlayerIndex;
              return (
                <div
                  key={p.id}
                  data-testid={`player-card-${idx}`}
                  className={`flex items-center gap-2 rounded-xl border px-3 py-1.5 text-xs transition ${
                    isActive
                      ? 'border-garden-rose bg-garden-blush font-semibold text-garden-deepMauve shadow-xs'
                      : 'border-garden-gold/30 bg-garden-cream text-garden-mauve/80'
                  }`}
                >
                  <span
                    className="h-3 w-3 rounded-full border border-garden-deepMauve/40"
                    style={{ backgroundColor: p.accentColor }}
                  />
                  <span>{p.name}</span>
                  <span
                    data-testid={`player-square-${idx}`}
                    className="rounded-md bg-white/80 px-1.5 py-0.5 text-[11px] font-bold text-garden-deepMauve"
                  >
                    #{p.square}
                  </span>
                </div>
              );
            })}
          </div>

          <div
            role="status"
            aria-live="polite"
            data-testid="status-banner"
            className="text-xs leading-snug text-garden-deepMauve"
          >
            {statusMessage}
          </div>

          <div>
            <button
              type="button"
              onClick={() => setHistoryOpen(!historyOpen)}
              className="flex items-center gap-1 text-[11px] font-semibold text-garden-rose hover:underline"
            >
              <History className="h-3.5 w-3.5" />
              Riwayat Langkah ({moveHistory.length})
              {historyOpen ? (
                <ChevronDown className="h-3.5 w-3.5" />
              ) : (
                <ChevronUp className="h-3.5 w-3.5" />
              )}
            </button>

            {historyOpen && (
              <ul
                data-testid="move-history-list"
                className="mt-1.5 max-h-28 space-y-1 overflow-y-auto rounded-xl border border-garden-gold/30 bg-garden-cream p-2 text-[11px]"
              >
                {moveHistory.length === 0 ? (
                  <li className="text-garden-mauve/60">
                    Belum ada langkah tercatat.
                  </li>
                ) : (
                  moveHistory.slice(0, 8).map((item) => (
                    <li key={item.id} className="border-b border-garden-blush/50 pb-1 last:border-none">
                      <strong>{item.playerName}</strong> dadu [{item.diceValue}]: #{item.fromSquare} → #{item.finalSquare}
                      {item.transition && ` (${item.transition.name})`}
                      {item.challenge &&
                        ` [${item.challenge.type.toUpperCase()} - ${
                          item.challenge.outcome === 'completed'
                            ? 'Selesai'
                            : 'Dilewati'
                        }]`}
                    </li>
                  ))
                )}
              </ul>
            )}
          </div>
        </div>

        <div className="pointer-events-auto flex items-center justify-between gap-3 rounded-2xl border border-garden-gold/60 bg-garden-ivory/95 p-3.5 shadow-romantic backdrop-blur-xs sm:justify-end">
          <div className="text-left sm:text-right">
            <div className="text-[11px] font-medium text-garden-mauve/75">
              Giliran Aktif
            </div>
            <div
              data-testid="active-player-indicator"
              className="font-serif text-sm font-bold text-garden-deepMauve"
            >
              {activePlayer.name} (Kotak #{activePlayer.square})
            </div>
            <div
              data-testid="dice-result-readout"
              className="text-xs font-semibold text-garden-rose"
            >
              Hasil Dadu: {lastDiceValue !== null ? lastDiceValue : '—'}
            </div>
          </div>

          <button
            type="button"
            disabled={!canRoll}
            onClick={() => rollDice()}
            data-testid="roll-dice-btn"
            className="flex items-center gap-2 rounded-2xl bg-garden-rose px-5 py-3.5 text-sm font-semibold text-white shadow-romantic transition hover:bg-garden-deepMauve disabled:cursor-not-allowed disabled:opacity-50 focus:outline-none focus:ring-2 focus:ring-garden-rose"
          >
            <Dices className="h-5 w-5" />
            <span>{canRoll ? 'Lempar Dadu' : 'Memproses...'}</span>
          </button>
        </div>
      </div>
    </div>
  );
}
EOF

cat << 'EOF' > src/app/page.tsx
'use client';

import React, { useEffect } from 'react';
import { RomanticGardenScene } from '@/components/scene/RomanticGardenScene';
import { ChallengeCardModal } from '@/components/ui/ChallengeCardModal';
import { CustomCardEditorModal } from '@/components/ui/CustomCardEditorModal';
import { GameplayHUD } from '@/components/ui/GameplayHUD';
import { PlayerSetupModal } from '@/components/ui/PlayerSetupModal';
import { VictoryModal } from '@/components/ui/VictoryModal';
import { useGameStore } from '@/game/store/useGameStore';

export default function HomePage() {
  const setReducedMotion = useGameStore((s) => s.setReducedMotion);
  const hydrateCustomCards = useGameStore((s) => s.hydrateCustomCards);

  useEffect(() => {
    hydrateCustomCards();

    if (typeof window !== 'undefined' && window.matchMedia) {
      const mediaQuery = window.matchMedia('(prefers-reduced-motion: reduce)');
      if (mediaQuery.matches) {
        setReducedMotion(true);
      }
    }

    if (typeof window !== 'undefined') {
      (window as unknown as { __GAME_STORE__?: typeof useGameStore }).__GAME_STORE__ =
        useGameStore;
    }
  }, [setReducedMotion, hydrateCustomCards]);

  return (
    <main className="relative h-screen w-screen overflow-hidden bg-garden-blush">
      <RomanticGardenScene />
      <GameplayHUD />
      <ChallengeCardModal />
      <CustomCardEditorModal />
      <PlayerSetupModal />
      <VictoryModal />
    </main>
  );
}
EOF

cat << 'EOF' >> src/tests/gameEngine.test.ts

describe('Custom Couple Cards Integration', () => {
  it('24. includes custom cards in selectNextChallengeCard and preserves them across restarts', () => {
    const customTruth = {
      id: 'custom-truth-1',
      type: 'truth' as const,
      category: 'Awal Jatuh Cinta' as const,
      prompt: 'Pertanyaan spesial buatan pasangan sendiri.',
      isCustom: true,
    };

    const selected = selectNextChallengeCard('truth', [], () => 0, [customTruth]);
    expect(selected.card.id).toBe('custom-truth-1');
    expect(selected.card.isCustom).toBe(true);

    let state = createInitialGameState({ customCards: [customTruth] });
    expect(state.customCards).toHaveLength(1);

    state = startMatch(state, [
      { name: 'Sayang 1', pieceStyle: 'ivory_rose_gold' },
      { name: 'Sayang 2', pieceStyle: 'blush_quartz' },
    ]);
    expect(state.customCards).toHaveLength(1);
    expect(state.customCards[0].id).toBe('custom-truth-1');
  });
});
EOF

echo "✅ Fitur Editor Kartu Kustom berhasil dipasang! Jalankan 'npm run test' untuk memverifikasi."