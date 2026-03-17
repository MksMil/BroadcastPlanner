import Combine
import CoreData
import SwiftUI

struct BroadcastListView: View {
  
  @StateObject var viewModel: BroadcastListViewModel
  @EnvironmentObject var appState: ApplicationState

    @FetchRequest<Broadcast>(sortDescriptors: [
        SortDescriptor(\.date, order: .forward)
    ]) var broadcasts

    @State private var filter: FilterEventOwnerCases = .notFiltered
    @State private var expired: Bool = true

    var body: some View {
        ZStack {
            MainBackground()
            
            VStack {
                Rectangle().fill(.white.opacity(0.4))
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
                
                    .overlay {
                        HStack {
                            Spacer()
                            BPEventFilterCaseTabView<FilterEventOwnerCases>(
                                selectedTab: $filter
                            ) {
                                updateBroadcasts()
                            }
                            Spacer()
                            Divider()
                            Button {
                                withAnimation(.easeIn(duration: 0.3)) {
                                    expired.toggle()
                                }
                                updateBroadcasts()
                            } label: {
                                Image(systemName: "hourglass")
                                    .resizable()
                                    .scaledToFit()
                                    .padding(12)
                                    .opacity(expired ? 1 : 0.2)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 5)
                    }
                
                ScrollView {
                    VStack {
                      ForEach(broadcasts) { broadcast in
                        MainEventListCell(broadcast: broadcast, currentUserId: viewModel.currentUserId,
                                          timerPublisher: appState.currentTime.eraseToAnyPublisher())
                        .id(broadcast.viewId)
                        .onTapGesture {
                          viewModel.openExisting(broadcast)
                        }
                        .transition(
                          .move(edge: .top)
                          .combined(with: .opacity)
                          
                        )
                        .animation(.easeIn(duration: 0.3), value: filter)
                      }
                    }
                    .opacity(viewModel.isLoading ? 0:1)
                    .frame(maxWidth: .infinity) // need to correct animation of changes of list!  (if (list empty & !maxWidth) - added 'scale' to transition animation of cell)
                  
                }
                .padding(.horizontal, 8)
              if viewModel.canCreateBroadcast{
                    Button {
                         Task { await viewModel.createAndOpen() }
                    } label: {
                        Text("New Broadcast")
                            .font(.title2)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background {
                                RoundedRectangle(cornerRadius: 15).fill(
                                    Color.white
                                )
                            }
                    }
                    .padding(.bottom)
                    .padding(.horizontal)
                }
            }
            .navigationBarBackButtonHidden()
            .transitionWithOpacity()
        }
    }
    func updateBroadcasts() {
          withAnimation(.easeIn(duration: 0.3)) {
              appState.setTitle(viewModel.title(for: filter))
              broadcasts.nsPredicate = viewModel.predicate(for: filter, expired: expired)
          }
      }
}

