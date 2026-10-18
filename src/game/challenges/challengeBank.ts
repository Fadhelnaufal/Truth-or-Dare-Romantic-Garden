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
