//
//  BottomSheetPresentationController.swift
//  bottom-sheet-delegate
//
//  Created by Granheim Brustad , Henrik on 01/11/2019.
//  Copyright © 2019 Henrik Brustad. All rights reserved.
//

import UIKit

extension BottomSheetPresentationController {
    enum TransitionState {
        case presenting
        case dismissing
    }
}

class BottomSheetPresentationController: UIPresentationController {

    // MARK: - Internal properties

    var transitionState: TransitionState = .presenting

    // MARK: - Private properties

    private let presenter: BottomSheetViewPresenter

    // MARK: - Init

    init(presentedViewController: UIViewController, presenting: UIViewController?, preferredHeights: [CGFloat]) {
        presenter = BottomSheetViewPresenter(preferredHeights: preferredHeights)
        presenter.isDimViewHidden = false
        super.init(presentedViewController: presentedViewController, presenting: presenting)
    }

    // MARK: - Transition life cycle

    override func presentationTransitionWillBegin() {
        guard let containerView = containerView else { return }
        guard let presentedView = presentedView else { return }

        presenter.delegate = self
        presenter.add(presentedView, to: containerView)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in self.presenter.reset() }, completion: nil)
    }
}

// MARK: - UIViewControllerAnimatedTransitioning

extension BottomSheetPresentationController: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        presenter.addAnimationCompletion { didComplete in
            transitionContext.completeTransition(didComplete)
        }

        switch transitionState {
        case .presenting:
            presenter.show()
        case .dismissing:
            presenter.hide()
        }
    }
}

// MARK: - UIViewControllerInteractiveTransitioning

extension BottomSheetPresentationController: UIViewControllerInteractiveTransitioning {
    func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        animateTransition(using: transitionContext)
    }
}

// MARK: - BottomSheetViewPresenterDelegate

extension BottomSheetPresentationController: BottomSheetViewPresenterDelegate {
    func bottomSheetViewPresenterDidReachDismissArea(_ presenter: BottomSheetViewPresenter) {
        presentedViewController.dismiss(animated: true)
    }
}
