import type { Config } from 'tailwindcss';

const config: Config = {
  content: [
    './src/pages/**/*.{js,ts,jsx,tsx,mdx}',
    './src/components/**/*.{js,ts,jsx,tsx,mdx}',
    './src/app/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      colors: {
        garden: {
          blush: '#F4D7DE',
          ivory: '#FFF7ED',
          rose: '#C98296',
          gold: '#C99A72',
          sage: '#A9B9A0',
          lavender: '#DCD5F0',
          cream: '#FFFDF8',
          mauve: '#654754',
          deepMauve: '#47303A',
        },
      },
      fontFamily: {
        serif: ['Georgia', 'Cambria', '"Times New Roman"', 'Times', 'serif'],
        sans: ['Inter', 'system-ui', '-apple-system', 'sans-serif'],
      },
      boxShadow: {
        romantic: '0 12px 32px -8px rgba(101, 71, 84, 0.18)',
        card: '0 20px 50px -12px rgba(101, 71, 84, 0.28)',
      },
    },
  },
  plugins: [],
};

export default config;
