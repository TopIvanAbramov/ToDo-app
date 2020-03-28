//
//  CustomTableViewCell.swift
//  ToDO
//
//  Created by Иван on 17.02.2020.
//  Copyright © 2020 Ivan Abramov. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
    
    weak var coverView: UIImageView!
    weak var titleLabel: UILabel!
    weak var time : UILabel!
    var timer : Timer?
    var timeCounter: Double = 0
    var totaTime : Double = 0
    var color : UIColor!
    weak var progressView : UIProgressView!
    let colorDict = ["red" :  UIColor.red,  "green" : UIColor.green, "yellow" : UIColor.yellow]
    
        func setColor(priority : Int) {
            let defaults = UserDefaults.standard
            let selectedUrgentColor = colorDict[defaults.string(forKey: "urgent")!]
            let selectedNotUrgentColor =  colorDict[defaults.string(forKey: "noturgent")!]
        
                
            color = priority == 0 ? selectedNotUrgentColor : selectedUrgentColor
            self.progressView.tintColor = color.withAlphaComponent(0.2)
        }
    
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            self.initialize()
        }

        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)

            self.initialize()
        }

        func initialize() {
            
            let titleLabel = UILabel(frame: .zero)
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            self.titleLabel = titleLabel
            titleLabel.numberOfLines = 0
            
            let time = UILabel(frame: .zero)
            time.translatesAutoresizingMaskIntoConstraints = false
            self.time = time
            
            let coverView = UIImageView(frame: .zero)
            coverView.alpha = 0.2
            coverView.translatesAutoresizingMaskIntoConstraints = false
            self.coverView = coverView
            
            let progressView = UIProgressView(progressViewStyle: .bar)
            self.progressView = progressView
            progressView.translatesAutoresizingMaskIntoConstraints =  false
//            progressView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: 100)
            
            progressView.transform =  progressView.transform.scaledBy(x: 1, y: self.frame.height / 2.0 + 20.0)
//            progressView.tintColor =  priority == 0 ? .green : .red
            
//            print("Priority: \(priority!)")

            //Add subviews
//            self.contentView.addSubview(coverView)
            self.contentView.addSubview(progressView)
            self.contentView.addSubview(titleLabel)
            self.contentView.addSubview(time)
            
            NSLayoutConstraint.activate([
//                self.contentView.topAnchor.constraint(equalTo: self.progressView.topAnchor),
//                self.contentView.bottomAnchor.constraint(equalTo: self.progressView.bottomAnchor),
//                self.contentView.leadingAnchor.constraint(equalTo: self.progressView.leadingAnchor),
//                self.contentView.trailingAnchor.constraint(equalTo: self.progressView.trailingAnchor),
    
                self.progressView.widthAnchor.constraint(equalTo: self.contentView.widthAnchor, multiplier: 1.0),
                
                self.contentView.trailingAnchor.constraint(equalTo: self.time.trailingAnchor, constant: 20),
                self.time.widthAnchor.constraint(equalToConstant: CGFloat(integerLiteral: 80)),
                self.contentView.centerYAnchor.constraint(equalTo: self.time.centerYAnchor),

                self.titleLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 20),
                self.titleLabel.trailingAnchor.constraint(equalTo: self.time.leadingAnchor, constant: -15),
                self.contentView.centerYAnchor.constraint(equalTo: self.titleLabel.centerYAnchor),
//                self.titleLabel.trailingAnchor.constraint(equalTo: self.time.leadingAnchor, constant: 120)
            ])
            

            self.titleLabel.adjustsFontSizeToFitWidth = true
            self.time.adjustsFontSizeToFitWidth = true
        }

    override func prepareForReuse() {
            super.prepareForReuse()
            timer?.invalidate()
            timer = nil
//            self.coverView.image = nil
        }
    
    
    
    
    var expiryTimeInterval: TimeInterval? {
        didSet {
            startTimer()
        }
    }

    private func startTimer() {
        if let interval = expiryTimeInterval {
            timeCounter = interval
            if #available(iOS 10.0, *) {
                timer = Timer(timeInterval: 1.0,
                              repeats: true,
                              block: { [weak self] _ in
                                guard let strongSelf = self else {
                                    return
                                }
                                strongSelf.onComplete()
                })
            } else {
                timer = Timer(timeInterval: 1.0,
                              target: self,
                              selector: #selector(onComplete),
                              userInfo: nil,
                              repeats: true)
            }
        }
        RunLoop.current.add(timer!, forMode: .common)
    }

    @objc func onComplete() {
//        print("Time counter: \(timeCounter)")
        guard timeCounter > 0 else {
            timer?.invalidate()
            timer = nil
            self.time.text = "Time ended"
            self.progressView.setProgress(1.0, animated: true)
            return
        }
        
//        print("\(timer!.timeInterval / timeCounter * 100), \(timer!.timeInterval),  \(timeCounter)")
        
        let percent = 1  - Float(timeCounter /  totaTime)
//        print("Current percent: \(percent)")
        
        progressView.setProgress(percent, animated: true)

       //constraint(equalToConstant: (CGFloat(self.frame.width) * CGFloat(percent)))])
        let (h,m,s) = secondsToHoursMinutesSeconds(seconds: Int(timeCounter))
        time.text = "\(h)h \(m)m \(s)s"
        timeCounter -= 1
    }
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
      return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    var redRectWidthConstraint: NSLayoutConstraint?
    
    func animate(time : Double) {
           UIView.animate(withDuration: time, animations: {
//            print("\n\nAnimation\n\n")
            
            self.redRectWidthConstraint?.constant = 100//self.frame.width
               self.contentView.setNeedsLayout()
           }, completion: {
               finished in
           })

       }
}
