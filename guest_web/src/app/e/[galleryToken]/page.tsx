import Link from "next/link";

interface Props {
  params: Promise<{
    galleryToken: string;
  }>;
}

export default async function EventPage({ params }: Props) {
  const { galleryToken } = await params;

  const response = await fetch(
    `http://127.0.0.1:8000/api/v1/gallery/${galleryToken}`,
    {
      cache: "no-store",
    }
  );

  if (!response.ok) {
    return (
      <main className="min-h-screen flex items-center justify-center bg-black text-white">
        Failed to load event.
      </main>
    );
  }

  const data = await response.json();

  return (
    <main className="min-h-screen bg-black text-white">

      {/* HERO */}
      <section className="relative h-[58vh] min-h-[420px] overflow-hidden">

        {data.cover_image ? (
        <img
            src={data.cover_image}
            alt={data.event_name}
            className="absolute inset-0 w-full h-full object-cover"
        />
        ) : data.photos.length > 0 ? (
        <img
            src={data.photos[0].image_url}
            alt={data.event_name}
            className="absolute inset-0 w-full h-full object-cover"
        />
        ) : (
        <div className="absolute inset-0 bg-zinc-900" />
        )}
        {/* Professional Gradient */}
        <div className="absolute inset-0 bg-gradient-to-t from-black via-black/45 to-transparent" />

        <div className="absolute bottom-0 left-0 right-0 p-7">

          <div className="inline-flex items-center rounded-full border border-white/20 bg-white/10 backdrop-blur-md px-4 py-2 text-sm">
            📸 Powered by <span className="ml-2 font-semibold">Pixora</span>
          </div>

          <h1 className="mt-5 text-4xl md:text-5xl font-extrabold leading-tight">
            {data.event_name}
          </h1>

          <p className="mt-3 max-w-xl text-zinc-300 text-lg">
            Find every professional photo you're in using AI face recognition.
          </p>

        </div>

      </section>

      {/* CONTENT */}
      <section className="mx-auto max-w-5xl px-6 py-8">

        {/* CTA */}
        <Link
          href={`/e/${galleryToken}/selfie?eventId=${data.event_id}`}
          className="block"
        >
          <button className="w-full rounded-2xl bg-blue-600 py-5 text-lg font-semibold transition duration-300 hover:bg-blue-700 hover:shadow-xl active:scale-[0.98]">
            📸 Find My Photos
          </button>
        </Link>

        {/* HOW IT WORKS */}
        <div className="mt-10 rounded-3xl border border-zinc-800 bg-zinc-900 p-8">

          <h2 className="text-2xl font-bold">
            Find your photos in seconds
          </h2>

          <div className="mt-8 grid gap-8 md:grid-cols-3">

            <div>
              <div className="text-5xl">📱</div>
              <h3 className="mt-4 text-lg font-semibold">
                Take a Selfie
              </h3>

              <p className="mt-2 text-zinc-400">
                Capture a live selfie securely from your device.
              </p>
            </div>

            <div>
              <div className="text-5xl">🤖</div>
              <h3 className="mt-4 text-lg font-semibold">
                AI Search
              </h3>

              <p className="mt-2 text-zinc-400">
                Pixora AI instantly searches thousands of event photos.
              </p>
            </div>

            <div>
              <div className="text-5xl">⬇️</div>
              <h3 className="mt-4 text-lg font-semibold">
                Download
              </h3>

              <p className="mt-2 text-zinc-400">
                View and download your professional photos instantly.
              </p>
            </div>

          </div>

          <p className="mt-8 text-center text-sm text-zinc-500">
            🔒 Your selfie is only used to find your photos and is never shared.
          </p>

        </div>

        {/* STATS */}
        <div className="mt-10 grid gap-5 md:grid-cols-3">

          <div className="rounded-2xl border border-zinc-800 bg-zinc-900 p-6">

            <p className="text-3xl font-bold">
              {data.photos.length}
            </p>

            <p className="mt-2 text-zinc-400">
              Professional Photos
            </p>

          </div>

          <div className="rounded-2xl border border-zinc-800 bg-zinc-900 p-6">

            <p className="text-3xl font-bold">
              AI
            </p>

            <p className="mt-2 text-zinc-400">
              Face Recognition
            </p>

          </div>

          <div className="rounded-2xl border border-zinc-800 bg-zinc-900 p-6">

            <p className="text-3xl font-bold">
              100%
            </p>

            <p className="mt-2 text-zinc-400">
              Private Search
            </p>

          </div>

        </div>

      </section>

    </main>
  );
}