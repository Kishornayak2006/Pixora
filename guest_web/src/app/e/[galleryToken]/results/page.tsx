"use client";

import { useEffect, useState } from "react";

export default function ResultsPage() {
  const [matches, setMatches] = useState<any[]>([]);

  useEffect(() => {
    const storedMatches = sessionStorage.getItem("pixora_matches");

    if (storedMatches) {
      setMatches(JSON.parse(storedMatches));
    }
  }, []);

  return (
    <main className="min-h-screen bg-black text-white p-6">
      <h1 className="text-3xl font-bold mb-2">
        Your Photos
      </h1>

      <p className="text-zinc-400 mb-8">
        {matches.length} match{matches.length !== 1 ? "es" : ""} found
      </p>

      {matches.length === 0 ? (
        <div className="flex flex-col items-center justify-center py-20">
          <h2 className="text-2xl font-semibold">
            No Photos Found
          </h2>

          <p className="text-zinc-500 mt-3">
            We couldn't find any matching photos for your selfie.
          </p>
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {matches.map((photo: any) => (
            <div
              key={photo.photo_id}
              className="overflow-hidden rounded-2xl bg-zinc-900 border border-zinc-800"
            >
              <img
                src={`http://127.0.0.1:8000${photo.image_url}`}
                alt="Matched Photo"
                className="w-full h-72 object-cover"
              />

              <div className="p-4">
                <p className="font-semibold text-lg">
                  Similarity: {(photo.similarity * 100).toFixed(2)}%
                </p>

                {photo.confidence && (
                  <p className="text-green-400 mt-1">
                    {photo.confidence}
                  </p>
                )}

                <a
                  href={`http://127.0.0.1:8000${photo.image_url}`}
                  download
                  className="mt-5 inline-flex items-center justify-center w-full rounded-xl bg-blue-600 py-3 font-medium hover:bg-blue-700 transition"
                >
                  Download Photo
                </a>
              </div>
            </div>
          ))}
        </div>
      )}
    </main>
  );
}