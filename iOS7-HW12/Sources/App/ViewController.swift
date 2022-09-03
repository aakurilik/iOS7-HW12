//
//  ViewController.swift
//  iOS7-HW12
//
//  Created by Anatoly Kurilik on 30.08.22.
//

import UIKit
import SnapKit

class ViewController: UIViewController {

    // MARK: - Outlets

    private let screenSize: CGRect = UIScreen.main.bounds
    private let width = UIScreen.main.bounds.width
    private let height = UIScreen.main.bounds.height
    private let workTime = 25.0
    private let restTime = 5.0
    private lazy var timeCounter = workTime
    private var trackLayer = CAShapeLayer()
    private var progressLayer = CAShapeLayer()
    private var timer = Timer()
    private var isStarted = true
    private var isWorkTime = true

    private lazy var imageView: UIImageView = {
        let image = UIImage(named: "pom5")
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private lazy var labelMethod: UILabel = {
        let label = UILabel()
        label.text = "МЕТОД ПОМИДОРА"
        label.textColor = UIColor.darkGray
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 35)
        return label
    }()

    private lazy var labelBottom: UILabel = {
        let label = UILabel()
        label.text = "УПРАВЛЕНИЕ ВРЕМЕНЕМ, ВДОХНОВЕНИЕМ И КОНЦЕТРАЦИЕЙ"
        label.textColor = UIColor.gray
        label.numberOfLines = 2
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()

    private lazy var labelTimer: UILabel = {
        let label = UILabel()
        label.text = formatTimer()
        label.textColor = UIColor.systemRed
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 45, weight: .bold)
        return label
    }()

