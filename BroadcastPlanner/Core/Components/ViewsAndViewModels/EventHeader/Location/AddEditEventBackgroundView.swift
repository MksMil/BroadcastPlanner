import SwiftUI
import UIKit
import PhotosUI

struct AddEditEventBackgroundView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var eventBackgroundItem: PhotosPickerItem?
    
    @FetchRequest<LocalImage>(sortDescriptors: [],predicate: NSPredicate(format: "type == %@", GlobalProperties.ImageType.eventTemplate.rawValue)) var backgroundLocalImages
    
    let addNewBackgroundAction: (UIImage, Image) -> Void
    let addExistBackgroundAction: (Int)->Void
    
    var body: some View {
        VStack{
            HStack{
                Button {
                    //                    cancelAction()
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .resizable()
                        .scaledToFit()
                        .bold()
                        .padding()
                        .background {
                            Rectangle()
                                .fill(.red
                                    .opacity(0.3))
                                .overlay {
                                    Rectangle()
                                        .stroke(Color
                                            .red
                                            .opacity(0.5),
                                                lineWidth: 2)
                                }
                        }
                        .frame(width: 50)
                }
                .frame(alignment: .leading)
                
                Spacer()
                
                Button{
                    //                    saveAction()
                    dismiss()
                } label: {
                    Image(systemName: "checkmark")
                        .resizable()
                        .scaledToFit()
                        .bold()
                        .padding()
                        .background {
                            Rectangle().fill(.green.opacity(0.3))
                                .overlay {
                                    Rectangle().stroke(Color.green.opacity(0.5),
                                                       lineWidth: 2)
                                }
                        }
                        .frame(width: 50)
                }
                .frame( alignment: .trailing)
            }
            .padding(.horizontal)
            .font(.title)
            .bold()
            ScrollView{
//                SmartLayout(hSpacing: 4, vSpacing: 4){
                VStack{
                    PhotosPicker(selection: $eventBackgroundItem) {
                        Image(systemName: "plus")
                            .resizable()
                            .scaledToFit()
                            .padding(20)
                            .background {
                                RoundedRectangle(cornerRadius: 5).fill(.ultraThinMaterial)
                            }
                            .frame(width: 150, height: 150)
                    }
                    ForEach(backgroundLocalImages){ image in
                        image.viewResizedImage
                                .resizable()
                                .scaledToFill()
                                .frame(width: 150, height: 150)
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                                .onTapGesture {
                                    //                                locationBackground = backImages[index]
                                    //                                globalStorage.container.saveContext()
                                    //                                isBackSheetShowed.toggle()
//                                    addExistBackgroundAction(index)
//                                    dismiss()
                                    Task{
                                        DataManager.shared.removeLocalImage(image, inContext: .main)
                                        DataManager.shared.saveContext(type: .main,publish: .images, id: [])
                                    }
                                }
                                .border(.red, width: 2)
//                        }
                    }
                }
            }
            .scrollIndicators(.hidden)
            .padding()
        }
        .onChange(of: eventBackgroundItem) { newValue in
            guard let item = eventBackgroundItem else { return }
            Task{
                if let data = try? await item.loadTransferable(type: Data.self),
                   let uiimage = UIImage(data: data){
                    addNewBackgroundAction(uiimage, Image(uiImage: uiimage))
                    dismiss()
                }
            }
        }
        
    }
}

#Preview {
    AddEditEventBackgroundView(
                                addNewBackgroundAction: {_,_ in },
                                addExistBackgroundAction: {_ in })
        .environment(\.managedObjectContext, DataManager.shared.moc)
        
}
