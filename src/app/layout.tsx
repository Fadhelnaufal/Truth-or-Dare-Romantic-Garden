import type { Metadata } from 'next';
import './globals.css';

export const metadata: Metadata = {
  title: 'Truth or Dare: A Romantic Garden Adventure — 3D Snakes & Ladders',
  description:
    'Permainan papan Ular Tangga 3D romantis dengan kartu Truth or Dare Bahasa Indonesia untuk pasangan.',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="id">
      <body className="antialiased selection:bg-garden-rose selection:text-white">
        {children}
      </body>
    </html>
  );
}