    private lazy var buttonReset: UIButton = {
        let button = UIButton()
        button.setTitle("RESET", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 22.0, weight: .bold)
        button.setTitleColor(UIColor.black, for: .normal)
        button.layer.cornerRadius = 15
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.5
        button.layer.shadowOffset = .zero
        button.layer.shadowRadius = 10
        button.layer.shouldRasterize = true
        button.layer.rasterizationScale = UIScreen.main.scale
        button.addTarget(self, action: #selector(buttonReseted), for: .touchUpInside)
        return button
    }()

    private lazy var buttonStart: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "playpause.fill")
        button.setImage(image, for: .normal)
        button.tintColor = UIColor.black
        button.layer.cornerRadius = 15
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.5
        button.layer.shadowOffset = .zero
        button.layer.shadowRadius = 10
        button.layer.shouldRasterize = true
        button.layer.rasterizationScale = UIScreen.main.scale
        button.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var viewCircle: UIView = {
        let circle = UIView()
        circle.backgroundColor = .clear
        return circle
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 254/255, green: 249/255, blue: 231/255, alpha: 1)
        setupHierarchy()
        setupLayout()
        makeShapeLayer()
    }

    // MARK: - Setup

    private func setupHierarchy() {
        view.addSubviews([
            imageView,
            labelMethod,
            buttonReset,
            buttonStart,
            labelTimer,
            viewCircle,
            labelBottom
        ])
    }

    private func makeShapeLayer() {
        let circularPath = UIBezierPath(
            arcCenter: viewCircle.center,
            radius: 100,
            startAngle: -CGFloat.pi / 2,
            endAngle: 3 / 2 * CGFloat.pi, clockwise: true
        )

        trackLayer.path = circularPath.cgPath
        trackLayer.lineCap = CAShapeLayerLineCap.round
        trackLayer.lineWidth = 13
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.strokeColor = UIColor.systemRed.cgColor
        viewCircle.layer.addSublayer(trackLayer)

        progressLayer.path = circularPath.cgPath
        progressLayer.lineCap = CAShapeLayerLineCap.round
        progressLayer.lineWidth = 12
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = UIColor.systemGray5.cgColor
        progressLayer.strokeEnd = 0
        viewCircle.layer.addSublayer(progressLayer)
    }

    private func animationCircular() {
        let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        basicAnimation.toValue = 1
        basicAnimation.speed = 1
        basicAnimation.duration = CFTimeInterval(timeCounter)
        basicAnimation.fillMode = CAMediaTimingFillMode.forwards
        basicAnimation.isRemovedOnCompletion = true
        progressLayer.add(basicAnimation, forKey: "basicAnimation")
    }

    private func stopAnimation() {
        progressLayer.speed = 1
        progressLayer.timeOffset = 0
        progressLayer.beginTime = 0
        progressLayer.strokeEnd = 0
        progressLayer.removeAllAnimations()
    }

    private func pausedAnimation() {
        let pausedTime = progressLayer.convertTime(CACurrentMediaTime(), from: nil)
        progressLayer.speed = 0
        progressLayer.timeOffset = pausedTime
    }

    private func resumeAnimation() {
        let pausedTime = progressLayer.timeOffset
        progressLayer.speed = 1
        progressLayer.timeOffset = 0
        progressLayer.beginTime = 0
        let timeSincePaused = progressLayer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        progressLayer.beginTime = timeSincePaused
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }

    private func formatTimer() -> String {
        let minutes = Int(timeCounter) / 60 % 60
        let seconds = Int(timeCounter) % 60
        return String(format: "%02i:%02i", minutes, seconds)
    }

    private func changeState() {
        if isWorkTime {
            buttonStart.tintColor = UIColor.systemGreen
            labelTimer.textColor = UIColor.systemGreen
            trackLayer.strokeColor = UIColor.systemGreen.cgColor
            return
        }
        buttonStart.tintColor = UIColor.systemRed
        labelTimer.textColor = UIColor.systemRed
        trackLayer.strokeColor = UIColor.systemRed.cgColor
    }

    private func setupLayout() {
        imageView.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.left.equalTo(view).offset(0)
            make.right.equalTo(view).offset(0)
            make.height.equalTo(height * 0.45)
        }

        labelMethod.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.bottom.equalTo(imageView).offset(25)
        }

        buttonReset.snp.makeConstraints { make in
            make.left.equalTo(view).offset(50)
            make.bottom.equalTo(labelBottom).offset(-height * 0.1)
            make.width.equalTo(100)
        }

        buttonStart.snp.makeConstraints { make in
            make.right.equalTo(view).offset(-40)
            make.bottom.equalTo(labelBottom).offset(-height * 0.11)
            make.width.equalTo(100)
        }

        labelTimer.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.bottom.equalTo(labelMethod).offset(height * 0.21)
        }

        viewCircle.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.bottom.equalTo(labelMethod).offset(height * 0.18)
        }

        labelBottom.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.left.equalTo(view).offset(65)
            make.right.equalTo(view).offset(-70)
            make.bottom.equalTo(view).offset(-height * 0.02)
        }
    }

    // MARK: - Actions

    @objc private func updateTimer() {
        timeCounter -= 0.01
        labelTimer.text = formatTimer()

        guard timeCounter <= 0 else { return }

        timeCounter = isWorkTime ? restTime : workTime

        changeState()
        animationCircular()
        isWorkTime.toggle()
    }

    @objc private func buttonReseted() {
        stopAnimation()
        buttonReset.isEnabled = false
        buttonReset.alpha = 0.5
        timer.invalidate()
        timeCounter = workTime
        labelTimer.text = formatTimer()
        let image = UIImage(systemName: "playpause.fill")
        buttonStart.setImage(image, for: .normal)
        buttonStart.tintColor = UIColor.black
        labelTimer.textColor = UIColor.systemGray
        trackLayer.strokeColor = UIColor.systemRed.cgColor
        isWorkTime = true
        isStarted = true
    }

    @objc private func startButtonTapped() {
        buttonReset.isEnabled = true
        buttonReset.alpha = 1.0

        guard isStarted else {
            let image = UIImage(systemName: "play.fill")
            buttonStart.setImage(image, for: .normal)

            if isWorkTime {
                buttonStart.tintColor = UIColor.systemRed
                isWorkTime = true
            } else {
                buttonStart.tintColor = UIColor.systemGreen
                isWorkTime = false
            }

            timer.invalidate()
            pausedAnimation()
            isStarted = true
            return
        }

        let image = UIImage(systemName: "pause.fill")
        buttonStart.setImage(image, for: .normal)
        timer = Timer.scheduledTimer(
            timeInterval: 0.01,
            target: self,
            selector: #selector(updateTimer),
            userInfo: nil,
            repeats: true
        )

        if isWorkTime {
            timeCounter == workTime ? animationCircular() : resumeAnimation()

            buttonStart.tintColor = UIColor.systemRed
            labelTimer.textColor = UIColor.systemRed
            isWorkTime = true
        } else {
            timeCounter == restTime ? animationCircular() : resumeAnimation()

            buttonStart.tintColor = UIColor.systemGreen
            labelTimer.textColor = UIColor.systemGreen
            isWorkTime = false
        }
        isStarted = false
    }
}

// MARK: - Extensions

extension UIView {
    func addSubviews(_ subviews: [UIView]) {
        subviews.forEach { addSubview($0) }
    }
}
