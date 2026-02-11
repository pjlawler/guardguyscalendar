import SwiftUI

@MainActor
class DayScheduleViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var events: [ScheduleEvent] = []
    @AppStorage("lastEventDownload") var lastDate = ""

    func loadEvents(for date: Date, completion: @escaping (Result<[ScheduleEvent], NetworkErrors>) -> Void) {
        isLoading = true
        Task {
            defer { Task { await MainActor.run { self.isLoading = false } } }
            do {
                let data = try await NetworkManager.shared.makeApiRequestFor(.getEvents(date: date))
                let results = try JSONDecoder().decode([ScheduleEvent].self, from: data)
                await MainActor.run {
                    self.events = results.filter { $0.date.starts(with: convertDateToApiString(date: date)) }
                    self.lastDate = convertDateToApiString(date: date)
                    completion(.success(self.events))
                }
            } catch {
                await MainActor.run {
                    completion(.failure(.networkFailure))
                }
            }
        }
    }
}
