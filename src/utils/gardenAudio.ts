// utils/gardenAudio.ts
// Procedural Kawaii Fantasy Garden BGM, SFX & WAV Exporter (Zero Dependencies)

class KawaiiGardenAudio {
  private ctx: AudioContext | null = null;
  private isPlaying = false;
  private isMuted = false;
  private masterGain: GainNode | null = null;
  private loopTimer: number | null = null;
  private stepIndex = 0;
  private listeners: Set<() => void> = new Set();

  // Tangga nada F Major Pentatonic / Lydian Pastel (Frekuensi dalam Hz)
  private readonly NOTES: Record<string, number> = {
    F3: 174.61, G3: 196.00, A3: 220.00, C4: 261.63, D4: 293.66, E4: 329.63,
    F4: 349.23, G4: 392.00, A4: 440.00, Bb4: 466.16, C5: 523.25, D5: 587.33,
    E5: 659.25, F5: 698.46, G5: 783.99, A5: 880.00, C6: 1046.50
  };

  // Pola Melodi Music Box & Pizzicato (16 ketukan per bar, 2 bar loop)
  private readonly MELODY: (string | null)[] = [
    'C5', null, 'A4', 'C5',  'F5', null, 'E5', 'C5',
    'D5', null, 'C5', 'A4',  'G4', null, 'A4', null,
    'C5', null, 'A4', 'C5',  'G5', null, 'F5', 'D5',
    'E5', 'F5', 'E5', 'C5',  'F5', null, null, null,
  ];

  private readonly BASS: (string | null)[] = [
    'F3', null, 'C4', null,  'F3', null, 'C4', null,
    'G3', null, 'D4', null,  'C4', null, 'G3', null,
    'F3', null, 'C4', null,  'A3', null, 'E4', null,
    'G3', null, 'C4', null,  'F3', null, 'C4', null,
  ];

  private initContext() {
    if (typeof window === 'undefined') return;
    if (!this.ctx) {
      const AudioCtx =
        window.AudioContext ||
        (window as unknown as { webkitAudioContext?: typeof AudioContext })
          .webkitAudioContext;
      if (AudioCtx) {
        this.ctx = new AudioCtx();
        this.masterGain = this.ctx.createGain();
        this.masterGain.gain.value = this.isMuted ? 0 : 0.35;
        this.masterGain.connect(this.ctx.destination);
      }
    }
    if (this.ctx && this.ctx.state === 'suspended') {
      this.ctx.resume().catch(() => {});
    }
  }

  private notify() {
    this.listeners.forEach((cb) => {
      try {
        cb();
      } catch {
        // Abaikan error callback listener
      }
    });
  }

  public subscribe(callback: () => void): () => void {
    this.listeners.add(callback);
    return () => {
      this.listeners.delete(callback);
    };
  }

  public isBGMPlaying(): boolean {
    return this.isPlaying;
  }

  public getIsMuted(): boolean {
    return this.isMuted;
  }

  // Instrumen Celesta / Music Box lembut
  private playBellNote(
    context: BaseAudioContext,
    destination: AudioNode,
    freq: number,
    startTime: number,
    duration = 0.45,
    volume = 0.22
  ) {
    const osc = context.createOscillator();
    const overtone = context.createOscillator();
    const gain = context.createGain();

    osc.type = 'sine';
    osc.frequency.setValueAtTime(freq, startTime);

    // Overtone lembut untuk karakter chime/glockenspiel kawaii
    overtone.type = 'triangle';
    overtone.frequency.setValueAtTime(freq * 2, startTime);

    const overtoneGain = context.createGain();
    overtoneGain.gain.setValueAtTime(volume * 0.25, startTime);
    overtoneGain.gain.exponentialRampToValueAtTime(0.0001, startTime + duration * 0.5);

    gain.gain.setValueAtTime(0.001, startTime);
    gain.gain.linearRampToValueAtTime(volume, startTime + 0.015);
    gain.gain.exponentialRampToValueAtTime(0.0008, startTime + duration);

    osc.connect(gain);
    overtone.connect(overtoneGain);
    overtoneGain.connect(gain);
    gain.connect(destination);

    osc.start(startTime);
    overtone.start(startTime);
    osc.stop(startTime + duration);
    overtone.stop(startTime + duration);
  }

