//
//  SwipingCollectionViewController.swift
//  ZaloChatApp
//
//  Created by huy on 12/10/2022.
//

import UIKit

private let reuseIdentifier = "Cell"

class SwipingCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { _ in
            self.collectionViewLayout.invalidateLayout()
            if self.pageControl.currentPage == 0 {
                self.collectionView?.contentOffset = .zero
            } else {
                let indexPath = IndexPath(item: self.pageControl.currentPage, section: 0)
                self.collectionView?.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            }
        })
    }

    let pages = [
        SwipePageModel(imageName: "swipingImage_1", headerText: "Gọi video ổn định", bodyText: "Trò chuyện thân mật với hình ảnh sắc nét, tiếng chất, âm chuẩn dưới mọi điều kiện mạng."),
        SwipePageModel(imageName: "swipingImage_2", headerText: "Chat nhóm tiện lợi", bodyText: "Cùng trao đổi, giữ liên lạc với gia đình, bạn bè và đồng nghiệp mọi lúc mọi nơi"),
        SwipePageModel(imageName: "swipingImage_3", headerText: "Gửi ảnh nhanh chóng", bodyText: "Chia sẻ hình ảnh chất lượng cao với bạn bè, người thân nhanh chóng và dễ dàng"),
        SwipePageModel(imageName: "swipingImage_4", headerText: "Nhật ký bạn bè", bodyText: "Nơi cập nhật hoạt động mới nhất của những người bạn quan tâm")
    ]
    
    private lazy var pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.currentPage = 0
        pc.numberOfPages = pages.count
        pc.currentPageIndicatorTintColor = .mainColor
        pc.pageIndicatorTintColor = .lightGray
        return pc
    }()

    override func viewDidLayoutSubviews() {
        let bottomControlsStackView = UIStackView(arrangedSubviews: [pageControl])
        bottomControlsStackView.translatesAutoresizingMaskIntoConstraints = false
        bottomControlsStackView.distribution = .fillEqually
        
        view.addSubview(bottomControlsStackView)
        
        NSLayoutConstraint.activate([
            bottomControlsStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
            bottomControlsStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            bottomControlsStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let x = targetContentOffset.pointee.x
        pageControl.currentPage = Int(x / view.frame.width)
        scrollView.showsHorizontalScrollIndicator = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.backgroundColor = .white
        collectionView?.register(PageViewCell.self, forCellWithReuseIdentifier: "cellId")
        collectionView?.isPagingEnabled = true
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as? PageViewCell else {
            return UICollectionViewCell()
        }
        let page = pages[indexPath.item]
        cell.page = page
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height)
    }
}
