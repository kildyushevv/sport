import SwiftUI

/// Фотография по URL. Пока снимок грузится или недоступен, показывается тёмная заглушка
/// с лаймовым оттенком, поэтому интерфейс выглядит цельно даже без сети.
struct RemotePhoto: View {
    let url: URL?
    var symbol: String = "figure.strengthtraining.traditional"

    var body: some View {
        Color.clear
            .overlay {
                AsyncImage(url: url, transaction: Transaction(animation: .easeOut(duration: 0.3))) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    default:
                        PhotoPlaceholder(symbol: symbol)
                    }
                }
            }
            .clipped()
    }
}

private struct PhotoPlaceholder: View {
    let symbol: String

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: 0x24300A), Color(hex: 0x0B0B0B)],
                startPoint: .topTrailing,
                endPoint: .bottomLeading
            )
            Image(systemName: symbol)
                .font(.system(size: 56, weight: .bold))
                .foregroundStyle(Color.sportLime.opacity(0.3))
        }
    }
}

/// Затемнение снизу вверх, чтобы белый текст читался на любой фотографии.
struct PhotoScrim: View {
    var body: some View {
        LinearGradient(
            stops: [
                .init(color: Color.black.opacity(0.15), location: 0),
                .init(color: Color.black.opacity(0.35), location: 0.45),
                .init(color: Color.black.opacity(0.92), location: 1),
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .allowsHitTesting(false)
    }
}

/// Фото-карточка с крупным заголовком поверх снимка.
struct PhotoCard: View {
    let url: URL?
    var symbol: String = "figure.strengthtraining.traditional"
    var eyebrow: String? = nil
    let title: String
    var detail: String? = nil
    var height: CGFloat = 180
    var titleSize: CGFloat = 26

    var body: some View {
        RemotePhoto(url: url, symbol: symbol)
            .frame(height: height)
            .overlay(PhotoScrim())
            .overlay(alignment: .bottomLeading) {
                VStack(alignment: .leading, spacing: 4) {
                    if let eyebrow {
                        Eyebrow(text: eyebrow)
                    }
                    Text(title.uppercased())
                        .font(.sportDisplay(titleSize))
                        .tracking(-0.5)
                        .foregroundStyle(Color.white)
                        .lineLimit(2)
                        .minimumScaleFactor(0.7)
                        .multilineTextAlignment(.leading)
                    if let detail {
                        Text(detail)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color.white.opacity(0.75))
                    }
                }
                .padding(16)
            }
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}