  // Instrumen Pizzicato Bass hangat
  private playPizzicatoNote(
    context: BaseAudioContext,
    destination: AudioNode,
    freq: number,
    startTime: number,
    duration = 0.22,
    volume = 0.18
  ) {
    const osc = context.createOscillator();
    const gain = context.createGain();

    osc.type = 'triangle';
    osc.frequency.setValueAtTime(freq, startTime);

    gain.gain.setValueAtTime(0.001, startTime);
    gain.gain.linearRampToValueAtTime(volume, startTime + 0.01);
    gain.gain.exponentialRampToValueAtTime(0.001, startTime + duration);

    osc.connect(gain);
    gain.connect(destination);

    osc.start(startTime);
    osc.stop(startTime + duration);
  }

  // ==========================================================================
  // 1. LIVE BGM PLAYBACK CONTROLS
  // ==========================================================================
  public startBGM() {
    this.initContext();
    if (this.isPlaying || !this.ctx || !this.masterGain) return;
    this.isPlaying = true;
    this.notify();

    const bpm = 108;
    const stepMs = (60 / bpm / 2) * 1000; // 8th-note steps

    const tick = () => {
      if (!this.isPlaying || !this.ctx || !this.masterGain) return;
      const now = this.ctx.currentTime;

      const melNote = this.MELODY[this.stepIndex % this.MELODY.length];
      const bassNote = this.BASS[this.stepIndex % this.BASS.length];

      if (melNote && this.NOTES[melNote]) {
        this.playBellNote(this.ctx, this.masterGain, this.NOTES[melNote], now, 0.5, 0.22);
      }
      if (bassNote && this.NOTES[bassNote]) {
        this.playPizzicatoNote(this.ctx, this.masterGain, this.NOTES[bassNote], now, 0.25, 0.16);
      }

      this.stepIndex = (this.stepIndex + 1) % this.MELODY.length;
      this.loopTimer = window.setTimeout(tick, stepMs);
    };

    tick();
  }

  public stopBGM() {
    this.isPlaying = false;
    if (this.loopTimer !== null) {
      clearTimeout(this.loopTimer);
      this.loopTimer = null;
    }
    this.notify();
  }

  public togglePlayPause(): boolean {
    if (this.isPlaying) {
      this.stopBGM();
      return false;
    } else {
      this.startBGM();
      return true;
    }
  }

  public toggleMute(): boolean {
    this.initContext();
    this.isMuted = !this.isMuted;
    if (this.masterGain && this.ctx) {
      this.masterGain.gain.setTargetAtTime(this.isMuted ? 0 : 0.35, this.ctx.currentTime, 0.05);
    }
    this.notify();
    return this.isMuted;
  }

  public setMuted(muted: boolean): boolean {
    this.initContext();
    this.isMuted = muted;
    if (this.masterGain && this.ctx) {
      this.masterGain.gain.setTargetAtTime(this.isMuted ? 0 : 0.35, this.ctx.currentTime, 0.05);
    }
    this.notify();
    return this.isMuted;
  }

  // ==========================================================================
  // 2. KAWAII GAMEPLAY SOUND EFFECTS (SFX)
  // ==========================================================================
  /** Suara loncatan imut saat pion Kuromi / Hello Kitty berpindah kotak */
  public playHop(stepNumber = 0) {
    this.initContext();
    if (this.isMuted || !this.ctx || !this.masterGain) return;

    const now = this.ctx.currentTime;
    const osc = this.ctx.createOscillator();
    const gain = this.ctx.createGain();

    const baseFreq = 380 + (stepNumber % 5) * 35;
    osc.type = 'sine';
    osc.frequency.setValueAtTime(baseFreq, now);
    osc.frequency.exponentialRampToValueAtTime(baseFreq * 1.45, now + 0.09);

    gain.gain.setValueAtTime(0.25, now);
    gain.gain.exponentialRampToValueAtTime(0.001, now + 0.11);

    osc.connect(gain);
    gain.connect(this.masterGain);
    osc.start(now);
    osc.stop(now + 0.11);
  }

