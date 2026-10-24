import Foundation

extension Calendar {
    /// Григорианский календарь с понедельника как началом недели и русской локалью.
    static let sport: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "ru_RU")
        calendar.firstWeekday = 2
        calendar.minimumDaysInFirstWeek = 4
        return calendar
    }()
}

/// Простой детерминированный генератор: графики выглядят правдоподобно и не меняются между запусками.
struct SeededRandom {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    /// Число в диапазоне 0..<1.
    mutating func next() -> Double {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return Double(state >> 11) / Double(1 << 53)
    }
}

/// Все демонстрационные данные приложения.
enum DemoData {

    // MARK: Упражнения

    private static func exercise(
        _ id: String,
        _ name: String,
        _ group: MuscleGroup,
        secondary: String,
        equipment: String,
        _ difficulty: Difficulty,
        measure: Measure = .reps,
        weighted: Bool = false,
        summary: String,
        steps: [String],
        tips: [String]
    ) -> Exercise {
        Exercise(
            id: id, name: name, group: group, secondary: secondary, equipment: equipment,
            difficulty: difficulty, measure: measure, isWeighted: weighted,
            summary: summary, steps: steps, tips: tips
        )
    }

    static let exercises: [Exercise] = [
        // Грудь
        exercise("bench-press", "Жим штанги лёжа", .chest,
                 secondary: "Передние дельты, трицепс", equipment: "Штанга, скамья", .intermediate, weighted: true,
                 summary: "Базовое упражнение для силы и массы грудных мышц.",
                 steps: ["Лягте на скамью, лопатки сведите и прижмите к скамье.",
                         "Снимите штангу и опустите её к нижней части груди.",
                         "Мощно выжмите штангу вверх, не отрывая таз от скамьи."],
                 tips: ["Стопы упирайте в пол — это даёт устойчивость.",
                        "Запястья держите над локтями, гриф — на основании ладони."]),
        exercise("incline-db-press", "Жим гантелей на наклонной", .chest,
                 secondary: "Передние дельты, трицепс", equipment: "Гантели, наклонная скамья", .intermediate, weighted: true,
                 summary: "Смещает акцент на верх груди и даёт большую амплитуду, чем штанга.",
                 steps: ["Установите скамью под углом 30°, гантели держите на уровне груди.",
                         "Выжмите гантели вверх по лёгкой дуге до сведения над грудью.",
                         "Медленно опустите, чувствуя растяжение грудных."],
                 tips: ["Угол больше 45° переносит нагрузку на плечи.",
                        "Опускайте за 2–3 секунды."]),
        exercise("push-up", "Отжимания", .chest,
                 secondary: "Трицепс, плечи, кор", equipment: "Свой вес", .beginner,
                 summary: "Классика, которая работает почти без оборудования.",
                 steps: ["Упор лёжа, ладони чуть шире плеч, тело — прямая линия.",
                         "Опуститесь до касания грудью пола или почти до него.",
                         "Вытолкните себя вверх до выпрямления рук."],
                 tips: ["Не прогибайте поясницу — напрягите пресс и ягодицы.",
                        "Локти держите под углом около 45° к корпусу."]),
        exercise("dips", "Отжимания на брусьях", .chest,
                 secondary: "Трицепс, передние дельты", equipment: "Брусья", .intermediate,
                 summary: "Тяжёлое упражнение с собственным весом для груди и трицепса.",
                 steps: ["Обопритесь на брусья на прямых руках, корпус слегка наклоните вперёд.",
                         "Опуститесь, пока плечи не окажутся на уровне локтей.",
                         "Выжмите себя вверх, не блокируя локти полностью."],
                 tips: ["Больше наклон вперёд — больше работает грудь.",
                        "Не опускайтесь слишком глубоко, если болят плечи."]),
        exercise("db-fly", "Разводка гантелей лёжа", .chest,
                 secondary: "Передние дельты", equipment: "Гантели, скамья", .beginner, weighted: true,
                 summary: "Изолирующее упражнение на растяжение и сведение грудных.",
                 steps: ["Лёжа на скамье, держите гантели над грудью, локти чуть согнуты.",
                         "Разведите руки в стороны по широкой дуге до растяжения в груди.",
                         "Сведите гантели обратно, как будто обнимаете большое дерево."],
                 tips: ["Угол в локтях не меняйте на протяжении всего подхода.",
                        "Берите вес меньше, чем в жиме."]),

        // Спина
        exercise("deadlift", "Становая тяга", .back,
                 secondary: "Ягодицы, бицепс бедра, трапеции", equipment: "Штанга", .advanced, weighted: true,
                 summary: "Король силовых упражнений: работает вся задняя цепь.",
                 steps: ["Встаньте так, чтобы гриф был над серединой стопы, возьмитесь хватом на ширине плеч.",
                         "Напрягите спину и оторвите штангу от пола, толкаясь ногами.",
                         "Выпрямитесь в верхней точке и контролируемо верните штангу на пол."],
                 tips: ["Штанга всё время скользит рядом с голенями и бёдрами.",
                        "Спина остаётся нейтральной — не округляйте поясницу."]),
        exercise("pull-up", "Подтягивания", .back,
                 secondary: "Бицепс, предплечья", equipment: "Турник", .intermediate,
                 summary: "Лучший тест верхней части тела и главное упражнение на широчайшие.",
                 steps: ["Повисните на турнике хватом чуть шире плеч.",
                         "Подтянитесь, ведя локти вниз и к корпусу, пока подбородок не окажется над перекладиной.",
                         "Медленно опуститесь до полного выпрямления рук."],
                 tips: ["Не раскачивайтесь — работайте строго.",
                        "Если не хватает силы, используйте резиновую петлю."]),
        exercise("bent-row", "Тяга штанги в наклоне", .back,
                 secondary: "Бицепс, задние дельты", equipment: "Штанга", .intermediate, weighted: true,
                 summary: "Толщина спины: средняя часть трапеций, ромбовидные, широчайшие.",
                 steps: ["Наклонитесь с прямой спиной почти до параллели корпуса с полом.",
                         "Тяните штангу к низу живота, сводя лопатки.",
                         "Опустите штангу без рывка."],
                 tips: ["Колени слегка согнуты, взгляд направлен вниз и вперёд.",
                        "Не помогайте себе рывком корпуса."]),
        exercise("lat-pulldown", "Тяга верхнего блока", .back,
                 secondary: "Бицепс", equipment: "Блочный тренажёр", .beginner, weighted: true,
                 summary: "Удобная замена подтягиваниям с точной регулировкой веса.",
                 steps: ["Сядьте, зафиксируйте бёдра под валиками, возьмитесь за рукоять широким хватом.",
                         "Потяните рукоять к верху груди, отводя локти вниз.",
                         "Верните рукоять вверх, не отрывая спину от нейтрали."],
                 tips: ["Не тяните за голову.",
                        "Грудь держите раскрытой, а лопатки — опущенными."]),

        // Ноги
        exercise("squat", "Приседания со штангой", .legs,
                 secondary: "Ягодицы, кор, поясница", equipment: "Штанга, стойки", .advanced, weighted: true,
                 summary: "Основа развития силы и массы ног.",
                 steps: ["Положите штангу на верх трапеций, встаньте на ширину плеч.",
                         "Присядьте до параллели бёдер с полом, колени идут по линии носков.",
                         "Встаньте, толкаясь всей стопой."],
                 tips: ["Вдох и напряжение пресса перед каждым повторением.",
                        "Пятки остаются на полу в течение всего движения."]),
        exercise("rdl", "Румынская тяга", .legs,
                 secondary: "Ягодицы, поясница", equipment: "Штанга", .intermediate, weighted: true,
                 summary: "Растягивает и укрепляет бицепсы бёдер и ягодичные.",
                 steps: ["Встаньте со штангой в руках, колени слегка согнуты.",
                         "Отведите таз назад, ведя штангу вдоль ног, пока не почувствуете растяжение сзади бёдер.",
                         "Выпрямитесь, сжав ягодицы."],
                 tips: ["Спина остаётся ровной, штанга ближе к ногам.",
                        "Движение идёт от таза, а не от поясницы."]),
        exercise("leg-press", "Жим ногами", .legs,
                 secondary: "Ягодицы", equipment: "Тренажёр для жима", .beginner, weighted: true,
                 summary: "Безопасный способ дать ногам большой объём нагрузки.",
                 steps: ["Сядьте в тренажёр, стопы на платформе на ширине плеч.",
                         "Опустите платформу, пока колени не согнутся примерно до 90°.",
                         "Выжмите платформу, не блокируя колени."],
                 tips: ["Таз не отрывайте от спинки.",
                        "Постановка стоп выше — больше ягодиц, ниже — больше квадрицепсов."]),
        exercise("lunge", "Выпады с гантелями", .legs,
                 secondary: "Ягодицы, кор", equipment: "Гантели", .intermediate, weighted: true,
                 summary: "Работает по одной ноге, исправляет дисбаланс силы.",
                 steps: ["Возьмите гантели, сделайте широкий шаг вперёд.",
                         "Опуститесь, пока заднее колено почти не коснётся пола.",
                         "Оттолкнитесь передней ногой и вернитесь в исходное положение."],
                 tips: ["Корпус держите вертикально.",
                        "Переднее колено не заваливайте внутрь."]),
        exercise("calf-raise", "Подъём на носки стоя", .legs,
                 secondary: "Камбаловидная мышца", equipment: "Тренажёр или гантели", .beginner, weighted: true,
                 summary: "Простое упражнение для развития икр.",
                 steps: ["Встаньте на возвышение так, чтобы пятки свисали.",
                         "Поднимитесь на носки максимально высоко.",
                         "Задержитесь на секунду и медленно опуститесь до растяжения."],
                 tips: ["Работайте на полную амплитуду.",
                        "Пауза внизу и вверху делает упражнение эффективнее."]),

        // Плечи
        exercise("ohp", "Жим штанги стоя", .shoulders,
                 secondary: "Трицепс, верх груди, кор", equipment: "Штанга", .intermediate, weighted: true,
                 summary: "Базовый жим над головой для силы и объёма плеч.",
                 steps: ["Возьмите штангу на уровне ключиц, стопы на ширине плеч.",
                         "Выжмите штангу вверх, слегка убирая голову назад, и зафиксируйте над макушкой.",
                         "Опустите штангу обратно на грудь."],
                 tips: ["Напрягите ягодицы и пресс, чтобы не прогибаться в пояснице.",
                        "Локти слегка впереди грифа."]),
        exercise("lateral-raise", "Махи гантелей в стороны", .shoulders,
                 secondary: "Трапеции", equipment: "Гантели", .beginner, weighted: true,
                 summary: "Изоляция средней дельты — ширина плеч.",
                 steps: ["Встаньте с гантелями вдоль корпуса, локти слегка согнуты.",
                         "Поднимите руки в стороны до уровня плеч.",
                         "Медленно опустите, не раскачиваясь."],
                 tips: ["Представляйте, что выливаете воду из кувшина — мизинец чуть выше большого пальца.",
                        "Небольшой вес и чистая техника лучше рывков."]),
        exercise("face-pull", "Тяга к лицу", .shoulders,
                 secondary: "Задние дельты, ротаторная манжета", equipment: "Блок с канатной рукоятью", .beginner, weighted: true,
                 summary: "Здоровые плечи и осанка в одном упражнении.",
                 steps: ["Установите блок на уровне лица и возьмитесь за канат.",
                         "Тяните канат к лицу, разводя руки и локти в стороны.",
                         "Задержитесь на секунду и вернитесь, контролируя вес."],
                 tips: ["Тяните к переносице, а не к шее.",
                        "Берите лёгкий вес и делайте больше повторений."]),

        // Руки
        exercise("biceps-curl", "Сгибания рук со штангой", .arms,
                 secondary: "Предплечья", equipment: "Штанга или EZ-гриф", .beginner, weighted: true,
                 summary: "Классическое упражнение на бицепс.",
                 steps: ["Встаньте с грифом в опущенных руках хватом снизу.",
                         "Согните руки, не двигая локти вперёд.",
                         "Опустите штангу за 2–3 секунды."],
                 tips: ["Корпус неподвижен, без читинга.",
                        "В верхней точке слегка сожмите мышцу."]),
        exercise("hammer-curl", "Молотковые сгибания", .arms,
                 secondary: "Плечелучевая мышца, предплечья", equipment: "Гантели", .beginner, weighted: true,
                 summary: "Нейтральный хват нагружает брахиалис и предплечья.",
                 steps: ["Возьмите гантели нейтральным хватом, ладони смотрят друг на друга.",
                         "Согните руки, ведя гантели к плечам.",
                         "Опустите их под контролем."],
                 tips: ["Локти прижаты к корпусу.",
                        "Можно чередовать руки для лучшей концентрации."]),
        exercise("triceps-pushdown", "Разгибания рук на блоке", .arms,
                 secondary: "Локтевая мышца", equipment: "Блок с рукоятью", .beginner, weighted: true,
                 summary: "Изоляция трёхглавой мышцы плеча.",
                 steps: ["Встаньте перед верхним блоком, локти прижмите к корпусу.",
                         "Разогните руки вниз до полного выпрямления.",
                         "Плавно вернитесь до угла в локтях 90°."],
                 tips: ["Плечи неподвижны, работают только предплечья.",
                        "В нижней точке сожмите трицепс."]),

        // Пресс
        exercise("plank", "Планка", .core,
                 secondary: "Плечи, ягодицы", equipment: "Свой вес", .beginner, measure: .seconds,
                 summary: "Статика, которая учит держать корпус жёстким.",
                 steps: ["Упритесь предплечьями в пол, локти под плечами.",
                         "Вытяните тело в линию от пяток до макушки.",
                         "Держите положение, дыша ровно."],
                 tips: ["Не прогибайте поясницу и не поднимайте таз.",
                        "Сжимайте ягодицы и тяните рёбра к тазу."]),
        exercise("leg-raise", "Подъём ног в висе", .core,
                 secondary: "Сгибатели бедра, предплечья", equipment: "Турник", .intermediate,
                 summary: "Нагружает нижний пресс и учит контролю корпуса.",
                 steps: ["Повисните на турнике, плечи опущены.",
                         "Поднимите ноги вперёд до параллели с полом или выше.",
                         "Медленно опустите, избегая раскачивания."],
                 tips: ["Подкручивайте таз в верхней точке.",
                        "Начните с согнутых коленей, если сложно."]),
        exercise("russian-twist", "Русские скручивания", .core,
                 secondary: "Косые мышцы живота", equipment: "Блин или гантель", .beginner, weighted: true,
                 summary: "Развивает косые мышцы и вращательную силу корпуса.",
                 steps: ["Сядьте, отклонитесь назад, ноги слегка приподнимите.",
                         "Держа вес двумя руками, поворачивайте корпус из стороны в сторону.",
                         "Касайтесь пола у бедра на каждой стороне."],
                 tips: ["Вращается корпус, а не только руки.",
                        "Спину держите прямой."]),

        // Кардио
        exercise("burpee", "Бёрпи", .cardio,
                 secondary: "Всё тело", equipment: "Свой вес", .intermediate,
                 summary: "Максимум нагрузки на пульс за минимум времени.",
                 steps: ["Из стойки присядьте и поставьте руки на пол.",
                         "Выпрыгните ногами назад в упор лёжа и отожмитесь.",
                         "Подтяните ноги обратно и выпрыгните вверх с хлопком."],
                 tips: ["Держите стабильный ритм, а не максимальную скорость.",
                        "При необходимости уберите отжимание."]),
        exercise("jump-rope", "Скакалка", .cardio,
                 secondary: "Икры, плечи, координация", equipment: "Скакалка", .beginner, measure: .seconds,
                 summary: "Лёгкая и очень эффективная разминка и кардио.",
                 steps: ["Держите рукояти на уровне бёдер, локти прижаты.",
                         "Крутите скакалку кистями и подпрыгивайте на 2–3 см.",
                         "Приземляйтесь на носки мягко."],
                 tips: ["Не прыгайте высоко — это лишнее.",
                        "Смотрите перед собой, а не на ноги."]),
        exercise("rowing", "Гребной тренажёр", .cardio,
                 secondary: "Спина, ноги, руки", equipment: "Гребной тренажёр", .beginner, measure: .seconds,
                 summary: "Кардио, которое работает на 85% мышц тела.",
                 steps: ["Сядьте, зафиксируйте стопы и возьмитесь за рукоять.",
                         "Оттолкнитесь ногами, затем откиньте корпус и подтяните рукоять к животу.",
                         "Верните рукоять вперёд в обратном порядке: руки, корпус, ноги."],
                 tips: ["Сила идёт от ног: 60% ноги, 20% корпус, 20% руки.",
                        "Не округляйте спину в конце гребка."]),
        exercise("kb-swing", "Махи гирей", .cardio,
                 secondary: "Ягодицы, задняя цепь, кор", equipment: "Гиря", .intermediate, weighted: true,
                 summary: "Взрывное упражнение для ягодиц и выносливости.",
                 steps: ["Расставьте ноги шире плеч, гирю держите двумя руками.",
                         "Отведите таз назад и «выстрелите» тазом вперёд, выбрасывая гирю до уровня груди.",
                         "Дайте гире упасть и отведите таз назад для следующего повторения."],
                 tips: ["Движение — тазовый толчок, а не подъём руками.",
                        "Спину держите нейтральной."]),

        // Мобильность
        exercise("cat-cow", "Кошка-корова", .mobility,
                 secondary: "Позвоночник, кор", equipment: "Коврик", .beginner, measure: .seconds,
                 summary: "Мягкая мобилизация позвоночника.",
                 steps: ["Встаньте на четвереньки: ладони под плечами, колени под бёдрами.",
                         "На выдохе округлите спину, подтягивая подбородок к груди.",
                         "На вдохе прогнитесь, подняв взгляд и копчик."],
                 tips: ["Двигайтесь в такт дыханию.",
                        "Амплитуду увеличивайте постепенно."]),
        exercise("hip-opener", "Глубокий выпад с поворотом", .mobility,
                 secondary: "Бёдра, грудной отдел", equipment: "Коврик", .beginner, measure: .seconds,
                 summary: "Открывает тазобедренные суставы и грудной отдел позвоночника.",
                 steps: ["Сделайте глубокий выпад, руки по сторонам от стопы.",
                         "Поднимите одну руку вверх, разворачивая грудь в сторону.",
                         "Задержитесь, затем смените сторону."],
                 tips: ["Не торопитесь — дышите глубоко.",
                        "Заднее колено можно опустить на пол."]),
    ]

