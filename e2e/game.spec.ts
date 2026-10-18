import { test, expect } from '@playwright/test';

test.describe('Truth or Dare: A Romantic Garden Adventure E2E', () => {
  test('loads interface, rolls die, resolves Truth card, and reaches deterministic victory', async ({
    page,
  }) => {
    await page.goto('/');

    await expect(
      page.getByText('Truth or Dare: Romantic Garden')
    ).toBeVisible();
    const rollBtn = page.getByTestId('roll-dice-btn');
    await expect(rollBtn).toBeVisible();
    await expect(rollBtn).toBeEnabled();

    await page.evaluate(() => {
      const store = (
        window as unknown as {
          __GAME_STORE__: {
            getState: () => {
              setReducedMotion: (v: boolean) => void;
              rollDice: (v: number) => void;
            };
          };
        }
      ).__GAME_STORE__;
      store.getState().setReducedMotion(true);
      store.getState().rollDice(2);
    });

    const challengeModal = page.getByTestId('challenge-card-modal');
    await expect(challengeModal).toBeVisible({ timeout: 6000 });
    await expect(page.getByTestId('challenge-prompt-text')).not.toBeEmpty();

    await page.getByTestId('skip-challenge-btn').click();
    await expect(challengeModal).toBeHidden();

    await expect(page.getByTestId('active-player-indicator')).toContainText(
      'Sayang 2'
    );

    await page.evaluate(() => {
      const store = (
        window as unknown as {
          __GAME_STORE__: {
            getState: () => {
              setDebugPlayerSquare: (idx: number, sq: number) => void;
              rollDice: (v: number) => void;
            };
          };
        }
      ).__GAME_STORE__;
      store.getState().setDebugPlayerSquare(1, 98);
      store.getState().rollDice(2);
    });

    const victoryModal = page.getByTestId('victory-modal');
    await expect(victoryModal).toBeVisible({ timeout: 6000 });
    await expect(victoryModal).toContainText('Memenangkan Petualangan');

    await page.getByTestId('victory-replay-btn').click();
    await expect(victoryModal).toBeHidden();
    await expect(page.getByTestId('player-square-0')).toHaveText('#1');
  });
});
