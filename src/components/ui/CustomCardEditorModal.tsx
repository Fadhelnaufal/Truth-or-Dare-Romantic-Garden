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
