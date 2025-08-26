import SwiftUI

struct ImageWrapper: View {
    @EnvironmentObject var dataManager: DataManager
    
    let id: String
    let type: GlobalProperties.ImageType
    let imageSize: ImageSizes
    let placeHolder: String
    
    @State private var image: Image
    @State private var isLoading: Bool = false
    
    init(id: String?, type: GlobalProperties.ImageType,imageSize: ImageSizes, placeHolder: String = "photo", image: Image = Image(systemName: "photo")) {
        self.id = id ?? ""
        self.type = type
        self.imageSize = imageSize
        self.placeHolder = placeHolder
        self.image = Image(systemName: placeHolder)
    }
    
    var body: some View {
#if DEBUG
        let _ = Self._printChanges()
#endif
            image
                .resizable()
                .opacity(isLoading ? 0.3: 1)
                .overlay{
                    if isLoading{
                        ProgressView()
                    }
                }
                .task{
                    update()
                }
                .onReceive(dataManager.updatePublisher) { value in
//                    print("wrapper received \(value) with id: \(id)")
                    guard !id.isEmpty else { return }
                    if value.0 == .images, value.1.contains(id){
                        update()
                    }
                }
    }
    
    func update(){
//        print("start to update image")
        guard !id.isEmpty else { return }
        isLoading = true
        Task{
            if let newImage = await dataManager.getImageWithId(id, type: type, size: imageSize){
//                print("get new image")
                await MainActor.run {
                    image = Image(uiImage: newImage)
                }
            } //else {
//                print("not update image")
//            }
            await MainActor.run {
                isLoading = false
            }
        }
    }
}

