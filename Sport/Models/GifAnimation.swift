import Foundation
import ImageIO
import UIKit

/// Источник GIF в датасете exercises-dataset (см. THIRD_PARTY_NOTICES.md).
struct GifSource: Hashable {
    let datasetID: String
    let name: String
}

/// Декодированный GIF: кадры и задержки между ними.
final class GifAnimation {
    let frames: [UIImage]
    /// Сколько секунд показывается каждый кадр.
    let delays: [Double]

    var duration: Double { delays.reduce(0, +) }

    init?(frames: [UIImage], delays: [Double]) {
        guard !frames.isEmpty, frames.count == delays.count else { return nil }
        self.frames = frames
        self.delays = delays
    }

    /// Индекс кадра в момент `time` (секунды); цикл повторяется.
    func frameIndex(at time: Double) -> Int {
        Self.frameIndex(delays: delays, at: time)
    }

    static func frameIndex(delays: [Double], at time: Double) -> Int {
        let total = delays.reduce(0, +)
        guard total > 0, !delays.isEmpty else { return 0 }

        var t = time.truncatingRemainder(dividingBy: total)
        if t < 0 { t += total }

        for (index, delay) in delays.enumerated() {
            if t < delay { return index }
            t -= delay
        }
        return delays.count - 1
    }

    // MARK: Загрузка

    private static let cache = NSCache<NSString, GifAnimation>()

    /// GIF упражнения из бандла (файл `<id>.gif`) или `nil`, если для него нет GIF.
    static func load(exerciseID: String, bundle: Bundle = .main) -> GifAnimation? {
        guard ExerciseGifs.sources[exerciseID] != nil else { return nil }

        let key = exerciseID as NSString
        if let cached = cache.object(forKey: key) { return cached }

        guard let url = bundle.url(forResource: exerciseID, withExtension: "gif"),
              let animation = decode(url: url)
        else { return nil }

        cache.setObject(animation, forKey: key)
        return animation
    }

    static func decode(url: URL) -> GifAnimation? {
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else { return nil }

        let count = CGImageSourceGetCount(source)
        var frames: [UIImage] = []
        var delays: [Double] = []

        for index in 0..<count {
            guard let image = CGImageSourceCreateImageAtIndex(source, index, nil) else { continue }
            frames.append(UIImage(cgImage: image))
            delays.append(delay(source: source, index: index))
        }
        return GifAnimation(frames: frames, delays: delays)
    }

    private static func delay(source: CGImageSource, index: Int) -> Double {
        let properties = CGImageSourceCopyPropertiesAtIndex(source, index, nil) as? [CFString: Any]
        let gif = properties?[kCGImagePropertyGIFDictionary] as? [CFString: Any]
        let value = (gif?[kCGImagePropertyGIFUnclampedDelayTime] as? Double)
            ?? (gif?[kCGImagePropertyGIFDelayTime] as? Double)
            ?? 0.1
        // Слишком короткие задержки браузеры трактуют как 100 мс.
        return value < 0.02 ? 0.1 : value
    }
}
