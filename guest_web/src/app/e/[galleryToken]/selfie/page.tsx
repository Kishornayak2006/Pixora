"use client";

import { useEffect, useRef, useState } from "react";
import { useParams, useRouter, useSearchParams } from "next/navigation";

export default function SelfiePage() {
  const videoRef = useRef<HTMLVideoElement>(null);
  const canvasRef = useRef<HTMLCanvasElement>(null);

  const router = useRouter();
  const params = useParams();
  const searchParams = useSearchParams();

  const galleryToken = params.galleryToken as string;
  const eventId = searchParams.get("eventId");

  const [isSearching, setIsSearching] = useState(false);

  useEffect(() => {
    let stream: MediaStream;

    async function startCamera() {
      try {
        stream = await navigator.mediaDevices.getUserMedia({
          video: {
            facingMode: "user",
          },
          audio: false,
        });

        if (videoRef.current) {
          videoRef.current.srcObject = stream;
        }
      } catch (error) {
        console.error(error);
        alert("Unable to access camera.");
      }
    }

    startCamera();

    return () => {
      stream?.getTracks().forEach((track) => track.stop());
    };
  }, []);

  async function capturePhoto() {
    if (!videoRef.current || !canvasRef.current || !eventId) return;

    setIsSearching(true);

    const video = videoRef.current;
    const canvas = canvasRef.current;

    canvas.width = video.videoWidth;
    canvas.height = video.videoHeight;

    const ctx = canvas.getContext("2d");

    if (!ctx) {
      setIsSearching(false);
      return;
    }

    ctx.drawImage(video, 0, 0);

    const blob = await new Promise<Blob | null>((resolve) => {
      canvas.toBlob(resolve, "image/jpeg", 0.95);
    });

    if (!blob) {
      setIsSearching(false);
      return;
    }

    const formData = new FormData();
    formData.append("selfie", blob, "selfie.jpg");

    try {
      const response = await fetch(
        `http://127.0.0.1:8000/ai/events/${eventId}/search`,
        {
          method: "POST",
          body: formData,
        }
      );

      if (!response.ok) {
        throw new Error("Face search failed");
      }

      const data = await response.json();

      // Store matches temporarily
      sessionStorage.setItem(
        "pixora_matches",
        JSON.stringify(data.matches)
      );

      router.push(`/e/${galleryToken}/results`);
    } catch (error) {
      console.error(error);
      alert("Face search failed.");
      setIsSearching(false);
    }
  }

  return (
    <main className="relative min-h-screen bg-black flex flex-col">
      <video
        ref={videoRef}
        autoPlay
        muted
        playsInline
        className="flex-1 object-cover"
      />

      <canvas ref={canvasRef} className="hidden" />

      <div className="p-8 flex justify-center">
        <button
          onClick={capturePhoto}
          disabled={isSearching}
          className="w-20 h-20 rounded-full border-4 border-white bg-white/20 active:scale-95 transition"
        />
      </div>

      {isSearching && (
        <div className="absolute inset-0 bg-black/90 flex flex-col items-center justify-center">
          <div className="w-16 h-16 rounded-full border-4 border-white border-t-transparent animate-spin" />

          <h2 className="mt-8 text-2xl font-bold text-white">
            Searching your photos...
          </h2>

          <p className="mt-2 text-zinc-400">
            Please wait a few seconds
          </p>
        </div>
      )}
    </main>
  );
}