//
//  NewsFeedServices.swift
//  VK_application
//
//  Created by Сергей Чумовских  on 26.10.2021.
//

import Foundation
import Alamofire

class NewsFeedServices {

    private let feedUrlPath = "https://api.vk.com/method/newsfeed.get"
    private let dispatchGroup = DispatchGroup()
    var dispatchQueueJsonResponse: NewsFeedResponse?
    
    func getNewsFeedPost(count: Int, startFrom: String? = nil, startTime: Double? = nil,
                           completion: @escaping (Result<NewsFeedResponse, SimpleServiceError>) -> Void){
        var paramters: Parameters = [
            "filters": "post",
            "count": "\(count)",
            "access_token": "\(UserSession.shared.token)",
            "v": "\(UserSession.shared.version)"
        ]
        if let startTime = startTime {
            paramters["start_time"] = startTime
               }
        if let startFrom = startFrom {
            paramters["start_from"] = startFrom
               }

        AF.request(feedUrlPath, method: .get, parameters: paramters).responseJSON { response in
            if let error = response.error {
                debugPrint("server Error!")
                debugPrint(error)
            }
            guard response.data != nil else {
                debugPrint("Error - not Data!")
                return
            }
            self.tryJson(data: response)
            self.dispatchGroup.notify(queue: DispatchQueue.main) {
                if let response = self.dispatchQueueJsonResponse {
                    completion(.success(response))
                } else {
                    completion(.failure(.decodeError))
                }
            }
        }
    }
    
    func tryJson(data: AFDataResponse<Any>) {
        DispatchQueue.global().async(group: dispatchGroup, qos: .utility) {
            do {
                let responseFeed = try JSONDecoder().decode(NewsFeedModel.self, from: data.data!)
                let feed = responseFeed.response
                self.dispatchQueueJsonResponse = feed
            } catch {
                debugPrint("DispatchQueue.global.async(group: dispatchGroup) JSON Decode ERROR")
                debugPrint(data.data!)
                self.dispatchQueueJsonResponse = nil
            }
        }
    }
}