    static let exercisesByID: [String: Exercise] = Dictionary(
        uniqueKeysWithValues: exercises.map { ($0.id, $0) }
    )

    // MARK: План недели

    private static func item(_ id: String, _ sets: Int, _ target: Int, _ weight: Double = 0, rest: Int = 90) -> PlannedExercise {
        PlannedExercise(exerciseID: id, sets: sets, target: target, weight: weight, restSeconds: rest)
    }

    static let weekPlan: [WorkoutDay] = [
        WorkoutDay(weekdayIndex: 0, title: "Грудь и трицепс", focus: "Сила • Верх тела", durationMinutes: 65, photo: .chest, items: [
            item("bench-press", 4, 8, 80, rest: 120),
            item("incline-db-press", 3, 10, 28, rest: 90),
            item("dips", 3, 10, rest: 90),
            item("db-fly", 3, 12, 14, rest: 60),
            item("triceps-pushdown", 3, 12, 30, rest: 60),
        ]),
        WorkoutDay(weekdayIndex: 1, title: "Спина и бицепс", focus: "Сила • Верх тела", durationMinutes: 70, photo: .back, items: [
            item("deadlift", 3, 5, 110, rest: 150),
            item("pull-up", 4, 8, rest: 120),
            item("bent-row", 4, 8, 60, rest: 90),
            item("biceps-curl", 3, 10, 30, rest: 60),
            item("hammer-curl", 3, 12, 14, rest: 60),
        ]),
        WorkoutDay(weekdayIndex: 2, title: "Кардио и мобильность", focus: "Выносливость • Восстановление", durationMinutes: 40, photo: .cardio, items: [
            item("rowing", 4, 240, rest: 60),
            item("jump-rope", 4, 90, rest: 45),
            item("burpee", 3, 15, rest: 60),
            item("cat-cow", 2, 60, rest: 20),
            item("hip-opener", 2, 60, rest: 20),
        ]),
        WorkoutDay(weekdayIndex: 3, title: "Ноги", focus: "Сила • Низ тела", durationMinutes: 75, photo: .legs, items: [
            item("squat", 4, 6, 100, rest: 150),
            item("rdl", 3, 8, 80, rest: 120),
            item("leg-press", 3, 12, 160, rest: 90),
            item("lunge", 3, 10, 20, rest: 75),
            item("calf-raise", 4, 15, 60, rest: 45),
        ]),
        WorkoutDay(weekdayIndex: 4, title: "Плечи и пресс", focus: "Гипертрофия • Кор", durationMinutes: 60, photo: .shoulders, items: [
            item("ohp", 4, 6, 50, rest: 120),
            item("lateral-raise", 3, 15, 10, rest: 45),
            item("face-pull", 3, 15, 25, rest: 45),
            item("plank", 3, 60, rest: 45),
            item("leg-raise", 3, 12, rest: 60),
            item("russian-twist", 3, 20, 8, rest: 45),
        ]),
        WorkoutDay(weekdayIndex: 5, title: "Лёгкое кардио", focus: "Выносливость • Жиросжигание", durationMinutes: 45, photo: .core, items: [
            item("kb-swing", 4, 20, 16, rest: 60),
            item("burpee", 3, 12, rest: 60),
            item("jump-rope", 3, 120, rest: 45),
            item("plank", 2, 45, rest: 30),
        ]),
        WorkoutDay(weekdayIndex: 6, title: "Отдых", focus: "Восстановление", durationMinutes: 0, photo: .mobility, items: []),
    ]

