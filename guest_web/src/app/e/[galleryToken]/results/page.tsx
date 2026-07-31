"use client";

import { useEffect, useState } from "react";
import Image from "next/image";

interface PhotoMatch {
  photo_id: string | number;
  image_url: string;
  similarity: number;
  confidence?: string;
}

export default function ResultsPage() {
  const [matches, setMatches] = useState<PhotoMatch[]>([]);
  const [selectedIndex, setSelectedIndex] = useState<number | null>(null);

  useEffect(() => {
    const storedMatches = sessionStorage.getItem("pixora_matches");
    if (storedMatches) {
      try {
        setMatches(JSON.parse(storedMatches));
      } catch (error) {
        console.error("Failed to parse stored matches:", error);
      }
    }
  }, []);

  // Keyboard navigation for full-screen preview
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (selectedIndex === null) return;

      if (e.key === "Escape") {
        setSelectedIndex(null);
      }
      if (e.key === "ArrowRight") {
        nextPhoto();
      }
      if (e.key === "ArrowLeft") {
        previousPhoto();
      }
    };

    window.addEventListener("keydown", handleKeyDown);
    return () => {
      window.removeEventListener("keydown", handleKeyDown);
    };
  }, [selectedIndex, matches]);

  const nextPhoto = () => {
    if (selectedIndex === null || matches.length === 0) return;
    setSelectedIndex((prevIndex) =>
      prevIndex !== null && prevIndex < matches.length - 1 ? prevIndex + 1 : 0
    );
  };

  const previousPhoto = () => {
    if (selectedIndex === null || matches.length === 0) return;
    setSelectedIndex((prevIndex) =>
      prevIndex !== null && prevIndex > 0 ? prevIndex - 1 : matches.length - 1
    );
  };

  const downloadPhoto = async (photo: PhotoMatch) => {
    const imageUrl = `http://127.0.0.1:8000${photo.image_url}`;
    try {
      const response = await fetch(imageUrl);
      const blob = await response.blob();
      const blobUrl = window.URL.createObjectURL(blob);
      
      const link = document.createElement("a");
      link.href = blobUrl;
      link.download = `pixora_photo_${photo.photo_id}.jpg`;
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
      window.URL.revokeObjectURL(blobUrl);
    } catch (error) {
      console.error("Download failed, opening direct link instead:", error);
      window.open(imageUrl, "_blank");
    }
  };

  return (
    <main className="min-h-screen bg-gradient-to-b from-black via-zinc-950 to-black text-white px-6 py-10">
      {/* Brand Header */}
      <div className="mb-12 flex flex-col items-center text-center">
        <Image
          src="/logo.png"
          alt="Pixora"
          width={180}
          height={180}
          className="mb-5 object-contain"
          priority
        />
        <h1 className="text-4xl font-extrabold tracking-tight">Your Photos</h1>
        <p className="mt-3 text-lg text-zinc-400">
          {matches.length} match{matches.length !== 1 ? "es" : ""} found
        </p>
      </div>

      {/* Main Content Area */}
      {matches.length === 0 ? (
        <div className="flex flex-col items-center justify-center py-24 text-center">
          <div className="mb-6 text-7xl select-none">📷</div>
          <h2 className="text-3xl font-bold">No Photos Found</h2>
          <p className="mt-4 max-w-md text-zinc-400">
            We couldn't find any photos matching your selfie. Try taking another
            selfie with your face clearly visible.
          </p>
        </div>
      ) : (
        <div className="grid grid-cols-1 gap-8 md:grid-cols-2 xl:grid-cols-3">
          {matches.map((photo, index) => (
            <div
              key={photo.photo_id || index}
              className="group relative overflow-hidden rounded-3xl bg-zinc-900/80 border border-zinc-800 shadow-xl hover:shadow-blue-600/20 hover:border-blue-500 transition-all duration-300"
            >
              {/* Photo */}
              <img
                src={`http://127.0.0.1:8000${photo.image_url}`}
                alt="Matched Photo"
                className="w-full h-72 object-cover cursor-pointer transition-transform duration-500 group-hover:scale-110"
                onClick={() => setSelectedIndex(index)}
              />

              {/* Similarity Badge */}
              <div className="absolute top-4 left-4 rounded-full bg-blue-600/90 backdrop-blur px-3 py-1 text-sm font-semibold text-white shadow-md select-none">
                {(photo.similarity * 100).toFixed(1)}% Match
              </div>

              {/* Card Details */}
              <div className="p-5">
                <p className="text-xl font-bold text-white">
                  Similarity: {(photo.similarity * 100).toFixed(2)}%
                </p>

                {photo.confidence && (
                  <p className="mt-2 text-emerald-400 font-medium">
                    {photo.confidence}
                  </p>
                )}

                <button
                  onClick={() => downloadPhoto(photo)}
                  className="mt-6 flex w-full items-center justify-center rounded-2xl bg-gradient-to-r from-blue-600 to-indigo-600 py-3 font-semibold text-white transition-all duration-300 hover:scale-[1.02] hover:from-blue-500 hover:to-indigo-500 active:scale-[0.98]"
                >
                  Download Photo
                </button>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Full-Screen Lightbox Preview */}
      {selectedIndex !== null && matches[selectedIndex] && (
        <div className="fixed inset-0 z-50 bg-black/95 backdrop-blur-md flex items-center justify-center p-4">
          {/* Close Button */}
          <button
            onClick={() => setSelectedIndex(null)}
            aria-label="Close preview"
            className="absolute top-6 right-6 z-10 text-white text-4xl hover:text-red-400 transition cursor-pointer leading-none p-2"
          >
            ×
          </button>

          {/* Previous Arrow */}
          {matches.length > 1 && (
            <button
              onClick={previousPhoto}
              aria-label="Previous photo"
              className="absolute left-6 z-10 text-5xl text-white hover:text-blue-400 transition cursor-pointer select-none p-2"
            >
              ❮
            </button>
          )}

          {/* Main Image Container */}
          <div className="max-w-6xl w-full px-4 md:px-10 flex flex-col items-center">
            <img
              src={`http://127.0.0.1:8000${matches[selectedIndex].image_url}`}
              alt="Full Preview"
              className="max-h-[75vh] w-auto max-w-full object-contain rounded-2xl shadow-2xl"
            />

            <div className="mt-6 flex flex-col md:flex-row items-center justify-between gap-4 w-full max-w-2xl bg-zinc-900/60 p-4 rounded-2xl border border-zinc-800/80">
              <div className="text-center md:text-left">
                <h3 className="text-2xl font-bold">
                  Similarity: {(matches[selectedIndex].similarity * 100).toFixed(2)}%
                </h3>

                {matches[selectedIndex].confidence && (
                  <p className="text-emerald-400 mt-1 font-medium">
                    {matches[selectedIndex].confidence}
                  </p>
                )}
              </div>

              <button
                onClick={() => downloadPhoto(matches[selectedIndex])}
                className="rounded-xl bg-gradient-to-r from-blue-600 to-indigo-600 px-8 py-3 font-semibold text-white transition-all hover:scale-105 active:scale-95"
              >
                Download Photo
              </button>
            </div>
          </div>

          {/* Next Arrow */}
          {matches.length > 1 && (
            <button
              onClick={nextPhoto}
              aria-label="Next photo"
              className="absolute right-6 z-10 text-5xl text-white hover:text-blue-400 transition cursor-pointer select-none p-2"
            >
              ❯
            </button>
          )}
        </div>
      )}
    </main>
  );
}