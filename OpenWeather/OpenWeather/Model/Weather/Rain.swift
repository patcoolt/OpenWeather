
import Foundation

struct Rain: Codable {
    
    var h1: Double? = nil
    
    enum CodingKeys: String, CodingKey {
        
        case h1 = "1h"
        
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        h1 = try values.decodeIfPresent(Double.self , forKey: .h1)
        
    }
    
    init() {
        
    }
    
}
