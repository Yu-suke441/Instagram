//
//  CommentViewController.swift
//  Instagram
//
//  Created by Yusuke Murayama on 2020/11/24.
//  Copyright © 2020 Yusuke.Murayama. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class CommentViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate {
    
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var commentTextView: UITextView!
    
    let SCREEN_SIZE = UIScreen.main.bounds.size
    
    var postData : PostData?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        
        let nib = UINib(nibName: "PostTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")
        
        // 背景をタップしたらdismissKeyboardメソッドを呼ぶように設定
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        
        commentTextView.layer.borderWidth = 1.0   //ボーダーの幅
        
        commentTextView.layer.borderColor = UIColor.lightGray.cgColor
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        //KeyboardWillHideという名前の通知のイベントをオブザーバー登録する
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    @IBAction func postCommentButton(_ sender: Any) {
        if let userName = Auth.auth().currentUser?.displayName {
            postData?.commentName.append(userName)
            postData?.comment.append(self.commentTextView.text!)
            
            print("DEBUG_PRINT:" ,postData!.comment, postData!.commentName)
            
            
            let postRef = Firestore.firestore().collection(Const.PostPath).document(postData!.id)
            let commentDic = [ "commentName": postData?.commentName, "comment": postData?.comment
            ]
            postRef.updateData(commentDic as [AnyHashable : Any])
            
            //HUDで投稿完了を表示する
            SVProgressHUD.showSuccess(withStatus: "コメントを投稿しました")
            
            print("DEBUG_PRINT: コメント投稿完了")
            
            // 投稿処理が完了したので先頭画面に戻る
            UIApplication.shared.windows.first{ $0.isKeyWindow }?.rootViewController?.dismiss(animated: true, completion: nil)
        }
        
    }
    
    @objc func dismissKeyboard() {
        // キーボードを閉じる
        view.endEditing(true)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        commentTextView.text = "コメント入力してください"
        commentTextView.textColor = UIColor.lightGray
        commentTextView.delegate = self
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if commentTextView.textColor == UIColor.lightGray {
            commentTextView.text = nil
            commentTextView.textColor = UIColor.black
        }
    }
    
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if commentTextView.text.isEmpty {
            commentTextView.text = "コメントを入力してください"
            commentTextView.textColor = UIColor.lightGray
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            } 
        }
    }
    
    @objc func keyboardWillHide() {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostTableViewCell
        
        cell.setPostData(postData!)
        return cell
    }

    
}
