import numpy as np


def cosine_similarity(vec1: list[float], vec2: list[float]) -> float:
    """
    Compute cosine similarity between two embeddings.
    Returns a value between -1 and 1.
    """

    a = np.asarray(vec1, dtype=np.float32)
    b = np.asarray(vec2, dtype=np.float32)

    denominator = np.linalg.norm(a) * np.linalg.norm(b)

    if denominator == 0:
        return 0.0

    return float(np.dot(a, b) / denominator)


def rank_matches(
    query_embedding: list[float],
    candidates: list[tuple[int, list[float]]],
    threshold: float = 0.60,
):
    best_matches = {}

    for photo_id, embedding in candidates:

        score = cosine_similarity(
            query_embedding,
            embedding,
        )

        if score < threshold:
            continue

        if (
            photo_id not in best_matches
            or score > best_matches[photo_id]
        ):
            best_matches[photo_id] = score

    matches = [
        {
            "photo_id": photo_id,
            "score": round(score, 4),
        }
        for photo_id, score in best_matches.items()
    ]

    matches.sort(
        key=lambda x: x["score"],
        reverse=True,
    )

    return matches