//
//  BigImageNewsVC.swift
//  VK_application
//
//  Created by Сергей Чумовских  on 08.08.2021.
//

import UIKit

class BigImageNewsVC: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var bigImageView: UIImageView!
    
    var imageName: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.tabBar.isHidden = true
        navigationController?.navigationBar.isHidden = true
        setImage()
        setGesture()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
        navigationController?.navigationBar.isHidden = false
    }
    
    private func setImage() {
        bigImageView.image = UIImage(named: imageName)
        bigImageView.frame = UIScreen.main.bounds
        bigImageView.backgroundColor = UIColor.clear
    }
    
    private func setGesture() {
        // показать/скрыть навигацию
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap))
        singleTap.numberOfTapsRequired = 1
        bigImageView.addGestureRecognizer(singleTap)
        
        // Double Tap (Like)
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
        doubleTap.numberOfTapsRequired = 2
        bigImageView.addGestureRecognizer(doubleTap)
        // обработка двойного или одиночного нажатия
        singleTap.require(toFail: doubleTap)
        singleTap.delaysTouchesBegan = true
        doubleTap.delaysTouchesBegan = true
        
        // вернуться на предыдущий экран
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(swipeToUp))
        swipeUp.direction = .up
        bigImageView.addGestureRecognizer(swipeUp)
        
        // перемещение изображения
        let panGR = UIPanGestureRecognizer(target: self, action: #selector(didPan))
        // управление двумя пальцами
        panGR.minimumNumberOfTouches = 2
        panGR.maximumNumberOfTouches = 2
        // делегат для реализации нескольких гестур одновременно
        panGR.delegate = self
        bigImageView.addGestureRecognizer(panGR)
        
        // масштабирование щипками
        let pinchGR = UIPinchGestureRecognizer(target: self, action: #selector(didPinch))
        // делегат для реализации нескольких гестур одновременно
        pinchGR.delegate = self
        bigImageView.addGestureRecognizer(pinchGR)
    }
    
//MARK: - UIGesture
    
    // по тапу показать/скрыть навигацию
    @objc func handleSingleTap(sender: UITapGestureRecognizer) {
        tabBarController?.tabBar.isHidden.toggle()
        navigationController?.navigationBar.isHidden.toggle()
    }
    
    // добавить/убрать лайк фотографии
    @objc func handleDoubleTap() {
        print("Like photo \(imageName)")
    }
    
    // по свайпу вверх можно вернуться назад
    @objc func swipeToUp() {
        bigImageView.isHidden = true
        self.navigationController?.popViewController(animated: true)
    }
    
    // перемещение изображения
    @objc func didPan(panGR: UIPanGestureRecognizer) {
        bigImageView.bringSubviewToFront(bigImageView)
        var translation = panGR.translation(in: bigImageView)
        switch panGR.state {
        case .ended:
            animation()
        case .changed:
            translation = translation.applying(bigImageView.transform)
            bigImageView.center.x += translation.x
            bigImageView.center.y += translation.y
            panGR.setTranslation(CGPoint.zero, in: bigImageView)
        default:
            return
        }
    }
    
    // масштабирование изображения
    @objc func didPinch(pinchGR: UIPinchGestureRecognizer) {
        bigImageView.bringSubviewToFront(bigImageView)
        let scale = pinchGR.scale
        switch pinchGR.state {
        case .changed:
            bigImageView.transform = bigImageView.transform.scaledBy(x: scale, y: scale)
            pinchGR.scale = 1.0
        case .ended:
            animation()
        default:
            return
        }
    }
    
    // нужно true для возможности использовать сразу несколько гестур (по дефолту false)
    func gestureRecognizer(_: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith
                            shouldRecognizeSimultaneouslyWithGestureRecognizer:UIGestureRecognizer) -> Bool {
        return true
    }
    
//MARK: - Animation
    
    // анимация возвращения в исходное состояние
    private func animation(){
        UIView.animate(
            withDuration: 0.15,
            animations: { [unowned self] in
                self.bigImageView.transform = CGAffineTransform.identity
                self.bigImageView.frame = UIScreen.main.bounds
            } )
    }
    
}