import SpriteKit
import SwiftUI

struct BluePrintEditView: View {
  
  @EnvironmentObject var appState: ApplicationState
  @EnvironmentObject var settings: GlobalSettings
  @StateObject var vm: BluePrintEditViewModel
  
  let broadcast: Broadcast
  
  @FetchRequest<Template>(sortDescriptors: []) var templates
  @FetchRequest<Obvan>(sortDescriptors: []) var obvans
  
  init(broadcast: Broadcast,
       dataManager: DataManager,
       router: Router) {
    self.broadcast = broadcast
    self._vm = .init(
      wrappedValue: BluePrintEditViewModel(broadcast: broadcast,
                                           dataManager: dataManager,
                                           router: router))
  }
  
  var body: some View {
    ZStack {
      MainBackground()
      
      VStack(spacing: 0) {
        //template group
        TemplateGroup(templates: templates) { templateToShow in
          withAnimation {
            vm.loadTemplate(template: templateToShow)
          }
        } addAction: {
          Task{
           await vm.saveTemplateWithName(vm.newTemplateName)
          }
          
        } removeAction: {
          vm.deleteTemplate()
        } setEmptyTemplateAction: {
          broadcast.cleanVenuePoints()
          withAnimation{
            vm.clear()
          }
        }
        .padding(.vertical, 15)
        
        //SKView
        SpriteView(
          scene: vm.scene,
          debugOptions: [.showsFPS, .showsNodeCount]
        )
        .aspectRatio(1.5, contentMode: .fit)
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 10))

        Spacer()
        HStack{
          BPEventFilterCaseTabView(selectedTab: $vm.stadiumFilter){}
            .padding(3)
            .background {
              RoundedRectangle(cornerRadius: 5).fill(.ultraThinMaterial)
            }
            .overlay {
              RoundedRectangle(cornerRadius: 5).stroke(Color.white, lineWidth: 1)
            }
          
          BPEditEventControlPanel(delegate: vm.renderDelegate)
        }
        HStack{
          PointDescriptionView(source: vm.states,
                               currentSource: $vm.selectedState,
                               sourceForCells: vm.filteredUnits,
                               currentCell: $vm.selectedUnit,
                               spacing: 0,
                               menuHeight: 40) { unit in
            ZStack{
              Color.orange
              Text("\(unit.id)")
                .font(.callout)
            }
            .onTapGesture {
              vm.selectedUnit = vm.selectedUnit != nil ? nil: unit
            }
            
//            .padding(2)
          } sourceCell: { state in
            ZStack{
//              Color.green
              Image(systemName: state.layoutType.rawValue)
                .font(.system(size: 22))
                .offset(y: -3)
//                .resizable()
//                .scaledToFit()
//              Text("\(state.layoutType.rawValue)")
            }
//            .frame(height: 40)
//            .padding(2)
          } statusLayout: {
            EmptyView()
              .frame(width: 0, height: 0)
//            ZStack{
//              Color.gray
//              Text("Status here")
//            }
//            .padding(2)
          }
          .border(Color.white.opacity(0.3), width: 2)
          .padding()

          BPJoystick(delegate: vm.renderDelegate)
            .aspectRatio(1, contentMode: .fit)
            .padding(15)
            .overlay {
              RoundedRectangle(cornerRadius: 5).stroke(.white.opacity(0.4), lineWidth: 2)
            }
        }

        saveDeleteGroup
      }
      .padding(.horizontal)
      .transitionWithOpacity()
    }
 
    .onAppear{
      let predicate = NSPredicate(format: "broadcasts CONTAINS %@", broadcast)
      obvans.nsPredicate = predicate
      //            appState.setTitle("\(broadcast.venue?.viewTitle ?? "") \( BPDateFormater.format(date: broadcast.viewDate))")
      appState.backAction = {vm.goBack()}
    }
    .ignoresSafeArea(.keyboard)
    .navigationBarBackButtonHidden()
    .confirmationDialog("", isPresented: $vm.isConfirmDiscardChangesOrSave) {
      Button("Save changes and step back?"){
        vm.saveAndGoBack()
      }
      Button("Discard all changes and step back?",role: .destructive){
        vm.discardChangesAndGoBack()
      }
    }
    .confirmationDialog("", isPresented: $vm.isDeleteConfirm) {
      Button("Delete selected unit?",role: .destructive){
        vm.delete()
      }
    }
//    .sheet(isPresented: $isEditPressed) {
//      if vm.selectedVenuePoint != nil{
//        AddEditPointOrObvanView(state: .point,
//                                broadcast: broadcast,
//                                selectedPoint: vm.selectedVenuePoint,
//                                selectedObvan: nil) { updatedPoint in
//          vm.updatePoint(updatedPoint)
//        } newObvanAction: { _ in }
//          .presentationBackground(Color.mainBackground)
//          .presentationDragIndicator(.visible)
//      } else if vm.selectedObvan != nil{
//        AddEditPointOrObvanView(state: .obvan,
//                                broadcast: broadcast,
//                                selectedPoint: nil,
//                                selectedObvan: vm.selectedObvan) { _ in} newObvanAction: { obvan in
//          vm.selectedObvan = obvan
//        }
//                                .presentationBackground(Color.mainBackground)
//                                .presentationDragIndicator(.visible)
//      } else {
//        AddEditPointOrObvanView(state: .new, broadcast: broadcast, selectedPoint: nil, selectedObvan: nil, newPointAction: { newVenuePoint in
//          broadcast.addToVenuePoints(newVenuePoint)
//          newVenuePoint.broadcast = broadcast
//          vm.addPoint(point: newVenuePoint)
//        }, newObvanAction: { _ in })
//        .presentationBackground(Color.mainBackground)
//        .presentationDragIndicator(.visible)
//      }
//    }

    //        .onReceive(vm.$selectedObvan) { obvan in
    //            if obvan == nil , vm.selectedVenuePoint == nil{
    //                appState.makePrimaryButtonEnabled(true)
    //            } else {
    //                appState.makePrimaryButtonEnabled(false)
    //            }
    //        }
    //        .onReceive(vm.$selectedVenuePoint) { point in
    //            if point == nil , vm.selectedObvan == nil{
    //                appState.makePrimaryButtonEnabled(true)
    //            } else {
    //                appState.makePrimaryButtonEnabled(false)
    //            }
    //        }
  }
  
  // MARK: - Toolbar
  private var saveDeleteGroup: some View {
    HStack(spacing: 0) {
      
      // Delete — левая часть, деструктивная, визуально приглушена
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
        .padding(.horizontal, 24)
        .opacity(vm.selectedUnit == nil ? 0.5: 1)
      }
      .disabled(vm.selectedUnit == nil)
      
      Divider()
        .frame(height: 24)
        .overlay(Color.white.opacity(0.4))
      
      Spacer()
      //add
      Button{
        vm.addUnit()
      } label: {
        HStack(spacing: 6) {
          Image(systemName: "plus")
            .font(.system(size: 16, weight: .medium))
          Text("Add")
            .font(.system(size: 15, weight: .medium))
        }
        .foregroundStyle(.black)
        .frame(maxHeight: .infinity)
        .padding(.horizontal, 24)
      }
      
      Divider()
        .frame(height: 24)
        .overlay(Color.white.opacity(0.4))
      
      Spacer()
      
      // Save — правая часть, акцентная
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
          .padding(.horizontal, 24)
        }
        .disabled(vm.isSaved)
      }
    }
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
  
}
