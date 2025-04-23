import SwiftUI

// MARK: - Generic filter tab bar, received enum with String RawValues

struct BPEventFilterCaseTabView<T: RawRepresentable & CaseIterable>: View  where T.RawValue: StringProtocol {
    
    let tabs: [T] = Array<T>(T.allCases)
    
    @Binding var selectedTab: T
    
    @Namespace var ns
    
    var body: some View {
        HStack(spacing: 0){
            ForEach(tabs.indices, id: \.self) { tabIndex in

                Image(systemName: "\(tabs[tabIndex].rawValue)")
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
//                    .font(.title)
                    .padding(12)
                    .onTapGesture {
                        withAnimation{
                            self.selectedTab = tabs[tabIndex]
                        }
                    }
//                    .border(.blue, width: 2)
//                })
                //data about geometry added to tabIndex Id in ns namespace
                    .matchedGeometryEffect(id: tabs[tabIndex].rawValue , in: ns)
            }
        }
        
//        .padding(.horizontal)
//        .overlay {
//            Rectangle()
//                .fill(Color.accentColor)
//                .padding(.horizontal,5)
//                .frame(height: 2, alignment: .bottom)
//                .offset(y: -5)
//            //receives data about geometry from ns namespaces by selectedtab Id and apply to line
//                .matchedGeometryEffect(id: selectedTab.rawValue, in: ns, isSource: false)
//        }
        .background{
            RoundedRectangle(cornerRadius: 8)
                .fill(.white.opacity(0.4))
            //receives data about geometry from ns namespaces by selectedtab Id and apply to rect
                .matchedGeometryEffect(id: selectedTab.rawValue, in: ns, isSource: false)
        }
    }
 }

#Preview {
    let lm = DataManager(forPreview: true)
    let mdm = MainDataManager(localDataManager: lm, globalDataManager: NetworkManager(),userId: "123")
    let localEvent = lm.fetchOrCreateObject(ofType: LocalEvent.self,
                  predicate: NSPredicate(format: "id == %@", "id"),
                                      in: lm.moc) { ctx in
        let newEvent = LocalEvent(context: ctx)
        newEvent.id = "id"
        return newEvent
    }
    
   return BPEditStadiumView(event: localEvent, editable: true)
        .environmentObject(mdm)
}


