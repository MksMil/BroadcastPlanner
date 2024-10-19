import Foundation

// global  constants : properties, string, localizeble strings, network links

struct GlobalProperties {
 
    enum Path: String{
        case users, events, locations, clubs, broadcasters, images
    }
    
}

enum TeamLogos: String, CaseIterable, Identifiable {
    case Chernomorets, Dynamo, Ingulets, Kolos, Krivbass, LNZ, Lviv, Metalist1925, Minaj, Oleksandriya, Rukh,SC_Dnipro_1, Shakhtar, Veres, Vorskla, Zorya
    var id: Self { self }
}

enum Stadiums: String, CaseIterable, Identifiable{
    var id: Self {self}
    case Krivbass_1_stad, Krivbass_2_stad, Krivbass_3_stad, LNZ_stad, Oleksandria_stad
    var description: String {
        String(self.rawValue.prefix { character in
            character != "_"
        })
    }
}
