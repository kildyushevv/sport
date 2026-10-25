// Сгенерировано tools/import_gifs.py — не редактируйте вручную.
// GIF — © Gym visual (https://gymvisual.com/), источник: github.com/hasaneyldrm/exercises-dataset.
// Условия использования: THIRD_PARTY_NOTICES.md.

enum ExerciseGifs {
    static let attribution = "© Gym visual — https://gymvisual.com/"

    /// Наш id упражнения → запись в датасете. Файл лежит в бандле как <id>.gif.
    static let sources: [String: GifSource] = [
        "bicycle-crunch": GifSource(datasetID: "0003", name: "air bike"),
        "burpee": GifSource(datasetID: "1160", name: "burpee"),
        "dead-bug": GifSource(datasetID: "0276", name: "dead bug"),
        "diamond-push-up": GifSource(datasetID: "0283", name: "diamond push-up"),
        "glute-bridge": GifSource(datasetID: "3013", name: "low glute bridge on floor"),
        "high-knees": GifSource(datasetID: "3221", name: "half knee bends (male)"),
        "hip-opener": GifSource(datasetID: "1604", name: "world greatest stretch"),
        "inchworm": GifSource(datasetID: "1471", name: "inchworm"),
        "jump-lunge": GifSource(datasetID: "3582", name: "lunge with jump"),
        "jumping-jacks": GifSource(datasetID: "3220", name: "astride jumps (male)"),
        "mountain-climbers": GifSource(datasetID: "0630", name: "mountain climber"),
        "push-up": GifSource(datasetID: "0662", name: "push-up"),
        "shadow-boxing": GifSource(datasetID: "2271", name: "left hook. boxing"),
        "side-plank": GifSource(datasetID: "0705", name: "side bridge v. 2"),
        "skater-jump": GifSource(datasetID: "3361", name: "skater hops"),
        "squat-jump": GifSource(datasetID: "0514", name: "jump squat"),
    ]
}