  /** Suara kocok dadu pastel */
  public playDiceRoll() {
    this.initContext();
    if (this.isMuted || !this.ctx || !this.masterGain) return;

    const popNotes = [523.25, 659.25, 587.33, 783.99];
    popNotes.forEach((freq, idx) => {
      if (!this.ctx || !this.masterGain) return;
      this.playPizzicatoNote(this.ctx, this.masterGain, freq, this.ctx.currentTime + idx * 0.055, 0.08, 0.2);
    });
  }

  /** Suara naik tangga: Arpeggio chime berkilau ke atas */
  public playLadderClimb() {
    this.initContext();
    if (this.isMuted || !this.ctx || !this.masterGain) return;

    const scale = ['F4', 'A4', 'C5', 'E5', 'F5', 'A5', 'C6'];
    scale.forEach((n, i) => {
      if (!this.ctx || !this.masterGain) return;
      const freq = this.NOTES[n];
      if (freq) {
        this.playBellNote(this.ctx, this.masterGain, freq, this.ctx.currentTime + i * 0.075, 0.45, 0.25);
      }
    });
  }

  /** Suara turun ular: Glissando komikal yang tetap lucu (tidak seram) */
  public playSnakeSlide() {
    this.initContext();
    if (this.isMuted || !this.ctx || !this.masterGain) return;

    const now = this.ctx.currentTime;
    const osc = this.ctx.createOscillator();
    const gain = this.ctx.createGain();

    osc.type = 'triangle';
    osc.frequency.setValueAtTime(680, now);
    osc.frequency.exponentialRampToValueAtTime(220, now + 0.48);

    gain.gain.setValueAtTime(0.25, now);
    gain.gain.exponentialRampToValueAtTime(0.001, now + 0.5);

    osc.connect(gain);
    gain.connect(this.masterGain);
    osc.start(now);
    osc.stop(now + 0.5);
  }

  /** Suara pembukaan kartu spesial (Truth / Dare / Custom) */
  public playSpecialCard(type: 'truth' | 'dare' | 'custom' = 'truth') {
    this.initContext();
    if (this.isMuted || !this.ctx || !this.masterGain) return;

    const now = this.ctx.currentTime;
    if (type === 'truth') {
      // Arpeggio nada romantis hangat & berkilau: F4, A4, C5, F5, A5
      const notes = ['F4', 'A4', 'C5', 'F5', 'A5'];
      notes.forEach((n, i) => {
        if (!this.ctx || !this.masterGain) return;
        const freq = this.NOTES[n];
        if (freq) {
          this.playBellNote(this.ctx, this.masterGain, freq, now + i * 0.065, 0.52, 0.24);
        }
      });
    } else if (type === 'dare') {
      // Arpeggio ceria, playful & bertenaga: G4, Bb4, D5, G5
      const notes = ['G4', 'Bb4', 'D5', 'G5'];
      notes.forEach((n, i) => {
        if (!this.ctx || !this.masterGain) return;
        const freq = this.NOTES[n] || 392;
        this.playPizzicatoNote(this.ctx, this.masterGain, freq, now + i * 0.06, 0.32, 0.24);
        this.playBellNote(this.ctx, this.masterGain, freq, now + i * 0.06, 0.48, 0.18);
      });
    } else {
      // Custom card: Shimmering sparkle chime: A4, C5, E5, A5, C6
      const notes = ['A4', 'C5', 'E5', 'A5', 'C6'];
      notes.forEach((n, i) => {
        if (!this.ctx || !this.masterGain) return;
        const freq = this.NOTES[n];
        if (freq) {
          this.playBellNote(this.ctx, this.masterGain, freq, now + i * 0.05, 0.55, 0.25);
        }
      });
    }
  }

