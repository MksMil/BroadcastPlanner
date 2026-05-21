import SwiftUI
import SpriteKit
import _PhotosUI_SwiftUI

struct AddEditObvanView: View {
  @EnvironmentObject var appState: ApplicationState
    @StateObject var vm: AddEditObvanViewModel
    let obvan: Obvan
    
    init(obvan: Obvan,dataManager: DataManager,
         router: Router, settings: GlobalSettings){
        self.obvan = obvan
      
        self._vm = StateObject(wrappedValue: AddEditObvanViewModel(
          obvan: obvan, dataManager: dataManager,
          router: router, settings: settings))
    }
    
  var body: some View {
    ZStack{
      MainBackground()
      
      VStack(spacing: 0){
        SpriteView(scene: vm.scene,
                   debugOptions: [.showsFPS,.showsNodeCount])
        .aspectRatio(1.5, contentMode: .fit)
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        
        descriptionGroup
        
        HStack{
          if vm.renderUnits.isEmpty {
            Spacer()
              .frame(maxWidth: .infinity)
          }
          ScrollView{
            ForEach(vm.renderUnits){ crew in
              ObvanTemplateCrewCell(crewPosition: crew.description,
                                    isSelected: crew == vm.selectedUnit)
              .onTapGesture {
                withAnimation{
                  vm.selectedUnit = vm.selectedUnit == crew ? nil: crew
                }
              }
              .animation(.easeInOut, value: vm.selectedUnit)
            }
          }
          controlGroup
        }
        .padding(.bottom, 6)
          
        saveDeleteGroup
      }
      .padding(.horizontal)
      .transitionWithOpacity()
      .ignoresSafeArea(.keyboard)
      .navigationBarBackButtonHidden()
      .onAppear{
        appState.backAction = {vm.goBack()}
      }
      .sheet(isPresented: $vm.isEdit) {
          ObvanPositionPickerSheet(
              positions: vm.positions,
              selected: vm.selectedUnit?.description
          ) { position in
              vm.setPosition(position)
          }
      }
    }
  }
  // MARK: - Toolbar
  private var saveDeleteGroup: some View {
    HStack(spacing: 0) {
      Spacer()
      Button(role: .destructive) {
        vm.isDeleteConfirm = true
      } label: {
        HStack(spacing: 6) {
          Image(systemName: "trash")
            .font(.system(size: 16, weight: .medium))
          Text("Delete")
            .font(.system(size: 15, weight: .medium))
        }
        .foregroundStyle(.red.opacity(0.8))
        .frame(maxHeight: .infinity)
        .opacity(vm.selectedUnit == nil ? 0.5: 1)
      }
      .disabled(vm.selectedUnit == nil)
      
      Spacer()
      Divider()
        .frame(width: 2,height: 40)
        .overlay(Color.white.opacity(0.5))
      Spacer()
      
      //add
      Button{
        vm.addUnit()
        vm.isEdit = true
      } label: {
        HStack(spacing: 6) {
          Image(systemName: "plus")
            .font(.system(size: 16, weight: .medium))
          Text("Add")
            .font(.system(size: 15, weight: .medium))
        }
        .foregroundStyle(.black)
        .frame(maxHeight: .infinity)
      }
      
      Spacer()
      Divider()
        .frame(width: 2,height: 40)
        .overlay(Color.white.opacity(0.5))
      Spacer()
      
      //edit
      Button{
        vm.isEdit = true
      } label: {
        HStack(spacing: 6) {
          Image(systemName: "square.and.pencil")
            .font(.system(size: 16, weight: .medium))
          Text("Edit")
            .font(.system(size: 15, weight: .medium))
        }
        .foregroundStyle(.black)
        .frame(maxHeight: .infinity)
        //        .padding(.horizontal, 24)
        .opacity(vm.selectedUnit == nil ? 0.5: 1)
      }
      
      .disabled(vm.selectedUnit == nil)
      
      Spacer()
      Divider()
        .frame(width: 2,height: 40)
        .overlay(Color.white.opacity(0.5))
      Spacer()
      
      if vm.isSaving {
        ProgressView()
          .padding(.horizontal, 24)
      } else {
        Button {
          vm.save()
        } label: {
          HStack(spacing: 6) {
            Image(systemName: "checkmark")
              .font(.system(size: 16, weight: .semibold))
            Text("Save")
              .font(.system(size: 15, weight: .semibold))
          }
          .foregroundStyle(vm.isSaved ? Color.black : Color.green)
          .opacity(vm.isSaved ? 0.5: 1)
          .frame(maxHeight: .infinity)
        }
        .disabled(vm.isSaved)
      }
      Spacer()
    }
    .minimumScaleFactor(0.5)
    .frame(height: 50)
    .frame(maxWidth: .infinity)
    .background {
      RoundedRectangle(cornerRadius: 14)
        .fill(.ultraThinMaterial)
        .overlay {
          RoundedRectangle(cornerRadius: 14)
            .stroke(Color.white.opacity(0.5), lineWidth: 1)
        }
    }
  }
  // MARK: - Description and photo picker
//  private var descriptionGroup: some View {
//    HStack {
//      PhotosPicker(selection: $vm.selectedPhoto) {
//        Image(systemName: "photo.artframe")
//          .resizable()
//          .scaledToFit()
//          .bold()
//          .padding(5)
//          .frame(width: 40, height: 40)
//          .background {
//            RoundedRectangle(cornerRadius: 5)
//              .fill(
//                .ultraThickMaterial
//                  .opacity(0.3)
//              )
//              .overlay {
//                RoundedRectangle(cornerRadius: 5)
//                  .stroke(
//                    .ultraThickMaterial
//                      .opacity(0.5),
//                    lineWidth: 2
//                  )
//              }
//          }
//      }
//      TextField("Obvan name", text: $vm.obvanName)
//                  .padding(.horizontal, 10)
//                  .frame(height: 40)
//                  .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
//                  .overlay {
//                      RoundedRectangle(cornerRadius: 8)
//                          .stroke(Color.white.opacity(0.5), lineWidth: 1)
//                  }
//
//              TextField("Broadcaster", text: $vm.broadcaster)
//                  .padding(.horizontal, 10)
//                  .frame(height: 40)
//                  .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
//                  .overlay {
//                      RoundedRectangle(cornerRadius: 8)
//                          .stroke(Color.white.opacity(0.5), lineWidth: 1)
//                  }
//      
//    }
//    .frame(height: 40)
//    .padding(.vertical,6)
//  }
  private var descriptionGroup: some View {
      HStack(spacing: 6) {
          PhotosPicker(selection: $vm.selectedPhoto) {
              Image(systemName: "photo.artframe")
                  .resizable()
                  .scaledToFit()
                  .bold()
                  .padding(8)
                  .frame(width: 40, height: 40)
                  .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
                  .overlay {
                      RoundedRectangle(cornerRadius: 8)
                          .stroke(Color.white.opacity(0.5), lineWidth: 1)
                  }
          }

          TextField("Obvan name", text: $vm.obvanName)
              .padding(.horizontal, 10)
              .frame(height: 40)
              .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
              .overlay {
                  RoundedRectangle(cornerRadius: 8)
                      .stroke(Color.white.opacity(0.5), lineWidth: 1)
              }

          TextField("Broadcaster", text: $vm.broadcaster)
          .font(.system(size: 10))
              .padding(.horizontal, 10)
              .frame(height: 40)
              .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
              .overlay {
                  RoundedRectangle(cornerRadius: 8)
                      .stroke(Color.white.opacity(0.5), lineWidth: 1)
              }
      }
      .padding(.vertical, 6)
  }
    // MARK: - Control
    private var controlGroup: some View {
      VStack(spacing: 6){
        BPJoystick(delegate: vm.renderDelegate)
          .aspectRatio(1, contentMode: .fit)
          .padding(5)
          .frame(maxWidth:.infinity,maxHeight: .infinity)
          .overlay {
            RoundedRectangle(cornerRadius: 5).stroke(.white.opacity(0.4), lineWidth: 2)
          }
        BPEditEventControlPanel(delegate: vm.renderDelegate)
      }
    }
}

