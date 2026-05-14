import SpriteKit
import SwiftUI

struct BluePrintEditView: View {
  
  @EnvironmentObject var appState: ApplicationState
  @EnvironmentObject var settings: GlobalSettings
  @StateObject var vm: BluePrintEditViewModel
  
  let broadcast: Broadcast
  
  @FetchRequest<Template>(sortDescriptors: []) var templates
  @FetchRequest<Obvan>(sortDescriptors: []) var obvans
  
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
        //template group
//        TemplateGroup(templates: templates) { templateToShow in
//          withAnimation {
//            vm.loadTemplate(template: templateToShow)
//          }
//        } addAction: {
//          Task{
//           await vm.saveTemplateWithName(vm.newTemplateName)
//          }
//        } removeAction: {
//          withAnimation{
//            vm.deleteTemplate()
//          }
//        } setEmptyTemplateAction: {
//          broadcast.cleanVenuePoints()
//          withAnimation{
//            vm.clear()
//          }
//        }
//        .padding(.vertical, 15)
        Spacer()
        //SKView
        SpriteView(
          scene: vm.scene,
          debugOptions: [.showsFPS, .showsNodeCount]
        )
        .aspectRatio(1.5, contentMode: .fit)
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 10))
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//                        .clipShape(RoundedRectangle(cornerRadius: 10))

        Spacer()
        VStack(spacing:6){
          HStack(spacing: 6){
            filterBlock
            TemplateMenuButton(
              templates: templates,
              chooseAction: { vm.loadTemplate(template: $0) },
              addAction: { name in              // ← имя приходит из sheet
                Task { await vm.saveTemplateWithName(name) }
              },
              removeAction: { withAnimation { vm.deleteTemplate() } },
              setEmptyTemplateAction: { withAnimation { vm.clear() } }
            )
            .frame(maxWidth: .infinity)
          }
          .frame(height: 40)
          HStack(spacing: 6){
            PointDescriptionView(source: vm.states,
                                 currentSource: $vm.selectedState,
                                 sourceForCells: vm.filteredUnits,
                                 currentCell: $vm.selectedUnit,
                                 spacing: 0,
                                 menuHeight: 40) { unit in
              //descriptrion cell
              PointDescriptionCell(image: unit.image,
                                   firstName: "FirstName",
                                   lastName: "LastName",
                                   number: unit.number,
                                   camera: unit.camera,
                                   sound: unit.sound,
                                   light: unit.light,
                                   unitDescription: "")
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
            }
            .border(Color.white.opacity(0.3), width: 2)
//            .layoutPriority(2)
            VStack(spacing: 6){
              Spacer()
                .frame(minHeight: 0)
                .layoutPriority(0)
              BPJoystick(delegate: vm.renderDelegate)
                .aspectRatio(1, contentMode: .fit)
                .padding(5)
                .overlay {
                  RoundedRectangle(cornerRadius: 5).stroke(.white.opacity(0.4), lineWidth: 2)
                }
//                .border(.green, width: 2)
                .layoutPriority(1)
              BPEditEventControlPanel(delegate: vm.renderDelegate)
              //              Spacer()
//                .border(.blue, width: 2)
                .layoutPriority(1)
            }
//            .border(.red, width: 2)
//            .frame(width: 130)
//            .layoutPriority(1)
          }
        }

        .padding(.vertical,6)

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