    // MARK: История

    static func makeHistory(
        plan: [WorkoutDay] = weekPlan,
        now: Date = .now,
        calendar: Calendar = .sport,
        weeks: Int = 26
    ) -> [WorkoutSession] {
        var rng = SeededRandom(seed: 20240611)
        let startOfToday = calendar.startOfDay(for: now)
        guard let thisWeekStart = calendar.dateInterval(of: .weekOfYear, for: now)?.start else { return [] }

        var sessions: [WorkoutSession] = []

        for weeksAgo in stride(from: weeks - 1, through: 0, by: -1) {
            guard let weekStart = calendar.date(byAdding: .weekOfYear, value: -weeksAgo, to: thisWeekStart) else { continue }
            // 0…1: чем ближе к сегодняшнему дню, тем сильнее атлет.
            let progress = 1 - Double(weeksAgo) / Double(weeks)
            let strength = 0.78 + 0.22 * progress

            for day in plan where !day.isRest {
                let skipRoll = rng.next()
                if skipRoll < 0.12 { continue }
                if day.weekdayIndex == 5 && weeksAgo % 2 == 1 { continue }

                guard let dayStart = calendar.date(byAdding: .day, value: day.weekdayIndex, to: weekStart),
                      dayStart < startOfToday,
                      let date = calendar.date(bySettingHour: 18, minute: 30, second: 0, of: dayStart)
                else { continue }

                let logged: [LoggedExercise] = day.items.map { planned in
                    let measure = exercisesByID[planned.exerciseID]?.measure ?? .reps
                    let weight = planned.weight > 0 ? roundedWeight(planned.weight * strength) : 0
                    let sets: [LoggedSet] = (0..<planned.sets).map { index in
                        var value = planned.target
                        if weight == 0 {
                            // Без отягощения растёт число повторений или время.
                            let scaled = Double(planned.target) * (0.7 + 0.3 * progress)
                            value = measure == .seconds ? Int((scaled / 5).rounded()) * 5 : Int(scaled.rounded())
                        } else if index == planned.sets - 1 && rng.next() < 0.3 {
                            value = max(1, value - 1)
                        }
                        return LoggedSet(value: max(1, value), weight: weight)
                    }
                    return LoggedExercise(exerciseID: planned.exerciseID, sets: sets)
                }

                let duration = day.durationMinutes + Int(rng.next() * 12) - 6
                let calories = Int(Double(duration) * (6.5 + rng.next() * 1.5))

                sessions.append(WorkoutSession(
                    id: UUID(),
                    date: date,
                    title: day.title,
                    focus: day.focus,
                    durationMinutes: duration,
                    calories: calories,
                    photo: day.photo,
                    exercises: logged
                ))
            }
        }

        return sessions.sorted { $0.date > $1.date }
    }

    static func makeBodyWeight(
        now: Date = .now,
        calendar: Calendar = .sport,
        weeks: Int = 26
    ) -> [BodyWeightEntry] {
        var rng = SeededRandom(seed: 777)
        let startOfToday = calendar.startOfDay(for: now)
        let totalDays = weeks * 7
        var entries: [BodyWeightEntry] = []

        for offset in stride(from: totalDays, through: 0, by: -3) {
            guard let day = calendar.date(byAdding: .day, value: -offset, to: startOfToday),
                  let date = calendar.date(bySettingHour: 7, minute: 30, second: 0, of: day)
            else { continue }
            let progress = 1 - Double(offset) / Double(totalDays)
            let kilograms = 84.2 - 4.2 * progress + (rng.next() - 0.5) * 0.6
            entries.append(BodyWeightEntry(date: date, kilograms: (kilograms * 10).rounded() / 10))
        }
        return entries
    }

    /// Округление до шага 2,5 кг для штанг и тренажёров, до 1 кг для небольших весов.
    private static func roundedWeight(_ value: Double) -> Double {
        if value <= 20 { return max(1, value.rounded()) }
        return max(2.5, (value / 2.5).rounded() * 2.5)
    }
}
