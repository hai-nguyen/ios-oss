public enum ShortcutItem {
  case creatorDashboard
  case projectsWeLove
  case recommendedForYou
  case search

  public init?(typeString: String) {
    switch typeString {
    case "creator_dashboard":
      self = .creatorDashboard
    case "projects_we_love":
      self = .projectsWeLove
    case "recommended_for_you":
      self = .recommendedForYou
    case "search":
      self = .search
    default:
      return nil
    }
  }

  public var typeString: String {
    switch self {
    case .creatorDashboard:
      return "creator_dashboard"
    case .projectsWeLove:
      return "projects_we_love"
    case .recommendedForYou:
      return "recommended_for_you"
    case .search:
      return "search"
    }
  }
}

extension ShortcutItem: Equatable {}
public func == (lhs: ShortcutItem, rhs: ShortcutItem) -> Bool {
  switch (lhs, rhs) {
  case (.creatorDashboard, .creatorDashboard), (.projectsWeLove, .projectsWeLove),
       (.recommendedForYou, .recommendedForYou), (.search, .search):
    return true
  default:
    return false
  }
}
