interface Props {
  params: Promise<{
    galleryToken: string;
  }>;
}
import Link from "next/link";

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
    <main className="min-h-screen bg-black text-white p-6 flex justify-center items-center">
      <div className="max-w-md w-full bg-zinc-900 rounded-3xl overflow-hidden shadow-xl">

        {data.photos.length > 0 && (
          <img
            src={data.photos[0].image_url}
            alt={data.event_name}
            className="w-full h-72 object-cover"
          />
        )}

        <div className="p-6">

          <h1 className="text-3xl font-bold">
            {data.event_name}
          </h1>

          <p className="text-zinc-400 mt-2">
            {data.photos.length} Photos Available
          </p>

          <Link href={`/e/${galleryToken}/selfie?eventId=${data.event_id}`}>
            <button className="mt-8 w-full rounded-xl bg-blue-600 py-4 font-semibold hover:bg-blue-700 transition">
                Take Live Selfie
            </button>
            </Link>

        </div>

      </div>
    </main>
  );
}