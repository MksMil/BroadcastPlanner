import Foundation

class UserDataManager {
    
    
    
    // MARK: - Users array control?
    func addUser(user: BPUserLocalData){
        
    }
    
    /// function that removes uesr
    func removeUser(){
        
    }
    
    func updateUser(user: BPUserLocalData){
        
    }
    
    // MARK: - Migration
    
    func migrateToLocal(user: BPUser) -> BPUserLocalData?{
        return nil
    }
    
    func migrateToGlobal(user: BPUserLocalData) -> BPUser?{
        return nil
    }
    
}
