import Foundation

/// Единственное место, где описаны адреса спортивных фотографий.
///
/// Снимки берутся с Unsplash по прямым ссылкам. Идентификаторы **не проверялись** на доступность:
/// если какая-то ссылка устарела, `RemotePhoto` покажет тёмную градиентную заглушку,
/// а заменить снимок можно, поправив одну строку ниже. Чтобы перейти на локальные файлы,
/// добавьте изображения в `Assets.xcassets` и замените `RemotePhoto` на `Image("имя")`.
enum PhotoCatalog {
    enum Key: String, CaseIterable, Hashable {
        case hero, chest, back, legs, shoulders, arms, core, cardio, mobility
        case timer, history, progress
    }

    private static let ids: [Key: String] = [
        .hero: "photo-1534438327276-14e5300c3a48",
        .chest: "photo-1571019613454-1cb2f99b2d8b",
        .back: "photo-1583454110551-21f2fa2afe61",
        .legs: "photo-1574680096145-d05b474e2155",
        .shoulders: "photo-1581009146145-b5ef050c2e1e",
        .arms: "photo-1526506118085-60ce8714f8c5",
        .core: "photo-1517836357463-d25dfeac3438",
        .cardio: "photo-1552674605-db6ffd4facb5",
        .mobility: "photo-1544367567-0f2fcb009e0b",
        .timer: "photo-1517963879433-6ad2b056d712",
        .history: "photo-1541534741688-6078c6bfb5c5",
        .progress: "photo-1549060279-7e168fcee0c2",
    ]

    static func url(_ key: Key, width: Int = 1000) -> URL? {
        guard let id = ids[key] else { return nil }
        return URL(string: "https://images.unsplash.com/\(id)?auto=format&fit=crop&w=\(width)&q=75")
    }
}
