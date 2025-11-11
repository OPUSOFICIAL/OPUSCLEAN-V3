import { useState, useEffect } from 'react';

interface LogoImageProps {
  src: string | null | undefined;
  fallbackSrc: string;
  alt: string;
  className?: string;
  'data-testid'?: string;
}

/**
 * Logo image component with automatic fallback handling
 * - Shows primary logo from branding if available
 * - Falls back to default logo if primary fails to load or is null
 * - Handles errors gracefully without showing broken images
 * - Resets error state when src changes (for tenant switching)
 */
export function LogoImage({ src, fallbackSrc, alt, className, 'data-testid': testId }: LogoImageProps) {
  const [error, setError] = useState(false);

  // Reset error state whenever src changes (critical for tenant switching)
  useEffect(() => {
    setError(false);
  }, [src]);

  // Use fallback if no src provided or if image failed to load
  const effectiveSrc = !src || error ? fallbackSrc : src;

  return (
    <img
      src={effectiveSrc}
      alt={alt}
      className={className}
      data-testid={testId}
      onError={() => setError(true)}
    />
  );
}