#Preview {
  let dc = DataCoordinator()
  let settings = GlobalSettings()
  
  let obvan = Obvan(context: dc.dataManager.mainContext)
  return AddEditObvanView(obvan: obvan,
                          dataManager: dc.dataManager,
                          router: Router(),settings: settings)
    .environment(\.managedObjectContext, dc.dataManager.mainContext)

}


//struct ObvanTemplateCrewCell: View {
//    let crewPosition: String?
//    let isSelected: Bool
//    
//    var body: some View {
//        
//        Text(crewPosition ?? "Unknown")
//            .padding(.vertical,3)
//            .frame(maxWidth: .infinity)
//            .background {
//                RoundedRectangle(cornerRadius: 5)
//                    .fill(
//                        .ultraThickMaterial
//                            .opacity(0.3)
//                    )
//                    .overlay {
//                        RoundedRectangle(cornerRadius: 5)
//                            .stroke(
//                                .ultraThickMaterial
//                                    .opacity(0.5),
//                                lineWidth: 2
//                            )
//                    }
//            }
//            .opacity(isSelected ? 1: 0.6)
//    }
//}
struct ObvanTemplateCrewCell: View {
    let crewPosition: String?
    let isSelected: Bool

    var body: some View {
        Text(crewPosition ?? "Unknown")
            .font(.system(size: 13, weight: .medium))
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .frame(maxWidth: .infinity)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(
                        isSelected ? Color.primary.opacity(0.4) : Color.white.opacity(0.4),
                        lineWidth: isSelected ? 2 : 0.5
                    )
            }
            .opacity(isSelected ? 1 : 0.7)
    }
}
struct ObvanPositionPickerSheet: View {
    let positions: [String]
    let selected: String?
    let onSelect: (String) -> Void
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            MainBackground()
            VStack(spacing: 0) {
                Text("выбери позицию")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                    .padding(.top, 8)
                    .padding(.bottom, 12)

                FlowLayout(spacing: 8) {
                    ForEach(positions, id: \.self) { position in
                        let isSelected = position == selected
                        Text(position)
                            .font(.system(size: 13, weight: .medium))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                isSelected
                                    ? Color.white.opacity(0.7)
                                    : Color.white.opacity(0.2),
                                in: RoundedRectangle(cornerRadius: 8)
                            )
                            .overlay {
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(
                                        isSelected
                                            ? Color.primary.opacity(0.4)
                                            : Color.white.opacity(0.4),
                                        lineWidth: isSelected ? 2 : 0.5
                                    )
                            }
                            .onTapGesture {
                                onSelect(position)
                                dismiss()
                            }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)

                Spacer()
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
        .presentationBackground { MainBackground() }
    }
}
