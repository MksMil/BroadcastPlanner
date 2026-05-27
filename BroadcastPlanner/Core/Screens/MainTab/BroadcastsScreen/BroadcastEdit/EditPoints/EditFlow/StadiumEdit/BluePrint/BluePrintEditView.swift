import SpriteKit
import SwiftUI

struct BluePrintEditView: View {
  
  @EnvironmentObject var appState: ApplicationState
  @StateObject var vm: BluePrintEditViewModel
  
  let broadcast: Broadcast
  
  @FetchRequest<Template>(sortDescriptors: []) var templates
  @FetchRequest<Obvan>(sortDescriptors: []) var obvans
  @FetchRequest<Member>(sortDescriptors: [SortDescriptor(\.lastName, order: .forward)]) var availableUsers

  private var stadiumFilterBinding: Binding<BPEventPlanPointStadiumFilter> {
      Binding(
          get: {
              if case .stadium(let f) = vm.selectedState?.activeFilter { return f }
              return .all
          },
          set: { vm.setStadiumFilter($0) }
      )
  }

  private var obvanFilterBinding: Binding<BPObvanPositionFilter> {
      Binding(
          get: {
              if case .obvan(let f) = vm.selectedState?.activeFilter { return f }
              return .all
          },
          set: { vm.setObvanFilter($0) }
      )
  }
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
        
        SpriteView(scene: vm.scene)
        .aspectRatio(1.5, contentMode: .fit)
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        
        HStack(spacing: 6){
          VStack(spacing:6){
            filterBlock
            
            PointDescriptionView(source: vm.states,
                                 currentSource: $vm.selectedState,
                                 sourceForCells: vm.filteredUnits,
                                 currentCell: $vm.selectedUnit,
                                 spacing: 0,
                                 menuHeight: 40) { unit in
              //descriptrion cell
              PointDescriptionCell(
                image: unit.image,
                firstName: unit.firstName,
                lastName: unit.lastName,
                number: unit.number,
                camera: unit.camera,
                sound: unit.sound,
                light: unit.light,
                unitDescription: unit.description)
              .onTapGesture {
                vm.selectedUnit = vm.selectedUnit != nil ? nil: unit
              }
            } sourceCell: { state in
              ZStack{
                // source cell
                Image(systemName: state.layoutType.rawValue)
                  .font(.system(size: 22))
                  .offset(y: -3)
              }
            } addSourceAction: {
              //TODO: from vm
              vm.isAddObvanSheetShow = true
            }
            .overlay {
              RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.3), lineWidth: 2)
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
          }
          controlGroup
        }
        .padding(.vertical,6)
        
        saveDeleteGroup
      }
      .padding(.horizontal)
      .transitionWithOpacity()
    }
    .onAppear{
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
    .sheet(isPresented: $vm.isEdit) {
      UnitEditView(vm: UnitEditViewModel(unit: vm.selectedUnit,dataManager: vm.dataManager, availableUsers: availableUsers), state: vm.selectedState)
    }
    .sheet(isPresented: $vm.isAddObvanSheetShow) {
      ObvanPickerSheet(
          vm: ObvanPickerViewModel(
            obvans: Array(obvans),
            alreadyAdded: broadcast.viewObvans,
            dataManager: vm.dataManager
          )
        ) { obvan in
          vm.addObvan(obvan)
        }
    }
    
  }
  // MARK: ControlGroup
  private var controlGroup: some View {
    VStack(spacing:6){
      TemplateMenuButton(
        templates: templates,
        chooseAction: { vm.loadTemplate(template: $0) },
        addAction: { name in
          Task { await vm.saveTemplateWithName(name) }
        },
        removeAction: { withAnimation { vm.deleteTemplate() } },
        setEmptyTemplateAction: { withAnimation { vm.clear() } }
      )
      .frame(height: 40)
      .frame(maxWidth: .infinity)
      BPJoystick(delegate: vm.renderDelegate)
        .aspectRatio(1, contentMode: .fit)
        .padding(5)
        .frame(maxWidth:.infinity,maxHeight: .infinity)
        .overlay {
          RoundedRectangle(cornerRadius: 5).stroke(.white.opacity(0.4), lineWidth: 2)
        }
        .layoutPriority(1)
      BPEditEventControlPanel(delegate: vm.renderDelegate)
        .layoutPriority(1)
    }
  }
  
  // MARK: Toolbar
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
          Task{
           await vm.save()
          }
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
  
  // MARK: filter
  private var filterBlock: some View {
      Group {
          switch vm.selectedState?.activeFilter {
          case .stadium:
              BPEventFilterCaseTabView(selectedTab: stadiumFilterBinding) {}
          case .obvan:
              BPEventFilterCaseTabView(selectedTab: obvanFilterBinding) {}
          case .none:
              EmptyView()
          }
      }
      .padding(3)
      .background {
          RoundedRectangle(cornerRadius: 10)
              .fill(.ultraThinMaterial)
              .overlay {
                  RoundedRectangle(cornerRadius: 10)
                      .stroke(Color.white.opacity(0.5), lineWidth: 1)
              }
      }
      .frame(height: 40)
  }
}

