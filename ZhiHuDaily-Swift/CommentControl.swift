//
//  CommentControl.swift
//  ZhiHuDaily-Swift
//
//  Created by SUN on 15/6/11.
//  Copyright (c) 2015年 SUN. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class CommentControl {
    
    /// 加载 长评论
    func loadLongComments(id:Int,complate:(longComments:[CommentVO]?)->Void,block:((error:NSError)->Void)? = nil){
        
        Alamofire.Manager.sharedInstance.request(Method.GET,COMMENTS_URL+"\(id)/long-comments", parameters: nil, encoding: ParameterEncoding.URL).responseJSON(options: NSJSONReadingOptions.MutableContainers){ (_, _, data, error) -> Void in
            if let result: AnyObject = data {
                //转换成JSON
                let json = JSON(result)
                
                complate(longComments: self.convertJSON2VO(json))
            }
        }
    }
    
    /// 加载 短评论
    func loadShortComments(id:Int,complate:(shortComments:[CommentVO]?)->Void,block:((error:NSError)->Void)? = nil){
        
        Alamofire.Manager.sharedInstance.request(Method.GET,COMMENTS_URL+"\(id)/short-comments", parameters: nil, encoding: ParameterEncoding.URL).responseJSON(options: NSJSONReadingOptions.MutableContainers) { (_, _, data, error) -> Void in
            if let result: AnyObject = data {
                //转换成JSON
                let json = JSON(result)
                
                complate(shortComments: self.convertJSON2VO(json))
            }
        }
        
    }
    
    private func convertJSON2VO(json:JSON) -> [CommentVO]? {
        
        if  let comments = json["comments"].array {
            var vos:[CommentVO] = []
            for comment in comments {
                let author = comment["author"].string!
                let content = comment["content"].string!
                let avatar = comment["avatar"].string
                let time = comment["time"].int!
                let id = comment["id"].int!
                let likes = comment["likes"].int!
                
                let replay = comment["reply_to"]
                
                let vo = CommentVO(author: author, content: content, avatar: avatar, time: time, id: id, likes: likes)
                
                vos.append(vo)
                
                if replay.null == nil{
                    //表示有引用
                    let _content = replay["content"].string!
                    let _status = replay["status"].int!
                    let _id = replay["id"].int!
                    let _author = replay["author"].string!
                    
                    vo.replayTo = RefCommentVO(id: _id, author: _author, content: _content, status: _status)
                }
            }
            return vos
        }
        return nil
    }
    
}