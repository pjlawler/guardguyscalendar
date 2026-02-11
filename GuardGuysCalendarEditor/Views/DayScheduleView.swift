import SwiftUI

struct DayScheduleView: View {
    @State private var selectedDate: Date = .now
    @StateObject private var viewModel = DayScheduleViewModel()

    var body: some View {
        VStack {
            // Top date selector similar to week view
            DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(.compact)
                .padding()
                .onChange(of: selectedDate) { newValue in
                    viewModel.loadEvents(for: newValue) { _ in }
                }

            if viewModel.isLoading {
                ProgressView("Loading...")
                    .padding()
            }

            if viewModel.events.isEmpty && !viewModel.isLoading {
                ContentUnavailableView("No Events", systemImage: "calendar", description: Text("No events for this day."))
                    .padding()
            } else {
                List(viewModel.events, id: \._id) { event in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(event.event)
                            .font(.headline)
                        HStack {
                            Text("Duration: \(event.duration) mins")
                            if let user = event.user?.username {
                                Text("• \(user)")
                            }
                        }
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        if !event.notes.isEmpty {
                            Text(event.notes)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Day")
        .onAppear {
            viewModel.loadEvents(for: selectedDate) { _ in }
        }
    }
}

#Preview {
    NavigationStack { DayScheduleView() }
}
