import Alamofire
import Foundation
import SwiftyJSON

final class SponsorBlockAPI: ObservableObject {
    static let categories = ["sponsor", "selfpromo", "outro", "intro", "music_offtopic", "interaction"]

    var id: String

    @Published var segments = [Segment]()

    init(_ id: String) {
        self.id = id
    }

    func load() {
        AF.request("https://sponsor.ajay.app/api/skipSegments", parameters: parameters).responseJSON { response in
            switch response.result {
            case let .success(value):
                self.segments = JSON(value).arrayValue.map { SponsorBlockSegment($0) }
            case let .failure(error):
                print(error)
            }
        }
    }

    private var parameters: [String: String] {
        [
            "videoID": id,
            "categories": JSON(SponsorBlockAPI.categories).rawString(String.Encoding.utf8)!
        ]
    }
}