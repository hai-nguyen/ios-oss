@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class ProjectPamphletViewModelTests: TestCase {
  private let releaseBundle = MockBundle(
    bundleIdentifier: KickstarterBundleIdentifier.release.rawValue,
    lang: "en"
  )
  fileprivate var vm: ProjectPamphletViewModelType!

  private let configureChildViewControllersWithProject = TestObserver<Project, Never>()
  private let configureChildViewControllersWithRefTag = TestObserver<RefTag?, Never>()
  private let configurePledgeCTAViewErrorEnvelope = TestObserver<ErrorEnvelope, Never>()
  private let configurePledgeCTAViewProject = TestObserver<Project, Never>()
  private let configurePledgeCTAViewIsLoading = TestObserver<Bool, Never>()
  private let configurePledgeCTAViewRefTag = TestObserver<RefTag?, Never>()
  private let dismissManagePledgeAndShowMessageBannerWithMessage = TestObserver<String, Never>()
  private let goToDeprecatedManagePledgeProject = TestObserver<Project, Never>()
  private let goToDeprecatedManagePledgeRefTag = TestObserver<RefTag?, Never>()
  private let goToDeprecatedManagePledgeReward = TestObserver<Reward, Never>()
  private let goToDeprecatedViewBackingProject = TestObserver<Project, Never>()
  private let goToDeprecatedViewBackingUser = TestObserver<User?, Never>()
  private let goToManageViewPledge = TestObserver<Project, Never>()
  private let goToRewardsProject = TestObserver<Project, Never>()
  private let goToRewardsRefTag = TestObserver<RefTag?, Never>()
  private let setNavigationBarHidden = TestObserver<Bool, Never>()
  private let setNavigationBarAnimated = TestObserver<Bool, Never>()
  private let setNeedsStatusBarAppearanceUpdate = TestObserver<(), Never>()
  private let topLayoutConstraintConstant = TestObserver<CGFloat, Never>()

  internal override func setUp() {
    super.setUp()

    self.vm = ProjectPamphletViewModel()
    self.vm.outputs.configureChildViewControllersWithProject.map(first)
      .observe(self.configureChildViewControllersWithProject.observer)
    self.vm.outputs.configureChildViewControllersWithProject.map(second)
      .observe(self.configureChildViewControllersWithRefTag.observer)

    self.vm.outputs.configurePledgeCTAView
      .map(first)
      .map(\.left)
      .skipNil()
      .map(first)
      .observe(self.configurePledgeCTAViewProject.observer)

    self.vm.outputs.configurePledgeCTAView
      .map(first)
      .map(\.left)
      .skipNil()
      .map(second)
      .observe(self.configurePledgeCTAViewRefTag.observer)

    self.vm.outputs.configurePledgeCTAView
      .map(first)
      .map(\.right)
      .skipNil()
      .observe(self.configurePledgeCTAViewErrorEnvelope.observer)

    self.vm.outputs.configurePledgeCTAView.map(second).observe(self.configurePledgeCTAViewIsLoading.observer)
    self.vm.outputs.dismissManagePledgeAndShowMessageBannerWithMessage
      .observe(self.dismissManagePledgeAndShowMessageBannerWithMessage.observer)
    self.vm.outputs.goToDeprecatedManagePledge.map { $0.project }
      .observe(self.goToDeprecatedManagePledgeProject.observer)
    self.vm.outputs.goToDeprecatedManagePledge.map { $0.reward }
      .observe(self.goToDeprecatedManagePledgeReward.observer)
    self.vm.outputs.goToDeprecatedManagePledge.map { $0.refTag }
      .observe(self.goToDeprecatedManagePledgeRefTag.observer)
    self.vm.outputs.goToManagePledge.observe(self.goToManageViewPledge.observer)
    self.vm.outputs.goToRewards.map(first).observe(self.goToRewardsProject.observer)
    self.vm.outputs.goToRewards.map(second).observe(self.goToRewardsRefTag.observer)
    self.vm.outputs.goToDeprecatedViewBacking.map(first)
      .observe(self.goToDeprecatedViewBackingProject.observer)
    self.vm.outputs.goToDeprecatedViewBacking.map(second).observe(self.goToDeprecatedViewBackingUser.observer)
    self.vm.outputs.setNavigationBarHiddenAnimated.map(first)
      .observe(self.setNavigationBarHidden.observer)
    self.vm.outputs.setNavigationBarHiddenAnimated.map(second)
      .observe(self.setNavigationBarAnimated.observer)
    self.vm.outputs.setNeedsStatusBarAppearanceUpdate.observe(self.setNeedsStatusBarAppearanceUpdate.observer)
    self.vm.outputs.topLayoutConstraintConstant.observe(self.topLayoutConstraintConstant.observer)
  }

  func testConfigureChildViewControllersWithProject_ConfiguredWithProject() {
    let project = Project.template
    let refTag = RefTag.category
    self.vm.inputs.configureWith(projectOrParam: .left(project), refTag: refTag)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewDidAppear(animated: false)

    self.configureChildViewControllersWithProject.assertValues([project])
    self.configureChildViewControllersWithRefTag.assertValues([refTag])

    self.scheduler.advance()

    self.configureChildViewControllersWithProject.assertValues([project, project])
    self.configureChildViewControllersWithRefTag.assertValues([refTag, refTag])

    self.vm.inputs.didBackProject()

    self.scheduler.advance()

    self.configureChildViewControllersWithProject.assertValues([project, project, project])
    self.configureChildViewControllersWithRefTag.assertValues([refTag, refTag, refTag])

    self.vm.inputs.managePledgeViewControllerFinished(with: nil)

    self.scheduler.advance()

    self.configureChildViewControllersWithProject.assertValues([project, project, project, project])
    self.configureChildViewControllersWithRefTag.assertValues([refTag, refTag, refTag, refTag])
  }

  func testConfigureChildViewControllersWithProject_ConfiguredWithParam() {
    let project = .template |> Project.lens.id .~ 42

    self.vm.inputs.configureWith(projectOrParam: .right(.id(project.id)), refTag: nil)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear(animated: false)
    self.vm.inputs.viewDidAppear(animated: false)

    self.configureChildViewControllersWithProject.assertValues([])
    self.configureChildViewControllersWithRefTag.assertValues([])

    self.scheduler.advance()

    self.configureChildViewControllersWithProject.assertValues([project])
    self.configureChildViewControllersWithRefTag.assertValues([nil])

    self.vm.inputs.didBackProject()

    self.scheduler.advance()

    self.configureChildViewControllersWithProject.assertValues([project, project])
    self.configureChildViewControllersWithRefTag.assertValues([nil, nil])

    self.vm.inputs.managePledgeViewControllerFinished(with: nil)

    self.scheduler.advance()

    self.configureChildViewControllersWithProject.assertValues([project, project, project])
    self.configureChildViewControllersWithRefTag.assertValues([nil, nil, nil])
  }

  func testNavigationBar() {
    self.vm.inputs.configureWith(projectOrParam: .left(.template), refTag: nil)
    self.vm.inputs.viewDidLoad()

    self.setNavigationBarHidden.assertValues([true])
    self.setNavigationBarAnimated.assertValues([false])

    self.vm.inputs.viewWillAppear(animated: false)
    self.vm.inputs.viewDidAppear(animated: false)

    self.setNavigationBarHidden.assertValues([true])
    self.setNavigationBarAnimated.assertValues([false])

    self.vm.inputs.viewWillAppear(animated: true)
    self.vm.inputs.viewDidAppear(animated: true)

    self.setNavigationBarHidden.assertValues([true, true])
    self.setNavigationBarAnimated.assertValues([false, true])

    self.vm.inputs.viewWillAppear(animated: false)
    self.vm.inputs.viewDidAppear(animated: true)

    self.setNavigationBarHidden.assertValues([true, true, true])
    self.setNavigationBarAnimated.assertValues([false, true, false])
  }

  // Tests that ref tags and referral credit cookies are tracked in koala and saved like we expect.
  func testTracksRefTag() {
    let project = Project.template

    self.vm.inputs.configureWith(projectOrParam: .left(project), refTag: .category)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear(animated: false)
    self.vm.inputs.viewDidAppear(animated: false)

    self.scheduler.advance()

    XCTAssertEqual(
      ["Project Page Viewed"],
      self.trackingClient.events, "A project page event is tracked."
    )
    XCTAssertEqual(
      [RefTag.category.stringTag],
      self.trackingClient.properties.compactMap { $0["session_ref_tag"] as? String },
      "The ref tag is tracked in the koala event."
    )
    XCTAssertEqual(
      [RefTag.category.stringTag],
      self.trackingClient.properties.compactMap { $0["session_referrer_credit"] as? String },
      "The referral credit is tracked in the koala event."
    )
    XCTAssertEqual(
      1, self.cookieStorage.cookies?.count,
      "A single cookie is set"
    )
    XCTAssertEqual(
      "ref_\(project.id)", self.cookieStorage.cookies?.last?.name,
      "A referral cookie is set for the project."
    )
    XCTAssertEqual(
      "category?",
      (self.cookieStorage.cookies?.last?.value.prefix(9)).map(String.init),
      "A referral cookie is set for the category ref tag."
    )

    // Start up another view model with the same project
    let newVm: ProjectPamphletViewModelType = ProjectPamphletViewModel()
    newVm.inputs.configureWith(projectOrParam: .left(project), refTag: .recommended)
    newVm.inputs.viewDidLoad()
    newVm.inputs.viewWillAppear(animated: true)
    newVm.inputs.viewDidAppear(animated: true)

    self.scheduler.advance()

    XCTAssertEqual(
      [
        "Project Page Viewed", "Project Page Viewed"
      ],
      self.trackingClient.events, "A project page koala event is tracked."
    )
    XCTAssertEqual(
      [
        RefTag.category.stringTag,
        RefTag.recommended.stringTag
      ],
      self.trackingClient.properties.compactMap { $0["session_ref_tag"] as? String },
      "The new ref tag is tracked in koala event."
    )
    XCTAssertEqual(
      [
        RefTag.category.stringTag,
        RefTag.category.stringTag
      ],
      self.trackingClient.properties.compactMap { $0["session_referrer_credit"] as? String },
      "The referrer credit did not change, and is still category."
    )
    XCTAssertEqual(
      1, self.cookieStorage.cookies?.count,
      "A single cookie has been set."
    )
  }

  func testProjectPageViewed_Tracking_OnError() {
    let service = MockService(fetchProjectError: .couldNotParseJSON)

    withEnvironment(apiService: service) {
      self.configureInitialState(.init(left: .template))

      self.scheduler.advance()

      XCTAssertEqual(
        [],
        self.trackingClient.events,
        "Project Page Viewed doesnt track if the request fails"
      )
    }
  }

  func testProjectPaveViewed_OnViewDidAppear() {
    XCTAssertEqual([], self.trackingClient.events)

    self.configureInitialState(.init(left: .template))

    self.scheduler.advance()

    XCTAssertEqual(["Project Page Viewed"], self.trackingClient.events)
  }

  func testMockCookieStorageSet_SeparateSchedulers() {
    let project = Project.template
    let scheduler1 = TestScheduler(startDate: MockDate().date)
    let scheduler2 = TestScheduler(startDate: scheduler1.currentDate.addingTimeInterval(1))

    withEnvironment(scheduler: scheduler1) {
      let newVm: ProjectPamphletViewModelType = ProjectPamphletViewModel()
      newVm.inputs.configureWith(projectOrParam: .left(project), refTag: .category)
      newVm.inputs.viewDidLoad()
      newVm.inputs.viewWillAppear(animated: true)
      newVm.inputs.viewDidAppear(animated: true)

      scheduler1.advance()

      XCTAssertEqual(1, self.cookieStorage.cookies?.count, "A single cookie has been set.")
    }

    withEnvironment(scheduler: scheduler2) {
      let newVm: ProjectPamphletViewModelType = ProjectPamphletViewModel()
      newVm.inputs.configureWith(projectOrParam: .left(project), refTag: .recommended)
      newVm.inputs.viewDidLoad()
      newVm.inputs.viewWillAppear(animated: true)
      newVm.inputs.viewDidAppear(animated: true)

      scheduler2.advance()

      XCTAssertEqual(2, self.cookieStorage.cookies?.count, "Two cookies are set on separate schedulers.")
    }
  }

  func testMockCookieStorageSet_SameScheduler() {
    let project = Project.template
    let scheduler1 = TestScheduler(startDate: MockDate().date)

    withEnvironment(scheduler: scheduler1) {
      let newVm: ProjectPamphletViewModelType = ProjectPamphletViewModel()
      newVm.inputs.configureWith(projectOrParam: .left(project), refTag: .category)
      newVm.inputs.viewDidLoad()
      newVm.inputs.viewWillAppear(animated: true)
      newVm.inputs.viewDidAppear(animated: true)

      scheduler1.advance()

      XCTAssertEqual(1, self.cookieStorage.cookies?.count, "A single cookie has been set.")
    }

    withEnvironment(scheduler: scheduler1) {
      let newVm: ProjectPamphletViewModelType = ProjectPamphletViewModel()
      newVm.inputs.configureWith(projectOrParam: .left(project), refTag: .recommended)
      newVm.inputs.viewDidLoad()
      newVm.inputs.viewWillAppear(animated: true)
      newVm.inputs.viewDidAppear(animated: true)

      scheduler1.advance()

      XCTAssertEqual(
        1, self.cookieStorage.cookies?.count,
        "A single cookie has been set on the same scheduler."
      )
    }
  }

  func testTopLayoutConstraints_AfterRotation() {
    self.vm.inputs.initial(topConstraint: 30.0)
    XCTAssertNil(self.topLayoutConstraintConstant.lastValue)

    self.vm.inputs.willTransition(toNewCollection: UITraitCollection(horizontalSizeClass: .compact))
    XCTAssertEqual(30.0, self.topLayoutConstraintConstant.lastValue)
  }

  func testTracksRefTag_WithBadData() {
    let project = Project.template

    self.vm.inputs.configureWith(
      projectOrParam: .left(project), refTag: RefTag.unrecognized("category%3F1232")
    )
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear(animated: false)
    self.vm.inputs.viewDidAppear(animated: false)

    self.scheduler.advance()

    XCTAssertEqual(
      ["Project Page Viewed"],
      self.trackingClient.events, "A project page koala event is tracked."
    )
    XCTAssertEqual(
      [RefTag.category.stringTag],
      self.trackingClient.properties.compactMap { $0["session_ref_tag"] as? String },
      "The ref tag is tracked in the koala event."
    )
    XCTAssertEqual(
      [RefTag.category.stringTag],
      self.trackingClient.properties.compactMap { $0["session_referrer_credit"] as? String },
      "The referral credit is tracked in the koala event."
    )
    XCTAssertEqual(
      1, self.cookieStorage.cookies?.count,
      "A single cookie is set"
    )
    XCTAssertEqual(
      "ref_\(project.id)", self.cookieStorage.cookies?.last?.name,
      "A referral cookie is set for the project."
    )
    XCTAssertEqual(
      "category?",
      (self.cookieStorage.cookies?.last?.value.prefix(9)).map(String.init),
      "A referral cookie is set for the category ref tag."
    )

    // Start up another view model with the same project
    let newVm: ProjectPamphletViewModelType = ProjectPamphletViewModel()
    newVm.inputs.configureWith(projectOrParam: .left(project), refTag: .recommended)
    newVm.inputs.viewDidLoad()
    newVm.inputs.viewWillAppear(animated: true)
    newVm.inputs.viewDidAppear(animated: true)

    self.scheduler.advance()

    XCTAssertEqual(
      [
        "Project Page Viewed", "Project Page Viewed"
      ],
      self.trackingClient.events, "A project page koala event is tracked."
    )
    XCTAssertEqual(
      [
        RefTag.category.stringTag,
        RefTag.recommended.stringTag
      ],
      self.trackingClient.properties.compactMap { $0["session_ref_tag"] as? String },
      "The new ref tag is tracked in koala event."
    )
    XCTAssertEqual(
      [
        RefTag.category.stringTag, RefTag.category.stringTag
      ],
      self.trackingClient.properties.compactMap { $0["session_referrer_credit"] as? String },
      "The referrer credit did not change, and is still category."
    )
    XCTAssertEqual(
      1, self.cookieStorage.cookies?.count,
      "A single cookie has been set."
    )
  }

  func testTrackingDoesNotOccurOnLoad() {
    let project = Project.template

    self.vm.inputs.configureWith(
      projectOrParam: .left(project), refTag: RefTag.unrecognized("category%3F1232")
    )
    self.vm.inputs.viewDidLoad()

    self.scheduler.advance()

    XCTAssertEqual([], self.trackingClient.events)
  }

  func testGoToRewards() {
    let config = Config.template
      |> \.features .~ [Feature.nativeCheckout.rawValue: true]
      |> \.abExperiments .~ [Experiment.Name.nativeCheckoutV1.rawValue: "experimental"]

    withEnvironment(config: config, mainBundle: self.releaseBundle) {
      let project = Project.template

      self.configureInitialState(.left(project))

      self.goToRewardsProject.assertDidNotEmitValue()
      self.goToRewardsRefTag.assertDidNotEmitValue()

      self.vm.inputs.pledgeCTAButtonTapped(with: .pledge)

      self.goToRewardsProject.assertValues([project], "Tapping 'Back this project' emits the project")
      self.goToRewardsRefTag.assertValues([.discovery], "Tapping 'Back this project' emits the refTag")

      self.vm.inputs.pledgeCTAButtonTapped(with: .viewRewards)

      self.goToRewardsProject.assertValues(
        [project, project],
        "Tapping 'View rewards' emits the project"
      )
      self.goToRewardsRefTag.assertValues(
        [.discovery, .discovery],
        "Tapping 'View rewards' emits the refTag"
      )

      self.vm.inputs.pledgeCTAButtonTapped(with: .viewYourRewards)

      self.goToRewardsProject.assertValues(
        [project, project, project],
        "Tapping 'View your rewards' emits the project"
      )
      self.goToRewardsRefTag.assertValues(
        [.discovery, .discovery, .discovery],
        "Tapping 'View your rewards' emits the refTag"
      )
    }
  }

  func testGoToManageViewPledge_ManagingPledge_FeatureNativeCheckoutPledgeView_Enabled() {
    let config = .template
      |> Config.lens.features .~ [Feature.nativeCheckoutPledgeView.rawValue: true]

    withEnvironment(config: config) {
      let reward = Project.cosmicSurgery.rewards.first!
      let backing = Backing.template
        |> Backing.lens.reward .~ reward
        |> Backing.lens.rewardId .~ reward.id

      let project = Project.cosmicSurgery
        |> Project.lens.personalization.backing .~ backing
        |> Project.lens.personalization.isBacking .~ true

      self.configureInitialState(.left(project))

      self.goToManageViewPledge.assertDidNotEmitValue()

      self.vm.inputs.pledgeCTAButtonTapped(with: .manage)

      self.goToManageViewPledge.assertValues([project])

      self.goToDeprecatedViewBackingUser.assertDidNotEmitValue()
      self.goToDeprecatedViewBackingProject.assertDidNotEmitValue()

      self.goToDeprecatedManagePledgeProject.assertDidNotEmitValue()
      self.goToDeprecatedManagePledgeReward.assertDidNotEmitValue()
      self.goToDeprecatedManagePledgeRefTag.assertDidNotEmitValue()
    }
  }

  func testGoToDeprecatedManagePledge_ManagingPledge_featureNativeCheckoutPledgeView_Disabled() {
    let config = .template
      |> Config.lens.features .~ [Feature.nativeCheckoutPledgeView.rawValue: false]

    withEnvironment(config: config) {
      let reward = Project.cosmicSurgery.rewards.first!
      let backing = Backing.template
        |> Backing.lens.reward .~ reward
        |> Backing.lens.rewardId .~ reward.id

      let project = Project.cosmicSurgery
        |> Project.lens.personalization.backing .~ backing
        |> Project.lens.personalization.isBacking .~ true

      self.configureInitialState(.left(project))

      self.goToDeprecatedManagePledgeProject.assertDidNotEmitValue()
      self.goToDeprecatedManagePledgeReward.assertDidNotEmitValue()
      self.goToDeprecatedManagePledgeRefTag.assertDidNotEmitValue()

      self.vm.inputs.pledgeCTAButtonTapped(with: .manage)

      self.goToDeprecatedManagePledgeProject.assertValues([project])
      self.goToDeprecatedManagePledgeReward.assertValues([project.rewards[0]])
      self.goToDeprecatedManagePledgeRefTag.assertValues([.discovery])

      self.goToManageViewPledge.assertDidNotEmitValue()

      self.goToDeprecatedViewBackingUser.assertDidNotEmitValue()
      self.goToDeprecatedViewBackingProject.assertDidNotEmitValue()
    }
  }

  func testGoToManageViewPledge_ViewingPledge_featureNativeCheckoutPledgeView_Enabled() {
    let config = .template
      |> Config.lens.features .~ [Feature.nativeCheckoutPledgeView.rawValue: true]
    let user = User.template

    withEnvironment(config: config, currentUser: user) {
      let reward = Project.cosmicSurgery.rewards.first!
      let backing = Backing.template
        |> Backing.lens.reward .~ reward
        |> Backing.lens.rewardId .~ reward.id

      let project = Project.cosmicSurgery
        |> Project.lens.state .~ .successful
        |> Project.lens.personalization.backing .~ backing
        |> Project.lens.personalization.isBacking .~ true

      self.configureInitialState(.left(project))

      self.goToManageViewPledge.assertDidNotEmitValue()

      self.vm.inputs.pledgeCTAButtonTapped(with: .viewBacking)

      self.goToManageViewPledge.assertValues([project])

      self.goToDeprecatedViewBackingUser.assertDidNotEmitValue()
      self.goToDeprecatedViewBackingProject.assertDidNotEmitValue()

      self.goToDeprecatedManagePledgeProject.assertDidNotEmitValue()
      self.goToDeprecatedManagePledgeReward.assertDidNotEmitValue()
      self.goToDeprecatedManagePledgeRefTag.assertDidNotEmitValue()
    }
  }

  func testGoToDeprecatedViewBacking_NativeCheckoutPledgeViewFeature_Disabled() {
    let config = .template
      |> Config.lens.features .~ [Feature.nativeCheckoutPledgeView.rawValue: false]
    let user = User.template

    withEnvironment(config: config, currentUser: user) {
      let reward = Project.cosmicSurgery.rewards.first!
      let backing = Backing.template
        |> Backing.lens.reward .~ reward
        |> Backing.lens.rewardId .~ reward.id

      let project = Project.cosmicSurgery
        |> Project.lens.state .~ .successful
        |> Project.lens.personalization.backing .~ backing
        |> Project.lens.personalization.isBacking .~ true

      self.configureInitialState(.left(project))

      self.goToDeprecatedViewBackingUser.assertDidNotEmitValue()
      self.goToDeprecatedViewBackingProject.assertDidNotEmitValue()

      self.vm.inputs.pledgeCTAButtonTapped(with: .viewBacking)

      self.goToDeprecatedViewBackingUser.assertValues([user])
      self.goToDeprecatedViewBackingProject.assertValues([project])

      self.goToDeprecatedManagePledgeProject.assertDidNotEmitValue()
      self.goToDeprecatedManagePledgeReward.assertDidNotEmitValue()
      self.goToDeprecatedManagePledgeRefTag.assertDidNotEmitValue()

      self.goToManageViewPledge.assertDidNotEmitValue()
    }
  }

  func testGoToViewBacking_NativeCheckoutPledgeViewFeature_Disabled() {}

  func testConfigurePledgeCTAView_fetchProjectSuccess_featureEnabled_experimentEnabled() {
    let config = Config.template
      |> \.features .~ [Feature.nativeCheckout.rawValue: true]
      |> \.abExperiments .~ [Experiment.Name.nativeCheckoutV1.rawValue: "experimental"]

    let project = Project.template
    let projectFull = Project.template
      |> \.id .~ 2
      |> Project.lens.personalization.isBacking .~ true

    let mockService = MockService(fetchProjectResponse: projectFull)

    withEnvironment(
      apiService: mockService,
      apiDelayInterval: .seconds(1),
      config: config,
      mainBundle: releaseBundle
    ) {
      self.configurePledgeCTAViewProject.assertDidNotEmitValue()
      self.configurePledgeCTAViewIsLoading.assertDidNotEmitValue()

      self.configureInitialState(.left(project))

      self.configurePledgeCTAViewProject.assertValues([project])
      self.configurePledgeCTAViewIsLoading.assertValues([true])
      self.configurePledgeCTAViewRefTag.assertValues([.discovery])

      self.scheduler.run()

      self.configurePledgeCTAViewProject.assertValues([project, projectFull, projectFull])
      self.configurePledgeCTAViewIsLoading.assertValues([true, true, false])
      self.configurePledgeCTAViewRefTag.assertValues([.discovery, .discovery, .discovery])
    }
  }

  func testConfigurePledgeCTAView_fetchProjectSuccess_featureEnabled_experimentDisabled() {
    let config = Config.template
      |> \.features .~ [Feature.nativeCheckout.rawValue: true]
      |> \.abExperiments .~ [Experiment.Name.nativeCheckoutV1.rawValue: "control"]
    let project = Project.template
    let projectFull = Project.template
      |> \.id .~ 2
      |> Project.lens.personalization.isBacking .~ true

    let mockService = MockService(fetchProjectResponse: projectFull)

    withEnvironment(
      apiService: mockService,
      apiDelayInterval: .seconds(1),
      config: config,
      mainBundle: releaseBundle
    ) {
      self.configurePledgeCTAViewProject.assertDidNotEmitValue()
      self.configurePledgeCTAViewIsLoading.assertDidNotEmitValue()
      self.configurePledgeCTAViewRefTag.assertDidNotEmitValue()

      self.configureInitialState(.left(project))

      self.configurePledgeCTAViewProject.assertDidNotEmitValue()
      self.configurePledgeCTAViewIsLoading.assertDidNotEmitValue()
      self.configurePledgeCTAViewRefTag.assertDidNotEmitValue()

      self.scheduler.run()

      self.configurePledgeCTAViewProject.assertDidNotEmitValue()
      self.configurePledgeCTAViewIsLoading.assertDidNotEmitValue()
      self.configurePledgeCTAViewRefTag.assertDidNotEmitValue()
    }
  }

  func testConfigurePledgeCTAView_fetchProjectFailure_featureEnabled_experimentEnabled() {
    let config = Config.template
      |> \.features .~ [Feature.nativeCheckout.rawValue: true]
      |> \.abExperiments .~ [Experiment.Name.nativeCheckoutV1.rawValue: "experimental"]
    let project = Project.template
    let mockService = MockService(fetchProjectError: .couldNotParseJSON)

    withEnvironment(
      apiService: mockService,
      apiDelayInterval: .seconds(1),
      config: config,
      mainBundle: releaseBundle
    ) {
      self.configurePledgeCTAViewProject.assertDidNotEmitValue()
      self.configurePledgeCTAViewIsLoading.assertDidNotEmitValue()
      self.configurePledgeCTAViewRefTag.assertDidNotEmitValue()

      self.configureInitialState(.left(project))

      self.configurePledgeCTAViewProject.assertValues([project])
      self.configurePledgeCTAViewIsLoading.assertValues([true])
      self.configurePledgeCTAViewRefTag.assertValues([.discovery])

      self.scheduler.run()

      self.configurePledgeCTAViewProject.assertValues([project, project])
      self.configurePledgeCTAViewErrorEnvelope.assertValueCount(1)
      self.configurePledgeCTAViewIsLoading.assertValues([true, false, false])
      self.configurePledgeCTAViewRefTag.assertValues([.discovery, .discovery])
    }
  }

  func testConfigurePledgeCTAView_fetchProjectFailure_featureEnabled_experimentDisabled() {
    let config = Config.template
      |> \.features .~ [Feature.nativeCheckout.rawValue: true]
      |> \.abExperiments .~ [Experiment.Name.nativeCheckoutV1.rawValue: "control"]
    let project = Project.template
    let mockService = MockService(fetchProjectError: .couldNotParseJSON)

    withEnvironment(
      apiService: mockService,
      apiDelayInterval: .seconds(1),
      config: config,
      mainBundle: releaseBundle
    ) {
      self.configurePledgeCTAViewProject.assertDidNotEmitValue()
      self.configurePledgeCTAViewIsLoading.assertDidNotEmitValue()
      self.configurePledgeCTAViewRefTag.assertDidNotEmitValue()

      self.configureInitialState(.left(project))

      self.configurePledgeCTAViewProject.assertDidNotEmitValue()
      self.configurePledgeCTAViewIsLoading.assertDidNotEmitValue()
      self.configurePledgeCTAViewRefTag.assertDidNotEmitValue()

      self.scheduler.run()

      self.configurePledgeCTAViewProject.assertDidNotEmitValue()
      self.configurePledgeCTAViewIsLoading.assertDidNotEmitValue()
      self.configurePledgeCTAViewRefTag.assertDidNotEmitValue()
    }
  }

  func testConfigurePledgeCTAView_reloadsUponBackProject_featureEnabled_experimentEnabled() {
    let config = Config.template
      |> \.features .~ [Feature.nativeCheckout.rawValue: true]
      |> \.abExperiments .~ [Experiment.Name.nativeCheckoutV1.rawValue: "experimental"]

    let project = Project.template
    let projectFull = Project.template
      |> Project.lens.rewards .~ [Reward.noReward, Reward.template]

    let backedProject = Project.template
      |> Project.lens.personalization.backing .~ Backing.template
      |> Project.lens.personalization.isBacking .~ true

    let mockService = MockService(fetchProjectResponse: projectFull)

    withEnvironment(apiService: mockService, config: config, mainBundle: releaseBundle) {
      self.configurePledgeCTAViewProject.assertDidNotEmitValue()
      self.configurePledgeCTAViewIsLoading.assertDidNotEmitValue()
      self.configurePledgeCTAViewRefTag.assertDidNotEmitValue()

      self.vm.inputs.configureWith(projectOrParam: .left(project), refTag: .discovery)
      self.vm.inputs.viewDidLoad()
      self.vm.inputs.viewDidAppear(animated: true)

      self.configurePledgeCTAViewProject.assertValues([project])
      self.configurePledgeCTAViewIsLoading.assertValues([true])
      self.configurePledgeCTAViewRefTag.assertValues([.discovery])

      self.scheduler.advance()

      self.configurePledgeCTAViewProject.assertValues([project, project, projectFull])
      self.configurePledgeCTAViewIsLoading.assertValues([true, true, false])
      self.configurePledgeCTAViewRefTag.assertValues([.discovery, .discovery, .discovery])
    }

    withEnvironment(
      apiService: MockService(fetchProjectResponse: backedProject),
      config: config,
      mainBundle: releaseBundle
    ) {
      self.vm.inputs.didBackProject()

      self.configurePledgeCTAViewProject.assertValues([project, project, projectFull, projectFull])
      self.configurePledgeCTAViewIsLoading.assertValues([true, true, false, true])
      self.configurePledgeCTAViewRefTag.assertValues([.discovery, .discovery, .discovery, .discovery])

      self.scheduler.advance()

      self.configurePledgeCTAViewProject.assertValues([project,
                                                       project,
                                                       projectFull,
                                                       projectFull,
                                                       projectFull,
                                                       backedProject])
      self.configurePledgeCTAViewIsLoading.assertValues([true, true, false, true, true, false])
      self.configurePledgeCTAViewRefTag.assertValues([.discovery,
                                                      .discovery,
                                                      .discovery,
                                                      .discovery,
                                                      .discovery,
                                                      .discovery])
    }
  }

  func testConfigurePledgeCTAView_reloadsUponUpdatePledge_featureEnabled_experimentEnabled() {
    let config = Config.template
      |> \.features .~ [Feature.nativeCheckout.rawValue: true]
      |> \.abExperiments .~ [Experiment.Name.nativeCheckoutV1.rawValue: "experimental"]
    let project = Project.template
    let projectFull = Project.template
      |> Project.lens.personalization.backing .~ (Backing.template |> Backing.lens.amount .~ 10.0)
      |> Project.lens.personalization.isBacking .~ true
    let updatedProject = Project.template
      |> Project.lens.personalization.backing .~ (Backing.template |> Backing.lens.amount .~ 15.0)
      |> Project.lens.personalization.isBacking .~ true

    let mockService = MockService(fetchProjectResponse: projectFull)

    withEnvironment(apiService: mockService, config: config, mainBundle: releaseBundle) {
      self.configurePledgeCTAViewProject.assertDidNotEmitValue()
      self.configurePledgeCTAViewIsLoading.assertDidNotEmitValue()
      self.configurePledgeCTAViewRefTag.assertDidNotEmitValue()

      self.vm.inputs.configureWith(projectOrParam: .left(project), refTag: .discovery)
      self.vm.inputs.viewDidLoad()

      self.configurePledgeCTAViewProject.assertValues([project])
      self.configurePledgeCTAViewIsLoading.assertValues([true])
      self.configurePledgeCTAViewRefTag.assertValues([.discovery])

      self.scheduler.advance()

      self.configurePledgeCTAViewProject.assertValues([project, project, projectFull])
      self.configurePledgeCTAViewIsLoading.assertValues([true, true, false])
      self.configurePledgeCTAViewRefTag.assertValues([.discovery, .discovery, .discovery])
    }

    withEnvironment(
      apiService: MockService(fetchProjectResponse: updatedProject),
      config: config,
      mainBundle: releaseBundle
    ) {
      self.vm.inputs.managePledgeViewControllerFinished(with: nil)

      self.configurePledgeCTAViewProject.assertValues([project, project, projectFull, projectFull])
      self.configurePledgeCTAViewIsLoading.assertValues([true, true, false, true])
      self.configurePledgeCTAViewRefTag.assertValues([.discovery, .discovery, .discovery, .discovery])

      self.scheduler.advance()

      self.configurePledgeCTAViewProject.assertValues([project,
                                                       project,
                                                       projectFull,
                                                       projectFull,
                                                       projectFull,
                                                       updatedProject])
      self.configurePledgeCTAViewIsLoading.assertValues([true, true, false, true, true, false])
      self.configurePledgeCTAViewRefTag.assertValues([.discovery,
                                                      .discovery,
                                                      .discovery,
                                                      .discovery,
                                                      .discovery,
                                                      .discovery])
    }
  }

  func testConfigurePledgeCTAView_reloadsUponReturnToView_featureEnabled_experimentDisabled() {
    let config = Config.template
      |> \.features .~ [Feature.nativeCheckout.rawValue: true]
      |> \.abExperiments .~ [Experiment.Name.nativeCheckoutV1.rawValue: "control"]
    let project = Project.template
    let projectFull = Project.template
      |> \.id .~ 2
      |> Project.lens.personalization.isBacking .~ true
    let projectFull2 = Project.template
      |> \.id .~ 3

    let mockService = MockService(fetchProjectResponse: projectFull)

    withEnvironment(apiService: mockService, config: config, mainBundle: releaseBundle) {
      self.configurePledgeCTAViewProject.assertDidNotEmitValue()
      self.configurePledgeCTAViewIsLoading.assertDidNotEmitValue()
      self.configurePledgeCTAViewRefTag.assertDidNotEmitValue()

      self.vm.inputs.configureWith(projectOrParam: .left(project), refTag: .discovery)
      self.vm.inputs.viewDidLoad()

      self.configurePledgeCTAViewProject.assertDidNotEmitValue()
      self.configurePledgeCTAViewIsLoading.assertDidNotEmitValue()
      self.configurePledgeCTAViewRefTag.assertDidNotEmitValue()

      self.scheduler.advance()

      self.configurePledgeCTAViewProject.assertDidNotEmitValue()
      self.configurePledgeCTAViewIsLoading.assertDidNotEmitValue()
      self.configurePledgeCTAViewRefTag.assertDidNotEmitValue()
    }

    withEnvironment(
      apiService: MockService(fetchProjectResponse: projectFull2),
      config: config,
      mainBundle: releaseBundle
    ) {
      self.vm.inputs.viewWillAppear(animated: true)
      self.vm.inputs.viewDidAppear(animated: true)

      self.configurePledgeCTAViewProject.assertDidNotEmitValue()
      self.configurePledgeCTAViewIsLoading.assertDidNotEmitValue()

      self.scheduler.advance()

      self.configurePledgeCTAViewProject.assertDidNotEmitValue()
      self.configurePledgeCTAViewIsLoading.assertDidNotEmitValue()
    }
  }

  func testConfigurePledgeCTAView_featureDisabled_experimentEnabled() {
    let config = Config.template
      |> \.features .~ [Feature.nativeCheckout.rawValue: false]
      |> \.abExperiments .~ [Experiment.Name.nativeCheckoutV1.rawValue: "experimental"]
    let project = Project.template

    withEnvironment(config: config, mainBundle: self.releaseBundle) {
      self.configureInitialState(.left(project))

      self.configurePledgeCTAViewProject.assertDidNotEmitValue()
      self.configurePledgeCTAViewIsLoading.assertDidNotEmitValue()
      self.configurePledgeCTAViewRefTag.assertDidNotEmitValue()
    }
  }

  func testConfigurePledgeCTAView_featureDisabled_experimentDisabled() {
    let config = Config.template
      |> \.features .~ [Feature.nativeCheckout.rawValue: false]
      |> \.abExperiments .~ [Experiment.Name.nativeCheckoutV1.rawValue: "control"]
    let project = Project.template

    withEnvironment(config: config, mainBundle: self.releaseBundle) {
      self.configureInitialState(.left(project))

      self.configurePledgeCTAViewProject.assertDidNotEmitValue()
      self.configurePledgeCTAViewIsLoading.assertDidNotEmitValue()
      self.configurePledgeCTAViewRefTag.assertDidNotEmitValue()
    }
  }

  func testConfigurePledgeCTAView_reloadsUponRetryButtonTappedEvent() {
    let config = Config.template
      |> \.features .~ [Feature.nativeCheckout.rawValue: true]
      |> \.abExperiments .~ [Experiment.Name.nativeCheckoutV1.rawValue: "experimental"]
    let project = Project.template
    let projectFull = Project.template
      |> \.id .~ 2
      |> Project.lens.personalization.isBacking .~ true
    let projectFull2 = Project.template
      |> \.id .~ 3

    let mockService = MockService(fetchProjectResponse: projectFull)

    withEnvironment(apiService: mockService, config: config) {
      self.configurePledgeCTAViewProject.assertDidNotEmitValue()
      self.configurePledgeCTAViewIsLoading.assertDidNotEmitValue()
      self.configurePledgeCTAViewRefTag.assertDidNotEmitValue()

      self.vm.inputs.configureWith(projectOrParam: .left(project), refTag: .discovery)
      self.vm.inputs.viewDidLoad()

      self.configurePledgeCTAViewProject.assertValues([project])
      self.configurePledgeCTAViewIsLoading.assertValues([true])
      self.configurePledgeCTAViewRefTag.assertValues([.discovery])

      self.scheduler.advance()

      self.configurePledgeCTAViewProject.assertValues([project, projectFull, projectFull])
      self.configurePledgeCTAViewIsLoading.assertValues([true, true, false])
      self.configurePledgeCTAViewRefTag.assertValues([.discovery, .discovery, .discovery])
    }

    withEnvironment(
      apiService: MockService(fetchProjectResponse: projectFull2),
      config: config
    ) {
      self.vm.inputs.pledgeRetryButtonTapped()

      self.configurePledgeCTAViewProject.assertValues([project, projectFull, projectFull, projectFull])
      self.configurePledgeCTAViewIsLoading.assertValues([true, true, false, true])

      self.scheduler.advance()

      self.configurePledgeCTAViewProject.assertValues([project,
                                                       projectFull,
                                                       projectFull,
                                                       projectFull,
                                                       projectFull2,
                                                       projectFull2])
      self.configurePledgeCTAViewIsLoading.assertValues([true, true, false, true, true, false])
      self.configurePledgeCTAViewRefTag.assertValues([.discovery,
                                                      .discovery,
                                                      .discovery,
                                                      .discovery,
                                                      .discovery,
                                                      .discovery])
    }
  }

  func testManagePledgeViewControllerFinished() {
    self.vm.inputs.configureWith(projectOrParam: .left(Project.template), refTag: .discovery)
    self.vm.inputs.viewDidLoad()

    self.dismissManagePledgeAndShowMessageBannerWithMessage.assertDidNotEmitValue()

    self.vm.inputs.managePledgeViewControllerFinished(with: "Your changes have been saved")

    self.dismissManagePledgeAndShowMessageBannerWithMessage.assertValues(["Your changes have been saved"])
  }

  // swiftlint:disable line_length
  func testOptimizelyTrackingPledgeCTAButtonTapped_LoggedOut_NonBacked() {
    self.vm.inputs.configureWith(projectOrParam: .left(.template), refTag: .discovery)
    self.vm.inputs.viewDidLoad()

    XCTAssertEqual(self.optimizelyClient.trackedUserId, nil)
    XCTAssertEqual(self.optimizelyClient.trackedEventKey, nil)
    XCTAssertNil(self.optimizelyClient.trackedAttributes)
    XCTAssertNil(self.optimizelyClient.trackedEventTags)

    self.vm.inputs.pledgeCTAButtonTapped(with: .manage)

    XCTAssertEqual(self.optimizelyClient.trackedUserId, nil)
    XCTAssertEqual(self.optimizelyClient.trackedEventKey, nil)
    XCTAssertNil(self.optimizelyClient.trackedAttributes)
    XCTAssertNil(self.optimizelyClient.trackedEventTags)

    // Only track for non-backed, pledge state
    self.vm.inputs.pledgeCTAButtonTapped(with: .pledge)

    XCTAssertEqual(self.optimizelyClient.trackedUserId, "DEADBEEF-DEAD-BEEF-DEAD-DEADBEEFBEEF")
    XCTAssertEqual(self.optimizelyClient.trackedEventKey, "Project Page Rewards CTA Tapped")

    XCTAssertEqual(self.optimizelyClient.trackedAttributes?["user_backed_projects_count"] as? Int, nil)
    XCTAssertEqual(self.optimizelyClient.trackedAttributes?["user_launched_projects_count"] as? Int, nil)
    XCTAssertEqual(self.optimizelyClient.trackedAttributes?["user_country"] as? String, "us")
    XCTAssertEqual(self.optimizelyClient.trackedAttributes?["user_facebook_account"] as? Bool, nil)
    XCTAssertEqual(self.optimizelyClient.trackedAttributes?["user_display_language"] as? String, "en")

    XCTAssertEqual(self.optimizelyClient.trackedAttributes?["session_ref_tag"] as? String, "discovery")
    XCTAssertEqual(self.optimizelyClient.trackedAttributes?["session_referrer_credit"] as? String, "discovery")
    XCTAssertEqual(self.optimizelyClient.trackedAttributes?["session_os_version"] as? String, "MockSystemVersion")
    XCTAssertEqual(self.optimizelyClient.trackedAttributes?["session_user_is_logged_in"] as? Bool, false)
    XCTAssertEqual(self.optimizelyClient.trackedAttributes?["session_app_release_version"] as? String, "1.2.3.4.5.6.7.8.9.0")
    XCTAssertEqual(self.optimizelyClient.trackedAttributes?["session_apple_pay_device"] as? Bool, true)
    XCTAssertEqual(self.optimizelyClient.trackedAttributes?["session_device_format"] as? String, "phone")

    XCTAssertEqual(self.optimizelyClient.trackedEventTags?["project_subcategory"] as? String, "Art")
    XCTAssertEqual(self.optimizelyClient.trackedEventTags?["project_category"] as? String, nil)
    XCTAssertEqual(self.optimizelyClient.trackedEventTags?["project_country"] as? String, "us")
    XCTAssertEqual(self.optimizelyClient.trackedEventTags?["project_user_has_watched"] as? String, nil)
  }

  func testOptimizelyTrackingPledgeCTAButtonTapped_LoggedOut_Backed() {
    let project = Project.cosmicSurgery
      |> Project.lens.state .~ .live
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.reward .~ Reward.otherReward
          |> Backing.lens.rewardId .~ Reward.otherReward.id
          |> Backing.lens.shippingAmount .~ 10
          |> Backing.lens.amount .~ 700
      )

    self.vm.inputs.configureWith(projectOrParam: .left(project), refTag: .discovery)
    self.vm.inputs.viewDidLoad()

    XCTAssertEqual(self.optimizelyClient.trackedUserId, nil)
    XCTAssertEqual(self.optimizelyClient.trackedEventKey, nil)
    XCTAssertNil(self.optimizelyClient.trackedAttributes)
    XCTAssertNil(self.optimizelyClient.trackedEventTags)

    self.vm.inputs.pledgeCTAButtonTapped(with: .manage)

    XCTAssertEqual(self.optimizelyClient.trackedUserId, nil)
    XCTAssertEqual(self.optimizelyClient.trackedEventKey, nil)
    XCTAssertNil(self.optimizelyClient.trackedAttributes)
    XCTAssertNil(self.optimizelyClient.trackedEventTags)

    // Only track for non-backed, pledge state
    self.vm.inputs.pledgeCTAButtonTapped(with: .manage)

    // Project is backed, no tracking
    XCTAssertEqual(self.optimizelyClient.trackedUserId, nil)
    XCTAssertEqual(self.optimizelyClient.trackedEventKey, nil)
    XCTAssertNil(self.optimizelyClient.trackedAttributes)
    XCTAssertNil(self.optimizelyClient.trackedEventTags)
  }

  func testOptimizelyTrackingPledgeCTAButtonTapped_SeeTheRewards() {
    let project = Project.cosmicSurgery

    self.vm.inputs.configureWith(projectOrParam: .left(project), refTag: .discovery)
    self.vm.inputs.viewDidLoad()

    XCTAssertEqual(self.optimizelyClient.trackedEventKey, nil)

    self.vm.inputs.pledgeCTAButtonTapped(with: .seeTheRewards)

    XCTAssertEqual(self.optimizelyClient.trackedEventKey, "Project Page Rewards CTA Tapped")
  }

  func testOptimizelyTrackingPledgeCTAButtonTapped_ViewTheRewards() {
    let project = Project.cosmicSurgery

    self.vm.inputs.configureWith(projectOrParam: .left(project), refTag: .discovery)
    self.vm.inputs.viewDidLoad()

    XCTAssertEqual(self.optimizelyClient.trackedEventKey, nil)

    self.vm.inputs.pledgeCTAButtonTapped(with: .viewTheRewards)

    XCTAssertEqual(self.optimizelyClient.trackedEventKey, "Project Page Rewards CTA Tapped")
  }

  func testOptimizelyTrackingPledgeCTAButtonTapped_LoggedIn_NonBacked() {
    let user = User.template
      |> \.location .~ Location.template
      |> \.stats.backedProjectsCount .~ 50

    withEnvironment(currentUser: user) {
      self.vm.inputs.configureWith(projectOrParam: .left(.template), refTag: .discovery)
      self.vm.inputs.viewDidLoad()

      XCTAssertEqual(self.optimizelyClient.trackedUserId, nil)
      XCTAssertEqual(self.optimizelyClient.trackedEventKey, nil)
      XCTAssertNil(self.optimizelyClient.trackedAttributes)
      XCTAssertNil(self.optimizelyClient.trackedEventTags)

      self.vm.inputs.pledgeCTAButtonTapped(with: .manage)

      XCTAssertEqual(self.optimizelyClient.trackedUserId, nil)
      XCTAssertEqual(self.optimizelyClient.trackedEventKey, nil)
      XCTAssertNil(self.optimizelyClient.trackedAttributes)
      XCTAssertNil(self.optimizelyClient.trackedEventTags)

      // Only track for non-backed, pledge state
      self.vm.inputs.pledgeCTAButtonTapped(with: .pledge)

      XCTAssertEqual(self.optimizelyClient.trackedUserId, "DEADBEEF-DEAD-BEEF-DEAD-DEADBEEFBEEF")
      XCTAssertEqual(self.optimizelyClient.trackedEventKey, "Project Page Rewards CTA Tapped")

      XCTAssertEqual(self.optimizelyClient.trackedAttributes?["user_backed_projects_count"] as? Int, 50)
      XCTAssertEqual(self.optimizelyClient.trackedAttributes?["user_launched_projects_count"] as? Int, nil)
      XCTAssertEqual(self.optimizelyClient.trackedAttributes?["user_country"] as? String, "us")
      XCTAssertEqual(self.optimizelyClient.trackedAttributes?["user_facebook_account"] as? Bool, nil)
      XCTAssertEqual(self.optimizelyClient.trackedAttributes?["user_display_language"] as? String, "en")

      XCTAssertEqual(self.optimizelyClient.trackedAttributes?["session_ref_tag"] as? String, "discovery")
      XCTAssertEqual(self.optimizelyClient.trackedAttributes?["session_referrer_credit"] as? String, "discovery")
      XCTAssertEqual(self.optimizelyClient.trackedAttributes?["session_os_version"] as? String, "MockSystemVersion")
      XCTAssertEqual(self.optimizelyClient.trackedAttributes?["session_user_is_logged_in"] as? Bool, true)
      XCTAssertEqual(self.optimizelyClient.trackedAttributes?["session_app_release_version"] as? String, "1.2.3.4.5.6.7.8.9.0")
      XCTAssertEqual(self.optimizelyClient.trackedAttributes?["session_apple_pay_device"] as? Bool, true)
      XCTAssertEqual(self.optimizelyClient.trackedAttributes?["session_device_format"] as? String, "phone")

      XCTAssertEqual(self.optimizelyClient.trackedEventTags?["project_subcategory"] as? String, "Art")
      XCTAssertEqual(self.optimizelyClient.trackedEventTags?["project_category"] as? String, nil)
      XCTAssertEqual(self.optimizelyClient.trackedEventTags?["project_country"] as? String, "us")
      XCTAssertEqual(self.optimizelyClient.trackedEventTags?["project_user_has_watched"] as? Bool, nil)
    }
  }

  // swiftlint:enable line_length

  func testOptimizelyTrackingPledgeCTAButtonTapped_LoggedIn_Backed() {
    let user = User.template
      |> \.location .~ Location.template
      |> \.stats.backedProjectsCount .~ 50

    let project = Project.cosmicSurgery
      |> Project.lens.state .~ .live
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.reward .~ Reward.otherReward
          |> Backing.lens.rewardId .~ Reward.otherReward.id
          |> Backing.lens.shippingAmount .~ 10
          |> Backing.lens.amount .~ 700
      )

    withEnvironment(currentUser: user) {
      self.vm.inputs.configureWith(projectOrParam: .left(project), refTag: .discovery)
      self.vm.inputs.viewDidLoad()

      XCTAssertEqual(self.optimizelyClient.trackedUserId, nil)
      XCTAssertEqual(self.optimizelyClient.trackedEventKey, nil)
      XCTAssertNil(self.optimizelyClient.trackedAttributes)
      XCTAssertNil(self.optimizelyClient.trackedEventTags)

      self.vm.inputs.pledgeCTAButtonTapped(with: .manage)

      XCTAssertEqual(self.optimizelyClient.trackedUserId, nil)
      XCTAssertEqual(self.optimizelyClient.trackedEventKey, nil)
      XCTAssertNil(self.optimizelyClient.trackedAttributes)
      XCTAssertNil(self.optimizelyClient.trackedEventTags)

      // Only track for non-backed, pledge state
      self.vm.inputs.pledgeCTAButtonTapped(with: .manage)

      // Project is backed, no tracking
      XCTAssertEqual(self.optimizelyClient.trackedUserId, nil)
      XCTAssertEqual(self.optimizelyClient.trackedEventKey, nil)
      XCTAssertNil(self.optimizelyClient.trackedAttributes)
      XCTAssertNil(self.optimizelyClient.trackedEventTags)
    }
  }

  // MARK: - Functions

  private func configureInitialState(_ projectOrParam: Either<Project, Param>) {
    self.vm.inputs.configureWith(projectOrParam: projectOrParam, refTag: .discovery)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear(animated: false)
    self.vm.inputs.viewDidAppear(animated: false)
  }
}
