import SwiftUI
import UIKit

struct TimerView: View {
    enum Mode: String, CaseIterable, Hashable {
        case interval = "Интервалы"
        case rest = "Отдых"
        case stopwatch = "Секундомер"
    }

    private struct Preset: Identifiable {
        let name: String
        let work: Int
        let rest: Int
        let rounds: Int
        var id: String { name }
    }

    private let presets = [
        Preset(name: "Табата", work: 20, rest: 10, rounds: 8),
        Preset(name: "40 / 20", work: 40, rest: 20, rounds: 10),
        Preset(name: "EMOM", work: 60, rest: 0, rounds: 10),
        Preset(name: "Круги", work: 45, rest: 15, rounds: 6),
    ]
    private let restPresets = [30, 60, 90, 120, 180]

    @State private var mode: Mode = .interval
    @State private var engine = TimerEngine()
    @State private var stopwatch = Stopwatch()
    @State private var workSeconds = 40
    @State private var restSeconds = 20
    @State private var rounds = 8
    @State private var restPreset = 60

    private let ticker = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    private var isActive: Bool { engine.isRunning || stopwatch.isRunning }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                header

                VStack(spacing: 24) {
                    PillPicker(options: Mode.allCases, selection: $mode) { $0.rawValue }
                    ring
                    controls
                    settings
                    if mode == .stopwatch, !stopwatch.laps.isEmpty {
                        laps
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 32)
            }
        }
        .ignoresSafeArea(edges: .top)
        .sportScreen()
        .onAppear {
            engine.onEvent = { Haptics.play($0) }
            if engine.segments.isEmpty, mode != .stopwatch { configure() }
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
        }
        .onReceive(ticker) { _ in
            if engine.isRunning { engine.tick() }
            if stopwatch.isRunning { stopwatch.tick() }
        }
        .onChange(of: mode) { _, _ in configure() }
        .onChange(of: workSeconds) { _, _ in if mode == .interval { configure() } }
        .onChange(of: restSeconds) { _, _ in if mode == .interval { configure() } }
        .onChange(of: rounds) { _, _ in if mode == .interval { configure() } }
        .onChange(of: restPreset) { _, _ in if mode == .rest { configure() } }
        .onChange(of: isActive) { _, active in
            UIApplication.shared.isIdleTimerDisabled = active
        }
    }

    // MARK: Шапка

    private var header: some View {
        RemotePhoto(url: PhotoCatalog.url(.timer), symbol: "timer")
            .frame(height: 230)
            .overlay(PhotoScrim())
            .overlay(alignment: .bottomLeading) {
                ScreenTitle(title: "Таймер", subtitle: "Интервалы • отдых • секундомер")
                    .padding(20)
            }
    }

    // MARK: Кольцо

    private var ringColor: Color {
        if mode != .stopwatch, engine.current?.kind == .rest, !engine.isFinished {
            return Color.white
        }
        return Color.sportLime
    }

    private var ringProgress: Double {
        switch mode {
        case .stopwatch:
            return stopwatch.elapsed.truncatingRemainder(dividingBy: 60) / 60
        case .interval, .rest:
            return engine.isFinished ? 0 : engine.fractionRemaining
        }
    }

    private var phaseLabel: String {
        switch mode {
        case .stopwatch:
            return stopwatch.isRunning ? "Идёт" : (stopwatch.isIdle ? "Готов" : "Пауза")
        case .interval, .rest:
            if engine.isFinished { return "Готово!" }
            if engine.isIdle { return "Готов" }
            if !engine.isRunning { return "Пауза" }
            return engine.current?.kind == .rest ? "Отдых" : "Работа"
        }
    }

    private var timeText: String {
        mode == .stopwatch ? Format.stopwatch(stopwatch.elapsed) : Format.clock(engine.remaining)
    }

    private var subLabel: String {
        switch mode {
        case .stopwatch:
            return stopwatch.laps.isEmpty ? "Круги: 0" : "Круги: \(stopwatch.laps.count)"
        case .rest:
            return "Отдых между подходами"
        case .interval:
            guard let current = engine.current else { return " " }
            return "Раунд \(current.round) из \(current.totalRounds)"
        }
    }

    private var ring: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.1), lineWidth: 14)
            Circle()
                .trim(from: 0, to: ringProgress)
                .stroke(ringColor, style: StrokeStyle(lineWidth: 14, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.1), value: ringProgress)

            VStack(spacing: 6) {
                Eyebrow(text: phaseLabel, color: ringColor)
                Text(timeText)
                    .font(.sportNumber(mode == .stopwatch ? 60 : 76))
                    .foregroundStyle(Color.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                Text(subLabel)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.sportMuted)
            }
            .padding(.horizontal, 30)
        }
        .frame(maxWidth: 320)
        .aspectRatio(1, contentMode: .fit)
        .padding(10)
        .frame(maxWidth: .infinity)
    }

    // MARK: Кнопки

    private var primaryTitle: String {
        switch mode {
        case .stopwatch:
            return stopwatch.isRunning ? "ПАУЗА" : (stopwatch.isIdle ? "СТАРТ" : "ПРОДОЛЖИТЬ")
        case .interval, .rest:
            if engine.isFinished { return "ЗАНОВО" }
            if engine.isRunning { return "ПАУЗА" }
            return engine.isIdle ? "СТАРТ" : "ПРОДОЛЖИТЬ"
        }
    }

    private var controls: some View {
        HStack(spacing: 12) {
            Button("СБРОС") {
                reset()
            }
            .buttonStyle(GhostButtonStyle(compact: true))

            Button(primaryTitle) {
                togglePrimary()
            }
            .buttonStyle(LimeButtonStyle())

            switch mode {
            case .interval:
                Button("ДАЛЕЕ") { engine.skip() }
                    .buttonStyle(GhostButtonStyle(compact: true))
                    .disabled(engine.isFinished || engine.isIdle)
            case .rest:
                Button("+15 С") { engine.add(seconds: 15) }
                    .buttonStyle(GhostButtonStyle(compact: true))
                    .disabled(engine.isFinished)
            case .stopwatch:
                Button("КРУГ") { stopwatch.lap() }
                    .buttonStyle(GhostButtonStyle(compact: true))
                    .disabled(!stopwatch.isRunning)
            }
        }
    }

    // MARK: Настройки

    @ViewBuilder
    private var settings: some View {
        switch mode {
        case .interval:
            VStack(alignment: .leading, spacing: 14) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(presets) { preset in
                            Button {
                                workSeconds = preset.work
                                restSeconds = preset.rest
                                rounds = preset.rounds
                            } label: {
                                Chip(
                                    title: preset.name,
                                    isSelected: workSeconds == preset.work && restSeconds == preset.rest && rounds == preset.rounds
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.horizontal, -20)

                VStack(spacing: 0) {
                    ValueStepper(title: "Работа", value: $workSeconds, range: 5...300, step: 5, unit: "с")
                    Divider().overlay(Color.sportLine)
                    ValueStepper(title: "Отдых", value: $restSeconds, range: 0...300, step: 5, unit: "с")
                    Divider().overlay(Color.sportLine)
                    ValueStepper(title: "Раунды", value: $rounds, range: 1...30, step: 1, unit: "")
                }
                .padding(.horizontal, 16)
                .background(Color.sportCard, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(Color.sportLine, lineWidth: 1))

                Text("Всего: \(Format.clock(engine.totalDuration))")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.sportMuted)
            }
            .disabled(engine.isRunning)
            .opacity(engine.isRunning ? 0.5 : 1)

        case .rest:
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(restPresets, id: \.self) { seconds in
                        Button {
                            restPreset = seconds
                        } label: {
                            Chip(title: "\(seconds) с", isSelected: restPreset == seconds)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.horizontal, -20)
            .disabled(engine.isRunning)

        case .stopwatch:
            EmptyView()
        }
    }

    private var laps: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Круги")
            VStack(spacing: 0) {
                ForEach(Array(stopwatch.laps.enumerated()), id: \.offset) { offset, lap in
                    HStack {
                        Eyebrow(text: "Круг \(stopwatch.laps.count - offset)", color: .sportMuted)
                        Spacer()
                        Text(Format.stopwatch(lap))
                            .font(.sportNumber(20))
                            .foregroundStyle(Color.white)
                    }
                    .padding(.vertical, 12)
                    if offset < stopwatch.laps.count - 1 {
                        Divider().overlay(Color.sportLine)
                    }
                }
            }
            .padding(.horizontal, 16)
            .background(Color.sportCard, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
    }

    // MARK: Действия

    private func togglePrimary() {
        switch mode {
        case .stopwatch:
            stopwatch.toggle()
            Haptics.tap()
        case .interval, .rest:
            engine.toggle()
        }
    }

    private func reset() {
        switch mode {
        case .stopwatch: stopwatch.reset()
        case .interval, .rest: engine.reset()
        }
        Haptics.tap()
    }

    private func configure() {
        switch mode {
        case .interval:
            engine.load(TimerEngine.intervals(work: workSeconds, rest: restSeconds, rounds: rounds))
        case .rest:
            engine.load(TimerEngine.rest(seconds: restPreset))
        case .stopwatch:
            engine.load([])
        }
    }
}

/// Строка «название — − значение +».
struct ValueStepper: View {
    let title: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    let step: Int
    let unit: String

    var body: some View {
        HStack {
            Eyebrow(text: title, color: .sportMuted)
            Spacer()
            stepButton(systemName: "minus", delta: -step)
            Text(unit.isEmpty ? "\(value)" : "\(value) \(unit)")
                .font(.sportNumber(22))
                .foregroundStyle(Color.white)
                .frame(minWidth: 72)
            stepButton(systemName: "plus", delta: step)
        }
        .padding(.vertical, 10)
    }

    private func stepButton(systemName: String, delta: Int) -> some View {
        Button {
            value = min(range.upperBound, max(range.lowerBound, value + delta))
            Haptics.tap()
        } label: {
            Image(systemName: systemName)
                .font(.system(size: 14, weight: .black))
                .foregroundStyle(Color.sportLime)
                .frame(width: 36, height: 36)
                .background(Color.sportCardRaised, in: Circle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    TimerView()
        .environment(AppStore())
        .preferredColorScheme(.dark)
}
