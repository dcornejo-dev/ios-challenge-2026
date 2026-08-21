import Moya

enum CatBreedsTarget {
    case getBreeds(page: Int, limit: Int)
}

extension CatBreedsTarget: NetworkingTargetType {
    var requestPath: String {
        switch self {
        case .getBreeds:
            return "breeds"
        }
    }

    var requestMethod: RequestMethod {
        switch self {
        case .getBreeds:
            return .get
        }
    }

    var task: Moya.Task {
        switch self {
        case .getBreeds(let page, let limit):
            return .requestParameters(
                parameters: ["page": page, "limit": limit],
                encoding: URLEncoding.queryString
            )
        }
    }
}