  /** Suara selebrasi kemenangan saat mencapai kotak 100 */
  public playVictory() {
    this.initContext();
    if (this.isMuted || !this.ctx || !this.masterGain) return;

    const now = this.ctx.currentTime;
    const fanfare = [
      { note: 'F4', time: 0.00, dur: 0.18 },
      { note: 'A4', time: 0.12, dur: 0.18 },
      { note: 'C5', time: 0.24, dur: 0.22 },
      { note: 'F5', time: 0.38, dur: 0.45 },
      { note: 'E5', time: 0.52, dur: 0.18 },
      { note: 'F5', time: 0.66, dur: 0.75 },
      { note: 'A5', time: 0.85, dur: 0.95 },
      { note: 'C6', time: 1.05, dur: 1.25 },
    ];

    fanfare.forEach((f) => {
      if (!this.ctx || !this.masterGain) return;
      const freq = this.NOTES[f.note];
      if (freq) {
        this.playBellNote(this.ctx, this.masterGain, freq, now + f.time, f.dur, 0.28);
        this.playPizzicatoNote(this.ctx, this.masterGain, freq / 2, now + f.time, f.dur * 0.7, 0.18);
      }
    });
  }

  /** Suara klik tombol kawaii lembut */
  public playClick() {
    this.initContext();
    if (this.isMuted || !this.ctx || !this.masterGain) return;
    const now = this.ctx.currentTime;
    const freq = this.NOTES['C6'] || 1046.5;
    this.playBellNote(this.ctx, this.masterGain, freq, now, 0.09, 0.14);
  }

  // ==========================================================================
  // 3. EXPORT BGM KE FILE "romantic-garden-bgm.wav"
  // ==========================================================================
  public async downloadGardenBGM(bars = 4) {
    if (typeof window === 'undefined') return;
    const bpm = 108;
    const stepSec = 60 / bpm / 2;
    const totalSteps = this.MELODY.length * bars;
    const durationSec = totalSteps * stepSec + 1.0;
    const sampleRate = 44100;

    const offlineCtx = new OfflineAudioContext(2, Math.ceil(sampleRate * durationSec), sampleRate);
    const master = offlineCtx.createGain();
    master.gain.value = 0.45;
    master.connect(offlineCtx.destination);

    for (let i = 0; i < totalSteps; i++) {
      const t = i * stepSec;
      const mel = this.MELODY[i % this.MELODY.length];
      const bas = this.BASS[i % this.BASS.length];
      if (mel && this.NOTES[mel]) {
        this.playBellNote(offlineCtx, master, this.NOTES[mel], t, 0.55, 0.24);
      }
      if (bas && this.NOTES[bas]) {
        this.playPizzicatoNote(offlineCtx, master, this.NOTES[bas], t, 0.28, 0.18);
      }
    }

    const renderedBuffer = await offlineCtx.startRendering();
    const wavBlob = this.audioBufferToWav(renderedBuffer);
    const url = URL.createObjectURL(wavBlob);
    const a = document.createElement('a');
    a.href = url;
    a.download = 'romantic-garden-bgm.wav';
    a.click();
    URL.revokeObjectURL(url);
  }

  private audioBufferToWav(buffer: AudioBuffer): Blob {
    const numOfChan = buffer.numberOfChannels;
    const length = buffer.length * numOfChan * 2 + 44;
    const out = new ArrayBuffer(length);
    const view = new DataView(out);
    const channels: Float32Array[] = [];
    let pos = 0;

    const setUint16 = (data: number) => { view.setUint16(pos, data, true); pos += 2; };
    const setUint32 = (data: number) => { view.setUint32(pos, data, true); pos += 4; };

    setUint32(0x46464952); // "RIFF"
    setUint32(length - 8);
    setUint32(0x45564157); // "WAVE"
    setUint32(0x20746d66); // "fmt "
    setUint32(16);
    setUint16(1);          // PCM
    setUint16(numOfChan);
    setUint32(buffer.sampleRate);
    setUint32(buffer.sampleRate * 2 * numOfChan);
    setUint16(numOfChan * 2);
    setUint16(16);
    setUint32(0x61746164); // "data"
    setUint32(length - pos - 4);

    for (let i = 0; i < numOfChan; i++) channels.push(buffer.getChannelData(i));

    let offset = 0;
    while (pos < length) {
      for (let i = 0; i < numOfChan; i++) {
        const sample = Math.max(-1, Math.min(1, channels[i][offset]));
        view.setInt16(pos, sample < 0 ? sample * 0x8000 : sample * 0x7FFF, true);
        pos += 2;
      }
      offset++;
    }
    return new Blob([out], { type: 'audio/wav' });
  }
}

export const gardenAudio = new KawaiiGardenAudio();